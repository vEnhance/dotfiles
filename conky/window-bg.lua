-- Window background settings for the conky configs, merged into conky.config.
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
local composited = os.execute('pgrep -u "$(id -u)" -x picom >/dev/null')

if composited then
	return {
		own_window_colour = "#c8140418", -- keep in sync with tint.lua
	}
end

return {
	own_window_transparent = true,
	lua_load = os.getenv("HOME") .. "/dotfiles/conky/tint.lua",
	lua_draw_hook_pre = "tint",
}
