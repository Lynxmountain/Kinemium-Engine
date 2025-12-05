local Instance = require("@Instance")
local signal = require("@kinetica.signal")

local PlayerGui = Instance.new("PlayerGui")

PlayerGui.InitRenderer = function(renderer, renderer_signal)
	PlayerGui:SetProperties({
		ResetOnSpawn = true,
	})

	PlayerGui.ChildAdded:Connect(function(child)
		if child:IsA("ScreenGui") then
			for _, screengui_child in pairs(child:GetDescendants()) do
				if screengui_child.BaseClass == "kinetica.uimodifier" then
					continue
				end
				renderer.AddToGuiRenderingPool(function()
					return screengui_child
				end, screengui_child.render)
			end

			child.ChildAdded:Connect(function(new)
				if new.BaseClass == "kinetica.uimodifier" then
					return
				end
				renderer.AddToGuiRenderingPool(function()
					return new
				end, new.render)
			end)
		end
	end)

	return PlayerGui
end

return PlayerGui
