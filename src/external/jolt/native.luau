--!strict

local fs = zune.fs
local ffi = zune.ffi

local jolt = require("./jolt")

local export = {}

export.const = jolt.const
export.lib = ffi.dlopen("src/external/jolt/joltc.dll", jolt.def)

return export
