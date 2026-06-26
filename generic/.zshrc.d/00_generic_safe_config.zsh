# List all files colorized in long format
alias l="eza"

alias grabsite='wget -r -np --wait=1 -k --execute="robots = off" --mirror --random-wait --user-agent="Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:52.0) Gecko/20100101 Firefox/52.0"'

# Find and interactively delete duplicate files
alias dup='fdupes -d'

# Merge PDF files, preserving hyperlinks
# Usage: `mergepdf input{1,2,3}.pdf`
alias mergepdf='gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=_merged.pdf'
alias mergepdf2='pdfjoin --rotateoversize false'

# Usage: pdfjoings merged.pdf file1.pdf file2.pdf ... fileN.pdf
pdfjoings () {
  gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile="$1" "${@:2}"
}
