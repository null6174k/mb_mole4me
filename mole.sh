#!/usr/bin/bash
echo "Prepping to move MovieBox files..."

set -euxo pipefail

MOVIES_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/d
SUBS_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/subtitle
WANTS_SUBS=n # if you want the subs 
TO_PHONE_DIR=n # if you want it saved on a visible folder on your phone.

read -rp "Want subs? (y/n)" WANTS_SUBS
read -rp "Do you want to make the videos visible on your File Manager (y/n)" TO_PHONE_DIR

VIDEOS_OUT_DIR="/home/$(whoami)/Videos/MovieBox"
SUBS_OUT_DIR="/home/$(whoami)/Videos/Subs"
PHONE_DIR=/storage/emulated/0/Movies/MovieBox_Local

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

adb start-server 

# We also need to check if a phone is actually connected to the laptop before pulling
if ! adb devices | grep -qE '\bdevice\b'; then
   echo "Error: Oops..No phones are connected to the laptop...Try plugging your phone or enabling USB debugging from Developer Settings" >&2
   adb kill-server
   exit 1
fi

if [[ "$TO_PHONE_DIR" == "y" || "$TO_PHONE_DIR" == "Y" ]] ; then 
   adb shell mkdir -p "$PHONE_DIR"
   adb shell cp -r "$MOVIES_DIR" "$PHONE_DIR"
fi

mkdir -p "$VIDEOS_OUT_DIR"
mkdir -p "$SUBS_OUT_DIR"

adb pull "$MOVIES_DIR" "$VIDEOS_OUT_DIR"

if [[ "$WANTS_SUBS" == "y" || "$WANTS_SUBS" == "Y" ]] ; then
   adb pull "$SUBS_DIR" "$SUBS_OUT_DIR"
fi

rm -f /tmp/tools.zip

adb kill-server
echo "Don't forget to turn off USB debugging when done..."
echo "All done!"
