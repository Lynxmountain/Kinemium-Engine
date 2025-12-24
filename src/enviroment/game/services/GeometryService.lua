local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local GeometryService = Instance.new("GeometryService")
GeometryService.ExplorerHidden = true

GeometryService.InitRenderer = function(renderer, renderer_signal)
	GeometryService:SetProperties({})
end

return GeometryService
