# Omarchy preferences

Personal system behaviour and shell preferences, deployed with one Bash script.
The starting configuration is based on an Omarchy 4.0.4 installation with Foot
and Bash. It uses Omarchy's existing defaults and personal override locations.

## Apply

On an Omarchy installation, clone this repository and run as your normal user:

```bash
git clone git@github.com:zkiss/omarchi-preferences.git omarchy-preferences
cd omarchy-preferences
./apply --dry-run --system
./apply --system
```

`./apply` deploys home-directory preferences. `--system` also installs the
logind drop-in under `/etc`, invoking sudo for privileged changes. `--dry-run`
prints planned changes without writing files or requesting sudo.

Every apply also installs and enables these Omarchy shell plugins:

| Plugin | Repository | Branch |
| --- | --- | --- |
| Automatic Night Light | `https://github.com/zkiss/omarchy-nightlight.git` | Repository default |
| Your OmaSwitch fork | `https://github.com/zkiss/omaswitch.git` | `fix/alt-release-commit` |

Plugin installation requires network access, Git, jq, and a running Omarchy shell
session. The OmaSwitch branch matches your existing Alt-release fix. The plugin
sources live in `plugins.manifest`; `-` selects the repository's default branch.
Installation uses `omarchy plugin add` and `omarchy plugin enable`, preserving
unrelated shell configuration.

An existing plugin from another source or branch is backed up in full before
replacement, including its Git history and local edits. Matching checkouts are
kept and enabled if necessary. Repeated application does not pull new commits;
update plugins explicitly with `omarchy plugin update <plugin-id>`.

Open a new terminal for the Bash and Foot changes. After applying desktop
preferences, validate the live Hyprland configuration:

```bash
hyprctl reload
hyprctl configerrors
```

Reboot after changing the logind drop-in. The installer does not restart logind
or other services during your session.

## Included preferences

| Preference | Source |
| --- | --- |
| Bash aliases and function modules | `home/.config/bash/` |
| Foot font, clipboard keys, and Shift/Alt+Shift+Return mappings | `home/.config/foot/foot.ini` |
| Short power-button press shuts down; long press opens the power menu | `home/.config/hypr/bindings.lua` |
| Optional OmaSwitch Alt+Tab bindings, enabled when its plugin manifest exists | `home/.config/hypr/bindings.lua` |
| Preserve a manually enabled keyboard backlight when waking | `home/.local/bin/omarchy-system-wake` |
| Leave power-button and lid handling to the desktop instead of logind | `system/etc/systemd/logind.conf.d/30-custom-keys.conf` |

The logind settings ignore lid events on battery and external power, including
docked operation. Edit the drop-in to match the behaviour you want on the target
machine. Firmware-controlled forced power-off on a very long button hold remains
independent of the desktop binding.

OmaSwitch is installed from your fork during apply. The Bash modules and six
helper scripts are ported from `zkiss/zsh` at commit
`ee120a64f1670e674b2b1d256c7be64db78122ad`.

## Shell preferences from zkiss/zsh

| Original module | Bash port |
| --- | --- |
| `aliases.zsh`, `gradle.zsh` | `aliases.bash`: disk/listing/history aliases and Gradle shortcuts; `installed` uses `pacman -Qe` |
| `env.zsh`, `bin_path.zsh` | `env.bash`: `EDITOR=vi`, `VISUAL=vi`, `HISTSIZE=1000`, Bash history exclusions, and `~/.local/bin` on PATH |
| `bookmark.zsh` | `functions.bash`: `bookmark` and `s`, with quoted directory paths |
| `codex.zsh` | `functions.bash`: use `nvm exec 24 codex` when nvm exists, otherwise the installed Codex command |
| `idea.zsh`, `cursor.zsh` | `functions.bash`: detached launchers when `IDEA_CMD` or `CURSOR_CMD` is set |
| `homebrew.zsh`, `sdkman.zsh`, `go.zsh` | `tools.bash`: initialise existing installations and append each Go workspace's `bin` directory once |
| `gitconfig.zsh` | `apply`: initialise a global excludes file only when unset and create the configured file if absent |
| `bin/*` | Executable scripts in `~/.local/bin`: `and_delete`, `find_idea_files`, `fork`, `keepalive`, `podman-api`, `work_diff` |

Bash history stays local to each running shell; Omarchy's append-on-exit behaviour
is retained. The old malformed Zsh `HISTORY_IGNORE` expression is translated to
Bash's colon-separated `HISTIGNORE`. These exports apply to Bash sessions and
their child processes, rather than the whole desktop session.

SDKMAN and nvm are sourced only when already installed. Node 24 must already be
available to nvm for the Codex wrapper to work. The port installs no applications.

For machine-specific launcher paths or environment variables, create
`~/.config/bash/local.bash`, which is loaded before tool integrations and functions:

```bash
export IDEA_CMD="$HOME/apps/idea/bin/idea.sh"
export CURSOR_CMD="$HOME/apps/cursor.AppImage"
export GOPATH="$HOME/go"
```

`IDEA_CMD` is an executable path. `CURSOR_CMD` accepts an executable path, including
spaces, or the old whitespace-separated command-and-flags form. That form does
not interpret shell quotes or operators. Paths and arguments are passed without
`eval`. Keep secrets and machine-local settings in `local.bash`; it is not deployed
or overwritten by apply.

Bookmarks are session-local, as in the original repository:

```bash
s work         # Bookmark the current directory
work           # Return to it
work -p        # Print its path
```

`fork` detaches its command with nohup and silences output. `and_delete` accepts
newline-separated paths and prompts before running the deletion command.
`keepalive -u URL -t SECONDS` repeatedly curls a URL. `work_diff [base]` writes
`work.diff` against `main` by default. `podman-api` exposes the same local Unix
socket at `/tmp/podman.sock` as the original script.

## Repository layout

```text
apply                  Deployment command
home.manifest          Modes and paths to install under $HOME
home/                  User configuration and executable scripts
system.manifest        Modes and paths to install under /
system/                System drop-ins
plugins.manifest       Plugin IDs, repositories, and branches
templates/bashrc       Omarchy bootstrap for a home without .bashrc
```

The script copies listed files into place, preserving executable modes. Matching
files are left alone. Existing files or symlinks that need replacement are backed
up under:

```text
~/.local/state/omarchy-preferences/backups/<timestamp>.<unique-id>/
```

Backups mirror `home/` and `system/` paths. To undo a replacement, copy its backup
to the original location; `/etc` restoration requires sudo. Newly created files
have no prior backup and can be removed to undo their installation.

Existing `.bashrc` content is preserved and a loader is appended once. Your
existing Omarchy defaults, Cargo setup, and Homebrew setup stay in that file.
If `.bashrc` is absent, the installer creates an Omarchy bootstrap first.

Each listed configuration file is managed as a whole: applying will replace local
edits with the repository version after backing them up. To keep a local change,
copy it into the corresponding repository file before applying again.

## Add or change a preference

1. Edit its source file in `home/` or `system/`.
2. For a new file, add its mode and relative path to the appropriate manifest:

   ```text
   644 .config/omarchy/hooks/post-boot.d/my-preference
   755 .local/bin/my-command
   ```

3. Run `./apply --dry-run`, then `./apply`. Include `--system` for system changes.
4. Validate the affected component and commit the source changes.

Run the shell-port checks with `python3 tests/shell_smoke.py`.

Add another Bash module by creating it under `home/.config/bash/`, listing it in
`home.manifest`, and sourcing it from `preferences.bash`.

Removing a manifest entry stops managing that file; delete the deployed file
explicitly if you also want to remove the preference from the machine.

## Omarchy updates

Hyprland preferences rely on the Lua override layout provided by Omarchy 4.0.4.
Foot retains the include for Omarchy's generated theme. Package-owned files under
`/usr/share/omarchy` remain the source of upstream defaults.

The keyboard-light fix overrides the packaged `omarchy-system-wake` command through
the user's PATH. Review it against `/usr/share/omarchy/bin/omarchy-system-wake`
after updates so upstream changes can be incorporated. Verify on a new machine
that `command -v omarchy-system-wake` resolves to the deployed user script.

Use `git pull` followed by `./apply --dry-run --system` and `./apply --system` to
deploy repository updates. This repository manages preferences; application
installation and generated runtime state are outside its deployment manifests;
the two shell plugins are installed as part of the preferences.
