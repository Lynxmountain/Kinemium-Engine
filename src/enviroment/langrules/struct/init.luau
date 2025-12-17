local struct = {}

local primitive = require("./struct/primitive")

function struct.InitEnviroment(enviroment)
	enviroment.prim = primitive

	enviroment.struct = function(name)
		return function(definition)
			local constructor = function(init)
				init = init or {}
				local obj = {}
				for fieldName, validator in pairs(definition) do
					warn(fieldName, validator)
					local value = init[fieldName]
					assert(value ~= nil, "Missing field: " .. fieldName)
					obj[fieldName] = validator(value)
				end
				return obj
			end

			local wrapper = {
				_class = name,
				new = constructor,
			}

			setmetatable(wrapper, {
				__call = function(self, ...)
					return constructor(...)
				end,
			})

			return wrapper
		end
	end
end

return struct
