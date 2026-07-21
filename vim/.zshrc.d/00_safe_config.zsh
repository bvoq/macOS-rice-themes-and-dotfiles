vimdirdiff() {
  DIR1=$(printf '%s\n' "$1" | sed "s/'/''/g")
  shift
  DIR2=$(printf '%s\n' "$1" | sed "s/'/''/g")
  shift
  \vim "$@" -c "execute 'DirDiff ' . fnameescape('$DIR1') . ' ' . fnameescape('$DIR2')"
}
