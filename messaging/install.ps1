function phase_2_user_installs {
    install_wingetfile -Path (Join-Path $PSScriptRoot "winget_package.json") `
        -OnlyScope user -IgnoreVersions | Out-Null
}