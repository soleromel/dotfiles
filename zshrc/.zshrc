# Path to your oh-my-zsh installation.
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
setopt correct

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_dups hist_ignore_space
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
command -v kubectl >/dev/null && source <(kubectl completion zsh)
command -v aws_completer >/dev/null && complete -C aws_completer aws

# VI Mode!!! (beam cursor in insert, block in normal)
bindkey -v
bindkey jj vi-cmd-mode
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  else
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() { echo -ne '\e[5 q' }
zle -N zle-line-init
preexec() { echo -ne '\e[5 q' }

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# You may need to manually set your language environment
export LANG=C.UTF-8

export EDITOR=nvim

alias la=tree
alias cat=bat

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# GO
export GOPATH="$HOME/go"

# VIM
alias v='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim'
alias sv='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs sudo -e'

export PATH=$HOME/.local/bin:${GOPATH}/bin:$HOME/.cargo/bin:/opt/nvim-linux-x86_64/bin:$HOME/.opencode/bin:$PATH:/snap/bin

alias cl='clear'
alias lg=lazygit
alias help='tldr --list | fzf --preview "tldr {1} --color=always" --preview-window=right,70% | xargs tldr --color=always | less -R'

# Disable XON/XOFF so Ctrl-s doesn't freeze the terminal
stty -ixon

# Node
# nvm.sh takes ~600ms to load: put the default node on PATH right away
# and only load nvm itself the first time `nvm` is called
export NVM_DIR="$HOME/.nvm"
_nvm_node=("$NVM_DIR"/versions/node/v$(cat "$NVM_DIR/alias/default" 2>/dev/null)*(N/nOn))
(( $#_nvm_node )) || _nvm_node=("$NVM_DIR"/versions/node/v*(N/nOn))
(( $#_nvm_node )) && export PATH="$_nvm_node[1]/bin:$PATH"
unset _nvm_node
nvm() {
  unfunction nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

# K8S
export KUBECONFIG=~/.kube/config
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kl="kubectl logs"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kc="kubectx"
alias kns="kubens"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kcns='kubectl config set-context --current --namespace'
alias podname=''

# HTTP requests with xh!
alias http="xh"

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

### FZF ###
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Nix!
export NIX_CONF_DIR=$HOME/.config/nix

function ranger {
	local IFS=$'\t\n'
	local tempfile="$(mktemp -t tmp.XXXXXX)"
	local ranger_cmd=(
		command
		ranger
		--cmd="map Q chain shell echo %d > "$tempfile"; quitall"
	)

	${ranger_cmd[@]} "$@"
	if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
		cd -- "$(cat "$tempfile")" || return
	fi
	command rm -f -- "$tempfile" 2>/dev/null
}
alias rr='ranger'

# navigation
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
# Clipboard: Windows on WSL, Wayland or X11 on native Linux
clip() {
  if command -v clip.exe >/dev/null; then clip.exe
  elif [[ -n $WAYLAND_DISPLAY ]]; then wl-copy
  else xclip -selection clipboard
  fi
}
fcp() { echo "$(find . -type f -not -path '*/.*' | fzf)" | clip }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

 # Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	 . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

export XDG_CONFIG_HOME="$HOME/.config"

eval "$(zoxide init zsh)"
[ -f "$HOME/.atuin/bin/env" ] && . "$HOME/.atuin/bin/env"
# Keep Claude Code's shell commands out of the atuin history
[[ -z $CLAUDECODE ]] && eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
eval "$(pay-respects zsh --alias --nocnf)"

# Ghost suggestion on empty prompt (next command / typo fix)
source "${${(%):-%N}:A:h}/predict.zsh"
