autoload -U colors && colors

ZSH_THEME_GIT_PROMPT_PREFIX=""
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[red]%}*"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%}+"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%}%%"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[yellow]%}R"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%}D"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[red]%}U"
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg[blue]%}$"
ZSH_THEME_GIT_PROMPT_AHEAD=""
ZSH_THEME_GIT_PROMPT_BEHIND=""
ZSH_THEME_GIT_PROMPT_DIVERGED=""
ZSH_THEME_GIT_PROMPT_EQUAL_REMOTE="%{$fg[green]%}="
ZSH_THEME_GIT_PROMPT_AHEAD_REMOTE="%{$fg[yellow]%}>"
ZSH_THEME_GIT_PROMPT_BEHIND_REMOTE="%{$fg[red]%}<"
ZSH_THEME_GIT_PROMPT_DIVERGED_REMOTE="%{$fg[red]%}X"
ZSH_THEME_GIT_PROMPT_SHA_BEFORE=" %{$fg[white]%}[%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$fg[white]%}]"

function _makeClickablePath() {
  local current_dir="${PWD}"
  local display_path="${current_dir/#$HOME/~}"

  if [[ ${#display_path} -gt 30 ]]; then
    display_path="...${display_path: -27}"
  fi

  local file_url="file://${current_dir}"

  if [[ -n "$ITERM_SESSION_ID" ]]; then
    printf '\e]8;;%s\e\\%s\e]8;;\e\\' "$file_url" "$display_path"
  else
    printf '%s' "$display_path"
  fi
}

custom_prompt=""
last_run_time=""

function _buildBasePrompt() {
  printf "%s[%s]%s%%B%%%%%%b " "%{$fg[cyan]%}" "$(_makeClickablePath)" "%(?.%{$fg[green]%}.%{$fg[red]%})"
}

function pipestatus_parse {
  PIPESTATUS="$pipestatus"
  ERROR=0
  for i in "${(z)PIPESTATUS}"; do
      if [[ "$i" -ne 0 ]]; then
          ERROR=1
      fi
  done

  if [[ "$ERROR" -ne 0 ]]; then
      print "[%{$fg[red]%}$PIPESTATUS%{$fg[cyan]%}]"
  fi
}

function preexec() {
    last_run_time=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')
}

function duration() {
    local duration
    local now=$(perl -MTime::HiRes=time -e 'printf "%.9f\n", time')
    local last=$1
    local last_split=("${(@s/./)last}")
    local now_split=("${(@s/./)now}")
    local T=$((now_split[1] - last_split[1]))
    local D=$((T/60/60/24))
    local H=$((T/60/60%24))
    local M=$((T/60%60))
    local S=$((T%60))
    local s=$(((now_split[2] - last_split[2]) / 1000000000.))
    local m=$(((now_split[2] - last_split[2]) / 1000000.))

    (( $D > 0 )) && duration+="${D}d"
    (( $H > 0 )) && duration+="${H}h"
    (( $M > 0 )) && duration+="${M}m"

    if [[ $S -le 0 ]]; then
        printf "%ims" "$m"
    else
        if ! [[ -z $duration ]] && printf "%s" "$duration"
        local sec_milli=$((S + s))
        printf "%.3fs" "$sec_milli"
    fi
}

function precmd() {
    RETVAL=$(pipestatus_parse)
    local info=""

    if [ ! -z "$last_run_time" ]; then
        local elapsed=$(duration $last_run_time)
        last_run_time=$(print $last_run_time | tr -d ".")
        if [ $(( $(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' | tr -d ".") - $last_run_time )) -gt $(( 120 * 1000 * 1000 * 1000 )) ]; then
            local elapsed_color="%{$fg[magenta]%}"
        elif [ $(( $(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' | tr -d ".") - $last_run_time )) -gt $(( 60 * 1000 * 1000 * 1000 )) ]; then
            local elapsed_color="%{$fg[red]%}"
        elif [ $(( $(perl -MTime::HiRes=time -e 'printf "%.9f\n", time' | tr -d ".") - $last_run_time )) -gt $(( 10 * 1000 * 1000 * 1000 )) ]; then
            local elapsed_color="%{$fg[yellow]%}"
        else
            local elapsed_color="%{$fg[green]%}"
        fi
        info=$(printf "%s%s%s%s%s" "%{$fg[cyan]%}[" "$elapsed_color" "$elapsed" "%{$fg[cyan]%}]" "$RETVAL")
        unset last_run_time
    else
        info="$RETVAL"
    fi

    local base_prompt="$(_buildBasePrompt)"
    [ -z "$info" ] && custom_prompt="$base_prompt" || custom_prompt="$info$base_prompt"
}

setopt PROMPT_SUBST
PROMPT='$custom_prompt'
RPROMPT='%{$fg_bold[green]%}$(git_remote_status)$(git_current_branch)$(git_prompt_short_sha)$(_omz_git_prompt_status)%{$reset_color%}'
