# Load extensions from this repository in lexical order.
for preferences_extension in "$preferences_directory"/config.d/*.sh; do
  [ -f "$preferences_extension" ] || continue
  . "$preferences_extension"
done
unset preferences_extension preferences_directory
