local primitive = {}

local function err(value, expected)
	error(string.format("Expected %s, got %s", expected, type(value)), 2)
end

primitive.string = function(maxLength)
	return function(value)
		if type(value) ~= "string" then
			err(value, "string")
		end
		if maxLength and #value > maxLength then
			error("String length exceeds " .. maxLength)
		end
		return value
	end
end

primitive.number = function()
	return function(value)
		if type(value) ~= "number" then
			err(value, "number")
		end
		return value
	end
end

primitive.boolean = function()
	return function(value)
		if type(value) ~= "boolean" then
			err(value, "boolean")
		end
		return value
	end
end

local function makeIntValidator(min, max)
	return function(value)
		if type(value) ~= "number" or value ~= math.floor(value) then
			err(value, "integer")
		end
		if value < min or value > max then
			error("Integer out of range (" .. min .. " -> " .. max .. ")", 2)
		end
		return value
	end
end

primitive.int8 = makeIntValidator(-128, 127)
primitive.uint8 = makeIntValidator(0, 255)
primitive.int16 = makeIntValidator(-32768, 32767)
primitive.uint16 = makeIntValidator(0, 65535)
primitive.int32 = makeIntValidator(-2147483648, 2147483647)
primitive.uint32 = makeIntValidator(0, 4294967295)

primitive.float = function()
	return function(value)
		if type(value) ~= "number" then
			err(value, "float")
		end
		return value
	end
end

primitive.double = primitive.float

return primitive
