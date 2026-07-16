# Windows counterpart to git/install.zsh.

function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping git machine install: this PowerShell process is not elevated." -ForegroundColor Yellow
        return
    }

    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope machine -IgnoreVersions | Out-Null
}

function phase_3_dotfiles {
    link_file (Join-Path $PSScriptRoot ".gitconfig") (Join-Path $HOME ".gitconfig")
    link_file (Join-Path $PSScriptRoot ".gitignore_global") (Join-Path $HOME ".gitignore_global")
    link_file (Join-Path $PSScriptRoot ".gitattributes_global") (Join-Path $HOME ".gitattributes_global")

    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_git.ps1")
}
