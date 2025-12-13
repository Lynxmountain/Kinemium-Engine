local rl = require("@raylib")
--local aereon = require("@Kinemium.Aereon")

local ideBuffer = require("./idebuffer")
local EnumMap = require("@EnumMap")
local syntax = require("./syntax")
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

	function editor:getCode()
		local source = ""

		for _, line in ipairs(editor.text.lines) do
			source ..= line .. "\n"
		end

		return source
	end

	function editor.draw(x, y, size, gutterwidth)
		local dt = raylib.GetFrameTime()
		editor.caretTimer = editor.caretTimer + dt
		if editor.caretTimer >= editor.caretBlinkRate then
			editor.caretVisible = not editor.caretVisible
			editor.caretTimer = editor.caretTimer - editor.caretBlinkRate
		end

		-- #####################################
		-- RENDERING
		-- #####################################

		local background = rect.new(x, y, size.x, size.y)
		local lines = rect.new(x, y, gutterwidth, size.y)

		raylib.DrawRectangleRec(rect:translate(background), theme_background)
		raylib.DrawRectangleRec(rect:translate(lines), theme_secondary)

		local padding = 10

		local fontSize = 18
		local lineHeight = fontSize + 4

		local offset = vector.create(x + padding + gutterwidth, y + padding)

		for i, line in ipairs(editor.text.lines) do
			local yLine = y + padding + (i - 1) * lineHeight

			local tokens = syntax.highlight(line)

			if editor.isActive then
				local c = editor.text.cursor
				local lineY = y + padding + (c.line - 1) * lineHeight
				raylib.DrawRectangle(x + gutterwidth, lineY, size.x - gutterwidth, lineHeight, currentLineColor)
			end

			-- gutter
			local lineNumberText = tostring(i)
			local lineNumberX = x + padding
			local lineNumberY = yLine
			raylib.DrawTextEx(vend, lineNumberText, vector.create(lineNumberX, lineNumberY), fontSize, 3, const.WHITE)

			local xPos = x + gutterwidth + padding
			for _, tok in ipairs(tokens) do
				raylib.DrawTextEx(vend, tok.text, vector.create(xPos, yLine), fontSize, 3, tok.color)
				xPos += raylib.MeasureTextEx(vend, tok.text, fontSize, 3).x
			end
		end
		-- #####################################
		-- #####################################

		-- #####################################
		-- INPUT (these commented headers look much better <:)
		-- #####################################

		local fontSize = 18
		local spacing = 3 -- same as what you pass to DrawTextEx
		local charWidth = raylib.MeasureTextEx(vend, "M", fontSize, spacing).x

		if editor.isActive then
			local byte = raylib.GetCharPressed()
			local char = string.char(byte)
			if byte ~= 0 then
				editor.text:insertChar(char)
			end
		end

		rect.Button(background, function()
			editor.isActive = true

			if #editor.text.lines == 0 then
				editor.text.lines[1] = ""
			end

			local mousePos = raylib.GetMousePosition()
			local relX = mousePos.x - (x + gutterwidth + padding)
			local relY = mousePos.y - (y + padding)

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

		-- Caret

		if editor.isActive then
			local c = editor.text.cursor

			if editor.caretVisible then
				local textBeforeCursor = editor.text.lines[c.line]:sub(1, c.col - 1)
				local cx = x + gutterwidth + padding + measureTextWidth(textBeforeCursor, fontSize, spacing)
				local cy = y + padding + (c.line - 1) * lineHeight

				raylib.DrawRectangle(cx, cy, 2, lineHeight, const.WHITE)
			end

			-- Controls
			if raylib.IsKeyPressed(const.KeyboardKey.KEY_ENTER) == 1 then
				print("new Line")
				editor.text:newline()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_BACKSPACE) == 1 then
				print("rela")
				editor.text:backspace()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_LEFT) == 1 then
				print("left")
				editor.text:moveLeft()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_RIGHT) == 1 then
				print("Right")
				editor.text:moveRight()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_UP) == 1 then
				print("up")
				editor.text:moveUp()
			end

			if raylib.IsKeyPressed(const.KeyboardKey.KEY_DOWN) == 1 then
				print("down")
				editor.text:moveDown()
			end
		end
	end

	return editor
end
