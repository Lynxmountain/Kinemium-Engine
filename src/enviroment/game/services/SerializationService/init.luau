local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local SerializationService = Instance.new("SerializationService")
SerializationService.ExplorerHidden = true

SerializationService.InitRenderer = function(renderer, renderer_signal)
	SerializationService:SetProperties({
		SerializeInstancesAsync = function(self, m)
			-- since the instance is already a table, we dont need to serialize it
			-- we could just.. compress it i guess
			-- TODO
		end,
	})
end

return SerializationService
