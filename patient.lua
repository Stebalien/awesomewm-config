local ipairs = ipairs
local pairs = pairs
local table = table
local inotify = require("inotify")

module("patient")

local changed = function(w, file)
    local events = w.inot:nbread()
    if events then
        if file then
            local wd = w.files[file]
            for i, event in ipairs(events) do
                if event.wd == w.files[file].wd then
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
    local events = w.inot:nbread()
    local changed = {}
    if events then
        for i, event in ipairs(events) do
            for file, wd in pairs(w.files) do
                if event.wd == wd then
                    table.insert(changed, file)
                    break
                end
            end
        end
    end
    return changed
end


watch = function(files)
    local w = {}
    w.inot = inotify.init(true)
    w.files = {}
    for file, events in pairs(files) do
        w.files[file] = w.inot:add_watch(file, events)
    end
    w.changed = changed
    w.changed_files = changed_files
    return w
end


