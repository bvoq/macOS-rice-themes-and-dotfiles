# interactive shell behavior (setopt, history) plus pre-compinit setup:
# fpath/FPATH additions, completion zstyles, plugins that only provide completion sources

# store all cd directory pushes
setopt AUTO_PUSHD

FPATH=$HOME/.zsh/completions:$FPATH

# for those old people who still use bash? bash completion support
# [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
