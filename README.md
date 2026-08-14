# vim-configuration

Personal vim and terminal configuration.

```text
.vimrc            → ~/.vimrc
ghostty/config    → ~/.config/ghostty/config
```

Vim runtime lives at `/usr/share/vim/vim90`; colorschemes go in `~/.vim/colors`.

## Ghostty

Terminal is [Ghostty](https://ghostty.org). Font is Monaco with Hangul
codepoints remapped to D2Coding, so Korean stays exactly double-width and
box-drawing characters line up.

```sh
brew install --cask ghostty font-d2coding
cp ghostty/config ~/.config/ghostty/config
```

Reload a running Ghostty with `Cmd + Shift + ,`.

Useful commands:

```sh
ghostty +list-themes       # 463 built-in themes, with live preview
ghostty +list-fonts        # monospace fonts Ghostty can see
ghostty +validate-config
```

The `ghostty` binary lives inside the app bundle
(`/Applications/Ghostty.app/Contents/MacOS/ghostty`) and is not on `PATH` by
default.

## History

Earlier revisions of this repo held a tmux + iTerm2 setup for running many
Claude Code agents: a `tmux` wrapper that forced iTerm2 control mode (`-CC`),
an `agents` entry point, and `claude-snapshot` / `claude-restore` with a
LaunchAgent that recorded running sessions every five minutes so a reboot
could be undone.

That stack was dropped in favour of Ghostty plus
[cmux](https://github.com/manaflow-ai/cmux), which tracks agent sessions
through hooks rather than by inspecting processes. The tmux and iTerm2 files
are still in git history if a Linux box ever needs them:

```sh
git log --oneline -- tmux/ zsh/ bin/ launchd/ iterm2/
git show d6d623e:tmux/tmux.conf
```
