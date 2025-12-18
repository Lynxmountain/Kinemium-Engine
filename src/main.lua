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
local Kinemium_env = require("./enviroment/get")
local threads = { internals = {}, game = {} }
local Kinemium = {}

local renderer = require("@Kinemium.3d")
Kinemium_env = Kinemium_env(renderer)

--local raygui = require("@raygui")

sandboxer.enviroment = Kinemium_env

local game = Kinemium_env.game

renderer.DatamodelObject(game)

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
Folder.Parent = sandboxer.enviroment.game.CoreGui

loop("src/sandboxed/internals", function(path, entry)
	if threads.internals[path] then
		return
	end
	if threads.game[path] then
		return
	end
	sandboxer.enviroment.SecurityCapabilities = sandboxer.enviroment.Enum.SecurityCapabilities.Internals
	print("Running internal:", path)
	threads.internals[path] = sandboxer.thread.new(path, entry, sandboxer.enviroment)

	local luauCleaned = string.gsub(entry.name, ".luau", "")
	local luaCleaned = string.gsub(luauCleaned, ".lua", "")

	local object = Instance.new("LocalScript")
	object.Source = filesystem.read(path)
	object.Name = luaCleaned
	object.Parent = Folder
end)

function Kinemium:playtest()
	loop("src/sandboxed", function(path, entry)
		if threads.internals[path] then
			return
		end
		if threads.game[path] then
			return
		end
		sandboxer.enviroment.SecurityCapabilities = sandboxer.enviroment.Enum.SecurityCapabilities.UserScript
		print("Running game:", path)
		threads.game[path] = sandboxer.thread.new(path, entry, sandboxer.enviroment)
	end)
end

renderer.Kinemium_camera.Parent = sandboxer.enviroment.workspace

game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

Kinemium:playtest()
renderer.Run()
