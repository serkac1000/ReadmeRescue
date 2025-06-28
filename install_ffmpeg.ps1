# Voice-Controlled Video Cutter - FFmpeg Installation Script
# This PowerShell script downloads and installs FFmpeg on Windows

Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "Voice-Controlled Video Cutter - FFmpeg Installation" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "WARNING: Not running as administrator." -ForegroundColor Yellow
    Write-Host "Some operations may fail. Consider running PowerShell as administrator." -ForegroundColor Yellow
    Write-Host ""
}

# Check if FFmpeg is already installed
$ffmpegPath = "C:\ffmpeg\bin\ffmpeg.exe"
if (Test-Path $ffmpegPath) {
    Write-Host "FFmpeg is already installed at: $ffmpegPath" -ForegroundColor Green
    
    # Test FFmpeg
    try {
        & $ffmpegPath -version | Out-Null
        Write-Host "FFmpeg is working correctly!" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now run the Voice-Controlled Video Cutter application." -ForegroundColor Green
        pause
        exit 0
    }
    catch {
        Write-Host "FFmpeg is installed but not working properly. Reinstalling..." -ForegroundColor Yellow
    }
}

# Create FFmpeg directory
$ffmpegDir = "C:\ffmpeg"
Write-Host "[1/4] Creating FFmpeg directory..." -ForegroundColor Yellow
try {
    if (-not (Test-Path $ffmpegDir)) {
        New-Item -ItemType Directory -Path $ffmpegDir -Force | Out-Null
    }
    Write-Host "Directory created: $ffmpegDir" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to create directory $ffmpegDir" -ForegroundColor Red
    Write-Host "Please ensure you have administrator privileges or create the directory manually." -ForegroundColor Red
    pause
    exit 1
}

# Download FFmpeg
$downloadUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
$zipPath = "$env:TEMP\ffmpeg-release-essentials.zip"

Write-Host "[2/4] Downloading FFmpeg..." -ForegroundColor Yellow
Write-Host "URL: $downloadUrl" -ForegroundColor Gray

try {
    # Use System.Net.WebClient for better compatibility
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $zipPath)
    Write-Host "Download completed: $zipPath" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to download FFmpeg" -ForegroundColor Red
    Write-Host "Please check your internet connection and try again." -ForegroundColor Red
    Write-Host "You can also download manually from: https://ffmpeg.org/download.html" -ForegroundColor Yellow
    pause
    exit 1
}

# Extract FFmpeg
Write-Host "[3/4] Extracting FFmpeg..." -ForegroundColor Yellow
try {
    # Use built-in Windows extraction
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $env:TEMP)
    
    # Find the extracted directory (it usually has a version number)
    $extractedDirs = Get-ChildItem -Path $env:TEMP -Directory | Where-Object { $_.Name -like "ffmpeg-*-essentials_build" }
    
    if ($extractedDirs.Count -eq 0) {
        throw "Could not find extracted FFmpeg directory"
    }
    
    $extractedDir = $extractedDirs[0].FullName
    Write-Host "Extracted to: $extractedDir" -ForegroundColor Green
    
    # Copy files to C:\ffmpeg
    Copy-Item -Path "$extractedDir\*" -Destination $ffmpegDir -Recurse -Force
    Write-Host "Files copied to: $ffmpegDir" -ForegroundColor Green
    
    # Clean up
    Remove-Item $zipPath -Force
    Remove-Item $extractedDir -Recurse -Force
    Write-Host "Cleanup completed" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Failed to extract FFmpeg: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please extract the downloaded file manually to C:\ffmpeg" -ForegroundColor Yellow
    pause
    exit 1
}

# Add to PATH (optional)
Write-Host "[4/4] Configuring system PATH..." -ForegroundColor Yellow
try {
    $currentPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $ffmpegBinPath = "C:\ffmpeg\bin"
    
    if ($currentPath -notlike "*$ffmpegBinPath*") {
        if ($isAdmin) {
            $newPath = $currentPath + ";" + $ffmpegBinPath
            [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            Write-Host "Added FFmpeg to system PATH" -ForegroundColor Green
            Write-Host "You may need to restart your command prompt/PowerShell" -ForegroundColor Yellow
        }
        else {
            Write-Host "Cannot add to system PATH (administrator required)" -ForegroundColor Yellow
            Write-Host "FFmpeg is installed but you may need to use the full path" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "FFmpeg is already in system PATH" -ForegroundColor Green
    }
}
catch {
    Write-Host "WARNING: Could not update PATH: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "FFmpeg is installed but may not be in PATH" -ForegroundColor Yellow
}

# Test installation
Write-Host ""
Write-Host "Testing FFmpeg installation..." -ForegroundColor Yellow
try {
    & $ffmpegPath -version | Select-Object -First 1
    Write-Host ""
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host "SUCCESS: FFmpeg has been installed successfully!" -ForegroundColor Green
    Write-Host "================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "FFmpeg location: $ffmpegPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now run the Voice-Controlled Video Cutter application." -ForegroundColor Green
    Write-Host "Use the 'install_and_run.bat' file to start the application." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: FFmpeg installation verification failed" -ForegroundColor Red
    Write-Host "Please check the installation manually" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
