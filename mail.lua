--[[
To use this widget, change MAIL_DIR and register mail.widget with vicious. To
reduce disk-io, this plugin will only update the unread mail count when files
are created/moved/removed in the new mail directories under MAIL_DIR.

    iter()      Returns an iterator that iterates over new mail and outputs the
                current iteration and a table with each email's from address and
                subject line.

    count()     Returns the number of new messages.

    widgit      The widgit worker function for vicious.

    MAIL_DIR    The directory under which your maildirs live.
                New mail folders must match this pattern:
                MAIL_DIR/*/INBOX/new

Licenced under the WTFPL.
--]]

-- {{{ imports
local table = require "table"
local string = require "string"
local os = require "os"
local io = require "io"
local lfs = require "lfs"
local b64 = require "base64"
local next = next
local ipairs = ipairs
local notify = naughty.notify
local patient = require("patient")
-- }}}

module("mail")

MAIL_DIR = os.getenv("HOME") .. "/.mail/"

-- {{{ Setup
local nmdirs = {}
local nmcount = 0
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
    if string.find(val, "^=\?.*\?.*=") ~= nil then
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
            "IN_CREATE",
            "IN_DELETE",
            "IN_MOVED_TO",
            "IN_MOVED_FROM"
        }
    end
    return patient.watch(to_watch)
end
-- }}}


iter = function()
    local cdir_iter = function(a, b) end
    local cdir_meta
    return function(t, i)
        local f
        repeat
            f = cdir_iter(cdir_meta)
            if f == nil then
                i, d = next(t, i)
                if d == nil then
                    return
                else
                    cdir_iter, cdir_meta = lfs.dir(d)
                end
            end
        until f ~= nil and isFile(d .. '/' .. f)
        return i, parseFile(d .. '/' .. f)
    end, nmdirs, nil
end

local update_count = function()
    local c = 0
    for i,d in ipairs(nmdirs) do
        for f in lfs.dir(d) do
            if isFile(d .. '/' .. f) then
                c = c + 1
            end
        end
    end
    if c > nmcount then
        notify({title = "New Mail", text = "You have " .. (c - nmcount) .. " new messages."})
    end
    nmcount = c
end




count = function()
    if not iwatch then
        iwatch = beginWatch()
        update_count()
    elseif iwatch:changed() then
        update_count()
    end
    return nmcount
end

widget = function(format, warg)
    return {count()}
end

-- vim: foldmethod=marker:filetype=lua
