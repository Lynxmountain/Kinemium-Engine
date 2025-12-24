local RunService = game:GetService("RunService")
local baseplate = Instance.new("Part")
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Size = Vector3.new(1000, 4, 1000)
baseplate.Color = Color3.new(0.2, 0.2, 0.2)
baseplate.Name = "Grid"
baseplate.Anchored = true
baseplate.Parent = game.Scene

local parts = {}

local configs = {
	{ pos = Vector3.new(4, 15, 4), shape = Enum.PartType.Ball, speed = math.rad(90) },
	{ pos = Vector3.new(10, 15, 4), shape = Enum.PartType.Block, speed = math.rad(60) },
	{ pos = Vector3.new(16, 15, 4), shape = Enum.PartType.Cylinder, speed = math.rad(120) },
	{ pos = Vector3.new(22, 15, 4), shape = Enum.PartType.Torus, speed = math.rad(120) },
}

local faces = {
	Enum.NormalId.Top,
	Enum.NormalId.Bottom,
	Enum.NormalId.Left,
	Enum.NormalId.Right,
	Enum.NormalId.Front,
	Enum.NormalId.Back,
}

for _, cfg in ipairs(configs) do
	local part = Instance.new("Part")
	part.Size = Vector3.new(2, 2, 2)
	part.Anchored = true
	part.Transparency = 0.5
	part.Shape = cfg.shape
	part.Position = cfg.pos
	part.CFrame = CFrame.new(cfg.pos)
	part.Parent = game.Scene

	for _, face in ipairs(faces) do
		local decal = Instance.new("Decal")
		decal.Face = face
		decal.Adornee = part
		decal.Parent = part
	end

	parts[#parts + 1] = {
		part = part,
		baseCFrame = part.CFrame,
		rot = 0,
		speed = cfg.speed,
	}
end

RunService.RenderStepped:Connect(function(dt)
	for _, data in ipairs(parts) do
		data.rot += data.speed * dt
		data.part.CFrame = data.baseCFrame * CFrame.Angles(data.rot, data.rot, 0)
	end
end)

local part = Instance.new("Part")
part.Size = Vector3.new(2, 2, 2)
part.Anchored = true
part.Transparency = 0.5
part.Position = Vector3.new(0, 30, 0)
part.CFrame = CFrame.new(0, 30, 0)
part.Parent = game.Scene

local arcHandles = Instance.new("ArcHandles")
arcHandles.Adornee = part
arcHandles.Parent = part
