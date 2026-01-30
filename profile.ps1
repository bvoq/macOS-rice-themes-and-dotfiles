# Source shared functions
. $PSScriptRoot\functions.ps1

# PowerShell privacy and update settings
$env:POWERSHELL_TELEMETRY_OPTOUT = "1"
$env:POWERSHELL_UPDATECHECK = "Off"

# Windows dotfiles
# Set-Location C:\
new-alias -Name clip -Value "C:\Windows\System32\clip.exe"
new-alias -Name pbcopy -Value "C:\Windows\System32\clip.exe"
new-alias -Name ncdu -Value gdu
new-alias -Name dup -Value windows_czkawka_cli 
new-alias -Name pass -Value gopass

# Github GNU tools aliases
new-alias -Name awk -Value "C:\Program Files\Git\usr\bin\awk.exe"
new-alias -Name bzip2 -Value "C:\Program Files\Git\usr\bin\bzip2.exe"
new-alias -Name cut -Value "C:\Program Files\Git\usr\bin\cut.exe"
new-alias -Name grep -Value "C:\Program Files\Git\usr\bin\grep.exe"
new-alias -Name gzip -Value "C:\Program Files\Git\usr\bin\gzip.exe"
new-alias -Name less -Value "C:\Program Files\Git\usr\bin\less.exe"
new-alias -Name sed -Value "C:\Program Files\Git\usr\bin\sed.exe"
new-alias -Name touch -Value "C:\Program Files\Git\usr\bin\touch.exe"
new-alias -Name uniq -Value "C:\Program Files\Git\usr\bin\uniq.exe"
new-alias -Name xargs -Value "C:\Program Files\Git\usr\bin\xargs.exe"

# Use analyzer using: Invoke-ScriptAnalyzer .\your-script.ps1
# Auto-install PSScriptAnalyzer if not present
if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -ErrorAction SilentlyContinue
}
Import-Module PSScriptAnalyzer -ErrorAction SilentlyContinue

function ymp3 { yt-dlp -x --audio-format mp3 --add-metadata --embed-thumbnail --cookies-from-browser chrome $args }
function ymp4 { yt-dlp -fmp4 --write-sub --write-auto-sub --sub-lang "en.*" --cookies-from-browser chrome $args }

# Set autocomplete similar to bash with a menu showing the options.
# Also check out -Function MenuComplete.
Set-PSReadlineKeyHandler -Key Tab -Function Complete

# When pushing arrow up and you've already typed something, it will only show prefixed strings.
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward


# TODO set your own host
# Write-Host "`e]0;$PWD`a" -NoNewLine
Clear-Host

# Enable this if you use Flutter in China.
# $env:FLUTTER_STORAGE_BASE_URL='https://storage.flutter-io.cn'
# $env:PUB_HOSTED_URL='https://pub.flutter-io.cn'


# zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Starship
Invoke-Expression (& 'C:\Program Files\starship\bin\starship.exe' init powershell)
Enable-TransientPrompt

# fnm (Fast Node Manager)
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression

