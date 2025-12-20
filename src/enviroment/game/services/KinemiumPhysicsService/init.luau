local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local ffi = zune.ffi
local jolt = require("@jolt")
local lib = jolt.lib
local structs = jolt.structs

local KinemiumPhysicsService = Instance.new("KinemiumPhysicsService")
KinemiumPhysicsService.ExplorerHidden = true

local bodiesMap = {} -- Part -> BodyID (uint32)
local inverseMap = {} -- BodyID -> Part

local LAYER_NON_MOVING = 0 -- Static objects
local LAYER_MOVING = 1 -- Dynamic objects
local NUM_OBJECT_LAYERS = 2

local function float_ptr(value: number): buffer
	local buf = buffer.create(4) -- 4 bytes for float32
	buffer.writef32(buf, 0, value)
	return buf
end

local function u32(value)
	local buf = buffer.create(4)
	buffer.writeu32(buf, 0, value)
	return buf
end

local function getResults(bf)
	local len = buffer.len(bf)
	print("Buffer length:", len)

	-- Read as floats at proper 4-byte intervals
	for i = 0, math.floor(len / 4) - 1 do
		local offset = i * 4
		print("float[" .. i .. "] at offset " .. offset .. ": " .. tostring(buffer.readf32(bf, offset)))
	end

	-- Also print raw hex to see what's actually there
	print("\nRaw bytes (hex):")
	for i = 0, math.min(31, len - 1) do
		print(string.format("%02d: %02X", i, buffer.readu8(bf, i)))
	end
end

local function ToJoltVec3(vec3)
	return {
		x = vec3.X,
		y = vec3.Y,
		z = vec3.Z,
	}
end

local function u8(value)
	local buf = buffer.create(1)
	buffer.writeu8(buf, 0, value)
	return buf
end

local function u16(value)
	local buf = buffer.create(2)
	buffer.writeu16(buf, 0, value)
	return buf
end

local function RVec3(x, y, z)
	local vec = structs.JPH_RVec3:new({})
	buffer.writef64(vec, 0, x)
	buffer.writef64(vec, 8, y)
	buffer.writef64(vec, 16, z)
	return vec
end

local function FromJoltVec3(jvec)
	return Vector3.new(jvec.x, jvec.y, jvec.z)
end

local function CFrameToJolt(cf)
	return {
		pos = ToJoltVec3(cf.Position),
		rot = { x = 0, y = 0, z = 0, w = 1 }, -- Identity quaternion
	}
end

local function createBody(bodyInterface, part)
	if bodiesMap[part] then
		print("[Physics] Body already exists for part", part.Name)
		return
	end

	local halfSize = structs.JPH_Vec3:new({
		x = part.Size.X / 2,
		y = part.Size.Y / 2,
		z = part.Size.Z / 2,
	})

	print({
		x = part.Size.X / 2,
		y = part.Size.Y / 2,
		z = part.Size.Z / 2,
	})

	local boxShape = lib.JPH_BoxShape_Create(halfSize, float_ptr(0.05))

	print(boxShape)

	local position = structs.JPH_RVec3:new({
		x = part.Position.X,
		y = part.Position.Y,
		z = part.Position.Z,
	})

	local rotation = structs.JPH_Quat:new({ x = 0, y = 0, z = 0, w = 1 })

	print("buh3")
	print(position)

	local state = 0
	if part.Anchored == true then
		state = 0
		print("blud anchored, setting to " .. state)
	elseif part.Anchored == false then
		state = 2
		print("blud unanchored, setting to " .. state)
	end

	local layer = part.Anchored and LAYER_NON_MOVING or LAYER_MOVING
	local bodySettings = lib.JPH_BodyCreationSettings_Create3(boxShape, position, rotation, u8(state), u16(layer))

	print("buh4")

	local bodyID = lib.JPH_BodyInterface_CreateAndAddBody(bodyInterface, bodySettings, 1)
	print("buh5")

	lib.JPH_BodyCreationSettings_Destroy(bodySettings)
	if bodyID == ffi.null then
		warn("[Physics] Failed to create body")
		return
	end
	if state == 2 then
		lib.JPH_BodyInterface_ActivateBody(bodyInterface, bodyID)
	end

	local isAdded = lib.JPH_BodyInterface_IsAdded(bodyInterface, bodyID)
	print("[Physics] Body added?", isAdded == 1)

	-- Check if body is active
	local isActive = lib.JPH_BodyInterface_IsActive(bodyInterface, bodyID)
	print("[Physics] Body active?", isActive == 1)

	if state == 2 then
		lib.JPH_BodyInterface_ResetSleepTimer(bodyInterface, bodyID)

		local testVel = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
		testVel:writef32(0, 0)
		testVel:writef32(4, -1) -- Small downward velocity
		testVel:writef32(8, 0)
		lib.JPH_BodyInterface_SetLinearVelocity(bodyInterface, bodyID, testVel)
	end

	bodiesMap[part] = bodyID
	inverseMap[bodyID] = part

	print("[Physics] Created body for part " .. part.Name .. " with ID:", bodyID)
end

KinemiumPhysicsService.InitRenderer = function(renderer, renderer_signal, game)
	print("[Physics] Initializing Jolt Physics...")

	-- Initialize Jolt
	local initSuccess = lib.JPH_Init()
	if initSuccess == 0 then
		error("[Physics] Failed to initialize Jolt")
	end
	print("[Physics] Jolt initialized")

	-- Define collision layers

	local broadPhaseLayerInterface = lib.JPH_BroadPhaseLayerInterfaceTable_Create(NUM_OBJECT_LAYERS, NUM_OBJECT_LAYERS)
	if broadPhaseLayerInterface == ffi.null then
		error("[Physics] Failed to create BroadPhaseLayerInterface")
	end
	print("finished")

	lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, LAYER_NON_MOVING, 0)
	lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, LAYER_MOVING, 1)
	print("[Physics] BroadPhaseLayerInterface created")

	local objectLayerPairFilter = lib.JPH_ObjectLayerPairFilterTable_Create(NUM_OBJECT_LAYERS)
	if objectLayerPairFilter == ffi.null then
		error("[Physics] Failed to create ObjectLayerPairFilter")
	end

	lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilter, LAYER_NON_MOVING, LAYER_MOVING)
	lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilter, LAYER_MOVING, LAYER_NON_MOVING)
	lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerPairFilter, LAYER_MOVING, LAYER_MOVING)
	print("[Physics] ObjectLayerPairFilter created")

	local objectVsBroadPhaseFilter = lib.JPH_ObjectVsBroadPhaseLayerFilterTable_Create(
		broadPhaseLayerInterface,
		NUM_OBJECT_LAYERS,
		objectLayerPairFilter,
		NUM_OBJECT_LAYERS
	)
	if objectVsBroadPhaseFilter == ffi.null then
		error("[Physics] Failed to create ObjectVsBroadPhaseLayerFilter")
	end
	print("[Physics] ObjectVsBroadPhaseLayerFilter created")

	local physicsSystemSettings = structs.JPH_PhysicsSystemSettings:new({
		maxBodies = 10240,
		numBodyMutexes = 0,
		maxBodyPairs = 65536,
		maxContactConstraints = 10240,
		_padding = 0,
		broadPhaseLayerInterface = broadPhaseLayerInterface,
		objectLayerPairFilter = objectLayerPairFilter,
		objectVsBroadPhaseLayerFilter = objectVsBroadPhaseFilter,
	})

	local physicsSystem = lib.JPH_PhysicsSystem_Create(physicsSystemSettings)

	if physicsSystem == ffi.null then
		error("[Physics] Failed to create physics system")
	end

	print("[Physics] Physics system created and initialized")

	-- Set gravity
	local gravity = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	gravity:writef32(0, 0) -- x
	gravity:writef32(4, -9.81) -- y
	gravity:writef32(8, 0) -- z
	lib.JPH_PhysicsSystem_SetGravity(physicsSystem, gravity)
	print("[Physics] Gravity set")

	-- Get body interface
	local bodyInterface = lib.JPH_PhysicsSystem_GetBodyInterface(physicsSystem)
	if bodyInterface == ffi.null then
		error("[Physics] Failed to get body interface")
	end
	print("[Physics] Body interface obtained")

	-- Store these for later use
	local physicsState = {
		system = physicsSystem,
		bodyInterface = bodyInterface,
		broadPhaseLayerInterface = broadPhaseLayerInterface,
		objectLayerPairFilter = objectLayerPairFilter,
		objectVsBroadPhaseFilter = objectVsBroadPhaseFilter,
		LAYER_MOVING = LAYER_MOVING,
		LAYER_NON_MOVING = LAYER_NON_MOVING,
	}

	local config = structs.JPH_JobSystemConfig:new({
		context = 0,
		queueJob = ffi.null, -- Use Jolt's default
		queueJobs = ffi.null, -- Use Jolt's default
		maxConcurrency = 8, -- Number of threads
		maxBarriers = 8, -- Max barriers
	})
	local jobSystem = lib.JPH_JobSystemThreadPool_Create(config)
	if jobSystem == ffi.null then
		error("[Physics] Failed to create job system")
	end
	print("[Physics] Job system created")

	-- Get body interface for creating/managing bodies
	local bodyInterface = lib.JPH_PhysicsSystem_GetBodyInterface(physicsSystem)

	-- Properties
	local propTable = {
		GetBody = function(part)
			return bodiesMap[part]
		end,
		ApplyImpulse = function(part, impulse)
			local bodyID = bodiesMap[part]
			if not bodyID then
				return
			end

			local jImpulse = structs.JPH_Vec3:new(ToJoltVec3(impulse))
			lib.JPH_BodyInterface_AddImpulse(bodyInterface, bodyID, jImpulse)
		end,
		SetVelocity = function(part, velocity)
			local bodyID = bodiesMap[part]
			if not bodyID then
				return
			end

			local jVel = structs.JPH_Vec3:new(ToJoltVec3(velocity))
			lib.JPH_BodyInterface_SetLinearVelocity(bodyInterface, bodyID, jVel)
		end,
		GetVelocity = function(part)
			local bodyID = bodiesMap[part]
			if not bodyID then
				return Vector3.new()
			end

			local velocity = structs.JPH_Vec3:new({ x = 0, y = 0, z = 0 })
			lib.JPH_BodyInterface_GetLinearVelocity(bodyInterface, bodyID, velocity)
			return FromJoltVec3(velocity)
		end,
	}
	KinemiumPhysicsService:SetProperties(propTable)

	-- Handle part creation
	renderer_signal:Connect(function(route, data)
		if route == "AddedPartToRenderPool" then
			if not data.CanCollide then
				return
			end

			createBody(bodyInterface, data)
		elseif route == "RemovedPartFromRenderPool" then
			local bodyID = bodiesMap[data]
			if bodyID then
				lib.JPH_BodyInterface_RemoveAndDestroyBody(bodyInterface, bodyID)
				bodiesMap[data] = nil
				inverseMap[bodyID] = nil
				print("[Physics] Destroyed body for part")
			end
		elseif route == "RenderStepped" then
			-- Step physics simulation

			-- JPH_CAPI JPH_PhysicsUpdateError JPH_PhysicsSystem_Update(JPH_PhysicsSystem* system, float deltaTime, int collisionSteps, JPH_JobSystem* jobSystem);

			local dt = data

			lib.JPH_PhysicsSystem_Update(physicsSystem, dt, 1, jobSystem)

			-- Sync physics back to parts
			for part, bodyID in pairs(bodiesMap) do
				local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())

				local rotation = structs.JPH_Quat:new({
					x = 0,
					y = 0,
					z = 0,
					w = 1,
				})

				lib.JPH_BodyInterface_GetPositionAndRotation(bodyInterface, bodyID, position, rotation)

				local posX = position:readf64(8)
				local posY = position:readf64(0) -- Correct offset for second double
				local posZ = position:readf64(16) -- Correct offset for third double

				part.Position = Vector3.new(posX, posY, posZ)
				local velocity = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
				lib.JPH_BodyInterface_GetLinearVelocity(bodyInterface, bodyID, velocity)

				local velX = velocity:readf32(0)
				local velY = velocity:readf32(4)
				local velZ = velocity:readf32(8)

				part.AssemblyLinearVelocity = Vector3.new(velX, velY, velZ)

				-- For quaternion rotation (4 floats)
				local rotX = buffer.readf32(rotation, 0)
				local rotY = buffer.readf32(rotation, 4)
				local rotZ = buffer.readf32(rotation, 8)
				local rotW = buffer.readf32(rotation, 12)

				-- TODO: Convert quaternion to CFrame rotation
			end
		end
	end)

	renderer_signal:Fire("PhysicsEngine", KinemiumPhysicsService)
end

return KinemiumPhysicsService
