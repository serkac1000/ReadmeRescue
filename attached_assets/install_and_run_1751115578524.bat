@echo off

:: This script automates the setup and launch of the Voice Video Editor.

:: Check for FFmpeg in the standard installation directory
if not exist "C:\ffmpeg\bin\ffmpeg.exe" (
    echo -----------------------------------------------------------------
    echo ERROR: FFmpeg not found in C:\ffmpeg\bin
    echo -----------------------------------------------------------------
    echo Please install FFmpeg first.
    echo You can use the 'install_ffmpeg.ps1' PowerShell script for automatic installation.
    echo.
    pause
    exit /b
)

:: Set the path to the virtual environment
set VENV_DIR=%~dp0venv

:: Check if the virtual environment exists, if not, create it
if not exist "%VENV_DIR%\Scripts\activate.bat" (
    echo Creating virtual environment...
    C:\Users\serka\venv\Scripts\python.exe -m venv "%VENV_DIR%"
    if %errorlevel% neq 0 (
        echo ERROR: Failed to create virtual environment.
        pause
        exit /b
    )
)

:: Activate the virtual environment
echo Activating virtual environment...
call "%VENV_DIR%\Scripts\activate.bat"

:: Update pip and setuptools within the virtual environment
echo Updating pip and setuptools in venv...
python -m pip install --upgrade pip setuptools

:: Install Python dependencies within the virtual environment
echo Checking for Python dependencies in venv...
pip install -r requirements.txt

:: Check if installation was successful
if %errorlevel% neq 0 (
    echo.
    echo -----------------------------------------------------------------
    echo ERROR: Failed to install Python dependencies in virtual environment.
    echo -----------------------------------------------------------------
    echo Please check your Python and pip installation.
    echo If the error persists, you might need to install Microsoft Visual C++ Build Tools.
    echo Search for "Build Tools for Visual Studio" on Microsoft's website.
    echo.
    pause
    exit /b
)

:: Launch the application using the virtual environment's Python
echo Starting the Voice Video Editor...
python main.py
