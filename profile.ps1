# Windows dotfiles
# Set-Location C:\
new-alias -Name clip -Value "C:\Windows\System32\clip.exe"
new-alias -Name ncdu -Value gdu

# Github GNU tools aliases
new-alias -Name awk -Value "C:\Program Files\Git\usr\bin\awk.exe"
new-alias -Name bzip2 -Value "C:\Program Files\Git\usr\bin\bzip2.exe"
new-alias -Name cut -Value "C:\Program Files\Git\usr\bin\cut.exe"
new-alias -Name grep -Value "C:\Program Files\Git\usr\bin\grep.exe"
new-alias -Name gzip -Value "C:\Program Files\Git\usr\bin\gzip.exe"
new-alias -Name sed -Value "C:\Program Files\Git\usr\bin\sed.exe"
new-alias -Name touch -Value "C:\Program Files\Git\usr\bin\touch.exe"
new-alias -Name uniq -Value "C:\Program Files\Git\usr\bin\uniq.exe"
new-alias -Name xargs -Value "C:\Program Files\Git\usr\bin\xargs.exe"

# Use analyzer using: Invoke-ScriptAnalyzer .\your-script.ps1
Import-Module PSScriptAnalyzer

# Usage: Set-PathVariable -AddPath C:\tmp\bin -RemovePath C:\path\java
# To persist changes set the -Scope User or -Scope Machine
Function Set-PathVariable {
    param (
        [string]$AddPath,
        [string]$RemovePath,
        [ValidateSet('Process', 'User', 'Machine')]
        [string]$Scope = 'Process'
    )
    $regexPaths = @()
    if ($PSBoundParameters.Keys -contains 'AddPath') {
        $regexPaths += [regex]::Escape($AddPath)
    }

    if ($PSBoundParameters.Keys -contains 'RemovePath') {
        $regexPaths += [regex]::Escape($RemovePath)
    }
    $arrPath = [System.Environment]::GetEnvironmentVariable('PATH', $Scope) -split ';'
    foreach ($path in $regexPaths) {
        $arrPath = $arrPath | Where-Object { $_ -notMatch "^$path\\?" } } $value = ($arrPath + $addPath) -join ';'
    [System.Environment]::SetEnvironmentVariable('PATH', $value, $Scope)
}

function vimdirdiff {
    param (
        [string]$Dir1,
        [string]$Dir2
    )
    $command = "vim -c `"DirDiff $Dir1 $Dir2`""
    Invoke-Expression $command
}

function open($name) { start $name  }
function which($name) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command -is [Management.Automation.FunctionInfo]) { $command.ScriptBlock.ToString() }
    elseif ($command -is [Management.Automation.CmdletInfo] -or $command -is [Management.Automation.ApplicationInfo]) { $command.Definition }
    else { "${name}: command not found" }
}
function sudo() {
    if ($args.Length -eq 1) {
        start-process $args[0] -verb "runAs"
    }
    if ($args.Length -gt 1) {
        start-process $args[0] -ArgumentList $args[1..$args.Length] -verb "runAs"
    }
}
function hopen() { start powershell } # start powershell in same directory, with the same user and elevation
function caffeinate() {
    # Usage: caffeinate (indefinitely), caffeinate --time-limit 3600 (1 hour), caffeinate --display-on true
    $awakeExe = "C:\Program Files\PowerToys\PowerToys.Awake.exe"
    if (Test-Path $awakeExe) {
        & $awakeExe $args
    } else {
        Write-Host "PowerToys Awake not found. Install PowerToys first." -ForegroundColor Red
    }
}

function System-Update() {
    Install-WindowsUpdate -IgnoreUserInput -IgnoreReboot -AcceptAll
    Update-Module
    Update-Help -Force
    gem update --system
    gem update
    npm install npm -g
    npm update -g
}

function Verify-Elevated {
    # Get the ID and security principal of the current user account
    $myIdentity=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myPrincipal=new-object System.Security.Principal.WindowsPrincipal($myIdentity)
    # Check to see if we are currently running "as Administrator"
    return $myPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Edit-Profile { Invoke-Expression "$(if($env:EDITOR -ne $null)  {$env:EDITOR } else { 'notepad' }) $profile" }

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


Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Starship prompt
Invoke-Expression (&starship init powershell)

# fnm (Fast Node Manager)
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression

