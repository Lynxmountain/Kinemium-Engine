local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Scene = Instance.new("Scene")

local pool = {}

local raylib = require("@raylib")
local lib = raylib.lib
local structs = raylib.structs

local Kilights = require("@Kilights")
local utils = require("@bufferutils")
local default = lib.LoadMaterialDefault()

local allowed_to_render = {
	["Part"] = "Part",
	["MeshPart"] = "MeshPart",
	["BasePart"] = "BasePart",
	["Model"] = "Model",
}

Scene:SetProperties({
	Gravity = -9.81,
	GlobalWind = Vector3.new(0, 0, 0),
	FallenPartsDestroyHeight = 90,
	AirTurbulenceIntensity = 0,
	AirDensity = 0,
	StreamingEnabled = false,
})

Scene.aliases = {
	"workspace",
}

Scene.InitRenderer = function(renderer, signal, game)
	local meshlib = renderer.meshlib
	local runtimelib = renderer.runtimelib
	local camera = renderer.camera
	local shadowSystem = renderer.shadowSystem
	local materialList = renderer.materialList
	local loadedMaterials = {}

	local default_shadow_shader = Kilights.getDefaultShader()

	Kilights.SetAmbientColor({
		r = 0.5,
		g = 0.5,
		b = 0.5,
		a = 1.0,
	}, default_shadow_shader)

	local light = Kilights.CreateLight(
		Kilights.LIGHT_POINT,
		vector.create(0, 20, 0),
		vector.create(0, -5, 0),
		{ r = 255, g = 255, b = 255, a = 255 },
		default_shadow_shader
	)

	light.attenuation = 0.001

	local preloadedMeshes
	if not IsHeadless then
		preloadedMeshes = meshlib.PreloadStandardMeshes()

		local material_index = 0
		for material_name, material_path in pairs(materialList) do
			local texture = lib.LoadTexture(material_path)
			local default = lib.LoadMaterialDefault()
			lib.SetMaterialTexture(default, 0, texture)

			local material_shader_buffer = utils.extract.material_shader(structs.Material, default)
			buffer.copy(material_shader_buffer, 0, default_shadow_shader, 0, structs.Shader:size())

			loadedMaterials[material_name] = {
				index = material_index,
				material = default,
				texture = texture,
			}
			material_index += 1
			print(`Loaded custom material: {material_name}`)
		end
	end

	signal:Connect(function(route, data) end)

	local function isRenderable(obj)
		return obj:IsA("Part") or obj:IsA("MeshPart")
	end

	Scene.DescendantAdded:Connect(function(v)
		pool[#pool + 1] = v
		if isRenderable(v) then
			signal:Fire("AddedPartToRenderPool", v)
		end
	end)

	--[[
	Scene.DescendantRemoving:Connect(function(v)
		for i = #pool, 1, -1 do
			if pool[i] == v then
				table.remove(pool, i)
				break
			end
		end
	end)
	--]]

	local function drawPart(part)
		local mesh
		if part.ClassName == "MeshPart" then
			mesh = meshlib.GetModelRegistry()[part.MeshId]
		else
			-- second value: Mesh
			mesh = preloadedMeshes[part.Shape.Value][2]
		end

		if not mesh then
			return
		end

		part._mesh = mesh

		local data = loadedMaterials[part.Material.Value]
		local matrix = part.CFrame:ToRaylibMatrixScale(part.Size, raylib.structs)

		raylib.lib.DrawMesh(mesh, data.material, matrix)
		signal:Fire("Rendered", part)
	end

	for _, child in pairs(Scene:GetDescendants()) do
		pool[#pool + 1] = child
		if isRenderable(child) then
			signal:Fire("AddedPartToRenderPool", child)
		end
	end

	if not IsHeadless then
		renderer.Add3DStack(function()
			Kilights:Begin(default_shadow_shader)
			Kilights.UpdateLightValues(default_shadow_shader, light)
			Kilights.SetCameraPos(default_shadow_shader, renderer.camera)

			for i = 1, #pool do
				local object = pool[i]
				if isRenderable(pool[i]) then
					drawPart(object)

					if object.Position.Y <= 300 then
						--object:Destroy()
					end
				else
					if object.render then
						object.render(object, renderer)
					end
				end
			end

			Kilights:End()

			local KinemiumPhysicsService = game:GetService("KinemiumPhysicsService")
			KinemiumPhysicsService.setGravity(Scene.Gravity, Scene.GlobalWind)
		end)
	end
end

return Scene
