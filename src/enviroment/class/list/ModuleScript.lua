local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")

local propTable = {
	Name = "ModuleScript",
	Source = [[]],
	RunContext = Enum.RunContext.Client,
}

return {
	class = "ModuleScript",
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
