#!/bin/bash
set -ex

if [[ "$target_platform" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ -z "$cuda_compiler_version" ]]; then
    cmake ${CMAKE_ARGS} --preset 'CPU' \
        && cmake --build --preset 'CPU' \
        && cmake --install build --component CPU --strip
else
  case "$cuda_compiler_version" in
    11.*)
      cmake ${CMAKE_ARGS} --preset 'CUDA 11' \
          && cmake --build --preset 'CUDA 11' \
          && cmake --install build --component CUDA --strip
          ;;
    12.*)
      cmake ${CMAKE_ARGS} --preset 'CUDA 12' \
          && cmake --build --preset 'CUDA 12' \
          && cmake --install build --component CUDA --strip
          ;;
    *)
      echo "unsupported cuda version"
      exit 1
  esac
fi

go build -trimpath -buildmode=pie -ldflags="-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release" -o $PREFIX/bin/ollama .

go-licenses save . --save_path="$SRC_DIR/license-files/" 
