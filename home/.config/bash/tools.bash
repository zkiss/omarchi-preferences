# Initialise existing tools only; no installation or downloading at shell startup.
if [[ -x /home/linuxbrew/.linuxbrew/bin/brew && ${HOMEBREW_PREFIX:-} != /home/linuxbrew/.linuxbrew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"
if [[ -s $SDKMAN_DIR/bin/sdkman-init.sh ]] && ! declare -F sdk >/dev/null; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# Oh My Zsh previously provided nvm; load an existing installation for codex.
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ -s $NVM_DIR/nvm.sh ]] && ! declare -F nvm >/dev/null; then
  source "$NVM_DIR/nvm.sh"
fi

# GOPATH can contain several colon-separated workspaces.
if [[ -n ${GOPATH:-} ]]; then
  IFS=: read -r -a _preferences_go_paths <<< "$GOPATH"
  for _preferences_go_path in "${_preferences_go_paths[@]}"; do
    [[ -z $_preferences_go_path ]] || preferences_path "$_preferences_go_path/bin"
  done
  unset _preferences_go_paths _preferences_go_path
fi
