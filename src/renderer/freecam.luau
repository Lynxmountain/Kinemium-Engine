local raylib = require("@raylib")
local lib = raylib.lib
local const = raylib.const
local structs = raylib.structs

local CFrame, Vector3 = require("@CFrame"), require("@Vector3")

local yaw = 0
local pitch = 0

local MOUSE_SENSITIVITY = 0.003
local MOVE_SPEED = 10

local cameraPos = vector.create(0.0, 5.0, 10.0)

local function UpdateFreecam(camera: raylib.Camera3D, delta: number, Kinemium_camera)
	if lib.IsMouseButtonPressed(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		lib.DisableCursor()
	end

	if lib.IsMouseButtonReleased(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		lib.EnableCursor()
	end

	if lib.IsMouseButtonDown(const.MouseButton.MOUSE_BUTTON_RIGHT) == 1 then
		local mouseDelta = lib.GetMouseDelta()
		yaw -= mouseDelta.x * MOUSE_SENSITIVITY
		pitch += mouseDelta.y * MOUSE_SENSITIVITY

		pitch = math.clamp(pitch, -math.pi / 2 + 0.01, math.pi / 2 - 0.01)
	end

	local forward = vector.create(math.sin(yaw) * math.cos(pitch), -math.sin(pitch), math.cos(yaw) * math.cos(pitch))
	forward = vector.normalize(forward)

	local up = vector.create(0.0, 1.0, 0.0)
	local right = vector.cross(forward, up)
	right = vector.normalize(right)

	local moveSpeed = MOVE_SPEED * delta
	local sideway = (lib.IsKeyDown(const.KeyboardKey.KEY_D) - lib.IsKeyDown(const.KeyboardKey.KEY_A))
		+ (lib.IsKeyDown(const.KeyboardKey.KEY_RIGHT) - lib.IsKeyDown(const.KeyboardKey.KEY_LEFT))

	local forwardInput = (lib.IsKeyDown(const.KeyboardKey.KEY_W) - lib.IsKeyDown(const.KeyboardKey.KEY_S))
		+ (lib.IsKeyDown(const.KeyboardKey.KEY_UP) - lib.IsKeyDown(const.KeyboardKey.KEY_DOWN))

	local vertical = lib.IsKeyDown(const.KeyboardKey.KEY_SPACE) - lib.IsKeyDown(const.KeyboardKey.KEY_LEFT_SHIFT)

	cameraPos += forward * (forwardInput * moveSpeed)
	cameraPos += right * (sideway * moveSpeed)
	cameraPos += up * (vertical * moveSpeed)

	local wheelMove = lib.GetMouseWheelMove()
	if wheelMove ~= 0 then
		cameraPos += forward * (wheelMove * 5.0) -- 5 units per scroll step
	end

	local target = cameraPos + forward
	zune.mem.writeVector3(camera, 0, cameraPos)
	zune.mem.writeVector3(camera, 12, target)
	buffer.writef32(camera, structs.Camera3D:offset("fovy"), Kinemium_camera.FieldOfView)

	local lookAt =
		CFrame.lookAt(Vector3.new(cameraPos.x, cameraPos.y, cameraPos.z), Vector3.new(target.x, target.y, target.z))

	Kinemium_camera.CFrame = lookAt
	Kinemium_camera.Position = Vector3.new(cameraPos.x, cameraPos.y, cameraPos.z)
	return cameraPos, target
end

return {
	Update = UpdateFreecam,
	SetSpeed = function(v)
		MOVE_SPEED = v
	end,
	SetSensitivity = function(v)
		MOUSE_SENSITIVITY = v
	end,
	GetPos = function()
		return cameraPos
	end,
}
