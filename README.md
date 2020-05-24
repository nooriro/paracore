# Paracore
An Android shell script that creates [two rescue boot images](https://forum.xda-developers.com/pixel-4-xl/how-to/magisk-modules-disabler-booting-magisk-t3990557) ('coreonly' [by Tulsadiver](https://forum.xda-developers.com/pixel-4-xl/how-to/magisk-modules-disabler-booting-magisk-t3990557) and 'remove' [by osm0sis](https://forum.xda-developers.com/showpost.php?p=80991013&postcount=15)) from `magisk_patched.img`.


## Requirements
This script does not use [Android Image Kitchen](https://forum.xda-developers.com/showthread.php?t=2073775) but uses `magiskboot` contained in [Magisk zip](https://github.com/topjohnwu/Magisk/releases). So you need **a working Android device** to run this script, since `magiskboot` binary in Magisk zip runs only on Android. But root access is NOT needed.


## Working with a PC
Screenshot: [paracore-windows-cmd-200524.png](https://raw.githubusercontent.com/nooriro/paracore/04e3f4921d649600a78a37ae4bfbd06a5772054b/screenshots/paracore-windows-cmd-200524.png)  
Latest SDK Platform Tools download: [Windows](https://dl.google.com/android/repository/platform-tools-latest-windows.zip) | [Mac](https://dl.google.com/android/repository/platform-tools-latest-darwin.zip) | [Linux](https://dl.google.com/android/repository/platform-tools-latest-linux.zip)

1. On your PC, [download the factory image](https://developers.google.com/android/images) of the **target device** and **build number** you need, and extract `boot.img` from there.

2. Copy `boot.img` from your PC to your device.
    ```bat
    adb push boot.img /sdcard/Download/
    ```
3. On your device, [download Magisk Manager apk](https://github.com/topjohnwu/Magisk/releases) (e.g. `MagiskManager-v7.5.1.apk`) and install the apk.

4. Run Magisk Manager app and press [Install] > [Install] > **[Select and Patch a File]**.  
   Select `boot.img` in `Download` folder and wait.  
   After the patch is complete, press [Back button] to return to the main screen of Magisk Manager.

5. On your device, [download Magisk zip](https://github.com/topjohnwu/Magisk/releases) (e.g. `Magisk-v20.4.zip`).  
   • Be sure the Magisk zip file is in `Download` folder (`/sdcard/Download`).  
   • Or, in Magisk Manager, press [Install] > [Install] > **[Download Zip Only]** and wait for downloading to complete.

6. On your PC, [download `paracore-master.zip`](https://github.com/nooriro/paracore/archive/master.zip) and extract `paracore.sh` from there.

7. Copy `paracore.sh` from your PC to your device's `/data/local/tmp` folder, and set "execute" permission on `paracore.sh`.
    ```bat
    adb push paracore.sh /data/local/tmp/ && adb shell chmod u+x /data/local/tmp/paracore.sh
    ```

8. Run `paracore.sh`.
    ```bat
    adb shell /data/local/tmp/paracore.sh
    ```

9. Copy the created img files to your PC.
    ```bat
    adb pull /sdcard/Download/magisk_patched.img
    adb pull /sdcard/Download/magisk_patched_coreonly.img
    adb pull /sdcard/Download/magisk_patched_remove.img
    ```

## Working without a PC
Screenshot (Terminal Emulator): [paracore-terminal-emulator-200524.png](https://raw.githubusercontent.com/nooriro/paracore/04e3f4921d649600a78a37ae4bfbd06a5772054b/screenshots/paracore-terminal-emulator-200524.png)  
Screenshot (Termux): [paracore-termux-1-200524.png](https://raw.githubusercontent.com/nooriro/paracore/04e3f4921d649600a78a37ae4bfbd06a5772054b/screenshots/paracore-termux-1-200524.png) | [paracore-termux-2-200524.png](https://raw.githubusercontent.com/nooriro/paracore/04e3f4921d649600a78a37ae4bfbd06a5772054b/screenshots/paracore-termux-2-200524.png)


1. [Download the factory image](https://developers.google.com/android/images) of the **target device** and **build number** you need, and extract `boot.img` from there.

2. [Download Magisk Manager apk](https://github.com/topjohnwu/Magisk/releases) (e.g. `MagiskManager-v7.5.1.apk`) and install the apk.

3. Run Magisk Manager app and press [Install] > [Install] > **[Select and Patch a File]**.  
   Select `boot.img` and wait.  
   After the patch is complete, press [Back button] to return to the main screen of Magisk Manager.

5. [Download Magisk zip](https://github.com/topjohnwu/Magisk/releases) (e.g. `Magisk-v20.4.zip`).  
   • Be sure the Magisk zip file is in `Download` folder (`/sdcard/Download`).  
   • Or, in Magisk Manager, press [Install] > [Install] > **[Download Zip Only]** and wait for downloading to complete.

5. [Download `paracore-master.zip`](https://github.com/nooriro/paracore/archive/master.zip) and extract `paracore.sh` from there.  
   • Be sure `paracore.sh` is in `Download` folder (`/sdcard/Download`).

6. Install [Terminal Emulator](https://play.google.com/store/apps/details?id=jackpal.androidterm) or [Termux](https://play.google.com/store/apps/details?id=com.termux) from the Google Play Store.

7. Run Terminal Emulator or Termux, and execute the commands below. (Select all the commands, then copy & paste them.)
    ```sh
    cp /sdcard/Download/paracore.sh ~; chmod u+x ~/paracore.sh; ~/paracore.sh
    ```
   • **For Terminal Emulator:** You can't paste the commands directly.  
   Paste into the address bar of Chrome, then copy the commands again, and paste them into Terminal Emulator.  
   • **For Termux:** You must grant storage permission before executing the commands.  
   Press and hold Termux app icon in launcher, then press [circled i icon]. And then press [Permissions] > [Storage] > [Allow].

## References
1. https://forum.xda-developers.com/pixel-4-xl/how-to/magisk-modules-disabler-booting-magisk-t3990557

2. https://github.com/nooriro/parasite/blob/master/parasite.sh

3. https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#root-directory-overlay-system


## Acknowledgements
Thanks: [Tulsadiver](https://forum.xda-developers.com/pixel-4-xl/how-to/magisk-modules-disabler-booting-magisk-t3990557), [osm0sis](https://forum.xda-developers.com/showpost.php?p=80991013&postcount=15), and [topjohnwu](https://github.com/topjohnwu/Magisk/blob/master/docs/guides.md#root-directory-overlay-system)
