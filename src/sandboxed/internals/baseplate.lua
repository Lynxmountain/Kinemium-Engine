local baseplate = Instance.new("Part")
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Parent = workspace

local p = Instance.new("Part")
p.Size = Vector3.new(4, 4, 4)
p.Position = Vector3.new(0, 50, 0)
p.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
p.Anchored = false
p.Parent = workspace
