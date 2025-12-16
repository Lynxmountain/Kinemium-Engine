local lua = require("@lua")
local vm = lua.LuaVM.new()

local function getPath(destination)
	local src = process.cwd() .. "/" .. destination
	src = string.gsub(src, [[\]], "/")
	return src
end

local moonode_dir = getPath("src/external/moonode")

-- Initialize MoonODE and create a registry to store objects
local success, _, err = vm:execute(string.format(
	[[
     -- Try with absolute path
     package.cpath = package.cpath .. ";%s/?.dll;%s/moonode.dll"
     package.path = package.path .. ";%s/?.lua"
     _G.ode = require("moonode")
     _G.ode.init()
     
     -- Create a registry to store ODE objects
     _G.ode_registry = {}
     _G.ode_next_id = 1
     
     function _G.ode_store(obj)
         local id = _G.ode_next_id
         _G.ode_next_id = _G.ode_next_id + 1
         _G.ode_registry[id] = obj
         return id
     end
     
     function _G.ode_get(id)
         return _G.ode_registry[id]
     end
     
     function _G.ode_remove(id)
         _G.ode_registry[id] = nil
     end
 ]],
	moonode_dir,
	moonode_dir,
	moonode_dir
))

if not success then
	error("Failed to initialize MoonODE: " .. tostring(err))
end

local MoonODE = {}

-- World functions
function MoonODE.createWorld()
	local success, result, err = vm:execute([[
        local world = _G.ode.create_world()
        return _G.ode_store(world)
    ]])
	if not success then
		error("Failed to create world: " .. tostring(err))
	end
	print(result)
	return result
end

function MoonODE.destroyWorld(worldId)
	vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        _G.ode.destroy_world(world)
        _G.ode_remove(%d)
    ]],
		worldId,
		worldId
	))
end

function MoonODE.setGravity(worldId, x, y, z)
	vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        _G.ode.world_set_gravity(world, %f, %f, %f)
    ]],
		worldId,
		x,
		y,
		z
	))
end

function MoonODE.getGravity(worldId)
	local success, result = vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        local gx, gy, gz = _G.ode.world_get_gravity(world)
        return {gx, gy, gz}
    ]],
		worldId
	))
	return result
end

function MoonODE.step(worldId, stepSize)
	vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        _G.ode.world_step(world, %f)
    ]],
		worldId,
		stepSize
	))
end

-- Body functions
function MoonODE.createBody(worldId)
	local success, result = vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        local body = _G.ode.create_body(world)
        return _G.ode_store(body)
    ]],
		worldId
	))
	return result
end

function MoonODE.destroyBody(bodyId)
	vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        _G.ode.destroy_body(body)
        _G.ode_remove(%d)
    ]],
		bodyId,
		bodyId
	))
end

function MoonODE.setBodyPosition(bodyId, x, y, z)
	vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        _G.ode.body_set_position(body, {%f, %f, %f})
    ]],
		bodyId,
		x,
		y,
		z
	))
end

function MoonODE.getBodyPosition(bodyId)
	local success, result = vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        local pos = _G.ode.body_get_position(body)
        return {pos[1], pos[2], pos[3]}
    ]],
		bodyId
	))
	return result
end

function MoonODE.getBodyRotation(bodyId)
	local success, result = vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        local rot = _G.ode.body_get_rotation(body)
        return rot
    ]],
		bodyId
	))
	return result
end

function MoonODE.setBodyMass(bodyId, mass)
	vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        local m = _G.ode.create_mass()
        _G.ode.mass_set_sphere(m, 1, %f)
        _G.ode.body_set_mass(body, m)
    ]],
		bodyId,
		mass
	))
end

function MoonODE.setBodyLinearVel(bodyId, vx, vy, vz)
	vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        _G.ode.body_set_linear_vel(body, {%f, %f, %f})
    ]],
		bodyId,
		vx,
		vy,
		vz
	))
end

function MoonODE.getBodyLinearVel(bodyId)
	local success, result = vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        local vel = _G.ode.body_get_linear_vel(body)
        return {vel[1], vel[2], vel[3]}
    ]],
		bodyId
	))
	return result
end

function MoonODE.addBodyForce(bodyId, fx, fy, fz)
	vm:execute(string.format(
		[[
        local body = _G.ode_get(%d)
        _G.ode.body_add_force(body, {%f, %f, %f})
    ]],
		bodyId,
		fx,
		fy,
		fz
	))
end

-- Geometry/Collision functions
function MoonODE.createSpace()
	local success, result = vm:execute([[
        local space = _G.ode.create_simple_space()
        return _G.ode_store(space)
    ]])
	return result
end

function MoonODE.createSphere(spaceId, radius)
	local success, result = vm:execute(string.format(
		[[
        local space = _G.ode_get(%d)
        local sphere = _G.ode.create_sphere(space, %f)
        return _G.ode_store(sphere)
    ]],
		spaceId,
		radius
	))
	return result
end

function MoonODE.createBox(spaceId, lx, ly, lz)
	local success, result = vm:execute(string.format(
		[[
        local space = _G.ode_get(%d)
        local box = _G.ode.create_box(space, {%f, %f, %f})
        return _G.ode_store(box)
    ]],
		spaceId,
		lx,
		ly,
		lz
	))
	return result
end

function MoonODE.createPlane(spaceId, a, b, c, d)
	local success, result = vm:execute(string.format(
		[[
        local space = _G.ode_get(%d)
        local plane = _G.ode.create_plane(space, %f, %f, %f, %f)
        return _G.ode_store(plane)
    ]],
		spaceId,
		a,
		b,
		c,
		d
	))
	return result
end

function MoonODE.setGeomBody(geomId, bodyId)
	vm:execute(string.format(
		[[
        local geom = _G.ode_get(%d)
        local body = _G.ode_get(%d)
        _G.ode.geom_set_body(geom, body)
    ]],
		geomId,
		bodyId
	))
end

function MoonODE.destroyGeom(geomId)
	vm:execute(string.format(
		[[
        local geom = _G.ode_get(%d)
        _G.ode.destroy_geom(geom)
        _G.ode_remove(%d)
    ]],
		geomId,
		geomId
	))
end

-- Joint functions
function MoonODE.createHingeJoint(worldId)
	local success, result = vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        local joint = _G.ode.create_hinge_joint(world)
        return _G.ode_store(joint)
    ]],
		worldId
	))
	return result
end

function MoonODE.createBallJoint(worldId)
	local success, result = vm:execute(string.format(
		[[
        local world = _G.ode_get(%d)
        local joint = _G.ode.create_ball_joint(world)
        return _G.ode_store(joint)
    ]],
		worldId
	))
	return result
end

function MoonODE.jointAttach(jointId, body1Id, body2Id)
	local b1_code = body1Id and string.format("_G.ode_get(%d)", body1Id) or "nil"
	local b2_code = body2Id and string.format("_G.ode_get(%d)", body2Id) or "nil"
	vm:execute(string.format(
		[[
        local joint = _G.ode_get(%d)
        local body1 = %s
        local body2 = %s
        _G.ode.joint_attach(joint, body1, body2)
    ]],
		jointId,
		b1_code,
		b2_code
	))
end

function MoonODE.hingeSetAnchor(jointId, x, y, z)
	vm:execute(string.format(
		[[
        local joint = _G.ode_get(%d)
        _G.ode.hinge_set_anchor(joint, {%f, %f, %f})
    ]],
		jointId,
		x,
		y,
		z
	))
end

function MoonODE.hingeSetAxis(jointId, x, y, z)
	vm:execute(string.format(
		[[
        local joint = _G.ode_get(%d)
        _G.ode.hinge_set_axis(joint, {%f, %f, %f})
    ]],
		jointId,
		x,
		y,
		z
	))
end

-- Cleanup
function MoonODE.close()
	vm:execute([[
        _G.ode.close()
        _G.ode_registry = {}
    ]])
end

-- Example usage function
function MoonODE.runExample()
	print("Creating physics world...")
	local world = MoonODE.createWorld()
	MoonODE.setGravity(world, 0, -9.81, 0)

	print("Creating body...")
	local body = MoonODE.createBody(world)
	MoonODE.setBodyPosition(body, 0, 10, 0)
	MoonODE.setBodyMass(body, 1.0)

	print("Simulating...")
	for i = 1, 100 do
		MoonODE.step(world, 0.01)
		local pos = MoonODE.getBodyPosition(body)
		if i % 20 == 0 then
			print(string.format("Step %d: pos = (%.2f, %.2f, %.2f)", i, pos[1], pos[2], pos[3]))
		end
	end

	print("Cleaning up...")
	MoonODE.destroyBody(body)
	MoonODE.destroyWorld(world)
	MoonODE.close()
	print("Done!")
end

return MoonODE
