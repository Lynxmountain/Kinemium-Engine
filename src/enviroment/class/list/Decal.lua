local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")

local propTable = {
	Transparency = 0,
	Color3 = Color3.new(1, 1, 1),
	Texture = "./src/assets/materials/debug.png",
	ColorMapContent = "./src/assets/materials/debug.png",
}

return {
	class = "Decal",
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
