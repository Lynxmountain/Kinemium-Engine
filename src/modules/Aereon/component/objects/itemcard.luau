local raylib = require("@raylib")
local structs = raylib.structs

local rect = require("@arect")
local color3 = require("@Color3")

return function(objects, data)
	local config = {
		obj_rect = rect.new(data.x or data[1], data.y or data[2], data.width or data[3], data.height or data[4]),
		rounded = data.rounded or { 0.08, 8 },
		modifiers = {},

		title = data.title or "Sodium",
		description = data.description or "The fastest and most compatible rendering optimization mod for Minecraft.",
		downloads = data.downloads or "109.57M",
		likes = data.likes or "32.0k",
		category = data.category or "Optimization",
		icon = data.icon,
		bannerImage = data.bannerImage,
		font = data.font, -- Custom font property

		backgroundColor = color3.new(0.14, 0.14, 0.16),
		darkBackgroundColor = color3.new(0.10, 0.10, 0.12),
		iconBackgroundColor = color3.new(0.35, 0.75, 0.35),
		textColor = color3.new(0.85, 0.85, 0.87),
		dimTextColor = color3.new(0.60, 0.60, 0.63),
		categoryColor = color3.new(0.50, 0.50, 0.53),

		visible = data.visible ~= false,
		lastSize = { width = data.width or data[3] or 0, height = data.height or data[4] or 0 },
		isHovered = false,
		onClick = data.onClick,
	}

	local wrapper = {}

	wrapper.get_rect = function()
		if not config.visible then
			return rect.new(config.obj_rect.x, config.obj_rect.y, 0, 0)
		end
		if (config.obj_rect.width == 0 or config.obj_rect.height == 0) and config.lastSize then
			return rect.new(config.obj_rect.x, config.obj_rect.y, config.lastSize.width, config.lastSize.height)
		end
		return config.obj_rect
	end

	wrapper.get = function(prop)
		return config[prop]
	end

	wrapper.set = function(prop, value)
		if type(config[prop]) == "function" then
			return wrapper
		end
		if prop == "obj_rect" and value then
			config.obj_rect = value
			if value.width and value.height and value.width > 0 and value.height > 0 then
				config.lastSize = { width = value.width, height = value.height }
			end
			return wrapper
		end
		config[prop] = value
		return wrapper
	end

	wrapper.render = function(dt)
		if not config.visible then
			return
		end
		local r = config.obj_rect
		local mousePos = raylib.lib.GetMousePosition()
		local mousePressed = raylib.lib.IsMouseButtonPressed(0) == 1

		config.isHovered = rect.MouseIsInRect(r)

		raylib.lib.DrawRectangleRounded(
			rect:translate(r),
			config.rounded[1],
			config.rounded[2],
			config.backgroundColor:ToRaylib(0)
		)

		local padding = 12
		local bannerHeight = r.height * 0.45
		local iconSize = 48
		local iconPadding = 16

		local bannerRect = rect.new(r.x, r.y, r.width, bannerHeight)

		if config.bannerImage then
			raylib.lib.DrawTexturePro(
				config.bannerImage.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.bannerImage.x, height = config.bannerImage.y }),
				rect:translate(bannerRect),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		else
			raylib.lib.DrawRectangleGradientV(
				bannerRect.x,
				bannerRect.y,
				bannerRect.width,
				bannerRect.height,
				config.backgroundColor:ToRaylib(0.65),
				config.darkBackgroundColor:ToRaylib(0.50)
			)
		end

		local contentY = r.y + bannerHeight

		local iconY = contentY - iconSize / 2
		local iconRect = rect.new(r.x + iconPadding, iconY, iconSize, iconSize)

		raylib.lib.DrawRectangleRounded(rect:translate(iconRect), 0.15, 8, config.iconBackgroundColor:ToRaylib(0))

		if config.icon then
			raylib.lib.DrawTexturePro(
				config.icon.texture,
				structs.Rectangle:new({ x = 0, y = 0, width = config.icon.x, height = config.icon.y }),
				rect:translate(iconRect),
				vector.create(0, 0),
				0,
				raylib.const.WHITE
			)
		end

		-- Title with custom font
		local titleY = contentY + iconSize / 2 + 8
		local titleFontSize = 18
		local titleSpacing = 1.0

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.title,
				vector.create(r.x + iconPadding, titleY),
				titleFontSize,
				titleSpacing,
				config.textColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(config.title, r.x + iconPadding, titleY, titleFontSize, config.textColor:ToRaylib(0))
		end

		-- Description with custom font and word wrapping
		local descY = titleY + 26
		local descWidth = r.width - iconPadding * 2
		local descFontSize = 11
		local descSpacing = 0.5

		local words = {}
		for word in config.description:gmatch("%S+") do
			table.insert(words, word)
		end

		local currentLine = ""
		local lineY = descY

		for _, word in ipairs(words) do
			local testLine = currentLine == "" and word or currentLine .. " " .. word
			local lineWidth

			if config.font then
				local textSize = raylib.lib.MeasureTextEx(config.font, testLine, descFontSize, descSpacing)
				lineWidth = textSize.x
			else
				lineWidth = raylib.lib.MeasureText(testLine, descFontSize)
			end

			if lineWidth > descWidth then
				if config.font then
					raylib.lib.DrawTextEx(
						config.font,
						currentLine,
						vector.create(r.x + iconPadding, lineY),
						descFontSize,
						descSpacing,
						config.dimTextColor:ToRaylib(0)
					)
				else
					raylib.lib.DrawText(
						currentLine,
						r.x + iconPadding,
						lineY,
						descFontSize,
						config.dimTextColor:ToRaylib(0)
					)
				end
				currentLine = word
				lineY = lineY + 16
			else
				currentLine = testLine
			end
		end

		if currentLine ~= "" then
			if config.font then
				raylib.lib.DrawTextEx(
					config.font,
					currentLine,
					vector.create(r.x + iconPadding, lineY),
					descFontSize,
					descSpacing,
					config.dimTextColor:ToRaylib(0)
				)
			else
				raylib.lib.DrawText(
					currentLine,
					r.x + iconPadding,
					lineY,
					descFontSize,
					config.dimTextColor:ToRaylib(0)
				)
			end
		end

		-- Stats with custom font
		local statsY = r.y + r.height - 32
		local statsIconSize = 12
		local statsFontSize = 11
		local statsSpacing = 0.5

		raylib.lib.DrawRectangle(
			r.x + iconPadding,
			statsY + 4,
			statsIconSize,
			statsIconSize,
			config.dimTextColor:ToRaylib(0)
		)

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.downloads,
				vector.create(r.x + iconPadding + statsIconSize + 6, statsY + 2),
				statsFontSize,
				statsSpacing,
				config.dimTextColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(
				config.downloads,
				r.x + iconPadding + statsIconSize + 6,
				statsY + 2,
				statsFontSize,
				config.dimTextColor:ToRaylib(0)
			)
		end

		local likesX = r.x + iconPadding + 100
		raylib.lib.DrawRectangle(likesX, statsY + 4, statsIconSize, statsIconSize, config.dimTextColor:ToRaylib(0))

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.likes,
				vector.create(likesX + statsIconSize + 6, statsY + 2),
				statsFontSize,
				statsSpacing,
				config.dimTextColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(
				config.likes,
				likesX + statsIconSize + 6,
				statsY + 2,
				statsFontSize,
				config.dimTextColor:ToRaylib(0)
			)
		end

		local categoryX = r.x + r.width - iconPadding - 100
		raylib.lib.DrawRectangle(categoryX, statsY + 4, statsIconSize, statsIconSize, config.categoryColor:ToRaylib(0))

		if config.font then
			raylib.lib.DrawTextEx(
				config.font,
				config.category,
				vector.create(categoryX + statsIconSize + 6, statsY + 2),
				statsFontSize,
				statsSpacing,
				config.categoryColor:ToRaylib(0)
			)
		else
			raylib.lib.DrawText(
				config.category,
				categoryX + statsIconSize + 6,
				statsY + 2,
				statsFontSize,
				config.categoryColor:ToRaylib(0)
			)
		end

		if config.isHovered then
			raylib.lib.DrawRectangleRounded(
				rect:translate(r),
				config.rounded[1],
				config.rounded[2],
				config.backgroundColor:ToRaylib(0.95)
			)
		end

		if config.isHovered and mousePressed and config.onClick then
			config.onClick()
		end

		for _, m in pairs(config.modifiers) do
			m()
		end
	end

	table.insert(objects, wrapper)
	return wrapper
end
