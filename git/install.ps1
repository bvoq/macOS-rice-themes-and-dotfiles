# Windows counterpart to git/install.zsh.

function phase_3_dotfiles {
    link_file (Join-Path $PSScriptRoot ".gitconfig") (Join-Path $HOME ".gitconfig")
    link_file (Join-Path $PSScriptRoot ".gitignore_global") (Join-Path $HOME ".gitignore_global")
    link_file (Join-Path $PSScriptRoot ".gitattributes_global") (Join-Path $HOME ".gitattributes_global")

    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_git.ps1")
}
