-- {{{ Grab environment
local setmetatable = setmetatable
local awesome = awesome
local sqlite3 = require("lsqlite3")
local patient = require("patient")
local os = {
    getenv = os.getenv
}
-- }}}


module("newsbeuter")


-- {{{ Init
local DB_FILE = os.getenv("XDG_DATA_HOME") .. "/newsbeuter/cache.db"

local COUNT_STMT = "SELECT COUNT(*) FROM rss_item WHERE unread=1"
local LIST_STMT = "SELECT \"title\" FROM rss_item WHERE unread=1"

-- }}}

local count = 0
local iwatch


local function update_count()
    local db = sqlite3.open(DB_FILE)
    local f,v = db:urows(COUNT_STMT)
    count = f(v)
    db:close()
end

widget = function(format, warg)
    if not iwatch then
        iwatch = patient.watch({[DB_FILE] = {"IN_MODIFY"}})
        update_count()
    elseif iwatch:changed() then
        update_count()
    end
    return {count}
end

list = function()
    local text = "News:"
    local db = sqlite3.open(DB_FILE)
    for l in db:urows(LIST_STMT) do
        if l:len() > 100 then
            text = text .. "\n " .. l:sub(0, 100) .. "..."
        else
            text = text .. "\n " .. l
        end
    end
    db:close()
    return text
end



