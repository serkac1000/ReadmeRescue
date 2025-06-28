#!/bin/bash
echo "======================================="
echo "Voice-Controlled Video Cutter Setup"
echo "Git Bash / MINGW64 Installation"
echo "======================================="
echo

# Check for Python
echo "Checking for Python..."
if command -v python &> /dev/null; then
    echo "SUCCESS: Python found"
    python --version
    PYTHON_CMD="python"
elif command -v python3 &> /dev/null; then
    echo "SUCCESS: Python3 found"
    python3 --version
    PYTHON_CMD="python3"
elif command -v py &> /dev/null; then
    echo "SUCCESS: Python launcher found"
    py --version
    PYTHON_CMD="py"
else
    echo "ERROR: Python not found in PATH"
    echo "Please ensure Python is installed and added to PATH"
    echo "Or use Command Prompt instead of Git Bash"
    read -p "Press Enter to exit..."
    exit 1
fi

echo
echo "Installing Python packages..."
$PYTHON_CMD -m pip install --upgrade pip
$PYTHON_CMD -m pip install Flask==2.3.0 Werkzeug==2.3.0 SpeechRecognition==3.10.0

echo
echo "Attempting to install PyAudio for voice recognition..."
$PYTHON_CMD -m pip install pyaudio
if [ $? -ne 0 ]; then
    echo "WARNING: PyAudio installation failed"
    echo "Voice recognition will not work, but manual input is available"
fi

echo
echo "Creating required directories..."
mkdir -p uploads output

echo
echo "Setup complete! Starting application..."
echo "Web interface will be available at: http://localhost:5000"
echo "Press Ctrl+C to stop the server"
echo

$PYTHON_CMD app.py