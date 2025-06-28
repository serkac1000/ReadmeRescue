# Voice-Controlled Video Cutter (Desktop GUI)

A Python desktop application with a graphical user interface for cutting video files using voice commands or manual input. Features an integrated video player and FFmpeg-based video processing.

## Features

- **Voice Control**: Cut videos using natural language voice commands
- **Manual Input**: Alternative text-based input for precise control
- **Video Preview**: Built-in video player to preview your content
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **Multiple Formats**: Supports MP4, AVI, MOV, MKV, and more
- **User-Friendly**: Clean, intuitive graphical interface

## System Requirements

- **Python 3.7+** - Download from [python.org](https://python.org/downloads/)
- **FFmpeg** - Required for video processing
- **Microphone** - Required for voice commands (optional)

## Quick Start (Windows)

### Automatic Installation
1. **Download/clone this repository**
2. **Install FFmpeg** (choose one):
   - Run `install_ffmpeg.ps1` in PowerShell as administrator
   - Or manually download from [ffmpeg.org](https://ffmpeg.org/download.html)
3. **Run the application**:
   - Double-click `install_and_run.bat`
   - This will automatically set up everything and start the app

### Manual Installation
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run application
python main.py
