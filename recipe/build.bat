cmake %CMAKE_ARGS% --preset CPU || exit 1
cmake --build --parallel --preset CPU || exit 1
cmake --install build --component CPU --strip --parallel 8 || exit 1


set CGO_ENABLED=1
go build -ldflags "-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release" -trimpath -buildmode=pie -o %LIBRARY_BIN%\ollama.exe . || exit 1

go-licenses save . --save_path="%SRC_DIR%/license-files/" || exit 1
