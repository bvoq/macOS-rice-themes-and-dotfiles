# Windows counterpart to starship/install.zsh. The package itself is declared
# in the active machine-scoped WinGet manifests; profile.ps1 owns Starship's
# PowerShell initialization.

function phase_3_dotfiles {
    # Keep the runtime initialization with the package folder so the linked
    # Windows profile does not need to know where this repository is located.
    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_starship.ps1")

    link_file (Join-Path $PSScriptRoot "starship.toml") `
        (Join-Path $HOME ".config\starship.toml")
}

function phase_4_post_dotfiles {
    . (Join-Path $PSScriptRoot "profile.ps1")
}