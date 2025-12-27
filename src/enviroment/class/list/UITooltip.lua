local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local UDim2 = require("@UDim2")
local raylib = require("@raylib")

local aereon = require("@Kinemium.Aereon")
local arect = aereon.rect()

local propTable = {
	Name = "UITooltip",
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 0.3,
	TextColor3 = Color3.new(0, 0, 0),
	TextTransparency = 0,
	TextSize = 18,
	Visible = true,
	--Font = Enum.Font.Montserrat,
	Text = "Hello World!",
}

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return raylib.structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

return {
	class = "UITooltip",

	callback = function(instance)
		propTable.render = function(lib, object, dt, structs, renderer)
			if not object.Visible then
				return
			end
			if object.Parent then
				local adornee = object.Parent
				if adornee.BaseClass == "GuiObject" then
					local absolutePosition, absoluteSize = adornee.AbsolutePosition, adornee.AbsoluteSize

					if not absolutePosition or not absoluteSize then
						return
					end

					local new = arect.new(absolutePosition.X, absolutePosition.Y, absoluteSize.X, absoluteSize.Y)
					if arect.MouseIsInRect(new) then
						local position = raylib.lib.GetMousePosition()

						local final = vector.create(position.x + 5, position.y - object.TextSize - 3)

						raylib.lib.DrawText(
							object.Text,
							final.x,
							final.y,
							object.TextSize,
							Color3ToRaylib(object.TextColor3, object.TextTransparency)
						)
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
