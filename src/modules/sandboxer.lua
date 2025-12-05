local sandboxer = {}

local luau = zune.luau

sandboxer.enviroment = {}
sandboxer.native_code_gen = true

function sandboxer.run(code, chunk, env)
	local options = {
		env = env or sandboxer.enviroment,
		chunk_name = chunk,
		native_code_gen = sandboxer.native_code_gen,
	}
	local bytecode = luau.compile(code)
	local thread = luau.load(bytecode, options)

	return thread()
end

return sandboxer
