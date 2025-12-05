local Instance = require("@Instance")
local signal = require("@kinetica.signal")

local RunService = Instance.new("RunService")

local RenderStepped = signal.new()
local Heartbeat = signal.new()
local Stepped = signal.new()

local renderBindings = {}

function RunService:BindToRenderStep(name, priority, callback)
	renderBindings[name] = { priority = priority, callback = callback }
end

function RunService:UnbindFromRenderStep(name)
	renderBindings[name] = nil
end

local function runRenderBindings(dt)
	local sorted = {}
	for name, data in pairs(renderBindings) do
		table.insert(sorted, data)
	end
	table.sort(sorted, function(a, b)
		return a.priority < b.priority
	end)
	for _, binding in ipairs(sorted) do
		binding.callback(dt)
	end
end

RunService.InitRenderer = function(renderer, renderer_signal)
	RunService:SetProperties({
		RenderStepped = RenderStepped,
		Heartbeat = Heartbeat,
		Stepped = Stepped,
		IsStudio = true,
		IsServer = false,
	})

	renderer_signal:Connect(function(route, dt)
		if route == "RenderStepped" then
			RenderStepped:Fire(dt)
			runRenderBindings(dt)
		elseif route == "Heartbeat" then
			Heartbeat:Fire(dt)
		elseif route == "Stepped" then
			Stepped:Fire(dt)
		end
	end)
end

function RunService:SetRobloxFPS(fps)
	local dt = 1 / fps
	local last = os.clock()
	return function()
		local now = os.clock()
		local elapsed = now - last
		if elapsed < dt then
			return false
		end
		last = now
		return true
	end
end

return RunService
