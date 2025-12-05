--!strict

local native = require("@self/native")
local jolt = require("@self/jolt")

local lib = native.lib
local const = native.const

-- Initialize Jolt Physics
local success = lib.JPH_Init()
if not success then
	error("Failed to initialize Jolt Physics")
end

local export = {
	lib = lib,
	const = const,
	initialized = true,
}

return export
