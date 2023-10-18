#!/bin/zsh

# enable what you want to install
FORMALMETHODS=1
GENERICTOOLS=1
GENERICCASKTOOLS=1
DEVOPSTOOLS=1
FLUTTERTOOLS=1
CPPTOOLS=1
TEXLIGHT=0
TEXFULL=0

# set -x
if [[ $OSTYPE == 'darwin'* ]]; then
  # clean up brew
  brew autoremove
  brew cleanup

  if [ $GENERICTOOLS = 1 ]; then
    brew install bat git gs jq nvim tmux trash tree yq yt-dlp zsh-completions

    # apple development, switch between xcode versions.
    brew install robotsandpencils/made/xcodes
    # xcode cleaner app
    brew install --cask devcleaner

    # zsh-completions setup script
    if type brew &>/dev/null; then
     rm -f ~/.zcompdump
     FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
     autoload -Uz compinit compaudit
     compaudit | xargs chmod g-w
     # rm -f ~/.zcompdump # may be necessary
     compinit
    fi
  fi

  if [ $FLUTTERTOOLS = 1 ]; then
    # Android
    brew install android-platform-tools
    brew install --cask android-file-transfer
    # flutter-stylizer
    brew install go
    export GOPATH=${HOME}/go
    mkdir -p $GOPATH
    export PATH=${PATH}:${HOME}/go/bin
    go install github.com/gmlewis/go-flutter-stylizer/cmd/flutter-stylizer@latest
    mkdir -p ~/Developer # create the ~/Developer folder if it doesn't exist yet.
    country=$(curl -s ipinfo.io/country --connect-timeout 5)
    if [[ "$country" == "CN" ]]; then
      # if in china:
      export PUB_HOSTED_URL=https://mirror.sjtu.edu.cn
      export FLUTTER_STORAGE_BASE_URL=https://mirror.sjtu.edu.cn/dart-pub
      git clone -b main https://git.sjtu.edu.cn/sjtug/flutter-sdk.git
    else
      # else:
      git clone -b main https://github.com/flutter/flutter.git ~/Developer/flutter
    fi 
  fi

  if [ $CPPTOOLS = 1 ]; then
    brew install gmp mpfr ncurses
  fi

  if [ $DEVOPSTOOLS = 1 ]; then
    brew install kubectl fluxcd/tap/flux kubetail
    brew tap johanhaleby/kubetail && brew install kubetail
    brewprefixlocation=$(brew --prefix)
    echo "$(brew --prefix)/share/zsh"

    (
      set -x; cd "$(mktemp -d)" &&
      OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
      ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
      KREW="krew-${OS}_${ARCH}" &&
      curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
      tar zxvf "${KREW}.tar.gz" &&
      ./"${KREW}" install krew
    )

    # For MQTT connections.
    brew install mqttx --cask
  fi

  ### Formal methods
  if [ $FORMALMETHODS = 1 ]; then
    brew install eprover
    brew install spin
    brew install --cask tla-plus-toolbox
    # PsiSolver
    brew tap bvoq/bvoq
    brew install psisolver
    # Kframework
    #brew tap kframework/k
    #brew install kframework
    ## Agda
    # brew install stack
    # stack install Agda # installs GHC automatically
    # # install emacs from mituharu: https://github.com/railwaycat/homebrew-emacsmacport
    # brew tap railwaycat/emacsmacport
    # brew install --cask emacs-mac
    # agda-mode setup
  fi

  ### Diaphora
  if [ $SECURITYTOOLS = 1]; then
    # https://github.com/joxeankoret/diaphora
  fi
  if [ $GENERICCASKTOOLS = 1 ]; then
    brew install appcleaner baidunetdisk caffeine dash docker keka tor-browser --cask
    # brew install visual-studio-code --cask # started using insider builds instead.
    # reminder to self: you own a license to use this:
    brew install daisydisk --cask
  fi

  if [ $TEXLIGHT = 1 ]; then
    # reminder to self: you own a license to use this:
    # comes with its own latex.
    brew install texifier --cask
    ## tex light version CLI
    # brew install --cask basictex
    # brew install --cask tex-live-utility
  fi

  if [ $TEXFULL = 1 ]; then
    # reminder to self: you own a license to use this:
    # comes with its own latex.
    brew install texifier --cask
    brew install mactex --cask
  fi

fi

# zgen for zsh plugin management
# git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

git submodule init
git submodule update

# create a backup, better safe than sorry.
mv ~/.emacs     ~/.emacs.old
mv ~/.inputrc   ~/.inputrc.old
mv ~/.gitconfig ~/.gitconfig.old
mv ~/.tmux.conf ~/.tmux.conf.old
rm -r ~/.tmux.old && mv ~/.tmux ~/.tmux.old
mv ~/.vimrc     ~/.vimrc.old
mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.old
mv ~/.zshrc     ~/.zshrc.old
mv ~/.zshenv     ~/.zshenv.old
#mkdir -p /usr/local/etc/periodic/weekly
#mv /usr/local/etc/periodic/weekly/weekly_macos_script.local /usr/local/etc/periodic/weekly/weekly_macos_script.local.old

if [[ $OSTYPE == 'darwin'* ]]; then
  mv ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.old
  cp .vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json # VSCode
  cp .vscode-settings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/settings.json # VSCode Insiders
fi

cp .emacs ~/.emacs
cp .inputrc   ~/.inputrc
cp .gitconfig ~/.gitconfig
cp .tmux.conf ~/.tmux.conf
cp -r .tmux   ~/.tmux
cp .zshrc     ~/.zshrc
cp .zshenv    ~/.zshenv
#cp weekly_macos_script.local /usr/local/etc/periodic/weekly/weekly_macos_script.local

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

waitconfirm() {
  if read -q "choice?Continue [press y/n]? "; then
    echo "Continuing..."
  else
    exit 0
  fi
}
echo "Installing VSCode extensions"
waitconfirm
# general
code --install-extension aaron-bond.better-comments
code --install-extension GitHub.copilot
code --install-extension deerawan.vscode-dash
code --install-extension johnpapa.vscode-peacock
code --install-extension usernamehw.errorlens
code --install-extension eamodio.gitlens
code --install-extension PKief.material-icon-theme
code --install-extension Ho-Wan.setting-toggle
code --install-extension ctf0.close-tabs-to-the-left
# generic linters
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension redhat.vscode-yaml

if [ $FORMALMETHODS = 1 ]; then
  code --install-extension banacorn.agda-mode
fi

if [ $FLUTTERTOOLS = 1 ]; then
  code --install-extension Dart-Code.dart-code
  code --install-extension Dart-Code.flutter
  code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom
fi


if [ $FLUTTERTOOLS = 1 ]; then
  echo "Next: Installing firebase, requires root permission."
  waitconfirm
  curl -sL https://firebase.tools | bash
  dart pub global activate flutterfire_cli 0.3.0-dev.16 --overwrite
fi


echo "Next: Installing chatgpt cli"
curl -sS https://raw.githubusercontent.com/0xacx/chatGPT-shell-cli/main/install.sh | sudo -E bash


# Language servers for vim and vscode (also edit in init.vim)
echo "Next: Installing language servers."
waitconfirm

npm install -g pyright
npm install -g bash-language-server


echo "Next: Installing rclone and others that need root permission"
waitconfirm
sudo -v ; curl https://rclone.org/install.sh | sudo bash
if [[ $OSTYPE == 'darwin'* ]]; then
  # brew install macfuse --cask # reinstall after changing security properties
fi
#later setup wasabi-kdkdk:
#using: https://wasabi-support.zendesk.com/hc/en-us/articles/115001600252-How-do-I-use-Rclone-with-Wasabi-
#s3.ap-northeast-1.wasabisys.com with PW in pass
# restart and make sure macfuse works, then:
#rclone mount wasabi-kdkdk:kdkdk/ wasabi-kdkdk/ &
# rclone copy source:path destination:path
echo "Next: Installing system changes for macOS."
waitconfirm

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
