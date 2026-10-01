-- conky.text blocks shared by the stats-style configs (stats-power-widget,
-- star-bar, and summary-bar on laptops). Each block ends in a newline, so they
-- splice into a config's text as:
--   ...previous line
--   ]] .. sections.top_cpu .. [[
--   next line...
-- Section headers use font5, which common.lua defines.
local sections = {}

-- five busiest processes by CPU, under a per-config column header
sections.top_cpu = [[
${color4}${top name 1} ${goto 150}${top cpu 1}%${goto 220}${top mem_res 1}${goto 290}${top_mem pid 1}
${color5}${top name 2} ${goto 150}${top cpu 2}%${goto 220}${top mem_res 2}${goto 290}${top_mem pid 2}
${color6}${top name 3} ${goto 150}${top cpu 3}%${goto 220}${top mem_res 3}${goto 290}${top_mem pid 3}
${color6}${top name 4} ${goto 150}${top cpu 4}%${goto 220}${top mem_res 4}${goto 290}${top_mem pid 4}
${color6}${top name 5} ${goto 150}${top cpu 5}%${goto 220}${top mem_res 5}${goto 290}${top_mem pid 5}
]]

sections.gpu = [[
${voffset 8}${font5}${color1}[ GPU ] ${voffset 2}${hr 2}${voffset 0}$color
${voffset 3}${font Exo 2:size=16}${execpi 3 ~/dotfiles/conky/gpu-load.sh}
]]

-- used/total memory with gauge and bar
sections.memory = [[
${voffset 5}${font5}${color1}[ Memory ] ${voffset 2}${hr 2}${voffset 10}$color
${goto 100}${color DAC0DE}${voffset -8}${font Exo 2:bold:size=20}${mem}${color3}${goto 230}${voffset 4}${memgauge 19,40} ${color DAC0DE}${voffset -4}${font Exo 2:bold:size=14}$memperc%
${goto 111}${color2}${font Exo 2:bold:size=14} / ${memmax}$font${alignr}${membar 12,105}
]]

-- five biggest processes by memory, under a per-config column header
sections.top_mem = [[
${color2}${top_mem name 1} ${goto 150}${top_mem mem_res 1}${goto 220}${top_mem mem 1}%${goto 290}${top_mem pid 1}
${color1}${top_mem name 2} ${goto 150}${top_mem mem_res 2}${goto 220}${top_mem mem 2}%${goto 290}${top_mem pid 2}
${color3}${top_mem name 3} ${goto 150}${top_mem mem_res 3}${goto 220}${top_mem mem 3}%${goto 290}${top_mem pid 3}
${color3}${top_mem name 4} ${goto 150}${top_mem mem_res 4}${goto 220}${top_mem mem 4}%${goto 290}${top_mem pid 4}
${color3}${top_mem name 5} ${goto 150}${top_mem mem_res 5}${goto 220}${top_mem mem 5}%${goto 290}${top_mem pid 5}
]]

-- One filesystem row: free space and a usage bar, labelled with `mark`.
-- `voffset` nudges the row's spacing, which differs between configs.
function sections.disk(voffset, mark, path)
	return string.format(
		"${voffset %d}${color9}${font DejaVu Sans Mono:bold}%s ${font Exo 2}${color4}${fs_free %s} Free (${color5}${fs_free_perc %s}%%${color4})$color   $alignr${color5}${voffset 2}${fs_bar 10,150 %s}$color\n",
		voffset,
		mark,
		path,
		path,
		path
	)
end

return sections
