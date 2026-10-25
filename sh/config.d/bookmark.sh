# Session-local directory bookmarks: s work; work; work -p.
bookmark() {
  local OPTIND=1 OPTARG option label='' directory="$PWD" print=false quoted
  while getopts ':l:d:p' option; do
    case "$option" in
      l) label=$OPTARG ;;
      d) directory=$OPTARG ;;
      p) print=true ;;
      *) printf 'Usage: bookmark [-l label] [-d directory] [-p]\n' >&2; return 2 ;;
    esac
  done
  if $print; then
    printf '%s\n' "$directory"
  elif [[ -n $label ]]; then
    [[ $label =~ ^[a-zA-Z_][a-zA-Z0-9_-]*$ ]] || { printf 'Invalid bookmark label: %s\n' "$label" >&2; return 2; }
    printf -v quoted '%q' "$directory"
    alias "$label=bookmark -d $quoted"
  else
    builtin cd -- "$directory"
  fi
}

s() {
  [[ $# == 1 ]] || { printf 'Usage: s <bookmark-label>\n' >&2; return 2; }
  bookmark -l "$1" -d "$PWD"
}
