@echo off
echo Testing Python paths for your system...
echo.

echo Testing: C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe
"C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" --version
if errorlevel 1 (
    echo FAILED: Python not found at this path
) else (
    echo SUCCESS: Python found!
)

echo.
echo Testing: %USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe
"%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" --version
if errorlevel 1 (
    echo FAILED: Python not found at this path
) else (
    echo SUCCESS: Python found!
)

echo.
echo Current user: %USERNAME%
echo User profile: %USERPROFILE%
echo.

pause