alias gitroot="cd \$(git rev-parse --show-toplevel)"
# find large git files in commit history.
alias largegit="git rev-list --objects --all | git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | awk '/^blob/ {print substr($""0,6)}' | sort --numeric-sort --key=2 | gnumfmt --field=2 --to=iec-i --suffix=B --padding=7 --round=nearest"

