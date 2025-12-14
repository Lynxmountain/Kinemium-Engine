local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")

local propTable = {
	Name = "Script",
	Source = [[
		print("Hello Kinemium!");
	]],
	RunContext = Enum.RunContext.Server,
	Language = Enum.Language.Luau,
}

return {
	class = "Script",
	callback = function(instance)
		instance:SetProperties(propTable)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
