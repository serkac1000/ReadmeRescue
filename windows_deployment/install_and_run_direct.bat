@echo off
echo ===================================
echo Voice-Controlled Video Cutter Setup
echo Direct Python Path Method
echo ===================================
echo.

REM Try multiple specific paths for your system
set "PYTHON_PATHS="C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe" "%USERPROFILE%\AppData\Local\Programs\Python\Python312\python.exe" "C:\Python312\python.exe" "python""

set PYTHON_CMD=
for %%i in (%PYTHON_PATHS%) do (
    echo Checking: %%i
    %%i --version >nul 2>&1
    if not errorlevel 1 (
        set PYTHON_CMD=%%i
        echo SUCCESS: Found Python at %%i
        goto :found_python
    )
)

echo ERROR: Could not find Python in any of these locations:
for %%i in (%PYTHON_PATHS%) do (
    echo   %%i
)
echo.
echo Please check your Python installation path and update this script
pause
exit /b 1

:found_python
echo.
echo Using Python: %PYTHON_CMD%
%PYTHON_CMD% --version
echo.

echo Installing/upgrading pip...
%PYTHON_CMD% -m pip install --upgrade pip

echo.
echo Installing required packages...
%PYTHON_CMD% -m pip install Flask>=2.3.0
%PYTHON_CMD% -m pip install Werkzeug>=2.3.0
%PYTHON_CMD% -m pip install SpeechRecognition>=3.10.0

echo.
echo Attempting to install PyAudio (for voice recognition)...
%PYTHON_CMD% -m pip install pyaudio
if errorlevel 1 (
    echo WARNING: PyAudio installation failed
    echo Voice recognition may not work, but you can still use manual input
    echo.
)

echo.
echo Installing FFmpeg...
powershell -ExecutionPolicy Bypass -File install_ffmpeg.ps1

echo.
echo Creating necessary directories...
if not exist "uploads" mkdir uploads
if not exist "output" mkdir output

echo.
echo Starting Voice-Controlled Video Cutter...
echo Web interface will be available at: http://localhost:5000
echo.
echo Press Ctrl+C to stop the server
echo.

%PYTHON_CMD% app.py

pause