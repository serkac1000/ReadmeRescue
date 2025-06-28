# Voice-Controlled Video Cutter (Windows Package)

A Python desktop application with a graphical user interface for cutting video files using voice commands or manual input. Features an integrated video player and FFmpeg-based video processing.

## Features

- **Voice Control**: Cut videos using natural language voice commands
- **Manual Input**: Alternative text-based input for precise control
- **Video Preview**: Built-in video player to preview your content (when available)
- **Cross-Platform**: Works on Windows, macOS, and Linux
- **Multiple Formats**: Supports MP4, AVI, MOV, MKV, and more
- **User-Friendly**: Clean, intuitive graphical interface

## System Requirements

- **Windows 10/11** (64-bit recommended)
- **Python 3.7+** - Download from [python.org](https://python.org/downloads/)
- **FFmpeg** - Required for video processing (auto-installable)
- **Microphone** - Required for voice commands (optional)

## Quick Start (Windows)

### 1. Install Python
1. Download Python from [python.org](https://python.org/downloads/)
2. **Important**: Check "Add Python to PATH" during installation
3. Verify installation by opening Command Prompt and typing: `python --version`

### 2. Install FFmpeg (Choose one method)

#### Method A: Automatic Installation (Recommended)
1. Right-click on `install_ffmpeg.ps1`
2. Select "Run with PowerShell"
3. Follow the prompts (may require administrator privileges)

#### Method B: Manual Installation
1. Download FFmpeg from [ffmpeg.org/download.html](https://ffmpeg.org/download.html)
2. Extract to `C:\ffmpeg`
3. Add `C:\ffmpeg\bin` to your system PATH

### 3. Run the Application
1. **Double-click `install_and_run.bat`**
2. The script will:
   - Create a virtual environment
   - Install all required Python packages
   - Launch the application automatically

## How to Use

### Voice Commands
1. Click "Select Video File" and choose your video
2. Click the microphone button and speak clearly:
   - **"Cut from 10 seconds to 30 seconds"**
   - **"Cut from 1 minute to 2 minutes 15 seconds"**
3. After specifying the cut, say:
   - **"Save with name my_clip"**

### Manual Input
1. Select your video file
2. Enter start time (e.g., "10 seconds", "1 minute 30 seconds")
3. Enter end time (e.g., "45 seconds", "2 minutes")
4. Enter output filename
5. Click "Cut Video"

## Supported Time Formats

- **Seconds**: "10 seconds", "45 seconds"
- **Minutes**: "2 minutes", "5 minutes"
- **Combined**: "1 minute 30 seconds", "2 minutes 15 seconds"
- **Numbers only**: "10", "45" (interpreted as seconds)

## Supported Video Formats

- MP4 (recommended)
- AVI
- MOV
- MKV
- WMV
- FLV
- WEBM

## Troubleshooting

### Common Issues

**"Python is not installed or not in PATH"**
- Reinstall Python and ensure "Add Python to PATH" is checked

**"FFmpeg not found"**
- Run `install_ffmpeg.ps1` as administrator
- Or manually install FFmpeg to `C:\ffmpeg`

**"Speech recognition not available"**
- This is normal - you can still use manual input
- For voice commands, ensure you have a working microphone

**"Video preview not available"**
- This is normal - the core functionality still works
- Video preview requires additional packages that may not install on all systems

### Getting Help

1. Check that Python and FFmpeg are properly installed
2. Try running the application with manual input first
3. Ensure your video file is in a supported format
4. Make sure you have sufficient disk space for output files

## Files Included

- `main.py` - Main application code
- `install_and_run.bat` - Automated setup and launch script
- `install_ffmpeg.ps1` - FFmpeg installation script
- `requirements.txt` - Python package dependencies
- `README.md` - This documentation

## Advanced Usage

### Command Line
```bash
# Activate virtual environment
venv\Scripts\activate

# Run application directly
python main.py
```

### Custom Installation
```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run application
python main.py
```

## License

This project is open source and available under the MIT License.

## Support

For issues and support, please check the troubleshooting section above or refer to the project documentation.