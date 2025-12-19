local Instance = require("@Instance")
local engine = require("@Impulse3D")
local Vector3 = require("@Vector3")
local ffi = zune.ffi

local KinemiumPhysicsService = Instance.new("KinemiumPhysicsService")
KinemiumPhysicsService.ExplorerHidden = true

local bodiesMap = {}

local function writeu32(v)
	local count = ffi.create(ffi.types.u32)
	count:writeu32(0, v)
	return count
end

KinemiumPhysicsService.InitRenderer = function(renderer, renderer_signal, game)
	local jolt = require("@jolt")
	local lib = jolt.lib

	--[[
	local state = lib.JPH_Init()

	print("Physics system initialized with status:", state)

	local jobSystem = lib.JPH_JobSystemThreadPool_Create(jolt.structs.JPH_JobSystemConfig:new({
		context = 0,
		queueJob = nil, -- replace with actual callback pointer if you have it
		queueJobs = nil, -- replace with actual callback pointer if you have it
		maxConcurrency = 4,
		maxBarriers = 16,
	}))

	print("1")

	local NON_MOVING = 0
	local MOVING = 1

	print("2")

	local objectLayerFilter = lib.JPH_ObjectLayerPairFilterTable_Create(writeu32(2))
	lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerFilter, NON_MOVING, MOVING)
	lib.JPH_ObjectLayerPairFilterTable_EnableCollision(objectLayerFilter, MOVING, NON_MOVING)
	print("3")
	local broadPhaseLayerInterface = lib.JPH_BroadPhaseLayerInterfaceTable_Create(2, 2)
	lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, NON_MOVING, 0)
	lib.JPH_BroadPhaseLayerInterfaceTable_MapObjectToBroadPhaseLayer(broadPhaseLayerInterface, MOVING, 1)

	print(4)
	local objectVsBroadPhaseFilter =
		lib.JPH_ObjectVsBroadPhaseLayerFilterTable_Create(broadPhaseLayerInterface, 2, objectLayerFilter, 2)
	print(5)
			--]]

	local propTable = {
		GetBody = function(part)
			return bodiesMap[part]
		end,
	}
	KinemiumPhysicsService:SetProperties(propTable)

	renderer_signal:Connect(function(route, data)
		if route == "AddedPartToRenderPool" then
			if data.CanCollide == false then
				print("Part cancollide off, Not registering body.")
				return
			end
			if data.Anchored == true then
				print("Part is anchored, Not registering body.")
				return
			end
			local id = engine.body.new({
				position = data.Position,
				size = data.Size,
			})
			data.PhysicsId = id
		elseif route == "RenderStepped" then
			engine.Step(data)
		end
	end)

	engine.physics.render = function(id, object, dt)
		for _, part in pairs(game.Scene:GetDescendants()) do
			if part.Anchored then
				continue
			end
			local physicsId = part.PhysicsId
			if physicsId == id then
				if part.AssemblyLinearVelocity ~= nil then
					part.AssemblyLinearVelocity = object.velocity
				end

				part.Position = object.position
			end
		end
	end

	renderer_signal:Fire("PhysicsEngine", KinemiumPhysicsService)
end

return KinemiumPhysicsService
