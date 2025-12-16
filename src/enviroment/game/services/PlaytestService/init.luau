local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Color3 = require("@Color3")

local PlaytestService = Instance.new("PlaytestService")
PlaytestService.ExplorerHidden = true

PlaytestService.InitRenderer = function(renderer, renderer_signal, datamodel)
	PlaytestService:SetProperties({
		CreatePlaytestAsync = function()
			local ScriptRunnerService = datamodel:GetService("ScriptRunnerService")

			ScriptRunnerService.Clear()

			-- ## run Server scripts
			for _, script in pairs(datamodel:GetDescendants()) do
				if script:IsA("Script") then
					print("FOUND SCRIPT! " .. script.Name)
					ScriptRunnerService.RunScript(script)
				end
			end
		end,

		StopCurrentPlaytest = function()
			local ScriptRunnerService = datamodel:GetService("ScriptRunnerService")

			print(ScriptRunnerService.GetActive())
			ScriptRunnerService.Clear()
		end,
	})

	print("hello world")
end

PlaytestService.GetToolbarCategory = function(renderer, renderer_signal, datamodel)
	local toggle = true

	local Category = {
		elements = {
			{
				type = "ImageButton",
				text = "Playtest",
				callback = function(object)
					if toggle == true then
						PlaytestService.CreatePlaytestAsync()
					else
						PlaytestService.StopCurrentPlaytest()
					end
				end,
				hoverTransparency = 0.5,
				hoverColor = Color3.new(0, 0, 0),
				roundness = 0.2,
				--texture = PlayIcon,
			},
		},
	}

	return Category
end

return PlaytestService
