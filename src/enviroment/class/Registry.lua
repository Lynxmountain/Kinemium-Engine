local filesystem = require("../../modules/filesystem")
local sandboxer = require("../../modules/sandboxer")
local Instance = require("../class/Instance")
local datatypes = require("../datatypes/getDatatypes")

local registry = {}
local listOfClasses = {}

sandboxer.enviroment = datatypes

filesystem.entryloop("./src/enviroment/class/list", function(entry)
	local path = "./src/enviroment/class/list/" .. entry.name
	local code = filesystem.read(path)

	local returned = sandboxer.run(code, entry.name)
	-- returned = { class = "Part", callback = function(Part) ... end }

	listOfClasses[returned.class] = returned
	print("Created class for " .. returned.class)
end)

function registry.createclass(data)
	listOfClasses[data.class] = data
	print("Created class for " .. data.class)
end

function registry.new(class, renderer)
	local found

	for _, looped_class in pairs(listOfClasses) do
		if looped_class.cover_up == class then
			found = looped_class
		elseif looped_class.class == class then
			found = looped_class
		end
	end

	if not found then
		return error("Class not found: " .. tostring(class))
	end
	if found.non_creatable then
		return error("Class is non-creatable: " .. tostring(class))
	end

	local instance = Instance.new(class)
	found.callback(instance, renderer)
	return instance
end

return registry
