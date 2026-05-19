local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")

local KinemiumFFI = Instance.new("KinemiumFFI")
KinemiumFFI.ExplorerHidden = true

local fs = zune.fs
local ffi = zune.ffi

KinemiumFFI.InitRenderer = function(renderer, renderer_signal)
	KinemiumFFI:SetProperties({

		GetLib = function()
			return ffi
		end,

		ImportLibFromMemory = function(name, contents, funcs)
			local path = `./.temp/{name}.{zune.ffi.suffix}`
			if fs.stat(path).kind == "none" then
				fs.writeFile(path, contents)
			end

			return ffi.dlopen(path, funcs)
		end,

		ImportLib = function(path, funcs)
			return ffi.dlopen(path, funcs)
		end,

		c = {
			compile = ffi.c.compile,
		},
	})
end

return KinemiumFFI
