local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local lua = require("@lua")
local LuaVM = lua.LuaVM
local task = zune.task

local KinemiumIDE = Instance.new("KinemiumIDE")
KinemiumIDE.ExplorerHidden = true

local startup = [[
    package.path = package.path .. ";src/external/lua-webview/?.lua"
    package.cpath = package.cpath .. ";src/external/lua-webview/?.dll"
    
    require("webview-launcher")
    return true  -- Return success indicator
]]

local editor = [[
					local webviewLauncher = require("webview-launcher")
					local webviewLib = require("webview")

					   local spawn = coroutine.wrap or function(f) 
							local co = coroutine.create(f)
							coroutine.resume(co)
						end

					-- JSON library fallback
					local status, jsonLib = pcall(require, "cjson")
					if not status then
						status, jsonLib = pcall(require, "dkjson")
						if not status then
							-- basic JSON encode/decode
							jsonLib = {
								null = {},
								encode = function(v)
									local t = type(v)
									if t == "string" then
										return '"'..v..'"'
									elseif t == "number" or t == "boolean" then
										return tostring(v)
									elseif t == "table" then
										local isArray = true
										local n = 0
										for k in pairs(v) do
											if type(k) ~= "number" then isArray = false end
											n = n + 1
										end
										local items = {}
										if isArray then
											for i=1,n do
												table.insert(items, jsonLib.encode(v[i]))
											end
											return "["..table.concat(items,",").."]"
										else
											for k,val in pairs(v) do
												table.insert(items, '"'..k..'":'..jsonLib.encode(val))
											end
											return "{"..table.concat(items,",").."}"
										end
									end
									return "null"
								end,
								decode = function(_) return {} end -- basic decode stub
							}
						end
					end

					-- Monaco Editor wrapper
					local monaco = {}
					function monaco.launchMonaco(pathToHtml, opts)
						opts = opts or {}
						local width = opts.width or 800
						local height = opts.height or 600
						local title = opts.title or "Monaco Editor"
						local resizable = opts.resizable ~= false

						local wv = webviewLib.new("file://"..pathToHtml, title, width, height, resizable, false)
						local ctx = {}

						-- Track if the window is alive
						ctx.isOpen = true

						-- JS->Lua bridge
						local function callback(request)
							local _, name, _, value = string.match(request, '^(%A?)(%a%w*)([:;])(.*)$')
							if name == "editorContent" and ctx.onContent then
								ctx.onContent(value)
							elseif name == "runLua" and ctx.onRun then
								ctx.onRun(value)
							elseif name == "editorChanged" then
								_G.lastEditorContent = value
								KinemiumIDE.Changed:Fire(value)
							end
						end
						webviewLib.callback(wv, callback)

						-- Stop polling if window closes
						webviewLib.onClose(wv, function()
							ctx.isOpen = false
							print("Monaco window closed — polling will stop")
							-- optionally just hide: webviewLib.hide(wv)
						end)

						-- API
						ctx.evalJs = function(js) webviewLib.eval(wv, js, true) end
						ctx.getEditorContent = function(cb)
							if ctx.isOpen then
								ctx.onContent = cb
								ctx.evalJs("window.external.invoke('editorContent:' + window.getEditorContent());")
							else
								cb(nil) -- Return nil if closed
							end
						end
						ctx.terminate = function() 
							ctx.isOpen = false
							webviewLib.terminate(wv, false)
						end

						-- Start loop asynchronously
						local co = coroutine.create(function() webviewLib.loop(wv) end)
						coroutine.resume(co)

						return ctx
					end

					_G.monaco = monaco
					_G.editor = monaco.launchMonaco("C:/Users/devco/OneDrive/Desktop/KineticaEngine/src/editor.html", {
						width = 1024, height = 768, title = "Kinemium Editor"
					})

					-- Store the last editor content
					_G.lastEditorContent = ""

					-- Request content update (non-blocking)
					function requestEditorContent()
						print("bro requesting editor content")
						print("wait twin")
						if _G.editor and _G.editor.getEditorContent then
							_G.editor.getEditorContent(function(content)
								_G.lastEditorContent = content
								print("i got it twin")
								print("its", content)
							end)
						end
					end

					-- Get the last cached content
					function getEditorText()
						print("returning the text for you twin")
						print("its", _G.lastEditorContent)
						return _G.lastEditorContent
					end

					return monaco
			]]

KinemiumIDE.InitRenderer = function(renderer, renderer_signal)
	local editorReady = false
	local vm = LuaVM.new()

	KinemiumIDE:SetProperties({
		Open = function()
			task.spawn(function()
				local success, result, err = vm:execute(startup)

				if not success then
					error("Failed to load webview-launcher.lua: " .. (err or "unknown error"))
				end

				local lib = vm:execute(editor)
				editorReady = true
				vm:execute([[
					print(_G)
				]])
			end)
		end,

		GetText = function()
			if not editorReady then
				warn("Editor not initialized yet")
				return ""
			end

			vm:call("requestEditorContent")

			task.wait(0.2)

			local success, text = vm:call("getEditorText")
			if success then
				print("Got editor text:", text)
				return text or ""
			else
				warn("Failed to get editor text")
				return nil
			end
		end,

		Changed = signal.new(),
	})
end

return KinemiumIDE
