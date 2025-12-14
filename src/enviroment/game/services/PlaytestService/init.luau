local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

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
end

return PlaytestService
