local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local ServerScriptService = Instance.new("ServerScriptService")

local allowed_to_render = {
	["Part"] = "Part",
	["MeshPart"] = "MeshPart",
	["BasePart"] = "BasePart",
}

ServerScriptService:SetProperties({
	LoadStringEnabled = false,
})

ServerScriptService.InitRenderer = function(renderer, signal) end

return ServerScriptService
