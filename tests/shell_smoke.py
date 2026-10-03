#!/usr/bin/env python3
"""Exercise the Bash port in an isolated home without installing applications."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]

with tempfile.TemporaryDirectory(prefix="omarchy-shell-test-") as directory:
    home = Path(directory)
    shutil.copytree(ROOT / "home", home, dirs_exist_ok=True)
    env = dict(os.environ, HOME=str(home), PATH="/usr/bin:/bin")
    # Make tool initialisation deterministic, even on hosts with Homebrew.
    env["HOMEBREW_PREFIX"] = "/home/linuxbrew/.linuxbrew"
    env["GOPATH"] = f"{home}/go workspace:{home}/other-go"
    env["SDKMAN_DIR"] = str(home / ".sdkman")
    env["NVM_DIR"] = str(home / ".nvm")

    def bash(code):
        result = subprocess.run(
            ["bash", "--noprofile", "--norc", "-c", code],
            env=env, capture_output=True, text=True,
        )
        assert result.returncode == 0, result.stdout + result.stderr
        return result.stdout

    load = 'source "$HOME/.config/bash/preferences.bash"; '
    bash(load + '''
        [[ $EDITOR == vi && $VISUAL == vi && $HISTSIZE == 1000 ]] || exit 1
        [[ $HISTIGNORE == *'prev *'* ]] || exit 1
        [[ $PATH == "$HOME/.local/bin:"* ]] || exit 1
        first_path=$PATH
        source "$HOME/.config/bash/preferences.bash"
        [[ $PATH == "$first_path" ]] || exit 1
        [[ $PATH == *"$HOME/go workspace/bin"* && $PATH == *"$HOME/other-go/bin"* ]] || exit 1
        [[ $(alias installed) == *'pacman -Qe'* ]] || exit 1
        [[ $(alias gu) == *'--gradle-version'* ]] || exit 1
    ''')

    bookmark = home / "a directory's name"
    bookmark.mkdir()
    bash(load + '''
        cd "$HOME/a directory's name"
        s work
        cd "$HOME"
        eval "${BASH_ALIASES[work]}"
        [[ $PWD == "$HOME/a directory's name" ]] || exit 1
        [[ $(eval "${BASH_ALIASES[work]} -p") == "$PWD" ]] || exit 1
        bookmark -l second -d "$HOME"
        eval "${BASH_ALIASES[second]}"
        [[ $PWD == "$HOME" ]] || exit 1
        ! bookmark -l 'bad label' -d "$HOME" || exit 1
    ''')

    executable = home / ".local/bin/codex"
    executable.write_text('#!/bin/sh\nprintf "fallback:%s\\n" "$1"\n')
    executable.chmod(0o755)
    assert bash(load + 'codex "argument with spaces"') == 'fallback:argument with spaces\n'
    (home / ".nvm").mkdir()
    (home / ".nvm/nvm.sh").write_text('nvm() { printf "%s\\n" "$@"; }\n')
    assert bash(load + 'codex "argument with spaces"') == 'exec\n24\ncodex\nargument with spaces\n'

    (home / ".config/bash/local.bash").write_text(
        'export IDEA_CMD="/path with spaces/idea"\nexport CURSOR_CMD="/cursor --no-sandbox"\n'
    )
    assert bash(load + '''
        fork() { printf '<%s>\\n' "$@"; }
        idea 'a project'
        cursor 'another project'
    ''') == '</path with spaces/idea>\n<a project>\n</cursor>\n<--no-sandbox>\n<another project>\n'

    script = home / "detached command with spaces"
    script.write_text('#!/bin/sh\nprintf "%s" "$1" > "$HOME/detached-output"\n')
    script.chmod(0o755)
    bash('"$HOME/.local/bin/fork" "$HOME/detached command with spaces" "quoted argument"')
    output = home / "detached-output"
    for _ in range(100):
        if output.exists() and output.read_text() == "quoted argument":
            break
        time.sleep(0.02)
    else:
        raise AssertionError("fork lost the executable path or argument")

    (home / "project/.idea").mkdir(parents=True)
    (home / "project/test.iml").touch()
    found = bash('cd "$HOME"; "$HOME/.local/bin/find_idea_files"').splitlines()
    assert './project/.idea' in found and './project/test.iml' in found
    bash('printf "" | "$HOME/.local/bin/and_delete"')
    bash('! "$HOME/.local/bin/keepalive" -u example.com -t invalid')

    # Record work_diff arguments instead of creating commits in a fixture repo.
    git = home / ".local/bin/git"
    git.write_text('''#!/bin/sh
case "$1" in
  rev-parse) printf 'feature/test\\n' ;;
  diff) printf '<%s>\\n' "$@" ;;
  *) exit 1 ;;
esac
''')
    git.chmod(0o755)
    bash(load + 'cd "$HOME"; work_diff "base with spaces"')
    assert (home / "work.diff").read_text() == '<diff>\n<base with spaces...feature/test>\n<-->\n'

print("PASS: environment, aliases, PATH idempotence, quoted bookmarks, Codex fallback/nvm, launcher arguments, detached execution, helper scripts")
