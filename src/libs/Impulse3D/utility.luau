local PhysicsUtils = {}

function PhysicsUtils.AABBOverlap(box1, box2)
	local b1min = box1.pos - box1.size / 2
	local b1max = box1.pos + box1.size / 2
	local b2min = box2.pos - box2.size / 2
	local b2max = box2.pos + box2.size / 2

	return (b1min.X <= b2max.X and b1max.X >= b2min.X)
		and (b1min.Y <= b2max.Y and b1max.Y >= b2min.Y)
		and (b1min.Z <= b2max.Z and b1max.Z >= b2min.Z)
end

function PhysicsUtils.getAABBBounds(pos, size)
	local halfSize = size / 2
	return pos - halfSize, pos + halfSize
end

function PhysicsUtils.resolveCollision(body, other)
	local b1min, b1max = PhysicsUtils.getAABBBounds(body.position, body.size)
	local b2min, b2max = PhysicsUtils.getAABBBounds(other.position, other.size)

	local overlapX = math.min(b1max.X - b2min.X, b2max.X - b1min.X)
	local overlapY = math.min(b1max.Y - b2min.Y, b2max.Y - b1min.Y)
	local overlapZ = math.min(b1max.Z - b2min.Z, b2max.Z - b1min.Z)

	local minOverlap = math.min(overlapX, overlapY, overlapZ)

	local normal = Vector3.new(0, 0, 0)
	local penetration = 0

	if minOverlap == overlapX then
		normal = Vector3.new(body.position.X > other.position.X and 1 or -1, 0, 0)
		penetration = overlapX
	elseif minOverlap == overlapY then
		normal = Vector3.new(0, body.position.Y > other.position.Y and 1 or -1, 0)
		penetration = overlapY
	else
		normal = Vector3.new(0, 0, body.position.Z > other.position.Z and 1 or -1)
		penetration = overlapZ
	end

	return normal, penetration
end

function PhysicsUtils.SphereOverlap(sphere1, sphere2)
	local diff = sphere1.pos - sphere2.pos
	local distSq = diff.Magnitude ^ 2
	local radiusSum = sphere1.radius + sphere2.radius
	return distSq <= radiusSum * radiusSum
end

function PhysicsUtils.SphereAABBOverlap(sphere, box)
	local bmin = box.pos - box.size / 2
	local bmax = box.pos + box.size / 2

	local closest = Vector3.new(
		math.max(bmin.X, math.min(sphere.pos.X, bmax.X)),
		math.max(bmin.Y, math.min(sphere.pos.Y, bmax.Y)),
		math.max(bmin.Z, math.min(sphere.pos.Z, bmax.Z))
	)

	local diff = sphere.pos - closest
	return diff.Magnitude ^ 2 <= sphere.radius * sphere.radius
end

return PhysicsUtils
