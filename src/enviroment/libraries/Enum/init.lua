local Enum = {}
local EnumItem = {}
EnumItem.__index = EnumItem

function EnumItem:IsA(value)
	return self.EnumType == value
end

function Enum.new(api)
	Enum._numberIndex = {}

	-- api = table of { EnumName = { ItemName = value } }
	for enumName, items in pairs(api) do
		local enumType = {}
		enumType.Name = enumName
		enumType.__index = enumType
		enumType.EnumType = enumType

		for itemName, itemValue in pairs(items) do
			local item = setmetatable({}, EnumItem)
			item.Name = itemName
			item.Value = itemValue
			item.EnumType = enumType

			if type(itemValue) == "number" then
				Enum._numberIndex[itemName] = item
			end

			enumType[itemName] = item
		end

		Enum[enumName] = enumType
	end

	return Enum
end

return Enum
