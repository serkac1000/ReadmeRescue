@echo off
echo ========================================
echo Python Installation Diagnosis and Fix
echo ========================================
echo.

echo Testing different Python commands...
echo.

echo 1. Testing "python":
python --version 2>nul
if errorlevel 1 (
    echo   FAILED: python command not working properly
) else (
    echo   SUCCESS: python command works
)

echo.
echo 2. Testing "py" (Python Launcher):
py --version 2>nul
if errorlevel 1 (
    echo   FAILED: py launcher not available
) else (
    echo   SUCCESS: py launcher works
    echo   Available Python versions:
    py -0
    echo.
    echo   SOLUTION: Use "py" instead of "python"
    echo   Example: py -m pip install Flask
    goto :use_py_launcher
)

echo.
echo 3. Testing "python3":
python3 --version 2>nul
if errorlevel 1 (
    echo   FAILED: python3 command not available
) else (
    echo   SUCCESS: python3 command works
)

echo.
echo DIAGNOSIS: Your Python installation appears to be corrupted or misconfigured.
echo.
echo SOLUTIONS:
echo 1. Completely uninstall Python and reinstall from https://python.org
echo 2. During installation, check "Add Python to PATH"
echo 3. Choose "Install for all users" if you have admin rights
echo.
echo Alternative: Try using Windows Store Python:
echo 1. Open Microsoft Store
echo 2. Search for "Python 3.12"
echo 3. Install the official Python from Microsoft Store
echo.
pause
exit /b 1

:use_py_launcher
echo Installing packages using py launcher...
py -m pip install --upgrade pip
py -m pip install Flask==2.3.0 Werkzeug==2.3.0 SpeechRecognition==3.10.0

echo.
echo Creating directories...
if not exist "uploads" mkdir uploads
if not exist "output" mkdir output

echo.
echo Starting application with py launcher...
py app.py

pause