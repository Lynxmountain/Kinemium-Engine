--!strict

local ffi = zune.ffi

local void = ffi.types.void
local int = ffi.types.i32
local uint = ffi.types.u32
local float = ffi.types.float
local double = ffi.types.double
local bool = ffi.types.u8
local cstring = ffi.types.pointer

-- Jolt Physics types
type JPC_BodyID = buffer
type JPC_Vec3 = buffer
type JPC_RVec3 = buffer
type JPC_Quat = buffer
type JPC_Mat44 = buffer
type JPC_BodyCreationSettings = buffer
type JPC_Shape = buffer
type JPC_ShapeSettings = buffer
type JPC_BoxShapeSettings = buffer
type JPC_PhysicsSystem = buffer
type JPC_PhysicsSystemSettings = buffer
type JPC_BodyInterface = buffer
type JPC_JobSystem = buffer
type JPC_JobSystemConfig = buffer

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

local def = {
	-- Initialization
	JPH_Init = fn(bool, {}),
	JPH_Shutdown = fn(void, {}),
}

local const = {
	JPC_MOTION_TYPE_STATIC = 0,
	JPC_MOTION_TYPE_KINEMATIC = 1,
	JPC_MOTION_TYPE_DYNAMIC = 2,

	JPC_BROAD_PHASE_LAYER_NON_MOVING = 0,
	JPC_BROAD_PHASE_LAYER_MOVING = 1,

	JPC_OBJECT_LAYER_NON_MOVING = 0,
	JPC_OBJECT_LAYER_MOVING = 1,

	JPC_ACTIVATION_ACTIVATE = 0,
	JPC_ACTIVATION_DONT_ACTIVATE = 1,
}

return {
	def = def,
	const = const,
}
