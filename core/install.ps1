function phase_3_dotfiles {
    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_core.ps1")
}
