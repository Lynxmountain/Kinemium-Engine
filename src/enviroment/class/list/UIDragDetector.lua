local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")
local raylib = require("@raylib")

local aereon = require("@Kinemium.Aereon")
local arect = aereon.rect()

local propTable = {
	Name = "UIDragDetector",
	isDragging = false,
}

return {
	class = "UIDragDetector",

	callback = function(instance)
		propTable.render = function(lib, object, dt, structs, renderer)
			if object.Parent then
				local adornee = object.Parent
				if adornee.BaseClass == "GuiObject" then
					local absolutePosition, absoluteSize = adornee.AbsolutePosition, adornee.AbsoluteSize

					if not absolutePosition or not absoluteSize then
						return
					end

					if instance.isDragging == true then
						local mousePos = raylib.lib.GetMousePosition()
						adornee.Position =
							UDim2.new(adornee.Position.X.Scale, mousePos.x, adornee.Position.Y.Scale, mousePos.y)
						raylib.lib.SetMouseCursor(raylib.const.MouseCursor.MOUSE_CURSOR_RESIZE_ALL)
					end

					local new = arect.new(absolutePosition.X, absolutePosition.Y, absoluteSize.X, absoluteSize.Y)
					if arect.MouseIsInRect(new) then
						if raylib.lib.IsMouseButtonDown(0) == 1 then
							instance.isDragging = true
						elseif raylib.lib.IsMouseButtonReleased(0) == 1 then
							instance.isDragging = false
							raylib.lib.SetMouseCursor(raylib.const.MouseCursor.MOUSE_CURSOR_DEFAULT)
						end
					end
				end
			end
		end

		instance:SetProperties(propTable)

		return instance
	end,

	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
