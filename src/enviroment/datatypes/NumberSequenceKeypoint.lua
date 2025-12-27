local NumberSequenceKeypoint = {}
NumberSequenceKeypoint.__index = NumberSequenceKeypoint

function NumberSequenceKeypoint.new(t, v)
	return setmetatable({
		Time = t,
		Value = v,
	}, NumberSequenceKeypoint)
end

function NumberSequenceKeypoint:ToTable()
	return {
		type = "NumberSequenceKeypoint",
		Time = self.Time,
		Value = self.Value,
	}
end

function NumberSequenceKeypoint.FromTable(tbl)
	assert(tbl.type == "NumberSequenceKeypoint")
	return NumberSequenceKeypoint.new(tbl.Time, tbl.Value)
end

return NumberSequenceKeypoint
