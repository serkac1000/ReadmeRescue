@echo off
echo Testing Python Installation
echo =============================
echo.

echo Testing python command...
python --version
if errorlevel 1 (
    echo FAILED: python command not found
    echo Please ensure Python was installed with "Add to PATH" option
    goto :end
)

echo SUCCESS: python command works
echo.

echo Testing pip...
python -m pip --version
if errorlevel 1 (
    echo FAILED: pip not working
    goto :end
)

echo SUCCESS: pip works
echo.

echo Testing package installation...
python -m pip install --quiet --no-warn-script-location requests
if errorlevel 1 (
    echo FAILED: Cannot install packages
    goto :end
)

echo SUCCESS: Package installation works
echo.

echo Python installation is ready for the video cutter application!
echo You can now run quick_install.bat

:end
pause