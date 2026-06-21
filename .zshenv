#!/bin/zsh

# General
export XDG_CONFIG_HOME="$HOME/.config"

# ccache
export PATH="/opt/homebrew/opt/ccache/libexec:$PATH"
# Python
# PYBIN=$(realpath ~/Library/Python/3.8/bin)
# export PATH="$PYBIN:$PATH"
# Flutter
export PATH="$PATH:$HOME/Developer/flutter/bin" 
export PATH="$PATH":"$HOME/.pub-cache/bin"
# Mobile testing, maestro & flashlight
export PATH=$PATH:$HOME/.maestro/bin
export PATH="$HOME/.flashlight/bin:$PATH"

# Android
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/emulator:$PATH"
# Android Studio comes bundled with JDK 21 now by default
# export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
# Flutter + React Native supports only JDK17 which is the version supported by sdkmanager.
# They recommend zulu version: https://reactnative.dev/docs/set-up-your-environment?platform=android
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# VSCode Insiders (picked first if installed)
export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
# VSCode
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# Rust
export PATH="$PATH:/${HOME}/.cargo/bin"
# Go
export GOPATH="$HOME/go"
export PATH=${PATH}:${HOME}/go/bin
# Agda
export PATH=${PATH}:${HOME}/.local/bin
# Crypto
export PATH="$PATH:$HOME/monero/build/release/bin"
# Emacs
export PATH="$PATH:$XDG_CONFIG_HOME/emacs/bin"
export DOOMDIR="$XDG_CONFIG_HOME/doom"

# Unity/Dotnet
export DOTNET_ROOT="${HOME}/.dotnet"
export PATH="${PATH}:$DOTNET_ROOT"

# Ruby (user-installed)
GEM_PATH="$HOME/.gem/ruby"
if [ -d "$GEM_PATH" ]; then
    # Find the largest version directory
    LARGEST_VERSION=$(\ls "$GEM_PATH" | sort -V | tail -n 1)
    if [ -d "$GEM_PATH/$LARGEST_VERSION/bin" ]; then
        export PATH="$GEM_PATH/$LARGEST_VERSION/bin:$PATH"
    fi
fi

for zshenv_file in "${ZDOTDIR:-$HOME}"/.zshenv.d/*.zsh(N); do
  source "$zshenv_file"
done
unset zshenv_file
