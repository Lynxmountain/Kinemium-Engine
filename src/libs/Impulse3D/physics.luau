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

-- Replace the substep function with this:

function physics.substep(body_manager: BodyManager, dt: number)
	body_manager.each(function(id, body)
		body.velocity = body.velocity or Vector3.new(0, 0, 0)
		body.position = body.position or Vector3.new(0, 0, 0)
	end)

	for id, body in pairs(body_manager.pool) do
		-- Apply gravity
		body.velocity += physics.gravity * dt
		body.velocity += physics.wind_direction * dt

		-- Hertz-based air resistance
		local airDamping = 0.99
		body.velocity *= math.pow(airDamping, dt * physics.hertz)

		local newPos = body.position + body.velocity * dt

		-- Collision detection
		for otherId, other in pairs(body_manager.pool) do
			if
				otherId ~= id
				and Utility.AABBOverlap({ pos = newPos, size = body.size }, { pos = other.position, size = other.size })
			then
				-- Bounce off other objects
				local restitution = 0.3
				body.velocity = Vector3.new(body.velocity.X, -body.velocity.Y * restitution, body.velocity.Z)
				newPos = body.position
				break
			end
		end

		-- Ground collision
		if newPos.Y - body.size.Y / 2 <= 0 then
			newPos = Vector3.new(newPos.X, body.size.Y / 2, newPos.Z)

			-- Hertz-based bounce
			local restitution = 0.3
			body.velocity = Vector3.new(body.velocity.X, -body.velocity.Y * restitution, body.velocity.Z)

			-- Ground friction
			local friction = 0.85
			body.velocity = Vector3.new(
				body.velocity.X * math.pow(friction, dt * physics.hertz),
				body.velocity.Y,
				body.velocity.Z * math.pow(friction, dt * physics.hertz)
			)
		end

		body.position = newPos

		if physics.render then
			physics.render(id, body)
		end
	end
end

return physics
