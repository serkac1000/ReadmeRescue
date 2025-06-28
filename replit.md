# Voice-Controlled Video Cutter

## Overview

This is a cross-platform desktop application for cutting video files using voice commands or manual input. The project implements both a desktop GUI application (using tkinter) and a web-based interface (using Flask). The application features an integrated video player for preview and uses FFmpeg for video processing.

## System Architecture

The project follows a dual-architecture approach:

### Desktop Application (Primary)
- **Framework**: tkinter for GUI
- **Video Processing**: FFmpeg command-line integration
- **Voice Recognition**: SpeechRecognition library with microphone input
- **Video Preview**: TkinterVideo widget for embedded video playback
- **Architecture Pattern**: Single-threaded GUI with background processing threads

### Web Application (Secondary)
- **Framework**: Flask web server
- **Frontend**: HTML/CSS/JavaScript with Bootstrap styling
- **API**: RESTful endpoints for video processing
- **File Handling**: Werkzeug for secure file uploads
- **Real-time Updates**: JavaScript polling for task status

## Key Components

### 1. Desktop GUI Application (`main.py`)
- **VoiceVideoEditor Class**: Main application window and logic
- **Speech Recognition**: Converts voice commands to text
- **Video Player Integration**: Embedded video preview with timeline
- **Time Parsing**: Natural language time parsing (e.g., "1 minute 30 seconds")
- **FFmpeg Integration**: Subprocess calls for video cutting operations

### 2. Web Interface (`app.py`)
- **Flask Routes**: File upload, processing, and status endpoints
- **Task Management**: Background processing with unique task IDs
- **File Security**: Secure filename handling and upload validation
- **Progress Tracking**: Real-time processing status updates

### 3. Frontend Web Components
- **Responsive UI**: Bootstrap-based responsive design
- **Voice Commands**: Web Speech API integration
- **Video Preview**: HTML5 video player
- **Progress Indicators**: Real-time processing feedback

## Data Flow

### Desktop Application Flow:
1. User selects video file through file dialog
2. Video loads in embedded player for preview
3. User issues voice command or manual input
4. Time parsing converts natural language to seconds
5. FFmpeg subprocess executes video cutting
6. Output file saved to same directory as input

### Web Application Flow:
1. User uploads video file via web form
2. File stored in uploads directory with secure filename
3. Processing task created with unique ID
4. Background thread executes FFmpeg operation
5. Processed video saved to output directory
6. Client polls for completion status
7. Download link provided upon completion

## External Dependencies

### Core Dependencies:
- **FFmpeg**: Required system dependency for video processing
- **Python 3.7+**: Minimum runtime requirement

### Desktop Application Libraries:
- **tkinter**: Built-in GUI framework (standard library)
- **speech_recognition**: Voice command processing
- **tkvideoplayer**: Video preview widget
- **pyaudio**: Audio input for voice recognition

### Web Application Libraries:
- **Flask**: Web framework
- **Werkzeug**: WSGI utilities and secure file handling

### Optional Dependencies:
- **Pillow**: Image processing support
- **pyav**: Advanced video processing capabilities

## Deployment Strategy

### Desktop Application:
- **Cross-platform**: Works on Windows, macOS, and Linux
- **Installation Scripts**: Automated setup via batch/PowerShell scripts
- **Virtual Environment**: Isolated Python environment recommended
- **FFmpeg Setup**: Platform-specific installation automation

### Web Application:
- **Local Deployment**: Flask development server for testing
- **Production Ready**: WSGI-compatible for production deployment
- **File Storage**: Local filesystem with configurable directories
- **Security**: File size limits and type validation

### Distribution Options:
- **Source Distribution**: Via setup.py for pip installation
- **Standalone Executable**: Can be packaged with PyInstaller
- **Web Service**: Can be deployed to cloud platforms

## Changelog

- June 28, 2025: Initial setup
- June 28, 2025: Created complete Windows distribution package (voice_video_cutter_windows.zip) with automated installer
- June 28, 2025: Enhanced speech recognition support with visual GUI fixer (fix_speech_recognition.py) and improved error handling

## User Preferences

Preferred communication style: Simple, everyday language.