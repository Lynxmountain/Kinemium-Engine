local Vector3 = require("@Vector3")
local Enum = require("@EnumMap")

local propTable = {
	Attachment0 = nil,

	Force = Vector3.new(0, 0, 0),
	RelativeTo = Enum.ActuatorRelativeTo.World,

	Enabled = true,
	Name = "VectorForce",
	ElapsedTime = 0,
}

return {
	class = "VectorForce",

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
