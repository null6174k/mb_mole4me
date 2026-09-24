### mb_mole

A simple Bash script to extract and back up MovieBox download files from an Android phone to your PC or a visible folder on your phone. 

### Why I Wrote This

The MovieBox app is handy for automating series downloads, but the app experience is packed with annoying ads. To make matters worse, they recently removed the "Move to Gallery" feature for downloaded videos—likely trying to force you to stay inside the app. 

Frustrated by this, I dug around the Android file system to find exactly where the raw .mp4 video files are saved. This script solves the problem by pulling those hidden files out and saving them exactly where you want them. 

Depending on your configuration choices, the script moves them to: 

* Your computer's **Videos/MovieBox** directory (supports Linux, Mac, and Windows Git Bash).
* A public, visible folder on your phone's storage (**Movies/MovieBox_Local**) so your standard File Manager app can see them.

### Features

* **Cross-Platform:** Works out-of-the-box on **Linux**, **macOS**, and **Windows (Git Bash/MSYS)**.
* **Auto-Setup:** Checks if adb (Android Debug Bridge) is installed. If it isn't, it automatically downloads the official Android platform tools locally so you don't have to install anything manually.
* **Flexible Choices:** Prompts you at runtime to choose if you want subtitles pulled or if you want the videos duplicated to a visible folder on the phone.
* **Safe Execution:** Uses set -euxo pipefail to stop immediately if a command fails, preventing messy half-finished states.
* **Resource Friendly:** Automatically kills the background ADB server when done so it doesn't stay running in the background.

### How it Works

1. **Detects your OS:** Checks if you are running Linux, Mac, or Windows to use the right settings.
2. **Checks for ADB:** Downloads the correct zip file from Google's servers into $HOME/platform-tools-local if you don't have ADB installed.
3. **Asks what you want:** Prompts you for your preference on subtitles and local phone visibility.
4. **Moves the files:** Uses adb pull to copy files to your PC and adb shell cp to copy files safely inside the phone if requested.
5. **Cleans up:** Deletes the temporary downloaded zip file and shuts down the ADB server.

### How to Use

### Prerequisites

* **On your phone:** Enable **USB Debugging** in your phone's Developer Options.
* **Connection:** Connect the phone to your PC via USB and make sure to accept the "Allow USB debugging" prompt on your phone screen.

### Running the Script

1. Save the script file or clone your repository: 

bash
git clone https://github.com/whotterre/mb_mole
cd mb_mole

2. Make the script executable: 

bash

chmod +x mb_mole.sh

3. Run it: 

bash

./mb_mole.sh


### The Hidden App Paths Used

If you want to look for them manually, the script targets these default paths on your Android device: 

* **Videos:** /storage/emulated/0/Android/data/com.community.oneroom/files/Download/d
* **Subtitles:** /storage/emulated/0/Android/data/com.community.oneroom/files/Download/subtitle
* **Visible Phone Storage:** /storage/emulated/0/Movies/MovieBox_Local

### Credits
It uses adb - props to the chads at Android for adb.


*Note: Use this strictly for your own personal backups!*