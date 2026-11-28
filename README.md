# omarchy-dotfiles

My personal setup on top of a fresh [Omarchy](https://omarchy.org) install:
what to remove, which web apps to add, which extra community themes to add, which extra tools to
install, the default editor, and the BNL VPN keybinding. Reproducible on a
new machine with `./install.sh`.

## Usage

```bash
git clone https://github.com/mpmdean/omarchy-dotfiles.git
cd omarchy-dotfiles
./install.sh                 # runs every step below, in order
./install.sh install-vpn     # or name specific steps (scripts/<name>.sh) to run just those
```

Every step is idempotent - safe to re-run, it skips anything already
installed/removed. Destructive bits (removing a package, adding a plugin)
go through `yay`/`omarchy-plugin-add`'s own confirmation prompts rather than
a prompt of this repo's own.

## Removed from the base install (`data/remove.txt`)

| App | Why |
|---|---|
| **Basecamp** (webapp) | Bundled by default (Omarchy's creator also makes Basecamp); not used here. |
| **Xournal++** (`xournalpp`) | Bundled by default; not used here. |
| **HEY** (webapp) | Bundled by default (same 37signals family as Basecamp); not used here. |

Add more lines to `data/remove.txt` any time (`webapp:<Name>` or
`pkg:<name>`).

## Extra web apps (`data/webapps.txt`)

Desktop launchers added with `omarchy-webapp-install`:

- **Outlook** - Microsoft 365 mail at `https://outlook.office.com/mail/`,
  bound to `SUPER + SHIFT + E` (replacing the default HEY Email binding).

Add more with a `Name|url|icon-url|keybinding` line (keybinding optional; icons from
[dashboard-icons](https://github.com/homarr-labs/dashboard-icons) work well).

## Extra themes (`data/themes.txt`)

Community themes cloned into `~/.config/omarchy/themes/` via
`omarchy-theme-install`, matching what's on this machine now:

akaito, ayu-light, azure, corporate, dayfox, desert-gleam, forest-green,
forest-night, gornergrat-station, green-garden, gruvbox-light, harbor,
infernium, jade-horse, latch, mapquest, milkmatcha-light, nz-forest,
nz-mountains-and-lakes, osaka-tree, ozark, qianli, retro-stripes,
roseofdune, sakura, seashells / seashells-light, snow, solarized-light,
thegreek, unicorn-dream, white-air, whitegold.

Sources are in `data/themes.txt`, one GitHub/GitLab repo per theme.

**Note on `seashells`:** its upstream repo also contains a bundled
`.claude/skills/` directory - an unrelated third-party "Claude Enforcer"
agent/skill framework with its own executable hooks, dropped into a color
theme repo. It has nothing to do with theming and gets silently picked up as
ambient Claude Code skills if a full `git clone` of that repo ends up under
your home directory. `scripts/install-themes.sh` avoids this by using the
theme's own minimal file-list installer instead of a full clone, and strips
`.claude/` as a backstop either way. If you ever `git clone` that repo
directly, delete `.claude/` from it before it sits under `~`.

## Extra tools (`data/extras.txt`)

- **[hyprmoncfg](https://github.com/crmne/omarchy-hyprmoncfg)** - the
  "good monitor tool" from the base machine: a terminal-first Hyprland
  monitor (display) configurator and auto-switching daemon, plus an Omarchy
  bar-widget plugin for editing multi-monitor layouts visually. Profiles are
  matched by monitor make/model/serial and reapplied automatically on
  hotplug, lid open/close, and resume. Installed as both the `hyprmoncfg`
  pacman package and the `crmne.hyprmoncfg` Omarchy plugin, with the
  `hyprmoncfgd` user service enabled for the auto-switching.
- **[openconnect](https://www.infradead.org/openconnect/)** - open-source
  client for Cisco AnyConnect, GlobalProtect, Pulse and Fortinet SSL VPNs.
  Plain pacman package, no plugin.
- **[hyprmon](https://github.com/erans/hyprmon)** - TUI multi-monitor
  profile manager for Hyprland: arrange monitors visually, set
  scale/rotation/mirroring, save and switch profiles. Installed from the
  AUR as `hyprmon-bin` (packaged by the upstream author), no plugin.
- **[ONLYOFFICE](https://www.onlyoffice.com/desktop.aspx)** - desktop
  office suite (documents, spreadsheets, presentations, PDFs) with good
  Microsoft Office format compatibility. Installed from the AUR as
  `onlyoffice-bin` (the official upstream build), no plugin.
- **[TeX Live](https://tug.org/texlive/)** - a full LaTeX install via the
  `texlive-meta` package, which pulls in every TeX Live collection except
  the language packs (`texlive-lang*`; add those individually if needed).
  Includes `latexmk`, so `latexmk -pdf file.tex` (or `-xelatex`/`-lualatex`)
  builds everything, rerunning as needed. Plus **biber**, the biblatex
  backend that latexmk calls automatically. About 3 GB installed.
- **[Obsidian](https://obsidian.md/)** - Markdown knowledge base and
  note-taking app that works on top of a local folder (vault) of plain-text
  notes. Plain pacman package from `extra`, no plugin.
- **[Blender](https://www.blender.org/)** - 3D modelling, animation,
  rendering and compositing suite. Plain pacman package from `extra`, no
  plugin. Alongside it: `python` and `python-pip` (for scripting and add-on
  work), `git`, and `git-lfs` for repos with large binary assets such as
  `.blend` files. After the extras are installed, `install-extras.sh` runs
  `git lfs install --skip-repo`, which registers the LFS filters in
  `~/.gitconfig` without touching any repository.
- **[Typst](https://typst.app/)** - markup-based typesetting system for
  the sciences: a fast, simpler alternative to LaTeX with readable syntax,
  built-in math, and incremental compilation. Plain pacman package from
  `extra`, no plugin. `typst compile file.typ` builds a PDF, and
  `typst watch file.typ` rebuilds on every save.

Add more tools by appending a line to `data/extras.txt`
(`name|pacman-package|plugin-git-url|plugin-id|user-service|description`;
leave the plugin/service fields empty for a plain package). Note that
Omarchy plugins run as unsandboxed code inside `omarchy-shell` - only add
ones you've reviewed.

## VESTA (`scripts/install-vesta.sh`)

[VESTA](https://jp-minerals.org/vesta/) shows crystal structures, volumetric
data such as electron/nuclear densities, and crystal morphologies in 3D. It
reads CIF, POSCAR, cube and many other formats. The script installs it the way
the [official download page](https://jp-minerals.org/vesta/en/download.html)
describes, not from the AUR. It downloads the stable Linux x86_64 GTK3 tarball
(ver. 3.5.8, which needs GTK 3.22 or newer) and unpacks it into
`~/.local/opt/VESTA-gtk3`. It then links `vesta`/`VESTA` into `~/.local/bin`
and adds a `vesta.desktop` launcher entry. No root is needed. If VESTA is
already unpacked there, the download is skipped, because VESTA keeps its
settings (`VESTA.ini`) in that folder. To upgrade, delete the folder and
rerun. Change `VERSION` in the script to pick another release.

## Conda `main` environment (`data/conda-main.yml`)

`scripts/install-conda-env.sh` creates a conda environment called `main`
with a general scientific Python stack from conda-forge:

- **Numerics:** numpy, scipy, sympy, pandas, xarray, h5py, dask (with
  distributed and its dashboard), numba
- **Fitting/analysis:** lmfit, scikit-learn, scikit-image
- **Plotting:** matplotlib, plus ipympl for interactive figures in Jupyter
  (`%matplotlib widget`)
- **Jupyter:** jupyterlab, ipykernel, ipywidgets
- **Utilities:** tqdm, pip

Python is pinned to 3.13. If `~/miniforge3` doesn't exist yet, the script
first installs [Miniforge](https://github.com/conda-forge/miniforge) there
from the official installer, after checking its checksum. On a re-run it
updates the existing env in place: packages newly added to the file get
installed, and nothing you installed yourself is removed. Use it with
`conda activate main`.

## Default editor (`data/editor.txt`)

Sets the Omarchy default editor (`omarchy-default-editor`, which drives
`$EDITOR`/`omarchy-launch-editor`) to **VS Code**. Change `data/editor.txt`
to switch it (one of `code`, `cursor`, `zed`, `sublime_text`, `helix`,
`vim`, `emacs`, `nvim`).

Note this doesn't touch `~/.config/mimeapps.list`, so double-clicking a text
file in the file manager still opens whatever's set there (currently
Neovim) - that's a separate, GUI-level default not covered by this repo yet.

## World Clock cities (`data/world-clock.json`)

Sets the cities in the World Clock bar widget (`omarchy.elsewhen`, in the
`centerEnd` section): New York, London, Chicago, San Francisco, Tokyo and Paris.
`scripts/set-world-clock.sh` applies them with
`omarchy bar set omarchy.elsewhen cities ... --json`, and does nothing if
the bar already shows the same list.

Each entry needs a `name` and an IANA `zone`. `lat`, `lon` and `region` are
optional and place the city on the widget's globe. To update the file after
changing cities in the widget, run:

```bash
omarchy bar get omarchy.elsewhen cities | jq . > data/world-clock.json
```

## Window corners (`data/window-corners.txt`)

Rounds window corners to **12 px**, twice Omarchy's built-in "rounded"
option (6 px). `scripts/set-window-corners.sh` writes a block marked
`omarchy-dotfiles: window corners` into `~/.config/hypr/looknfeel.lua`.
On a re-run it replaces that block instead of adding a second one, so
changing the number in `data/window-corners.txt` and re-running updates it.
Hyprland picks up the change as soon as the file is saved.

`looknfeel.lua` loads after the theme, so the radius applies to every
theme. Omarchy's own `omarchy hyprland corners rounded` setting loads
later still and would force 6 px, so the script switches it back to
`theme` if it's on. `omarchy hyprland corners sharp` still gives square
corners.

## Boot screen (`data/plymouth.txt`)

`scripts/set-plymouth.sh` sets the Plymouth boot screen with
`omarchy plymouth set`: a white background, `#e85237` orange text, and the
orange EDRIXS logo (`data/EDRIXS_logo_orange.png`). The orange was taken
from the Retro Stripes Flare background, and the logo is a recolored copy
of `data/EDRIXS_logo.png`. The same command also restyles the SDDM login
screen with these colors and logo. It needs sudo. The step is skipped if
the installed logo, background and text color already match.

Change the `background|text|logo` line in `data/plymouth.txt` to use
something else. Preview a change first with
`omarchy plymouth preview <background> <text> <logo> preview.png`, and go
back to the stock screen with `omarchy plymouth reset`.

## iCloud Documents sync (`data/rclone-sync.txt`)

Keeps iCloud Drive's `Documents` folder and `~/Documents` in sync **both
ways** with [rclone bisync](https://rclone.org/bisync/), re-syncing every
10 minutes on a systemd user timer (`rclone-sync-icloud-documents.timer`).

- **Two-way.** New files, edits and **deletions** on either side reach the
  other side. Deleting a file here deletes it from iCloud, and so from your
  Mac and iPhone too.
- **Conflicts:** if a file changed on both sides between syncs, both
  copies are kept as `<file>.conflict1` / `<file>.conflict2`. Pick one and
  delete the other.
- **Local safety net:** local files that bisync deletes or overwrites are
  moved to `~/.local/share/rclone-sync-backup/icloud-documents/` first.
  rclone also aborts any run that would delete more than half of the files.
- **Baseline:** the install script runs a one-time `bisync --resync
  --resync-mode newer` first. That merges the two sides without deleting
  anything, and where a file differs the newer copy wins. If bisync ever
  aborts and asks for a resync (you'll get a failure notification), delete
  `~/.local/state/rclone-sync/icloud-documents.resynced` and re-run
  `./install.sh install-rclone-sync`.
- **First run is interactive.** If there's no `icloud:` remote yet, the
  script opens `rclone config`. Choose `n` and the name `icloud`, then the
  type `iclouddrive`, and enter your Apple ID, password and 2FA code. iCloud
  requires **Advanced Data Protection off** and **"Access iCloud Data on
  the Web" on**.
- **Re-authenticating:** Apple's trust token expires after about 30 days.
  When it does, a failed sync shows a desktop notification. Fix it with
  `rclone config reconnect icloud:`.
- Logs: `journalctl --user -u rclone-sync-icloud-documents`. Sync now:
  `systemctl --user start rclone-sync-icloud-documents`.

To add another folder, add a `name|bisync-or-sync|remote:path|local-dir|interval`
line (`sync` = one-way, cloud -> local only).

## BNL VPN (`scripts/install-vpn.sh`)

Installs the `bnl-vpn` toggle and wires up `SUPER+SHIFT+V` in
`~/.config/hypr/bindings.lua`. The actual script, the privileged
`bnl-vpn-helper`, and its `sudoers.d` rule live in the private
[mpmdean/VPN_helper](https://github.com/mpmdean/VPN_helper) repo (kept out
of this public one since it's BNL/employer-specific and touches sudo) -
`install-vpn.sh` clones it (via `gh`'s git credential helper) and runs its
installer, which needs sudo for the root-owned helper and validates the
sudoers rule with `visudo -cf` before installing it.

Credentials are never stored in either repo - after installing, run once:

```bash
secret-tool store --label='BNL VPN username' service bnl-vpn field username
secret-tool store --label='BNL VPN password' service bnl-vpn field password
```

Then `SUPER+SHIFT+V` connects (opening a small floating terminal for the
DUO second-factor prompt) or disconnects.

## Superwhisper dictation fixes (manual, not scripted yet)

Dictation worked in terminals but often didn't arrive in **VS Code** or the
**Outlook** webapp. Superwhisper types through the fcitx5 input method,
and the log (`journalctl --user -u superwhisper`) showed
`fcitx5 commit declined (no_input_context)`. Chromium and Electron apps
don't talk to the Wayland input method by default, and the paste fallback
didn't reliably land either.

**1. Turn on the Wayland input method in Chromium/Electron:**

- `~/.config/chromium-flags.conf` (covers Chromium and every webapp,
  including Outlook): append
  ```
  --enable-wayland-ime
  --wayland-text-input-version=3
  ```
- `~/.config/code-flags.conf` (read by the `visual-studio-code-bin`
  launcher):
  ```
  --ozone-platform=wayland
  --enable-wayland-ime
  --wayland-text-input-version=3
  ```
  `code .` then warns that these options are "not in the list of known
  options". That's harmless: VS Code still passes them through to Chromium.

Fully quit and reopen Chromium and VS Code to pick these up.

**2. Don't use Alt in the dictation shortcut.** With the flags in place,
VS Code still lost its input-method focus at the moment the old shortcut
`Ctrl+Alt+Space` was pressed, while dictation started from the CLI with no
keys pressed went straight in. Most likely the Alt press (Electron moves
focus to the menu bar on Alt) is what drops it. A Left Ctrl hold key gave
false triggers during ordinary Ctrl shortcuts, so the hold-to-talk key is
now **Right Ctrl**:

```bash
superwhisper shortcuts set hold "RightControl"
```

**3. Give the Magic Keyboard a Right Ctrl.** It has no Right Ctrl key, so
`~/.config/hypr/input.lua` maps its right Command key to Right Ctrl, for
that keyboard only. Superwhisper's shortcuts are Hyprland binds, so they
see the remapped key. The thumb position matches the Framework keyboard's
Right Ctrl:

```lua
hl.device({
  name = "<magic-keyboard-name>",   -- from `hyprctl devices`
  kb_layout = "us",
  kb_options = "omarchy:shift_caps_compose,ctrl:swap_rwin_rctl",
})
```

The trade-off is that right Command on the Magic Keyboard no longer acts
as Super. Use left Command for Super bindings.

**Debugging tip:** to see whether an app's text field is connected to
fcitx5, run
`busctl --user call org.fcitx.Fcitx5 /controller org.fcitx.Fcitx.Controller1 DebugInfo`
and look for that app's entry with `focus:1`.
