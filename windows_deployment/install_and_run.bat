@echo off
echo ===================================
echo Voice-Controlled Video Cutter Setup
echo ===================================
echo.

REM Set Python paths - try common installation locations
set PYTHON_PATHS=python;C:\Python312\python.exe;C:\Python311\python.exe;C:\Python310\python.exe;C:\Python39\python.exe;%LOCALAPPDATA%\Programs\Python\Python312\python.exe;%LOCALAPPDATA%\Programs\Python\Python311\python.exe

set PYTHON_CMD=
for %%i in (%PYTHON_PATHS%) do (
    %%i --version >nul 2>&1
    if not errorlevel 1 (
        set PYTHON_CMD=%%i
        goto :found_python
    )
)

echo ERROR: Python is not found in common locations
echo Checked: %PYTHON_PATHS%
echo.
echo Please ensure Python 3.7+ is installed from https://www.python.org/downloads/
echo Or add Python to your system PATH
pause
exit /b 1

:found_python
echo Found Python: %PYTHON_CMD%

echo Python found. Installing dependencies...
%PYTHON_CMD% -m pip install --upgrade pip
%PYTHON_CMD% -m pip install -r requirements.txt

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

%PYTHON_CMD% app.py

pause