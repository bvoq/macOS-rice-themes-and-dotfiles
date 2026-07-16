function open($name) { start $name }

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

function Edit-Profile { Invoke-Expression "$(if($env:EDITOR -ne $null)  {$env:EDITOR } else { 'notepad' }) $profile" }
