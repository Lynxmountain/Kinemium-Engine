local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")

local propTable = {
	CelestialBodiesShown = true,
	StarCount = 3000,
	SunAngularSize = 21,
	MoonAngularSize = 21,
	SkyboxBk = "",
	SkyboxDn = "",
	SkyboxFt = "",
	SkyboxLf = "",
	SkyboxRt = "",
	SkyboxUp = "",
	SkyboxBkColor = Color3.new(1, 1, 1),
	SkyboxDnColor = Color3.new(1, 1, 1),
	SkyboxFtColor = Color3.new(1, 1, 1),
	SkyboxLfColor = Color3.new(1, 1, 1),
	SkyboxRtColor = Color3.new(1, 1, 1),
	SkyboxUpColor = Color3.new(1, 1, 1),
	SunTextureId = "",
	MoonTextureId = "",
}

return {
	class = "Sky",
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
