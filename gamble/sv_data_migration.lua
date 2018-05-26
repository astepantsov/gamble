GAMBLE.Migration = GAMBLE.Migration or {}

GAMBLE.Migration.ImportData = function(path)
	local content = file.Read("gamble/" .. path .. ".dat", "DATA")
	if !content then print("[GAMBLE] Invalid data file."); return end

	local temp = {}
	for k, v in pairs(pon.decode(content)) do
		table.insert(temp, {sid = k, data = v})
	end

	local delay = 0.2
	print("[GAMBLE] This will take ~" .. delay * #temp .. " seconds")

	local i = 0
	if #temp == 0 then return end
	timer.Create("gamble_importdata", delay, #temp, function()
		i = i + 1
		
		print("[GAMBLE] Adding " .. temp[i].sid .. "...")
		file.Write("gamble/users/" .. temp[i].sid .. ".txt", temp[i].data)
	end)
end

GAMBLE.Migration.ExportData = function(path)
	local files, _ = file.Find("gamble/users/*", "DATA")
	local delay = 0.2

	print("[GAMBLE] This will take ~" .. delay * #files .. " seconds")

	local temp = {}
	local i = 0
	timer.Create("gamble_exportdata", delay, #files + 1, function()
		i = i + 1
		
		if i > #files then
			file.Write("gamble/" .. path .. ".dat", pon.encode(temp))
			print("[GAMBLE] Data export is over, saved to the 'gamble/" .. path .. ".dat'")
			return
		end
		local sid = files[i]:StripExtension()
		print("[GAMBLE] Adding " .. sid .. "...")
		temp[sid] = file.Read("gamble/users/" .. files[i], "DATA")
	end)
end

GAMBLE.Migration.ClearData = function()
	local files, _ = file.Find("gamble/users/*", "DATA")
	local delay = 0.3

	print("[GAMBLE] This will take ~" .. delay * #files .. " seconds")

	local i = 0
	timer.Create("gamble_cleardata", delay, #files, function()
		i = i + 1

		print("[GAMBLE] Deleting " .. files[i] .. "...")
		file.Delete("gamble/users/" .. files[i])
	end)
end

concommand.Add("gamble_exportdata", function(ply, _, args)
	if ply != NULL and !ply:IsSuperAdmin() then return end

	GAMBLE.Migration.ExportData(args[1] or "exported_data")
end)

concommand.Add("gamble_importdata", function(ply, _, args)
	if ply != NULL and !ply:IsSuperAdmin() then return end

	GAMBLE.Migration.ImportData(args[1] or "exported_data")
end)

concommand.Add("gamble_cleardata", function(ply, _, args)
	if ply != NULL and !ply:IsSuperAdmin() then return end

	GAMBLE.Migration.ClearData()
end)