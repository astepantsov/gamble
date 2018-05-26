GAMBLE.Client = GAMBLE.Client or {credits = 0, total_gain = 0, unsynchronized = true}
GAMBLE.__LOADED = true
net.Receive("gamble_sync_config", function()
	local tbl = net.ReadTable()
	for k, v in pairs(tbl) do
		GAMBLE.CONFIG[k] = v
	end
end)

net.Receive("gamble_get_total_gain", function()
	GAMBLE.Client.total_gain = net.ReadFloat()
end)

net.Receive("gamble_sync_users", function()
	GAMBLE.Client.unsynchronized = nil
	local total = GAMBLE.Client.total_gain
	GAMBLE.Client = net.ReadTable()
	GAMBLE.Client.total_gain = total
end)

net.Receive("gamble_sendtop", function()
	GAMBLE.TOP30 = net.ReadTable();
end)

hook.Add("Think", "gamble_ask_for_sync", function()
	if !IsValid(LocalPlayer()) then return end

	if GAMBLE.Client.unsynchronized then
		RunConsoleCommand("_gamble_syncdata")
	end

	hook.Remove("Think", "gamble_ask_for_sync")
end)