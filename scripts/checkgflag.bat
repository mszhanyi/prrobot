set GFLAGS_EXE="C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\gflags.exe"
echo %GFLAGS_EXE%
if exist %GFLAGS_EXE% (
    echo Some smoke tests
    %GFLAGS_EXE% /i python.exe +sls
    python -c "import numpy as np"
    if ERRORLEVEL 1 exit /b 1

    %GFLAGS_EXE% /i python.exe -sls
    if ERRORLEVEL 1 exit /b 1
)