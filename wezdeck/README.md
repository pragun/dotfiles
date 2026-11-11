# wezdeck

Session deck for WezTerm + Claude Code: a Hammerspoon panel (Option+W) that lists every
Claude session by project, jumps to one, searches, pins a session to a project/group.

- `bin/deck`: the Python script (model, jump, rename, assign). Stdlib only, Python 3.9 compatible.
- `registry.json`: projects, their short codes, and manager keys. Edit freely.
- `docs/`: the design pages (overview, sidebar idea, window layout, groups).
- `state.json`, `panel.log`, `moves-undo.json`: written at runtime, not tracked.

The panel lives in `../hammerspoon/deck/`, and `../wezterm/wezterm.lua` has the
`user-var-changed` handler that lets the deck focus a session. The deck expects this
folder at `~/.config/wezdeck`, so on a new machine:

    ln -s ~/Projects/dotfiles/wezdeck ~/.config/wezdeck
