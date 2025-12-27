local wrapper = {}

local io = zune.io
local process = zune.process
local task = zune.task

function wrapper:init(callback)
	task.spawn(function()
		io.stdout:write("Kilang Terminal Initialized\n")

		while true do
			io.stdout:write("> ")

			local line = io.stdin:read()

			if line == nil then
				io.stdout:write("\n")
				break
			end

			if not line:match("^%s*$") then
				callback(line)
			end
		end

		process.exit(0)
	end)
end

return wrapper
