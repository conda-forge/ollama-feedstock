#!/bin/bash
set -ex

build_and_install() {
    local preset="$1"
    local component="$2"
    cmake ${CMAKE_ARGS} --preset "$preset" \
        && cmake --build --preset "$preset" \
        && cmake --install build --component "$component" --strip
}

if [[ "$target_platform" == osx-* ]]; then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi
export CMAKE_BUILD_PARALLEL_LEVEL=1

if [[ -z "$cuda_compiler_version" || "$cuda_compiler_version" == "None" ]]; then
    build_and_install "CPU" "CPU"
else
  case "$cuda_compiler_version" in
    11.*) build_and_install "CUDA 11" "CUDA" ;;
    12.*) build_and_install "CUDA 12" "CUDA" ;;
    *)
      echo "unsupported cuda version"
      exit 1
  esac
fi

go build -trimpath -buildmode=pie -ldflags="-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release" -o $PREFIX/bin/ollama .

go-licenses save . --save_path="$SRC_DIR/license-files/" 
