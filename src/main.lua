_G.warn = function(...)
	print("[\x1b[33mWARN\x1b[0m]", ...)
end

_G.FlagExists = function(flag)
	local args = zune.process.args
	for _, v in pairs(args) do
		if v == "--" .. flag then
			return true
		end
	end
	return false
end

local sandboxer = require("./modules/sandboxer")
local Instance = require("@Instance")
local filesystem = require("./modules/filesystem")
local Enum = require("@EnumMap")
local kilang = require("@kilang")
local task = zune.task
local Kinemium = {}

local dummy = require("./renderer/dummy")

local renderer

if FlagExists("client") then
	_G.IsClient = true
	_G.IsServer = false
elseif FlagExists("server") then
	kilang.renderer = dummy

	_G.IsServer = true
	_G.IsClient = false

	print("Running engine headless mode (Server).")
end

if FlagExists("headless") or FlagExists("cli") then
	kilang.renderer = dummy
	_G.IsHeadless = true
else
	kilang.renderer = require("@Kinemium.3d")
end

kilang:init()

local game = kilang.env.game
kilang.renderer.DatamodelObject(game)

local function loop(base, callback)
	base = base or "src/sandboxed"
	filesystem.entryloop(base, function(entry)
		local path = base .. "/" .. entry.name

		if entry.kind == "directory" then
			loop(path, callback)
		else
			callback(path, entry)
		end
	end)
end

local Folder = Instance.new("Folder")
Folder.Name = "Studio"
Folder.Parent = kilang.env.game.CoreGui

loop("src/sandboxed/internals", function(path, entry)
	if kilang.threads[path] then
		return
	end

	local code = zune.fs.readFile(path)
	kilang:execute(code, {
		SecurityCapabilities = Enum.SecurityCapabilities.Internals,
		StackId = path,
	})

	local luauCleaned = string.gsub(entry.name, ".luau", "")
	local luaCleaned = string.gsub(luauCleaned, ".lua", "")

	local object = Instance.new("LocalScript")
	object.Source = filesystem.read(path)
	object.Name = luaCleaned
	object.Parent = Folder
end)

function Kinemium:playtest()
	loop("src/sandboxed", function(path, entry)
		if kilang.threads[path] then
			return
		end

		local code = filesystem.read(path)
		kilang:execute(code, {
			SecurityCapabilities = Enum.SecurityCapabilities.UserScript,
			StackId = path,
		})
	end)
end

kilang.renderer.Kinemium_camera.Parent = sandboxer.enviroment.Scene

game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

if FlagExists("kilang") then
	require("./repl"):init(function(line)
		task.spawn(function()
			local success, result = pcall(function(...)
				kilang:execute(line, {
					SecurityCapabilities = Enum.SecurityCapabilities.Internals,
				})
			end)
		end)
	end)
end

Kinemium:playtest()

kilang.renderer.Run()
