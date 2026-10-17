#!/usr/bin/env bash
# Check that everything the dotfiles rely on is installed. Installs nothing.
# Usage: ./check-requirements.sh

set -u

red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' dim=$'\e[2m' reset=$'\e[0m'
missing_apt=() missing_other=() missing_count=0

ok()   { printf '  %s✓%s %s\n' "$green" "$reset" "$1"; }
warn() { printf '  %s!%s %s %s%s%s\n' "$yellow" "$reset" "$1" "$dim" "$2" "$reset"; }
ko()   { printf '  %s✗%s %s %s%s%s\n' "$red" "$reset" "$1" "$dim" "$2" "$reset"; missing_count=$((missing_count + 1)); }

# check <command> <apt package or "-"> [install hint for non-apt tools]
check() {
  local cmd=$1 pkg=$2 hint=${3:-}
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd"
  elif [[ $pkg != - ]]; then
    ko "$cmd" "(apt: $pkg)"; missing_apt+=("$pkg")
  else
    ko "$cmd" "($hint)"; missing_other+=("$cmd: $hint")
  fi
}

# Debian/Ubuntu ship bat and fd as batcat and fdfind
check_renamed() {
  local cmd=$1 debian_cmd=$2 pkg=$3
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd"
  elif command -v "$debian_cmd" >/dev/null 2>&1; then
    ko "$cmd" "(installed as $debian_cmd: ln -s \"\$(command -v $debian_cmd)\" ~/.local/bin/$cmd)"
  else
    ko "$cmd" "(apt: $pkg, then symlink $debian_cmd to ~/.local/bin/$cmd)"; missing_apt+=("$pkg")
  fi
}

echo "Core"
check zsh zsh
check git git
check stow stow
check nvim neovim
check tmux tmux

echo "Shell tools"
check fzf fzf
check_renamed fd fdfind fd-find
check_renamed bat batcat bat
check eza eza
check zoxide zoxide
check direnv direnv
check tree tree
check starship - "curl -sS https://starship.rs/install.sh | sh"
check atuin - "curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh"
check pay-respects - "binary from https://github.com/iffse/pay-respects/releases (skip the request-ai module)"
check tldr - "tealdeer binary from https://github.com/tealdeer-rs/tealdeer/releases (apt version is broken)"
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  ok "zsh-autosuggestions"
else
  ko "zsh-autosuggestions" "(apt: zsh-autosuggestions)"; missing_apt+=(zsh-autosuggestions)
fi

echo "Dev tools"
check lazygit - "binary from https://github.com/jesseduffield/lazygit/releases (not in apt before Ubuntu 25.04)"
check xh - "cargo install xh, or binary from https://github.com/ducaale/xh/releases"
check ranger ranger
check docker - "https://docs.docker.com/engine/install/ (or Docker Desktop on WSL)"
if [[ -s ${NVM_DIR:-$HOME/.nvm}/nvm.sh ]]; then ok "nvm"; else warn "nvm" "(optional: https://github.com/nvm-sh/nvm)"; fi

echo "Kubernetes (optional)"
for cmd in kubectl kubectx kubens; do
  if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd"; else warn "$cmd" "(optional)"; fi
done

echo "Clipboard (used by fcp)"
if [[ -n ${WSL_DISTRO_NAME:-} ]]; then
  check clip.exe - "should come with WSL: check Windows interop"
elif [[ -n ${WAYLAND_DISPLAY:-} ]]; then
  check wl-copy wl-clipboard
else
  check xclip xclip
fi

echo "Tmux plugins"
if [[ -d $HOME/.config/tmux/plugins/tpm ]]; then
  ok "tpm"
else
  ko "tpm" "(git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm, then prefix + I in tmux)"
fi

echo
if (( missing_count == 0 )); then
  printf '%sAll requirements are installed.%s\n' "$green" "$reset"
  exit 0
fi

printf '%s%d missing.%s\n' "$red" "$missing_count" "$reset"
if (( ${#missing_apt[@]} )); then
  echo "Install with apt:"
  echo "  sudo apt install ${missing_apt[*]}"
fi
if (( ${#missing_other[@]} )); then
  echo "Install manually:"
  printf '  %s\n' "${missing_other[@]}"
fi
exit 1
