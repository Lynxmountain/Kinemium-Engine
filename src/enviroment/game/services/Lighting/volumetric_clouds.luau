local volumetricClouds = {}

local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const
local utils = require("@bufferutils")

-- CLOUD DATA
local cloudShader
local cloudUniforms
local screenQuad
local quadMaterial

-- SHADOW
local shadowRT -- render texture for cloud shadows
local lightSpaceMatrix = lib.MatrixIdentity()

-- SETTINGS
local settings = {
	CloudHeight = 3,
	CloudThickness = 3,
	CloudSize = 3,
	Steps = 3,
}

function volumetricClouds.Init()
	cloudShader = lib.LoadShader("./src/assets/shaders/clouds.vert", "./src/assets/shaders/clouds.frag")

	cloudUniforms = {
		cameraPos = lib.GetShaderLocation(cloudShader, "cameraPos"),
		sunDir = lib.GetShaderLocation(cloudShader, "sunDir"),
		sunColor = lib.GetShaderLocation(cloudShader, "sunColor"),
		time = lib.GetShaderLocation(cloudShader, "time"),
		cloudShadowMap = lib.GetShaderLocation(cloudShader, "cloudShadowMap"),
		lightSpaceMatrix = lib.GetShaderLocation(cloudShader, "lightSpaceMatrix"),
	}

	screenQuad = lib.GenMeshPlane(5, 5, 1, 90)
	quadMaterial = lib.LoadMaterialDefault()

	shadowRT = lib.LoadRenderTexture(1024, 1024)
end

function volumetricClouds.UpdateUniforms(camera, sunDir)
	local len = math.sqrt(sunDir.X ^ 2 + sunDir.Y ^ 2 + sunDir.Z ^ 2)
	local sun = { sunDir.X / len, sunDir.Y / len, sunDir.Z / len }

	local cameraPos = zune.mem.toVector3(camera, 0)

	lib.SetShaderValue(cloudShader, cloudUniforms.cameraPos, cameraPos, const.ShaderUniformDataType.SHADER_UNIFORM_VEC3)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.sunDir,
		vector.create(sun[1], sun[2], sun[3]),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.sunColor,
		vector.create(1.0, 0.95, 0.9),
		const.ShaderUniformDataType.SHADER_UNIFORM_VEC3
	)
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.time,
		utils:float(os.clock()),
		const.ShaderUniformDataType.SHADER_UNIFORM_FLOAT
	)

	-- bind shadow map
	lib.rlActiveTextureSlot(1)
	lib.rlEnableTexture(utils.extract.texture(shadowRT))
	lib.SetShaderValue(
		cloudShader,
		cloudUniforms.cloudShadowMap,
		utils:u32(1),
		const.ShaderUniformDataType.SHADER_UNIFORM_INT
	)
	lib.rlActiveTextureSlot(0)

	-- set light space matrix
	lib.SetShaderValueMatrix(cloudShader, cloudUniforms.lightSpaceMatrix, lightSpaceMatrix)
end

-- Render full-screen clouds
function volumetricClouds.Render()
	lib.rlDisableDepthTest()
	lib.rlDisableDepthMask()

	lib.BeginShaderMode(cloudShader)
	lib.BeginBlendMode(const.BlendMode.BLEND_ALPHA)
	--lib.DrawMesh(screenQuad, quadMaterial, lib.MatrixIdentity())
	lib.EndBlendMode()
	lib.EndShaderMode()

	lib.rlEnableDepthTest()
	lib.rlEnableDepthMask()
end

function volumetricClouds.Unload()
	if cloudShader then
		lib.UnloadShader(cloudShader)
	end
	if screenQuad then
		lib.UnloadMesh(screenQuad)
	end
	if shadowRT then
		lib.UnloadRenderTexture(shadowRT)
	end
end

return volumetricClouds
