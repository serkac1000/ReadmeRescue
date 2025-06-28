@echo off
echo ===================================
echo Voice-Controlled Video Cutter
echo Quick Install for Fresh Python Setup
echo ===================================
echo.

REM Use the standard Python installation path
set PYTHON_CMD=python

echo Testing Python installation...
python --version
if errorlevel 1 (
    echo ERROR: Python not found in PATH
    echo Please ensure Python was installed with "Add to PATH" checked
    pause
    exit /b 1
)

echo SUCCESS: Python found
echo.

echo Installing required packages...
python -m pip install --upgrade pip
python -m pip install Flask==2.3.0
python -m pip install Werkzeug==2.3.0
python -m pip install SpeechRecognition==3.10.0

echo.
echo Attempting to install PyAudio for voice recognition...
python -m pip install pyaudio
if errorlevel 1 (
    echo WARNING: PyAudio failed to install
    echo Voice recognition will not work, but manual input is available
)

echo.
echo Creating directories...
if not exist "uploads" mkdir uploads
if not exist "output" mkdir output

echo.
echo Installation complete! Starting application...
echo Open your browser to: http://localhost:5000
echo.

python app.py

pause