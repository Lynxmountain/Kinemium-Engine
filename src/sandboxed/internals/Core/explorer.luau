-- devcell

local KinemiumRaylib = game:GetService("KinemiumRaylib")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")
local KinemiumFontService = game:GetService("KinemiumFontService")

local Selection = game:GetService("Selection")

local spring = import("@kispring")
local selectspring = spring.new(2, 5)
local hoverspring = spring.new(2, 5)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local rl = KinemiumRaylib.lib
local structs = KinemiumRaylib.structs
local renderer = KinemiumRaylib.renderer
local EngineSignal = game.EngineSignal
local vend = KinemiumFontService.GetDefaultFont()
local classes = Instance.getClasses()

local lastClickTime = {}
local doubleClickThreshold = 0.3

if game.Context ~= Enum.GameContext.Editor then
	return
end

if FlagExists("client") then
	return
end

local function DoubleClicked(instance)
	if instance:IsA("Script") or instance:IsA("ModuleScript") or instance:IsA("LocalScript") then
		EngineSignal:Fire("idestate", true, instance)
	else
		EngineSignal:Fire("idestate", false, instance)
	end
end

local serviceOrder = {
	"Scene",
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

local instanceTypes = {}

for class, _ in pairs(classes) do
	table.insert(instanceTypes, class)
end

local addMenuOpen = {}
local addMenuWidth = 150
local addMenuItemHeight = 22

local lastClicked = nil

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

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")
KinemiumIconLoader.new("ArrowRight", "./src/assets/images/icons/vanilla3/ui/16x/200/ArrowRight.png")
KinemiumIconLoader.new("ArrowDown", "./src/assets/images/icons/vanilla3/ui/16x/200/ArrowDown.png")

local png = KinemiumIconLoader.Get("Add")

local ArrowRight, ArrowDown =
	KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowRight")),
	KinemiumIconLoader.ToTexture(KinemiumIconLoader.Get("ArrowDown"))

local addIcon = KinemiumIconLoader.ToTexture(png)

local windowRegistry = {}

local aereon = import("@Kinemium.Aereon")
local window = aereon.window(game)
local arect = aereon.rect()

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

-- create explorer ingame
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Explorer"
screenGui.Parent = LocalPlayer.PlayerGui

local explorerback, frame = create_window_back(screenGui, "Explorer", Vector2.new(1, 0), UDim2.new(0, 400, 0.7, 0))

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

local function handleSelection(instance, rectData, mousePos)
	if isMouseInRect(rectData, mousePos) then
		if rl.IsMouseButtonPressed(0) == 1 then
			local currentTime = os.clock()
			local ctrl = rl.IsKeyDown(341) == 1 or rl.IsKeyDown(345) == 1
			local shift = rl.IsKeyDown(340) == 1 or rl.IsKeyDown(344) == 1

			if lastClickTime[instance] and (currentTime - lastClickTime[instance]) < doubleClickThreshold then
				DoubleClicked(instance)
				expanded[instance] = not expanded[instance]
				lastClickTime[instance] = nil
				return
			end

			lastClickTime[instance] = currentTime

			if shift and lastClicked then
				local parent = instance.Parent
				if parent then
					local siblings = parent:GetChildren()

					local startIndex, endIndex
					for i, obj in ipairs(siblings) do
						if obj == lastClicked then
							startIndex = i
						end
						if obj == instance then
							endIndex = i
						end
					end

					if startIndex and endIndex then
						if startIndex > endIndex then
							startIndex, endIndex = endIndex, startIndex
						end

						for i = startIndex, endIndex do
							if not Selection.IsSelected(siblings[i]) then
								Selection.Add(siblings[i])
							end
						end
					end
				end
			elseif ctrl then
				-- ctrl
				if not Selection.IsSelected(instance) then
					Selection.Add(instance)
				else
					Selection.Remove(instance)
				end
			else
				-- normal selection
				Selection.Clear()

				Selection.Add(instance)

				lastClicked = instance
			end
		end
	end
end

task.spawn(function()
	for _, class in pairs(instanceTypes) do
		if not loadedIcon[class] then
			local png = KinemiumIconLoader.Get(class .. ".png")
			if png then
				loadedIcon[class] = KinemiumIconLoader.ToTexture(png)
			end
		end
	end
end)

local addMenuScroll = {}

local function drawAdditionMenu(instance, mousePos, btnY, toggleX)
	local itemW = 200
	local itemH = 22
	local maxVisibleItems = 15
	local menuPadding = 4

	if addMenuOpen[instance] then
		if not addMenuScroll[instance] then
			addMenuScroll[instance] = 0
		end

		local totalItems = #instanceTypes
		local menuHeight = math.min(totalItems, maxVisibleItems) * itemH + menuPadding * 2
		local contentHeight = totalItems * itemH

		local menuX = toggleX - itemW - 10
		local menuY = btnY + 4

		rl.DrawRectangleRounded(
			structs.Rectangle:new({
				x = menuX,
				y = menuY,
				width = itemW,
				height = menuHeight,
			}),
			0.2,
			6,
			Color3ToRaylib(Color3.new(0.12, 0.12, 0.12), 0)
		)

		local menuRect = { x = menuX, y = menuY, width = itemW, height = menuHeight }
		if isMouseInRect(menuRect, mousePos) then
			local mouseWheel = rl.GetMouseWheelMove()
			if mouseWheel ~= 0 then
				addMenuScroll[instance] = addMenuScroll[instance] - (mouseWheel * itemH * 2)
				local maxScroll = math.max(0, contentHeight - (maxVisibleItems * itemH))
				addMenuScroll[instance] = math.max(0, math.min(addMenuScroll[instance], maxScroll))
			end
		end

		local scissorPadding = 2
		rl.BeginScissorMode(
			math.floor(menuX + scissorPadding),
			math.floor(menuY + menuPadding),
			math.floor(itemW - scissorPadding * 2),
			math.floor(menuHeight - menuPadding * 2)
		)

		for i, class in ipairs(instanceTypes) do
			local itemX = menuX
			local itemY = menuY + menuPadding + ((i - 1) * itemH) - addMenuScroll[instance]
			local itemRect = { x = itemX, y = itemY, width = itemW, height = itemH }

			if itemY + itemH >= menuY and itemY <= menuY + menuHeight then
				local isHovered = isMouseInRect(itemRect, mousePos)
					and mousePos.y >= menuY + menuPadding
					and mousePos.y <= menuY + menuHeight - menuPadding

				if isHovered then
					rl.DrawRectangle(itemX, itemY, itemW, itemH, Color3ToRaylib(Color3.new(0.2, 0.2, 0.2), 1))

					if rl.IsMouseButtonPressed(0) == 1 then
						local success, newObj = pcall(Instance.new, class)
						if success then
							newObj.Parent = instance
						end
						addMenuOpen[instance] = false
						addMenuScroll[instance] = 0
					end
				end

				local iconTex = loadedIcon[class]
				if iconTex then
					local iconSize = itemH - 6
					rl.DrawTexturePro(
						iconTex.texture,
						structs.Rectangle:new({ x = 0, y = 0, width = iconTex.x, height = iconTex.y }),
						structs.Rectangle:new({
							x = itemX + 4,
							y = itemY + 3,
							width = iconSize,
							height = iconSize,
						}),
						vector.create(0, 0),
						0,
						KinemiumRaylib.const.WHITE
					)
				end

				rl.DrawTextEx(
					vend,
					class,
					vector.create(itemX + itemH + 4, itemY + 3),
					17,
					1,
					KinemiumRaylib.const.WHITE
				)
			end
		end

		rl.EndScissorMode()

		if contentHeight > maxVisibleItems * itemH then
			local scrollbarWidth = 6
			local scrollbarX = menuX + itemW - scrollbarWidth - 2
			local scrollbarHeight = menuHeight - menuPadding * 2
			local scrollbarTrackHeight = scrollbarHeight - 4

			local thumbHeight = math.max(20, (scrollbarTrackHeight * (maxVisibleItems * itemH)) / contentHeight)
			local maxScroll = contentHeight - (maxVisibleItems * itemH)
			local thumbY = menuY
				+ menuPadding
				+ 2
				+ (addMenuScroll[instance] / maxScroll) * (scrollbarTrackHeight - thumbHeight)

			rl.DrawRectangleRounded(
				structs.Rectangle:new({
					x = scrollbarX,
					y = menuY + menuPadding + 2,
					width = scrollbarWidth,
					height = scrollbarTrackHeight,
				}),
				0.5,
				4,
				Color3ToRaylib(Color3.new(0.08, 0.08, 0.08), 0)
			)

			rl.DrawRectangleRounded(
				structs.Rectangle:new({
					x = scrollbarX,
					y = thumbY,
					width = scrollbarWidth,
					height = thumbHeight,
				}),
				0.5,
				4,
				Color3ToRaylib(Color3.new(0.3, 0.3, 0.3), 0)
			)
		end
	end
end

local function DrawTree(instance, indent, winX, winY, winWidth)
	indent = indent or 0
	winX = winX or 0
	winY = winY or 0
	winWidth = winWidth or 350 -- fallback if not provided

	if instance.Destroyed == true then
		return
	end

	if instance.ExplorerHidden == true then
		return
	end

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

	local btnX = winX + 25 + winWidth - nodeWidth - padding - (indent * -12)
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
	local temp = { value = 0 }
	if isMouseInRect(rectData, mousePos) then
		transparency = 0.5
		DisplayAddIcon = true
	else
		transparency = 1
		DisplayAddIcon = false
	end

	if Selection.IsSelected(instance) then
		color = Color3.new(0, 0.533333, 1)
		transparency = 0
	end

	rl.DrawRectangleRounded(rect, 0.5, 8, Color3ToRaylib(color, transparency))
	rl.DrawTextEx(vend, instance.Name, vector.create(btnX + 28, btnY + 5), 18, 1, KinemiumRaylib.const.WHITE)

	if DisplayAddIcon then
		local iconSize = nodeHeight - 4 -- scale icon to fit the button height
		local data = { x = toggleX - 50, y = winY + 10 + yOffset, width = iconSize, height = iconSize }
		rl.DrawTexturePro(
			addIcon.texture,
			structs.Rectangle:new({ x = 0, y = 0, width = addIcon.x, height = addIcon.y }), -- source rect
			structs.Rectangle:new(data), -- destination
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)
		if isMouseInRect(data, mousePos) and rl.IsMouseButtonReleased(0) == 1 then
			if not addMenuOpen[instance] then
				for key, _ in pairs(addMenuOpen) do
					addMenuOpen[key] = false
				end
			end
			addMenuOpen[instance] = not addMenuOpen[instance]
		end
	end

	-- selection
	handleSelection(instance, rectData, mousePos)

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

	-- 261 is delete key (yes i dont care)
	if rl.IsKeyDown(261) == 1 then
		if Selection.Get()[1] then
			for _, v in pairs(Selection.Get()) do
				v:Destroy()
			end
		end
	end

	-- double clicks
	local object = arect.new(btnX, btnY, nodeWidth, nodeHeight)
	arect.RightClick(object, function()
		print("right click")
	end)

	if hasChildren then
		-- place the toggle button on the left side
		local toggleSize = 20

		local toggleTexture = expanded[instance] and ArrowDown or ArrowRight
		local buttonData = { x = rectData.x - 25, y = rectData.y, width = toggleSize, height = toggleSize }
		local toggleSourceRect =
			structs.Rectangle:new({ x = 0, y = 0, width = toggleTexture.x, height = toggleTexture.y })
		local toggleDestRect = structs.Rectangle:new(buttonData)

		rl.DrawTexturePro(
			toggleTexture.texture,
			toggleSourceRect,
			toggleDestRect,
			vector.create(0, 0),
			0,
			KinemiumRaylib.const.WHITE
		)

		if isMouseInRect(buttonData, rl.GetMousePosition()) and rl.IsMouseButtonReleased(0) == 1 then
			expanded[instance] = not expanded[instance]
		end

		-- shift icon and text right to account for toggle button
		btnX = btnX + toggleSize + 5
	end

	yOffset = yOffset + nodeHeight + 2

	drawAdditionMenu(instance, mousePos, btnY, toggleX)

	if expanded[instance] then
		for _, child in ipairs(children) do
			DrawTree(child, indent + 1, winX, winY, winWidth)
		end
	end
end

local windowObject

RunService.GuiRender:Connect(function()
	if not windowObject then
		return
	end
	renderer.blur:DrawBlurredRegion(
		windowObject.x,
		windowObject.y,
		windowObject.width,
		windowObject.height,
		Color3ToRaylib(Color3.new(1, 1, 1), 0)
	)
end)

window.stepped = function(windowData)
	if windowData.title == "Explorer" then
		windowObject = windowData
		yOffset = 0

		if rl.IsWindowResized() == 1 then
			window.dragspring:target(windowData, {
				x = frame.AbsolutePosition.X,
				y = frame.AbsolutePosition.Y,
				width = frame.AbsoluteSize.X,
				height = frame.AbsoluteSize.Y,
			})
		end

		local services = getServicesInOrder()
		for _, child in ipairs(services) do
			DrawTree(child, 0, windowData.x, windowData.y + 20)
		end
	end
end

RunService.RenderStepped:Connect(function(dt: number)
	hoverspring:step(dt)

	--aereon.step()
end)
