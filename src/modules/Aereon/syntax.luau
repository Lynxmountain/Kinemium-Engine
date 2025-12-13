local raylib = require("@raylib")
local const = raylib.const

local keywords = {
	["local"] = true,
	["function"] = true,
	["if"] = true,
	["then"] = true,
	["end"] = true,
	["while"] = true,
	["for"] = true,
	["do"] = true,
	["return"] = true,
	["break"] = true,
	["else"] = true,
	["elseif"] = true,
	["repeat"] = true,
	["until"] = true,
	["in"] = true,

	-- Kilang exclusives
	["import"] = true,
	["include"] = true,
	["kinemium"] = true,
}

local builtins = {
	["true"] = true,
	["false"] = true,
	["nil"] = true,
	["and"] = true,
	["or"] = true,
	["not"] = true,
}

local stdlib = {
	["print"] = true,
	["require"] = true,
	["table"] = true,
	["string"] = true,
	["math"] = true,
	["pairs"] = true,
	["ipairs"] = true,
	["tonumber"] = true,
	["tostring"] = true,
	["warn"] = true,
	["type"] = true,
	["error"] = true,
	["assert"] = true,
}

local operators = {
	["+"] = true,
	["-"] = true,
	["*"] = true,
	["/"] = true,
	["="] = true,
	["=="] = true,
	["~="] = true,
	["<"] = true,
	[">"] = true,
	["<="] = true,
	[">="] = true,
	[".."] = true,
	["#"] = true,
	["%"] = true,
}

local function processTokens(text, tokens)
	local i = 1
	while i <= #text do
		local char = text:sub(i, i)

		if char == '"' or char == "'" then
			local quote = char
			local j = i + 1
			while j <= #text do
				if text:sub(j, j) == quote and text:sub(j - 1, j - 1) ~= "\\" then
					break
				end
				j = j + 1
			end
			table.insert(tokens, { text = text:sub(i, j), color = const.GREEN })
			i = j + 1
		elseif char:match("%d") then
			local j = i
			while j <= #text and text:sub(j, j):match("[%d%.xabcdefABCDEF]") do
				j = j + 1
			end
			table.insert(tokens, { text = text:sub(i, j - 1), color = const.ORANGE })
			i = j
		elseif char:match("%a") or char == "_" then
			local j = i
			while j <= #text and text:sub(j, j):match("[%w_]") do
				j = j + 1
			end
			local word = text:sub(i, j - 1)
			local color = const.WHITE

			if keywords[word] then
				color = const.SKYBLUE
			elseif builtins[word] then
				color = const.MAGENTA
			elseif stdlib[word] then
				color = const.VIOLET
			end

			table.insert(tokens, { text = word, color = color })
			i = j
		elseif not char:match("%s") then
			local twoChar = text:sub(i, i + 1)
			if operators[twoChar] then
				table.insert(tokens, { text = twoChar, color = const.BLUE })
				i = i + 2
			elseif operators[char] or char:match("[%(%)%[%]{}:;,.]") then
				table.insert(tokens, { text = char, color = const.WHITE })
				i = i + 1
			else
				table.insert(tokens, { text = char, color = const.WHITE })
				i = i + 1
			end
		elseif char == "." then
			local j = i + 1
			if j <= #text and (text:sub(j, j):match("%a") or text:sub(j, j) == "_") then
				local k = j
				while k <= #text and text:sub(k, k):match("[%w_]") do
					k = k + 1
				end

				local remaining = text:sub(k)
				local hasAssignment = remaining:match("^%s*=") and not remaining:match("^%s*==")

				if hasAssignment then
					table.insert(tokens, { text = ".", color = const.WHITE })
					table.insert(tokens, { text = text:sub(j, k - 1), color = const.YELLOW }) -- or const.GOLD
					i = k
				else
					table.insert(tokens, { text = ".", color = const.WHITE })
					i = j
				end
			else
				table.insert(tokens, { text = ".", color = const.WHITE })
				i = i + 1
			end
		else
			table.insert(tokens, { text = char, color = const.WHITE })
			i = i + 1
		end
	end
end

local function highlightLine(line)
	local tokens = {}

	local commentStart = line:find("%-%-")
	if commentStart then
		local beforeComment = line:sub(1, commentStart - 1)
		local comment = line:sub(commentStart)

		if #beforeComment > 0 then
			processTokens(beforeComment, tokens)
		end

		table.insert(tokens, { text = comment, color = const.GRAY })
		return tokens
	end

	processTokens(line, tokens)
	return tokens
end

return {
	highlight = highlightLine,
}
