local baseplate = Instance.new("Part")
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Parent = Scene

local SerializationService = game:GetService("SerializationService")
print("buh 2")
local success, result = pcall(function(...)
	return SerializationService.SerializeInstancesAsync({ game, baseplate })
end)
warn(result)
