nvimdirdiff()
{
    DIR1=$(printf '%q' "$1"); shift
    DIR2=$(printf '%q' "$1"); shift
    nvim $@ -c "DirDiff $DIR1 $DIR2"
}

nvimdiff()
{
    DIR1=$(printf '%q' "$1"); shift
    DIR2=$(printf '%q' "$1"); shift
    nvim $@ -d $DIR1 $DIR2
}
