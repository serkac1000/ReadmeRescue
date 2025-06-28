@echo off
echo Installing Flask for Windows...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python not found. Please install Python first.
    echo Download from: https://python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo Python found. Installing Flask...
pip install flask
if %errorlevel% neq 0 (
    echo Failed with pip. Trying pip3...
    pip3 install flask
)

echo Installing from requirements file...
if exist windows_requirements.txt (
    pip install -r windows_requirements.txt
) else (
    echo Installing individual packages...
    pip install werkzeug pillow gunicorn
)

echo.
echo Flask installation complete!
echo.
echo To run the application:
echo 1. python app.py
echo 2. Open browser to http://localhost:5000
echo.
pause