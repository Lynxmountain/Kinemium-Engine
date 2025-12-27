local RunService = game:GetService("RunService")
local baseplate = Instance.new("Part")
baseplate.CFrame = CFrame.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Baseplate"
baseplate.Anchored = true
baseplate.Parent = game.Workspace

--[[
task.wait(5)

for i = 0, 1000 do
	local part = Instance.new("Part")
	part.CFrame = CFrame.new(math.random(1, 10), 50, math.random(1, 10))
	part.Size = Vector3.new(math.random(), math.random(), math.random())
	part.Color = Color3.new(math.random(), math.random(), math.random())
	part.Name = "v"
	part.Anchored = false
	part.Parent = game.Workspace
	task.wait(0.01)
end
--]]
