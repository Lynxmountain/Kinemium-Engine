_G.warn = function(...)
	print("[\x1b[33mWARN\x1b[0m]", ...)
end

local sandboxer = require("./modules/sandboxer")
local filesystem = require("./modules/filesystem")
local Instance = require("@Instance")
local ModuleScript = require("@ModuleScript")
local Kinemium_env = require("./enviroment/get")
local task = zune.task
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
			-- Call your callback for this file
			callback(path, entry)
		end
	end)
end

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
