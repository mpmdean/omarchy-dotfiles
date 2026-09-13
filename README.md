# omarchy-dotfiles

My personal setup on top of a fresh [Omarchy](https://omarchy.org) install:
what to remove, which extra community themes to add, and which extra tools
to install. Reproducible on a new machine with `./install.sh --all`.

## Usage

```bash
git clone https://github.com/mpmdean/omarchy-dotfiles.git
cd omarchy-dotfiles
./install.sh --all          # or --remove / --themes / --extras individually
```

Every step is idempotent - safe to re-run, it skips anything already
installed/removed. Pass `--yes` to skip the confirmation prompt.

## Removed from the base install (`data/remove.txt`)

| App | Why |
|---|---|
| **Basecamp** (webapp) | Bundled by default (Omarchy's creator also makes Basecamp); not used here. |
| **Xournal++** (`xournalpp`) | Bundled by default; not used here. |

Add more lines to `data/remove.txt` any time (`webapp:<Name>` or
`pkg:<name>`). `HEY` is left as a commented-out suggestion in that file -
same family as Basecamp, not removed yet since it wasn't asked for.

## Extra themes (`data/themes.txt`)

Community themes cloned into `~/.config/omarchy/themes/` via
`omarchy-theme-install`, matching what's on this machine now:

akaito, ayu-light, azure, corporate, dayfox, desert-gleam,
gornergrat-station, gruvbox-light, harbor, infernium, latch, mapquest,
milkmatcha-light, roseofdune, seashells / seashells-light, snow,
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
  pacman package and the `crmne.hyprmoncfg` Omarchy plugin.

Add more tools by appending a line to `data/extras.txt`
(`name|pacman-package|plugin-git-url|plugin-id|description`; leave the
plugin fields empty for a plain package). Note that Omarchy plugins run as
unsandboxed code inside `omarchy-shell` - only add ones you've reviewed.
