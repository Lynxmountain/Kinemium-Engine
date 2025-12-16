local physics = {}

local Vector3, CFrame, Utility = require("@Vector3"), require("@CFrame"), require("./utility")

export type BodyManager = typeof(require("./body"))

physics.gravity = Vector3.new(0, -9.81, 0)
physics.wind_direction = Vector3.new(0, 0, 0)
physics.render = nil
physics.hertz = 60
physics.substeps = 4
physics.accumulator = 0

function physics.step(body_manager: BodyManager, dt: number)
	dt = math.min(dt, 0.1)

	physics.accumulator += dt

	local subDt = 1 / (physics.hertz * physics.substeps)

	while physics.accumulator >= subDt do
		physics.substep(body_manager, subDt)
		physics.accumulator -= subDt
	end
end

function physics.substep(body_manager: BodyManager, dt: number)
	body_manager.each(function(id, body)
		body.velocity = body.velocity or Vector3.new(0, 0, 0)
		body.position = body.position or Vector3.new(0, 0, 0)
	end)

	for id, body in pairs(body_manager.pool) do
		body.velocity += physics.gravity * dt
		body.velocity += physics.wind_direction * dt

		local airDamping = 0.99
		body.velocity *= math.pow(airDamping, dt * physics.hertz)

		body.position += body.velocity * dt
	end

	for id, body in pairs(body_manager.pool) do
		for otherId, other in pairs(body_manager.pool) do
			if
				otherId ~= id
				and Utility.AABBOverlap(
					{ pos = body.position, size = body.size },
					{ pos = other.position, size = other.size }
				)
			then
				local normal, penetration = Utility.resolveCollision(body, other)

				body.position += normal * (penetration / 2)
				other.position -= normal * (penetration / 2)

				local relativeVel = body.velocity - other.velocity
				local velAlongNormal = relativeVel.X * normal.X + relativeVel.Y * normal.Y + relativeVel.Z * normal.Z

				if velAlongNormal < 0 then
					local restitution = 0.3
					local j = -(1 + restitution) * velAlongNormal / 2

					local impulse = normal * j
					body.velocity += impulse
					other.velocity -= impulse
				end
			end
		end
	end

	for id, body in pairs(body_manager.pool) do
		if body.position.Y - body.size.Y / 2 <= 0 then
			body.position = Vector3.new(body.position.X, body.size.Y / 2, body.position.Z)

			local restitution = 0.3
			body.velocity = Vector3.new(body.velocity.X, -body.velocity.Y * restitution, body.velocity.Z)

			local friction = 0.85
			body.velocity = Vector3.new(
				body.velocity.X * math.pow(friction, dt * physics.hertz),
				body.velocity.Y,
				body.velocity.Z * math.pow(friction, dt * physics.hertz)
			)
		end

		if physics.render then
			physics.render(id, body, dt)
		end
	end
end

return physics
