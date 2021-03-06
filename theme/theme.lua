---------------------------
-- Default awesome theme --
---------------------------
local lfs = require("lfs")

local theme_dir = config_dir .. "/theme"

theme = {}

theme.font          = "snap 8"


theme.bg_normal     = "#121212"
theme.bg_focus      = "#111111"
theme.bg_urgent     = "#A6000A"
theme.bg_minimize   = "#111111"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#A6000A"
theme.fg_urgent     = "#850d0d"
theme.fg_minimize   = "#555555"
theme.fg_highlight  = "#dddddd"
theme.fg_faded      = "#555555"

theme.border_width  = "2"
theme.border_normal = "#222222"
theme.border_focus  = "#A6000A"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:

theme.tooltip_opacity = .9
theme.tooltip_font = "MonteCarlo 8"
theme.tooltip_fg_color = "#aaaaaa"

theme.taglist_bg_focus = "#222222"
theme.taglist_bg_urgent = "#991000"


theme.wibox_fg_normal = "#999999"
theme.wibox_bg_normal = "#121212"
theme.wibox_border_normal = "#222222"
theme.wibox_border_width = "1"
theme.wibox_height = "16"

-- Display the taglist squares
--theme.taglist_squares_sel   = theme_dir .. "/taglist/squarefw.png"
--theme.taglist_squares_unsel = theme_dir .. "/taglist/squarew.png"
--theme.taglist_bg_focus = theme.bg_normal

--theme.tasklist_floating_icon = theme_dir .. "/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = theme_dir .. "/submenu.png"
theme.menu_height = "10"
theme.menu_width  = "100"
theme.menu_border_width = "0"
theme.menu_bg = "#111111"
theme.menu_bg_focus = "#222222"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = theme_dir .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = theme_dir .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = theme_dir .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = theme_dir .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme_dir .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = theme_dir .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = theme_dir .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = theme_dir .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme_dir .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = theme_dir .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = theme_dir .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = theme_dir .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme_dir .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = theme_dir .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = theme_dir .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme_dir .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme_dir .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = theme_dir .. "/titlebar/maximized_focus_active.png"


-- You can use your own layout icons like this:
theme.layout_fairh = theme_dir .. "/layouts/fairhw.png"
theme.layout_fairv = theme_dir .. "/layouts/fairvw.png"
theme.layout_floating  = theme_dir .. "/layouts/floatingw.png"
theme.layout_magnifier = theme_dir .. "/layouts/magnifierw.png"
theme.layout_max = theme_dir .. "/layouts/maxw.png"
theme.layout_fullscreen = theme_dir .. "/layouts/fullscreenw.png"
theme.layout_tilebottom = theme_dir .. "/layouts/tilebottomw.png"
theme.layout_tileleft   = theme_dir .. "/layouts/tileleftw.png"
theme.layout_tile = theme_dir .. "/layouts/tilew.png"
theme.layout_tiletop = theme_dir .. "/layouts/tiletopw.png"
theme.layout_spiral  = theme_dir .. "/layouts/spiralw.png"
theme.layout_dwindle = theme_dir .. "/layouts/dwindlew.png"
theme.layout_uselessfair = theme_dir .. "/layouts/uselessfairw.png"
theme.layout_termfair = theme_dir .. "/layouts/termfairw.png"
theme.layout_centerwork = theme_dir .. "/layouts/centerworkw.png"
theme.layout_browse = theme_dir .. "/layouts/browsew.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

theme.useless_gap_width = 10

theme.icons = {}
local icon_dir = theme_dir .. "/icons/png/"

for f in lfs.dir(icon_dir) do
    theme.icons[string.sub(f, 0, -5)] = icon_dir .. f
end


return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
