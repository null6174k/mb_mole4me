#!/usr/bin/bash
echo "Prepping to steal MovieBox files..."

set -eux pipefail

MOVIES_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/d
SUBS_DIR=/storage/emulated/0/Android/data/com.community.oneroom/files/Download/subtitle

# Check OS
