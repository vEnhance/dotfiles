-- Settings shared by every conky config. Each config passes its own settings,
-- which take precedence over these:
--   conky.config = dofile(os.getenv("HOME") .. "/dotfiles/conky/common.lua")({
--   	alignment = "top_right",
--   	...
--   })

local common = {
	background = true,
	cpu_avg_samples = 1,
	net_avg_samples = 2,
	default_color = "white",
	default_outline_color = "white",
	default_shade_color = "white",
	double_buffer = true,
	draw_borders = false,
	draw_graph_borders = true,
	draw_outline = false,
	draw_shades = false,
	use_xft = true,
	imlib_cache_size = 10,
	no_buffers = true,
	out_to_console = false,
	out_to_stderr = false,
	extra_newline = false,
	own_window = true,
	own_window_class = "Conky",
	own_window_type = "override",
	own_window_hints = "undecorated,skip_taskbar,skip_pager,below",
	stippled_borders = 0,
	short_units = false,
	text_buffer_size = 512,
	uppercase = false,
	use_spacer = "none",
	show_graph_scale = true,
	show_graph_range = false,
	color1 = "D14EE3", -- purple 1
	color2 = "D77FE3", -- purple 2
	color3 = "B03BC3", -- purple 3
	color4 = "77d3f4", -- blue 1
	color5 = "33b5e5", -- blue 2
	color6 = "0099cc", -- blue 3
	color7 = "75b704", -- green
	color8 = "b4ebff", -- light blue
	color9 = "dedede", -- white
	color0 = "777777", -- gray
	font5 = "Exo 2:semibold", -- section headers
}

-- Window background.
--
-- conky 1.24 always uses an ARGB window when a compositor is running, and then
-- applies the window colour's alpha to $hr lines and bars too (conky #2464). A
-- fully transparent window makes those draw as alpha-0 pixels, which picom
-- adds on top of the background, washing them out to white. So:
--   * picom running: a real translucent window, as before tint.lua existed.
--   * no compositor: pseudo-transparency (a copy of the wallpaper) darkened by
--     tint.lua, which matches the translucent look without needing picom.
-- This is decided once at startup, so conky must be restarted whenever picom
-- starts or stops (sh-scripts/obs.sh does this).
if os.execute('pgrep -u "$(id -u)" -x picom >/dev/null') then
	common.own_window_colour = "#c8140418" -- keep in sync with tint.lua
else
	common.own_window_transparent = true
	common.lua_load = os.getenv("HOME") .. "/dotfiles/conky/tint.lua"
	common.lua_draw_hook_pre = "tint"
end

return function(settings)
	local config = {}
	for k, v in pairs(common) do
		config[k] = v
	end
	for k, v in pairs(settings) do
		config[k] = v
	end
	return config
end
