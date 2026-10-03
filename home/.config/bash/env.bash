# Interactive Bash preferences from env.zsh and bin_path.zsh.
export HISTSIZE=1000
export HISTIGNORE='&:ls:bg:fg:exit:history:e:prev:prev *:ll'
export EDITOR=vi
export VISUAL=vi
# Bash keeps per-session history without reading other shells on each prompt.
# Retain Omarchy's histappend so sessions append their history when they exit.

# Add a directory once; prepend user scripts so they override packaged commands.
preferences_path() {
  local directory=$1 placement=${2:-append}
  case ":$PATH:" in
    *":$directory:"*) return 0 ;;
  esac
  if [[ $placement == prepend ]]; then
    export PATH="$directory${PATH:+:$PATH}"
  else
    export PATH="${PATH:+$PATH:}$directory"
  fi
}
preferences_path "$HOME/.local/bin" prepend
