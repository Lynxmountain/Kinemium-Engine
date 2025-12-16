local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")

local pool = {}

local raylib = require("@raylib")
local lib = raylib.lib
local structs = raylib.structs

local allowed_to_render = {
	["Part"] = "Part",
	["MeshPart"] = "MeshPart",
	["BasePart"] = "BasePart",
	["Model"] = "Model",
}

Workspace:SetProperties({
	Gravity = 196.2,
	GlobalWind = Vector3.new(0, 0, 0),
	FallenPartsDestroyHeight = 90,
	AirTurbulenceIntensity = 0,
	AirDensity = 0,
	StreamingEnabled = false,
})

Workspace.InitRenderer = function(renderer, signal)
	local meshlib = renderer.meshlib
	local runtimelib = renderer.runtimelib
	local camera = renderer.camera
	local shadowSystem = renderer.shadowSystem
	local materialList = renderer.materialList
	local loadedMaterials = {}

	local preloadedMeshes = meshlib.PreloadStandardMeshes()

	local material_index = 0
	for material_name, material_path in pairs(materialList) do
		local texture = lib.LoadTexture(material_path)
		local default = lib.LoadMaterialDefault()
		lib.SetMaterialTexture(default, 0, texture)

		loadedMaterials[material_name] = {
			index = material_index,
			material = default,
			texture = texture,
		}
		material_index += 1
		print(`Loaded custom material: {material_name}`)
	end

	signal:Connect(function(route, data) end)

	local function isRenderable(obj)
		return obj:IsA("Part") or obj:IsA("MeshPart")
	end

	for _, child in pairs(Workspace:GetDescendants()) do
		if isRenderable(child) then
			pool[#pool + 1] = child
			signal:Fire("AddedPartToRenderPool", v)
		end
	end

	Workspace.DescendantAdded:Connect(function(v)
		if isRenderable(v) then
			pool[#pool + 1] = v
			signal:Fire("AddedPartToRenderPool", v)
		end
	end)

	--[[
	Workspace.DescendantRemoving:Connect(function(v)
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
			mesh = preloadedMeshes[part.Shape.Value][1]
		end

		if not mesh then
			return
		end

		part._mesh = mesh

		meshlib.drawModel(mesh, part, loadedMaterials)

		signal:Fire("Rendered", part)
	end

	renderer.Add3DStack(function()
		-- Main render pass
		for i = 1, #pool do
			drawPart(pool[i])
		end
	end)

	renderer.Add3DStack(function()
		-- Shadow pass
		shadowSystem:BeginShadowMapRender()
		for i = 1, #pool do
			drawPart(pool[i])
		end
		shadowSystem:EndShadowMapRender()
	end)
end

return Workspace
