#!/bin/sh
apk add curl git gnupg openssh pass vim zoxide
apk add bat ncdu oath-toolkit oath-toolkit-oathtool

# install ashrc properly
echo "ENV=$HOME/.ashrc; export ENV" > ~/.profile
echo ". $ENV" >> ~/.profile
cp .ashrc ~/.ashrc

cp .gitconfig ~/.gitconfig

echo "Installing  Vim and Neovim configurations and plugins"

# Install vim and neovim
# install vundle for vim
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# install vundle for nvim
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# copy the vim config files
mkdir -p ~/.config/nvim && cp .config/nvim/init.vim ~/.config/nvim/init.vim
cp .vimrc ~/.vimrc
if command -v nvim > /dev/null; then
  nvim +'PlugInstall --sync' +qa
  nvim +'PlugClean --sync' +qa
fi
\vim +'PlugInstall --sync' +qa
\vim +'PlugClean --sync' +qa

# you can mount a drive on iOS using:
# mkdir -p /mnt/mysharedfolder
# mount -t ios . /mnt/mysharedfolder
# the above command will make you have to chose a folder to share.

## manual way: install cydownload for installing cydia tools
# https://github.com/borishonman/cydownload/releases
# Download spotify decrypted IPA files:
# open https://armconverter.com/decryptedappstore
# Download spotilife using cydownload
# https://julio.hackyouriphone.org/description.html?id=com.julioverne.spotilife
# Apply patch using sideloadly
# Note eg. http://apt.thebigboss.org/repofiles/cydia/

# Youtube repo:
# https://github.com/qnblackcat/uYouPlus/releases/
# Spotify repo:
# https://github.com/SpotCompiled/SpotC-Plus-Plus/releases
# Instagram rocket:
# https://github.com/qnblackcat/IGSideloadFix
# Rhino Instagram:
# https://lemamichael.github.io/WhatIsRhino/
# TikTok:
# https://github.com/ipahost/Unicorn-for-TikTok
# TikTok god:
# https://github.com/haoict/tiktok-god/releases

# https://github.com/purp0s3/Tweaked-iOS-Apps/releases/
