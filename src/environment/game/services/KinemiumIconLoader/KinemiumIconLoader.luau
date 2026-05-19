local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local fs = zune.fs
local ffi = zune.ffi
local mem = zune.mem

local KinemiumIconLoader = Instance.new("KinemiumIconLoader")
KinemiumIconLoader.ExplorerHidden = true
local raylib = require("@raylib")
local lib = raylib.lib

local zembed = require("@zembed")
local general = zembed.AssetPath("kineasset://images/icons")

KinemiumIconLoader.InitRenderer = function(renderer, renderer_signal)
	if IsHeadless then
		return
	end
	local registry = {}
	local textures = {}

	local raylib = require("@raylib")

	local function reload()
		for _, data in pairs(textures) do
			if data.texture then
				lib.UnloadTexture(data.texture)
			end
		end

		table.clear(registry)
		table.clear(textures)

		for _, file in pairs(type(general) == "string" and fs.entries(general) or general) do
			local fileName = file.name
			local filePath

			if type(general) == "string" then
				filePath = general .. "/" .. fileName
			else
				filePath = file
			end

			registry[fileName] = filePath

			log("Loading " .. fileName)
		end
	end

	KinemiumIconLoader:SetProperties({
		Reload = reload,
		LoadImageCustom = function(path: string)
			path = zembed.AssetPath(path)
			if true then
				local image = raylib.lib.LoadImage(path)

				local width = buffer.readi32(image, 0)
				local height = buffer.readi32(image, 4)
				return {
					texture = raylib.lib.LoadTextureFromImage(image),
					width = width,
					height = height,
					image = image,
				}
			end

			local sail = require("@Sail")
			local structs = sail.common.structs
			local image_holder = ffi.alloc(8)
			local result = sail.lib.sail_load_from_file(path, image_holder)

			if result == 0 then
				local addr_buf = buffer.create(8)
				mem.copy(addr_buf, 0, image_holder, 0, 8)

				local image_ptr = ffi.ptrFromAddress(addr_buf)
				local width = image_ptr:readu32(structs.sail_image:offset("width"))
				local height = image_ptr:readu32(structs.sail_image:offset("height"))
				local pixels = image_ptr:readptr(structs.sail_image:offset("pixels"))
				local pixel_format = image_ptr:readi32(structs.sail_image:offset("pixel_format"))

				local rl_image = raylib.structs.Image:new({
					width = width,
					height = height,
					mipmaps = 1,
					format = 7,
				})

				local pixels_lo = image_ptr:readu32(structs.sail_image:offset("pixels"))
				local pixels_hi = image_ptr:readu32(structs.sail_image:offset("pixels") + 4)
				buffer.writeu32(rl_image, 0, pixels_lo)
				buffer.writeu32(rl_image, 4, pixels_hi)

				result = nil
				sail.commonlib.sail_destroy_image(image_ptr)

				return {
					texture = raylib.lib.LoadTextureFromImage(rl_image),
					width = width,
					height = height,
					pixels = pixels,
					pixel_format = pixel_format,
					image = rl_image,
				}
			end
			return
		end,
		ToTextureBuffer = function(buffer_data: buffer, filename: string)
			if not buffer_data then
				return nil
			end

			local ext = filename and raylib.lib.GetFileExtension(filename) or ".png"
			local image_ptr = raylib.lib.LoadImageFromMemory(ext, buffer_data, buffer.len(buffer_data))

			if typeof(image_ptr) == "buffer" then
				local image_struct = raylib.structs.Image:new({})
				zune.mem.copy(image_struct, 0, image_ptr, 0, 24)

				local succ, texture = pcall(raylib.lib.LoadTextureFromImage, image_struct)
				raylib.lib.UnloadImage(image_struct)
				if succ and typeof(texture) == "buffer" then
					local size = vector.create(buffer.readi32(texture, 4), buffer.readi32(texture, 8))

					local data = {
						texture = texture,
						x = size.x,
						y = size.y,
					}

					raylib.lib.SetTextureFilter(texture, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
					raylib.lib.SetTextureWrap(texture, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
					raylib.lib.GenTextureMipmaps(texture)

					return data
				end
			end
			return nil
		end,
		ToTexture = function(path: string)
			path = zembed.AssetPath(path)

			if textures[path] then
				return textures[path]
			end

			local texture

			if not string.find(path, ".svg") then
				texture = lib.LoadTexture(path)
			else
				texture = KinemiumIconLoader.LoadImageCustom(path).texture
			end

			local size = vector.create(buffer.readi32(texture, 4), buffer.readi32(texture, 8))

			local data = {
				texture = texture,
				x = size.x,
				y = size.y,
			}

			lib.SetTextureFilter(texture, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			lib.SetTextureWrap(texture, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			lib.GenTextureMipmaps(texture)

			textures[path] = data
			return data
		end,
		new = function(name, path)
			registry[name] = path
		end,
		Get = function(name)
			return registry[name]
		end,
		Remove = function(name)
			registry[name] = nil
		end,
		Change = function(name, newPath)
			if not registry[name] then
				return
			end
			registry[name] = newPath
		end,
		LoadAutoTexture = function(name, path)
			path = zembed.AssetPath(path)
			if textures[path] then
				return textures[path].texture
			end
			warn(`Loading {name} and {path}`)
			local texture

			if not string.find(path, ".svg") then
				texture = lib.LoadTexture(path)
			else
				texture = KinemiumIconLoader.LoadImageCustom(path).texture
			end
			registry[name] = path

			textures[path] = {
				texture = texture,
				x = 0,
				y = 0,
			}

			lib.SetTextureFilter(texture, raylib.const.TextureFilter.TEXTURE_FILTER_TRILINEAR)
			lib.SetTextureWrap(texture, raylib.const.TextureWrap.TEXTURE_WRAP_CLAMP)
			lib.GenTextureMipmaps(texture)

			return texture
		end,
		Cleanup = function()
			for _, data in pairs(textures) do
				if data.texture then
					lib.UnloadTexture(data.texture)
				end
			end
			table.clear(textures)
		end,
	})

	reload()

	return registry
end

return KinemiumIconLoader
