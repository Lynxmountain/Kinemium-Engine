local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local Workspace = Instance.new("Workspace")

local allowed_to_render = {
	["Part"] = "Part",
	["MeshPart"] = "MeshPart",
	["BasePart"] = "BasePart",
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
	signal:Connect(function(route, data) end)

	for _, child in pairs(Workspace:GetDescendants()) do
		if not allowed_to_render[child.ClassName] then
			continue
		end
		renderer.AddToRegistry(function()
			return child
		end)
	end

	Workspace.DescendantAdded:Connect(function(v)
		if not allowed_to_render[v.ClassName] then
			return
		end

		renderer.AddToRegistry(function()
			return v
		end)
	end)
end

return Workspace
