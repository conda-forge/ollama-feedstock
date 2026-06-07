go mod edit -replace github.com/mattn/go-localereader@v0.0.1=github.com/mattn/go-localereader@v0.0.2-0.20220822084749-2491eb6c1c75 || exit 1
go mod tidy || exit 1

cmake %CMAKE_ARGS% --preset CPU || exit 1
cmake --build --preset CPU || exit 1
cmake --install build --component CPU --strip || exit 1


go build -ldflags "-s -w -X=github.com/ollama/ollama/version.Version=${PKG_VERSION} -X=github.com/ollama/ollama/server.mode=release" -trimpath -buildmode=pie -o %LIBRARY_BIN%\ollama.exe . || exit 1

go-licenses save . --save_path="%SRC_DIR%/license-files/" || exit 1
