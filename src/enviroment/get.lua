local datatypes = require("@kinetica.datatypes.get")
local Registry = require("@kinetica.registry")
local DataModel = require("@DataModel")
local EnumMap = require("@EnumMap")
local PlayerGui = require("@PlayerGui")
local sandboxer = require("@sandboxer")

return function(renderer)
	local mainDatamodel = DataModel.new(renderer, { "StarterGui" })
	local data = datatypes

	local shared = {}
	local _G = {}

	data.Instance = {
		new = function(class)
			return Registry.new(class, renderer)
		end,
	}
	data.Enum = EnumMap
	data.task = zune.task
	data.game = mainDatamodel
	data.workspace = mainDatamodel:GetService("Workspace")
	data.shared = shared
	data._G = _G
	data.wait = zune.task.wait
	data.kinetica = {
		version = 1.0,
		window = require("@kinetica.window")(renderer.lib),
		--jolt = require("@kinetica.jolt"),
	}
	data.require = function(Instance)
		if type(Instance) == "table" then
			if Instance.ClassName == "ModuleScript" then
				local source = Instance.Source
				local returned = sandboxer.run(source, nil)
				if returned then
					return returned
				end
			end
		elseif type(Instance) == "string" then
			error("Cannot require string")
		end
	end
	data.typeof = function(v)
		print("Someone used me.")
	end

	local players = mainDatamodel:GetService("Players")
	players.LocalPlayer.PlayerGui = PlayerGui.InitRenderer(renderer, renderer.Signal)

	renderer.SetLightingService(mainDatamodel:GetService("Lighting"))
	return data
end
