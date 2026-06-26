#!/bin/zsh

isadmin() { id -G $1 | grep -q -w 80 ; }
is_on() { [[ -o $1 ]] && return 0 || return 1 }

waitconfirm() {
    if read -q "choice?Continue [press y/n]? "; then
        echo "Continuing..."
    else
        exit 0
    fi
}

bash_error_handler() {
    # Iterate over the stack trace to find the original error location
    echo "Encountered an error. Stacktrace:"
    for (( i=${#BASH_SOURCE[@]}-1; i >= 0; i-- )); do
        if [[ $i == 0 ]]; then
            args=("$@")
            file="${args[0]}"
            lineno="E" # the executed command
            content_on_line="${args[*]:2}"
        else
            file="${BASH_SOURCE[$i]}"
            lineno="${BASH_LINENO[$((i-1))]}"
            content_on_line=$(awk "NR == $lineno" "$file")
        fi
        trimmed_line=$(echo "$content_on_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ ${#trimmed_line} -gt 50 ]]; then
            limited_line="${trimmed_line:0:47}..."
        else
            limited_line="$trimmed_line"
        fi
        padded_line=$(printf "%-50s" "$limited_line")
        echo -e "\t$padded_line  on line $lineno\t in file $file"
    done
}

# A function that returns nonzero without tripping errexit in-context (e.g. the
# left side of `a && b`, or an explicit `return 1`) unwinds its frame before the
# ERR trap fires at the call site, so funcfiletrace no longer holds the failing
# line. The DEBUG trap records each command's location before it runs, keeping
# the true inner line available to the error handler even after the unwind.
_unodot_record_command_location() {
    UNODOT_LAST_LOCATION="${funcfiletrace[1]}"
}

_unodot_format_source_line() {
    local file="$1" lineno="$2"
    local content_on_line trimmed_line limited_line padded_line
    content_on_line="$(awk "NR == $lineno" "$file" 2>/dev/null)"
    trimmed_line=$(echo "$content_on_line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [[ ${#trimmed_line} -gt 50 ]]; then
        limited_line="${trimmed_line:0:47}..."
    else
        limited_line="$trimmed_line"
    fi
    padded_line=$(printf "%-50s" "$limited_line")
    echo "\t$padded_line  on line $lineno\t in file $file."
}

zsh_error_handler() {
    # Iterate over the stack trace to find the original error location
    echo "Encountered an error. Stacktrace:"
    if [[ -n "$UNODOT_LAST_LOCATION" && "$UNODOT_LAST_LOCATION" != "${funcfiletrace[1]}" ]]; then
        _unodot_format_source_line "${UNODOT_LAST_LOCATION%%:*}" "${UNODOT_LAST_LOCATION##*:}"
    fi
    for (( i=${#funcfiletrace[@]}; i >= 1; i-- )); do
        fileandlineno=${funcfiletrace[i]}
        file=${fileandlineno%%:*}  # Get the first part before the first ':'
        lineno=${fileandlineno##*:}  # Get the last part after the last ':'
        _unodot_format_source_line "$file" "$lineno"
    done
}

set_error_handler() {
    if [[ $SHELL == "/bin/bash" ]]; then
        set -eE -o functrace
        trap 'bash_error_handler ${BASH_SOURCE} ${BASH_COMMAND} ${BASH_ARGV[@]}' ERR
    elif [[ $SHELL == "/bin/zsh" ]]; then
        set -e
        trap '_unodot_record_command_location' DEBUG
        trap 'zsh_error_handler' ERR
    else
        echo "No error handler for shell $SHELL"
    fi
}

install_brewfile() {
  local brew_file="$1"
  [ -f "$brew_file" ] || { echo "Brewfile missing: $brew_file"; return 1; }
  echo "\n>>> brew bundle --file=$brew_file"
  brew bundle --verbose --file="$brew_file"
}

link_dotfile() {
    local source_path="${1:a}"
    local target_path="${2:a}"
    local backup_root="$PWD/backups"
    local backup_path

    [[ -e "$source_path" || -L "$source_path" ]] || { echo "Dotfile source missing: $source_path"; return 1; }

    if [[ "$target_path" == "$HOME/"* ]]; then
        backup_path="$backup_root/home/${target_path#$HOME/}"
    else
        backup_path="$backup_root/absolute/${target_path#/}"
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
            return 0
        fi

        local backup_base="$backup_path"
        local backup_suffix=1
        while [[ -e "$backup_path" || -L "$backup_path" ]]; do
            backup_path="$backup_base.$backup_suffix"
            (( backup_suffix++ ))
        done

        mkdir -p "${backup_path:h}"
        mv "$target_path" "$backup_path"
    fi

    mkdir -p "${target_path:h}"
    ln -sfn "$source_path" "$target_path"
}

# Darwin specific
assure_userlevel_zsh() {
    if [[ "$(dscl . -read ~/ UserShell)" == */bin/bash ]]; then
        echo "Your current user shell is /bin/bash. Let's change this to zsh."
        echo "This script will execute: chsh -s /bin/zsh"
        waitconfirm
        chsh -s /bin/zsh
    fi
}

check_not_rosetta() {
    if [[ "$(uname -m)" == "arm64" && "$(sysctl -n sysctl.proc_translated)" != 0 ]]; then
        echo "It seems you are running this script with Rosetta enabled."
        echo "Make sure that this terminal or session has Rosetta turned off."
        echo "For example: Right-Click Terminal > Get Info > Uncheck Open using Rosetta"
        exit 1
    fi
}
