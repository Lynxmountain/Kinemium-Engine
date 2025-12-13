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
local luacss = "./src/rblx/luacss/init.luau"

local renderer = require("@Kinemium.3d")
Kinemium_env = Kinemium_env(renderer)

--local raygui = require("@raygui")

sandboxer.enviroment = Kinemium_env

local game = Kinemium_env.game

local function newThread(path, entry, env)
	if threads.internals[path] or threads.game[path] then
		return
	end -- Prevent double execution
	return sandboxer.newThread(path, entry, env)
end

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

--[[
sandboxer.rblxrequire(luacss, function(code, path)
	local scriptInstance = Instance.new("ModuleScript")
	ModuleScript.callback(scriptInstance)
	scriptInstance.Source = code

	local function processDirectory(dirPath, parentInstance)
		local entries = zune.fs.entries(dirPath)
		for _, entry in pairs(entries) do
			if entry.kind == "directory" then
				local folder = Instance.new("Folder")
				folder.Name = entry.name
				folder.Parent = parentInstance
				processDirectory(dirPath .. "/" .. entry.name, folder) -- recursive call
			elseif entry.kind == "file" and entry.name:match("%.lu[au]$") then
				local childModule = Instance.new("ModuleScript")
				ModuleScript.callback(childModule)

				childModule.Name = entry.name:gsub("%.lu[au]$", "")
				childModule.Source = zune.fs.readFile(dirPath .. "/" .. entry.name)
				childModule.Parent = parentInstance
			end
		end
	end

	processDirectory("./src/rblx/luacss", scriptInstance)

	return scriptInstance
end)
--]]

renderer.Kinemium_camera.Parent = sandboxer.enviroment.workspace

game.EngineSignal:Connect(function(route)
	if route == "playtest" then
		Kinemium:playtest()
	end
end)

Kinemium:playtest()
print(threads)
renderer.Run()
