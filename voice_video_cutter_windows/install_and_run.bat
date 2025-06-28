@echo off
setlocal enabledelayedexpansion

:: Voice-Controlled Video Cutter - Installation and Run Script
:: This script sets up the environment and runs the application

echo ================================================================
echo Voice-Controlled Video Cutter - Setup and Run
echo ================================================================
echo.

:: Check if Python is available
set PYTHON_CMD=
python --version >nul 2>&1
if !errorlevel! equ 0 (
    set PYTHON_CMD=python
) else (
    :: Try common Python installation paths
    for %%P in (
        "C:\Python312\python.exe"
        "C:\Python311\python.exe" 
        "C:\Python310\python.exe"
        "C:\Python39\python.exe"
        "C:\Python38\python.exe"
        "C:\Python37\python.exe"
        "py"
    ) do (
        %%P --version >nul 2>&1
        if !errorlevel! equ 0 (
            set PYTHON_CMD=%%P
            goto :python_found
        )
    )
)

:python_found
if "!PYTHON_CMD!"=="" (
    echo ERROR: Python is not installed or not found
    echo Please install Python 3.7+ from https://python.org
    echo Make sure to check "Add Python to PATH" during installation
    echo.
    echo Or, if Python is installed in a custom location like C:\Python312,
    echo add it to your system PATH or run this script from the Python directory.
    echo.
    pause
    exit /b 1
)

echo [1/5] Python found: !PYTHON_CMD!
echo.

:: Check for FFmpeg
set FFMPEG_FOUND=0
ffmpeg -version >nul 2>&1
if !errorlevel! equ 0 (
    set FFMPEG_FOUND=1
    echo [2/5] FFmpeg found in system PATH
) else (
    if exist "C:\ffmpeg\bin\ffmpeg.exe" (
        set FFMPEG_FOUND=1
        echo [2/5] FFmpeg found in C:\ffmpeg\bin
        set PATH=C:\ffmpeg\bin;!PATH!
    ) else (
        echo [2/5] WARNING: FFmpeg not found
        echo.
        echo FFmpeg is required for video processing. The application will start
        echo but video cutting will not work until FFmpeg is installed.
        echo.
        echo To install FFmpeg:
        echo - Download from: https://ffmpeg.org/download.html
        echo - Extract to C:\ffmpeg
        echo - Or run: install_ffmpeg.ps1 (PowerShell script)
        echo.
    )
)

:: Set up virtual environment directory
set VENV_DIR=%~dp0venv

:: Create virtual environment if it doesn't exist
if not exist "!VENV_DIR!\Scripts\activate.bat" (
    echo [3/5] Creating virtual environment...
    !PYTHON_CMD! -m venv "!VENV_DIR!"
    if !errorlevel! neq 0 (
        echo ERROR: Failed to create virtual environment
        echo This might be due to:
        echo - Insufficient permissions
        echo - Python installation issues
        echo - Disk space limitations
        echo.
        pause
        exit /b 1
    )
    echo Virtual environment created successfully
) else (
    echo [3/5] Virtual environment already exists
)

:: Activate virtual environment
echo [4/5] Activating virtual environment...
call "!VENV_DIR!\Scripts\activate.bat"
if !errorlevel! neq 0 (
    echo ERROR: Failed to activate virtual environment
    pause
    exit /b 1
)

:: Upgrade pip and install requirements
echo [5/5] Installing/updating Python dependencies...
!PYTHON_CMD! -m pip install --upgrade pip setuptools wheel

:: Install requirements with error handling
!PYTHON_CMD! -m pip install -r requirements.txt
if !errorlevel! neq 0 (
    echo.
    echo WARNING: Some dependencies failed to install
    echo This is common with PyAudio on Windows. Trying alternative installation...
    echo.
    
    :: Try installing PyAudio from wheel
    !PYTHON_CMD! -m pip install --upgrade pip
    !PYTHON_CMD! -m pip install pipwin
    pipwin install pyaudio
    
    :: Install other requirements
    !PYTHON_CMD! -m pip install SpeechRecognition tkvideoplayer Pillow
    
    echo.
    echo Dependencies installation completed with warnings.
    echo The application should still work, but some features might be limited.
    echo.
)

echo.
echo ================================================================
echo Setup completed! Starting Voice-Controlled Video Cutter...
echo ================================================================
echo.
echo Instructions:
echo 1. Select a video file using the "Select Video File" button
echo 2. Use voice commands or manual input to specify cut times
echo 3. Voice commands: "Cut from X seconds to Y seconds"
echo 4. Save command: "Save with name filename"
echo.
echo Press Ctrl+C to exit the application
echo ================================================================
echo.

:: Run the application
!PYTHON_CMD! main.py

:: Pause to show any error messages
if !errorlevel! neq 0 (
    echo.
    echo Application exited with an error.
    pause
)

endlocal