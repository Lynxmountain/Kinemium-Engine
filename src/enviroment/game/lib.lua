local Instance = require("@Instance")
local Enum = require("@EnumMap")
local signal = require("@Kinemium.signal")

local DataModel = {}
DataModel.__index = DataModel

local fs = zune.fs

function DataModel.new(RENDERER, ...)
	local self = setmetatable({}, DataModel)

	self = Instance.new("DataModel")
	self.Name = "game"
	self.Dimension = Enum.Dimension["3D"]
	self.Context = Enum.GameContext.Editor
	self.EngineSignal = signal.new()

	self.Services = {}

	local services = fs.entries("./src/enviroment/game/services")
	for _, service in pairs(services) do
		local name = service.name:gsub(".lua", "")
		local success, returnedData = pcall(require, "./services/" .. name)
		if success then
			local success2, returnedData2 = pcall(function()
				self.Services[name] = returnedData
				if returnedData.InitRenderer then
					returnedData.InitRenderer(RENDERER, RENDERER.Signal, self)
				end
			end)
			if success2 then
				print("Added service " .. name)
			else
				warn("Error initializing service " .. name .. ": " .. tostring(returnedData2))
			end
		else
			warn("Failed to get service " .. name .. ": " .. tostring(returnedData))
		end
	end

	for name, service in pairs(self.Services) do
		service.Name = name
		service.Parent = self
	end

	function self:GetService(v)
		return self.Services[v]
	end

	function self:AddService(ServiceObject)
		ServiceObject.Parent = self
		self.Services[ServiceObject.Name] = ServiceObject
	end

	return self
end

function DataModel:__index(key)
	if DataModel[key] then
		return DataModel[key]
	end

	if self.Services and self.Services[key] then
		return self.Services[key]
	end

	return nil
end

return DataModel
