@echo off
echo ===================================
echo Voice-Controlled Video Cutter Setup
echo For User Directory Python Installation
echo ===================================
echo.

REM Set specific Python path for user directory installation
set PYTHON_CMD=%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe

REM Check if Python exists at this location
if not exist "%PYTHON_CMD%" (
    echo ERROR: Python not found at expected location
    echo Expected: %PYTHON_CMD%
    echo.
    echo Please verify Python 3.12 is installed in your user directory
    echo Or check the exact path and modify this script accordingly
    pause
    exit /b 1
)

echo Found Python at: %PYTHON_CMD%
%PYTHON_CMD% --version

echo.
echo Installing dependencies...
%PYTHON_CMD% -m pip install --upgrade pip
%PYTHON_CMD% -m pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo WARNING: Some packages failed to install
    echo This might affect voice recognition functionality
    echo You can continue anyway...
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

%PYTHON_CMD% app.py

pause