--[[
An mpd backend for the awesome music framework.

Unlike other implimentations, this does not poll mpd.
--]]
local socket = require("socket")
local setmetatable = setmetatable
local capi = { widget = widget,
               button = awful.button,
               escape = awful.util.escape,
               join = awful.util.table.join,
               tooltip = awful.tooltip,
               timer = timer,
               emit_signal = awesome.emit_signal,
               add_signal = awesome.add_signal }
local coroutine = coroutine


-- Mpd: provides Music Player Daemon information
module("mpd")


HOST    = "127.0.0.1"
PORT    = 6600
PASSWORD= nil

local state
local reset = function()
    state = {}
    setmetatable(state, {__index = function() return "N/A" end})
end
reset()

local clear = function(sock)
    local buffer
    repeat
        buffer = sock:receive("*l")
        if not buffer then
            return false
        end
    until buffer:sub(0,2) == "OK"
    return true
end

local cmd = function(sock, command)
    if command then
        sock:send(command .. "\n")
    end
    local buffer = sock:receive("*l")
    if buffer and buffer:sub(0,2) == "OK" then
        return true
    end
    return false
end

    

local connect = function()
    sock = socket.tcp()
    sock:settimeout(1)
    sock:connect(HOST, PORT)
    if not cmd(sock) then
        sock:close()
        return nil
    end
    if PASSWORD and not cmd(sock, "password " .. PASSWORD) then
        sock:close()
        return nil
    end
    return sock
end


local refresh_co = function()
    s = connect()
    if s == nil then
        state = {}
        capi.emit_signal("music::update")
        return
    end
    local buffer, err
    while true do
        s:send("command_list_begin\nstatus\ncurrentsong\ncommand_list_end\n")

        while true do
            buffer,err = s:receive("*l")
            if err == "timeout" then
                coroutine.yield()
            elseif not buffer then
                state = {}
                capi.emit_signal("music::update")
                return
            elseif buffer:sub(0,2) == "OK" then
                break
            else
                for k, v in buffer:gmatch("([%w]+):[%s](.*)$") do
                    state[k:lower()] = capi.escape(v)
                end
            end
        end
        capi.emit_signal("music::update")

        s:settimeout(0)
        s:send("idle player\n")
        repeat
            buffer,err = s:receive("*l")
            if err == "timeout" then
                coroutine.yield()
            elseif not buffer then
                state = {}
                capi.emit_signal("music::update")
                return
            end
        until buffer and buffer:sub(0,2) == "OK"
        s:settimeout(1)
    end
end

-- Default watcher to return false
local watcher = nil
local timer = capi.timer({timeout = 2})

local refresh = function()
    if not watcher or not coroutine.resume(watcher) then
        watcher = coroutine.create(refresh_co)
    end
end
timer:add_signal("timeout", refresh)

start = function()
    reset()
    timer:start()
    capi.emit_signal("music::update")
end

stop = function()
    timer:stop()
    pause()
end


-- {{{ Actions

next = function()
    local s = connect()
    if not s then return end
    cmd(s, "next")
    s:close()
    refresh()
end

prev = function()
    local s = connect()
    if not s then return end
    cmd(s, "previous")
    s:close()
    refresh()
end

toggle = function()
    local s = connect()
    if not s then return end
    refresh()
    if state["state"] == "play" then
        cmd(s, "pause 1")
    else
        cmd(s, "pause 0")
    end
    s:close()
    refresh()
end

play = function()
    local s = connect()
    if not s then return end
    cmd(s, "pause 0")
    s:close()
    refresh()
end

pause = function()
    local s = connect()
    if not s then return end
    cmd(s, "pause 1")
    s:close()
    refresh()
end

remove = function()
    local s = connect()
    if not s then return end
    cmd(s, "delete 0")
    s:close()
    refresh()
end

get = function(item)
    return state[item]
end

isPlaying = function()
    return state["state"] == "play"
end
    
    
    
-- }}}
