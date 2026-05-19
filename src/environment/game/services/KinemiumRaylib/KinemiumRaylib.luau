local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local Enum = require("@EnumMap")

local KinemiumRaylib = Instance.new("KinemiumRaylib")
KinemiumRaylib.ExplorerHidden = true

KinemiumRaylib.InitRenderer = function(renderer, renderer_signal)
	KinemiumRaylib:SetProperties({
		_SecurityCapabilities = Enum.SecurityCapabilities.Internals,

		GetLib = function()
			return renderer.Raylib.lib
		end,

		GetConst = function()
			return renderer.Raylib.const
		end,

		GetStructs = function()
			return renderer.Raylib.structs
		end,

		GetRenderer = function()
			return renderer
		end,
	})
end

return KinemiumRaylib
