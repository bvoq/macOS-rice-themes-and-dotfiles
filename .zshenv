#!/bin/zsh

# Python
# PYBIN=$(realpath ~/Library/Python/3.8/bin)
# export PATH="$PYBIN:$PATH"
# Flutter
export PATH="$PATH:$HOME/Developer/flutter/bin" 
export PATH="$PATH":"$HOME/.pub-cache/bin"
# If in China:
country=$(curl -s ipinfo.io/country --connect-timeout 5)
if [[ "$country" == "CN" ]]; then
  export PUB_HOSTED_URL=https://mirror.sjtu.edu.cn
  export FLUTTER_STORAGE_BASE_URL=https://mirror.sjtu.edu.cn/dart-pub
fi 
# Mobile testing, maestro & flashlight
export PATH=$PATH:$HOME/.maestro/bin
export PATH="/Users/deke/.flashlight/bin:$PATH"

# Android
export ANDROID_HOME=/Users/$USER/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools
# VSCode Insiders (picked first if installed)
export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
# VSCode
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# Rust
export PATH="$PATH:/${HOME}/.cargo/bin"
# Go
export GOPATH=${HOME}/go
mkdir -p $GOPATH
export PATH=${PATH}:${HOME}/go/bin
# Agda
export PATH=${PATH}:${HOME}/.local/bin
# Java (Flutter supports only JDK11, which is bundled in Android Studio)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
#export JAVA_HOME=$(/usr/libexec/java_home)

# Crypto
export PATH="$PATH:$HOME/monero/build/release/bin"
# Devops
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Unity/Dotnet
export DOTNET_ROOT="${HOME}/.dotnet"
export PATH="${PATH}:$DOTNET_ROOT"

