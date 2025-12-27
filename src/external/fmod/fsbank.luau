--!strict
--!optimize 2
--!native

local ffi = zune.ffi

-- Basic type aliases
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local double = ffi.types.double

-- Struct definitions (ordered by dependencies)
-- NOTE: Some structs may have FIXME comments for array sizes that need manual definition

local FSBANK_SUBSOUND = ffi.struct({
	{ numFiles = ffi.types.i32 },
	{ overrideFlags = ffi.types.pointer },
	{ overrideQuality = ffi.types.i32 },
	{ desiredSampleRate = ffi.types.float },
	{ percentOptimizedRate = ffi.types.float },
})
export type FSBANK_SUBSOUND = typeof(FSBANK_SUBSOUND:new({}))

local FSBANK_PROGRESSITEM = ffi.struct({
	{ subSoundIndex = ffi.types.i32 },
	{ threadIndex = ffi.types.i32 },
	{ state = ffi.types.pointer },
})
export type FSBANK_PROGRESSITEM = typeof(FSBANK_PROGRESSITEM:new({}))

local FSBANK_STATEDATA_FAILED = ffi.struct({
	{ errorCode = ffi.types.pointer },
	{ errorString = ffi.types.i8:array(256) },
})
export type FSBANK_STATEDATA_FAILED = typeof(FSBANK_STATEDATA_FAILED:new({}))

local FSBANK_STATEDATA_WARNING = ffi.struct({
	{ warnCode = ffi.types.pointer },
	{ warningString = ffi.types.i8:array(256) },
})
export type FSBANK_STATEDATA_WARNING = typeof(FSBANK_STATEDATA_WARNING:new({}))

-- Function definitions
local funcs = {
	FSBank_MemoryInit = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.pointer },
	},
	FSBank_Init = {
		returns = ffi.types.pointer,
		args = { ffi.types.pointer, ffi.types.pointer, ffi.types.u32, ffi.types.pointer },
	},
	FSBank_Release = { returns = ffi.types.pointer, args = {} },
	FSBank_Build = {
		returns = ffi.types.pointer,
		args = {
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
			ffi.types.pointer,
			ffi.types.u32,
			ffi.types.pointer,
			ffi.types.pointer,
		},
	},
	FSBank_FetchFSBMemory = { returns = ffi.types.pointer, args = { ffi.types.pointer, ffi.types.u32 } },
	FSBank_BuildCancel = { returns = ffi.types.pointer, args = {} },
	FSBank_FetchNextProgressItem = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FSBank_ReleaseProgressItem = { returns = ffi.types.pointer, args = { ffi.types.pointer } },
	FSBank_MemoryGetStats = { returns = ffi.types.pointer, args = { ffi.types.u32, ffi.types.u32 } },
}

local structs = {
	FSBANK_SUBSOUND = FSBANK_SUBSOUND,
	FSBANK_PROGRESSITEM = FSBANK_PROGRESSITEM,
	FSBANK_STATEDATA_FAILED = FSBANK_STATEDATA_FAILED,
	FSBANK_STATEDATA_WARNING = FSBANK_STATEDATA_WARNING,
}

return { funcs = funcs, structs = structs }
