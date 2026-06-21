#!/bin/zsh

# General
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export ARCHFLAGS="-arch $(uname -m)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Pager settings for less
export PAGER='less'
export LESS='-R'

# Bat theme
export BAT_THEME='zenburn'

# ccache
export PATH="/opt/homebrew/opt/ccache/libexec:$PATH"
# Python
# PYBIN=$(realpath ~/Library/Python/3.8/bin)
# export PATH="$PYBIN:$PATH"
# VSCode Insiders (picked first if installed)
export PATH="$PATH:/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin"
# VSCode
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
# Rust
export PATH="$PATH:/${HOME}/.cargo/bin"
# Go
export GOPATH="$HOME/go"
export PATH=${PATH}:${HOME}/go/bin
# Emacs
export PATH="$PATH:$HOME/.config/emacs/bin"
export DOOMDIR="$HOME/.config/doom"

# Unity/Dotnet
export DOTNET_ROOT="${HOME}/.dotnet"
export PATH="${PATH}:$DOTNET_ROOT"

# Ruby (user-installed)
GEM_PATH="$HOME/.gem/ruby"
if [ -d "$GEM_PATH" ]; then
    # Find the largest version directory
    LARGEST_VERSION=$(\ls "$GEM_PATH" | sort -V | tail -n 1)
    if [ -d "$GEM_PATH/$LARGEST_VERSION/bin" ]; then
        export PATH="$GEM_PATH/$LARGEST_VERSION/bin:$PATH"
    fi
fi

for zshenv_file in "${ZDOTDIR:-$HOME}"/.zshenv.d/*.zsh(N); do
  source "$zshenv_file"
done
unset zshenv_file
