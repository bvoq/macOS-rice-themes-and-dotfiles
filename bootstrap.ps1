# Source shared functions
. $PSScriptRoot\functions.ps1

# To run this script you might have to be Admin and run this before:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# Bootstrap Windows dotfiles for Powershell & Vim

start ms-settings:developers

Invoke-Expression (&starship init powershell)

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

# Create .config directory and copy starship config
New-Item -Path $HOME/.config -ItemType Directory -Force -ErrorAction SilentlyContinue
Copy-Item -Path ./starship.toml -Destination $HOME/.config/starship.toml

# Powershell packages
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PSScriptAnalyzer -Scope CurrentUser

# Update Microsoft PowerShell first (before using it for other installations)
do {
    $answer = Read-Host "Install/Update Microsoft PowerShell with privacy settings and context menus? (y/n)"
}
while("y","n" -notcontains $answer)
if ($answer -eq "y") {
    Write-Host "Installing Microsoft PowerShell with privacy settings and context menus..." -ForegroundColor Cyan
    $packageToInstall = winget list -e "Microsoft.PowerShell"
    if ($packageToInstall -lt 4) {
        winget install --id Microsoft.PowerShell -e --source winget --interactive --override 'USE_MU=0 ENABLE_MU=0 DISABLE_TELEMETRY=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=0 ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_PATH=1'
    }
}

do {
    $answer = Read-Host "Installed dotfiles and PowerShell, continue to install other winget packages and vim? (y/n)"
}
while("y","n" -notcontains $answer)
if ($answer -eq "n") {
    exit 0
}


### Install packages using winget
# show dependencies of a package using: winget show -e --id <package-id>
$wingetPackages = @(
    "7zip.7zip",
    "ajeetdsouza.zoxide",
    # "baremetalsoft.baretail",
    "BurntSushi.ripgrep.MSVC",
    "dbrgn.tealdeer",
    "dundee.gdu",  # gdu, but works more like ncdu
    "Git.Git",  # Make sure to select openssh and use recommendations. You can add ssh keys to $HOME/.ssh
    "GitHub.Copilot",
    "GnuPG.Gpg4win",
    "gopass.gopass",
    "jqlang.jq",
    "junegunn.fzf",
    "MikeFarah.yq",
    "Microsoft.NuGet",
    "Microsoft.PowerToys",
    "Microsoft.VisualStudioCode",
    "NickeManarin.ScreenToGif",
    # "PaperCutSoftware.GhostTrap", # aka GhostScript
    "qarmin.czkawka.cli",
    "Rclone.Rclone",
    "Schniz.fnm",
    "sharkdp.bat",
    "Starship.Starship",
    "vim.vim",  # Make sure to enable .bat scripts
    "yt-dlp.yt-dlp"  # also installs yt-dlp.fmpeg and DenoLand.Deno
)

foreach ($package in $wingetPackages) {
    Write-Host "Installing package: $package" -ForegroundColor Cyan
    $packageToInstall = winget list -e $package
    if ($packageToInstall -lt 4) {
        winget install --id $package -e --source winget --interactive
    }
}

# Special handling: PowerShell with privacy settings
Write-Host "Installing Microsoft PowerShell with privacy settings..." -ForegroundColor Cyan
$packageToInstall = winget list -e "Microsoft.PowerShell"
if ($packageToInstall -lt 4) {
    winget install --id Microsoft.PowerShell -e --source winget --interactive --override 'USE_MU=0 ENABLE_MU=0 DISABLE_TELEMETRY=1 REGISTER_MANIFEST=1 ENABLE_PSREMOTING=0'
}

### Install packages using msstore
$msstorePackages = @(
    "Perplexity"
)

foreach ($package in $msstorePackages) {
    $packageToInstall = winget list $package
    if ($packageToInstall -lt 4) {
        winget install $package --source msstore
    }
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
code --install-extension ms-vscode.PowerShell

# generic linters
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension redhat.vscode-yaml

# flutter
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom


### Install flutter
if (-not (Test-Path "C:\flutter")) {
    git clone -b stable git@github.com:flutter/flutter.git C:\flutter
}
Set-PathVariable -AddPath "C:\flutter\bin" -Scope "User"
Set-PathVariable -AddPath "$env:USERPROFILE\AppData\Local\Pub\Cache\bin" -Scope "User"


### Installing npm packages
# npm install -g firebase-tools

# Special instructions: Visual Studio
do {
    $answer = Read-Host "Install Microsoft Visual Studio Community? (y/n)"
}
while("y","n" -notcontains $answer)
    if ($answer -eq "y") {
    # uninstall previous versions if there are issues using:
    # cd "C:\Program Files (x86)\Microsoft Visual Studio\Installer"
    # .\InstallCleanup.exe -i 17 # to cleanup 2022
    # .\InstallCleanup.exe -i 18 # to cleanup 2026
    # Make sure to enable: Desktop development with C++
    $packageToInstall=winget list "Microsoft.VisualStudio.Community"
    if ($packageToInstall -lt 4) {
        winget install --id Microsoft.VisualStudio.Community -e --interactive
    }
}
