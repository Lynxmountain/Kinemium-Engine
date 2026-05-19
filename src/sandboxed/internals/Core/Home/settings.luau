-- devcell

local raylib = require("@raylib")
local lib = raylib.lib
local aereon = require("@Aereon")
local gui = aereon.gui

local KinemiumFontService = game:GetService("KinemiumFontService")
local StudioThemeService = game:GetService("StudioThemeService")

local vend = KinemiumFontService.GetDefaultFontSmall()
local arect = require("@arect")
local KinemiumIconLoader = game:GetService("KinemiumIconLoader")

local ThirdBackgroundColor = StudioThemeService.SelectedTheme.ThirdBackgroundColor

local backgroundColor = StudioThemeService.SelectedTheme.BackgroundColor
local TextColor = StudioThemeService.SelectedTheme.TextColor:ToRaylib(StudioThemeService.SelectedTheme.TextTransparency)
StudioThemeService.SelectedTheme.GuiHandlesColor:ToRaylib(StudioThemeService.SelectedTheme.GuiHandlesTransparency)
local SecondaryBackgroundColorRaylib = StudioThemeService.SelectedTheme.SecondaryBackgroundColor:ToRaylib(
	StudioThemeService.SelectedTheme.SecondaryBackgroundColorTransparency
)

local screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

KinemiumIconLoader.new("Add", "./src/assets/images/icons/vanilla3/ui/16x/200/Add.png")

local textbox = aereon.textbox(StudioThemeService.SelectedTheme, game)
local group

group = aereon.create({
	frame = {
		comp = "frame",
		x = 0,
		y = 0,
		width = screenx,
		height = screeny,
		zindex = 1,
	},
	background = {
		comp = "frame",
		x = 0,
		y = 0,
		width = screenx,
		height = screeny,
		raylib_color = SecondaryBackgroundColorRaylib,
		zindex = 2,
		rounded = { 0, 10 },
	},
	title = {
		comp = "label",
		text = "Settings",
		x = 120,
		y = 120,
		font = vend,
		textColor = TextColor,
		backgroundColor = backgroundColor,
		zindex = 3,
	},
})

local cells = gui.cellparser({
	x = 0,
	y = 0,
	width = 800,

	aboutSection = {
		{
			name = "Version " .. ENGINE_VERSION,
			font = vend,
			backgroundColor = ThirdBackgroundColor,
		},

		{
			name = "Documentation",
			font = vend,
			backgroundColor = ThirdBackgroundColor,
		},
	},

	settingsSection = {
		{
			name = "Automatic updates",
			description = "Turn this off to prevent updates.",
			font = vend,
			backgroundColor = ThirdBackgroundColor,
		},
		{
			name = "Language",
			description = "Change interface language.",
			font = vend,
			backgroundColor = ThirdBackgroundColor,
		},
		{
			name = "Theme",
			description = "Change display gui theme.",
			font = vend,
			backgroundColor = ThirdBackgroundColor,
			editor = textbox.new({
				padding = 5,
				placeholder = "My Project",
				cornerRadius = 0.8,

				fontSize = 14,
				onSubmit = function(text)
					print("Project name:", text)
				end,
			}),
			editorWidth = 200,
		},
		{
			name = "Open project in VSCODE",
			description = "This will boot VSCode whenever you open a project.",
			font = vend,
			backgroundColor = ThirdBackgroundColor,
			editor = textbox.new({
				padding = 5,
				placeholder = "My Project",
				cornerRadius = 0.8,

				fontSize = 14,
				onSubmit = function(text)
					print("Project name:", text)
				end,
			}),
			editorWidth = 200,
		},
		{
			name = "Language",
			description = "Change display language.",
			font = vend,
			backgroundColor = ThirdBackgroundColor,
		},
	},
})

local scrollArea = gui.scrollable({
	child = cells,
	scrollbarWidth = 8,
	scrollbarColor = StudioThemeService.SelectedTheme.SecondaryBackgroundColor,
	scrollbarHoverColor = StudioThemeService.SelectedTheme.Accent,
	scrollbarBackground = StudioThemeService.SelectedTheme.ThirdBackgroundColor,
	scrollbarBackgroundTransparency = 0.7,
})

group.frame.setTransparency(1)

repeat
	task.wait()
until ishared.Home

ishared.Home.pages["Settings"] = function(dt, alpha, slideOffset)
	if ishared.Home.activePage ~= "Settings" and ishared.Home.previousPage ~= "Settings" then
		return
	end

	screenx, screeny = lib.GetRenderWidth(), lib.GetScreenHeight()

	local x = 60
	local y = 60 + slideOffset

	group.frame.set("obj_rect", arect.new(x, y, screenx, screeny))
	group.background.set("obj_rect", arect.new(x + 30, y + 30, screenx - 60, screeny - 60))
	group.title.set("obj_rect", arect.new(x + 60, y + 60, 200, 30))

	group.render(dt, { "newProjectPrompt" })

	-- Render scroll area
	scrollArea.set("obj_rect", arect.new(x + 60, y + 100, screenx - 120, screeny - 160))
	cells.setWidth(screenx - 140)
	scrollArea.render(dt)
end
