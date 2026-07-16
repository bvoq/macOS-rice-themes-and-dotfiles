function rgd {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )
    rg --hidden --files --no-ignore --sort-files . 2>$null |
        Split-Path -Parent |
        Sort-Object -Unique |
        rg $Pattern
}

function rgf {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )
    rg --hidden --files --no-ignore --sort-files . 2>$null | rg $Pattern
}

function rgall {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )
    rg --files | rg $Pattern
    rg --hidden -uu $Pattern
}

function rgvim {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )
    & vim -c 'set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --fixed-strings' -c "grep $Pattern ." .
}
