local BlobLoader = game:GetService("BlobLoader")

local flagValue = GetFlagValue("blob")

if flagValue then
	if BlobLoader.MarkBlobLoadingPending then
		BlobLoader:MarkBlobLoadingPending()
	end
	task.spawn(function()
		print("Loading blob from", flagValue)
		local ok, read = pcall(Filesystem.readFile, flagValue, true)
		if not ok or not read then
			warn("Failed to read blob file: " .. tostring(read or flagValue))
			return
		end
		local loadOk, loadErr = pcall(BlobLoader.LoadFileAsGame, read)
		if not loadOk then
			warn("Failed to load blob: " .. tostring(loadErr))
		end
	end)
end
