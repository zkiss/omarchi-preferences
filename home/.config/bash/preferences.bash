# Loaded after Omarchy's Bash defaults so personal definitions take precedence.
source "$HOME/.config/bash/env.bash"
# Machine-specific commands/variables can be kept outside the repository.
[[ ! -r $HOME/.config/bash/local.bash ]] || source "$HOME/.config/bash/local.bash"
source "$HOME/.config/bash/tools.bash"
source "$HOME/.config/bash/aliases.bash"
source "$HOME/.config/bash/functions.bash"
