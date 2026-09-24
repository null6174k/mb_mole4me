#!/usr/bin/bash
echo "Prepping to move MovieBox files..."

set -euxo pipefail

MOVIES_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/d
SUBS_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/subtitle
WANTS_SUBS=n # if you want the subs 
TO_PHONE_DIR=n # if you want it saved on a visible folder on your phone.

read -rp "Want subs? (y/n)" WANTS_SUBS
read -rp "Do you want to make the videos visible on your File Manager (y/n)" TO_PHONE_DIR

# Check OS and install platform specific version of adb for OS platform.
case "$OSTYPE" in
    linux-gnu*)
        echo "OS detected: Linux"
        # Check if adb is installed 
        if ! command -v adb &> /dev/null; then
           echo "Error: 'adb' is not installed or not added to your PATH." >&2
           echo "Attempting install...Maintain your internet connection"
           echo "Downloading Android Command Line Tools for Linux..."
           mkdir -p "$HOME/platform-tools-local"
           wget -qO- "https://dl.google.com/android/repository/platform-tools-latest-linux.zip" > /tmp/tools.zip
           unzip -q /tmp/tools.zip -d "$HOME/platform-tools-local"
           # Add to PATH
           export PATH="$PATH:$HOME/platform-tools-local/platform-tools"
        fi
          # Alternate case: adb does exist (yay!)
          # Check adb server status 
          # If server isn't up, start server
          adb start-server 

          LINUX_VIDEOS_OUT_DIR="/home/$(whoami)/Videos/MovieBox"
          LINUX_SUBS_OUT_DIR="/home/$(whoami)/Videos/Subs"
          PHONE_DIR=/storage/emulated/0/Movies/
          if [[ "$TO_PHONE_DIR" == "y" || "$TO_PHONE_DIR" == "Y" ]] ; then 
             adb shell mkdir -p "$PHONE_DIR"
             adb shell cp -r "$MOVIES_DIR" "$PHONE_DIR"
          fi
          # Take files from the directory and move them to the MovieBox directory
          # Make LINUX_OUT_DIR and SUBS_DIR iff not exists (idempotent)
          mkdir -p "$LINUX_VIDEOS_OUT_DIR"
          mkdir -p "$LINUX_SUBS_OUT_DIR"

          adb pull "$MOVIES_DIR" "$LINUX_VIDEOS_OUT_DIR"
           if [[ "$WANTS_SUBS" == "y" || "$WANTS_SUBS" == "Y" ]] ; then
           adb pull "$SUBS_DIR" "$LINUX_SUBS_OUT_DIR"
          fi
        ;;
    darwin*)
        echo "OS detected: macOS"
        VIDEOS_OUT_DIR="/Users/$(whoami)/Movies/MovieBox"
        SUBS_OUT_DIR="/Users/$(whoami)/Movies/Subs"

        if ! command -v adb &> /dev/null; then
           echo "Error: 'adb' is not installed. Attempting macOS download..." >&2
           mkdir -p "$HOME/platform-tools-local"
           curl -sSL "https://dl.google.com/android/repository/platform-tools-latest-darwin.zip" -o /tmp/tools.zip
           unzip -q /tmp/tools.zip -d "$HOME/platform-tools-local"
           export PATH="$PATH:$HOME/platform-tools-local/platform-tools"
        fi
        ;;
    msys* | cygwin* | mingw*)
        echo "OS detected: Windows (Bash Environment)"
        if ! command -v adb &> /dev/null; then
           echo "Error: 'adb' is not installed. Attempting Windows download..." >&2
           mkdir -p "$HOME/platform-tools-local"
           curl -sSL "https://dl.google.com/android/repository/platform-tools-latest-windows.zip" -o /tmp/tools.zip
           unzip -q /tmp/tools.zip -d "$HOME/platform-tools-local"
           export PATH="$PATH:$HOME/platform-tools-local/platform-tools"
        fi
        ;;
    *)
        echo "Error: Operating system '$OSTYPE' is not supported by this script." >&2
        exit 1
        ;;
esac 

echo "All done!"


