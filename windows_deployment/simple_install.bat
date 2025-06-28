@echo off
echo ===================================
echo Voice-Controlled Video Cutter Setup
echo Simple Installation Method
echo ===================================
echo.

REM Set the exact Python path based on your feedback
set PYTHON_CMD="C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe"

echo Checking Python at: %PYTHON_CMD%
%PYTHON_CMD% --version
if errorlevel 1 (
    echo ERROR: Python not found at the specified path
    echo Please verify Python is installed at: %PYTHON_CMD%
    echo.
    echo Alternative: Try running test_python_path.bat first to find the correct path
    pause
    exit /b 1
)

echo SUCCESS: Python found!
echo.

echo Installing dependencies...
%PYTHON_CMD% -m pip install --upgrade pip
%PYTHON_CMD% -m pip install Flask==2.3.0 Werkzeug==2.3.0 SpeechRecognition==3.10.0

echo.
echo Trying to install PyAudio (optional for voice recognition)...
%PYTHON_CMD% -m pip install pyaudio
if errorlevel 1 (
    echo WARNING: PyAudio installation failed - voice recognition may not work
    echo You can still use manual input for cutting videos
)

echo.
echo Creating required directories...
if not exist "uploads" mkdir uploads
if not exist "output" mkdir output

echo.
echo Setup complete! Starting the application...
echo Web interface will be available at: http://localhost:5000
echo.
echo Press Ctrl+C to stop the server
echo.

%PYTHON_CMD% app.py

pause