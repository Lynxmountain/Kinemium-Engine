--!strict
local fs = zune.fs
local process = zune.process

local function build()
	local res = process.run(fs.getExePath(), {
		"bundle",
		"-f",
		"./**/.luaurc",
		"-s",
		"src/main.lua",
		"src/enviroment/**/*.lua*",
		"src/modules/**/*.lua*",
		"src/renderer/**/*.lua*",
		"src/sandboxed/**/*.lua*",
		"src/shaders/**/*.lua*",
		"src/external/**/*.lua*",
		"src/assets/**",
		"src/rblx/**",
		"src/template/**",

		"src/external/signal.lua",

		"--out=./KinemiumRuntime.exe",
	})
	print("Building")

	if not res.ok then
		error(`\n- {res.stderr}`)
	end
end

build()
