local Instance = require("@Instance")
local signal = require("@kinetica.signal")

local KineticaShaderService = Instance.new("KineticaShaderService")

local ShaderAdded = signal.new()
local ShaderRemoved = signal.new()

KineticaShaderService.InitRenderer = function(renderer, renderer_signal)
	KineticaShaderService:SetProperties({
		ShaderAdded = ShaderAdded,
		ShaderRemoved = ShaderRemoved,
		LoadShader = function(shaderName: string, vertexPath: string?, fragmentPath: string?)
			renderer.LoadShader(shaderName, vertexPath, fragmentPath)
			ShaderAdded:Fire(shaderName, vertexPath, fragmentPath)
		end,
		GetShaderUniformLocation = renderer.GetShaderUniformLocation,
		SetShaderUniform = renderer.SetShaderUniform,
		LoadShaderCode = renderer.LoadShaderCode,
		UnloadShader = function(shaderName: string)
			renderer.UnloadShader(shaderName)
			ShaderRemoved:Fire(shaderName)
		end,
	})
end

return KineticaShaderService
