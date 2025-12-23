local shadowmap = {}

local rl = require("@raylib")

local LIGHT_TYPE = {
	DIRECTIONAL = "directional",
	POINT = "point",
	SURFACE = "surface",
}

local pointLightDirs = {
	{ dir = { 1, 0, 0 }, up = { 0, -1, 0 } }, -- +X
	{ dir = { -1, 0, 0 }, up = { 0, -1, 0 } }, -- -X
	{ dir = { 0, 1, 0 }, up = { 0, 0, 1 } }, -- +Y
	{ dir = { 0, -1, 0 }, up = { 0, 0, -1 } }, -- -Y
	{ dir = { 0, 0, 1 }, up = { 0, -1, 0 } }, -- +Z
	{ dir = { 0, 0, -1 }, up = { 0, -1, 0 } }, -- -Z
}

function shadowmap.new(lib: typeof(rl.lib), structs: typeof(rl.structs), const: typeof(rl.const), resolution)
	resolution = resolution or 2048

	local self = {
		resolution = resolution,
		lights = {},
		shadowMaps = {},
		lightCameras = {},
		shadowShader = nil,
		depthShader = nil,
		shadowMapLoc = nil,
		lightSpaceMatrixLoc = nil,
	}

	self.shadowMap = lib.LoadRenderTexture(resolution, resolution)

	-- Load shaders (make sure these shader files exist)
	self.depthShader = lib.LoadShader("./src/assets/shaders/depth.vs", "./src/assets/shaders/depth.fs")
	self.shadowShader = lib.LoadShader("./src/assets/shaders/shadow.vs", "./src/assets/shaders/shadow.fs")

	-- Get shader uniform locations
	self.shadowMapLoc = lib.GetShaderLocation(self.shadowShader, "shadowMap")
	self.lightSpaceMatrixLoc = lib.GetShaderLocation(self.shadowShader, "lightSpaceMatrix")
	-- depth shader might also need the lightSpace matrix (if you transform in vertex shader)
	self.lightSpaceMatrixLocDepth = lib.GetShaderLocation(self.depthShader, "lightSpaceMatrix")

	-- Setup light camera (orthographic for directional light)
	self.lightCamera = structs.Camera3D:new({
		position = vector.create(10.0, 10.0, 10.0),
		target = vector.create(0.0, 0.0, 0.0),
		up = vector.create(0.0, 1.0, 0.0),
		fovy = 20.0,
		projection = const.CameraProjection.CAMERA_ORTHOGRAPHIC,
	})

	function self:ComputeLightSpaceMatrix()
		local lightPos = zune.mem.toVector3(self.lightCamera, 0)
		local lightTarget = zune.mem.toVector3(self.lightCamera, 12)
		local lightUp = zune.mem.toVector3(self.lightCamera, 24)

		local lightProjection = lib.MatrixOrtho(-20, 20, -20, 20, 0.1, 100.0)
		local lightView = lib.MatrixLookAt(lightPos, lightTarget, lightUp)

		return lib.MatrixMultiply(lightProjection, lightView)
	end

	function self:UpdateLightPosition(position, target)
		target = target or vector.create(0.0, 0.0, 0.0)

		zune.mem.writeVector3(self.lightCamera, 0, position) -- offset 0: position
		zune.mem.writeVector3(self.lightCamera, 12, target) -- offset 12: target
	end

	function self:BeginShadowMapRender()
		local lightSpaceMatrix = self:ComputeLightSpaceMatrix()

		if self.lightSpaceMatrixLocDepth and self.lightSpaceMatrixLocDepth ~= -1 then
			lib.SetShaderValueMatrix(self.depthShader, self.lightSpaceMatrixLocDepth, lightSpaceMatrix)
		end
		lib.BeginTextureMode(self.shadowMap)
		lib.ClearBackground(const.BLACK) -- Clear color; depth value will be written into color by the depth shader
		lib.BeginMode3D(self.lightCamera)
		lib.BeginShaderMode(self.depthShader)
		-- If your depth shader expects a lightSpace matrix, set it now (we compute it each frame in ApplyShadows)
	end

	-- End depth pass
	function self:EndShadowMapRender()
		lib.EndShaderMode()
		lib.EndMode3D()
		lib.EndTextureMode()
	end

	-- Compute light-space matrix and bind shadow map to the scene shader
	function self:ApplyShadows()
		local lightSpaceMatrix = self:ComputeLightSpaceMatrix()

		if self.lightSpaceMatrixLoc and self.lightSpaceMatrixLoc ~= -1 then
			lib.SetShaderValueMatrix(self.shadowShader, self.lightSpaceMatrixLoc, lightSpaceMatrix)
		end

		lib.BeginShaderMode(self.shadowShader)

		-- Get shadow map texture ID
		local depthTex = zune.mem.slice(self.shadowMap, structs.RenderTexture:offset("texture"), structs.Texture:size())
		local texId = buffer.readu32(depthTex, 0)

		-- Manually bind to texture unit 1
		lib.rlActiveTextureSlot(1)
		lib.rlEnableTexture(texId)

		-- Tell shader shadowMap is on unit 1
		if self.shadowMapLoc ~= -1 then
			local unitBuf = buffer.create(4)
			buffer.writei32(unitBuf, 0, 1)
			lib.SetShaderValue(
				self.shadowShader,
				self.shadowMapLoc,
				unitBuf,
				const.ShaderUniformDataType.SHADER_UNIFORM_INT
			)
		end

		-- Back to unit 0
		lib.rlActiveTextureSlot(0)
	end

	function self:EndShadows()
		lib.EndShaderMode()
	end

	function self:Draw()
		--lib.ClearBackground(const.BLACK)

		local rec = structs.Rectangle:new({ x = 0, y = 0, width = self.resolution, height = -self.resolution })
		local dest = structs.Rectangle:new({ x = 10, y = 10, width = 1000, height = 1000 })

		local tex = zune.mem.slice(self.shadowMap, structs.RenderTexture:offset("texture"), structs.Texture:size())
		lib.DrawTextureRec(tex, rec, dest, const.WHITE)
		print("drawing")
	end

	function self:Unload()
		lib.UnloadRenderTexture(self.shadowMap)
		lib.UnloadShader(self.depthShader)
		lib.UnloadShader(self.shadowShader)
	end

	return self
end

return shadowmap
