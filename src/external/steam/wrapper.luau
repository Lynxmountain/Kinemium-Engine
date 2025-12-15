local lua = require("@luajit")
local vm = lua.LuaVM.new()
local platform = zune.platform.os

local scriptDir = debug.getinfo(1, "S").source:match("@?(.*[/\\])")
local steamDir = scriptDir .. "steam"

local LIB_NAME = ""
if platform == "windows" then
	LIB_NAME = "luasteam"
elseif platform == "linux" then
	LIB_NAME = "luasteamlinux"
end

local success, lib, result = vm:execute(string.format(
	[[
    local steamDir = "%s"
    local libName = "%s"

    package.cpath = package.cpath .. ";" .. steamDir .. "/?.dll;" .. steamDir .. "/" .. libName .. ".dll"
    package.path = package.path .. ";" .. steamDir .. "/?.lua"

    local main = require(libName)
    _G.steam = main

    -- initialize Steam
    if main.init then
        main.init()
    end

    return main
]],
	steamDir,
	LIB_NAME
))

if not success then
	error("Failed to load Steam binding in VM: " .. tostring(result))
end

local wrapper = {}
wrapper.steam = lib

return wrapper
