local RunService = game:GetService("RunService")
local MainGui = Instance.new("ScreenGui")
MainGui.Parent = game.Players.LocalPlayer.PlayerGui

local KinemiumPhysicsService = game:GetService("KinemiumPhysicsService")

local mainFps = 0

local logo = Instance.new("ImageLabel")
logo.Position = UDim2.new(0, 20, 0, 20)
logo.BackgroundColor3 = Color3.new(0, 0, 0)
logo.Size = UDim2.new(0, 100, 0, 100)
logo.Image = "./src/assets/images/icons/vanilla3/kinemium/KinemiumRaylib.png"
logo.BackgroundTransparency = 0.3
logo.Parent = MainGui

local corner = Instance.new("UICorner")
corner.Parent = logo

local main = Instance.new("Frame")
main.Position = UDim2.new(0, 130, 0, 20)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.Size = UDim2.new(0, 200, 0, 100)
main.BackgroundTransparency = 0.3
main.Parent = MainGui

local UITooltip = Instance.new("UITooltip")
UITooltip.Text = "Kinemium"
UITooltip.Parent = logo

local corner = Instance.new("UICorner")
corner.Parent = main

local fpsText = Instance.new("TextLabel")
fpsText.Size = UDim2.new(0, 130, 0, 30)
fpsText.BackgroundTransparency = 1
fpsText.Position = UDim2.new(0, 5, 0, 0)
fpsText.TextSize = 18
fpsText.TextColor3 = Color3.new(0, 1, 0)
fpsText.TextXAlignment = Enum.TextXAlignment.Left
fpsText.Parent = main

local bodiesText = Instance.new("TextLabel")
bodiesText.Size = UDim2.new(0, 130, 0, 70)
bodiesText.BackgroundTransparency = 1
bodiesText.Position = UDim2.new(0, 5, 0, 0)
bodiesText.TextSize = 18
bodiesText.TextColor3 = Color3.new(1, 1, 1)
bodiesText.TextXAlignment = Enum.TextXAlignment.Left
bodiesText.Parent = main

local blur = Instance.new("BlurEffect")
blur.Parent = main

RunService.RenderStepped:Connect(function(dt: number)
	mainFps = 1 / dt
	fpsText.Text = `FPS: {math.round(mainFps)}`
	bodiesText.Text = `Bodies: {KinemiumPhysicsService.GetPhysicsBodyCount()}`
end)
