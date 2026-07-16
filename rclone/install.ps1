# Windows counterpart to rclone/install.zsh.

function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping rclone machine install: this PowerShell process is not elevated." -ForegroundColor Yellow
        return
    }

    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope machine -IgnoreVersions | Out-Null
}

function phase_3_dotfiles {
    link_file (Join-Path $PSScriptRoot "bsync.sh") `
        (Join-Path $HOME ".config\rclone\bsync.sh")
}
