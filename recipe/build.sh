if [ "$(uname)" == 'Darwin' ];
then
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake --preset 'CPU' \
    && cmake --build --parallel --preset 'CPU' \
    && cmake --install build --component CPU --strip --parallel 8


export GOFLAGS="'-ldflags=-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release'"
export CGO_ENABLED=1
go build -trimpath -buildmode=pie -o $PREFIX/bin/ollama .

go-licenses save . --save_path="$SRC_DIR/license-files/" 
