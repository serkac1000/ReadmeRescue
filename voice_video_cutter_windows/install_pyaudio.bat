@echo off
setlocal enabledelayedexpansion

echo ================================================================
echo PyAudio Installation for Speech Recognition
echo ================================================================
echo.

:: Detect Python
set PYTHON_CMD=
python --version >nul 2>&1
if !errorlevel! equ 0 (
    set PYTHON_CMD=python
) else (
    for %%P in (
        "C:\Python312\python.exe"
        "C:\Python311\python.exe" 
        "C:\Python310\python.exe"
        "C:\Python39\python.exe"
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
    echo ERROR: Python not found
    pause
    exit /b 1
)

echo Python found: !PYTHON_CMD!
echo.

:: Get Python version
for /f "tokens=2" %%i in ('!PYTHON_CMD! --version 2^>^&1') do set PYTHON_VERSION=%%i
echo Python version: !PYTHON_VERSION!

:: Activate virtual environment if it exists
if exist "%~dp0venv\Scripts\activate.bat" (
    echo Activating virtual environment...
    call "%~dp0venv\Scripts\activate.bat"
)

echo.
echo [Method 1] Trying standard pip installation...
!PYTHON_CMD! -m pip install PyAudio
if !errorlevel! equ 0 (
    echo SUCCESS: PyAudio installed via pip
    goto :test_pyaudio
)

echo.
echo [Method 2] Trying pipwin (Windows binary packages)...
!PYTHON_CMD! -m pip install pipwin
if !errorlevel! equ 0 (
    pipwin install pyaudio
    if !errorlevel! equ 0 (
        echo SUCCESS: PyAudio installed via pipwin
        goto :test_pyaudio
    )
)

echo.
echo [Method 3] Trying unofficial Windows binaries...
!PYTHON_CMD! -m pip install --find-links https://github.com/intxcc/pyaudio_portaudio/releases PyAudio
if !errorlevel! equ 0 (
    echo SUCCESS: PyAudio installed via unofficial binaries
    goto :test_pyaudio
)

echo.
echo [Method 4] Trying Christoph Gohlke's binaries...
echo Detecting Python architecture...
!PYTHON_CMD! -c "import platform; print('64-bit' if platform.machine().endswith('64') else '32-bit')"

echo.
echo All automatic methods failed. Manual installation required:
echo.
echo MANUAL INSTALLATION STEPS:
echo 1. Go to: https://www.lfd.uci.edu/~gohlke/pythonlibs/#pyaudio
echo 2. Download the PyAudio wheel file for your Python version
echo 3. For Python 3.12 64-bit: PyAudio-0.2.11-cp312-cp312-win_amd64.whl
echo 4. Save the file to this folder
echo 5. Run: !PYTHON_CMD! -m pip install PyAudio-0.2.11-cp312-cp312-win_amd64.whl
echo.
echo OR install Microsoft Visual C++ Build Tools and try again
echo.
pause
exit /b 1

:test_pyaudio
echo.
echo Testing PyAudio installation...
!PYTHON_CMD! -c "import pyaudio; print('PyAudio test successful'); pa = pyaudio.PyAudio(); print(f'Audio devices found: {pa.get_device_count()}'); pa.terminate()"
if !errorlevel! equ 0 (
    echo.
    echo ================================================================
    echo SUCCESS: PyAudio is working correctly!
    echo Voice recognition should now be available in the application.
    echo ================================================================
) else (
    echo.
    echo WARNING: PyAudio installed but may not be working properly.
    echo Check your audio drivers and microphone settings.
)

echo.
pause
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
