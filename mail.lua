--[[
To use this widget, change MAIL_DIR and register mail.widget with vicious. To
reduce disk-io, this plugin will only update the unread mail count when files
are created/moved/removed in the new mail directories under MAIL_DIR.

    count()     Returns the number of new messages.

    widgit      The widgit worker function for vicious.

    MAIL_DIR    The directory under which your maildirs live.
                New mail folders must match this pattern:
                MAIL_DIR/*/INBOX/new

Licenced under the WTFPL.
--]]

-- {{{ imports
local table = require("table")
local string = require("string")
local os = require("os")
local io = require("io")
local lfs = require("lfs")
local b64 = require("base64")
local next = next
local ipairs = ipairs
local notify = naughty.notify
local patient = require("patient")
-- }}}


MAIL_DIR = os.getenv("HOME") .. "/.mail/"

-- {{{ Setup
local nmdirs = {}
local nmcount = 0
local nmlist = {}
local iwatch

for d in lfs.dir(MAIL_DIR) do
    local nmdir = MAIL_DIR .. d .. "/INBOX/new"
    if string.sub(d, 1, 1) ~= '.' and lfs.attributes(nmdir, "mode") == "directory" then
        table.insert(nmdirs, nmdir)
    end
end
-- }}}

-- {{{ Helpers
local decode = function(val)
    if string.find(val, "^=?.*?.*=") ~= nil then
        return b64.decode(val)
    else
        return val
    end
end

local parseFile = function(file)
    local e = {subject="(none)", from="Anonymous"}
    local i = 0
    for line in io.lines(file) do
        if string.sub(line, 1, 6) == "From: " then
            e["from"] = decode(string.sub(line, 7, -1))
            i = i + 1
        elseif string.sub(line, 1, 9) == "Subject: " then
            e["subject"] = decode(string.sub(line, 10, -1))
            i = i + 1
        end
        if i == 2 then
            break
        end
    end
    return e
end

local isFile = function(file)
    return lfs.attributes(file, "mode") == "file"
end

local beginWatch = function()
    local to_watch = {}
    for i,d in ipairs(nmdirs) do
        to_watch[d] = {
            patient.IN_CREATE,
            patient.IN_MOVED_TO,
            patient.IN_MOVED_FROM,
        }
    end
    return patient(to_watch)
end
-- }}}


local memo_list = function(l)
    nmlist = l
end

local do_list = function()
    local l = {}
    for i,d in ipairs(nmdirs) do
        for f in lfs.dir(d) do
            local fpath = d .. "/" .. f
            if isFile(fpath) then
                table.insert(l, parseFile(fpath))
            end
        end
    end
    return l
end

local memo_count = function(c)
    if c > nmcount then
        notify({title = "New Mail", text = "You have " .. (c - nmcount) .. " new messages."})
    end
    nmcount = c
end

local list = function()
    if not iwatch then
        iwatch = beginWatch()
        local l = do_list()
        memo_list(l)
        memo_count(#l)
    elseif nmlist == nil or iwatch:changed() then
        local l = do_list()
        memo_list(l)
        memo_count(#l)
    end
    return nmlist
end

local do_count = function()
    local c = 0
    for i,d in ipairs(nmdirs) do
        for f in lfs.dir(d) do
            if isFile(d .. '/' .. f) then
                c = c + 1
            end
        end
    end
    return c
end

local count = function()
    if not iwatch then
        iwatch = beginWatch()
        memo_count(do_count())
        nmlist = nil
    elseif iwatch:changed() then
        memo_count(do_count())
        nmlist = nil
    end
    return nmcount
end

local widget = function(format, warg)
    return {count()}
end

local module = {
    widget = widget,
    count = count,
    list = list,
}
setmetatable(module, { __call = function(_, ...) return module.widget(...) end })

return module

-- vim: foldmethod=marker:filetype=lua
