local volumetricClouds = {}

local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const

local cloudShader
local cloudUniforms

function volumetricClouds.Init()
	-- Load volumetric cloud shader
	cloudShader = lib.LoadShader("./src/assets/shaders/screen.vert", "./src/assets/shaders/volumetric_clouds.frag")
	cloudUniforms = {
		cameraPos = lib.GetShaderLocation(cloudShader, "cameraPos"),
		invProj = lib.GetShaderLocation(cloudShader, "invProj"),
		invView = lib.GetShaderLocation(cloudShader, "invView"),
		sunDir = lib.GetShaderLocation(cloudShader, "sunDir"),
		sunColor = lib.GetShaderLocation(cloudShader, "sunColor"),
		time = lib.GetShaderLocation(cloudShader, "time"),
		cloudHeight = lib.GetShaderLocation(cloudShader, "cloudHeight"),
		cloudThickness = lib.GetShaderLocation(cloudShader, "cloudThickness"),
	}
end

function volumetricClouds.UpdateUniforms(camera, cameraPos, sunDir, settings)
	lib.SetShaderValue(cloudShader, cloudUniforms.cameraPos, cameraPos, const.ShaderUniformDataType.SHADER_UNIFORM_VEC3)

	local proj = lib.MatrixPerspective(70 * math.pi / 180, 16 / 9, 0.1, 1000)
	local invProj = lib.MatrixInvert(proj)
	local view = lib.GetCameraMatrix(camera)
	local invView = lib.MatrixInvert(view)
	lib.SetShaderValue(cloudShader, cloudUniforms.invProj, invProj, const.ShaderUniformDataType.SHADER_UNIFORM_MAT4)
	lib.SetShaderValue(cloudShader, cloudUniforms.invView, invView, const.ShaderUniformDataType.SHADER_UNIFORM_MAT4)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.sunDir,
		vector.create(sunDir.X, sunDir.Y, sunDir.Z),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.sunColor,
		vector.create(1.0, 0.95, 0.8),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(cloudShader, cloudUniforms.time, os.clock(), const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.cloudHeight,
		settings.CloudHeight,
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.cloudThickness,
		settings.CloudThickness,
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)
end

function volumetricClouds.Render()
	lib.BeginShaderMode(cloudShader)
	local quad = lib.GenMeshPlane(2, 2, 1, 1)
	lib.DrawMesh(quad, lib.LoadMaterialDefault(), lib.MatrixIdentity())
	lib.UnloadMesh(quad)
	lib.EndShaderMode()
end

function volumetricClouds.Unload()
	if cloudShader then
		lib.UnloadShader(cloudShader)
	end
end

return volumetricClouds
