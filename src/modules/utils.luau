local bufferUtils = {}

-- Unsigned integers
function bufferUtils:u8(number)
	local buf = buffer.create(1)
	buffer.writeu8(buf, 0, number)
	return buf
end

function bufferUtils:u16(number)
	local buf = buffer.create(2)
	buffer.writeu16(buf, 0, number)
	return buf
end

function bufferUtils:u32(number)
	local buf = buffer.create(4)
	buffer.writeu32(buf, 0, number)
	return buf
end

-- Signed integers
function bufferUtils:i8(number)
	local buf = buffer.create(1)
	buffer.writei8(buf, 0, number)
	return buf
end

function bufferUtils:i16(number)
	local buf = buffer.create(2)
	buffer.writei16(buf, 0, number)
	return buf
end

function bufferUtils:i32(number)
	local buf = buffer.create(4)
	buffer.writei32(buf, 0, number)
	return buf
end

-- Floating point
function bufferUtils:float(number)
	local buf = buffer.create(4)
	buffer.writef32(buf, 0, number)
	return buf
end

function bufferUtils:double(number)
	local buf = buffer.create(8)
	buffer.writef64(buf, 0, number)
	return buf
end

-- Vectors
function bufferUtils:vector2_32(x, y)
	local buf = buffer.create(8)
	buffer.writef32(buf, 0, x)
	buffer.writef32(buf, 4, y)
	return buf
end

function bufferUtils:vector3_32(x, y, z)
	local buf = buffer.create(12)
	buffer.writef32(buf, 0, x)
	buffer.writef32(buf, 4, y)
	buffer.writef32(buf, 8, z)
	return buf
end

return bufferUtils
