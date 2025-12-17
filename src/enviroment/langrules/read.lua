local fs = zune.fs
local langrules = {}

for _, file in pairs(fs.entries("./src/enviroment/langrules")) do
	if file.name == "read.lua" then
		continue
	end
	local moduleName = file.name:gsub("%.lua$", "")
	moduleName = file.name:gsub("%.luau$", "")
	langrules[moduleName] = require("./" .. moduleName)
	langrules[moduleName].type = moduleName
end

return langrules
