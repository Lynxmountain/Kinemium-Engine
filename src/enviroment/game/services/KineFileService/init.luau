local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local KineFileService = Instance.new("KineFileService")
KineFileService.ExplorerHidden = true

local fs = zune.fs
local process = zune.process

export type KinemiumPlaceFile = {
	ToExe: (string) -> (),
}

local function build(placeFile)
	local args = {
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
		"src/runtime/**/*.lua*",
		"src/external/**/*.lua*",
		"src/assets/**",
		"src/runtime/**",
		"src/libs/**",
		"src/**",
		"src/template/**",

		"src/external/signal.lua",
	}

	table.insert(args, placeFile)
	table.insert(args, "--out=./KinemiumRuntime.exe")

	local res = process.run(fs.getExePath(), args)
	print("Building")

	if not res.ok then
		error(`\n- {res.stderr}`)
	end
end

KineFileService.InitRenderer = function(renderer, renderer_signal, datamodel)
	local SerializationService = datamodel:GetService("SerializationService")

	KineFileService:SetProperties({
		Save = function(path)
			local serialized = SerializationService.SerializeInstancesAsync({ datamodel })
			print("got data")
			if serialized then
				local wrapper = {}
				print("wrapper")
				fs.createFile(path)
				print("created")
				fs.writeFile(path, serialized)
				print("writed")
				function wrapper:ToExe()
					build(path)
				end

				return wrapper
			end
		end,
	})
end

return KineFileService
