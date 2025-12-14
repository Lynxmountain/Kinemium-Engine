-- devcell
local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local Enum = require("@EnumMap")
local sandboxer = require("@sandboxer")
local task = zune.task

local ScriptRunnerService = Instance.new("ScriptRunnerService")
ScriptRunnerService.ExplorerHidden = true

--local lua = require("@lua")
local python = require("@python")
local duktape = require("@duktape")
local threads = { luau = {}, python = {}, duktape = {} }

ScriptRunnerService.InitEnviroment = function(enviroment)
	ScriptRunnerService:SetProperties({
		RunLuauScript = function(ScriptInstance)
			local object = task.spawn(function()
				sandboxer.run(ScriptInstance.Source, ScriptInstance.Name, enviroment)
			end)
			threads.luau[ScriptInstance.Name] = object
			return object
		end,

		RunPythonScript = function(ScriptInstance)
			local VM = python.PythonVM.new()

			for k, p in pairs(enviroment) do
				VM:setGlobal(k, p)
			end

			threads.python[ScriptInstance.Name] = VM

			return VM:execute(ScriptInstance.Source), VM
		end,

		RunDuktapeScript = function(ScriptInstance)
			local object = task.spawn(function()
				local VM = duktape.DuktapeVM.new()

				for k, p in pairs(enviroment) do
					if type(p) == "table" then
						continue
					end
					VM:setGlobal(k, p)
				end

				VM:execute(ScriptInstance.Source)
			end)

			threads.duktape[ScriptInstance.Name] = object
			return object
		end,

		RunScript = function(ScriptInstance)
			local language = ScriptInstance.Language

			if language == Enum.Language.Luau then
				return ScriptRunnerService.RunLuauScript(ScriptInstance)
			elseif language == Enum.Language.Python then
				return ScriptRunnerService.RunPythonScript(ScriptInstance)
			elseif language == Enum.Language.JavaScript then
				return ScriptRunnerService.RunDuktapeScript(ScriptInstance)
			end
			return
		end,

		GetActive = function()
			return threads
		end,

		Clear = function()
			for _, thread in pairs(threads.luau) do
				task.cancel(thread)
			end

			for _, thread in pairs(threads.python) do
				thread:close()
			end

			for _, thread in pairs(threads.duktape) do
				thread:close()
			end
		end,
	})

	return ScriptRunnerService
end

return ScriptRunnerService
