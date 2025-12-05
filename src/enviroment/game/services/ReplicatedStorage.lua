local Instance = require("@Instance")
local signal = require("@kinetica.signal")

local ReplicatedStorage = Instance.new("ReplicatedStorage")

local RenderStepped = signal.new()
local Heartbeat = signal.new()

-- nothing to implement for now..

return ReplicatedStorage
