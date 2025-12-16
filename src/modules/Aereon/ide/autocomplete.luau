local completions = {
	"function ",
	"local ",
	"return ",
	"if ",
	"then",
	"else",
	"elseif ",
	"while ",
	"for ",
	"do",
	"break",
	"continue",
	"include ",
	"assert(",
	"typeof(",
	"import(",
	"require(",
}

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

	if #word < 2 then
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

local function getIndentLevel(line)
	local tabs = line:match("^\t+")
	if tabs then
		return #tabs
	end

	local spaces = line:match("^ +")
	if spaces then
		return math.floor(#spaces / 4) -- 4 spaces = 1 indent
	end

	return 0
end

return {
	completions = completions,
	getCurrentWord = getCurrentWord,
	updateAutocomplete = updateAutocomplete,
	completeWord = completeWord,
	getIndentLevel = getIndentLevel,

	step = function(
		editor,
		x,
		gutterwidth,
		padding,
		measureTextWidth,
		fontSize,
		spaces,
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
		if editor.isActive and editor.autocomplete.visible then
			local c = editor.text.cursor
			local textBeforeCursor = editor.text.lines[c.line]:sub(1, c.col - 1)
			local cx = x + gutterwidth + padding + measureTextWidth(textBeforeCursor, fontSize, spacing)
			local cy = y + padding + (c.line - 1) * lineHeight - editor.scrollY

			local acWidth = autocompletetheme.Width
			local acItemHeight = autocompletetheme.Height
			local acHeight = #editor.autocomplete.items * acItemHeight
			local acPadding = autocompletetheme.ListPadding

			local targetX = cx
			local targetY = cy - acHeight - 5

			if targetY < y then
				targetY = cy + lineHeight + 5
			end

			editor.autocomplete.targetX = targetX
			editor.autocomplete.targetY = targetY

			local lerpFactor = 1 - math.exp(-editor.autocomplete.lerpSpeed * dt)
			editor.autocomplete.currentX = editor.autocomplete.currentX
				+ (targetX - editor.autocomplete.currentX) * lerpFactor
			editor.autocomplete.currentY = editor.autocomplete.currentY
				+ (targetY - editor.autocomplete.currentY) * lerpFactor

			local acX = editor.autocomplete.currentX
			local acY = editor.autocomplete.currentY

			local background = rect.new(acX, acY, acWidth, acHeight)

			raylib.DrawRectangleRounded(rect:translate(background), autocompletetheme.CornerRadius, 15, theme_secondary)
			raylib.DrawRectangleRoundedLinesEx(
				rect:translate(background),
				autocompletetheme.CornerRadius,
				15,
				autocompletetheme.OutlineThickness,
				Color3ToRaylib(autocompletetheme.OutlineColor, autocompletetheme.OutlineTransparency)
			)

			for i, item in ipairs(editor.autocomplete.items) do
				local itemY = acY + (i - 1) * acItemHeight

				if i == editor.autocomplete.selectedIndex then
					local obj = rect.new(acX + 1, itemY + 1, acWidth - 2, acItemHeight - 2)
					raylib.DrawRectangleRounded(
						rect:translate(obj),
						autocompletetheme.CornerRadius,
						15,
						Color3ToRaylib(autocompletetheme.ItemSelectColor, 0)
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
			editor.autocomplete.currentX = editor.autocomplete.targetX or 0
			editor.autocomplete.currentY = editor.autocomplete.targetY or 0
		end
	end,
}
