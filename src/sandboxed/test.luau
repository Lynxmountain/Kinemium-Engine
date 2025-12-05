local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClickMinigame"
screenGui.Parent = LocalPlayer.PlayerGui

local Explorer = Instance.new("Frame")
Explorer.Position = UDim2.new(1, 0, 0.5, 0)
Explorer.AnchorPoint = Vector2.new(1, 0.5)
Explorer.Size = UDim2.new(0, 400, 0, 700)
Explorer.BackgroundColor3 = Color3.new(0, 0, 0)
Explorer.BackgroundTransparency = 0.3
Explorer.Parent = screenGui

local corner = Instance.new("UICorner")
corner.Parent = Explorer

local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = Explorer

local services = game.Root:GetChildren()

local image = Instance.new("ImageButton")
image.Image = "./src/assets/images/cat.png"
image.Size = UDim2.new(0, 500, 0, 500)
image.Position = UDim2.new(0.5, 0, 0.5, 0)
image.AnchorPoint = Vector2.new(0.5, 0.5)
image.Parent = screenGui
