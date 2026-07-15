# Shared PowerShell functions for dotfiles scripts
# This file contains utility functions used by install.ps1, razordot.ps1, and
# profile.ps1.

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

function Get-WingetManifestPackageEntries {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Path
    )

    foreach ($manifestPath in $Path) {
        if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
            throw "WinGet manifest not found: $manifestPath"
        }

        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        foreach ($source in @($manifest.Sources)) {
            $sourceName = [string]$source.SourceDetails.Name
            foreach ($package in @($source.Packages)) {
                $packageIdentifier = [string]$package.PackageIdentifier
                if ([string]::IsNullOrWhiteSpace($packageIdentifier)) {
                    $packageIdentifier = [string]$package.Id
                }
                if ([string]::IsNullOrWhiteSpace($packageIdentifier)) {
                    throw "WinGet manifest package has no PackageIdentifier or Id: $manifestPath"
                }

                $scope = [string]$package.Scope
                if ([string]::IsNullOrWhiteSpace($scope)) { $scope = "user" }

                [PSCustomObject]@{
                    SourceName        = $sourceName
                    PackageIdentifier = $packageIdentifier
                    Scope             = $scope
                    Package           = $package
                }
            }
        }
    }
}

function Merge-WingetPackageManifests {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Path,
        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $sources = [ordered]@{}
    foreach ($manifestPath in $Path) {
        $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
        foreach ($source in @($manifest.Sources)) {
            $sourceDetails = [ordered]@{
                Argument   = [string]$source.SourceDetails.Argument
                Identifier = [string]$source.SourceDetails.Identifier
                Name       = [string]$source.SourceDetails.Name
                Type       = [string]$source.SourceDetails.Type
            }
            $sourceKey = "$($sourceDetails.Name)|$($sourceDetails.Argument)"
            if (-not $sources.Contains($sourceKey)) {
                $sources[$sourceKey] = [ordered]@{
                    SourceDetails = $sourceDetails
                    Packages      = [ordered]@{}
                }
            }

            foreach ($package in @($source.Packages)) {
                $packageIdentifier = [string]$package.PackageIdentifier
                if ([string]::IsNullOrWhiteSpace($packageIdentifier)) {
                    $packageIdentifier = [string]$package.Id
                }
                if ([string]::IsNullOrWhiteSpace($packageIdentifier)) {
                    throw "WinGet manifest package has no PackageIdentifier or Id: $manifestPath"
                }

                $scope = [string]$package.Scope
                if ([string]::IsNullOrWhiteSpace($scope)) { $scope = "user" }
                if ($scope -notin @("user", "machine")) {
                    throw "Unsupported WinGet package scope '$scope' in $manifestPath"
                }

                $mergedPackage = [ordered]@{}
                foreach ($property in $package.PSObject.Properties) {
                    if ($property.Name -ne "Id") {
                        $mergedPackage[$property.Name] = $property.Value
                    }
                }
                $mergedPackage["PackageIdentifier"] = $packageIdentifier
                $mergedPackage["Scope"] = $scope

                # The same package can be listed by several feature manifests.
                # Keep one entry per source, package ID, and scope.
                $packageKey = "$packageIdentifier|$scope"
                $sources[$sourceKey].Packages[$packageKey] = $mergedPackage
            }
        }
    }

    $mergedSources = @(
        foreach ($source in $sources.Values) {
            [ordered]@{
                SourceDetails = $source.SourceDetails
                Packages      = @($source.Packages.Values)
            }
        }
    )
    $mergedManifest = [ordered]@{
        '$schema'    = "https://aka.ms/winget-packages.schema.2.0.json"
        CreationDate = (Get-Date).ToUniversalTime().ToString("o")
        Sources      = $mergedSources
    }

    $outputDirectory = Split-Path -Parent $OutputPath
    if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
        New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
    }
    $mergedManifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    return $OutputPath
}

function Invoke-WingetManifestImport {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Path,
        [switch]$IgnoreVersions
    )

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Warning "WinGet is not available; skipping package import."
        return $false
    }

    $mergedPath = Join-Path ([IO.Path]::GetTempPath()) "razordot-winget-$([guid]::NewGuid()).json"
    try {
        Merge-WingetPackageManifests -Path $Path -OutputPath $mergedPath | Out-Null
        $arguments = @(
            "import", "--import-file", $mergedPath,
            "--accept-package-agreements", "--accept-source-agreements"
        )
        if ($IgnoreVersions) { $arguments += "--ignore-versions" }

        & winget @arguments
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "WinGet import failed with exit code $LASTEXITCODE."
            return $false
        }
        return $true
    } finally {
        Remove-Item -LiteralPath $mergedPath -Force -ErrorAction SilentlyContinue
    }
}

function Get-WingetInstalledPackageIds {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("user", "machine")]
        [string]$Scope,
        [string]$SourceName = "winget"
    )

    $output = @(& winget list --source $SourceName --scope $Scope --details `
        --accept-source-agreements --disable-interactivity 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet could not list $Scope-scoped packages from $SourceName (exit code $LASTEXITCODE)."
    }

    # With --details, each package starts with a line ending in [Package.Id].
    # Redirected output is not console-wrapped, so the identifier remains intact.
    foreach ($line in $output) {
        if ($line -match '^\(\d+\/\d+\).*\[(?<id>[^\[\]]+)\]\s*$') {
            $Matches["id"]
        }
    }
}

function Get-WingetPackageDependencyIds {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageIdentifier,
        [Parameter(Mandatory = $true)]
        [ValidateSet("user", "machine")]
        [string]$Scope,
        [string]$SourceName = "winget"
    )

    $output = @(& winget show --id $PackageIdentifier --exact --source $SourceName --scope $Scope `
        --locale en-US --accept-source-agreements --disable-interactivity 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "WinGet could not read dependencies for $PackageIdentifier (exit code $LASTEXITCODE)."
    }

    $readingPackageDependencies = $false
    foreach ($line in $output) {
        if ($line -match '^\s*-\s*Package Dependencies:\s*$') {
            $readingPackageDependencies = $true
            continue
        }
        if ($readingPackageDependencies) {
            if ($line -match '^\s{8,}(?<id>\S+)\s*$') {
                $Matches["id"]
            } else {
                $readingPackageDependencies = $false
            }
        }
    }
}

function Test-WingetManifestPackagesInstalled {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Path,
        [Parameter(Mandatory = $true)]
        [ValidateSet("user", "machine")]
        [string]$Scope,
        [string]$SourceName = "winget"
    )

    $desiredIds = @(
        Get-WingetManifestPackageEntries -Path $Path |
            Where-Object { $_.SourceName -eq $SourceName -and $_.Scope -eq $Scope } |
            Select-Object -ExpandProperty PackageIdentifier -Unique
    )
    if ($desiredIds.Count -eq 0) { return $true }

    $installedIds = @(Get-WingetInstalledPackageIds -Scope $Scope -SourceName $SourceName | Sort-Object -Unique)
    $missingIds = @($desiredIds | Where-Object { $_ -notin $installedIds })
    if ($missingIds.Count -gt 0) {
        Write-Warning "Skipping WinGet cleanup because these requested $Scope packages from $SourceName are not installed: $($missingIds -join ', ')"
        return $false
    }
    return $true
}

function Resolve-WingetManifestDependencyIds {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$PackageIdentifier,
        [Parameter(Mandatory = $true)]
        [ValidateSet("user", "machine")]
        [string]$Scope,
        [string]$SourceName = "winget"
    )

    $visited = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $queue = [Collections.Generic.Queue[string]]::new()
    foreach ($identifier in $PackageIdentifier) { $queue.Enqueue($identifier) }

    while ($queue.Count -gt 0) {
        $current = $queue.Dequeue()
        if (-not $visited.Add($current)) { continue }

        foreach ($dependency in @(Get-WingetPackageDependencyIds -PackageIdentifier $current -Scope $Scope -SourceName $SourceName)) {
            if (-not $visited.Contains($dependency)) {
                $dependency
                $queue.Enqueue($dependency)
            }
        }
    }
}

function Invoke-WingetManifestCleanup {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Path,
        [ValidateSet("user", "machine")]
        [string]$Scope = "machine"
    )

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { return }

    $managedEntries = @(
        Get-WingetManifestPackageEntries -Path $Path |
            Where-Object { $_.Scope -eq $Scope }
    )
    if ($managedEntries.Count -eq 0) {
        Write-Host "WinGet cleanup: no $Scope-scoped manifest entries to reconcile." -ForegroundColor Green
        return
    }

    $unmanagedPackages = @()
    foreach ($sourceName in @($managedEntries | Select-Object -ExpandProperty SourceName -Unique)) {
        $sourceEntries = @($managedEntries | Where-Object { $_.SourceName -eq $sourceName })
        $sourcePaths = @($Path)
        if (-not (Test-WingetManifestPackagesInstalled -Path $sourcePaths -Scope $Scope -SourceName $sourceName)) {
            return
        }

        $desiredIds = @($sourceEntries | Select-Object -ExpandProperty PackageIdentifier -Unique)
        $dependencyIds = @()
        try {
            $dependencyIds = @(Resolve-WingetManifestDependencyIds -PackageIdentifier $desiredIds -Scope $Scope -SourceName $sourceName)
        } catch {
            Write-Warning "Skipping WinGet cleanup because dependency resolution failed for $sourceName`: $($_.Exception.Message)"
            return
        }
        $installedIds = @(Get-WingetInstalledPackageIds -Scope $Scope -SourceName $sourceName | Sort-Object -Unique)
        $protectedIds = @($desiredIds + $dependencyIds | Sort-Object -Unique)
        foreach ($packageIdentifier in @($installedIds | Where-Object { $_ -notin $protectedIds })) {
            $unmanagedPackages += [PSCustomObject]@{
                SourceName        = $sourceName
                PackageIdentifier = $packageIdentifier
            }
        }
    }

    if ($unmanagedPackages.Count -eq 0) {
        Write-Host "WinGet cleanup: no unmanaged $Scope packages found." -ForegroundColor Green
        return
    }

    Write-Host "The following $Scope-scoped WinGet packages are not in the active manifests:" -ForegroundColor Yellow
    $unmanagedPackages | ForEach-Object { Write-Host "  [$($_.SourceName)] $($_.PackageIdentifier)" }

    $decision = $global:RAZORDOT_WINGET_CLEANUP_DECISION
    if ([string]::IsNullOrWhiteSpace($decision)) {
        $decision = $env:RAZORDOT_WINGET_CLEANUP
    }
    if ([string]::IsNullOrWhiteSpace($decision)) {
        if ($Host.UI -and $Host.UI.RawUI) {
            $decision = Read-Host "Uninstall these packages now? (y/n)"
        } else {
            Write-Host "Non-interactive session; leaving unmanaged WinGet packages installed." -ForegroundColor Yellow
            return
        }
    }
    $global:RAZORDOT_WINGET_CLEANUP_DECISION = $decision
    if ($decision -notmatch "^(1|y|yes)$") {
        Write-Host "Keeping unmanaged WinGet packages." -ForegroundColor Yellow
        return
    }

    foreach ($package in $unmanagedPackages) {
        Write-Host "Uninstalling package: $($package.PackageIdentifier) [$($package.SourceName)]" -ForegroundColor Cyan
        & winget uninstall --id $package.PackageIdentifier --exact --source $package.SourceName --scope $Scope --interactive
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not uninstall $($package.PackageIdentifier) (exit code $LASTEXITCODE)."
        }
    }
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
