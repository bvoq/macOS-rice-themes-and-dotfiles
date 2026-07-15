# WinGet package manifests

These files are the Windows equivalent of the repository's multiple Homebrew
files. They use WinGet's packages JSON schema 2.0 and are grouped by target
scope:

- `machine/` contains packages imported with `Scope: machine`.
- `user/` contains packages imported with `Scope: user`.

The active lists are configured near the top of [`../install.ps1`](../install.ps1).
The `install_wingetfile` command imports each selected file and copies it into a
run-specific temporary accumulator. Duplicate packages are still harmless because
WinGet recognizes package identifiers during each import.
Feature-specific Windows setup lives beside the corresponding cross-platform
folder, for example [`starship/install.ps1`](../../starship/install.ps1),
[`git/install.ps1`](../../git/install.ps1), [`vim/install.ps1`](../../vim/install.ps1),
and [`vscode/install.ps1`](../../vscode/install.ps1). Each feature can also
provide a `profile.ps1`; those fragments are installed into the user's
PowerShell `profiles.d/` directory.

The `Scope` property is part of the schema 2.0 format. A package whose selected
installer does not support that scope will be reported by WinGet as unavailable;
the orchestrator does not silently fall back to the other scope.

## Cleanup

After phase 2, cleanup is opt-in and is similar to
`brew bundle cleanup`:

```powershell
$env:RAZORDOT_WINGET_CLEANUP = "1"
. .\razordot.ps1
```

Leave the variable unset to receive a prompt, or set it to `0` to keep all
unmanaged packages. Cleanup considers only packages from sources represented in
the selected manifests and never removes applications from an unrepresented
source. Cleanup is also skipped when using `razordot.ps1 --install <folder>`,
because a single folder is not the complete desired package set.

WinGet automatically installs package dependencies, but the export/import JSON
format does not provide a portable dependency graph. Before cleanup, the
accumulated manifests are used to query WinGet metadata and protect transitive
dependencies. Machine cleanup is skipped when the current PowerShell process is
not elevated. If dependency metadata cannot be read, cleanup fails closed and
leaves packages installed. Review the preview before enabling cleanup.
