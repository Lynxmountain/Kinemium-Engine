local Instance = require("@Instance")
local Color3 = require("@Color3")
local Vector3 = require("@Vector3")
local raylib = require("@raylib")
local const = raylib.const
local lib = raylib.lib
local structs = raylib.structs
local Lighting = Instance.new("Lighting")

local volumetricClouds = require("./Lighting/volumetric_clouds")
local ssao = require("./Lighting/ssao")

local sun = "./src/assets/sky/default/sun.png"

Lighting:SetProperties({
	Ambient = Color3.fromRGB(128, 128, 128), -- Now this will be 128/255 = 0.5
	Brightness = 2.0, -- Increase brightness multiplier
	ColorShift_Top = Color3.fromRGB(255, 255, 255),
	ColorShift_Bottom = Color3.fromRGB(0, 0, 0),
	OutdoorAmbient = Color3.fromRGB(128, 128, 128),
	GlobalShadows = true,
	ClockTime = 14.0,
	GeographicLatitude = 0.0,
	-- Volumetric Lighting Settings
	VolumetricCloudsEnabled = true,
	CloudHeight = 1000.0,
	CloudThickness = 200.0,
	CloudDensity = 0.5,
	CloudSpeed = 0.01,
	CloudCoverage = 0.7,
	-- SSAO Settings
	SSAOEnabled = true,
	SSAORadius = 0.5,
	SSAOBias = 0.025,
	SSAOIntensity = 1.0,
})

function Lighting:GetSunDirection()
	local time = self.ClockTime
	local latitude = math.rad(self.GeographicLatitude)
	local declination = math.rad(23.45 * math.sin(math.rad(360 * (284 + time * 15) / 365))) -- Approximate solar declination
	local hourAngle = math.rad(15 * (time - 12))

	local elevation = math.asin(
		math.sin(latitude) * math.sin(declination) + math.cos(latitude) * math.cos(declination) * math.cos(hourAngle)
	)
	local azimuth = math.atan2(
		math.sin(hourAngle),
		math.cos(hourAngle) * math.sin(latitude) - math.tan(declination) * math.cos(latitude)
	)

	return Vector3.new(
		math.cos(azimuth) * math.cos(elevation),
		math.sin(elevation),
		math.sin(azimuth) * math.cos(elevation)
	)
end

local function handleSky(skyObject, renderer)
	if skyObject.ClassName == "Sky" then
		local skybox = renderer.skybox
		local cubemapPaths

		if skyObject.Cubemap ~= "" then
			skybox.Load(skyObject.Cubemap)
		else
			cubemapPaths = {
				skyObject.SkyboxRt, -- +X
				skyObject.SkyboxLf, -- -X
				skyObject.SkyboxUp, -- +Y
				skyObject.SkyboxDn, -- -Y
				skyObject.SkyboxFt, -- +Z
				skyObject.SkyboxBk, -- -Z
			}

			local cubemap = skybox.FromCubemap(cubemapPaths)
			if not cubemap then
				return
			end
			skybox.Unload()
			skybox.Load(cubemap)
		end

		print("Reinitialized sky with new Skybox skyObject")
	end
end

Lighting.InitRenderer = function(renderer, renderer_signal, datamodel)
	local IsHeadless = false -- Assume not headless for now
	if IsHeadless == true then
	end
	local EngineSignal = datamodel.EngineSignal
	renderer.skybox.Load()

	local sunTexture = lib.LoadTexture(sun)
	local sunPos = vector.create(0, 100, 0)

	local sunShader = lib.LoadShader("./src/assets/shaders/sun.vert", "./src/assets/shaders/sun.frag")

	volumetricClouds.Init()
	ssao.Init()

	renderer_signal:Connect(function(route, dt)
		if route == "RenderStepped" then
			local ambient = Lighting.Ambient
			local brightness = Lighting.Brightness
			renderer.shader.SetShaderUniform(
				"Kinemium",
				"globalAmbient",
				{ ambient.R / 255, ambient.G / 255, ambient.B / 255 },
				4
			)
			renderer.shader.SetShaderUniform("Kinemium", "brightness", brightness, 0)

			local sunDir = Lighting:GetSunDirection()
			renderer.shader.SetShaderUniform("Kinemium", "sunDirection", { sunDir.X, sunDir.Y, sunDir.Z }, 3)

			if Lighting.VolumetricCloudsEnabled then
				local cameraPos = zune.mem.toVector3(renderer.camera, 0)
				--volumetricClouds.UpdateUniforms(renderer.camera, cameraPos, sunDir, Lighting)
			end

			if Lighting.SSAOEnabled then
				ssao.UpdateUniforms(renderer.camera, Lighting)
			end
		end
	end)

	Lighting.ChildAdded:Connect(function(child)
		handleSky(child, renderer)
	end)

	renderer.Add3DStack(function()
		local camera = renderer.camera

		renderer.skybox.Draw(camera, 50)

		if Lighting.VolumetricCloudsEnabled then
			--volumetricClouds.Render()
		end

		if Lighting.SSAOEnabled then
			-- SSAO requires depth and normal textures from G-buffers
			-- for now, placeholder; integrate with deferred renderer
			-- ssao.Render(depthTex, normalTex)
		end
	end)
end

return Lighting
