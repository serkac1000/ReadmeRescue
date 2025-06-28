@echo off
echo ===================================
echo Voice-Controlled Video Cutter Setup
echo ===================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.7+ from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo Python found. Installing dependencies...
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo WARNING: Some packages failed to install
    echo This might affect voice recognition functionality
    echo.
)

echo.
echo Installing FFmpeg...
powershell -ExecutionPolicy Bypass -File install_ffmpeg.ps1

echo.
echo Starting Voice-Controlled Video Cutter...
echo Web interface will be available at: http://localhost:5000
echo.
echo Press Ctrl+C to stop the server
echo.

python app.py

pause