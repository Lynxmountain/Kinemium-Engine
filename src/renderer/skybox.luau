local skybox = {}

local rl = require("@raylib")
local structs = rl.structs
local const = rl.const
local ffi = zune.ffi

local _skyboxdata = {}

export type raylib = typeof(rl.lib)

local function setshader(buff, shader)
	local materials = ffi.ptrFromAddress(zune.mem.slice(buff, structs.Model:offset("materials"), 8))
	materials:write(structs.Material:offset("shader"), shader, 0, structs.Shader:size())
	return materials
end

local function setCubemap(model, texture)
	local CUBEMAP_MAP = const.MaterialMapIndex.MATERIAL_MAP_CUBEMAP

	local materials = zune.ffi.ptrFromAddress(zune.mem.slice(model, structs.Model:offset("materials"), 8))
	local maps = materials:readptr(structs.Material:offset("maps"))
	maps:write(CUBEMAP_MAP * structs.MaterialMap:size(), texture, 0, structs.Texture:size())

	return maps
end

local function float_ptr(value: number): FFIPointer
	local ptr = ffi.create(ffi.types.float)
	ptr:writef32(0, value)
	return ptr
end

local function int_ptr(value: number): FFIPointer
	local ptr = ffi.create(ffi.types.i32)
	ptr:writei32(0, value)
	return ptr
end

function skybox.load(raylib: raylib)
	local cube = raylib.GenMeshCube(1, 1, 1)
	local model = raylib.LoadModelFromMesh(cube)

	local vs, fs, cubemapfs, cubemapvs, image =
		"./src/assets/sky/default/shader/skybox.vs",
		"./src/assets/sky/default/shader/skybox.fs",
		"./src/assets/sky/default/shader/cubemap.fs",
		"./src/assets/sky/default/shader/cubemap.vs",
		"./src/assets/sky/default/images/cubemap.png"

	local shader = raylib.LoadShader(vs, fs)

	setshader(model, shader)

	local shaderCubemap = raylib.LoadShader(cubemapvs, cubemapfs)

	raylib.SetShaderValue(
		shaderCubemap,
		raylib.GetShaderLocation(shaderCubemap, "equirectangularMap"),
		float_ptr(0),
		const.ShaderUniformDataType.SHADER_UNIFORM_INT
	)

	-- doesnt use HDR
	local loaded = raylib.LoadImage(image)
	--skybox.materials[0].maps[MATERIAL_MAP_CUBEMAP].texture = LoadTextureCubemap(image, CUBEMAP_LAYOUT_AUTO_DETECT);
	local cubemap_texture = raylib.LoadTextureCubemap(loaded, const.CubemapLayout.CUBEMAP_LAYOUT_AUTO_DETECT)
	setCubemap(model, cubemap_texture)

	_skyboxdata = {
		model = model,
		mesh = cube,
		image = loaded,
		cubemap = cubemap_texture,
		shadercubemap = shaderCubemap,
		shadersky = shader,
	}

	return _skyboxdata
end

function skybox.draw(raylib: raylib, cameraPos)
	--raylib.DrawModel(_skyboxdata.model, cameraPos or vector.create(0, 0, 0), 1, const.WHITE)
	raylib.DrawModelEx(
		_skyboxdata.model,
		vector.create(0, 10, 0),
		vector.create(0, 0, 0),
		0,
		vector.create(5, 5, 5),
		const.WHITE
	)
end

return skybox
