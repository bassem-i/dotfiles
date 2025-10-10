local wezterm = require("wezterm")
local config = wezterm.config_builder()
local mux = wezterm.mux

-- Maximize wezterm window on startup
wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	window:gui_window():maximize()
end)

-- Theme & Font
config.color_scheme = "Abernathy"
config.font = wezterm.font("fira code", { weight = "Regular" })
config.font_size = 22.0

-- Disable tab bar
config.enable_tab_bar = false

return config
