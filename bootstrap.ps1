# Windows Dotfiles Powershell & Vim

$profileDir = Split-Path -parent $profile
$componentDir = Join-Path $profileDir "components"

New-Item $profileDir -ItemType Directory -Force -ErrorAction SilentlyContinue
New-Item $componentDir -ItemType Directory -Force -ErrorAction SilentlyContinue

Copy-Item -Path ./*.ps1 -Destination $profileDir -Exclude "bootstrap.ps1"
# Copy-Item -Path ./components/** -Destination $componentDir -Include **
# Copy-Item -Path ./home/** -Destination $home -Include **

Remove-Variable componentDir
Remove-Variable profileDir


Write-Host "Installed dotfiles."
Write-Host "Press any key to continue installing choco packages...."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")




# copy the vim config files
Copy-Item -Path ./.vimrc -Destination $HOME/.vimrc

# Installing vim plug (make sure to run for admin and user)
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni $HOME/vimfiles/autoload/plug.vim -Force
vim +'PlugInstall --sync' +qa
vim +'PlugClean --sync' +qa

pushd $HOME\.vim\plugged\YouCompleteMe
# windows support is really not working
# git config --global fetch.fsckobjects false
# git submodule update --init --recursive
# python $HOME\.vim\plugged\YouCompleteMe\install.py --clang-completer
popd


# Installing chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Installing choco packages
choco install 7zip
choco install dotnet
choco install ffmpeg
choco install nvm.portable
choco install nuget.commandline
choco install ripgrep # or use :vimgrep (using :cnext), :lvimgrep (using :lnext)
choco install screentogif
choco install webpi
choco install vim
choco install vcredist140
choco install vcredist2015
choco install vcredist2017

# less used
# choco install baretail
# choco install boldon-james-file-classifier
# choco install boldon-james-office-classifier
# choco install boldon-james-power-classifier
# choco install conemu
# choco install wireshark
