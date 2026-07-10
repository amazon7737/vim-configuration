# vim-configuration

```text
.vimrc
.vim/colors

vim location
usr/share/vim/vim90
```

## tmux helper

- Guide: [`tmuxh.md`](tmuxh.md)
- `tmuxh` prints current tmux sessions and a quick command guide.

## iTerm2 theme

- Theme file: `iterm2/Warm-Charcoal.itermcolors`

Apply in iTerm2:

1. Open iTerm2 Settings: `Cmd + ,`
2. Go to **Profiles → Colors**
3. Click **Color Presets… → Import…**
4. Select `iterm2/Warm-Charcoal.itermcolors`
5. Choose **Color Presets… → Warm-Charcoal**

Palette:

```text
Background:           #151515
Foreground:           #D8D5CF
Bold / Accent:        #CDA66B
Selection Background: #303030
Selection Foreground: #F2EEE6
Cursor:               #F2E8D5
Cursor Text:          #151515
```

## iTerm2 full settings backup

- Settings file: `iterm2/com.googlecode.iterm2.plist` (profiles, key bindings, colors — machine-specific `NoSync*`/window-position keys stripped)

Restore on a new Mac — option A (one-shot import):

1. Quit iTerm2 completely (`Cmd + Q`)
2. `defaults import com.googlecode.iterm2 iterm2/com.googlecode.iterm2.plist`
3. Launch iTerm2

Restore on a new Mac — option B (keep synced with this repo):

1. Clone this repo
2. iTerm2 Settings → **General → Settings** (or **Preferences**)
3. Check **Load preferences from a custom folder or URL** and select the repo's `iterm2/` folder
4. Restart iTerm2

To update the backup later:

```sh
defaults export com.googlecode.iterm2 - | plutil -convert xml1 -o iterm2/com.googlecode.iterm2.plist -
```

(then review the diff for anything private before pushing — this repo is public)
