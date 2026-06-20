# Shared PowerShell functions for dotfiles scripts
# This file contains utility functions used by bootstrap.ps1 and profile.ps1

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
        $arrPath = $arrPath | Where-Object { $_ -notMatch "^$path\\?" }
    }
    $value = ($arrPath + $addPath) -join ';'
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

function l { eza @args }
function la { eza -lAF @args }

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

function cpwd() { Get-Location | Set-Clipboard }

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
