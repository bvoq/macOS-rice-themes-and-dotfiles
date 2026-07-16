function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping generic machine installs: this PowerShell process is not elevated." -ForegroundColor Yellow
        return
    }

    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope machine -IgnoreVersions | Out-Null
}

function phase_2_user_installs {
    $tldr = Get-Command tldr -ErrorAction SilentlyContinue
    if ($tldr) {
        tldr --update
    }
}

function phase_3_dotfiles {
    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_generic.ps1")
}
