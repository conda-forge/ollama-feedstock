#!/bin/bash
set -ex

if [[ "$target_platform" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# The CUDA 12 variant uses the nocgo go toolchain (see recipe.yaml), whose
# activation sets CGO_ENABLED=0. ollama needs cgo, so enable it everywhere.
export CGO_ENABLED=1

# go-localereader v0.0.1 doesn't compile on Windows; replace with a patched fork.
go mod edit -replace github.com/mattn/go-localereader@v0.0.1=github.com/mattn/go-localereader@v0.0.2-0.20220822084749-2491eb6c1c75
go mod tidy

CMAKE_BACKEND_ARGS=()
if [[ ${cuda_compiler_version} != "None" ]]; then
  if [[ ${cuda_compiler_version} == 12.* ]]; then
    CMAKE_BACKEND_ARGS=(-DOLLAMA_LLAMA_BACKENDS=cuda_v12)
  elif [[ ${cuda_compiler_version} == 13.* ]]; then
    CMAKE_BACKEND_ARGS=(-DOLLAMA_LLAMA_BACKENDS=cuda_v13)
  else
    echo "unsupported cuda version"
    exit 1
  fi
fi

cmake ${CMAKE_ARGS} -B build \
    -DOLLAMA_VERSION="${PKG_VERSION}" \
    -DOLLAMA_MLX_BACKENDS= \
    -DHOST_CXX_COMPILER="${CXX}" \
    "${CMAKE_BACKEND_ARGS[@]}" \
    .
cmake --build build --parallel ${CPU_COUNT}
cmake --install build --strip

go-licenses save . --save_path="$SRC_DIR/license-files/"
