local Vector2 = require("@Vector2")

local UDim2 = {}
UDim2.__index = UDim2

function UDim2.new(xScale, xOffset, yScale, yOffset)
	return setmetatable({
		X = { Scale = xScale or 0, Offset = xOffset or 0 },
		Y = { Scale = yScale or 0, Offset = yOffset or 0 },
	}, UDim2)
end

function UDim2:Lerp(other, alpha)
	return UDim2.new(
		self.X.Scale + (other.X.Scale - self.X.Scale) * alpha,
		self.X.Offset + (other.X.Offset - self.X.Offset) * alpha,
		self.Y.Scale + (other.Y.Scale - self.Y.Scale) * alpha,
		self.Y.Offset + (other.Y.Offset - self.Y.Offset) * alpha
	)
end

function UDim2:ToPixels(referenceSize)
	return Vector2.new(self.X.Scale * referenceSize.X + self.X.Offset, self.Y.Scale * referenceSize.Y + self.Y.Offset)
end

function UDim2.FromPixels(pixels, referenceSize)
	return UDim2.new(pixels.X / referenceSize.X, 0, pixels.Y / referenceSize.Y, 0)
end

function UDim2:__tostring()
	return string.format("UDim2.new(%g, %g, %g, %g)", self.X.Scale, self.X.Offset, self.Y.Scale, self.Y.Offset)
end

function UDim2.__eq(a, b)
	return a.X.Scale == b.X.Scale and a.X.Offset == b.X.Offset and a.Y.Scale == b.Y.Scale and a.Y.Offset == b.Y.Offset
end

function UDim2.__add(a, b)
	return UDim2.new(a.X.Scale + b.X.Scale, a.X.Offset + b.X.Offset, a.Y.Scale + b.Y.Scale, a.Y.Offset + b.Y.Offset)
end

function UDim2.__sub(a, b)
	return UDim2.new(a.X.Scale - b.X.Scale, a.X.Offset - b.X.Offset, a.Y.Scale - b.Y.Scale, a.Y.Offset - b.Y.Offset)
end

function UDim2.__mul(a, b)
	if type(a) == "number" then
		return UDim2.new(b.X.Scale * a, b.X.Offset * a, b.Y.Scale * a, b.Y.Offset * a)
	elseif type(b) == "number" then
		return UDim2.new(a.X.Scale * b, a.X.Offset * b, a.Y.Scale * b, a.Y.Offset * b)
	else
		error("UDim2 multiplication only supports a number")
	end
end

function UDim2.__div(a, b)
	if type(b) ~= "number" then
		error("UDim2 division only supports a number")
	end
	return UDim2.new(a.X.Scale / b, a.X.Offset / b, a.Y.Scale / b, a.Y.Offset / b)
end

function UDim2:ToTable()
	return {
		type = "UDim2",
		X = {
			Scale = self.X.Scale,
			Offset = self.X.Offset,
		},
		Y = {
			Scale = self.Y.Scale,
			Offset = self.Y.Offset,
		},
	}
end

function UDim2.FromTable(tbl)
	assert(tbl.type == "UDim2")
	return UDim2.new(tbl.X.Scale, tbl.X.Offset, tbl.Y.Scale, tbl.Y.Offset)
end

return UDim2
