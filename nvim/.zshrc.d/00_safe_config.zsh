nvimdirdiff() {
  DIR1=$(printf '%s\n' "$1" | sed "s/'/''/g")
  shift
  DIR2=$(printf '%s\n' "$1" | sed "s/'/''/g")
  shift
  nvim "$@" -c "execute 'DirDiff ' . fnameescape('$DIR1') . ' ' . fnameescape('$DIR2')"
}

nvimdiff() {
  DIR1=$1
  shift
  DIR2=$1
  shift
  nvim "$@" -d "$DIR1" "$DIR2"
}
