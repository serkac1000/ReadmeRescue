@echo off
echo ===================================
echo Voice-Controlled Video Cutter Setup
echo Universal Python Installation
echo ===================================
echo.

REM Try Python launcher first (most reliable method)
echo Trying Python launcher...
py --version >nul 2>&1
if not errorlevel 1 (
    set PYTHON_CMD=py
    echo SUCCESS: Using Python launcher
    py --version
    goto :install_packages
)

REM Try python command in PATH
echo Trying python from PATH...
python --version >nul 2>&1
if not errorlevel 1 (
    set PYTHON_CMD=python
    echo SUCCESS: Using python from PATH
    python --version
    goto :install_packages
)

REM Try specific user path for serka
echo Trying specific path for user serka...
if exist "C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" (
    "C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" --version >nul 2>&1
    if not errorlevel 1 (
        set PYTHON_CMD="C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe"
        echo SUCCESS: Found Python at user-specific path
        "C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" --version
        goto :install_packages
    )
)

REM Try current user path
echo Trying current user path...
if exist "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" (
    "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" --version >nul 2>&1
    if not errorlevel 1 (
        set PYTHON_CMD="%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe"
        echo SUCCESS: Found Python at current user path
        "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" --version
        goto :install_packages
    )
)

echo.
echo ERROR: Cannot find Python installation
echo.
echo Please run diagnose_python.bat to identify your Python installation
echo or manually install Python from https://python.org and ensure it's in PATH
echo.
pause
exit /b 1

:install_packages
echo.
echo Installing Python packages...
%PYTHON_CMD% -m pip install --upgrade pip
%PYTHON_CMD% -m pip install Flask==2.3.0 Werkzeug==2.3.0 SpeechRecognition==3.10.0

echo.
echo Attempting to install PyAudio for voice recognition...
%PYTHON_CMD% -m pip install pyaudio
if errorlevel 1 (
    echo WARNING: PyAudio installation failed
    echo Voice recognition will not work, but manual input is still available
    echo.
)

echo.
echo Creating required directories...
if not exist "uploads" mkdir uploads
if not exist "output" mkdir output

echo.
echo Setup complete! Starting the application...
echo.
echo Web interface will be available at: http://localhost:5000
echo Press Ctrl+C to stop the server
echo.

%PYTHON_CMD% app.py

pause