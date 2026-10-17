# Dotfiles

Fork of [omerxx/dotfiles](https://github.com/omerxx/dotfiles), adapted for Ubuntu (WSL2 and native Linux).

## Fresh install

### 1. Clone

```bash
sudo apt install zsh git stow
git clone https://github.com/soleromel/dotfiles ~/apps/dotfiles
cd ~/apps/dotfiles
```

Keep the `~/apps/dotfiles` path: the tmux config refers to it.

### 2. Check requirements

```bash
./check-requirements.sh
```

It lists every tool the configs rely on, and prints the `apt` command and the manual install steps for whatever is missing. It installs nothing. Run it again until everything is green.

On Debian/Ubuntu, `bat` and `fd` are installed as `batcat` and `fdfind`: the script prints the `ln -s` to run so the usual names work.

### 3. Back up your current configs

`stow` refuses to overwrite existing files, but take a backup anyway:

```bash
tar czf ~/dotfiles-backup-$(date +%F).tgz -C ~ .zshrc .zshenv .tmux.conf .config 2>/dev/null
```

### 4. Link the configs

`stow` links each top-level directory into `~/.config` (see `.stowrc`). Directories you want to keep your own version of, like `nvim`, are listed there as `--ignore`.

```bash
stow -n -v .   # dry run: shows what would be linked and any conflict
stow -v .
```

If a conflict shows up, move your own file out of the way first or add the directory to `.stowrc`.

### 5. Zsh

The zsh config is not handled by stow, link it by hand and make zsh the default shell:

```bash
ln -s ~/apps/dotfiles/zshrc/.zshrc ~/.zshrc
chsh -s "$(command -v zsh)"
```

Per-machine settings (tokens, project paths...) go in `~/.zshrc.local`, which is sourced last and never versioned.

### 6. Tmux plugins

Start tmux and press `prefix` + `I` to install the plugins (prefix is `Ctrl-s`).

## Layout

| Path | Content |
| --- | --- |
| `zshrc/.zshrc` | Main zsh config, works on any Linux |
| `zshrc/wsl.zsh` | WSL-only bits (Windows clipboard, `open`), loaded when `$WSL_DISTRO_NAME` is set |
| `zshrc/predict.zsh` | Ghost suggestion on an empty prompt |
| `check-requirements.sh` | Checks installed tools |
| `.stowrc` | Stow target (`~/.config`) and ignored directories |

## Shell features

- **Ghost suggestion**: after a successful command, the command you usually run next shows up greyed out; after a failed one, the suggested fix. Accept with `Ctrl-e`, ignore by typing anything else.
- `f`: pick a fix for the last failed command ([pay-respects](https://github.com/iffse/pay-respects)).
- `Ctrl-x Ctrl-x`: fix the command line being typed.
- `help`: browse [tldr](https://tldr.sh) pages with fzf (French first, English fallback).
- `z` / `zi`: jump to a directory ([zoxide](https://github.com/ajeetdsouza/zoxide)).
- `Ctrl-r`: search history ([atuin](https://atuin.sh)).
- `fcp`: pick a file with fzf and copy its path to the clipboard.
- `v`: pick a file with fzf and open it in nvim.

## Updates from upstream

```bash
git fetch upstream
git log --oneline master..upstream/master   # see what changed
```

Pushing to `upstream` is disabled, so changes only ever go to this fork.
