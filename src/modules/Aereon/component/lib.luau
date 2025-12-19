local lib = {}
local raylib = require("@raylib")
local structs = raylib.structs

local function c3tr(c, transparency)
	local r, g, b = c:ToRGB()
	return structs.Color:new({
		r = r,
		g = g,
		b = b,
		a = math.floor(255 * (1 - transparency)),
	})
end

local rect = require("../rect")(raylib.lib)
local color3 = require("@Color3")

local renderCallbacks = {}

local comps = {
	frame = function(data)
		local config = {
			obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
			color = color3.new(1, 1, 1),
			raylib_color = c3tr(color3.new(1, 1, 1), 0),
			bgtransparency = 0,
			clicked = nil,
			hoveredCallback = nil,
			rounded = nil,
			disabled = false,
			modifiers = {},
		}

		local wrapper = {}

		wrapper.modifers = {
			outline = function(value, color, transparency)
				table.insert(config.modifiers, function()
					if config.rounded then
						raylib.lib.DrawRectangleRoundedLinesEx(
							rect:translate(config.obj_rect),
							config.rounded[1],
							config.rounded[2],
							value,
							c3tr(color, transparency) or raylib.const.WHITE
						)
					else
						raylib.lib.DrawRectangleLinesEx(
							rect:translate(config.obj_rect),
							value,
							c3tr(color, transparency) or raylib.const.WHITE
						)
					end
				end)
				return wrapper
			end,

			mouseIsIn = function(callback)
				if rect.MouseIsInRect(config.obj_rect) then
					callback(wrapper)
				end
			end,

			custom = function(callback)
				callback(wrapper)
			end,
		}

		wrapper.disabled = function(value)
			config.disabled = value
			return wrapper
		end

		wrapper.clicked = function(callback)
			config.clicked = callback
			return wrapper
		end

		wrapper.hovered = function(hoverCallback)
			config.hoveredCallback = hoverCallback
			return wrapper
		end

		wrapper.setTransparency = function(t)
			config.bgtransparency = t
			config.raylib_color = c3tr(config.color, config.bgtransparency)
			return wrapper
		end

		wrapper.width = function(v)
			config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, v, config.obj_rect.height)
			return wrapper
		end

		wrapper.height = function(v)
			config.obj_rect = rect.new(config.obj_rect.x, config.obj_rect.y, config.obj_rect.width, v)
			return wrapper
		end

		wrapper.rounded = function(radius, segments)
			config.rounded = { radius, segments }
		end

		wrapper.posx = function(v)
			config.obj_rect = rect.new(v, config.obj_rect.y, config.obj_rect.width, config.obj_rect.height)
			return wrapper
		end

		wrapper.posy = function(v)
			config.obj_rect = rect.new(config.obj_rect.x, v, config.obj_rect.width, config.obj_rect.height)
			return wrapper
		end

		wrapper.set = function(prop, value)
			if type(config[prop]) == "function" then
				return wrapper
			end
			config[prop] = value
			return wrapper
		end

		wrapper.render = function(dt)
			if config.clicked ~= nil then
				if not config.disabled then
					rect.Button(config.obj_rect, function(a0)
						config.clicked(wrapper)
					end)
				end
			end
			if config.hoveredCallback ~= nil then
				rect.Hover(config.obj_rect, function(a0)
					config.hoveredCallback(wrapper)
				end)
			end

			if config.rounded then
				raylib.lib.DrawRectangleRounded(
					rect:translate(config.obj_rect),
					config.rounded[1],
					config.rounded[2],
					config.raylib_color
				)
			else
				raylib.lib.DrawRectangleRec(rect:translate(config.obj_rect), config.raylib_color)
			end

			for _, modifier in pairs(config.modifiers) do
				modifier()
			end
		end

		table.insert(renderCallbacks, wrapper.render)
		return wrapper
	end,
}

function comps:step(dt)
	for _, callback in pairs(renderCallbacks) do
		callback(dt)
	end
end

return comps
