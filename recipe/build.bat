go mod edit -replace github.com/mattn/go-localereader@v0.0.1=github.com/mattn/go-localereader@v0.0.2-0.20220822084749-2491eb6c1c75 || exit 1
go mod tidy || exit 1

set CMAKE_GENERATOR=Ninja

set "CMAKE_BACKEND_ARGS="
echo %cuda_compiler_version% | findstr /b "12" >nul && set "CMAKE_BACKEND_ARGS=-DOLLAMA_LLAMA_BACKENDS=cuda_v12"
echo %cuda_compiler_version% | findstr /b "13" >nul && set "CMAKE_BACKEND_ARGS=-DOLLAMA_LLAMA_BACKENDS=cuda_v13"

cmake %CMAKE_ARGS% -B build -DOLLAMA_VERSION=%PKG_VERSION% -DOLLAMA_MLX_BACKENDS= -DOLLAMA_GO_OUTPUT=%LIBRARY_BIN%\ollama.exe %CMAKE_BACKEND_ARGS% . || exit 1
cmake --build build --parallel || exit 1
cmake --install build || exit 1

rem go-licenses 1.6 identifies stdlib packages by checking whether their files
rem are under build.Default.GOROOT. The win go 1.27 package sets GOROOT with
rem forward slashes (env_vars.d), so it never prefix-matches native paths.
rem Normalize the separators and verify the stdlib is there.
set "GOROOT=%GOROOT:/=\%"
echo GOROOT=%GOROOT%
if not exist "%GOROOT%\src\fmt" (echo stdlib not found under GOROOT & exit 1)
go-licenses save . --save_path="%SRC_DIR%/license-files/" || exit 1
