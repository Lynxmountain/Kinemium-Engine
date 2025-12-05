local fs = zune.fs
local datatypes = {}

for _, file in pairs(fs.entries("./src/enviroment/datatypes")) do
	if file.name == "getDatatypes.lua" then
		continue
	end
	local moduleName = file.name:gsub("%.lua$", "")
	datatypes[moduleName] = require("./" .. moduleName)
end

return datatypes
