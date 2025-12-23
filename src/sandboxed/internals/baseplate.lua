local baseplate = Instance.new("Part")
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Grid"
baseplate.Anchored = true
baseplate.Parent = Scene

--[[
for x = 0, 2 do
	for z = 0, 2 do
		local part = Instance.new("Part")
		part.Size = Vector3.new(4, 4, 4)
		part.Position = Vector3.new(x * 4, 15, z * 4)
		part.CFrame = CFrame.new(x * 4, 15, z * 4)
		part.Anchored = true
		part.Parent = Scene

		local Decal = Instance.new("Decal")
		Decal.Adornee = part
		Decal.Parent = part
	end
end
--]]
