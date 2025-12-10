local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Vector3 = require("@Vector3")

local StarterGui = Instance.new("StarterGui")

StarterGui:SetProperties({
	Enabled = true,
	ResetOnSpawn = true,
	ZIndexBehavior = "Sibling",
	CoreGuiEnabled = true,
})

StarterGui.InitRenderer = function(renderer, signal, datamodel)
	-- we dont need to do anything here since the engine
	-- copies the children of starter gui to the player's gui
	StarterGui.DescendantAdded:Connect(function(child)
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

	--[[
	signal:Connect(function(route, data)
		if route == "RenderStepped" then
			local GuiSelectionService = datamodel:GetService("GuiSelectionService")

			for _, child in pairs(StarterGui:GetDescendants()) do
				print(child)

				if child.AbsolutePosition ~= nil then
					print(child.AbsolutePosition)
				end

				if not child.AbsolutePosition then
					return
				end
				GuiSelectionService.step()
				GuiSelectionService.add(child)
			end
		end
	end)
	--]]
end

return StarterGui
