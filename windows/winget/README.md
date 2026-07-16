# WinGet package manifests

Each feature folder owns the WinGet manifest for its packages, just as each
macOS feature folder owns its `Brewfile`. For example,
[`starship/winget_package.json`](../../starship/winget_package.json) declares
Starship and is imported by [`starship/install.ps1`](../../starship/install.ps1)
through the shared `install_wingetfile` command.

The Windows-specific packages remain in [`packages.json`](packages.json). Other
feature folders can add their own `winget_package.json` later without changing
the shared installer. The root [`razordot.ps1`](../../razordot.ps1) sources
[`install.ps1`](install.ps1) once before feature installers run, so every
feature can call `install_wingetfile` directly.

`install_wingetfile` can optionally filter a manifest by `-OnlyScope` before
importing it because `winget import` has no `--scope` command-line option. When
`-OnlyScope` is omitted, every package in the manifest is imported. Each
feature's `install.ps1` decides whether a phase should pass `-OnlyScope
machine`, `-OnlyScope user`, or no filter. The `Scope` property remains
controlled by each package entry, and there is no silent fallback to another
scope when an installer does not support the requested one.

Every imported, filtered manifest is copied into a run-specific temporary
accumulator. Cleanup runs once after every folder has completed phase 2, so the
desired package set is the union of all enabled feature manifests.

Feature-specific Windows setup lives beside the corresponding cross-platform
folder, for example [`starship/install.ps1`](../../starship/install.ps1),
[`git/install.ps1`](../../git/install.ps1), [`vim/install.ps1`](../../vim/install.ps1),
and [`vscode/install.ps1`](../../vscode/install.ps1). Each feature can also
provide a `profile.ps1`; those fragments are installed into the user's
PowerShell `profiles.d/` directory.

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
