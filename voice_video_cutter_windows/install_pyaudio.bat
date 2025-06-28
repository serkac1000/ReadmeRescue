@echo off
echo ========================================
echo   Voice Video Cutter - PyAudio Installer
echo ========================================
echo.

echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation
    pause
    exit /b 1
)

echo Python found! Installing PyAudio...
echo.

echo [Method 1] Trying standard pip installation...
pip install PyAudio
if %errorlevel% equ 0 (
    echo SUCCESS: PyAudio installed successfully!
    goto :test_installation
)

echo.
echo [Method 2] Trying pipwin (Windows binaries)...
pip install pipwin
pipwin install pyaudio
if %errorlevel% equ 0 (
    echo SUCCESS: PyAudio installed via pipwin!
    goto :test_installation
)

echo.
echo [Method 3] Trying unofficial binaries...
pip install --find-links https://github.com/intxcc/pyaudio_portaudio/releases PyAudio
if %errorlevel% equ 0 (
    echo SUCCESS: PyAudio installed via unofficial binaries!
    goto :test_installation
)

echo.
echo ========================================
echo   All automatic methods failed
echo ========================================
echo Manual installation required:
echo 1. Go to: https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio
echo 2. Download PyAudio wheel for your Python version
echo 3. Run: pip install [downloaded_wheel_file.whl]
echo.
echo Alternatively, try running fix_speech_recognition.py for a visual installer
echo.
pause
exit /b 1

:test_installation
echo.
echo Testing PyAudio installation...
python -c "import pyaudio; print('PyAudio is working!')" 2>nul
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   Installation completed successfully!
    echo ========================================
    echo You can now run the main application.
) else (
    echo.
    echo WARNING: PyAudio installation may have issues.
    echo The application will still work with manual input.
)

echo.
pause