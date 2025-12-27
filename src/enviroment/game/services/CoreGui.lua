local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Vector3 = require("@Vector3")

local CoreGui = Instance.new("CoreGui")

CoreGui:SetProperties({
	Version = "1.0.9",
})

CoreGui.InitRenderer = function(renderer, signal, datamodel)
	-- we dont need to do anything here since the engine
	-- copies the children of starter gui to the player's gui
	CoreGui.DescendantAdded:Connect(function(child)
		if child:IsA("ScreenGui") then
			for _, screengui_child in pairs(child:GetDescendants()) do
				if screengui_child.BaseClass == "Kinemium.uimodifier" then
					continue
				end

				renderer.AddToGuiRenderingPool(function()
					return screengui_child
				end, screengui_child.render)
			end

			child.ChildAdded:Connect(function(new)
				if new.BaseClass == "Kinemium.uimodifier" then
					return
				end
				renderer.AddToGuiRenderingPool(function()
					return new
				end, new.render)
			end)
		end
	end)
end

return CoreGui
