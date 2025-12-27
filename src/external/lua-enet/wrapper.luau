local lua = require("@lua")
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

local enetDir = getPath("src/external/lua-enet")
local vm = lua.LuaVM.new()

print(enetDir)

local success, _, err = vm:execute(string.format(
	[[
		package.cpath = package.cpath .. ";%s/bin/?.dll"
		package.path  = package.path  .. ";%s/?.lua"

		_G.enet = require("enet")
	]],
	enetDir,
	fileFormat,
	enetDir
))

if not success then
	error(err)
end

if not success then
	error(err)
end

local wrapper = {}

function wrapper:InitServer(address)
	address = address or "localhost:6789"

	local ok, err = vm:execute(string.format(
		[[
		if _G.__enet_host then return end

		_G.__enet_host = enet.host_create("%s")
		assert(_G.__enet_host, "Failed to create ENet host")
	]],
		address
	))

	if not ok then
		error(err)
	end
end

function wrapper:Service(timeout)
	timeout = timeout or 0

	local ok, err = vm:execute(string.format(
		[[
		local host = _G.__enet_host
		if not host then return end

		local event = host:service(%d)
		if event and event.type == "receive" then
			print("[enet] recv:", event.data)
			event.peer:send(event.data)
		end
	]],
		timeout
	))

	if not ok then
		error(err)
	end
end

function wrapper:Shutdown()
	vm:execute([[
		if _G.__enet_host then
			_G.__enet_host:destroy()
			_G.__enet_host = nil
		end
	]])
end

return wrapper
