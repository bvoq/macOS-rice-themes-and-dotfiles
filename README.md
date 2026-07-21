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

To get started with your own razordot powered repository, just copy the self-updating razordot.zsh / razordot.ps1 to your repository or clone this one, and create your own folders.

If you like to load different folders for different machines, you can have various razordot files without needing to duplicate folders, eg.:
`razordot_work_windows.ps1`, `razordot_private_windows.ps1`, `razordot_work_macos.zsh`, `razordot_private_macos.zsh`.

## Main zsh

Download and run main without Git, after this repository is renamed to `bvoq/dotfiles`:

```zsh
curl -fsSL https://github.com/bvoq/dotfiles/archive/refs/heads/main.tar.gz | tar -xz && cd dotfiles-main && zsh razordot.zsh
```

After the first run installed Git and you initialised your personal Git setup, you can attach that download to Git:

```zsh
git init -b main && git remote add origin git@github.com:bvoq/dotfiles.git && git fetch origin main && git reset --mixed origin/main && git branch --set-upstream-to=origin/main main
```

## Main PowerShell

Download and run main without Git, after this repository is renamed to `bvoq/dotfiles`:

```powershell
Invoke-WebRequest -Uri https://github.com/bvoq/dotfiles/archive/refs/heads/main.zip -OutFile dotfiles-main.zip; Expand-Archive -Path dotfiles-main.zip -DestinationPath . -Force; Set-Location dotfiles-main; Set-ExecutionPolicy -Scope Process Bypass -Force; .\razordot.ps1
```

After the first run installed Git and your personal Git setup, attach that download to Git:

```powershell
git init -b main; git remote add origin git@github.com:bvoq/dotfiles.git; git fetch origin main; git reset --mixed origin/main; git branch --set-upstream-to=origin/main main
```

## Develop

### zsh

Download and run develop without Git:

```zsh
curl -fsSL https://github.com/bvoq/dotfiles/archive/refs/heads/develop.tar.gz | tar -xz && cd dotfiles-develop && zsh razordot.zsh
```

After the first develop run installed Git and your personal Git setup, attach that download to Git:

```zsh
git init -b develop && git remote add origin git@github.com:bvoq/dotfiles.git && git fetch origin develop && git reset --mixed origin/develop && git branch --set-upstream-to=origin/develop develop
```

### PowerShell

Download and run develop without Git:

```powershell
Invoke-WebRequest -Uri https://github.com/bvoq/dotfiles/archive/refs/heads/develop.zip -OutFile dotfiles-develop.zip; Expand-Archive -Path dotfiles-develop.zip -DestinationPath . -Force; Set-Location dotfiles-develop; Set-ExecutionPolicy -Scope Process Bypass -Force; .\razordot.ps1
```

After the first develop run installed Git and your personal Git setup, attach that download to Git:

```powershell
git init -b develop; git remote add origin git@github.com:bvoq/dotfiles.git; git fetch origin develop; git reset --mixed origin/develop; git branch --set-upstream-to=origin/develop develop
```

Install using:

```zsh
zsh razordot.zsh
```

On Windows, run `razordot.ps1`. It dispatches the enabled feature folders in
phase order, sourcing each folder's `install.ps1` and calling the corresponding
phase function. Run it from an elevated PowerShell session when you want
machine-scoped installs. Windows-specific implementation remains under
`windows/`, just like any other feature folder. The shared WinGet helper is
acquired as the `razordot/winget` feature folder; its manifest import and
optional cleanup behavior are documented in that repository's `README.md`.

The Windows feature folders mirror the macOS layout: `git/`, `vim/`, `vscode/`,
and `starship/` each own an `install.ps1` and a `profile.ps1`. Their profile
fragments are linked into the current user's PowerShell `profiles.d/` directory
and loaded by `windows/profile.ps1`.

Like `razordot.zsh`, the Windows orchestrator also accepts remote install-folder
entries containing a slash, such as `razordot/example`. By default these are
downloaded into gitignored folders and pinned to the commit recorded beside the
ignore entry in `.gitignore`. The pin comment starts with the script filename,
such as `# razordot.zsh`, so several razordot entrypoints can share one
`.gitignore` without cleaning up each other's managed folders. Public GitHub
repositories are downloaded without requiring Git; Git is used only as a fallback
when the web download cannot access the repository, such as for private remotes.
When a managed remote folder is removed from that script's install folder list,
the corresponding managed download is removed on the next full run. Use
`--install <folder>` for a single-folder run when you do not want the full
managed-folder cleanup.

![Alt text](xcode/xcodetheme.png?raw=true "XCode Theme")
![Alt text](terminal/terminaltheme.png?raw=true "Terminal Theme")
