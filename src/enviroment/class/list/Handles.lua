local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")
local raylib = require("@raylib")
local lib, const, structs = raylib.lib, raylib.const, raylib.structs

local propTable = {
	Color = Color3.new(0.5, 0.5, 0.5),
	Adornee = nil,
	CastShadows = false,
	Name = "Handles",
}

local function toVector(v)
	return vector.create(v.X, v.Y, v.Z)
end

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function DrawGridAt(pos, size, spacing, color)
	local half = size * 0.5

	for i = -half, half, spacing do
		-- X lines
		lib.DrawLine3D(toVector(pos + Vector3.new(i, 0, -half)), toVector(pos + Vector3.new(i, 0, half)), color)

		-- Z lines
		lib.DrawLine3D(toVector(pos + Vector3.new(-half, 0, i)), toVector(pos + Vector3.new(half, 0, i)), color)
	end
end

local function arrow(origin, direction, scale, color)
	local dir = direction:Unit() -- Normalize the direction vector
	local shaftStart = origin + dir * 2.5
	local shaftEnd = origin + dir * (scale + 1)
	lib.DrawCylinderEx(toVector(shaftStart), toVector(shaftEnd), 0.1, 0.1, 18, color)
	local coneBase = origin + dir * (scale + 1)
	local coneTip = origin + dir * (scale + 1.5)
	lib.DrawCylinderEx(toVector(coneBase), toVector(coneTip), 0.3, 0.01, 18, color)

	-- Calculate bounding box that encompasses the entire arrow (shaft + cone)
	local minX = math.min(shaftStart.X, shaftEnd.X, coneBase.X, coneTip.X) - 0.3
	local minY = math.min(shaftStart.Y, shaftEnd.Y, coneBase.Y, coneTip.Y) - 0.3
	local minZ = math.min(shaftStart.Z, shaftEnd.Z, coneBase.Z, coneTip.Z) - 0.3

	local maxX = math.max(shaftStart.X, shaftEnd.X, coneBase.X, coneTip.X) + 0.3
	local maxY = math.max(shaftStart.Y, shaftEnd.Y, coneBase.Y, coneTip.Y) + 0.3
	local maxZ = math.max(shaftStart.Z, shaftEnd.Z, coneBase.Z, coneTip.Z) + 0.3

	local position = vector.create((minX + maxX) / 2, (minY + maxY) / 2, (minZ + maxZ) / 2)

	local size = vector.create(maxX - minX, maxY - minY, maxZ - minZ)

	return position, size
end

return {
	class = "Handles",

	callback = function(instance, renderer)
		propTable.render = function(handles, renderer)
			if handles.Adornee then
				local part = handles.Adornee

				local pos = part.Position
				local size = part.Size
				local scale = math.max(size.X, size.Y, size.Z) * 1.2

				DrawGridAt(part.Position, 10, 2, const.GRAY)
				local pos1, size1 = arrow(pos, Vector3.new(1, 0, 0), scale, const.RED)
				local bb2 = arrow(pos, Vector3.new(-1, 0, 0), scale, const.RED)
				local bb3 = arrow(pos, Vector3.new(0, 1, 0), scale, const.GREEN)
				local bb4 = arrow(pos, Vector3.new(0, -1, 0), scale, const.GREEN)
				local bb5 = arrow(pos, Vector3.new(0, 0, 1), scale, const.BLUE)
				local bb6 = arrow(pos, Vector3.new(0, 0, -1), scale, const.BLUE)
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
