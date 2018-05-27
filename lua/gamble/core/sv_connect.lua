GAMBLE.CFG.CreateField("enablechatcommand", "shared", 1, "Do you want to enable !gamble chat command?")
local function SendTotalGain(ply)
	local sid64 = ply:SteamID64()
	local data = pon.decode(file.Read("gamble/top.txt", "DATA") or "{}")
	local total = data[sid64] or 0
	net.Start("gamble_get_total_gain")
	net.WriteFloat(total)
	net.Send(ply)
end

net.Receive("gamble_get_total_gain", function(_, ply)
	if ply.sendTotalGain and ply.sendTotalGain > CurTime() then return end
	SendTotalGain(ply)
	ply.sendTotalGain = CurTime() + 25
end)

hook.Add("PlayerInitialSpawn", "Gamble_LoadPlayer", function(ply) 
	ply:Gamble_CheckData()
	GAMBLE.CFG.Network(ply)
	SendTotalGain(ply)
end)
hook.Add("PlayerDisconnected", "Gamble_DisconnectPlayer", function(ply) 
	GAMBLE.ConnectedUsers[ply:SteamID64()] = false;
end)
GAMBLE.SendUser = function(ply)
	net.Start("gamble_sync_users");
	net.WriteTable(GAMBLE.ConnectedUsers[ply:SteamID64()] or {credits = 0});
	net.Send(ply);
end
hook.Add("PlayerSay", "Gamble", function(ply, txt)
	if txt:lower():match("^[!/]gamble$") and GAMBLE.CFG.GetValue("enablechatcommand") == 1 then
		ply:ConCommand("gamble_menu")
		return ""
	end
end)
util.AddNetworkString("gamble_sync_users");
util.AddNetworkString("gamble_get_total_gain");
util.AddNetworkString("gamble_drm_failed");

for k,v in pairs(player.GetAll()) do
	v:Gamble_CheckData()
	GAMBLE.CFG.Network(v)
	SendTotalGain(v)
end

concommand.Add("_gamble_syncdata", function(ply)
	if ply.GMB_SYNC then return end

	ply:Gamble_CheckData()
	GAMBLE.CFG.Network(ply)
	SendTotalGain(ply)
	GAMBLE.TOP.Send(ply)

	ply.GMB_SYNC = true
end)