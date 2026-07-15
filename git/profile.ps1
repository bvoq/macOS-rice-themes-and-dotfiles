# Git PowerShell profile fragment; equivalent to git/.zshrc.d/00_safe_config.zsh.

# GNU tools shipped with Git for Windows.
$gitUnixBin = "C:\Program Files\Git\usr\bin"
if (Test-Path -LiteralPath $gitUnixBin -PathType Container) {
    foreach ($tool in @("awk", "bzip2", "cut", "grep", "gzip", "less", "sed", "touch", "uniq", "xargs")) {
        New-Alias -Name $tool -Value (Join-Path $gitUnixBin "$tool.exe") -Force
    }
}

function gitroot {
    Set-Location (git rev-parse --show-toplevel)
}

function gitzip {
    $archiveName = "{0}.zip" -f (Split-Path -Leaf (Get-Location))
    git archive HEAD -o $archiveName
}

function largegit {
    git rev-list --objects --all |
        git cat-file --batch-check="%(objecttype) %(objectname) %(objectsize) %(rest)" |
        Where-Object { $_ -match '^blob ' } |
        Sort-Object {
            [int64](($_ -split ' ', 4)[2])
        } |
        ForEach-Object { $_ }
}
