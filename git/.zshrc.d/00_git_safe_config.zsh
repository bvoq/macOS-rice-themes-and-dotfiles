alias gitroot="cd \$(git rev-parse --show-toplevel)"
alias largegit="git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print substr($""0,6)}' | sort --numeric-sort --key=2 | gnumfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest"

