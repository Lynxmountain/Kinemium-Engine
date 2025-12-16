local luajit = require("@luajit")
local vm = luajit.LuaVM.new()
local wrapper = {}
local process = zune.process
local platform = zune.platform

local function getPath(destination)
	local src = process.cwd() .. "/" .. destination
	src = string.gsub(src, [[\]], "/")
	return src
end

local fileFormat = ""

if platform == "windows" then
	fileFormat = "dll"
elseif platform == "macos" then
	fileFormat = "dylib"
elseif platform == "linux" then
	fileFormat = "so"
end

local discordDir = getPath("src/external/discordrpc")

local success, lib, result = vm:execute(string.format(
	[[
     package.cpath = package.cpath .. ";%s/?.%s;%s/discord-rpc.%s"
     package.path = package.path .. ";%s/?.lua"
     local main = require("discordRPC")
     _G.rpc = main
     
     main.initialize("1450043126445113408", true)
     
     return main
]],
	discordDir,
	fileFormat,
	discordDir,
	fileFormat,
	discordDir
))

warn(success, lib, result)

function wrapper:UpdatePresence(options)
	assert(type(options) == "table", "options must be a table")

	print(options)
	local state = options.state or ""
	local details = options.details or ""
	local largeText = options.largeImageText or ""
	local smallText = options.smallImageText or ""
	local partySize = tonumber(options.partySize) or 0
	local partyMax = tonumber(options.partyMax) or 0

	vm:execute(string.format(
		[[
        local main = _G.rpc
        main.updatePresence({
            state = "%s",
            details = "%s",
            startTimestamp = os.time(),
            largeImageKey = "logo_large",
            largeImageText = "%s",
            smallImageKey = "logo_small",
            smallImageText = "%s",
            partySize = %d,
            partyMax = %d,
       })
    ]],
		state,
		details,
		largeText,
		smallText,
		partySize,
		partyMax
	))
end

return wrapper
