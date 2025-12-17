local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local raylib = require("@raylib")
local const = raylib.const
local structs = raylib.structs
local lib = raylib.lib

local Selection3DService = Instance.new("Selection3DService")
Selection3DService.ExplorerHidden = true

Selection3DService.InitRenderer = function(renderer, renderer_signal)
	Selection3DService:SetProperties({})
end

return Selection3DService
