local raylib = require("@raylib")
local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 10 },
		modifiers = {},

		-- Colors
		backgroundColor = color3.new(0.08, 0.09, 0.10),
		panelColor = color3.new(0.11, 0.12, 0.13),
		headerColor = color3.new(0.09, 0.10, 0.11),
		itemColor = color3.new(0.13, 0.14, 0.15),
		hoverColor = color3.new(0.17, 0.18, 0.20),
		selectedColor = color3.new(0.22, 0.40, 0.60),
		textColor = color3.new(0.92, 0.93, 0.95),
		subtextColor = color3.new(0.58, 0.60, 0.62),
		accentColor = color3.new(0.35, 0.70, 1.0),
		dividerColor = color3.new(0.16, 0.17, 0.18),
		scrollbarColor = color3.new(0.28, 0.30, 0.32),
		scrollbarHoverColor = color3.new(0.35, 0.37, 0.40),
		borderColor = color3.new(0.20, 0.21, 0.23),
		shadowColor = color3.new(0, 0, 0),

		-- Layout
		headerHeight = 46,
		itemHeight = 30,
		padding = 14,
		spacing = 4,
		indentSize = 18,
		iconSize = 14,
		searchHeight = 36,

		-- Panel widths
		leftPanelWidth = 350,
		middlePanelWidth = 350,

		-- Font
		font = data.font,
		fontSize = data.fontSize or 14,
		fontSpacing = 0.5,
		headerFontSize = 17,
		headerFontSpacing = 0.8,

		-- Data structure
		categories = data.categories or {
			{
				name = "Classes",
				count = 858,
				expanded = true,
				items = {
					{
						name = "Object",
						type = "class",
						expanded = false,
						children = {
							{ name = "AnimationNode", type = "class" },
							{
								name = "Capture",
								type = "class",
								expanded = false,
								children = {
									{ name = "ScreenshotCapture", type = "class" },
									{ name = "VideoCapture", type = "class" },
								},
							},
							{ name = "ConfigSnapshot", type = "class" },
						},
					},
					{
						name = "Instance",
						type = "class",
						expanded = false,
						children = {
							{ name = "Accessory", type = "class" },
							{ name = "Animation", type = "class" },
						},
					},
				},
			},
			{
				name = "Enums",
				count = 545,
				expanded = false,
				items = {
					{ name = "AccessModifierType", type = "enum" },
					{ name = "AccessoryType", type = "enum" },
					{ name = "ActionType", type = "enum" },
				},
			},
			{
				name = "Types",
				count = 69,
				expanded = false,
				items = {
					{ name = "DataType", type = "type" },
					{ name = "BinaryString", type = "type" },
					{ name = "Color3", type = "type" },
				},
			},
		},

		middleItems = {},
		middleScrollOffset = 0,
		middleSearch = "",

		selectedItem = nil,
		rightScrollOffset = 0,

		-- Interaction
		leftScrollOffset = 0,
		selectedCategoryIndex = 1,
		hoveredItem = nil,
		searchFocused = false,

		-- Animation states
		hoverStates = {},
		expandAnimations = {},
		scrollbarAlpha = {},
		scrollbarDrag = {
			activePanel = nil,
			offset = 0,
		},

		onItemSelect = data.onItemSelect,
	}

	local wrapper = {}

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	local function drawText(text, x, y, fontSize, spacing, color)
		if config.font then
			raylib.lib.DrawTextEx(config.font, text, vector.create(x, y), fontSize, spacing, color:ToRaylib(0))
		else
			raylib.lib.DrawText(text, x, y, fontSize, color:ToRaylib(0))
		end
	end

	local function measureText(text, fontSize, spacing)
		if config.font then
			local textSize = raylib.lib.MeasureTextEx(config.font, text, fontSize, spacing)
			return textSize.x
		else
			return raylib.lib.MeasureText(text, fontSize)
		end
	end

	local function truncateText(text, maxWidth, fontSize, spacing)
		maxWidth = math.max(0, maxWidth)
		if maxWidth == 0 then
			return ""
		end

		if measureText(text, fontSize, spacing) <= maxWidth then
			return text
		end

		local ellipsis = "..."
		local ellipsisWidth = measureText(ellipsis, fontSize, spacing)
		if ellipsisWidth > maxWidth then
			return ""
		end

		local truncated = ""
		for i = 1, #text do
			local character = string.sub(text, i, i)
			local candidate = truncated .. character

			if measureText(candidate, fontSize, spacing) + ellipsisWidth > maxWidth then
				break
			end

			truncated = candidate
		end

		return truncated .. ellipsis
	end

	local function wrapText(text, maxWidth, fontSize, spacing)
		local wrappedLines = {}
		maxWidth = math.max(1, maxWidth)

		local function addWrappedLine(line)
			if line == "" then
				table.insert(wrappedLines, "")
				return
			end

			if measureText(line, fontSize, spacing) <= maxWidth then
				table.insert(wrappedLines, line)
				return
			end

			local currentLine = ""
			for i = 1, #line do
				local character = string.sub(line, i, i)
				local candidate = currentLine .. character

				if currentLine ~= "" and measureText(candidate, fontSize, spacing) > maxWidth then
					table.insert(wrappedLines, currentLine)
					currentLine = character
				else
					currentLine = candidate
				end
			end

			if currentLine ~= "" then
				table.insert(wrappedLines, currentLine)
			end
		end

		local function addParagraph(paragraph)
			if paragraph == "" then
				table.insert(wrappedLines, "")
			else
				local currentLine = ""
				for word in string.gmatch(paragraph, "%S+") do
					local candidate = currentLine == "" and word or (currentLine .. " " .. word)

					if currentLine ~= "" and measureText(candidate, fontSize, spacing) > maxWidth then
						addWrappedLine(currentLine)
						currentLine = word
					else
						currentLine = candidate
					end
				end

				if currentLine ~= "" then
					addWrappedLine(currentLine)
				end
			end
		end

		local paragraphStart = 1
		while true do
			local newlineIndex = string.find(text, "\n", paragraphStart, true)
			if newlineIndex then
				addParagraph(string.sub(text, paragraphStart, newlineIndex - 1))
				paragraphStart = newlineIndex + 1
			else
				addParagraph(string.sub(text, paragraphStart))
				break
			end
		end

		if #wrappedLines == 0 then
			table.insert(wrappedLines, "")
		end

		return wrappedLines
	end

	local function drawWrappedLines(lines, x, y, fontSize, spacing, color, lineHeight)
		for index, line in ipairs(lines) do
			drawText(line, x, y + (index - 1) * lineHeight, fontSize, spacing, color)
		end
	end

	local function getHoverState(key, dt, isHovered)
		if not config.hoverStates[key] then
			config.hoverStates[key] = 0
		end

		if isHovered then
			config.hoverStates[key] = math.min(config.hoverStates[key] + dt * 10, 1)
		else
			config.hoverStates[key] = math.max(config.hoverStates[key] - dt * 10, 0)
		end

		return config.hoverStates[key]
	end

	local scrollKeys = {
		left = "leftScrollOffset",
		middle = "middleScrollOffset",
		right = "rightScrollOffset",
	}

	local function getScrollOffset(panelId)
		local key = scrollKeys[panelId]
		if not key then
			return 0
		end

		return config[key] or 0
	end

	local function setScrollOffset(panelId, value)
		local key = scrollKeys[panelId]
		if not key then
			return
		end

		config[key] = value
	end

	local function drawIcon(x, y, size, iconType, color)
		local centerX = x + size / 2
		local centerY = y + size / 2
		local thickness = 1.5

		if iconType == "class" then
			-- Filled circle with border
			raylib.lib.DrawCircle(centerX, centerY, size / 3, color:ToRaylib(0))
			raylib.lib.DrawCircleLines(centerX, centerY, size / 3, color:ToRaylib(0))
		elseif iconType == "enum" then
			-- Filled square with border
			raylib.lib.DrawRectangle(
				centerX - size / 3,
				centerY - size / 3,
				size * 2 / 3,
				size * 2 / 3,
				color:ToRaylib(0)
			)
			raylib.lib.DrawRectangleLines(
				centerX - size / 3,
				centerY - size / 3,
				size * 2 / 3,
				size * 2 / 3,
				color:ToRaylib(0)
			)
		elseif iconType == "type" then
			-- Diamond shape
			raylib.lib.DrawTriangle(
				vector.create(centerX, centerY - size / 3),
				vector.create(centerX + size / 3, centerY),
				vector.create(centerX, centerY + size / 3),
				color:ToRaylib(0)
			)
			raylib.lib.DrawTriangle(
				vector.create(centerX, centerY - size / 3),
				vector.create(centerX - size / 3, centerY),
				vector.create(centerX, centerY + size / 3),
				color:ToRaylib(0)
			)
		elseif iconType == "expanded" then
			-- Down chevron
			raylib.lib.DrawTriangle(
				vector.create(centerX - size / 3, centerY - size / 6),
				vector.create(centerX + size / 3, centerY - size / 6),
				vector.create(centerX, centerY + size / 4),
				color:ToRaylib(0)
			)
		elseif iconType == "collapsed" then
			-- Right chevron
			raylib.lib.DrawTriangle(
				vector.create(centerX - size / 5, centerY - size / 3),
				vector.create(centerX + size / 4, centerY),
				vector.create(centerX - size / 5, centerY + size / 3),
				color:ToRaylib(0)
			)
		end
	end

	local function drawTreeItem(item, x, y, width, indent, mousePos, mousePressed, dt)
		local itemKey = tostring(item) .. "_" .. x .. "_" .. y
		local itemRect = rect.new(x, y, width, config.itemHeight)
		local isHovered = rect.MouseIsInRect(itemRect)
		local hoverAlpha = getHoverState(itemKey, dt, isHovered)
		local isSelected = config.selectedItem == item

		-- Background with rounded corners and smooth hover
		if isSelected then
			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(x + 2, y + 1, width - 4, config.itemHeight - 2)),
				0.15,
				6,
				config.selectedColor:ToRaylib(0)
			)
		elseif hoverAlpha > 0 then
			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(x + 2, y + 1, width - 4, config.itemHeight - 2)),
				0.15,
				6,
				config.hoverColor:ToRaylib(0)
			)
		end

		-- Expand/collapse arrow
		if item.children and #item.children > 0 then
			local arrowX = x + indent
			local arrowY = y + config.itemHeight / 2 - config.iconSize / 2
			drawIcon(arrowX, arrowY, config.iconSize, item.expanded and "expanded" or "collapsed", config.subtextColor)

			if isHovered and mousePressed and mousePos.x < x + indent + config.iconSize + 4 then
				item.expanded = not item.expanded
			end
		end

		-- Icon
		local iconX = x + indent + (item.children and (config.iconSize + 4) or 0)
		local iconY = y + config.itemHeight / 2 - config.iconSize / 2
		local iconColor = isSelected and config.textColor or config.accentColor
		drawIcon(iconX, iconY, config.iconSize, item.type, iconColor)

		-- Text
		local textX = iconX + config.iconSize + 8
		local textY = y + (config.itemHeight - config.fontSize) / 2
		local visibleText =
			truncateText(item.name, (x + width - config.padding) - textX, config.fontSize, config.fontSpacing)
		drawText(visibleText, textX, textY, config.fontSize, config.fontSpacing, config.textColor)

		-- Click handling
		if isHovered and mousePressed and (not item.children or mousePos.x >= x + indent + config.iconSize + 4) then
			config.selectedItem = item
			if config.onItemSelect then
				config.onItemSelect(item)
			end
		end

		local nextY = y + config.itemHeight

		-- Draw children if expanded
		if item.expanded and item.children then
			for _, child in ipairs(item.children) do
				nextY = drawTreeItem(child, x, nextY, width, indent + config.indentSize, mousePos, mousePressed, dt)
			end
		end

		return nextY
	end

	local function drawScrollbar(panelRect, contentHeight, panelId, dt)
		local visibleHeight = panelRect.height
		local maxScroll = math.max(0, contentHeight - visibleHeight)

		if maxScroll <= 0 then
			if config.scrollbarDrag.activePanel == panelId then
				config.scrollbarDrag.activePanel = nil
			end
			setScrollOffset(panelId, 0)
			return
		end

		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
		local mouseDown = raylib.lib.IsMouseButtonDown(0) == 1
		local scrollOffset = math.clamp(getScrollOffset(panelId), 0, maxScroll)
		local trackY = panelRect.y
		local scrollbarWidth = 6
		local scrollbarHeight = math.min(visibleHeight, math.max(30, (visibleHeight / contentHeight) * visibleHeight))
		local scrollbarRange = math.max(0, visibleHeight - scrollbarHeight)
		local scrollbarY = trackY + (scrollOffset / maxScroll) * scrollbarRange
		local scrollbarX = panelRect.x + panelRect.width - scrollbarWidth - 4

		setScrollOffset(panelId, scrollOffset)

		local scrollbarRect = rect.new(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)
		local trackRect = rect.new(scrollbarX, trackY, scrollbarWidth, visibleHeight)
		local isHovered = rect.MouseIsInRect(scrollbarRect)
		local isTrackHovered = rect.MouseIsInRect(trackRect)
		local isDragging = config.scrollbarDrag.activePanel == panelId

		-- Fade in/out scrollbar
		if not config.scrollbarAlpha[panelId] then
			config.scrollbarAlpha[panelId] = 0
		end

		if rect.MouseIsInRect(panelRect) or isTrackHovered or isDragging then
			config.scrollbarAlpha[panelId] = math.min(config.scrollbarAlpha[panelId] + dt * 5, 1)
		else
			config.scrollbarAlpha[panelId] = math.max(config.scrollbarAlpha[panelId] - dt * 3, 0)
		end

		if mousePressed and isHovered then
			config.scrollbarDrag.activePanel = panelId
			config.scrollbarDrag.offset = mousePos.y - scrollbarY
			isDragging = true
		elseif mousePressed and isTrackHovered then
			local newScrollbarY = math.clamp(mousePos.y - scrollbarHeight / 2, trackY, trackY + scrollbarRange)
			local percent = scrollbarRange > 0 and ((newScrollbarY - trackY) / scrollbarRange) or 0
			setScrollOffset(panelId, percent * maxScroll)
			config.scrollbarDrag.activePanel = panelId
			config.scrollbarDrag.offset = mousePos.y - newScrollbarY
			scrollbarY = newScrollbarY
			scrollOffset = percent * maxScroll
			isDragging = true
		end

		if isDragging then
			if mouseDown then
				local newScrollbarY =
					math.clamp(mousePos.y - config.scrollbarDrag.offset, trackY, trackY + scrollbarRange)
				local percent = scrollbarRange > 0 and ((newScrollbarY - trackY) / scrollbarRange) or 0
				setScrollOffset(panelId, percent * maxScroll)
				scrollbarY = newScrollbarY
			else
				config.scrollbarDrag.activePanel = nil
				isDragging = false
			end
		end

		scrollbarRect = rect.new(scrollbarX, scrollbarY, scrollbarWidth, scrollbarHeight)

		if config.scrollbarAlpha[panelId] > 0.01 then
			local scrollbarColor = (isHovered or isDragging) and config.scrollbarHoverColor or config.scrollbarColor
			raylib.lib.DrawRectangleRounded(rect:translate(scrollbarRect), 0.5, 4, scrollbarColor:ToRaylib(0))
		end
	end

	-- Update middle panel based on selected category
	local function updateMiddlePanel()
		config.middleItems = {}
		if config.selectedCategoryIndex > 0 and config.selectedCategoryIndex <= #config.categories then
			local category = config.categories[config.selectedCategoryIndex]

			-- Flatten all items from the category
			local function addItems(items)
				for _, item in ipairs(items) do
					if
						config.middleSearch == ""
						or string.find(string.lower(item.name), string.lower(config.middleSearch))
					then
						table.insert(config.middleItems, item)
					end
					if item.children then
						addItems(item.children)
					end
				end
			end

			if category.items then
				addItems(category.items)
			end
		end
	end

	wrapper.render = function(dt)
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1
		local scrollWheel = raylib.lib.GetMouseWheelMove()

		-- Background with border
		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.shadowColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangleRounded(
			rect:translate(rect.new(r.x + 1, r.y + 1, r.width - 2, r.height - 2)),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		-- Calculate panel positions
		local leftPanel = rect.new(r.x + 1, r.y + 1, config.leftPanelWidth, r.height - 2)
		local middlePanel = rect.new(r.x + config.leftPanelWidth + 2, r.y + 1, config.middlePanelWidth, r.height - 2)
		local rightPanel = rect.new(
			r.x + config.leftPanelWidth + config.middlePanelWidth + 3,
			r.y + 1,
			r.width - config.leftPanelWidth - config.middlePanelWidth - 4,
			r.height - 2
		)

		-- Draw dividers with subtle gradient effect
		raylib.lib.DrawRectangle(
			r.x + config.leftPanelWidth + 1,
			r.y + 1,
			1,
			r.height - 2,
			config.dividerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			r.x + config.leftPanelWidth + config.middlePanelWidth + 2,
			r.y + 1,
			1,
			r.height - 2,
			config.dividerColor:ToRaylib(0)
		)

		-- LEFT PANEL: Categories tree
		local leftHeaderRect = rect.new(leftPanel.x, leftPanel.y, leftPanel.width, config.headerHeight)
		local leftContentViewport = rect.new(
			leftPanel.x,
			leftPanel.y + config.headerHeight,
			leftPanel.width,
			leftPanel.height - config.headerHeight
		)

		-- Header gradient effect
		raylib.lib.DrawRectangle(
			leftHeaderRect.x,
			leftHeaderRect.y,
			leftHeaderRect.width,
			config.headerHeight,
			config.headerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			leftHeaderRect.x,
			leftHeaderRect.y + config.headerHeight - 1,
			leftHeaderRect.width,
			1,
			config.dividerColor:ToRaylib(0)
		)

		drawText(
			"API Reference",
			leftHeaderRect.x + config.padding,
			leftHeaderRect.y + 16,
			config.headerFontSize,
			config.headerFontSpacing,
			config.textColor
		)

		raylib.lib.BeginScissorMode(
			leftContentViewport.x,
			leftContentViewport.y,
			leftContentViewport.width,
			leftContentViewport.height
		)

		local currentY = leftContentViewport.y + config.padding - config.leftScrollOffset
		local contentStartY = currentY

		if rect.MouseIsInRect(leftContentViewport) then
			config.leftScrollOffset = math.max(0, config.leftScrollOffset - scrollWheel * 25)
		end

		for i, category in ipairs(config.categories) do
			local categoryKey = "cat_" .. i
			local categoryRect = rect.new(
				leftPanel.x + config.padding,
				currentY,
				leftPanel.width - config.padding * 2,
				config.itemHeight
			)
			local isHovered = rect.MouseIsInRect(categoryRect)
			local hoverAlpha = getHoverState(categoryKey, dt, isHovered)

			-- Background with rounded corners
			if hoverAlpha > 0 then
				raylib.lib.DrawRectangleRounded(
					rect:translate(
						rect.new(categoryRect.x, categoryRect.y + 1, categoryRect.width, categoryRect.height - 2)
					),
					0.15,
					6,
					config.hoverColor:ToRaylib(0)
				)
			end

			-- Arrow with rotation animation
			drawIcon(
				categoryRect.x + 2,
				categoryRect.y + config.itemHeight / 2 - config.iconSize / 2,
				config.iconSize,
				category.expanded and "expanded" or "collapsed",
				config.subtextColor
			)

			-- Category name
			local textX = categoryRect.x + config.iconSize + 8
			local textY = categoryRect.y + (config.itemHeight - config.fontSize) / 2
			local countText = tostring(category.count)
			local badgeFontSize = config.fontSize - 2
			local badgeHeight = 18
			local countWidth = measureText(countText, badgeFontSize, config.fontSpacing)
			local badgeWidth = math.max(30, countWidth + 14)
			local badgeRect = rect.new(
				categoryRect.x + categoryRect.width - badgeWidth,
				categoryRect.y + (config.itemHeight - badgeHeight) / 2,
				badgeWidth,
				badgeHeight
			)
			local categoryText =
				truncateText(category.name, badgeRect.x - textX - 8, config.fontSize, config.fontSpacing)
			drawText(categoryText, textX, textY, config.fontSize, config.fontSpacing, config.textColor)

			-- Count badge

			raylib.lib.DrawRectangleRounded(rect:translate(badgeRect), 0.3, 6, config.accentColor:ToRaylib(0))
			drawText(
				countText,
				badgeRect.x + (badgeRect.width - countWidth) / 2,
				badgeRect.y + (badgeRect.height - badgeFontSize) / 2 - 1,
				badgeFontSize,
				config.fontSpacing,
				config.textColor
			)

			-- Click handling
			if isHovered and mousePressed then
				category.expanded = not category.expanded
				config.selectedCategoryIndex = i
				updateMiddlePanel()
			end

			currentY = currentY + config.itemHeight

			-- Draw items if expanded
			if category.expanded and category.items then
				for _, item in ipairs(category.items) do
					currentY = drawTreeItem(
						item,
						leftPanel.x + config.padding,
						currentY,
						leftPanel.width - config.padding * 2,
						config.indentSize,
						mousePos,
						mousePressed,
						dt
					)
				end
			end
		end

		local leftContentHeight = currentY - contentStartY
		raylib.lib.EndScissorMode()

		drawScrollbar(leftContentViewport, leftContentHeight, "left", dt)

		-- MIDDLE PANEL: Filtered list
		local middleHeaderRect = rect.new(middlePanel.x, middlePanel.y, middlePanel.width, config.headerHeight)
		local middleContentViewport = rect.new(
			middlePanel.x,
			middlePanel.y + config.headerHeight + config.searchHeight + config.padding * 2,
			middlePanel.width,
			middlePanel.height - config.headerHeight - config.searchHeight - config.padding * 2
		)
		raylib.lib.DrawRectangle(
			middleHeaderRect.x,
			middleHeaderRect.y,
			middleHeaderRect.width,
			middleHeaderRect.height,
			config.headerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			middleHeaderRect.x,
			middleHeaderRect.y + config.headerHeight - 1,
			middleHeaderRect.width,
			1,
			config.dividerColor:ToRaylib(0)
		)

		if config.selectedCategoryIndex > 0 and config.selectedCategoryIndex <= #config.categories then
			local category = config.categories[config.selectedCategoryIndex]
			drawText(
				truncateText(
					category.name,
					middleHeaderRect.width - config.padding * 2,
					config.headerFontSize,
					config.headerFontSpacing
				),
				middleHeaderRect.x + config.padding,
				middleHeaderRect.y + 16,
				config.headerFontSize,
				config.headerFontSpacing,
				config.textColor
			)
		end

		-- Search bar with focus effect
		local searchRect = rect.new(
			middlePanel.x + config.padding,
			middlePanel.y + config.headerHeight + config.padding,
			middlePanel.width - config.padding * 2,
			config.searchHeight
		)
		local searchHovered = rect.MouseIsInRect(searchRect)
		local searchHoverAlpha = getHoverState("search", dt, searchHovered)

		-- Search background
		raylib.lib.DrawRectangleRounded(rect:translate(searchRect), 0.18, 8, config.panelColor:ToRaylib(0))

		-- Search icon
		local searchIconX = searchRect.x + 10
		local searchIconY = searchRect.y + (config.searchHeight - 12) / 2
		raylib.lib.DrawCircleLines(searchIconX + 5, searchIconY + 5, 4, config.subtextColor:ToRaylib(0))
		raylib.lib.DrawLineEx(
			vector.create(searchIconX + 8, searchIconY + 8),
			vector.create(searchIconX + 11, searchIconY + 11),
			1.5,
			config.subtextColor:ToRaylib(0)
		)

		drawText(
			truncateText(
				config.middleSearch == "" and "Search..." or config.middleSearch,
				searchRect.width - 38,
				config.fontSize,
				config.fontSpacing
			),
			searchRect.x + 28,
			searchRect.y + (config.searchHeight - config.fontSize) / 2,
			config.fontSize,
			config.fontSpacing,
			config.middleSearch == "" and config.subtextColor or config.textColor
		)

		raylib.lib.BeginScissorMode(
			middleContentViewport.x,
			middleContentViewport.y,
			middleContentViewport.width,
			middleContentViewport.height
		)

		currentY = middlePanel.y
			+ config.headerHeight
			+ config.searchHeight
			+ config.padding * 2
			- config.middleScrollOffset
		contentStartY = currentY

		if rect.MouseIsInRect(middleContentViewport) then
			config.middleScrollOffset = math.max(0, config.middleScrollOffset - scrollWheel * 25)
		end

		if #config.middleItems == 0 then
			updateMiddlePanel()
		end

		for i, item in ipairs(config.middleItems) do
			local itemKey = "middle_" .. i
			local itemRect = rect.new(
				middlePanel.x + config.padding,
				currentY,
				middlePanel.width - config.padding * 2,
				config.itemHeight
			)
			local isHovered = rect.MouseIsInRect(itemRect)
			local hoverAlpha = getHoverState(itemKey, dt, isHovered)
			local isSelected = config.selectedItem == item

			-- Background
			if isSelected then
				raylib.lib.DrawRectangleRounded(
					rect:translate(rect.new(itemRect.x + 2, itemRect.y + 1, itemRect.width - 4, itemRect.height - 2)),
					0.15,
					6,
					config.selectedColor:ToRaylib(0)
				)
			elseif hoverAlpha > 0 then
				raylib.lib.DrawRectangleRounded(
					rect:translate(rect.new(itemRect.x + 2, itemRect.y + 1, itemRect.width - 4, itemRect.height - 2)),
					0.15,
					6,
					config.hoverColor:ToRaylib(0)
				)
			end

			-- Icon
			local iconColor = isSelected and config.textColor or config.accentColor
			drawIcon(
				itemRect.x + 6,
				itemRect.y + config.itemHeight / 2 - config.iconSize / 2,
				config.iconSize,
				item.type,
				iconColor
			)

			-- Text
			local itemText = truncateText(
				item.name,
				itemRect.width - config.iconSize - config.padding - 18,
				config.fontSize,
				config.fontSpacing
			)
			drawText(
				itemText,
				itemRect.x + config.iconSize + 14,
				itemRect.y + (config.itemHeight - config.fontSize) / 2,
				config.fontSize,
				config.fontSpacing,
				config.textColor
			)

			if isHovered and mousePressed then
				config.selectedItem = item
				if config.onItemSelect then
					config.onItemSelect(item)
				end
			end

			currentY = currentY + config.itemHeight
		end

		local middleContentHeight = currentY - contentStartY
		raylib.lib.EndScissorMode()

		drawScrollbar(middleContentViewport, middleContentHeight, "middle", dt)

		-- RIGHT PANEL: Detail view
		local rightHeaderRect = rect.new(rightPanel.x, rightPanel.y, rightPanel.width, config.headerHeight)
		local rightContentViewport = rect.new(
			rightPanel.x,
			rightPanel.y + config.headerHeight,
			rightPanel.width,
			rightPanel.height - config.headerHeight
		)
		raylib.lib.DrawRectangle(
			rightHeaderRect.x,
			rightHeaderRect.y,
			rightHeaderRect.width,
			rightHeaderRect.height,
			config.headerColor:ToRaylib(0)
		)
		raylib.lib.DrawRectangle(
			rightHeaderRect.x,
			rightHeaderRect.y + config.headerHeight - 1,
			rightHeaderRect.width,
			1,
			config.dividerColor:ToRaylib(0)
		)

		if config.selectedItem then
			drawText(
				truncateText(
					config.selectedItem.name,
					rightHeaderRect.width - config.padding * 2,
					config.headerFontSize,
					config.headerFontSpacing
				),
				rightHeaderRect.x + config.padding,
				rightHeaderRect.y + 16,
				config.headerFontSize,
				config.headerFontSpacing,
				config.textColor
			)

			raylib.lib.BeginScissorMode(
				rightContentViewport.x,
				rightContentViewport.y,
				rightContentViewport.width,
				rightContentViewport.height
			)

			currentY = rightContentViewport.y + config.padding - config.rightScrollOffset
			contentStartY = currentY

			if rect.MouseIsInRect(rightContentViewport) then
				config.rightScrollOffset = math.max(0, config.rightScrollOffset - scrollWheel * 25)
			end

			-- Type badge
			local typeText = config.selectedItem.type:upper()
			local badgeFontSize = config.fontSize - 2
			local badgeHeight = 22
			local typeWidth = measureText(typeText, badgeFontSize, config.fontSpacing)
			local badgeWidth = typeWidth + 18
			local badgeRect = rect.new(rightPanel.x + config.padding, currentY, badgeWidth, badgeHeight)

			raylib.lib.DrawRectangleRounded(rect:translate(badgeRect), 0.25, 6, config.accentColor:ToRaylib(0))
			drawText(
				typeText,
				badgeRect.x + (badgeRect.width - typeWidth) / 2,
				badgeRect.y + (badgeRect.height - badgeFontSize) / 2 - 1,
				badgeFontSize,
				config.fontSpacing,
				config.textColor
			)

			if config.selectedItem.super then
				local superText = "Inherits from " .. config.selectedItem.super
				drawText(
					superText,
					rightPanel.x + config.padding + badgeWidth + 12,
					currentY + (badgeHeight - config.fontSize) / 2,
					config.fontSize,
					config.fontSpacing,
					config.subtextColor
				)
			end

			currentY = currentY + badgeHeight + 12

			-- Section divider
			raylib.lib.DrawRectangle(
				rightPanel.x + config.padding,
				currentY,
				rightPanel.width - config.padding * 2,
				1,
				config.dividerColor:ToRaylib(0)
			)
			currentY = currentY + 16

			-- Description section
			drawText(
				"Description",
				rightPanel.x + config.padding,
				currentY,
				config.fontSize + 1,
				config.fontSpacing,
				config.textColor
			)
			currentY = currentY + 28

			-- Description content in a subtle box
			local descText = config.selectedItem.description
				or (
					"Detailed information about "
					.. config.selectedItem.name
					.. ". This would typically include usage examples, parameters, return values, and other relevant documentation."
				)
			local descBoxWidth = rightPanel.width - config.padding * 2
			local descPaddingX = 12
			local descPaddingY = 12
			local descLineHeight = config.fontSize + 6
			local descTextWidth = descBoxWidth - descPaddingX * 2
			local descLines = wrapText(descText, descTextWidth, config.fontSize, config.fontSpacing)
			local descTextHeight = ((#descLines - 1) * descLineHeight) + config.fontSize
			local descBoxHeight = descTextHeight + descPaddingY * 2

			raylib.lib.DrawRectangleRounded(
				rect:translate(rect.new(rightPanel.x + config.padding, currentY, descBoxWidth, descBoxHeight)),
				0.12,
				8,
				config.panelColor:ToRaylib(0)
			)

			drawWrappedLines(
				descLines,
				rightPanel.x + config.padding + descPaddingX,
				currentY + descPaddingY,
				config.fontSize,
				config.fontSpacing,
				config.subtextColor,
				descLineHeight
			)

			currentY = currentY + descBoxHeight + 16

			local rightContentHeight = currentY - contentStartY
			raylib.lib.EndScissorMode()
		else
			drawText(
				"Details",
				rightHeaderRect.x + config.padding,
				rightHeaderRect.y + 16,
				config.headerFontSize,
				config.headerFontSpacing,
				config.textColor
			)

			-- Empty state
			local emptyY = rightPanel.y + rightPanel.height / 2 - 30
			drawText(
				"Select an item to view details",
				rightPanel.x + config.padding,
				emptyY,
				config.fontSize,
				config.fontSpacing,
				config.subtextColor
			)
		end

		if config.selectedItem then
			drawScrollbar(rightContentViewport, currentY - contentStartY, "right", dt)
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
