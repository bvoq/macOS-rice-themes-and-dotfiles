# dotfiles :: razordot author's example
Here are my dotfiles. They also serve as the main example of the razordot-file manager.

Here you can get a good grasps of the 5 install phases:

| Phase | Package hook | Run with non-admin user | What it is for |
| --- | --- | --- | --- |
| 1 | `phase_1_machine_installs` | ❌ | Machine-scoped installs such as Homebrew bundles/casks, AppStore apps, WinGet packages, and other system-level apps. |
| 2 | `phase_2_user_installs` | ✅ | User-level installs that do not require dotfiles yet: cloned tools, per-user package managers, and curl-based installers. |
| 3 | `phase_3_dotfiles` | ✅ | Dotfile linking via `link_dotfile`, including package-owned config files and shell fragments. |
| 4 | `phase_4_post_dotfiles` | ✅ | User-level setup that requires dotfiles to already be linked: plugin installs, sync commands, and tool initialization. |
| 5 | `phase_5_system_changes` | ❌ | Heavy system changes that require admin privileges and may require a restart, such as macOS defaults or system-wide configuration. |

Further, you can see the numerical ordering in action.
For example, my .zshrc.d/ files are ordered numerically by the following phases:

00_safe_config.zsh
  aliases, functions, helper sources, variables safe to define even in limited/dumb contexts

10_guard.zsh
  return early for non-interactive/dumb/non-tty cases; terminal repair like stty sane

20_pre_compinit.zsh
  interactive shell behavior (setopt, bindkey, history) plus pre-compinit setup:
  fpath/FPATH additions, completion zstyles, plugins that only provide completion sources

30_compinit.zsh
  autoload -Uz compinit
  compinit

40_ishell_setup.zsh
  tool initialization after shell/completion base is ready:
  fzf, zoxide, direnv, starship, compdef, current antidote load

Package folders provide their own fragments under the same names (e.g. git/.zshrc.d/00_safe_config.zsh),
linked into ~/.zshrc.d/ with the folder name appended (e.g. 00_safe_config_git.zsh) so they sort by phase.

You can define your own naming convention, all razordot does is link them and source them in order for you.

To get started with your own razordot powered repository, just copy the self-updating razordot.zsh / razordot.ps1 to your repository and create your own folders.

If you like to load different folders for different machines, just copy them and enable/disable different folders.

Further, some of these folders can be used directly by you.

If you are on macOS/unix check out `razordot.zsh`

If you are on Windows check out `razordot.ps1`

Install using:
```
zsh razordot.zsh
```

On Windows, run `razordot.ps1`. It dispatches the enabled feature folders in
phase order, sourcing each folder's `install.ps1` and calling the corresponding
phase function. Run it from an elevated PowerShell session when you want
machine-scoped installs. Windows-specific implementation remains under
`windows/`, just like any other feature folder. The active WinGet package
manifests and optional cleanup behavior are documented in
`windows/winget/README.md`.

The Windows feature folders mirror the macOS layout: `git/`, `vim/`, `vscode/`,
and `starship/` each own an `install.ps1` and a `profile.ps1`. Their profile
fragments are linked into the current user's PowerShell `profiles.d/` directory
and loaded by `windows/profile.ps1`.

Like `razordot.zsh`, the Windows orchestrator also accepts remote install-folder
entries containing a slash, such as `razordot/example`. By default these are
shallow-cloned into gitignored folders and pinned to the commit recorded beside
the ignore entry in `.gitignore`. Set `$RAZORDOT_DOWNLOAD_TYPE` to
`"GITSUBMODULE"` to acquire them as recursive Git submodules instead. When the
mode changes, or a managed remote folder is removed from `$installFolders`, the
corresponding managed download or submodule is removed on the next full run.
Use `--install <folder>` for a single-folder run when you do not want the full
managed-folder cleanup.

![Alt text](xcode/xcodetheme.png?raw=true "XCode Theme")
![Alt text](terminal/terminaltheme.png?raw=true "Terminal Theme")
