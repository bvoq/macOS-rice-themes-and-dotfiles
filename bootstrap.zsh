#!/bin/zsh

# enable what you want to install here
FORMALMETHODS=1
GENERICTOOLS=1
GENERICCASKTOOLS=1
DEVOPSTOOLS=1
MOBILETOOLS=1
UNITYTOOLS=1
CPPTOOLS=1
TEXLIGHT=0
TEXFULL=0

source .zshfunctions
set_error_handler

if [[ $OSTYPE == 'darwin'* ]]; then
    # sanity checks
    assure_userlevel_zsh
    check_not_rosetta
fi

if [[ $OSTYPE == 'darwin'* ]] && isadmin; then
  # clean up brew
  brew autoremove
  brew cleanup

  if [ $GENERICTOOLS = 1 ]; then
    brew install bat fzf git gs jq npm nvim tmux trash tree yq yt-dlp watch zsh-completions

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

  if [ $MOBILETOOLS = 1 ]; then
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
      if [ ! -d ~/Developer/flutter ]; then
        git clone -b main https://git.sjtu.edu.cn/sjtug/flutter-sdk.git ~/Developer/flutter
      fi
    else
      if [ ! -d ~/Developer/flutter ]; then
        git clone -b main https://github.com/flutter/flutter.git ~/Developer/flutter
      fi
    fi 

    # maestro for testing
    curl -Ls "https://get.maestro.mobile.dev" | bash
  fi

  if [ $CPPTOOLS = 1 ]; then
    brew install gmp mpfr ncurses
    # Boehm-Demers-Weiser garbage collector
    brew install bdw-gc
  fi

  if [ $UNITYTOOLS = 1 ]; then
    brew install dotnet
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
  if [ $SECURITYTOOLS = 1 ]; then
    # https://github.com/joxeankoret/diaphora
  fi
  if [ $GENERICCASKTOOLS = 1 ]; then
    brew install appcleaner baidunetdisk caffeine dash docker keka tor-browser --cask
    # also install regex for safari: https://apps.apple.com/ch/app/regex-for-safari/id1597580456?l=en-GB
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

git submodule init
git submodule update

# Copy dotfiles after installation, because some install script like to add stuff to .zshrc (evil right?!?)
# create a backup, better safe than sorry.
[ -f ~/.emacs ] && mv ~/.emacs     ~/.emacs.old
[ -f ~/.inputrc ] && mv ~/.inputrc   ~/.inputrc.old
[ -f ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.old
[ -f ~/.tmux.conf ] && mv ~/.tmux.conf ~/.tmux.conf.old
[ -d ~/.tmux.old ] && rm -r ~/.tmux.old
[ -d ~/.tmux ] && mv ~/.tmux ~/.tmux.old
[ -f ~/.vimrc ] && mv ~/.vimrc     ~/.vimrc.old
[ -f ~/.config ] && mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.old
[ -f ~/.zshrc ] && mv ~/.zshrc     ~/.zshrc.old
[ -f ~/.zshfunctions ] && mv ~/.zshfunctions ~/.zshfunctions.old
[ -f ~/.zshenv ] && mv ~/.zshenv     ~/.zshenv.old

cp .emacs ~/.emacs
cp .inputrc   ~/.inputrc
cp .gitconfig ~/.gitconfig
cp .tmux.conf ~/.tmux.conf
cp -a .tmux   ~/.tmux
cp .zshrc     ~/.zshrc
cp .zshenv    ~/.zshenv
cp .zshfunctions ~/.zshfunctions

if [[ $OSTYPE == 'darwin'* ]]; then
  [ -f ~/Library/Application\ Support/Code/User/settings.json ] && mv ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.old
  mkdir -p ~/Library/Application\ Support/Code/User
  mkdir -p ~/Library/Application\ Support/Code\ -\ Insiders/User
  cp vscode/.vscode-settings.json ~/Library/Application\ Support/Code/User/settings.json # VSCode
  cp vscode/.vscode-settings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/settings.json # VSCode Insiders
  #cp vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings # VSCode
  #cp vscode/keybindings.json ~/Library/Application\ Support/Code\ -\ Insiders/User/keybindings.json # VSCode Insiders
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false # VSCode
  defaults write com.microsoft.VSCodeInsiders ApplePressAndHoldEnabled -bool false # VSCode Insiders
fi


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

if [ $UNITYTOOLS = 1 ]; then
  code --install-extension visualstudiotoolsforunity.vstuc
fi

if [ $FORMALMETHODS = 1 ]; then
  code --install-extension banacorn.agda-mode
fi

if [ $MOBILETOOLS = 1 ]; then
  code --install-extension Dart-Code.dart-code
  code --install-extension Dart-Code.flutter
  code --install-extension gmlewis-vscode.flutter-stylizer # nice button at bottom
  code --install-extension mariomatheu.syntax-project-pbxproj
  # Flutter test coverage:
  code --install-extension ryanluker.vscode-coverage-gutters
  code --install-extension flutterando.flutter-coverage
fi


if [ $MOBILETOOLS = 1 ]; then
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

if ! isadmin; then
    # store npm packages on the user-level not admin level.
    # http://michaelb.org/archive/article/30.html
    npm config set prefix ~/.local
fi
npm install -g pyright
npm install -g bash-language-server


if [[ $OSTYPE == 'darwin'* ]] && isadmin; then
  #echo "Next: Installing rclone and others that need root permission"
  #waitconfirm
  #sudo -v ; curl https://rclone.org/install.sh | sudo bash
  # brew install macfuse --cask # reinstall after changing security properties
fi
#later setup wasabi-kdkdk:
#using: https://wasabi-support.zendesk.com/hc/en-us/articles/115001600252-How-do-I-use-Rclone-with-Wasabi-
#s3.ap-northeast-1.wasabisys.com with PW in pass
# restart and make sure macfuse works, then:
#rclone mount wasabi-kdkdk:kdkdk/ wasabi-kdkdk/ &
# rclone copy source:path destination:path

# System changes for macOS
if [[ $OSTYPE == 'darwin'* ]] && isadmin; then
  echo "Next: Installing system changes for macOS."
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
