@echo off
echo ================================================
echo Voice-Controlled Video Cutter - Windows Setup
echo ================================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.11+ from https://python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo Python found. Installing required packages...
echo.

REM Install Python dependencies
echo Installing Flask and dependencies...
pip install flask werkzeug pillow gunicorn
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Python packages
    echo Try running as Administrator
    pause
    exit /b 1
)

echo.
echo Checking FFmpeg installation...

REM Check if FFmpeg is available
ffmpeg -version >nul 2>&1
if %errorlevel% neq 0 (
    echo WARNING: FFmpeg not found in PATH
    echo.
    echo To install FFmpeg:
    echo 1. Download from https://ffmpeg.org/download.html#build-windows
    echo 2. Extract to C:\ffmpeg
    echo 3. Add C:\ffmpeg\bin to Windows PATH
    echo 4. Restart this script
    echo.
    echo The web application will still run but video processing won't work.
    pause
) else (
    echo FFmpeg found and ready!
)

echo.
echo ================================================
echo Setup Complete!
echo ================================================
echo.
echo To start the application:
echo 1. Open Command Prompt in this folder
echo 2. Run: python app.py
echo 3. Open browser to: http://localhost:5000
echo.
echo Press any key to start the application now...
pause >nul

echo Starting Voice-Controlled Video Cutter...
python app.py