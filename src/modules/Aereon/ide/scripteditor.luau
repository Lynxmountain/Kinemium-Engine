local rl = require("@raylib")
--local aereon = require("@Kinemium.Aereon")

local ideBuffer = require("./idebuffer")
local EnumMap = require("@EnumMap")
local Color3 = require("@Color3")
local syntax = require("./syntax")
local autocomplete = require("./autocomplete")
local task = zune.task
local structs = rl.structs
local const = rl.const

local function Color3ToRaylib(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

return function(raylib: typeof(rl.lib), theme, aereon, game)
	local rect = aereon.rect()
	local editor = {}
	local KinemiumFontService = game:GetService("KinemiumFontService")
	local IconLoader = game:GetService("KinemiumIconLoader")

	local icons = {
		constant = "./src/assets/images/icons/vanilla3/general/32x/200/WireframeRendering.png",
		functionVar = "./src/assets/images/icons/vanilla3/general/32x/200/Function.png",
	}

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

	local autocompletetheme = theme.autocomplete

	editor.text = ideBuffer.create()
	editor.text.lines = {}
	editor.isActive = false
	editor.caretVisible = true
	editor.caretTimer = 0
	editor.caretBlinkRate = 0.5 -- seconds

	editor.autocomplete = {
		visible = false,
		items = autocomplete.completions,
		selectedIndex = 1,
		currentX = 0,
		currentY = 0,
		targetX = 0,
		targetY = 0,
		lerpSpeed = 35,
	}

	function editor:getCode()
		local buf = table.create(#editor.text.lines)
		for i, line in ipairs(editor.text.lines) do
			buf[i] = line
		end
		return table.concat(buf, "\n")
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

		local padding = 20
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

			local indentLevel = autocomplete.getIndentLevel(line)
			local indentWidth = 14
			local indentStartX = x + gutterwidth + padding

			for lvl = 1, indentLevel do
				local rx = indentStartX + (lvl - 1) * indentWidth

				raylib.DrawRectangle(
					rx,
					yLine,
					2,
					lineHeight,
					structs.Color:new({
						r = 255,
						g = 255,
						b = 255,
						a = 40, -- transparency
					})
				)
			end

			editor._highlightCache = editor._highlightCache or {}
			local tokens = editor._highlightCache[i]
			if not tokens then
				tokens = syntax.highlight(line)
				editor._highlightCache[i] = tokens
			end

			local lineNumberText = tostring(i)
			local lineNumberX = x + padding
			raylib.DrawTextEx(vend, lineNumberText, vector.create(lineNumberX, yLine), fontSize, spacing, const.WHITE)

			local xPos = x + gutterwidth + padding
			for _, tok in ipairs(tokens) do
				raylib.DrawTextEx(vend, tok.text, vector.create(xPos, yLine), fontSize, spacing, tok.color)

				xPos += raylib.MeasureTextEx(vend, tok.text, fontSize, spacing).x
			end
		end

		if editor.isActive then
			local byte = raylib.GetCharPressed()
			local char = string.char(byte)
			if byte ~= 0 then
				editor.text:insertChar(char)
				autocomplete.updateAutocomplete(editor)
				editor._highlightCache = {}
			end
		end

		rect.Button(background, function()
			editor.isActive = true

			if #editor.text.lines == 0 then
				editor.text.lines[1] = ""
			end

			local mousePos = raylib.GetMousePosition()
			local relX = mousePos.x - (x + gutterwidth + padding)
			local relY = mousePos.y - (y + padding) + editor.scrollY

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

		-- AUTOCOMPLETE
		autocomplete.step(
			editor,
			x,
			gutterwidth,
			padding,
			measureTextWidth,
			fontSize,
			5,
			lineHeight,
			autocompletetheme,
			rect,
			raylib,
			Color3ToRaylib,
			vend,
			spacing,
			theme_text,
			theme_secondary,
			y,
			dt
		)

		if editor.isActive then
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_TAB) == 1 then
				if editor.autocomplete.visible then
					autocomplete.completeWord(editor)
					editor._highlightCache = {}
				else
					editor.text:insertChar("\t")
					editor._highlightCache = {}
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				if editor.autocomplete.visible then
					autocomplete.completeWord(editor)
					editor._highlightCache = {}
				else
					editor.text:newline()
					editor._highlightCache = {}
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ESCAPE) == 1 then
				if editor.autocomplete.visible then
					editor.autocomplete.visible = false
				end
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				editor.text:backspace()
				autocomplete.updateAutocomplete(editor)
				editor._highlightCache = {}
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
					autocomplete.updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
					editor.text:moveRight()
					autocomplete.updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
					editor.text:moveUp()
					autocomplete.updateAutocomplete(editor)
				end
				if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
					editor.text:moveDown()
					autocomplete.updateAutocomplete(editor)
				end
			end

			if raylib.IsKeyDown(341) == 1 then
				if raylib.IsKeyReleased(86) == 1 then
					local text = raylib.GetClipboardText()
					local bufferLength = buffer.len(text:span())
					local data = buffer.readstring(text:span(), 0, bufferLength - 1)
					data = string.gsub(data, "\r\n", "\n")
					data = string.gsub(data, "\r", "\n")
					editor.text:insertString(data)
					autocomplete.updateAutocomplete(editor)
					editor._highlightCache = {}
				end
			end
		end
	end

	return editor
end
