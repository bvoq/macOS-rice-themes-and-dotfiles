# Starship PowerShell profile component; equivalent to starship/.zshrc.d/40_ishell_setup.zsh.
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)

    # Enable-TransientPrompt is provided by windows/profile.ps1 when the
    # repository profile is loaded. Keep the component safe when run alone.
    if (Get-Command Enable-TransientPrompt -ErrorAction SilentlyContinue) {
        Enable-TransientPrompt
    }
}