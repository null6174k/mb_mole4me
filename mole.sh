#!/usr/bin/bash
echo "Prepping to steal MovieBox files..."

set -euxo pipefail

MOVIES_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/d
SUBS_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/subtitle

# Check OS 
case "$OSTYPE" in
    linux*)
        echo "OS detected: Linux"
        ;;
    darwin*)
        echo "OS detected: macOS"
        ;;
    msys* | cygwin* | mingw*)
        echo "OS detected: Windows (Bash Environment)"
        ;;
    *)
        echo "Error: Operating system '$OSTYPE' is not supported by this script." >&2
        exit 1
        ;;
esac 
