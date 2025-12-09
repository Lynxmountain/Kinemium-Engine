local baseplate = Instance.new("Part")
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Parent = workspace

local parentPart = baseplate

for i = 1, 5 do
	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(5, 5, 5)
	newPart.Position = parentPart.Position + Vector3.new(0, newPart.Size.Y / 2 + parentPart.Size.Y / 2, 0)
	newPart.Color = Color3.fromHSV(i * 0.1, 1, 1) -- just to differentiate colors
	newPart.Anchored = true
	newPart.Name = "NestedPart_" .. i
	newPart.Parent = parentPart -- make it a child of the previous part
	parentPart = newPart -- update the parent for the next iteration
end
