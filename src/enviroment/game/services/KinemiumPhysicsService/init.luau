local Instance = require("@Instance")
local engine = require("@Impulse3D")
local Vector3 = require("@Vector3")

local KinemiumPhysicsService = Instance.new("KinemiumPhysicsService")
KinemiumPhysicsService.ExplorerHidden = true

local bodiesMap = {}

KinemiumPhysicsService.InitRenderer = function(renderer, renderer_signal)
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
			if data.Anchored == true then -- ADD THIS
				print("Part is anchored, Not registering body.")
				return
			end
			print(data.ClassName)
			local id = engine.body.new({
				position = data.Position,
				size = data.Size,
			})
			data.PhysicsId = id
		elseif route == "RenderStepped" then
			engine.Step(data)
		end
	end)

	engine.physics.render = function(id, object)
		for _, part in pairs(renderer.GetPool3D()) do
			if part.Anchored then
				continue
			end
			local physicsId = part.PhysicsId
			part.Position = object.position
		end
	end

	renderer_signal:Fire("PhysicsEngine", KinemiumPhysicsService)
end

return KinemiumPhysicsService
