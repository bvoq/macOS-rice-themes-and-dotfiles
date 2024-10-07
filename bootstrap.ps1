# To run this script you might have to be Admin and run this before:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# Bootstrap Windows dotfiles for Powershell & Vim

# need some functions from profile.ps1
. $PSScriptRoot\profile.ps1

### Move profile.ps1 into the main powershell location
$profileDir = Split-Path -parent $profile
$componentDir = Join-Path $profileDir "components"

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
# Copy-Item -Path ./components/** -Destination $componentDir -Include **
# Copy-Item -Path ./home/** -Destination $home -Include **

Remove-Variable componentDir
Remove-Variable profileDir

### copy config files 
Copy-Item -Path ./.gitconfig -Destination $HOME/.gitconfig
Copy-Item -Path ./vscode/.vscode-settings.json -Destination $env:APPDATA\Code\User\settings.json
Copy-Item -Path ./.vimrc -Destination $HOME/.vimrc

do {
    $answer = Read-Host "Installed dotfiles, continue to install winget packages and vim packages? (y/n)"
}
while("y","n" -notcontains $answer)

if ($answer -eq "n") {
    exit 0
}


### Install packages using winget
$packageToInstall=winget list "Microsoft.VisualStudio.2022.Community"
if ($packageToInstall -lt 4) {
    winget install --id Microsoft.VisualStudio.2022.Community --interactive
}
$packageToInstall=winget list "Microsoft.VisualStudioCode"
if ($packageToInstall -lt 4) {
    winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'
}
# Git, make sure to select openssh and use recommendations. You can add ssh keys to $HOME/.ssh
$packageToInstall=winget list "Git.Git"
if ($packageToInstall -lt 4) {
    winget install --id Git.Git -e --source winget --interactive
}

# NPM
$packageToInstall=winget list "OpenJS.NodeJS"
if ($packageToInstall -lt 4) {
    winget install OpenJS.NodeJS
}

# NuGet
$packageToInstall=winget list "Microsoft.NuGet"
if ($packageToInstall -lt 4) {
    winget install Microsoft.NuGet --interactive
}


# Install vim, make sure to enable .bat scripts
$packageToInstall=winget list "Vim.Vim"
if ($packageToInstall -lt 4) {
    winget install Vim.Vim --interactive
}

$packageToInstall=winget list "burntsushi.ripgrep.msvc"
if ($packageToInstall -lt 4) {
    winget install burntsushi.ripgrep.msvc
}


# Installing vim plug
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
vim +'PlugInstall --sync' +qa
vim +'PlugClean --sync' +qa

### Installing VSCode plugins
# General:
code --install-extension aaron-bond.better-comments
code --install-extension GitHub.copilot
code --install-extension johnpapa.vscode-peacock
code --install-extension usernamehw.errorlens
code --install-extension eamodio.gitlens
code --install-extension PKief.material-icon-theme
code --install-extension Ho-Wan.setting-toggle

# generic linters
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension redhat.vscode-yaml

# flutter
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom


### Install flutter
# make sure git is configured first
git clone -b stable git@github.com:flutter/flutter.git C:\flutter
Set-PathVariable -AddPath "C:\flutter\bin" -Scope "User"
Set-PathVariable -AddPath "$env:USERPROFILE\AppData\Local\Pub\Cache\bin" -Scope "User"

### Installing npm packages
npm install -g firebase-tools
# Set-PathVariable -AddPath "C:\flutter\bin" -Scope "User"se



# Alternatively: Installing chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# 
# Installing choco packages
#choco install 7zip
#choco install dotnet
#choco install ffmpeg
#choco install nvm.portable
#choco install nuget.commandline
#choco install ripgrep # or use :vimgrep (using :cnext), :lvimgrep (using :lnext)
#choco install screentogif
#choco install webpi
#choco install vim
#choco install vcredist140
#choco install vcredist2015
#choco install vcredist2017

# less used
# choco install baretail
# choco install boldon-james-file-classifier
# choco install boldon-james-office-classifier
# choco install boldon-james-power-classifier
# choco install conemu
# choco install wireshark
