local random = math.random
local randomf = function(a, b)
	a = a or 0.0
	b = b or 1.0
	return a + (b - a) * random()
end

local randomi = function(n, m)
	n = n or 0
	m = m or 1
	return random(n, m)
end

local randomvec3 = function(a)
	a = a or 1.0
	return { randomf(-a, a), randomf(-a, a), randomf(-a, a) }
end

local randomvec4 = function(a)
	a = a or 1.0
	return { randomf(-a, a), randomf(-a, a), randomf(-a, a), randomf(-a, a) }
end

local randommat3 = function(a)
	a = a or 1.0
	return {
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
		randomf(-a, a),
	}
end

local randomdir = function()
	local x, y, z
	repeat
		x = randomf(-1, 1)
		y = randomf(-1, 1)
		z = randomf(-1, 1)
	until x * x + y * y + z * z <= 1
	local len = math.sqrt(x * x + y * y + z * z)
	return { x / len, y / len, z / len }
end

local randomrot = function()
	-- Simple random rotation matrix, for simplicity, use identity or something
	-- Actually, need proper random rotation
	-- For now, placeholder
	return {
		1,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		1,
	}
end

local randomquat = function()
	-- Random quaternion
	local u1 = random()
	local u2 = random()
	local u3 = random()
	local w = math.sqrt(1 - u1) * math.sin(2 * math.pi * u2)
	local x = math.sqrt(1 - u1) * math.cos(2 * math.pi * u2)
	local y = math.sqrt(u1) * math.sin(2 * math.pi * u3)
	local z = math.sqrt(u1) * math.cos(2 * math.pi * u3)
	return { w, x, y, z }
end

local randomsign = function()
	return random() < 0.5 and -1.0 or 1.0
end

return {
	random = random,
	randomi = randomi,
	randomf = randomf,
	randomvec3 = randomvec3,
	randomvec4 = randomvec4,
	randommat3 = randommat3,
	randomdir = randomdir,
	randomrot = randomrot,
	randomquat = randomquat,
	randomsign = randomsign,
}
