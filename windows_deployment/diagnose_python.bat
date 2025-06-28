@echo off
echo ====================================
echo Python Installation Diagnostic Tool
echo ====================================
echo.

echo Current User: %USERNAME%
echo User Profile: %USERPROFILE%
echo.

echo Testing possible Python locations:
echo.

echo 1. Testing: python (from PATH)
python --version 2>nul
if errorlevel 1 (
    echo   FAILED: python command not found in PATH
) else (
    echo   SUCCESS: python found in PATH
    where python
)

echo.
echo 2. Testing: C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312\python.exe
if exist "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312\python.exe" (
    echo   File exists - testing execution...
    "C:\Users\%USERNAME%\AppData\Local\Programs\Python\Python312\python.exe" --version 2>nul
    if errorlevel 1 (
        echo   FAILED: File exists but cannot execute
    ) else (
        echo   SUCCESS: Python 3.12 found and working
    )
) else (
    echo   FAILED: File does not exist
)

echo.
echo 3. Testing: C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe
if exist "C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" (
    echo   File exists - testing execution...
    "C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" --version 2>nul
    if errorlevel 1 (
        echo   FAILED: File exists but cannot execute
    ) else (
        echo   SUCCESS: Python 3.12 found and working
    )
) else (
    echo   FAILED: File does not exist at this specific path
)

echo.
echo 4. Testing: %USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe
if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" (
    echo   File exists - testing execution...
    "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" --version 2>nul
    if errorlevel 1 (
        echo   FAILED: File exists but cannot execute
    ) else (
        echo   SUCCESS: Python 3.12 found and working
    )
) else (
    echo   FAILED: File does not exist
)

echo.
echo 5. Searching for python.exe in common locations...
for /r "C:\Users\%USERNAME%\AppData\Local\Programs" %%f in (python.exe) do (
    if exist "%%f" (
        echo   Found: %%f
        "%%f" --version 2>nul
        if not errorlevel 1 echo   ^(Working^)
    )
)

echo.
echo 6. Checking Python Launcher
py --version 2>nul
if errorlevel 1 (
    echo   FAILED: py launcher not available
) else (
    echo   SUCCESS: py launcher found
    py -0
)

echo.
echo ====================================
echo Diagnostic complete. 
echo Please share the results above to get the correct installation path.
echo ====================================
pause