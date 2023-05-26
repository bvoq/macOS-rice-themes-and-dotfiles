# To run this script you might have to be Admin and run this before:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
# Bootstrap Windows dotfiles for Powershell & Vim

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
Copy-Item -Path ./.vscode-settings.json -Destination %APPDATA%\Code\User\settings.json
Copy-Item -Path ./.vimrc -Destination $HOME/.vimrc

If ($Roles -eq '1') {
    $Cursor = [System.Console]::CursorTop
    Do {
        [System.Console]::CursorTop = $Cursor
        Clear-Host
        $Answer = Read-Host -Prompt 'Installed dotfiles, continue to install winget packages and vim? (y/n)'
    }
    Until ($Answer -eq 'y' -or $Answer -eq 'n')
}

# Install using winget:
winget install Microsoft.VisualStudioCode --override '/SILENT /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders"'
# Git, make sure to select openssh and use recommendations. You can add ssh keys to $HOME/.ssh
winget install --id Git.Git -e --source winget --interactive
# Install vim, make sure to enable .bat scripts
winget install vim.vim --interactive
# Installing vim plug
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
vim +'PlugInstall --sync' +qa
vim +'PlugClean --sync' +qa



# Alternatively: Installing chocolatey
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
# 
# Installing choco packages
#choco install 7zip
#choco install dotnet
#choco install ffmpeg
#choco install nvm.portable
#choco install nuget.commandline
#choco install ripgrep # or use :vimgrep (using :cnext), :lvimgrep (using :lnext)
#choco install screentogif
#choco install webpi
#choco install vim
#choco install vcredist140
#choco install vcredist2015
#choco install vcredist2017

# less used
# choco install baretail
# choco install boldon-james-file-classifier
# choco install boldon-james-office-classifier
# choco install boldon-james-power-classifier
# choco install conemu
# choco install wireshark
