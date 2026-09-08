# psc-research

This script will rebuild the Phantasy Star Classics APK with the Google Play Services dependencies removed.

Sega released a final update (6.4.0) which has removed the online requirements for their emulator saves, however they
left some dependencies in the AndroidManifest.xml which causes the game to close as soon as you acknowledge the dialog
that claims they have enabled offline play. This script will allow you to rebuild a stock APK and install it yourself.

This is distributed as a script because installing random APK's from the internet isn't great practice.

The bash script runs in Linux (I used WSL2) and has a few dependencies.

Ubuntu:  

```shell
sudo apt update && sudo apt install -y \
  apksigner \
  apktool \
  openssl \
  xmlstarlet
```

Place the apk in the repo root with the name `phantasy-star-classics-6-4-0.apk` or pass the path as the first argument:

`./patch phantasy-star-classics.apk`

This will decompile the APK, edit the Google Services out of the Android Manifest, then rebuild the APK. The script will
also create an RSA private key and resign the new APK.  

If you have an existing installation of the game, from PowerShell or wherever you have ADB setup, backup your save files:  
`adb pull "/sdcard/Android/data/com.sega.PhantasyStarII/files/Save" "."`

Now install the APK on your phone and open the game one time, make it through the emulator menus to the game's main menu:
`adb push "Save\." "/sdcard/Android/data/com.sega.PhantasyStarII/files/Save/"`

The game seems to need to run once before it will accept the saves. You do not need to use ADB, however the dates of the 
saves will be based on the dates of the files and ADB preserves those values.  

If you have issues with the saves not appearing, try deleting them and copying again, if not try uninstalling the APK first.
