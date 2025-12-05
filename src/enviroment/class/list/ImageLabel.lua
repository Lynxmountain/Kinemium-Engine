local Vector2 = require("@Vector2")
local Color3 = require("@Color3")
local UDim2 = require("@UDim2")
local Enum = require("@EnumMap")
local Frame = require("@Frame")

local propTable = {
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(0, 100, 0, 100),
	AnchorPoint = Vector2.new(0, 0),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0,
	Image = "",
	ImageColor3 = Color3.new(1, 1, 1),
	ImageTransparency = 0.5,
	--ScaleType = Enum.ScaleType.Stretch,
	--SliceCenter = Rect.new(0, 0, 0, 0),
	--SliceScale = 1,
	Name = "ImageLabel",
	Visible = true,
	ZIndex = 1,

	render = function(lib, object, dt, structs, renderer)
		local framePos, frameSize = Frame.render(lib, object, dt, structs, renderer)

		local cached = renderer.gbGet(object.Image)
		if cached then
			local size = vector.create(buffer.readi32(cached, 4), buffer.readi32(cached, 8))

			local rec = structs.Rectangle:new({
				x = 0,
				y = 0,
				width = size.x,
				height = size.y,
			})

			local dest = structs.Rectangle:new({
				x = framePos.X,
				y = framePos.Y,
				width = frameSize.X,
				height = frameSize.Y,
			})

			local function Color3ToRaylib(c, transparency)
				local r, g, b = c:ToRGB()
				return structs.Color:new({
					r = r,
					g = g,
					b = b,
					a = math.floor(255 * (1 - transparency)),
				})
			end

			lib.DrawTexturePro(
				cached,
				rec,
				dest,
				vector.create(0, 0), -- origin top-left
				object.Rotation or 0,
				Color3ToRaylib(object.ImageColor3, object.ImageTransparency)
			)
		end

		return framePos, frameSize, cached
	end,
}

Frame.inherit(propTable)

return {
	class = "ImageLabel",
	render = propTable.render,
	callback = function(instance, renderer)
		-- includes lib
		instance:SetProperties(propTable)

		instance.Changed:Connect(function(property)
			if property == "Image" then
				renderer.gbSet(instance.Image, renderer.lib.LoadTexture(instance.Image))
			end
		end)

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
