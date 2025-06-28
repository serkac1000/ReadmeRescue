#!/bin/bash
echo "======================================="
echo "Python Installation Fix for Git Bash"
echo "======================================="
echo

echo "Your current Python output shows it's broken:"
echo "python --version just prints 'Python' instead of version number"
echo

echo "Testing alternative Python commands..."
echo

# Test py launcher
if command -v py &> /dev/null; then
    echo "✓ Found Python launcher 'py' - this should work!"
    echo "Version: $(py --version 2>/dev/null)"
    echo
    echo "Installing packages using py launcher..."
    py -m pip install --upgrade pip
    py -m pip install Flask==2.3.0 Werkzeug==2.3.0 SpeechRecognition==3.10.0
    
    echo
    echo "Creating directories..."
    mkdir -p uploads output
    
    echo
    echo "Starting application..."
    echo "Web interface will be available at: http://localhost:5000"
    py app.py
    exit 0
fi

# Test python3
if command -v python3 &> /dev/null; then
    echo "✓ Found python3 command"
    echo "Version: $(python3 --version 2>/dev/null)"
    echo
    echo "Installing packages using python3..."
    python3 -m pip install --upgrade pip
    python3 -m pip install Flask==2.3.0 Werkzeug==2.3.0 SpeechRecognition==3.10.0
    
    echo
    echo "Creating directories..."
    mkdir -p uploads output
    
    echo
    echo "Starting application..."
    echo "Web interface will be available at: http://localhost:5000"
    python3 app.py
    exit 0
fi

echo "❌ No working Python installation found"
echo
echo "SOLUTION: Your Python installation is corrupted."
echo
echo "To fix this:"
echo "1. Uninstall Python completely from Windows Settings"
echo "2. Download fresh Python from: https://python.org/downloads/"
echo "3. During installation:"
echo "   - Check 'Add Python to PATH'"
echo "   - Choose 'Install for all users' if possible"
echo "4. Restart your computer after installation"
echo "5. Try running this script again"
echo
echo "Alternative: Install from Microsoft Store"
echo "1. Open Microsoft Store"
echo "2. Search 'Python 3.12'"
echo "3. Install official Python from Microsoft"
echo
read -p "Press Enter to exit..."