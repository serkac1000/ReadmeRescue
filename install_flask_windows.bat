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

echo Installing additional dependencies...
pip install werkzeug pillow

echo.
echo Flask installation complete!
echo You can now run: python app.py
pause