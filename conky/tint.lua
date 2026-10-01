-- Purple tint over conky's pseudo-transparent background. With
-- own_window_transparent, the window starts each frame as a copy of the
-- wallpaper; painting a translucent colour over it before the text is drawn
-- gives the same look as the old ARGB window, without needing picom.
-- common.lua hooks this up when no compositor is running.
require("cairo")
pcall(require, "cairo_xlib") -- split out of 'cairo' in newer conky

-- #140418 at 200/255, matching own_window_colour in common.lua.
local R, G, B, A = 0x14 / 255, 0x04 / 255, 0x18 / 255, 200 / 255

function conky_tint()
	if conky_window == nil then
		return
	end
	local cs = cairo_xlib_surface_create(
		conky_window.display,
		conky_window.drawable,
		conky_window.visual,
		conky_window.width,
		conky_window.height
	)
	local cr = cairo_create(cs)
	cairo_set_source_rgba(cr, R, G, B, A)
	cairo_paint(cr)
	cairo_destroy(cr)
	cairo_surface_destroy(cs)
end
