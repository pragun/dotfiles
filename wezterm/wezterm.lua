local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Show which key table is active in the status area
wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then
    name = 'table: ' .. name .. ' '
  end
  window:set_right_status(name or '')
end)

config.color_scheme = "Catppuccin Latte"
-- config.font = wezterm.font("Fira Code")

config.leader = { key = 'b', mods = 'CTRL' }
config.keys = {
  -- Leader, followed by 'r' will put us in resize-pane
  -- mode until we cancel that mode.
  {
      key = 'E',
      mods = 'CTRL|SHIFT',
      action = act.InputSelector {
        action = wezterm.action_callback(function(window, pane, id, label)
          if not id and not label then
            wezterm.log_info 'cancelled'
          else
            wezterm.log_info('you selected ', id, label)
            pane:send_text(id)
          end
        end),
        title = 'I am title',
        choices = {
          -- This is the first entry
          {
            -- Here we're using wezterm.format to color the text.
            -- You can just use a string directly if you don't want
            -- to control the colors
            label = wezterm.format {
              { Foreground = { AnsiColor = 'Red' } },
              { Text = 'No' },
              { Foreground = { AnsiColor = 'Green' } },
              { Text = ' thanks' },
            },
            -- This is the text that we'll send to the terminal when
            -- this entry is selected
            id = 'Regretfully, I decline this offer.',
          },
          -- This is the second entry
          {
            label = 'WTF?',
            id = 'An interesting idea, but I have some questions about it.',
          },
          -- This is the third entry
          {
            label = 'LGTM',
            id = 'This sounds like the right choice',
          },
        },
      },
    },  
  {
    key = 'p',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'move_panes',
      one_shot = false,
      -- timeout_milliseconds = 2000,
    },
  },

  -- Leader, followed by 'n' will put us in new-pane
  {
    key = 's',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
      name = 'splits',
      one_shot = true,
      timeout_milliseconds = 3000,
    },
  },

  {
    key = 't',
    mods = 'LEADER',
    action = act.ActivateKeyTable {
        name = 'tabs',
	one_shot = true,
      -- timeout_milliseconds = 2000,
    },
  },

  {
    key = '/',
    mods = 'LEADER',
    action = act.ActivateCommandPalette,
  }

}

config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  move_panes = {
    { key = 'l', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'h', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },

    { key = 'y', action = act.ActivatePaneDirection 'Left' },
    { key = 'u', action = act.ActivatePaneDirection 'Down' },
    { key = 'i', action = act.ActivatePaneDirection 'Up' },
    { key = 'o', action = act.ActivatePaneDirection 'Right' },

    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
  },

  splits = {
    { key = 'h', action = act.SplitPane { direction = 'Left', size = { Percent = 50 }, }, },
    { key = 'l', action = act.SplitPane { direction = 'Right', size = { Percent = 50 }, }, },
    { key = 'k', action = act.SplitPane { direction = 'Up', size = { Percent = 50 }, }, },
    { key = 'j', action = act.SplitPane { direction = 'Down', size = { Percent = 50 }, }, },

    --{ key = 'y', action = act.ActivatePaneDirection 'Left' },
    --{ key = 'u', action = act.ActivatePaneDirection 'Down' },
    --{ key = 'i', action = act.ActivatePaneDirection 'Up' },
    --{ key = 'o', action = act.ActivatePaneDirection 'Right' },
    --
    { key = 's', action = act.PaneSelect { mode = "Activate" }, },
    { key = 'y', action = act.PaneSelect { mode = "SwapWithActiveKeepFocus" }, },
    { key = 'u', action = act.PaneSelect { mode = "SwapWithActive" }, },
    { key = 'o', action = act.PaneSelect { mode = "MoveToNewTab" }, },
    { key = 'p', action = act.PaneSelect { mode = "MoveToNewWindow" }, },
    
    { key = 'q', action = act.CloseCurrentPane { confirm = true }, },

    { key = 'Escape', action = 'PopKeyTable' },
  },

  tabs = {
    { key = 'h', action = act.ActivateTabRelative(-2) },
    { key = 'l', action = act.ActivateTabRelative(2) },
    { key = 'j', action = act.ActivateTabRelative(-1) },
    { key = 'k', action = act.ActivateTabRelative(1) },
    { key = 'y', action = act.MoveTabRelative(-2) },
    { key = 'u', action = act.MoveTabRelative(-1) },
    { key = 'i', action = act.MoveTabRelative(1) },
    { key = 'o', action = act.MoveTabRelative(2) },
    { key = 't', action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 's', action = act.ShowTabNavigator },
    { key = 'n', action = act.SpawnWindow },
    { key = 'q', action = act.CloseCurrentTab { confirm = true }, },

    { key = '1', action= act.ActivateTab(0) },
    { key = '2', action= act.ActivateTab(1) },
    { key = '3', action= act.ActivateTab(2) },
    { key = '4', action= act.ActivateTab(3) },
    { key = '5', action= act.ActivateTab(4) },
    { key = '6', action= act.ActivateTab(5) },
    { key = '7', action= act.ActivateTab(6) },
    { key = '8', action= act.ActivateTab(7) },
    { key = '9', action= act.ActivateTab(8) },

    { key = 'Escape', action = 'PopKeyTable' },
  }

}

wezterm.on('augment-command-palette', function(window, pane)
  return {
    {
      brief = 'Action 1',
      icon = 'fa_plug',

      action = wezterm.action.PromptInputLine {
        description = "This is action 1",
        action = wezterm.action_callback(function(window, pane, line)  -- do nothing but wait for keypress
        end),
      },
    },
    {
      brief = 'Action 2',
      icon = 'fa_plug',

      action = wezterm.action.PromptInputLine {
        description = "This is action 2",
        action = wezterm.action_callback(function(window, pane, line)  -- do nothing but wait for keypress
        end),
      },
    },
  }
end)


return config
