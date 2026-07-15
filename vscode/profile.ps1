# VS Code PowerShell profile fragment; equivalent to vscode/.zshenv and
# vscode/.zshrc.d/40_ishell_setup.zsh.

# VS Code's Windows installer normally adds `code` to PATH. Keep the common
# per-user and machine locations available when it does not.
$codeBinPaths = @(
    (Join-Path $env:LOCALAPPDATA "Programs/Microsoft VS Code/bin")
    (Join-Path $env:ProgramFiles "Microsoft VS Code/bin")
)

foreach ($codeBinPath in $codeBinPaths) {
    if ((Test-Path -LiteralPath $codeBinPath) -and
        (($env:Path -split [IO.Path]::PathSeparator) -notcontains $codeBinPath)) {
        $env:Path = "$codeBinPath$([IO.Path]::PathSeparator)$env:Path"
    }
}
