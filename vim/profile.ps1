# Vim PowerShell profile fragment; equivalent to vim/.zshrc.d/00_safe_config.zsh.

function vimdirdiff {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Dir1,
        [Parameter(Mandatory = $true)]
        [string]$Dir2,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$VimArgs
    )

    $EscapedDir1 = $Dir1 -replace "'", "''"
    $EscapedDir2 = $Dir2 -replace "'", "''"
    & vim @VimArgs -c "execute 'DirDiff ' . fnameescape('$EscapedDir1') . ' ' . fnameescape('$EscapedDir2')"
}
