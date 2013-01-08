-- Standard awesome library
--local gears = require("gears")
awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
wibox = require("wibox")
-- Theme handling library
beautiful = require("beautiful")
-- Notification library
naughty = require("naughty")
--local menubar = require("menubar")
-- layouts
layouts = require("layouts")
-- Terminal
quake = require("quake")
vicious = require("vicious")
--vicious.contrib = require("vicious.contrib")

--{{{ Encode for html.
encode = function(s)
    if s then
        return s:gsub("(.)", function(c)
            return string.format("&#%d;", string.byte(c))
        end)
    else
        return ""
    end
end
--}}}

local widget = function(...)
    local options = {}
    local arg = {...}
    if type(arg[#arg]) == "table" then
        options = table.remove(arg)
    end

    local w = options.widget
    if not w then
        w = wibox.widget.textbox()
    end
    vicious.register(w, ...)

    if options.icon then
        local t = w
        local i = wibox.layout.margin(wibox.widget.imagebox(options.icon))
        i:set_margins(4)
        w = wibox.layout.fixed.horizontal()
        w:add(i)
        w:add(t)
    end
    if options.tooltip then
        awful.tooltip({ objects = {w}, timer_function = options.tooltip })
    end
    if options.min_width then
        local old_fit = w.fit
        w.fit = function(...)
            x, y = old_fit(...)
            return math.max(options.min_width, x), y
        end
    end

    return w
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
terminal = os.getenv("TERMINAL") or "/usr/bin/urxvt"
browser = os.getenv("BROWSER") or "/usr/bin/firefox"
editor = os.getenv("EDITOR") or "vim"
config_dir = awful.util.getdir("config")
home_dir = os.getenv("HOME")
editor_cmd = terminal .. " -e " .. editor


quake_console = quake({
    terminal = terminal,
    argname = "-name %s -e tmux",
    name = "tilda",
    height = 300,
    width = 520,
    horiz = "right",
    vert = "bottom",
    screen = 1
})

-- Themes define colours, icons, and wallpapers
beautiful.init(config_dir .. "/theme/theme.lua")

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    --awful.layout.suit.floating,
    --awful.layout.suit.tile,
    layouts.uselesstile,
    layouts.termfair,
    layouts.browse,
    --layouts.uselessfair,
    --layouts.centerwork,
--    awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
--    awful.layout.suit.fair.horizontal,
--    awful.layout.suit.spiral,
--    awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max
--    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
local SYSTEMCTL="systemctl -q --no-block"

session = {
    lock        = SYSTEMCTL .. " --user start lock.target",
    sleep       = SYSTEMCTL .. " suspend",
    logout      = SYSTEMCTL .. " --user exit",
    restart     = SYSTEMCTL .. " reboot",
    shutdown    = SYSTEMCTL .. " poweroff"
}

mysessionmenu = {}
for k, v in pairs(session) do
    table.insert(mysessionmenu, {k, v})
end

mysystemmenu = {
    { "io", terminal .. " -e sudo iotop" },
    { "network", terminal .. " -e sudo iftop" },
    { "printers", "xdg-open http://localhost:631"},
    { "system", terminal .. " -e htop" },
    { "volume", terminal .. " -e alsamixr" },
}
mysettingsmenu = {
    { "awesome", editor_cmd .. " " .. config_dir .. "/rc.lua"},
    { "theme", "lxappearance" },
    { "wallpaper", "nitrogen" }
}

mymainmenu = awful.menu({ items = {
            { "WEB", nil},
            { "  browser", browser },
            { "  mail", terminal .. " -e mutt" },
            { "  irc", terminal .. " -e irssi" },
            { "  news", terminal .. " -e newsbeuter" },
            { "TOOLS", nil},
            { "  music", terminal .. " -e ncmpcpp" },
            { "  terminal", terminal },
            { "preferences", mysettingsmenu },
            { "system", mysystemmenu },
            { "session", mysessionmenu },
          }
})

-- Menubar configuration
--menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

sep = wibox.widget.textbox()
sep:set_markup("<span color=\"" .. beautiful.border_focus .. "\"> ¦ </span>")

-- {{{ System Tray
mysystray = wibox.widget.systray()
-- }}}

-- {{{ Date
local dot = "<span color=\"" .. beautiful.fg_faded .. "\">.</span>"
local colon = "<span color=\"" .. beautiful.fg_faded .. "\">:</span>"
local cal_script = config_dir .. "/cal.sh"
local date_string = "%Y" .. dot .. "%m" .. dot .."<span color=\"" .. beautiful.fg_highlight .. "\">%d</span><span color=\"" .. beautiful.fg_focus .. "\">/</span><span color=\"" .. beautiful.fg_faded .. "\">%a</span> <span color=\"" .. beautiful.fg_highlight .. "\">%H"..colon.."%M</span> "
datewidget = awful.widget.textclock(date_string)
datewidget_t = awful.tooltip({
    objects = {datewidget},
    timer_function = function()
        return awful.util.pread(cal_script)
    end
})
datewidget_t:set_timeout(60)
-- }}}

-- {{{ Memory
local memwidget = widget(vicious.widgets.mem, "$1", 13, {
    icon = beautiful.icons.mem, 
    min_width = 30,
    tooltip = function()
        return awful.util.pread("free -m"):gsub("^([^\n]+)\n", "<span color=\"" .. beautiful.fg_highlight .. "\">%1</span>\n", 1)
    end
})

-- }}}

-- {{{ CPU
local cpuwidget = widget(vicious.widgets.cpu, "$1", 2, {
    icon = beautiful.icons.cpu,
    min_width = 30,
    tooltip = function()
        local text = awful.util.pread("ps --cols 100 --sort -pcpu -e -o \"%cpu,rss,pid,command\" | head -20")
        text = awful.util.escape(text)
        text = text:gsub("^([^\n]+)\n", "<span color=\"" .. beautiful.fg_highlight .. "\">%1</span>\n", 1)
        return text
    end
})
-- }}}
local tempwidget  = widget(vicious.widgets.thermal, "$1", 17, "thermal_zone0", {
    icon = beautiful.icons.temp,
    min_width = 30,
    tooltip = function()
        return awful.util.pread("acpi -tf")
    end
})
-- }}}

-- {{{ Volume
local volwidget  = widget(vicious.widgets.volume, "$1$2", 67, "Master", {
    icon = beautiful.icons.spkr_01,
    tooltip = function()
        return awful.util.pread("amixer get Master")
    end
})
-- }}}

-- {{{ Battery
local batwidget  = widget(vicious.widgets.bat, "$2$1", 61, "BAT0", {
    icon = beautiful.icons.bat_full_02,
    tooltip = function()
        return awful.util.pread("acpi -b")
    end
})
-- }}}

-- {{{ Drives
local fswidget = widget(vicious.widgets.fs, "${/ used_p}<span color=\"" ..
beautiful.fg_faded ..  "\">r</span> ${" ..  home_dir .. " used_p}<span color=\"" ..
beautiful.fg_faded .. "\">h</span> ${/var used_p}<span color=\"" ..
beautiful.fg_faded .. "\">v</span>", 59, "BAT0", {
    icon = beautiful.icons.fs_02,
    tooltip = function()
        local text = awful.util.pread("df -lh -x tmpfs -x devtmpfs -x rootfs")
        text = awful.util.escape(text)
        text = text:gsub("^([^\n]+)\n", "<span color=\"" .. beautiful.fg_highlight .. "\">%1</span>\n", 1)
        return text
    end
})
-- }}}

-- {{{Net
netwidget = widget(vicious.widgets.net,
    function (widget, args)
        return string.format("% 4d<span color=\"" .. beautiful.fg_faded .. "\">u </span>% 5d<span color=\"" .. beautiful.fg_faded .. "\">d</span>", args["{eth0 up_kb}"] + args["{wlan0 up_kb}"], args["{eth0 down_kb}"] + args["{wlan0 down_kb}"])
    end, 3, {
    icon = beautiful.icons.net_wired,
    tooltip = function()
        local essid = awful.util.pread("iwgetid --raw")
        if essid == "" then
            return awful.util.escape(awful.util.pread("ip addr"))
        else
            return awful.util.escape("Wireless: " .. essid .. awful.util.pread("ip -o -f inet addr"))
        end
    end
})
-- }}}

--[[ {{{ Mail
mailwidget = wibox.widget.textbox()
mailwidget.bg_image = image(beautiful.icons.mail)
mailwidget:margin({left = 10, right = 6})
mailwidget.bg_align = "middle"
mailwidget:buttons(awful.util.table.join(
                        awful.button({ }, 1, function ()
                            vicious.force({mailwidget})
                        end
                        )))

mailwidget_t = awful.tooltip({
    objects = {mailwidget},
    timer_function = function()
        local text = ""
        for i, m in mail.iter() do
            text = text .. string.format("<span color=\"%s\">%s</span>:\n    %s\n", beautiful.fg_highlight, encode(m["from"]), encode(m["subject"]))
        end
        if text == "" then
            return "No new mail."
        else
            return text
        end
    end
})
mailwidget_t:set_timeout(60)
vicious.register(mailwidget, mail.widget, "$1", 11)
-- }}} ]]

-- {{{ Weather
weatherwidget = widget(vicious.widgets.weather, "${tempf} ${sky}", 600, "KBOS", {
    icon = beautiful.icons.dish
})

-- }}}

-- {{{ News
--[[

newswidget = wibox.widget.textbox()
newswidget.bg_image = image(beautiful.icons.info_02)
newswidget:margin({left = 10, right = 6})
newswidget.bg_align = "middle"
newswidget:buttons(awful.util.table.join(
                        awful.button({ }, 1, function ()
                            vicious.force({newswidget})
                        end
                        )))
newswidget_t = awful.tooltip({
    objects = {newswidget},
    timer_function = function()
        local news = newsbeuter.list()
        if news == "" then
            return "No news."
        else
            return encode(news)
        end
    end
})
vicious.register(newswidget, newsbeuter.widget, "$1", 11)
--]]
-- }}}

--[[ {{{ MPD
musicwidget = music.widget("{artist} - {title}",
                           "<span color=\"" .. beautiful.fg_highlight .. "\">Music - {state}</span>\n Title: {title}\n Artist: {artist}\n Album: {album}",
                       {
                           pause = image(beautiful.icons.pause),
                           play = image(beautiful.icons.play)
                       })
musicwidget.width = 400
-- }}} ]]



mywibox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )


for s = 1, screen.count() do
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.noempty, mytaglist.buttons)
    -- Min width.
    local old_fit = mytaglist[s].fit
    mytaglist[s].fit = function(...)
        x, y = old_fit(...)
        return math.max(x, 500), y
    end

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 16, border_width = 1, border_color = "#222222", fg = "#999999" })

    local layout = wibox.layout.align.horizontal()

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylayoutbox[s])
    left_layout:add(mytaglist[s])
    layout:set_left(left_layout)

    if s == 1 then
        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(datewidget)
        right_layout:add(mysystray)

        local center_layout = wibox.layout.fixed.horizontal()
        center_layout:add(cpuwidget)
        center_layout:add(memwidget)
        center_layout:add(tempwidget)
        center_layout:add(batwidget)
        center_layout:add(sep)
        center_layout:add(fswidget)
        center_layout:add(sep)
        center_layout:add(netwidget)
        center_layout:add(sep)
        center_layout:add(volwidget)
        center_layout:add(sep)
        center_layout:add(weatherwidget)

        -- Now bring it all together (with the tasklist in the middle)
        layout:set_middle(center_layout)
        layout:set_right(right_layout)
    end

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    --awful.button({ }, 2, function () wicd.toggle() end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

globalkeys = awful.util.table.join(
    -- Custom
    awful.key({}, "F12", function () quake_console:toggle() end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "p",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "n",  awful.tag.viewnext       ),
    awful.key({ "Control", "Mod1" }, "Left",   awful.tag.viewprev       ),
    awful.key({ "Control", "Mod1" }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey, "Control" }, "r", awesome.restart),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, ".", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey,           }, ",", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "Right",   function (c)
        screen = mouse.screen
        i = awful.tag.getidx(awful.tag.selected(screen))+1
        if i > #tags[screen] then
            i = 1
        end
        tag = tags[screen][i]
        awful.client.movetotag(tag)
        awful.tag.viewonly(tag)
    end),
    awful.key({ modkey, "Shift"   }, "Left",   function (c)
        screen = mouse.screen
        i = awful.tag.getidx(awful.tag.selected(screen))-1
        if i == 0 then
            i = #tags[screen]-1
        end
        tag = tags[screen][i]
        awful.client.movetotag(tag)
        awful.tag.viewonly(tag)
    end),
    awful.key({ modkey,           }, "a",      function (c) c.ontop = not c.ontop end),
    awful.key({ modkey,           }, "s",      function (c) c.sticky = not c.sticky end),
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Control", "Shift" }, "j",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Control", "Shift" }, "k",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     maximized_vertical = false,
                     maximized_horizontal = false,
                     minimized = false,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "mplayer2" },
      properties = { floating = true } },
    { rule = { type = "dialog" },
      properties = {
          opacity = 0.95,
          focus = true,
          floating = true,
          ontop = true

      } },
    { rule = { class = "gcr-prompter" },
      properties = { focus = true, floating = true, ontop = true },
      callback = awful.placement.centered },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Firefox", name="Downloads" },
       callback = awful.client.setslave },
    -- Preferences should float
    { rule = { name = "Preferences" },
       properties = { floating = true, focus = true } },
    { rule_any = { class = { "Qalculate-gtk", "Pidgin", "Oblogout" } },
       properties = { floating = true} },
    { rule = { class = "URxvt"},
       properties = {size_hints_honor = false } },
    { rule = { class = "XTerm"},
       properties = { size_hints_honor = false } },
    { rule = { name = "tilda" },
       properties = { floating = true, ontop = true, focus = true } },
    { rule = { class = "Display" },
       properties = { floating = true, ontop = true, focus = true },
       callback = awful.placement.centered,
    },
    { rule = { title = "Download Manager" },
       properties = { floating = true, ontop = true } },
    { rule = { class = "Eclipse", name="Commit" },
       properties = { floating = false },
       callback = awful.client.setslave },
    { rule = { class = "Pithos", name = "Pithos"},
      callback = function(c)
          awful.client.setslave(c)
          c:geometry({width = 400})
      end,
    },
    { rule = { class = "Conky" },
       properties = { tag = tags[1][1], switchtotag = false, floating = true } },
    { rule = { class = "Conky", name="Main" },
      callback = function(c)
          c:struts( { top = 15 } )
      end
    },
    { rule = { class = "Conky", name = "Sidebar" },
       callback = function(c)
            c:struts( { left = 130 } )
          end
    },
    { rule_any = { class = { "Kupfer", "Keepass" } },
       properties = { floating = true },
       callback = awful.placement.centered },
    -- GIMP
    { rule = { role = "gimp-toolbox" },
      properties = {
          floating = false,
          keys = awful.util.table.join(
            awful.key({ "Mod1" }, "F4", function (c) return true end))
        },
      callback = awful.client.setslave },
    { rule = { class = "gimp" },
      properties = { floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)
    c:connect_signal("property::minimized", function(c)
        if c.minimized then
            c.minimized = false
        end
    end)
    
    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)
-- }}}

-- {{{ Notifications
naughty.config.timeout          = 10
naughty.config.presets.normal.screen           = 1
naughty.config.presets.normal.position         = "top_right"
naughty.config.presets.normal.margin           = 4
naughty.config.presets.normal.gap              = 1
naughty.config.presets.normal.ontop            = true
naughty.config.presets.normal.icon             = nil
naughty.config.presets.normal.icon_size        = 16
naughty.config.presets.normal.border_width     = 1
naughty.config.presets.normal.hover_timeout    = nil
naughty.config.presets.normal.bg               = '#111111'
naughty.config.presets.normal.border_color     = '#333333'
naughty.config.presets.critical.bg = '#991000cc'

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
