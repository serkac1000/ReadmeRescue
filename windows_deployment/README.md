# Voice-Controlled Video Cutter - Windows Deployment

## Overview
This is a Flask web application for cutting video files using voice commands or manual input.

## Requirements
- Python 3.7 or higher
- FFmpeg (will be installed automatically)

## Quick Start

1. Run `install_and_run.bat` as Administrator
2. Open your web browser and go to: http://localhost:5000
3. Upload a video file and start cutting!

## Manual Installation

### Step 1: Install Python Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Install FFmpeg
Run `install_ffmpeg.ps1` in PowerShell as Administrator, or download FFmpeg manually from https://ffmpeg.org/

### Step 3: Start the Application
```bash
python main.py
```

## Features
- Web-based interface accessible from any browser
- Voice command support (requires microphone access)
- Manual time input for precise cutting
- Real-time processing status updates
- Download processed videos directly

## Voice Commands
- "Cut from [start time] to [end time]"
- "Save as [filename]"

Time formats supported:
- "1 minute 30 seconds"
- "90 seconds"
- "1.5 minutes"
- Plain numbers (assumed to be seconds)

## Troubleshooting
- If FFmpeg is not found, restart the application after running the installer
- For voice recognition issues, ensure microphone permissions are granted
- Large video files may take time to process