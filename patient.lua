local ipairs = ipairs
local pairs = pairs
local table = table
local inotify = require("inotify")

local module = {}

local changed = function(w, file)
    local events = w.inot:read()
    if events and #events > 0 then
        if file then
            for i, event in ipairs(events) do
                if w.watches[event.wd] == file then
                    return true
                end
            end
            return false
        end
        return true
    end
    return false
end

local changed_files = function(w)
    local changed = {}
    for i, event in ipairs(w.inot:events()) do
        table.insert(changed, w.watches[event.wd])
    end
    return changed
end


module.watch = function(files)
    local w = {}
    w.inot = inotify.init{blocking = false}
    w.watches = {}
    for file, events in pairs(files) do
        w.watches[w.inot:addwatch(file, unpack(events))] = file
    end
    w.changed = changed
    w.changed_files = changed_files
    return w
end

for k,v in pairs(inotify) do
    if k:sub(0,3) == 'IN_' then
        module[k] = v
    end
end

setmetatable(module, { __call = function(_, ...) return module.watch(...) end })

return module
