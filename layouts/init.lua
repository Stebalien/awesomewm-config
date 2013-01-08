
local layouts = { _NAME = "layouts" }
return setmetatable(layouts, {
    __index = function(table, key)
        local module = rawget(table, key)
        return module or require(table._NAME .. "." .. key)
    end
})
