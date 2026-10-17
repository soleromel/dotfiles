# Warp-like ghost suggestion on an empty prompt:
# - after a failed command: best fix from pay-respects (offline rules only)
# - after a successful one: the command you most often run next (atuin history)
# Accept with ^e, ignore by typing anything else. Enter alone never runs it.

autoload -Uz add-zsh-hook
typeset -g _PREDICT_SUGGESTION _PREDICT_LAST _PREDICT_EXE_PATH
typeset -ga _PREDICT_EXE

_predict_next_command() {
  atuin history list --cmd-only 2>/dev/null | tail -n 5000 |
    LAST="$1" awk '
      prev == ENVIRON["LAST"] && $0 != ENVIRON["LAST"] { count[$0]++ }
      { prev = $0 }
      END { for (c in count) if (count[c] >= 2 && count[c] > best) { best = count[c]; pick = c }; print pick }'
}

# Skip Windows executables from the WSL PATH: thousands of them make typo matching slow.
# Scanning PATH costs ~120ms, so cache it until PATH changes (must run outside a subshell).
_predict_refresh_exe() {
  [[ $_PREDICT_EXE_PATH == $PATH ]] && return
  local d
  _PREDICT_EXE=()
  for d in ${path:#/mnt/*}; do _PREDICT_EXE+=($d/*(N-*:t)); done
  _PREDICT_EXE_PATH=$PATH
}

_predict_fix() {
  command -v pay-respects >/dev/null || return
  local msg=" "   # non-empty: prevents pay-respects from re-running the failed command
  (( $2 == 127 )) && msg="zsh: command not found: ${1%% *}"
  _PR_SHELL=zsh _PR_LAST_COMMAND="$1" _PR_ERROR_MSG="$msg" \
  _PR_EXECUTABLES="$_PREDICT_EXE ${(k)aliases} ${(k)functions}" \
  _PR_ALIAS="$(alias)" _PR_MODE=echo _PR_NO_DESPERATE=1 _PR_NO_MULTIPLEXER=1 \
    timeout 0.3 pay-respects 2>/dev/null | head -n 1
}

_predict_preexec() { _PREDICT_LAST=$1 }

_predict_precmd() {
  local exit_code=$?
  _PREDICT_SUGGESTION=
  [[ -n $_PREDICT_LAST ]] || return   # Enter on an empty line: no suggestion
  local last=$_PREDICT_LAST
  _PREDICT_LAST=
  if (( exit_code == 0 )); then
    _PREDICT_SUGGESTION=$(_predict_next_command "$last")
  elif (( exit_code != 130 )); then  # 130 = Ctrl-C, not an error
    _predict_refresh_exe
    _PREDICT_SUGGESTION=$(_predict_fix "$last" $exit_code)
  fi
}

add-zsh-hook preexec _predict_preexec
precmd_functions=(_predict_precmd ${precmd_functions:#_predict_precmd})

# Chain onto the existing zle-line-init (vi cursor shape)
zle -A zle-line-init _predict_orig_line_init 2>/dev/null
_predict_line_init() {
  zle _predict_orig_line_init 2>/dev/null
  [[ -z $BUFFER && -n $_PREDICT_SUGGESTION ]] || return
  POSTDISPLAY=$_PREDICT_SUGGESTION
  _zsh_autosuggest_highlight_apply   # grey style + cleared by the plugin on next keystroke
}
zle -N zle-line-init _predict_line_init
