@echo off
echo Installing Flask for Voice-Controlled Video Cutter...
echo.

REM Simple one-command installation
echo Running: pip install flask werkzeug pillow
pip install flask werkzeug pillow

echo.
echo Installation complete!
echo.
echo Now run: python app.py
echo Then open: http://localhost:5000
echo.
pause