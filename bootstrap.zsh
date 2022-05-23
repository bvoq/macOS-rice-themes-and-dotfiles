#!/bin/zsh
# set -x
if [[ $OSTYPE == 'darwin'* ]]; then
  brew install bat git nvim tmux tree zsh-completions
  # devops tools
  brew install kubectl fluxcd/tap/flux kubetail
  brew tap johanhaleby/kubetail && brew install kubetail
  brewprefixlocation=$(brew --prefix)
  echo "$(brew --prefix)/share/zsh"

  # zsh-completions first install
  if type brew &>/dev/null; then
   rm -f ~/.zcompdump
   FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
   autoload -Uz compinit compaudit
   compaudit | xargs chmod g-w
   # rm -f ~/.zcompdump # may be necessary
   compinit
  fi
fi

# zgen for zsh plugin management
# git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

waitconfirm() {
    if read -q "choice?Continue [press y/n]? "; then
        echo "Continuing..."
    else
        exit 0
    fi
}

git submodule init
git submodule update

# create a backup, better safe than sorry.
mv ~/.inputrc   ~/.inputrc.old
mv ~/.gitconfig ~/.gitconfig.old
mv ~/.zshrc     ~/.zshrc.old
mv ~/.vimrc     ~/.vimrc.old
mv ~/.tmux.conf ~/.tmux.conf.old
rm -r ~/.tmux.old && mv ~/.tmux ~/.tmux.old
mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.old

cp .inputrc   ~/.inputrc
cp .gitconfig ~/.gitconfig
cp .tmux.conf ~/.tmux.conf
cp -r .tmux   ~/.tmux
cp .zshrc     ~/.zshrc

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
nvim +'PlugInstall --sync' +qa
nvim +'PlugClean --sync' +qa
\vim +'PlugInstall --sync' +qa
\vim +'PlugClean --sync' +qa

# Language servers for vim and vscode (also edit in init.vim)
echo "Next: Installing language servers."
waitconfirm

npm install -g pyright
npm install -g bash-language-server

# System changes for macOS
if [[ $OSTYPE == 'darwin'* ]]; then
  echo "Next: Tuning macOS settings. Some updates will only take effect after restarting the system."
  waitconfirm
  bash .macos
  echo "Almost done. Next we will install some Terminal and Xcode themes. You can also install them manually alternatively."
  waitconfirm
  mkdir -p ~/Library/Developer/Xcode/UserData/FontAndColorThemes/ && cp xcode/Zenburn.xccolortheme ~/Library/Developer/Xcode/UserData/FontAndColorThemes/Zenburn.xccolortheme
  echo "Done. It will need to be manually selected under Xcode > Preferences > Themes > Zenburn"
  echo "Also, in the new Xcode you may need to set Xcode > Preferences > General > Appearance > Dark"
  echo "Afer this Terminal.app will be killed. Note that in order to apply all settings a full restart is required."
  waitconfirm

  cp terminal.app/com.apple.Terminal.plist ~/Library/Preferences/com.apple.Terminal.plist
  defaults read com.apple.Terminal
  echo "Done. Goodbye."
  killall "Terminal"
fi
