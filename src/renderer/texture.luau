return function(lib)
	local function LoadTextureFromFile(path: string)
		return lib.LoadTexture(path)
	end

	local function GetMaterials()
		local path = "./src/assets/materials"
		local fs = zune.fs
		local entries = fs.entries(path)
		local result = {}
		for i, v in pairs(entries) do
			local objectPath = "src/assets/materials/" .. v.name
			result[v.name:gsub(".png", "")] = objectPath
		end
		return result
	end

	return {
		LoadTextureFromFile = LoadTextureFromFile,
		GetMaterials = GetMaterials,
	}
end
