# WinGet helpers and active manifest lists.
# This is sourced by windows/install.ps1 so the command and accumulator are
# shared with every folder installer in the razordot.ps1 process.

if (-not $global:RAZORDOT_RUN_ID) {
    $global:RAZORDOT_RUN_ID = [guid]::NewGuid().ToString()
}

# Reinitialize the run-specific accumulator when razordot.ps1 is run again in
# the same PowerShell session.
if ($global:RAZORDOT_WINGET_ACCUMULATOR_RUN_ID -ne $global:RAZORDOT_RUN_ID) {
    if (-not [string]::IsNullOrWhiteSpace($global:RAZORDOT_WINGET_MANIFEST_DIRECTORY)) {
        Remove-Item -LiteralPath $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY `
            -Recurse -Force -ErrorAction SilentlyContinue
    }

    $global:RAZORDOT_WINGET_ACCUMULATOR_RUN_ID = $global:RAZORDOT_RUN_ID
    $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY = $null
    $global:RAZORDOT_WINGET_MANIFEST_PATHS = @()
    $global:RAZORDOT_WINGET_IMPORT_FAILED = $false
    $global:RAZORDOT_WINGET_CLEANUP_DONE = $false
    $global:RAZORDOT_WINGET_CLEANUP_DECISION = $null
}

function Get-WingetManifestAccumulatorDirectory {
    if ([string]::IsNullOrWhiteSpace($global:RAZORDOT_WINGET_MANIFEST_DIRECTORY)) {
        $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY = Join-Path `
            ([IO.Path]::GetTempPath()) "razordot-winget-$($global:RAZORDOT_RUN_ID)"
        New-Item -Path $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY `
            -ItemType Directory -Force | Out-Null
    }

    return $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY
}

function install_wingetfile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [switch]$IgnoreVersions
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Warning "WinGet manifest missing: $Path"
        $global:RAZORDOT_WINGET_IMPORT_FAILED = $true
        return $false
    }

    $manifestPath = (Resolve-Path -LiteralPath $Path).Path
    $accumulatorDirectory = Get-WingetManifestAccumulatorDirectory
    $manifestIndex = @($global:RAZORDOT_WINGET_MANIFEST_PATHS).Count
    $accumulatorPath = Join-Path $accumulatorDirectory (
        "{0:D4}_{1}" -f $manifestIndex, [IO.Path]::GetFileName($manifestPath)
    )

    # Keep each manifest as a separate file, mirroring the Brewfile accumulator
    # while retaining the original WinGet JSON structure for cleanup later.
    Copy-Item -LiteralPath $manifestPath -Destination $accumulatorPath -Force
    $global:RAZORDOT_WINGET_MANIFEST_PATHS += $accumulatorPath

    Write-Host "`n>>> winget import --import-file $manifestPath" -ForegroundColor Cyan
    if ($IgnoreVersions) {
        $imported = Invoke-WingetManifestImport -Path @($manifestPath) -IgnoreVersions
    } else {
        $imported = Invoke-WingetManifestImport -Path @($manifestPath)
    }

    if (-not $imported) {
        $global:RAZORDOT_WINGET_IMPORT_FAILED = $true
        return $false
    }

    return $true
}

function cleanup_wingetfiles {
    if ($global:RAZORDOT_WINGET_CLEANUP_DONE) { return }

    # Like the Brewfile cleanup, never reconcile the whole machine during a
    # single-folder install. The selected folder is not the complete desired
    # package set in that mode.
    if ($global:RAZORDOT_SINGLE_FOLDER) {
        Write-Host "Skipping WinGet cleanup during a single-folder install." -ForegroundColor Yellow
        $global:RAZORDOT_WINGET_CLEANUP_DONE = $true
        return
    }

    $manifestPaths = @($global:RAZORDOT_WINGET_MANIFEST_PATHS)
    if ($manifestPaths.Count -eq 0) {
        return
    }

    if ($global:RAZORDOT_WINGET_IMPORT_FAILED) {
        Write-Warning "Skipping WinGet cleanup because at least one manifest import failed."
        $global:RAZORDOT_WINGET_CLEANUP_DONE = $true
        return
    }

    $entries = @(Get-WingetManifestPackageEntries -Path $manifestPaths)
    $hasMachineEntries = @($entries | Where-Object { $_.Scope -eq "machine" }).Count -gt 0
    $hasUserEntries = @($entries | Where-Object { $_.Scope -eq "user" }).Count -gt 0
    $cleanupDeferred = $false

    # Machine cleanup is performed here, after phase 2, because all folder
    # phase_1 calls have completed by then. It still requires an elevated
    # process even though this phase also installs user-scoped packages.
    if ($hasMachineEntries) {
        if (Verify-Elevated) {
            Invoke-WingetManifestCleanup -Path $manifestPaths -Scope machine
        } else {
            Write-Warning "Skipping machine-scoped WinGet cleanup: this PowerShell process is not elevated."
            $cleanupDeferred = $true
        }
    }

    if ($hasUserEntries) {
        Invoke-WingetManifestCleanup -Path $manifestPaths -Scope user
    }

    if (-not $cleanupDeferred) {
        $global:RAZORDOT_WINGET_CLEANUP_DONE = $true
    }
}

function Remove-WingetManifestAccumulator {
    if (-not [string]::IsNullOrWhiteSpace($global:RAZORDOT_WINGET_MANIFEST_DIRECTORY)) {
        Remove-Item -LiteralPath $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY `
            -Recurse -Force -ErrorAction SilentlyContinue
    }
    $global:RAZORDOT_WINGET_MANIFEST_DIRECTORY = $null
    $global:RAZORDOT_WINGET_MANIFEST_PATHS = @()
}
