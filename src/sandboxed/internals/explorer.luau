-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local structs = KinemiumRaylib.structs

local serviceOrder = {
	"Workspace",
	"Players",
	"Lighting",
	"MaterialService",
	"ReplicatedFirst",
	"ReplicatedStorage",
	"ServerScriptService",
	"ServerStorage",
	"StarterGui",
	"StarterPack",
	"StarterPlayer",
	"Teams",
	"SoundService",
}

local function getServicesInOrder()
	local services = {}
	for _, name in ipairs(serviceOrder) do
		local success, svc = pcall(game.GetService, game, name)
		if success and svc then
			table.insert(services, svc)
		end
	end

	-- optionally add any remaining children that are not in the list
	for _, child in ipairs(game:GetChildren()) do
		local found = false
		for _, svc in ipairs(services) do
			if child == svc then
				found = true
				break
			end
		end
		if not found then
			table.insert(services, child)
		end
	end

	return services
end

rl.GuiLoadStyle("./src/assets/studiothemes/style_dark.rgs")

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")

local png = KinemiumIconLoader.Get("Add")
print(png)
local addIcon = KinemiumIconLoader.ToTexture(png)

local windowRegistry = {}

local window = require("@Kinemium.rayguiwindow")(rl, structs)

local function create_window(title, frame)
	repeat
		task.wait()
	until frame.AbsolutePosition and frame.AbsoluteSize
	local myWindow = window.create({
		title = title,
		x = frame.AbsolutePosition.X,
		y = frame.AbsolutePosition.Y,
		width = frame.AbsoluteSize.X,
		height = frame.AbsoluteSize.Y,
	})
	return myWindow
end

local function create_window_back(screenGui, title, AnchorPoint, size)
	local frame = Instance.new("Frame")
	frame.Position = UDim2.new(AnchorPoint.X, 0, AnchorPoint.Y, 0)
	frame.AnchorPoint = AnchorPoint
	frame.Size = size or UDim2.new(0, 400, 0.5, 0)
	frame.BackgroundColor3 = Color3.new(1, 1, 1)
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui

	return create_window(title, frame)
end

-- create explorer ingame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Explorer"
screenGui.Parent = LocalPlayer.PlayerGui

local propback = create_window_back(screenGui, "Properties", Vector2.new(1, 1), UDim2.new(0, 400, 0.3, 0))
local explorerback = create_window_back(screenGui, "Explorer", Vector2.new(1, 0), UDim2.new(0, 400, 0.7, 0))
local outputback = create_window_back(screenGui, "Output", Vector2.new(0.5, 1), UDim2.new(1, 0, 0.08, 0))
local toolbar = create_window_back(screenGui, "toolbar", Vector2.new(0.5, 0), UDim2.new(1, 0, 0.1, 0))

local expanded = {}
local yOffset = 0
local selected = nil

local loadedIcon = {}

local function lerp(a, b, t)
	return a + (b - a) * t
end

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function isMouseInRect(rect, mousePos)
	return mousePos.x >= rect.x
		and mousePos.x <= rect.x + rect.width
		and mousePos.y >= rect.y
		and mousePos.y <= rect.y + rect.height
end

local vend = renderer.GetFont("Vend")

local function DrawTree(instance, indent, winX, winY, winWidth)
	indent = indent or 0
	winX = winX or 0
	winY = winY or 0
	winWidth = winWidth or 350 -- fallback if not provided

	local children = instance:GetChildren()
	local hasChildren = #children > 0
	local isExpanded = expanded[instance]

	local nodeWidth = 330 -- width of the text button
	local nodeHeight = 25
	local padding = 10

	if not loadedIcon[instance.ClassName] then
		loadedIcon[instance.ClassName] =
			KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get(instance.ClassName .. ".png"))
	end
	local icon = loadedIcon[instance.ClassName]

	-- Node button (aligned to the right side)
	local btnX = winX + winWidth - nodeWidth - padding - (indent * -12)
	local btnY = winY + 10 + yOffset
	local rectData = {
		x = btnX,
		y = btnY,
		width = nodeWidth,
		height = nodeHeight,
	}
	local rect = structs.Rectangle:new(rectData)
	local toggleX = btnX + nodeWidth

	local transparency = 1
	local color = Color3.new()

	local mousePos = rl.GetMousePosition() -- returns vector {x, y}

	local DisplayAddIcon = false

	if isMouseInRect(rectData, mousePos) then
		transparency = 0.5
		DisplayAddIcon = true
	else
		transparency = 1
		DisplayAddIcon = false
	end

	rl.DrawRectangleRounded(rect, 0.5, 8, Color3ToRaylib(color, transparency))
	rl.DrawTextEx(vend, instance.Name, vector.create(btnX + 28, btnY + 5), 18, 1, KinemiumRaylib.const.WHITE)

	if DisplayAddIcon then
		local iconSize = nodeHeight - 4 -- scale icon to fit the button height
		local data = { x = toggleX - 27, y = winY + 10 + yOffset, width = iconSize, height = iconSize }
		rl.DrawTexturePro(
			addIcon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }), -- source rect
			structs.Rectangle:new(data), -- destination
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)
		if isMouseInRect(data, mousePos) then
			print("is diddy blud going to add")
		end
	end

	--[[

	local btn = rl.GuiButton(
		structs.Rectangle:new({
			x = btnX,
			y = btnY,
			width = nodeWidth,
			height = nodeHeight,
		}),
		instance.Name
	)

	if btn == 1 then
		selected = instance
		print("Selected:", instance.Name)
	end
	--]]

	if icon then
		local iconSize = nodeHeight - 4 -- scale icon to fit the button height
		rl.DrawTexturePro(
			icon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = icon.x, height = icon.y }), -- source rect
			structs.Rectangle:new({ x = btnX + 2, y = btnY + 2, width = iconSize, height = iconSize }), -- destination
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)
	end

	if hasChildren then
		local toggle = rl.GuiButton(
			structs.Rectangle:new({
				x = toggleX,
				y = winY + 10 + yOffset,
				width = 20,
				height = nodeHeight,
			}),
			isExpanded and "::" or "<"
		)
		if toggle == 1 then
			expanded[instance] = not isExpanded
		end
	end

	yOffset = yOffset + nodeHeight + 2

	-- Recurse into children if expanded
	if isExpanded then
		for _, child in ipairs(children) do
			DrawTree(child, indent + 1, winX, winY, winWidth)
		end
	end
end

-- Update window.stepped for Explorer tree
window.stepped = function(windowData)
	if windowData.title == "Explorer" then
		yOffset = 0
		local services = getServicesInOrder()
		for _, child in ipairs(services) do
			DrawTree(child, 0, windowData.x, windowData.y + 20)
		end
	end
end

renderer.Add2DStack(function(data)
	window.update()

	window.draw()
end)
