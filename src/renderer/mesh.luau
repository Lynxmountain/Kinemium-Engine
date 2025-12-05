return function(lib)
	local modelRegistry = {}

	local function LoadMesh(meshId: string, filePath: string)
		local model = lib.LoadModel(filePath)
		if lib.IsModelValid(model) == 1 then
			modelRegistry[filePath] = model
			print(`Loaded mesh: {meshId} from {filePath}`)
			return model
		else
			warn(`Failed to load mesh: {filePath}`)
			return nil
		end
	end

	local function UnloadMesh(meshId: string)
		local model = modelRegistry[meshId]
		if model then
			lib.UnloadModel(model)
			modelRegistry[meshId] = nil
			print(`Unloaded mesh: {meshId}`)
		end
	end

	local function GetMesh(meshId: string)
		return modelRegistry[meshId]
	end

	local function GenerateMesh(meshId: string, meshType: string, params: any)
		local mesh

		if meshType == "Cube" then
			mesh = lib.GenMeshCube(params.width or 1, params.height or 1, params.length or 1)
		elseif meshType == "Sphere" then
			mesh = lib.GenMeshSphere(params.radius or 1, params.rings or 16, params.slices or 16)
		elseif meshType == "Cylinder" then
			mesh = lib.GenMeshCylinder(params.radius or 1, params.height or 2, params.slices or 16)
		elseif meshType == "Plane" then
			mesh = lib.GenMeshPlane(params.width or 10, params.length or 10, params.resX or 1, params.resZ or 1)
		elseif meshType == "Torus" then
			mesh = lib.GenMeshTorus(params.radius or 1, params.size or 0.3, params.radSeg or 16, params.sides or 16)
		else
			warn(`Unknown mesh type: {meshType}`)
			return nil
		end

		local model = lib.LoadModelFromMesh(mesh)
		modelRegistry[meshId] = model
		print(`Generated mesh: {meshId} ({meshType})`)
		return model
	end

	local function PreloadStandardMeshes()
		local preloaded = {}
		preloaded["block"] = GenerateMesh("cube", "Cube", { width = 1, height = 1, length = 1 })
		preloaded["sphere"] = GenerateMesh("sphere", "Sphere", { radius = 0.5, rings = 16, slices = 16 })
		preloaded["cylinder"] = GenerateMesh("cylinder", "Cylinder", { radius = 0.5, height = 1, slices = 16 })
		preloaded["plane"] = GenerateMesh("plane", "Plane", { width = 10, length = 10, resX = 1, resZ = 1 })
		preloaded["torus"] = GenerateMesh("torus", "Torus", { radius = 1, size = 0.3, radSeg = 16, sides = 16 })
		return preloaded
	end

	local function GetModelRegistry()
		return modelRegistry
	end

	return {
		LoadMesh = LoadMesh,
		UnloadMesh = UnloadMesh,
		GetMesh = GetMesh,
		GenerateMesh = GenerateMesh,
		PreloadStandardMeshes = PreloadStandardMeshes,
		GetModelRegistry = GetModelRegistry,
	}
end
