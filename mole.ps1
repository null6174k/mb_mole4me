Write-Host "Prepping to move MovieBox files..."

$ErrorActionPreference = "Stop"

$MOVIES_DIR = "/storage/emulated/0/Android/data/com.community.oneroom/files/Download/d"
$SUBS_DIR = "/storage/emulated/0/Android/data/com.community.oneroom/files/Download/subtitle"
$PHONE_DIR = "/storage/emulated/0/Movies/MovieBox_Local"

$WANTS_SUBS = Read-Host "Want subs? (y/n)"
$TO_PHONE_DIR = Read-Host "Do you want to make the videos visible on your File Manager (y/n)"


$HOME_DIR = [System.Environment]::GetFolderPath("UserProfile")
$VIDEOS_OUT_DIR = Join-Path $HOME_DIR "Videos/MovieBox"
$SUBS_OUT_DIR = Join-Path $HOME_DIR "Videos/Subs"
$ZIP_PATH = Join-Path [System.IO.Path]::GetTempPath() "tools.zip"

# Detect OS and adjust paths / handle ADB setup if missing
if ($IsLinux) {
    Write-Host "OS detected: Linux"
    $URL = "https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
} 
elseif ($IsMacOS) {
    Write-Host "OS detected: macOS"
    $VIDEOS_OUT_DIR = Join-Path $HOME_DIR "Movies/MovieBox"
    $SUBS_OUT_DIR = Join-Path $HOME_DIR "Movies/Subs"
    $URL = "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
} 
elseif ($IsWindows) {
    Write-Host "OS detected: Windows"
    $URL = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
} 
else {
    Write-Error "Error: Operating system is not supported by this script."
    exit 1
}

$AdbInstalled = Get-Command adb -ErrorAction SilentlyContinue

if (-not $AdbInstalled) {
    Write-Warning "'adb' is not installed or not added to your PATH. Attempting automatic download..."
    $LocalToolsDir = Join-Path $HOME_DIR "platform-tools-local"
    
    if (-not (Test-Path $LocalToolsDir)) {
        New-Item -ItemType Directory -Path $LocalToolsDir | Out-Null
    }

    Write-Host "Downloading Android Command Line Tools..."
    Invoke-WebRequest -Uri $URL -OutFile $ZIP_PATH -UseBasicParsing
    
    Write-Host "Extracting tools..."
    Expand-Archive -Path $ZIP_PATH -DestinationPath $LocalToolsDir -Force
    
    $ExtractedAdbPath = Join-Path $LocalToolsDir "platform-tools"
    $env:PATH += [System.IO.Path]::PathSeparator + $ExtractedAdbPath
}

adb start-server


if ($TO_PHONE_DIR -ieq "y") { 
   adb shell mkdir -p "$PHONE_DIR"
   adb shell cp -r "$MOVIES_DIR" "$PHONE_DIR"
}

if (-not (Test-Path $VIDEOS_OUT_DIR)) { New-Item -ItemType Directory -Path $VIDEOS_OUT_DIR | Out-Null }
if (-not (Test-Path $SUBS_OUT_DIR)) { New-Item -ItemType Directory -Path $SUBS_OUT_DIR | Out-Null }


adb pull "$MOVIES_DIR" "$VIDEOS_OUT_DIR"

if ($WANTS_SUBS -ieq "y") {
   adb pull "$SUBS_DIR" "$SUBS_OUT_DIR"
}

if (Test-Path $ZIP_PATH) { Remove-Item -Path $ZIP_PATH -Force }

adb kill-server
Write-Host "All done!"
