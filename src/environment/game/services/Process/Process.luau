local Instance = require("@Instance")
local signal = require("@Kinemium.signal")

local zpross = zune.process

local Process = Instance.new("Process")
Process.ExplorerHidden = true

Process.InitRenderer = function(renderer, renderer_signal)
	Process:SetProperties({
		CreateKinemiumClientProcess = function(flags: { string })
			local info = {
				"run",
				"game",
				"--client",
				"--username",
				"Dev",
				"--max3dpixels",
				"144000",
				"--perfoverlay",
			}

			if flags then
				for _, flag in ipairs(flags) do
					table.insert(info, flag)
				end
			end

			local process = zune.process.create(zune.fs.getExePath(), info, {
				opts = { stdin = "inherit", stdout = "inherit", stderr = "inherit" },
			})
			return process
		end,

		CreateKinemiumClientProcessEx = function(username, ip, port, flags)
			local info = {
				"run",
				"game",
				"--client",
				"--username",
				username,
				"--address",
				ip,
				"--port",
				tostring(port),
				"--max3dpixels",
				"144000",
				"--perfoverlay",
			}

			if flags then
				for _, flag in ipairs(flags) do
					table.insert(info, flag)
				end
			end

			local process = zune.process.create(zune.fs.getExePath(), info, {
				opts = { stdin = "inherit", stdout = "inherit", stderr = "inherit" },
			})
			return process
		end,

		CreateKinemiumServerProcessPiped = function(ip, port, maxPlayers)
			local info = {
				"run",
				"game",
				"--server",
				"--kilang",
				"--port",
				tostring(port),
				"--address",
				ip,
			}

			if maxPlayers then
				table.insert(info, "--max-players")
				table.insert(info, tostring(maxPlayers))
			end

			local process = zune.process.create(zune.fs.getExePath(), info, {
				opts = { stdout = "piped", stderr = "piped" },
			})
			return process
		end,

		CreateKinemiumServerProcessEx = function(ip, port)
			-- example zune run game --server --port 1234 --address 0.0.0.0
			local info = {
				"run",
				"game",
				"--server",
				"--kilang",
				"--port",
				tostring(port),
				"--address",
				ip,
			}

			local process = zune.process.create(zune.fs.getExePath(), info, {
				opts = { stdin = "inherit", stdout = "inherit", stderr = "inherit" },
			})
			return process
		end,

		CreateKinemiumServerProcess = function(flags: { string })
			local info = {
				"run",
				"game",
				"--server",
				"--kilang",
			}

			if flags then
				for _, flag in ipairs(flags) do
					table.insert(info, flag)
				end
			end

			local process = zune.process.create(zune.fs.getExePath(), info, {
				opts = { stdin = "inherit", stdout = "inherit", stderr = "inherit" },
			})
			return process
		end,
	})
end
return Process
