local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action

config.font = wezterm.font("MesloLGS NF")
config.color_scheme = "Catppuccin Mocha"

config.hide_tab_bar_if_only_one_tab = true

config.font_size = 17

config.enable_tab_bar = true

config.window_decorations = "TITLE|RESIZE"

config.window_background_opacity = 0.85

config.keys = {
   { 
        key = 'Backspace', 
        mods = 'CTRL', 
        action = act.SendKey {key = 'w', mods = 'CTRL'} 
    },
    {
        key = 'LeftArrow',
        mods = 'OPT',
        action = act.SendKey {
          key = 'b',
          mods = 'ALT',
        },
      },
      {
        key = 'RightArrow',
        mods = 'OPT',
        action = act.SendKey { key = 'f', mods = 'ALT' },
      },
      {
        key = 'Backspace',
        mods = 'CMD',
        action = act.SendKey { key = 'u', mods = 'CTRL' },
      },
}

config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}


return config
