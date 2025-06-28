# PowerShell script for Voice-Controlled Video Cutter setup
# Run this in PowerShell: powershell -ExecutionPolicy Bypass -File install_and_run.ps1

Write-Host "=======================================" -ForegroundColor Green
Write-Host "Voice-Controlled Video Cutter Setup" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Define possible Python paths
$pythonPaths = @(
    "C:\Users\serka\AppData\Local\Programs\Python\Python312\python.exe",
    "$env:USERPROFILE\AppData\Local\Programs\Python\Python312\python.exe",
    "C:\Python312\python.exe",
    "python"
)

$pythonCmd = $null

# Try to find Python
foreach ($path in $pythonPaths) {
    Write-Host "Checking: $path" -ForegroundColor Yellow
    try {
        $result = & $path --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $pythonCmd = $path
            Write-Host "SUCCESS: Found Python at $path" -ForegroundColor Green
            Write-Host "Version: $result" -ForegroundColor Green
            break
        }
    }
    catch {
        # Continue to next path
    }
}

if (-not $pythonCmd) {
    Write-Host "ERROR: Could not find Python in any of these locations:" -ForegroundColor Red
    foreach ($path in $pythonPaths) {
        Write-Host "  $path" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Please install Python 3.7+ or check the path" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Installing Python packages..." -ForegroundColor Yellow

# Install packages
try {
    & $pythonCmd -m pip install --upgrade pip
    & $pythonCmd -m pip install Flask>=2.3.0 Werkzeug>=2.3.0 SpeechRecognition>=3.10.0
    
    # Try to install pyaudio
    Write-Host "Installing PyAudio for voice recognition..." -ForegroundColor Yellow
    & $pythonCmd -m pip install pyaudio
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: PyAudio installation failed. Voice recognition may not work." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error installing packages: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Installing FFmpeg..." -ForegroundColor Yellow
& powershell -ExecutionPolicy Bypass -File install_ffmpeg.ps1

Write-Host ""
Write-Host "Creating directories..." -ForegroundColor Yellow
if (-not (Test-Path "uploads")) { New-Item -ItemType Directory -Name "uploads" }
if (-not (Test-Path "output")) { New-Item -ItemType Directory -Name "output" }

Write-Host ""
Write-Host "Starting Voice-Controlled Video Cutter..." -ForegroundColor Green
Write-Host "Web interface will be available at: http://localhost:5000" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start the application
& $pythonCmd app.py

Read-Host "Press Enter to exit"