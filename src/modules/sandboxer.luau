local sandboxer = {}

local luau = zune.luau
local fs = zune.fs
local task = zune.task
local filesystem = require("./filesystem")

sandboxer.enviroment = {}
sandboxer.native_code_gen = true
sandboxer.thread = { active = {} }

local function gsub(code)
	-- transform into kinemium compatible code
	code = string.gsub(code, "require", "krequire")
	code = string.gsub(code, "typeof", "ktypeof")
	return code
end

local function merge(v1, v2)
	for k, v in pairs(v2) do
		v1[k] = v
	end
	return v1
end

function sandboxer.run(code, chunk, env)
	local options = {
		env = env or sandboxer.enviroment,
		chunk_name = chunk,
		native_code_gen = sandboxer.native_code_gen,
	}

	local success, result = pcall(function(...)
		local bytecode = luau.compile(code)
		local thread = luau.load(bytecode, options)

		setfenv(thread, setmetatable(env or sandboxer.enviroment, { __index = getfenv(1) }))
		return thread()
	end)

	local thread
	if success then
		thread = result
	else
		thread = nil
	end

	return thread, success, result
end

function sandboxer.rblxrequire(path: string, callbackScript)
	local file = fs.readFile(path)
	local result
	if file then
		print("Got file")
		local code = gsub(file)
		if code then
			print("Got code")
			print("Running")
			-- require implementation already added in enviroment, skip
			local object = callbackScript(code, path)

			local enviroment = table.clone(sandboxer.enviroment)
			enviroment.script = object
			result = sandboxer.run(code, path, enviroment)
		end
	end
	if result then
		return result
	end
	return
end

-- Threads API
function sandboxer.thread.new(path, entry, env)
	local code = filesystem.read(path)
	local thread = task.spawn(function()
		sandboxer.run(code, entry.name, env)
	end)
	local info = { thread = thread, flags = { running = true } }
	sandboxer.thread.active[path] = info

	local wrapper = {}

	function wrapper.set(prop, val)
		sandboxer.thread.active[path][prop] = val
		wrapper.info = sandboxer.thread.active[path][prop]

		return wrapper
	end

	function wrapper.get()
		return sandboxer.thread.active[path]
	end

	return wrapper
end

function sandboxer.thread.fromCode(id, code, env)
	local thread = task.spawn(function()
		sandboxer.run(code, id, env)
	end)
	local info = { thread = thread, flags = { running = true } }
	sandboxer.thread.active[id] = info

	local wrapper = {}

	function wrapper.set(prop, val)
		sandboxer.thread.active[id][prop] = val
		wrapper.info = sandboxer.thread.active[id][prop]

		return wrapper
	end

	function wrapper.get()
		return sandboxer.thread.active[id]
	end

	return wrapper
end

function sandboxer.thread.kill(thread)
	thread.flags.running = false
	task.cancel(thread.thread)
end

function sandboxer.thread.clear()
	for _, thread in pairs(sandboxer.thread.active) do
		sandboxer.thread.kill(thread)
	end
end

return sandboxer
