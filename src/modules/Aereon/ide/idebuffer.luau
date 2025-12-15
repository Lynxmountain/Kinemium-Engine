-- buffer.lua
local buffer = {}
buffer.__index = buffer

function buffer.create()
	return setmetatable({
		lines = { "" },
		cursor = { line = 1, col = 1 },
	}, buffer)
end

function buffer:insertChar(ch)
	local line = self.lines[self.cursor.line]
	local left = line:sub(1, self.cursor.col - 1)
	local right = line:sub(self.cursor.col)

	self.lines[self.cursor.line] = left .. ch .. right
	self.cursor.col += 1
end

function buffer:backspace()
	local c = self.cursor
	local line = self.lines[c.line]

	if c.col > 1 then
		self.lines[c.line] = line:sub(1, c.col - 2) .. line:sub(c.col)
		c.col -= 1
		return
	end

	if c.line == 1 then
		return
	end

	local prevLine = self.lines[c.line - 1]
	self.lines[c.line - 1] = prevLine .. line

	table.remove(self.lines, c.line)

	c.line -= 1
	c.col = #prevLine + 1
end

function buffer:newline()
	local c = self.cursor
	local line = self.lines[c.line]

	local left = line:sub(1, c.col - 1)
	local right = line:sub(c.col)

	self.lines[c.line] = left
	table.insert(self.lines, c.line + 1, right)

	c.line += 1
	c.col = 1
end

function buffer:moveLeft()
	local c = self.cursor
	if c.col > 1 then
		c.col -= 1
	elseif c.line > 1 then
		c.line -= 1
		c.col = #self.lines[c.line] + 1
	end
end

function buffer:moveRight()
	local c = self.cursor
	local line = self.lines[c.line]

	if c.col <= #line then
		c.col += 1
	elseif c.line < #self.lines then
		c.line += 1
		c.col = 1
	end
end

function buffer:moveUp()
	local c = self.cursor
	if c.line > 1 then
		c.line -= 1
		local len = self._lineLengths and self._lineLengths[c.line] or #self.lines[c.line]
		c.col = math.min(c.col, len + 1)
	end
end

function buffer:moveDown()
	local c = self.cursor
	if c.line < #self.lines then
		c.line += 1
		local len = self._lineLengths and self._lineLengths[c.line] or #self.lines[c.line]
		c.col = math.min(c.col, len + 1)
	end
end

function buffer:delete()
	local c = self.cursor
	local line = self.lines[c.line]

	if c.col <= #line then
		self.lines[c.line] = line:sub(1, c.col - 1) .. line:sub(c.col + 1)
		return
	end

	if c.line < #self.lines then
		self.lines[c.line] = self.lines[c.line] .. self.lines[c.line + 1]
		table.remove(self.lines, c.line + 1)
	end
end

function buffer:insertString(str)
	local lines = string.split(str, "\n")
	if #lines == 1 then
		local c = self.cursor
		local line = self.lines[c.line]
		self.lines[c.line] = line:sub(1, c.col - 1) .. lines[1] .. line:sub(c.col)
		c.col += #lines[1]
		return
	end

	local c = self.cursor
	local line = self.lines[c.line]
	local left = line:sub(1, c.col - 1)
	local right = line:sub(c.col)

	self.lines[c.line] = left .. lines[1]

	for i = 2, #lines - 1 do
		table.insert(self.lines, c.line + i - 1, lines[i])
	end

	table.insert(self.lines, c.line + #lines - 1, lines[#lines] .. right)

	c.line += #lines - 1
	c.col = #lines[#lines] + 1
end

function buffer:getText()
	return table.concat(self.lines, "\n")
end

function buffer:setCursor(line, col)
	line = math.clamp(line, 1, #self.lines)
	col = math.clamp(col, 1, #self.lines[line] + 1)

	self.cursor.line = line
	self.cursor.col = col
end

function buffer:clear()
	self.lines = { "" }
	self.cursor.line = 1
	self.cursor.col = 1
end

return buffer
