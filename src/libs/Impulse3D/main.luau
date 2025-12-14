-- devcell

local Impulse3D = {}

local body, physics, utility = require("./body"), require("./physics"), require("./utility")

Impulse3D.body = body
Impulse3D.physics = physics

function Impulse3D.Step(dt)
	physics.step(Impulse3D.body, dt)
end

export type Impulse3D = typeof(Impulse3D)

return Impulse3D :: Impulse3D
