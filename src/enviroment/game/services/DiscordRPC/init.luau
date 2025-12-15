local rpc = require("@rpc")

local Instance = require("@Instance")
local signal = require("@Kinemium.signal")
local task = zune.task

local DiscordRPC = Instance.new("DiscordRPC")
DiscordRPC.ExplorerHidden = true

DiscordRPC.InitRenderer = function(renderer, renderer_signal)
	DiscordRPC:SetProperties({
		data = {
			state = "Playing",
			details = "idle..",
			largeImageText = "Kinemium Engine",
			smallImageText = "v5.0",
		},
		UpdatePresence = function(v)
			rpc:UpdatePresence(v)
		end,
		ChangeDetail = function(v)
			DiscordRPC.data.details = v
			rpc:UpdatePresence(DiscordRPC.data)
		end,
	})

	rpc:UpdatePresence(DiscordRPC.data)
end

return DiscordRPC
