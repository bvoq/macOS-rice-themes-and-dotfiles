# Windows counterpart to vscode/install.zsh.

function phase_3_dotfiles {
    $settingsDir = Join-Path $env:APPDATA "Code/User"
    New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot ".vscode-settings.json") `
        -Destination (Join-Path $settingsDir "settings.json") -Force

    link_file (Join-Path $PSScriptRoot "profile.ps1") `
        (Join-Path $profileFragmentsDir "profile_vscode.ps1")
}

function phase_4_post_dotfiles {
    # Refresh the current session after a phase-1 installation; the profile
    # fragment also makes these paths available to future PowerShell sessions.
    . (Join-Path $PSScriptRoot "profile.ps1")
    $codeCommand = Get-Command code -ErrorAction SilentlyContinue
    if (-not $codeCommand) {
        Write-Warning "VS Code is not available; skipping VS Code extension installation."
        return
    }

    $extensions = @(
        "aaron-bond.better-comments"
        "GitHub.copilot"
        "johnpapa.vscode-peacock"
        "usernamehw.errorlens"
        "eamodio.gitlens"
        "PKief.material-icon-theme"
        "Ho-Wan.setting-toggle"
        "ms-vscode.PowerShell"
        "DavidAnson.vscode-markdownlint"
        "redhat.vscode-yaml"
        "Dart-Code.dart-code"
        "Dart-Code.flutter"
        "gmlewis-vscode.flutter-stylizer"
    )

    foreach ($extension in $extensions) {
        Write-Host "Installing VS Code extension: $extension" -ForegroundColor Cyan
        & code --install-extension $extension
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not install VS Code extension $extension (exit code $LASTEXITCODE)."
        }
    }
}
