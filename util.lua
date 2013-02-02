local wibox = wibox
local vicious = vicious

return {
    widget = function(...)
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

        local update = function()
            vicious.force(w)
        end

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

        w.update = update
        return w
    end,
    encode = function(s)
        if s then
            return s:gsub("(.)", function(c)
                return string.format("&#%d;", string.byte(c))
            end)
        else
            return ""
        end
    end
}
