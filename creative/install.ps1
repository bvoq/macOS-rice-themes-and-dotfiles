function phase_1_machine_installs {
    if (-not (Verify-Elevated)) {
        Write-Host "Skipping Processing machine install: this PowerShell process is not elevated." -ForegroundColor Yellow
        return
    }

    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope machine -IgnoreVersions | Out-Null
}