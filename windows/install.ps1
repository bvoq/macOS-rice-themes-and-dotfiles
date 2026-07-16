# To run this script you might have to be Admin and run this before:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# Windows feature installer for PowerShell, Flutter and Visual Studio.
#
# The work is grouped into the same five install phases as unodot.zsh so the two
# bootstrappers stay conceptually in sync. The phases run in order, so packages
# are installed before the dotfiles are copied (mirroring phase_3_dotfiles on
# macOS, which links dotfiles only after the installs in phases 1 and 2).
#   1 machine_installs - machine-scoped winget apps, PowerShell, Flutter, Visual Studio
#   2 user_installs   - user-scoped WinGet apps and PowerShell modules
#   3 dotfiles        - copy profile.ps1 and config files into place
#   4 post_dotfiles   - setup needing dotfiles/tools present
#   5 system_changes  - persistent PATH edits and system settings

###############################################################
# Phase 1: Machine-scoped installs and machine-level changes #
##############################################################
function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping machine installs: this PowerShell process is not elevated. Restart PowerShell with 'Run as administrator'." -ForegroundColor Yellow
        return
    }

    do {
        $answer = Read-Host "Continue to install machine-scoped WinGet packages, Flutter and Visual Studio? (y/n)"
    }
    while("y","n" -notcontains $answer)
    if ($answer -eq "n") {
        Write-Host "Skipping machine installs; continuing with user packages, dotfiles and configuration." -ForegroundColor Yellow
        return
    }

    do {
        $answer = Read-Host "Install/Update Microsoft PowerShell with privacy settings and context menus? (y/n)"
    }
    while("y","n" -notcontains $answer)
    $excludedMachinePackageIdentifiers = @()
    if ($answer -eq "n") {
        $excludedMachinePackageIdentifiers += "Microsoft.PowerShell"
    }

    do {
        $answer = Read-Host "Install Microsoft Visual Studio Community as well? (y/n)"
    }
    while("y","n" -notcontains $answer)
    if ($answer -eq "n") {
        $excludedMachinePackageIdentifiers += "Microsoft.VisualStudio.Community"
    }

    Write-Host "Importing machine-scoped WinGet packages..." -ForegroundColor Cyan
    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") -OnlyScope machine `
        -ExcludePackageIdentifier $excludedMachinePackageIdentifiers -IgnoreVersions | Out-Null
    ### Install flutter
    if (-not (Test-Path "C:\flutter")) {
        git clone -b stable git@github.com:flutter/flutter.git C:\flutter
    }

    # Cleanup is deferred until phase 2.
}

##################################
# Phase 2: User-level installs   #
##################################
function phase_2_user_installs {
    Write-Host "Importing user-scoped WinGet packages..." -ForegroundColor Cyan
    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") -OnlyScope user -IgnoreVersions | Out-Null

    # Powershell packages
    # Bootstrap NuGet provider if available (may fail on PS 5.1 with corrupted PSModulePath from PS 7)
    try { Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser -ErrorAction Stop }
    catch { Write-Host "Skipping Install-PackageProvider (not available or already installed)" -ForegroundColor Yellow }
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser -ErrorAction SilentlyContinue
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force
}

#########################################################
# Phase 3: Dotfiles (user-level), copied after installs #
#########################################################
function phase_3_dotfiles {
    ### Move profile.ps1 into the main powershell location
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path -Parent $profilePath

    New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null

    Copy-Item -Path (Join-Path $PSScriptRoot "*.ps1") -Destination $profileDir -Exclude "install.ps1"
}

####################################################################################
# Phase 4 is implemented by feature installers after their dotfiles are in place. #
####################################################################################
##############################################################
# Phase 5: System changes (persistent PATH, dev settings).   #
##############################################################
function phase_5_system_changes {
    Set-PathVariable -AddPath "C:\flutter\bin" -Scope "User"
    Set-PathVariable -AddPath "$env:USERPROFILE\AppData\Local\Pub\Cache\bin" -Scope "User"
    Set-PathVariable -AddPath "$env:USERPROFILE\AppData\Local\gopass" -Scope "User"
    # Enable Developer Mode (needed by Flutter for Windows desktop symlink support).
    # This writes the same machine-wide flag the Settings page toggles, so it
    # requires admin. Equivalent manual route: start ms-settings:developers
    $devModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (Verify-Elevated) {
        if (-not (Test-Path $devModeKey)) { New-Item -Path $devModeKey -Force | Out-Null }
        New-ItemProperty -Path $devModeKey -Name "AllowDevelopmentWithoutDevLicense" `
            -PropertyType DWord -Value 1 -Force | Out-Null
        Write-Host "Developer Mode enabled." -ForegroundColor Green
    } else {
        Write-Host "Skipping Developer Mode: this PowerShell process is not elevated. Enable it manually via: start ms-settings:developers" -ForegroundColor Yellow
    }
}

