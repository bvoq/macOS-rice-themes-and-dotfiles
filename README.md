# dotfiles :: unodot author's example
Here are my dotfiles. They also serve as the main example of the unodot-file manager.

Here you can get a good grasps of the 5 install phases:

| Phase | Package hook | What it is for |
| --- | --- | --- |
| 1 | `phase_1_admin_installs` | Admin-privileged installs: Homebrew bundles, taps, casks, and system-level prerequisites. Skipped when the user is not an admin. |
| 2 | `phase_2_user_installs` | User-level installs that do not require dotfiles yet: cloned tools, per-user package managers, and curl-based installers. |
| 3 | `phase_3_dotfiles` | Dotfile linking via `link_dotfile`, including package-owned config files and shell fragments. |
| 4 | `phase_4_post_dotfiles` | User-level setup that requires dotfiles to already be linked: plugin installs, sync commands, and tool initialization. |
| 5 | `phase_5_system_changes` | Heavy system changes that require admin privileges and may require a restart, such as macOS defaults or system-wide configuration. |

Further, you can see the numerical ordering in action.
For example, my .zshrc.d/ files are ordered numerically by the following phases:

00_safe_config.zsh
  aliases, functions, helper sources, variables safe to define even in limited/dumb contexts

10_guard.zsh
  return early for non-interactive/dumb/non-tty cases; terminal repair like stty sane

20_ishell_config.zsh
  interactive shell behavior: setopt, bindkey basics, history options

30_pre_compinit_setup.zsh
  fpath/FPATH additions, completion zstyles, plugins that only provide completion sources

40_compinit.zsh
  autoload -Uz compinit
  compinit

50_ishell_setup.zsh
  tool initialization after shell/completion base is ready:
  fzf, zoxide, direnv, starship, compdef, current antidote load

You can define your own naming convention, all unodot does is link them and source them in order for you.

To get started with your own unodot powered repository, just copy the self-updating unodot.zsh / unodot.ps to your repository and create your own folders.

If you like to load different folders for different machines, just copy them and enable/disable different folders.

Further, some of these folders can be used directly by you.

If you are on macOS/unix check out `unodot.zsh`

If you are on Windows check out `bootstrap.ps1`

Install using:
```
zsh unodot.zsh
```

![Alt text](xcode/xcodetheme.png?raw=true "XCode Theme")
![Alt text](terminal/terminaltheme.png?raw=true "Terminal Theme")
