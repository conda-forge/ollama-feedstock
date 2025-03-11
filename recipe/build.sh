#!/bin/bash
set -ex

if [ "$(uname)" == 'Darwin' ];
then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ ${cuda_compiler_version} != "None" ]]; then
  if [[ ${cuda_compiler_version} == 11.8 ]]; then
    cmake ${CMAKE_ARGS} --preset 'CUDA 11' \
        && cmake --build --preset 'CUDA 11' \
        && cmake --install build --component CUDA --strip
  elif [[ ${cuda_compiler_version} == 12.0 || ${cuda_compiler_version} == 12.6 ]]; then
    cmake ${CMAKE_ARGS} --preset 'CUDA 12' \
        && cmake --build --preset 'CUDA 12' \
        && cmake --install build --component CUDA --strip
  else
    echo "unsupported cuda version"
    exit 1
  fi
else
    cmake ${CMAKE_ARGS} --preset 'CPU' \
        && cmake --build --preset 'CPU' \
        && cmake --install build --component CPU --strip
fi


export CGO_ENABLED=1
go build -trimpath -buildmode=pie -ldflags="-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release" -o $PREFIX/bin/ollama .

go-licenses save . --save_path="$SRC_DIR/license-files/" 
