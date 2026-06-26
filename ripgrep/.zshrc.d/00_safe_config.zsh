# Search for files:
alias rgd='rg --hidden --files --no-ignore --sort-files . 2> /dev/null | xargs -0 dirname | uniq | rg'
alias rgf='rg --hidden --files --no-ignore --sort-files . 2> /dev/null | rg'
rgall() {
  rg --files | rg "$1" ; rg --hidden -uu "$1"
}
rgvim() { # use :cn and :cp to navigate afterwards, :cl to list
  vim -c 'set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --fixed-strings' \
      -c "grep ${1} ." .
}
export -f rgall > /dev/null
_is_on() { [[ -o $1 ]] && return 0 || return 1 }
rgdot() {
  local eg_was_on=1 gd_was_on=1
  _is_on extended_glob || eg_was_on=0
  _is_on glob_dots     || gd_was_on=0
  setopt extended_glob glob_dots
  rg "$1" .*~.zsh_history(.)
  (( eg_was_on == 0 )) && unsetopt extended_glob
  (( gd_was_on == 0 )) && unsetopt glob_dots
}
rgempty() {
    # empty directories
    find . -type d -empty -print
    # grep is slightly faster with whitespaces.
    find . -type f ! -exec grep -q '[^[:space:]]' {} \; -print
    # alternatively: find . -type f ! -exec rg -q '[^[:space:]]' {} \; -print
}
export -f rgempty > /dev/null

# Use as follows: rgfzf '*_bloc.dart' to recursively find all files ending with _bloc.dart and then use fzf to find a string.
rgfzf() {
  rg --no-heading --hidden --sort-files --line-number --color=always --glob "$1" "" | fzf --ansi --nth=3..
}
export -f rgfzf > /dev/null
