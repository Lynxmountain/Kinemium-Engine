local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")

local propTable = {
	FieldOfView = 70,
	CFrame = CFrame.new(0, 0, 0),
	Name = "Camera",
	CameraType = "Fixed",
	CameraSubject = nil,
	Focus = CFrame.new(0, 0, 0),
}

return {
	class = "Camera",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)

		instance.Position = instance.CFrame.Position

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
