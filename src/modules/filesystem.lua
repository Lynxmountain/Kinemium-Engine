local filesystem = {}

local zunefs = zune.fs

function filesystem.entryloop(path, callback)
	local entries = zunefs.entries(path)
	if entries then
		for _, entry in pairs(entries) do
			callback(entry)
		end
	end
	return true
end

function filesystem.read(file)
	return zunefs.readFile(file)
end

return filesystem
