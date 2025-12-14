-- simple body manager
-- devcell
local body = {
	pool = {},
}

export type Vector3 = typeof(require("@Vector3"))

export type Body = {
	size: Vector3,
	position: Vector3,
	forces: { Vector3 },
}

body._lastId = 0

function body.new(data: Body)
	local clone = table.clone(data)
	body._lastId += 1
	clone.id = body._lastId
	body.pool[body._lastId] = clone
	return clone.id
end

function body.get(id: number)
	return body.pool[id]
end

function body.remove(id)
	body.pool[id] = nil
end

function body.edit(id, changes)
	for k, v in pairs(changes) do
		body.pool[id][k] = v
	end
	return body.pool[id]
end

function body.each(func)
	for id, obj in pairs(body.pool) do
		func(id, obj)
	end
end

return body
