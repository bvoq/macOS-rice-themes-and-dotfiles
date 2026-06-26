vimdirdiff()
{
    DIR1=$(printf '%q' "$1"); shift
    DIR2=$(printf '%q' "$1"); shift
    \vim $@ -c "DirDiff $DIR1 $DIR2"
}
