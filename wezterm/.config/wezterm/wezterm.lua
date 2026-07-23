local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.font_size = 13.0
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.scrollback_lines = 100000
config.audible_bell = 'Disabled'
-- Keep bell feedback visible, but make the background flash gentle.
config.visual_bell = {
	fade_in_duration_ms = 90,
	fade_out_duration_ms = 140,
	target = 'BackgroundColor',
}
config.window_decorations = 'RESIZE'
config.adjust_window_size_when_changing_font_size = false

-- Change these two once you know your preferred terminal look.
config.font = wezterm.font 'Menlo'

local preferred_scheme = 'Builtin Solarized Light'
local builtin_schemes = wezterm.get_builtin_color_schemes()
if builtin_schemes[preferred_scheme] then
	config.color_scheme = preferred_scheme

	-- Keep the bell color close to the theme background for a softer flash.
	local scheme_bg = builtin_schemes[preferred_scheme].background
	if scheme_bg then
		config.colors = config.colors or {}
		config.colors.visual_bell = wezterm.color.parse(scheme_bg):darken(0.06)
	end
end

return config
