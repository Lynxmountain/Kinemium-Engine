-- devcell
local Instance = require("@Instance")
local Vector3 = require("@Vector3")
local CFrame = require("@CFrame")
local ffi = zune.ffi
local jolt = require("@jolt")
local lib = jolt.lib
local structs = jolt.structs
local task = zune.task

local KinemiumPhysicsService = Instance.new("KinemiumPhysicsService")
KinemiumPhysicsService.ExplorerHidden = true

local runtime = {}

local function allocRVec3()
	-- 24 bytes, 8-byte aligned (double-safe)
	return ffi.alloc(24, 8)
end

local function readRvec3(bodyInterface, bodyID)
	local position = allocRVec3()
	lib.JPH_BodyInterface_GetPosition(bodyInterface, bodyID, position)

	local x = position:readf64(0)
	local y = position:readf64(8)
	local z = position:readf64(16)
	return vector.create(x, y, z)
end

local function roundVec3(v)
	return Vector3.new(math.round(v.X * 1e4) / 1e4, math.round(v.Y * 1e4) / 1e4, math.round(v.Z * 1e4) / 1e4)
end

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

local function getResults(ptr, size)
	-- ptr = ffi pointer
	-- size = number of bytes to inspect (optional)

	size = size or 32

	print("FFI ptr:", ptr)

	for i = 0, 16 do
		local offset = i
		print(string.format("f64[%d] @ %d = %.6f", i, offset, ptr:readf64(offset)))
	end

	for i = 0, 20 do
		local offset = i
		print(string.format("u32[%d] @ %d = %.6f", i, offset, ptr:readu32(offset)))
	end

	for i = 0, 22 do
		local offset = i
		print(string.format("u16[%d] @ %d = %.6f", i, offset, ptr:readu16(offset)))
	end

	for i = 0, 20 do
		local offset = i
		print(string.format("i32[%d] @ %d = %.6f", i, offset, ptr:readi32(offset)))
	end

	for i = 0, 22 do
		local offset = i
		print(string.format("i16[%d] @ %d = %.6f", i, offset, ptr:readi16(offset)))
	end

	for i = 0, 23 do
		local offset = i
		print(string.format("i8[%d] @ %d = %.6f", i, offset, ptr:readi8(offset)))
	end

	print("\nRaw bytes:")
	for i = 0, size - 1 do
		print(string.format("%02d: %02X", i, ptr:readu8(i)))
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

local function debugBody(bodyInterface, bodyID, partName)
	local isActive = lib.JPH_BodyInterface_IsActive(bodyInterface, bodyID)
	local isAdded = lib.JPH_BodyInterface_IsAdded(bodyInterface, bodyID)

	local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())
	lib.JPH_BodyInterface_GetPosition(bodyInterface, bodyID, position)

	local posX = position:readf64(0)
	local posY = position:readf64(8)
	local posZ = position:readf64(16)

	print(
		string.format(
			"[Physics Debug] %s: Active=%s, Added=%s, Pos=(%.2f, %.2f, %.2f)",
			partName,
			tostring(isActive == 1),
			tostring(isAdded == 1),
			posX,
			posY,
			posZ
		)
	)
end

local function createBody(bodyInterface, part)
	if bodiesMap[part] then
		print("[Physics] Body already exists for part", part.Name)
		return
	end

	local halfSize = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	halfSize:writef32(0, part.Size.X / 2)
	halfSize:writef32(4, part.Size.Y / 2)
	halfSize:writef32(8, part.Size.Z / 2)

	local boxShape = lib.JPH_BoxShape_Create(halfSize, float_ptr(0.05))

	local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())
	position:writef64(0, part.Position.X)
	position:writef64(8, part.Position.Y)
	position:writef64(16, part.Position.Z)

	local rotation = ffi.alloc(structs.JPH_Quat:size(), structs.JPH_Quat:alignment())
	rotation:writef32(0, 0) -- x
	rotation:writef32(4, 0) -- y
	rotation:writef32(8, 0) -- z
	rotation:writef32(12, 1) -- w (identity quaternion)

	local motionType = part.Anchored and 0 or 2
	local layer = part.Anchored and LAYER_NON_MOVING or LAYER_MOVING

	local bodySettings = lib.JPH_BodyCreationSettings_Create3(boxShape, position, rotation, u8(motionType), u16(layer))

	local activation = (motionType == 2) and 1 or 0
	local bodyID = lib.JPH_BodyInterface_CreateAndAddBody(bodyInterface, bodySettings, activation)

	lib.JPH_BodyCreationSettings_Destroy(bodySettings)

	if bodyID == ffi.null then
		warn("[Physics] Failed to create body for", part.Name)
		return
	end

	if motionType == 2 then
		lib.JPH_BodyInterface_ActivateBody(bodyInterface, bodyID)
	end

	bodiesMap[part] = bodyID
	inverseMap[bodyID] = part

	--debugBody(bodyInterface, bodyID, part.Name)
end

local function CalculateBodyPhysics(part, bodyInterface, bodyID)
	if part.Anchored then
		return
	end
	if lib.JPH_BodyInterface_IsActive(bodyInterface, bodyID) == 0 then
		return
	end

	local position = ffi.alloc(structs.JPH_RVec3:size(), structs.JPH_RVec3:alignment())
	local rotation = ffi.alloc(structs.JPH_Quat:size(), structs.JPH_Quat:alignment())

	lib.JPH_BodyInterface_GetPositionAndRotation(bodyInterface, bodyID, position, rotation)

	local posX = position:readf64(0)
	local posY = position:readf64(8)
	local posZ = position:readf64(16)

	local velocity = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	local angular_vel = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())

	lib.JPH_BodyInterface_GetLinearVelocity(bodyInterface, bodyID, velocity)
	lib.JPH_BodyInterface_GetAngularVelocity(bodyInterface, bodyID, angular_vel)

	local velX = velocity:readf32(0)
	local velY = velocity:readf32(4)
	local velZ = velocity:readf32(8)

	local angvelX = angular_vel:readf32(0)
	local angvelY = angular_vel:readf32(4)
	local angvelZ = angular_vel:readf32(8)

	local rotX = rotation:readf32(0)
	local rotY = rotation:readf32(4)
	local rotZ = rotation:readf32(8)
	local rotW = rotation:readf32(12)

	local finalCF = CFrame.fromQuaternion(rotX, rotY, rotZ, rotW, roundVec3(Vector3.new(posX, posY, posZ)))
	local linearVelocity = roundVec3(Vector3.new(velX, velY, velZ))
	local angularVelocity = roundVec3(Vector3.new(angvelX, angvelY, angvelZ))

	return finalCF, linearVelocity, angularVelocity
end

local function setGravity(physicsSystem, v, wind)
	-- i HAVE to add the wind, its mandatory trust
	local gravity = ffi.alloc(structs.JPH_Vec3:size(), structs.JPH_Vec3:alignment())
	gravity:writef32(0, 0 + (wind and wind.X or 0)) -- X
	gravity:writef32(4, v + -(wind and wind.Y or 0)) -- Y
	gravity:writef32(8, 0 + (wind and wind.Z or 0)) -- Z
	lib.JPH_PhysicsSystem_SetGravity(physicsSystem, gravity)
end

KinemiumPhysicsService.InitRenderer = function(renderer, renderer_signal, game)
	print("[Physics] Initializing Jolt Physics...")

	local initSuccess = lib.JPH_Init()
	if initSuccess == 0 then
		error("[Physics] Failed to initialize Jolt")
	end
	print("[Physics] Jolt initialized")

	local broadPhaseLayerInterface =
		lib.JPH_BroadPhaseLayerInterfaceTable_Create(u32(NUM_OBJECT_LAYERS), u32(NUM_OBJECT_LAYERS))
	if broadPhaseLayerInterface == ffi.null then
		error("[Physics] Failed to create BroadPhaseLayerInterface")
	end
	print("finished")

	lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, LAYER_NON_MOVING, 0)
	lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, LAYER_MOVING, 1)
	print("[Physics] BroadPhaseLayerInterface created")

	local objectLayerPairFilter = lib.JPH_ObjectLayerPairFilterTable_Create(u32(NUM_OBJECT_LAYERS))
	if objectLayerPairFilter == ffi.null then
		error("[Physics] Failed to create ObjectLayerPairFilter")
	end

	lib.JPH_ObjectLayerPairFilterTable_DisableCollision(objectLayerPairFilter, LAYER_NON_MOVING, LAYER_NON_MOVING)
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

	setGravity(physicsSystem, -9.81)
	print("[Physics] Gravity set")

	local bodyInterface = lib.JPH_PhysicsSystem_GetBodyInterface(physicsSystem)
	if bodyInterface == ffi.null then
		error("[Physics] Failed to get body interface")
	end
	print("[Physics] Body interface obtained")

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
		maxConcurrency = 18, -- Number of threads
		maxBarriers = 8, -- Max barriers
	})
	local jobSystem = lib.JPH_JobSystemThreadPool_Create(config)
	if jobSystem == ffi.null then
		error("[Physics] Failed to create job system")
	end
	print("[Physics] Job system created")

	local bodyInterface = lib.JPH_PhysicsSystem_GetBodyInterface(physicsSystem)

	local propTable = {
		GetBody = function(part)
			return bodiesMap[part]
		end,
		UpdatePart = function(part)
			local body = bodiesMap[part]
			if not body then
				return
			end
			CalculateBodyPhysics(part, bodyInterface, body)
		end,
		Enabled = true,
		setGravity = function(value, wind)
			setGravity(physicsSystem, value, wind)
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
		Unload = function()
			-- added this function for
			-- Memory purposes........
			for _, body in pairs(bodiesMap) do
				lib.JPH_BodyInterface_RemoveAndDestroyBody(body)
			end
			lib.JPH_JobSystem_Destroy(jobSystem)
			lib.JPH_PhysicsSystem_Destroy(physicsSystem)
			lib.JPH_Shutdown()
		end,
		GetBodies = function()
			return bodiesMap
		end,
		GetPhysicsBodyCount = function()
			local i = 0

			-- i hate it when you cant do #bodiesmap
			-- why cant i just do that bruh
			for _, v in pairs(bodiesMap) do
				i += 1
			end

			return i
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
	lib.JPH_PhysicsSystem_OptimizeBroadPhase(physicsSystem)

	----------------------------------------
	-- CONSTRAINTS
	----------------------------------------

	propTable.constraints = {
		Weld = function(part1, part2)
			-- havent tested this yet but this must work
			local bodyID1 = bodiesMap[part1]
			local bodyID2 = bodiesMap[part2]

			if not bodyID1 or not bodyID2 then
				warn("[Physics] Both parts must have physics bodies")
				return
			end

			local settings = structs.JPH_FixedConstraintSettings:new({
				mAutoDetectPoint = 1,
				mSpace = 0,
			})

			local constraint = lib.JPH_FixedConstraint_Create(settings, bodyID1, bodyID2)
			lib.JPH_PhysicsSystem_AddConstraint(physicsSystem, constraint)
			return constraint
		end,
	}

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
			if not KinemiumPhysicsService.Enabled then
				return
			end
			local dt = data

			lib.JPH_PhysicsSystem_Update(physicsSystem, dt, 1, jobSystem)

			for part, bodyID in pairs(bodiesMap) do
				task.spawn(function()
					local cf, linear, angular = CalculateBodyPhysics(part, bodyInterface, bodyID)
					if not cf then
						return
					end
					runtime[part] = { cf, linear, angular }
				end)
			end

			for part, data in pairs(runtime) do
				part.CFrame = data[1]
				part.AssemblyLinearVelocity = data[2]
				part.AssemblyAngularVelocity = data[3]
			end
		end
	end)

	renderer_signal:Fire("PhysicsEngine", KinemiumPhysicsService)
end

return KinemiumPhysicsService
