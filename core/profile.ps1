function open($name) { Start-Process $name }

function la { eza -lAF @args }

function which {
    param($name)

    $command = Get-Command $name -ErrorAction SilentlyContinue
    if (-not $command) {
        "${name}: command not found"
        return
    }

    $type = $command.CommandType
    if ($command -is [Management.Automation.FunctionInfo]) {
        "${type}: $($command.ScriptBlock.ToString())"
    } else {
        "${type}: $($command.Definition)"
    }

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

function Edit-Profile { Invoke-Expression "$(if($null -ne $env:EDITOR)  {$env:EDITOR } else { 'notepad' }) $profile" }
