function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping Starship machine install: this PowerShell process is not elevated." -ForegroundColor Yellow
        return
    }

    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope machine -IgnoreVersions | Out-Null
}

function phase_3_dotfiles {
    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_starship.ps1")

    link_file (Join-Path $PSScriptRoot "starship.toml") `
        (Join-Path $HOME ".config\starship.toml")
}

function phase_4_post_dotfiles {
    . (Join-Path $PSScriptRoot "profile.ps1")
}