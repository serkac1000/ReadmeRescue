# Windows Setup Guide for Voice-Controlled Video Cutter

## Quick Setup (Recommended)

### Option 1: Automated Installation
1. Download and run `windows_quick_install.bat` (creates this file below)
2. The script will automatically install Python, Flask, and all dependencies
3. Run the application with `python app.py`

### Option 2: Manual Installation

#### Step 1: Install Python 3.11+
1. Download Python from https://www.python.org/downloads/
2. **IMPORTANT**: Check "Add Python to PATH" during installation
3. Verify installation: Open Command Prompt and type `python --version`

#### Step 2: Install Dependencies
Open Command Prompt as Administrator and run:
```cmd
pip install flask werkzeug gunicorn pillow
```

#### Step 3: Install FFmpeg
1. Download FFmpeg from https://ffmpeg.org/download.html#build-windows
2. Extract to `C:\ffmpeg`
3. Add `C:\ffmpeg\bin` to your Windows PATH environment variable
4. Verify: Open new Command Prompt and type `ffmpeg -version`

#### Step 4: Run the Application
```cmd
cd path\to\your\project
python app.py
```

## Troubleshooting

### Common Issues:

1. **"python is not recognized"**
   - Reinstall Python with "Add to PATH" checked
   - Or manually add Python to PATH

2. **"Module not found: flask"**
   - Run: `pip install flask`
   - If pip not found, reinstall Python

3. **FFmpeg not working**
   - Download FFmpeg binary for Windows
   - Add to PATH environment variable
   - Restart Command Prompt

### Alternative: Use Virtual Environment
```cmd
python -m venv venv
venv\Scripts\activate
pip install flask werkzeug pillow
python app.py
```

## Project Structure
Your project should have:
- `app.py` - Main Flask application
- `templates/` - HTML templates
- `static/` - CSS, JavaScript files
- `uploads/` - Video upload directory
- `output/` - Processed video output

## Running the Web Application
1. Open Command Prompt
2. Navigate to project directory
3. Run: `python app.py`
4. Open browser to: http://localhost:5000