local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local GuiObject = require("@GuiObject")
local Enum = require("@EnumMap")

local propTable = {
	Name = "Frame",
	AbsoluteSize = nil,
	AbsolutePosition = nil,
}

GuiObject.inherit(propTable)

return {
	class = "Frame",
	render = function(lib, object, dt, structs, renderer)
		local pos, size = GuiObject.render(lib, object, dt, structs, renderer)
		object.AbsolutePosition = pos
		object.AbsoluteSize = size
		return pos, size
	end,
	callback = function(instance, renderer)
		return GuiObject.callback(instance, renderer)
	end,
	inherit = function(tble)
		GuiObject.inherit(tble)
	end,
}
