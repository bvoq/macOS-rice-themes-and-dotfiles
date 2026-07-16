# Windows counterpart to vim/install.zsh.

function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping vim machine install: this PowerShell process is not elevated." -ForegroundColor Yellow
        return
    }

    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope machine -IgnoreVersions | Out-Null
}

function phase_3_dotfiles {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot ".vimrc") `
        -Destination (Join-Path $HOME ".vimrc") -Force

    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_vim.ps1")
}

function phase_4_post_dotfiles {
    if (-not (Get-Command vim -ErrorAction SilentlyContinue)) {
        Write-Warning "Vim is not available; skipping vim-plug installation."
        return
    }

    $plugPath = Join-Path $HOME "vimfiles/autoload/plug.vim"
    New-Item -Path (Split-Path -Parent $plugPath) -ItemType Directory -Force | Out-Null
    Invoke-WebRequest -UseBasicParsing `
        -Uri "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" `
        -OutFile $plugPath

    & vim "+PlugInstall --sync" +qa
    & vim "+PlugClean --sync" +qa
}
