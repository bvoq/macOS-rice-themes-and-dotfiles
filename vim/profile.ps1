# Vim PowerShell profile fragment; equivalent to vim/.zshrc.d/00_safe_config.zsh.

function vimdirdiff {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Dir1,
        [Parameter(Mandatory = $true)]
        [string]$Dir2
    )

    & vim -c "DirDiff $Dir1 $Dir2"
}
