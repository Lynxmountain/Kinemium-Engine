local Vector3 = require("./Vector3")

local CFrame = {}
CFrame.__index = CFrame

local function mulRotation(a, b)
	local r = {}
	for i = 1, 3 do
		r[i] = {}
		for j = 1, 3 do
			r[i][j] = a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j]
		end
	end
	return r
end

function CFrame.new(...)
	local args = { ... }
	local self = setmetatable({}, CFrame)

	self.Rotation = {
		{ 1, 0, 0 },
		{ 0, 1, 0 },
		{ 0, 0, 1 },
	}

	if #args == 1 then
		self.Position = args[1]
	elseif #args == 3 then
		self.Position = Vector3.new(args[1], args[2], args[3])
	elseif #args == 2 then
		local pos, target = args[1], args[2]
		local z = (pos - target)
		local zmag = math.sqrt(z.X ^ 2 + z.Y ^ 2 + z.Z ^ 2)
		z = Vector3.new(z.X / zmag, z.Y / zmag, z.Z / zmag)
		local up = Vector3.new(0, 1, 0)
		local x = up:Cross(z)
		local xmag = math.sqrt(x.X ^ 2 + x.Y ^ 2 + x.Z ^ 2)
		x = Vector3.new(x.X / xmag, x.Y / xmag, x.Z / xmag)
		local y = z:Cross(x)
		self.Position = pos
		self.Rotation = {
			{ x.X, y.X, z.X },
			{ x.Y, y.Y, z.Y },
			{ x.Z, y.Z, z.Z },
		}
	elseif #args == 12 then
		self.Position = Vector3.new(args[1], args[2], args[3])
		self.Rotation = {
			{ args[4], args[5], args[6] },
			{ args[7], args[8], args[9] },
			{ args[10], args[11], args[12] },
		}
	else
		error("Invalid CFrame.new arguments")
	end

	return self
end

function CFrame.__mul(a, b)
	local pos = a.Position
		+ Vector3.new(
			a.Rotation[1][1] * b.Position.X + a.Rotation[1][2] * b.Position.Y + a.Rotation[1][3] * b.Position.Z,
			a.Rotation[2][1] * b.Position.X + a.Rotation[2][2] * b.Position.Y + a.Rotation[2][3] * b.Position.Z,
			a.Rotation[3][1] * b.Position.X + a.Rotation[3][2] * b.Position.Y + a.Rotation[3][3] * b.Position.Z
		)
	local rot = mulRotation(a.Rotation, b.Rotation)
	local cf = CFrame.new(pos)
	cf.Rotation = rot
	return cf
end

function CFrame:Inverse()
	local rT = {}
	for i = 1, 3 do
		rT[i] = {}
		for j = 1, 3 do
			rT[i][j] = self.Rotation[j][i]
		end
	end
	local invPos = Vector3.new(
		-(rT[1][1] * self.Position.X + rT[1][2] * self.Position.Y + rT[1][3] * self.Position.Z),
		-(rT[2][1] * self.Position.X + rT[2][2] * self.Position.Y + rT[2][3] * self.Position.Z),
		-(rT[3][1] * self.Position.X + rT[3][2] * self.Position.Y + rT[3][3] * self.Position.Z)
	)
	local cf = CFrame.new(invPos)
	cf.Rotation = rT
	return cf
end

function CFrame:Lerp(target, alpha)
	local pos = Vector3.new(
		self.Position.X + (target.Position.X - self.Position.X) * alpha,
		self.Position.Y + (target.Position.Y - self.Position.Y) * alpha,
		self.Position.Z + (target.Position.Z - self.Position.Z) * alpha
	)
	local rot = {}
	for i = 1, 3 do
		rot[i] = {}
		for j = 1, 3 do
			rot[i][j] = self.Rotation[i][j] + (target.Rotation[i][j] - self.Rotation[i][j]) * alpha
		end
	end
	local cf = CFrame.new(pos)
	cf.Rotation = rot
	return cf
end

function CFrame:PointToWorldSpace(point)
	return self.Position
		+ Vector3.new(
			self.Rotation[1][1] * point.X + self.Rotation[1][2] * point.Y + self.Rotation[1][3] * point.Z,
			self.Rotation[2][1] * point.X + self.Rotation[2][2] * point.Y + self.Rotation[2][3] * point.Z,
			self.Rotation[3][1] * point.X + self.Rotation[3][2] * point.Y + self.Rotation[3][3] * point.Z
		)
end

function CFrame:ToWorldSpace(cf)
	return self * cf
end

function CFrame.lookAt(pos, target, up)
	up = up or Vector3.new(0, 1, 0)
	local z = (pos - target)
	local zmag = math.sqrt(z.X ^ 2 + z.Y ^ 2 + z.Z ^ 2)
	z = Vector3.new(z.X / zmag, z.Y / zmag, z.Z / zmag)
	local x = up:Cross(z)
	local xmag = math.sqrt(x.X ^ 2 + x.Y ^ 2 + x.Z ^ 2)
	x = Vector3.new(x.X / xmag, x.Y / xmag, x.Z / xmag)
	local y = z:Cross(x)
	local cf = CFrame.new(pos)
	cf.Rotation = {
		{ x.X, y.X, z.X },
		{ x.Y, y.Y, z.Y },
		{ x.Z, y.Z, z.Z },
	}
	return cf
end

-- Get rotation components (XVector, YVector, ZVector)
function CFrame:GetComponents()
	return self.Position.X,
		self.Position.Y,
		self.Position.Z,
		self.Rotation[1][1],
		self.Rotation[1][2],
		self.Rotation[1][3],
		self.Rotation[2][1],
		self.Rotation[2][2],
		self.Rotation[2][3],
		self.Rotation[3][1],
		self.Rotation[3][2],
		self.Rotation[3][3]
end

function CFrame:GetRightVector()
	return Vector3.new(self.Rotation[1][1], self.Rotation[2][1], self.Rotation[3][1])
end

function CFrame:GetUpVector()
	return Vector3.new(self.Rotation[1][2], self.Rotation[2][2], self.Rotation[3][2])
end

function CFrame:GetLookVector()
	return Vector3.new(-self.Rotation[1][3], -self.Rotation[2][3], -self.Rotation[3][3])
end

function CFrame:PointToObjectSpace(point)
	local rel = point - self.Position
	return Vector3.new(
		self.Rotation[1][1] * rel.X + self.Rotation[2][1] * rel.Y + self.Rotation[3][1] * rel.Z,
		self.Rotation[1][2] * rel.X + self.Rotation[2][2] * rel.Y + self.Rotation[3][2] * rel.Z,
		self.Rotation[1][3] * rel.X + self.Rotation[2][3] * rel.Y + self.Rotation[3][3] * rel.Z
	)
end

function CFrame:ToObjectSpace(cf)
	return self:Inverse() * cf
end

function CFrame:VectorToWorldSpace(vec)
	return Vector3.new(
		self.Rotation[1][1] * vec.X + self.Rotation[1][2] * vec.Y + self.Rotation[1][3] * vec.Z,
		self.Rotation[2][1] * vec.X + self.Rotation[2][2] * vec.Y + self.Rotation[2][3] * vec.Z,
		self.Rotation[3][1] * vec.X + self.Rotation[3][2] * vec.Y + self.Rotation[3][3] * vec.Z
	)
end

function CFrame:VectorToObjectSpace(vec)
	return Vector3.new(
		self.Rotation[1][1] * vec.X + self.Rotation[2][1] * vec.Y + self.Rotation[3][1] * vec.Z,
		self.Rotation[1][2] * vec.X + self.Rotation[2][2] * vec.Y + self.Rotation[3][2] * vec.Z,
		self.Rotation[1][3] * vec.X + self.Rotation[2][3] * vec.Y + self.Rotation[3][3] * vec.Z
	)
end

function CFrame.fromEulerAnglesXYZ(x, y, z)
	return CFrame.Angles(x, y, z)
end

function CFrame.fromEulerAnglesYXZ(y, x, z)
	local cx, sx = math.cos(x), math.sin(x)
	local cy, sy = math.cos(y), math.sin(y)
	local cz, sz = math.cos(z), math.sin(z)

	local rot = {
		{ cy * cz + sy * sx * sz, -cy * sz + sy * sx * cz, sy * cx },
		{ cx * sz, cx * cz, -sx },
		{ -sy * cz + cy * sx * sz, sy * sz + cy * sx * cz, cy * cx },
	}

	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame.fromAxisAngle(axis, angle)
	local c, s = math.cos(angle), math.sin(angle)
	local t = 1 - c
	local x, y, z = axis.X, axis.Y, axis.Z
	local mag = math.sqrt(x * x + y * y + z * z)
	x, y, z = x / mag, y / mag, z / mag

	local rot = {
		{ t * x * x + c, t * x * y - s * z, t * x * z + s * y },
		{ t * x * y + s * z, t * y * y + c, t * y * z - s * x },
		{ t * x * z - s * y, t * y * z + s * x, t * z * z + c },
	}

	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame.__add(a, b)
	if type(b) == "table" and b.X then -- Vector3
		return CFrame.new(a.Position + b)
	end
	error("Cannot add CFrame with " .. type(b))
end

function CFrame.__sub(a, b)
	if type(b) == "table" and b.X then -- Vector3
		return CFrame.new(a.Position - b)
	end
	error("Cannot subtract " .. type(b) .. " from CFrame")
end

function CFrame.__eq(a, b)
	if a.Position ~= b.Position then
		return false
	end
	for i = 1, 3 do
		for j = 1, 3 do
			if math.abs(a.Rotation[i][j] - b.Rotation[i][j]) > 1e-6 then
				return false
			end
		end
	end
	return true
end

function CFrame.fromMatrix(pos, x, y, z)
	local cf = CFrame.new(pos)
	cf.Rotation = {
		{ x.X, y.X, z.X },
		{ x.Y, y.Y, z.Y },
		{ x.Z, y.Z, z.Z },
	}
	return cf
end

function CFrame:ToEulerAnglesXYZ()
	local r = self.Rotation
	local x, y, z

	if r[3][1] < 1 then
		if r[3][1] > -1 then
			y = math.asin(r[3][1])
			x = math.atan2(-r[3][2], r[3][3])
			z = math.atan2(-r[2][1], r[1][1])
		else
			y = -math.pi / 2
			x = -math.atan2(r[2][3], r[2][2])
			z = 0
		end
	else
		y = math.pi / 2
		x = math.atan2(r[2][3], r[2][2])
		z = 0
	end

	return x, y, z
end

function CFrame.Angles(x, y, z)
	local cx, sx = math.cos(x), math.sin(x)
	local cy, sy = math.cos(y), math.sin(y)
	local cz, sz = math.cos(z), math.sin(z)

	local rotX = {
		{ 1, 0, 0 },
		{ 0, cx, -sx },
		{ 0, sx, cx },
	}

	local rotY = {
		{ cy, 0, sy },
		{ 0, 1, 0 },
		{ -sy, 0, cy },
	}

	local rotZ = {
		{ cz, -sz, 0 },
		{ sz, cz, 0 },
		{ 0, 0, 1 },
	}

	local rot = mulRotation(rotZ, mulRotation(rotY, rotX))
	local cf = CFrame.new(Vector3.new(0, 0, 0))
	cf.Rotation = rot
	return cf
end

function CFrame:__tostring()
	return ("CFrame.new(%s, %s, %s)"):format(self.Position.X, self.Position.Y, self.Position.Z)
end

function CFrame:ToTable()
	return {
		type = "CFrame",
		Position = self.Position:ToTable(),
		Rotation = self.Rotation,
	}
end

function CFrame.FromTable(tbl)
	assert(tbl.type == "CFrame")
	local cf = CFrame.new(Vector3.FromTable(tbl.Position))
	cf.Rotation = tbl.Rotation
	return cf
end

function CFrame:ToRaylibMatrixScale(scale, structs)
	local r = self.Rotation
	local p = self.Position
	scale = scale or { X = 1, Y = 1, Z = 1 }

	-- i love when i require raylib just to get the structs every frame
	-- isnt that right quaded
	-- Yes, that is very right
	-- Do i look like dumbass?
	-- Yes

	return structs.Matrix:new({
		m0 = r[1][1] * scale.X,
		m1 = r[2][1] * scale.X,
		m2 = r[3][1] * scale.X,
		m3 = 0,

		m4 = r[1][2] * scale.Y,
		m5 = r[2][2] * scale.Y,
		m6 = r[3][2] * scale.Y,
		m7 = 0,

		m8 = r[1][3] * scale.Z,
		m9 = r[2][3] * scale.Z,
		m10 = r[3][3] * scale.Z,
		m11 = 0,

		m12 = p.X,
		m13 = p.Y,
		m14 = p.Z,
		m15 = 1,
	})
end

function CFrame.fromQuaternion(x, y, z, w, pos)
	local len = math.sqrt(x * x + y * y + z * z + w * w)
	x, y, z, w = x / len, y / len, z / len, w / len

	local xx, yy, zz = x * x, y * y, z * z
	local xy, xz, yz = x * y, x * z, y * z
	local wx, wy, wz = w * x, w * y, w * z

	local m00 = 1 - 2 * (yy + zz)
	local m01 = 2 * (xy - wz)
	local m02 = 2 * (xz + wy)

	local m10 = 2 * (xy + wz)
	local m11 = 1 - 2 * (xx + zz)
	local m12 = 2 * (yz - wx)

	local m20 = 2 * (xz - wy)
	local m21 = 2 * (yz + wx)
	local m22 = 1 - 2 * (xx + yy)

	local right = Vector3.new(m00, m10, m20)
	local up = Vector3.new(m01, m11, m21)
	local look = Vector3.new(m02, m12, m22)

	return CFrame.fromMatrix(pos, right, up, look)
end

function CFrame:ToRaylibMatrix(structs)
	local r = self.Rotation
	local p = self.Position

	return structs.Matrix:new({
		m0 = r[1][1],
		m1 = r[2][1],
		m2 = r[3][1],
		m3 = 0,

		m4 = r[1][2],
		m5 = r[2][2],
		m6 = r[3][2],
		m7 = 0,

		m8 = r[1][3],
		m9 = r[2][3],
		m10 = r[3][3],
		m11 = 0,

		m12 = p.X,
		m13 = p.Y,
		m14 = p.Z,
		m15 = 1,
	})
end

return CFrame
