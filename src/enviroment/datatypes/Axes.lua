local Axes = {}
Axes.__index = Axes

function Axes.new(x, y, z, top, bottom, left, right, front, back)
	return setmetatable({
		X = x or false,
		Y = y or false,
		Z = z or false,
		Top = top or false,
		Bottom = bottom or false,
		Left = left or false,
		Right = right or false,
		Front = front or false,
		Back = back or false,
	}, Axes)
end

return Axes
