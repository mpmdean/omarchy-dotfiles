# omarchy-dotfiles

My personal setup on top of a fresh [Omarchy](https://omarchy.org) install:
what to remove, which extra community themes to add, which extra tools to
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

## Extra themes (`data/themes.txt`)

Community themes cloned into `~/.config/omarchy/themes/` via
`omarchy-theme-install`, matching what's on this machine now:

akaito, ayu-light, azure, corporate, dayfox, desert-gleam,
gornergrat-station, gruvbox-light, harbor, infernium, latch, mapquest,
milkmatcha-light, qianli, roseofdune, seashells / seashells-light, snow,
solarized-light, thegreek, unicorn-dream, white-air, whitegold.

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

Add more tools by appending a line to `data/extras.txt`
(`name|pacman-package|plugin-git-url|plugin-id|user-service|description`;
leave the plugin/service fields empty for a plain package). Note that
Omarchy plugins run as unsandboxed code inside `omarchy-shell` - only add
ones you've reviewed.

## Default editor (`data/editor.txt`)

Sets the Omarchy default editor (`omarchy-default-editor`, which drives
`$EDITOR`/`omarchy-launch-editor`) to **VS Code**. Change `data/editor.txt`
to switch it (one of `code`, `cursor`, `zed`, `sublime_text`, `helix`,
`vim`, `emacs`, `nvim`).

Note this doesn't touch `~/.config/mimeapps.list`, so double-clicking a text
file in the file manager still opens whatever's set there (currently
Neovim) - that's a separate, GUI-level default not covered by this repo yet.

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
