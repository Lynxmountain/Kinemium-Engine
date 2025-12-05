local Vector3 = require("@Vector3")
local Color3 = require("@Color3")
local CFrame = require("@CFrame")
local Part = require("./src/enviroment/class/list/Part")
local task = zune.task

local propTable = {
	MeshId = "",
}

Part.inherit(propTable)

return {
	class = "MeshPart",
	callback = function(instance, renderer)
		instance:SetProperties(propTable)
		instance.Changed:Connect(function(propname, propvalue)
			if propname == "MeshId" then
				task.spawn(function()
					renderer.mesh.LoadMesh(instance.UniqueId, propvalue)
				end)
				print("Loaded mesh")
			end
		end)

		return instance
	end,
	inherit = function()
		return propTable
	end,
}
