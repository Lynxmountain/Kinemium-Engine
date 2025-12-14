local rl = require("@raylib")
--local aereon = require("@Kinemium.Aereon")

local ideBuffer = require("./idebuffer")
local EnumMap = require("@EnumMap")
local Color3 = require("@Color3")
local syntax = require("./syntax")
local task = zune.task
local structs = rl.structs
local const = rl.const

local completions = {
	"function",
	"local",
	"return",
	"end",
	"if",
	"then",
	"else",
	"elseif",
	"while",
	"for",
	"do",
	"break",
	"continue",
}

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local function getCurrentWord(editor)
	local c = editor.text.cursor
	local line = editor.text.lines[c.line] or ""
	local beforeCursor = line:sub(1, c.col - 1)

	local word = beforeCursor:match("([%w_]+)$") or ""
	return word
end

local function updateAutocomplete(editor)
	local word = getCurrentWord(editor)

	if #word == 0 then
		editor.autocomplete.visible = false
		return
	end

	local allItems = completions

	editor.autocomplete.items = {}
	for _, item in ipairs(allItems) do
		if item:sub(1, #word):lower() == word:lower() and item ~= word then
			table.insert(editor.autocomplete.items, item)
		end
	end

	if #editor.autocomplete.items > 0 then
		editor.autocomplete.visible = true
		editor.autocomplete.selectedIndex = 1
	else
		editor.autocomplete.visible = false
	end
end

local function completeWord(editor)
	if not editor.autocomplete.visible or #editor.autocomplete.items == 0 then
		return
	end

	local selectedItem = editor.autocomplete.items[editor.autocomplete.selectedIndex]
	local currentWord = getCurrentWord(editor)

	for i = 1, #currentWord do
		editor.text:backspace()
	end

	editor.text:insertString(selectedItem)
	editor.autocomplete.visible = false
end

return function(raylib: typeof(rl.lib), theme, aereon, game)
	local rect = aereon.rect()
	local editor = {}
	local KinemiumFontService = game:GetService("KinemiumFontService")
	local vend = KinemiumFontService.GetMonoFontDefault()

	local function measureTextWidth(text, fontSize, spacing)
		if #text == 0 then
			return 0
		end
		return raylib.MeasureTextEx(vend, text, fontSize, spacing).x
	end

	local function getColumnFromX(line, xPos, fontSize, spacing)
		if #line == 0 then
			return 1
		end

		local bestCol = 1
		local bestDist = math.abs(xPos)

		for col = 1, #line + 1 do
			local substr = line:sub(1, col - 1)
			local width = measureTextWidth(substr, fontSize, spacing)
			local dist = math.abs(xPos - width)

			if dist < bestDist then
				bestDist = dist
				bestCol = col
			end
		end

		return bestCol
	end

	--[[
        ide = {
			BackgroundColor = Color3.new(0.05, 0.05, 0.05),
			SecondaryBackgroundColor = Color3.new(0.07, 0.07, 0.07),
			TextColor = Color3.new(1, 1, 1),
		},
    --]]
	local theme = theme.ide
	local theme_background, theme_secondary, theme_text, currentLineColor =
		Color3ToRaylib(theme.BackgroundColor, 0),
		Color3ToRaylib(theme.SecondaryBackgroundColor, 0),
		Color3ToRaylib(theme.TextColor, 0),
		Color3ToRaylib(theme.currentLineColor, 0)

	editor.text = ideBuffer.create()
	editor.text.lines = {}
	editor.isActive = false
	editor.caretVisible = true
	editor.caretTimer = 0
	editor.caretBlinkRate = 0.5 -- seconds

	editor.autocomplete = {
		visible = false,
		items = { "function", "local", "return", "end", "if", "then" },
		selectedIndex = 1,
		currentX = 0,
		currentY = 0,
		targetX = 0,
		targetY = 0,
		lerpSpeed = 15,
	}

	function editor:getCode()
		local source = ""

		for _, line in ipairs(editor.text.lines) do
			source ..= line .. "\n"
		end

		return source
	end

	editor.scrollY = 0
	editor.maxScroll = 0

	function editor.draw(x, y, size, gutterwidth)
		local dt = raylib.GetFrameTime()
		editor.caretTimer = editor.caretTimer + dt
		if editor.caretTimer >= editor.caretBlinkRate then
			editor.caretVisible = not editor.caretVisible
			editor.caretTimer = editor.caretTimer - editor.caretBlinkRate
		end

		local padding = 10
		local fontSize = 18
		local lineHeight = fontSize + 4
		local spacing = 1

		local contentHeight = #editor.text.lines * lineHeight
		local viewportHeight = size.y - (padding * 2)
		editor.maxScroll = math.max(0, contentHeight - viewportHeight)

		local background = rect.new(x, y, size.x, size.y)
		if rect.MouseIsInRect(background) then
			local wheel = raylib.GetMouseWheelMove()
			if wheel ~= 0 then
				local scrollSpeed = lineHeight * 3 -- scroll 3 lines at a time
				editor.scrollY = editor.scrollY - (wheel * scrollSpeed)
				editor.scrollY = math.clamp(editor.scrollY, 0, editor.maxScroll)
			end
		end

		local firstVisibleLine = math.floor(editor.scrollY / lineHeight) + 1
		local lastVisibleLine = math.ceil((editor.scrollY + viewportHeight) / lineHeight)
		firstVisibleLine = math.max(1, firstVisibleLine)
		lastVisibleLine = math.min(#editor.text.lines, lastVisibleLine)

		-- RENDERING
		local lines = rect.new(x, y, gutterwidth, size.y)
		raylib.DrawRectangleRec(rect:translate(background), theme_background)
		raylib.DrawRectangleRec(rect:translate(lines), theme_secondary)

		if editor.isActive then
			local c = editor.text.cursor
			local lineY = y + padding + (c.line - 1) * lineHeight - editor.scrollY
			if lineY >= y and lineY < y + size.y then
				raylib.DrawRectangle(x + gutterwidth, lineY, size.x - gutterwidth, lineHeight, currentLineColor)
			end
		end

		for i = firstVisibleLine, lastVisibleLine do
			local line = editor.text.lines[i]
			if not line then
				break
			end

			local yLine = y + padding + (i - 1) * lineHeight - editor.scrollY

			local tokens = syntax.highlight(line)

			local lineNumberText = tostring(i)
			local lineNumberX = x + padding
			raylib.DrawTextEx(vend, lineNumberText, vector.create(lineNumberX, yLine), fontSize, spacing, const.WHITE)

			local xPos = x + gutterwidth + padding
			for _, tok in ipairs(tokens) do
				task.spawn(function()
					raylib.DrawTextEx(vend, tok.text, vector.create(xPos, yLine), fontSize, spacing, tok.color)
				end)
				xPos += raylib.MeasureTextEx(vend, tok.text, fontSize, spacing).x
			end
		end

		if editor.isActive then
			local byte = raylib.GetCharPressed()
			local char = string.char(byte)
			if byte ~= 0 then
				editor.text:insertChar(char)
				updateAutocomplete(editor)
			end
		end

		rect.Button(background, function()
			editor.isActive = true

			if #editor.text.lines == 0 then
				editor.text.lines[1] = ""
			end

			local mousePos = raylib.GetMousePosition()
			local relX = mousePos.x - (x + gutterwidth + padding)
			local relY = mousePos.y - (y + padding) + editor.scrollY -- Add scroll offset

			local clickedLine = math.floor(relY / lineHeight) + 1
			clickedLine = math.clamp(clickedLine, 1, #editor.text.lines)

			local clickedCol = getColumnFromX(editor.text.lines[clickedLine], relX, fontSize, spacing)

			editor.text.cursor.line = clickedLine
			editor.text.cursor.col = clickedCol
		end)

		if rect.MouseIsInRect(background) then
			raylib.SetMouseCursor(EnumMap.KinemiumMouseCursor.MOUSE_CURSOR_IBEAM.Value)
		else
			raylib.SetMouseCursor(EnumMap.KinemiumMouseCursor.MOUSE_CURSOR_DEFAULT.Value)
			if raylib.IsMouseButtonReleased(0) == 1 then
				if editor.isActive then
					editor.isActive = false
				end
			end
		end

		if editor.isActive and editor.caretVisible then
			local c = editor.text.cursor
			local textBeforeCursor = editor.text.lines[c.line]:sub(1, c.col - 1)
			local cx = x + gutterwidth + padding + measureTextWidth(textBeforeCursor, fontSize, spacing)
			local cy = y + padding + (c.line - 1) * lineHeight - editor.scrollY

			if cy >= y and cy < y + size.y then
				raylib.DrawRectangle(cx, cy, 2, lineHeight, const.WHITE)
			end

			local caretTop = (c.line - 1) * lineHeight
			local caretBottom = c.line * lineHeight

			if caretTop < editor.scrollY then
				editor.scrollY = caretTop
			elseif caretBottom > editor.scrollY + viewportHeight then
				editor.scrollY = caretBottom - viewportHeight
			end
		end

		-- AUTOCOMPLETE with smooth lerp animation
		if editor.isActive and editor.autocomplete.visible then
			local c = editor.text.cursor
			local textBeforeCursor = editor.text.lines[c.line]:sub(1, c.col - 1)
			local cx = x + gutterwidth + padding + measureTextWidth(textBeforeCursor, fontSize, spacing)
			local cy = y + padding + (c.line - 1) * lineHeight - editor.scrollY

			local acWidth = 200
			local acItemHeight = 20
			local acHeight = #editor.autocomplete.items * acItemHeight
			local acPadding = 5

			-- Calculate target position
			local targetX = cx
			local targetY = cy - acHeight - 5

			if targetY < y then
				targetY = cy + lineHeight + 5
			end

			-- Update target
			editor.autocomplete.targetX = targetX
			editor.autocomplete.targetY = targetY

			-- Smooth lerp to target position
			local lerpFactor = 1 - math.exp(-editor.autocomplete.lerpSpeed * dt)
			editor.autocomplete.currentX = editor.autocomplete.currentX
				+ (targetX - editor.autocomplete.currentX) * lerpFactor
			editor.autocomplete.currentY = editor.autocomplete.currentY
				+ (targetY - editor.autocomplete.currentY) * lerpFactor

			-- Use lerped position for rendering
			local acX = editor.autocomplete.currentX
			local acY = editor.autocomplete.currentY

			raylib.DrawRectangle(acX, acY, acWidth, acHeight, theme_secondary)
			raylib.DrawRectangleLines(acX, acY, acWidth, acHeight, theme_text)

			for i, item in ipairs(editor.autocomplete.items) do
				local itemY = acY + (i - 1) * acItemHeight

				if i == editor.autocomplete.selectedIndex then
					raylib.DrawRectangle(
						acX + 1,
						itemY + 1,
						acWidth - 2,
						acItemHeight - 2,
						Color3ToRaylib(Color3.new(0.2, 0.3, 0.5), 0)
					)
				end

				raylib.DrawTextEx(
					vend,
					item,
					vector.create(acX + acPadding, itemY + 2),
					fontSize - 2,
					spacing,
					theme_text
				)
			end
		else
			-- Reset position when hidden
			editor.autocomplete.currentX = editor.autocomplete.targetX or 0
			editor.autocomplete.currentY = editor.autocomplete.targetY or 0
		end

		if editor.autocomplete.visible then
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
				editor.autocomplete.selectedIndex =
					math.min(editor.autocomplete.selectedIndex + 1, #editor.autocomplete.items)
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
				editor.autocomplete.selectedIndex = math.max(editor.autocomplete.selectedIndex - 1, 1)
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				local selectedItem = editor.autocomplete.items[editor.autocomplete.selectedIndex]
				editor.text:insertString(selectedItem)
				editor.autocomplete.visible = false
			elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				editor.autocomplete.visible = false
			end
		end

		if editor.isActive then
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_TAB) == 1 then
				if editor.autocomplete.visible then
					completeWord(editor)
				else
					editor.text:insertChar("\t")
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				if editor.autocomplete.visible then
					completeWord(editor)
				else
					editor.text:newline()
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				if editor.autocomplete.visible then
					editor.autocomplete.visible = false
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				editor.text:backspace()
				updateAutocomplete(editor)
			end

			-- paste
			if editor.autocomplete.visible then
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					editor.autocomplete.selectedIndex =
						math.min(editor.autocomplete.selectedIndex + 1, #editor.autocomplete.items)
				elseif raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					editor.autocomplete.selectedIndex = math.max(editor.autocomplete.selectedIndex - 1, 1)
				end
			else
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_LEFT) == 1 then
					editor.text:moveLeft()
					updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
					editor.text:moveRight()
					updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					editor.text:moveUp()
					updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					editor.text:moveDown()
					updateAutocomplete(editor)
				end
			end

			if raylib.IsKeyDown(341) == 1 then
				if raylib.IsKeyDown(86) == 1 then
					local text = raylib.GetClipboardText()
					local bufferLength = buffer.len(text:span())
					local data = buffer.readstring(text:span(), 0, bufferLength - 1)
					data = string.gsub(data, "\r\n", "\n")
					data = string.gsub(data, "\r", "\n")
					editor.text:insertString(data)
					updateAutocomplete(editor)
				end
			end
		end
	end

	return editor
end
