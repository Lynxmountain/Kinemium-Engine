local NumberSequenceKeypoint = {}
NumberSequenceKeypoint.__index = NumberSequenceKeypoint

function NumberSequenceKeypoint.new(t, v)
	return setmetatable({
		Time = t,
		Value = v,
	}, NumberSequenceKeypoint)
end

return NumberSequenceKeypoint
