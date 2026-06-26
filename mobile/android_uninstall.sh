#!/bin/sh

set -e
set -x
rm -Rfv /Applications/Android\ Studio*.app
# Delete All Android Studio related preferences
# The asterisk here should target all folders/files beginning with the string before it
rm -Rfv ~/Library/Preferences/AndroidStudio*
rm -Rfv ~/Library/Preferences/Google/AndroidStudio*
# Deletes the Android Studio's plist file
rm -Rfv ~/Library/Preferences/com.google.android.*
# Deletes the Android Emulator's plist file
rm -Rfv ~/Library/Preferences/com.android.*
# Deletes mainly plugins (or at least according to what mine (Edric) contains)
rm -Rfv ~/Library/Application\ Support/AndroidStudio*
rm -Rfv ~/Library/Application\ Support/Google/AndroidStudio*
# Deletes all logs that Android Studio outputs
rm -Rfv ~/Library/Logs/AndroidStudio*
rm -Rfv ~/Library/Logs/Google/AndroidStudio*
# Deletes Android Studio's caches
rm -Rfv ~/Library/Caches/AndroidStudio*
rm -Rfv ~/Library/Caches/Google/AndroidStudio*
# Application support files
rm -Rfv ~/Application\ Support/Google/AndroidStudio*
# Deletes older versions of Android Studio
rm -Rfv ~/.AndroidStudio*
# Sometimes used
rm -Rfv ~/.android
# Remove gradle stuff
rm -Rfv ~/.gradle
# Remove Android SDK tools
rm -Rfv /usr/local/var/lib/android-sdk/
rm -Rfv ~/Library/Android*
# Emulator console auth token
rm -Rfv ~/.emulator_console_auth_token
set +x

echo "To reinstall Android Studio run:"
echo "brew install android-studio --cask"
echo "Install jdk/sdk versions based on:"
echo "gradle version: android/gradle/wrapper/gradle-wrapper.properties"
echo "check compileSdk as a minimum sdk version."
echo "find a compatible jdk version too."
echo "Next install sdkmanager:"
echo "Preferences → Appearance & Behavior → System Settings → Android SDK → SDK Tools → [Tick]: Android SDK Command-line Tools (latest) + [Tick] Apply"
echo "Then resolve android licenses. Easy way: flutter doctor --android-licenses"

