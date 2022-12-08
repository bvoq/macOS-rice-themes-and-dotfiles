#!/bin/zsh
# set -x
if [[ $OSTYPE == 'darwin'* ]]; then
  brew autoremove
  brew cleanup
  brew install bat git nvim tmux trash tree zsh-completions jq yq
  brew install caffeine dash docker visual-studio-code --cask
  brew install kubectl go
  # brew install fzf
  # $(brew --prefix)/opt/fzf/install

  # flutter-stylizer
  export GOPATH=${HOME}/go
  mkdir -p $GOPATH
  export PATH=${PATH}:${HOME}/go/bin
  go install github.com/gmlewis/go-flutter-stylizer/cmd/flutter-stylizer@latest

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

  # formal methods
  brew install stack
  stack install Agda # installs GHC automatically
fi



echo "Installing VSCode extensions"
# general
code --install-extension aaron-bond.better-comments
code --install-extension GitHub.copilot
code --install-extension deerawan.vscode-dash
code --install-extension Gruntfuggly.todo-tree
code --install-extension robertohuertasm.vscode-icons
code --install-extension johnpapa.vscode-peacock
#code --install-extension waymondo.todoist

# flutter
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
code --install-extension Nash.awesome-flutter-snippets
code --install-extension localizely.flutter-intl
code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom

# generic linters
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension redhat.vscode-yaml
#code --install-extension vscjava.vscode-gradle
#code --install-extension twxs.cmake

# formal
code --install-extension banacorn.agda-mode

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

if [[ $OSTYPE == 'darwin'* ]]; then
  mv ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.old
  cp .vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json
fi

cp .inputrc   ~/.inputrc
cp .gitconfig ~/.gitconfig
cp .tmux.conf ~/.tmux.conf
cp -r .tmux   ~/.tmux
cp .zshrc     ~/.zshrc

echo "Installing Vim and Neovim configurations and plugins"

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

echo "To enable trace, run: 'csrutil enable --without dtrace --without debug' in reboot mode."
# Language servers for vim and vscode (also edit in init.vim)
echo "Next: Installing rclone and others that need root permission"
waitconfirm
sudo -v ; curl https://rclone.org/install.sh | sudo bash
if [[ $OSTYPE == 'darwin'* ]]; then
  brew install macfuse --cask # reinstall after changing security properties
fi
#later use:
#using: https://wasabi-support.zendesk.com/hc/en-us/articles/115001600252-How-do-I-use-Rclone-with-Wasabi-
# restart and make sure macfuse works, then:
#rclone mount wasabi-kdkdk:kdkdk/ wasabi-kdkdk/ &
# rclone copy source:path destination:path
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

  cp terminal/com.apple.Terminal.plist ~/Library/Preferences/com.apple.Terminal.plist
  defaults read com.apple.Terminal
  echo "Done. Goodbye."
  killall "Terminal"
fi
