go mod edit -replace github.com/mattn/go-localereader@v0.0.1=github.com/mattn/go-localereader@v0.0.2-0.20220822084749-2491eb6c1c75 || exit 1
go mod tidy || exit 1

cmake %CMAKE_ARGS% -B build -DOLLAMA_VERSION=%PKG_VERSION% . || exit 1
cmake --build build || exit 1
cmake --install build --strip || exit 1

go-licenses save . --save_path="%SRC_DIR%/license-files/" || exit 1
