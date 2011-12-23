local socket = require("socket")
local type = type
local setmetatable = setmetatable
local mpd = mpd
local pianobar = pianobar

local capi = { widget = widget,
               button = awful.button,
               escape = awful.util.escape,
               join = awful.util.table.join,
               menu = awful.menu,
               tooltip = awful.tooltip,
               timer = timer,
               emit_signal = awesome.emit_signal,
               add_signal = awesome.add_signal }
local coroutine = coroutine


-- Mpd: provides Music Player Daemon information
module("music")

local backend = nil

setBackend = function(b)
    if backend ~= nil then
        backend.stop()
    end
    backend = b
    backend.start()
end

setBackend(mpd)

widget = function(widget_template, tooltip_template, icon)
    local w = {
        icon = icon,
        widget_template = widget_template,
        tooltip_template = tooltip_template,
        widget = capi.widget({type = "textbox"})
    }
    if w.icon then
        w.widget.bg_image = w.icon.pause
        w.widget:margin({left = 10, right = 6})
        w.widget.bg_align = "middle"
    else
        w.widget:margin({right = 6})
    end
    
    w.backend_menu = capi.menu({ items = {
        {"mpd", function() setBackend(mpd) end},
        {"pianobar", function() setBackend(pianobar) end}
    }})

    w.widget:buttons(capi.join(
        capi.button({ }, 1, function () toggle() end),
        capi.button({ }, 3, function () w.backend_menu:toggle() end)
    ))
    w.tooltip = capi.tooltip({
        objects = {w.widget},
        timeout = 0
    })

    local update = function()
        w.widget.text = format(w.widget_template)
        w.tooltip:set_text(
            format(w.tooltip_template)
        )
        if w.icon then
            if isPlaying() then
                w.widget.bg_image = w.icon.play
            else
                w.widget.bg_image = w.icon.pause
            end
        end
    end
    capi.add_signal("music::update", update)
    update()
    return w.widget
end

format = function(template)
    if backend ~= nil then
        return template:gsub("{(%w+)}", backend.get)
    else
        return "Backend unset."
    end
end

isPlaying = function()
    if backend ~= nil then
        return backend.isPlaying()
    else
        return false
    end
end

next = function()
    if backend ~= nil then
        backend.next()
    end
end

prev = function()
    if backend ~= nil then
        backend.prev()
    end
end

toggle = function()
    if backend ~= nil then
        backend.toggle()
    end
end

play = function()
    if backend ~= nil then
        backend.play()
    end
end

pause = function()
    if backend ~= nil then
        backend.pause()
    end
end

remove = function()
    if backend ~= nil then
        backend.remove()
    end
end
    
-- }}}
