# PowerShell script to install FFmpeg on Windows
# Run as Administrator

Write-Host "Installing FFmpeg for Windows..." -ForegroundColor Green

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    Write-Host "Right-click on PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Create FFmpeg directory
$ffmpegDir = "C:\ffmpeg"
$ffmpegBin = "$ffmpegDir\bin"

try {
    # Check if FFmpeg is already installed
    $ffmpegExists = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($ffmpegExists) {
        Write-Host "FFmpeg is already installed and available in PATH." -ForegroundColor Green
        exit 0
    }

    Write-Host "Creating FFmpeg directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Force -Path $ffmpegDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ffmpegBin | Out-Null

    # Download FFmpeg
    $downloadUrl = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
    $zipFile = "$env:TEMP\ffmpeg.zip"
    
    Write-Host "Downloading FFmpeg..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing

    Write-Host "Extracting FFmpeg..." -ForegroundColor Yellow
    Expand-Archive -Path $zipFile -DestinationPath $env:TEMP -Force

    # Find the extracted folder (name varies by version)
    $extractedFolder = Get-ChildItem -Path $env:TEMP -Directory -Filter "ffmpeg-*" | Sort-Object CreationTime -Descending | Select-Object -First 1

    if ($extractedFolder) {
        # Copy FFmpeg binaries
        Copy-Item -Path "$($extractedFolder.FullName)\bin\*" -Destination $ffmpegBin -Force
        Write-Host "FFmpeg binaries copied to $ffmpegBin" -ForegroundColor Green
    } else {
        throw "Could not find extracted FFmpeg folder"
    }

    # Add to PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($currentPath -notlike "*$ffmpegBin*") {
        Write-Host "Adding FFmpeg to system PATH..." -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$ffmpegBin", "Machine")
        Write-Host "FFmpeg added to PATH. You may need to restart your command prompt." -ForegroundColor Green
    }

    # Cleanup
    Remove-Item -Path $zipFile -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $extractedFolder.FullName -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "FFmpeg installation completed successfully!" -ForegroundColor Green
    Write-Host "You can now use FFmpeg from the command line." -ForegroundColor Green

} catch {
    Write-Host "Error installing FFmpeg: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Please install FFmpeg manually from https://ffmpeg.org/download.html" -ForegroundColor Yellow
}

Read-Host "Press Enter to continue"