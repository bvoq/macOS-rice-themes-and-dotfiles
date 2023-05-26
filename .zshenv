#!/bin/zsh

# Python
# PYBIN=$(realpath ~/Library/Python/3.8/bin)
# export PATH="$PYBIN:$PATH"
# Flutter
export PATH="$PATH:$HOME/Developer/flutter/bin" 
export PATH="$PATH":"$HOME/.pub-cache/bin"
# VSCode Insiders
export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
# Go
export GOPATH=${HOME}/go
mkdir -p $GOPATH
export PATH=${PATH}:${HOME}/go/bin
# Agda
export PATH=${PATH}:${HOME}/.local/bin
# Java (Flutter supports only JDK11, which is bundled in Android Studio)
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
#export JAVA_HOME=$(/usr/libexec/java_home)
