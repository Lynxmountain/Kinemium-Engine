-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local renderer = KinemiumRaylib.renderer
local rl = KinemiumRaylib.lib
local Selection = game:GetService("Selection")
local LogService = game:GetService("LogService")
local structs = KinemiumRaylib.structs
local vend = KinemiumFontService.GetDefaultFont()

export type elementTitle = string

export type RibbonBarCategory = {
	title: string,
	elements: {
		[elementTitle]: {
			type: "Imageelement" | "Textelement" | "TextLabel" | "Custom",
			callback: () -> (),
			render: () -> (),

			imagePath: string?,
			text: string?,
		},
	},
}

if game.Context ~= Enum.GameContext.Editor then
	return
end

KinemiumIconLoader.new("Play", "src/assets/images/icons/vanilla3/general/32x/200/Play.png")

local png = KinemiumIconLoader.Get("Play")
local PlayIcon = KinemiumIconLoader.ToTexture(png)

local categoryRegistry = {
	Category = {
		elements = {
			{
				type = "ImageButton",
				text = "Playtest",
				callback = function()
					print("hello world")
				end,
				hoverTransparency = 0.5,
				hoverColor = Color3.new(0, 0, 0),
				roundness = 0.2,
				texture = PlayIcon,
			},
			{
				type = "ImageButton",

				callback = function()
					print("Stopping the simulation")
				end,
				hoverTransparency = 0.5,
				hoverColor = Color3.new(1, 0, 0),
				roundness = 0.2,
			},
		},
	},
}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game, nil, 1)
local aRect = aereon.rect()
local elements = {}

local blacklisted = {
	"Children",
}

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

	return create_window(title, frame), frame
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Toolbar"
screenGui.Parent = LocalPlayer.PlayerGui

local propback, frame = create_window_back(screenGui, "Toolbar", Vector2.new(0, 0), UDim2.new(1, 0, 0, 122))

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function renderButton(i, name, element, windowData)
	local winX, winY = windowData.x, windowData.y + 30
	local winWidth = windowData.width
	local cellWidth = element.width or 50
	local cellHeight = element.height or 50
	local paddingLeft = 15
	local padding = element.padding or 20
	local rectX = winX + paddingLeft + i * (cellWidth + padding)
	local rectY = winY
	local rectData = aRect.new(rectX, rectY, cellWidth, cellHeight)
	local mousePos = rl.GetMousePosition()

	local transparency = 1
	local color = Color3.new(0.5, 0.5, 0.5)

	if aRect.MouseIsInRect(rectData) then
		color = element.hoverColor
		transparency = element.hoverTransparency
	end

	aRect.Button(rectData, function()
		element.callback(element, rectData)
	end)

	local bgColor = Color3ToRaylib(color, transparency)
	rl.DrawRectangleRounded(aRect:translate(rectData), element.roundness, 8, bgColor)

	if element.texture then
		rl.DrawTexturePro(
			element.texture.texture, -- wow
			structs.Rectangle:new({ x = 0, y = 0, width = element.texture.x, height = element.texture.y }), -- source rect
			aRect:translate(rectData), -- destination
			vector.create(0, 0),
			element.rotation or 0,
			KinemiumRaylib.const.WHITE
		)
	end

	-- text
	if name then
		local textX = rectData.x + cellWidth / 2 - (#name * 9) / 2 -- center text horizontally
		local textY = rectData.y + cellHeight + 5 -- below the element with 5px padding
		rl.DrawTextEx(vend, name, vector.create(textX, textY), 18, 1, KinemiumRaylib.const.WHITE)
	end

	if element.render then
		element.render(aRect)
	end
end

local function renderSeperator(i, windowData, element)
	local winX, winY = windowData.x, windowData.y + 30
	local paddingLeft = 15
	local padding = element.padding or 20
	local rectX = winX + paddingLeft + i * (50 + padding)
	local rectY = winY

	local sepColor = Color3ToRaylib(element.color or Color3.new(0.7, 0.7, 0.7), 0)
	rl.DrawRectangle(rectX, rectY, element.width or 2, element.height or 50, sepColor)
end

window.stepped = function(windowData)
	if windowData.title == "Toolbar" then
		windowData.x = frame.AbsolutePosition.X
		windowData.y = frame.AbsolutePosition.Y
		windowData.width = frame.AbsoluteSize.X
		windowData.height = frame.AbsoluteSize.Y

		local i = 0
		for _, category in pairs(categoryRegistry) do
			local elements = category.elements
			for _, element in pairs(elements) do
				if element.type == "ImageButton" then
					game.EngineSignal:Fire("ToolbarUpdateElement", element)

					renderButton(i, element.text, element, windowData)
				elseif element.type == "Separator" then
					renderSeperator(i, windowData, element)
				end
				i += 1
			end
		end
	end
end
