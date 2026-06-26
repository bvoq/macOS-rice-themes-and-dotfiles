alias brewleaves='brew deps --installed | grep -E "$(paste -sd "|" <(brew leaves))"'

brewmem() {
  brew list --formula | xargs -n1 -P8 -I {} sh -c "brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'" | sort -h -r -k2 - | xargs -L1 bash -c 'echo $0 $1 Leaves: $(brew uses --installed --recursive $0 | grep -E "( |^)$(paste -sd " " <(brew leaves) | sed "s/ /( |$)|( |^)/g")( |$)")'
}
export -f brewmem > /dev/null

alias brewmemsimple="brew list --formula | xargs -n1 -P8 -I {} sh -c \"brew info {} | egrep '[0-9]* files, ' | sed 's/^.*[0-9]* files, \(.*\)).*$/{} \1/'\" | sort -h -r -k2 - | column -t"

report_brewfile_size() {
  local brew_file="$1"
  local brew_cellar brew_caskroom
  brew_cellar="$(brew --cellar)"
  brew_caskroom="$(brew --caskroom)"
  echo ">>> size report for $brew_file (sorted by size, largest first)"

  echo "  formulas (including transitive dependencies):"
  {
    brew bundle list --file="$brew_file" --formula 2>/dev/null | while read -r dep; do
      dep="${dep##*/}"
      echo "$dep"
      brew deps --installed "$dep" 2>/dev/null
    done
  } | sort -u | while read -r dep; do
    [ -d "$brew_cellar/$dep" ] && /usr/bin/du -sk "$brew_cellar/$dep" | awk -v name="$dep" '{ printf "%d\t%s\n", $1, name }'
  done | sort -rn | awk -F'\t' '{ printf "  %8.1f MB  %s\n", $1/1024, $2 }'

  echo "  casks:"
  brew bundle list --file="$brew_file" --cask 2>/dev/null | while read -r cask; do
    [ -d "$brew_caskroom/$cask" ] && /usr/bin/du -sk "$brew_caskroom/$cask" | awk -v name="$cask" '{ printf "%d\t%s\n", $1, name }'
  done | sort -rn | awk -F'\t' '{ printf "  %8.1f MB  %s\n", $1/1024, $2 }'
  echo ">>> finish\n"
}
