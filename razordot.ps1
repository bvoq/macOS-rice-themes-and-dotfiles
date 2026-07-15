# Windows counterpart to razordot.zsh.
# Keep orchestration here; each folder owns an install.ps1 that defines phase
# functions. The selected installer is sourced once per phase, then that phase
# function is called, matching the macOS installer model.

$repoRoot = $PSScriptRoot
$profileFragmentsDir = Join-Path (Split-Path -Parent $PROFILE.CurrentUserAllHosts) "profiles.d"
New-Item -Path $profileFragmentsDir -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
. (Join-Path $repoRoot "windows/functions.ps1")
$global:RAZORDOT_RUN_ID = [guid]::NewGuid().ToString()

function link_file {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SourcePath,
        [Parameter(Mandatory = $true, Position = 1)]
        [string]$TargetPath
    )

    $sourcePath = [IO.Path]::GetFullPath($SourcePath)
    $targetPath = [IO.Path]::GetFullPath($TargetPath)
    if (-not (Get-Item -LiteralPath $sourcePath -Force -ErrorAction SilentlyContinue)) {
        throw "Link source not found: $sourcePath"
    }

    $homePath = [IO.Path]::GetFullPath($HOME).TrimEnd('\', '/')
    $backupRoot = Join-Path $repoRoot "backups"
    if ($targetPath.StartsWith($homePath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        $relativeTargetPath = $targetPath.Substring($homePath.Length).TrimStart('\', '/')
        $backupPath = Join-Path (Join-Path $backupRoot "home") $relativeTargetPath
    } else {
        $relativeTargetPath = $targetPath.TrimStart('\', '/')
        $backupPath = Join-Path (Join-Path $backupRoot "absolute") $relativeTargetPath
    }

    $targetItem = Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
    if ($targetItem) {
        if ($targetItem.LinkType -in @("SymbolicLink", "Junction")) {
            $existingTarget = [string]@($targetItem.Target)[0]
            if (-not [IO.Path]::IsPathRooted($existingTarget)) {
                $existingTarget = Join-Path (Split-Path -Parent $targetPath) $existingTarget
            }
            if ([IO.Path]::GetFullPath($existingTarget).Equals($sourcePath, [StringComparison]::OrdinalIgnoreCase)) {
                return
            }
        }

        $backupBase = $backupPath
        $backupSuffix = 1
        while (Get-Item -LiteralPath $backupPath -Force -ErrorAction SilentlyContinue) {
            $backupPath = "$backupBase.$backupSuffix"
            $backupSuffix++
        }

        New-Item -ItemType Directory -Path (Split-Path -Parent $backupPath) -Force | Out-Null
        Move-Item -LiteralPath $targetPath -Destination $backupPath
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $targetPath) -Force | Out-Null
    try {
        New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath | Out-Null
    } catch {
        throw "Could not create link '$targetPath' -> '$sourcePath'. Enable Developer Mode or run PowerShell elevated. $($_.Exception.Message)"
    }
}

######################
# MODIFIABLE SECTION #
######################
# Enable or disable feature folders here, analogous to install_folders in
# razordot.zsh. Each enabled folder must contain an install.ps1.
$installFolders = @(
    "windows"
    "git"
    "starship"
    "vim"
    "vscode"
)

########################
# WINDOWS PREFLIGHT    #
########################
Write-Host "PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Cyan
Write-Host "PSScriptRoot $PSScriptRoot" -ForegroundColor Cyan

# Detect and fix PSModulePath cross-contamination (pwsh 7 paths leaking into PS 5.1 or vice versa).
# See https://github.com/PowerShell/PowerShell/issues/18530
$pathEntries = $env:PSModulePath -split ';'
$contaminated = @()
if ($PSVersionTable.PSVersion.Major -le 5) {
    # PS 5.1 should NOT have pwsh 7 module paths.
    $contaminated = $pathEntries | Where-Object {
        ($_ -match '\\PowerShell\[7-9]') -or
        ($_ -match '[\\/]PowerShell[\\/]Modules' -and $_ -notmatch 'WindowsPowerShell')
    }
} else {
    # pwsh 7 inheriting WindowsPowerShell paths is normal (by design), so nothing to fix.
}
if ($contaminated.Count -gt 0) {
    Write-Host "`nWARN: PSModulePath cross-contamination detected!" -ForegroundColor Red
    Write-Host "  The following pwsh 7 paths do not belong in PowerShell $($PSVersionTable.PSVersion):" -ForegroundColor Yellow
    $contaminated | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    $clean = ($pathEntries | Where-Object { $_ -notin $contaminated }) -join ';'
    $env:PSModulePath = $clean
    Write-Host "  OK: Removed contaminated paths for this session." -ForegroundColor Green
    Write-Host "  Tip: run razordot.ps1 directly from powershell.exe, not from a pwsh/VS Code terminal.`n" -ForegroundColor Yellow
} else {
    Write-Host "PSModulePath: OK (no cross-contamination)" -ForegroundColor Green
}

# Optional: `./razordot.ps1 --install <folder>` runs only that folder, even if
# it is disabled above.
$singleFolder = $null
$global:RAZORDOT_SINGLE_FOLDER = 0
if ($args.Count -ge 1 -and $args[0] -eq "--install") {
    if ($args.Count -ne 2) {
        throw "Usage: .\razordot.ps1 --install <folder>"
    }

    $singleFolder = $args[1].TrimEnd('\\', '/')
    $singleInstallScript = Join-Path $repoRoot (Join-Path $singleFolder "install.ps1")
    if (-not (Test-Path -LiteralPath $singleInstallScript -PathType Leaf)) {
        throw "Usage: .\razordot.ps1 --install <folder> (no '$singleFolder/install.ps1' found)"
    }
    $installFolders = @($singleFolder)
    $global:RAZORDOT_SINGLE_FOLDER = 1
}

$installScripts = foreach ($folder in $installFolders) {
    $installScript = Join-Path $repoRoot (Join-Path $folder "install.ps1")
    if (-not (Test-Path -LiteralPath $installScript -PathType Leaf)) {
        throw "Install script not found for '$folder': $installScript"
    }
    (Resolve-Path -LiteralPath $installScript).Path
}

################
# RUN RAZORDOT #
################

try {
# Phase 1: machine-scoped installs and machine-level changes.
foreach ($installScript in $installScripts) {
    function phase_1_machine_installs {}
    . $installScript
    phase_1_machine_installs
}

# Phase 2: user-level installs.
foreach ($installScript in $installScripts) {
    function phase_2_user_installs {}
    . $installScript
    phase_2_user_installs
}

# Phase 3: user dotfiles.
foreach ($installScript in $installScripts) {
    function phase_3_dotfiles {}
    . $installScript
    phase_3_dotfiles
}

# Phase 4: user-level setup that requires dotfiles to be in place.
foreach ($installScript in $installScripts) {
    function phase_4_post_dotfiles {}
    . $installScript
    phase_4_post_dotfiles
}

# Phase 5: heavy system changes.
foreach ($installScript in $installScripts) {
    function phase_5_system_changes {}
    . $installScript
    phase_5_system_changes
}

} finally {
    # The WinGet command keeps copies of every imported manifest only for this
    # run, so always remove them even if a later phase fails.
    if (Get-Command Remove-WingetManifestAccumulator -ErrorAction SilentlyContinue) {
        Remove-WingetManifestAccumulator
    }
}
