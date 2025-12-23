local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Enum = require("@EnumMap")

local raylib = require("@raylib")
local utils = require("@bufferutils")

local propTable = {
	Transparency = 0,
	Color3 = Color3.new(1, 1, 1),
	Texture = "./src/assets/images/icons/vanilla3/kinemium/KinemiumRaylib.png",
	ColorMapContent = "./src/assets/images/icons/vanilla3/kinemium/KinemiumRaylib.png",
	Face = Enum.NormalId.Top,
	Adornee = nil,
}

local function getFaceSize(size, face)
	if face == Enum.NormalId.Front or face == Enum.NormalId.Back then
		return size.X, size.Y
	elseif face == Enum.NormalId.Left or face == Enum.NormalId.Right then
		return size.Z, size.Y
	elseif face == Enum.NormalId.Top or face == Enum.NormalId.Bottom then
		return size.X, size.Z
	end
end

local function getFaceCFrame(cf, size, face)
	local half = size * 0.5
	local padding = 0.005 -- offset to prevent Z-fighting

	if face == Enum.NormalId.Front then
		return cf * CFrame.new(0, 0, -half.Z - padding)
	elseif face == Enum.NormalId.Back then
		return cf * CFrame.new(0, 0, half.Z + padding) * CFrame.Angles(0, math.pi, 0)
	elseif face == Enum.NormalId.Left then
		return cf * CFrame.new(-half.X - padding, 0, 0) * CFrame.Angles(0, math.pi / 2, 0)
	elseif face == Enum.NormalId.Right then
		return cf * CFrame.new(half.X + padding, 0, 0) * CFrame.Angles(0, -math.pi / 2, 0)
	elseif face == Enum.NormalId.Top then
		return cf * CFrame.new(0, half.Y + padding, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
	elseif face == Enum.NormalId.Bottom then
		return cf * CFrame.new(0, -half.Y - padding, 0) * CFrame.Angles(math.pi / 2, 0, 0)
	end
end

local function DrawModelExCFrame(model, cf, scaleVec, color)
	scaleVec = scaleVec or vector.create(1, 1, 1)
	color = color or raylib.const.WHITE

	local mat = cf:ToRaylibMatrix()

	raylib.lib.rlPushMatrix()
	raylib.lib.rlMultMatrixf(mat) -- apply CFrame transform
	raylib.lib.rlScale(scaleVec.X, scaleVec.Y, scaleVec.Z) -- apply scaling
	raylib.lib.DrawModel(model, vector.create(0, 0, 0), 1, color)
	raylib.lib.rlPopMatrix()
end

return {
	class = "Decal",
	callback = function(instance)
		instance:SetProperties(propTable)

		local mesh
		local imageTex
		local material
		local pastLoaded
		local default = raylib.lib.LoadMaterialDefault()
		local currentTexturePath
		local model

		imageTex = raylib.lib.LoadTexture(instance.Texture)
		raylib.lib.SetMaterialTexture(default, 0, imageTex)
		pastLoaded = instance.Texture

		instance.render = function()
			local adornee: Part = instance.Adornee

			if not imageTex or pastLoaded ~= instance.Texture then
				imageTex = raylib.lib.LoadTexture(instance.Texture)
				raylib.lib.SetMaterialTexture(default, 0, imageTex)
				pastLoaded = instance.Texture
			end

			if not instance.Adornee then
				return
			end

			if not (adornee:IsA("Part") or adornee:IsA("MeshPart")) then
				return
			end

			local face = instance.Face
			local size = adornee.Size

			local width, height = getFaceSize(size, face)

			if not mesh then
				mesh = raylib.lib.GenMeshPlane(width, height, 1, 1)
				model = raylib.lib.LoadModelFromMesh(mesh)
			end

			local cf = getFaceCFrame(adornee.CFrame, size, face)

			if not imageTex or currentTexturePath ~= instance.Texture then
				imageTex = raylib.lib.LoadTexture(instance.Texture)
				raylib.lib.SetMaterialTexture(default, 0, imageTex)

				-- update the model's texture maps
				local maps = utils.extract.maps(model, imageTex)
				utils.extract.setModelTexture(maps, imageTex)

				currentTexturePath = instance.Texture
			end

			local x, y, z = cf:ToEulerAnglesXYZ()
			local degX, degY, degZ = math.deg(x), math.deg(y), math.deg(z)

			-- DrawModelEx only rotates around one axis, so you need to pick the dominant rotation
			-- Usually Y (up) for models
			raylib.lib.DrawModelEx(
				model,
				vector.create(cf.Position.X, cf.Position.Y, cf.Position.Z),
				vector.create(0, 1, 0), -- up axis
				degY, -- rotation in degrees around Y
				vector.create(1, 1, 1), -- scale
				raylib.const.WHITE
			)
		end

		return instance
	end,
	inherit = function(tble)
		for prop, val in pairs(propTable) do
			tble[prop] = val
		end
	end,
}
