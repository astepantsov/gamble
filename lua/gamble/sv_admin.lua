util.AddNetworkString("gamble_changeconfig");
util.AddNetworkString("gamble_findplayer");
util.AddNetworkString("gamble_setmoney");
util.AddNetworkString("gamble_setwins");

net.Receive("gamble_changeconfig", function(len, ply)
	if ply:IsSuperAdmin() then
		for k,v in pairs(net.ReadTable()) do
			GAMBLE.CFG.SetValue(k,v);
			GAMBLE.CFG.Network(_,k);
		end
		ui.Notify(ply, {Text = "Configuration has been saved", TextColor = ui.Colors.Green});
	end
end)

net.Receive("gamble_findplayer", function(len, ply)
	if ply:IsSuperAdmin() then
		local id = net.ReadString();
		if id:match("^STEAM_[0-4]:[01]:[0-9]+$") then
			id = util.SteamIDTo64(id); 
		end
		local data = GAMBLE.GetPlayerData(id);
		if data then
			local totalwins = GAMBLE.GetTotalWins(id);
			net.Start("gamble_findplayer");
			net.WriteTable({nickname = data.nickname, credits = data.credits, total_wins = totalwins, steamid64 = id});
			net.Send(ply);
		else
			ui.Notify(ply, {Text = "Player couldn't be found", TextColor = ui.Colors.Red});
		end
	end
end)

net.Receive("gamble_setmoney", function(len, ply)
	if ply:IsSuperAdmin() then
		local data = net.ReadTable();
		GAMBLE.SetCreditsSteamID64(data.steamid64, data.amount);
	end
end)

net.Receive("gamble_setwins", function(len, ply)
	if ply:IsSuperAdmin() then
		local data = net.ReadTable();
		GAMBLE.SetTotalWins(data.steamid64, data.amount);
	end 
end) 