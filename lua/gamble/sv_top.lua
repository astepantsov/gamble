util.AddNetworkString("gamble_sendtop");

GAMBLE.CFG.CreateField("TopRefresh", "server", 3);
GAMBLE.TOP = GAMBLE.TOP or {};
GAMBLE.TOP.Refresh = function()
	local data = pon.decode(file.Read( "gamble/top.txt", "DATA" ) or "{}") or {};
	local temp = {};
	local top30 = {};
	for k,v in pairs(data) do
		table.insert(temp, {steamid64 = k, total_sum = v})
	end
	table.SortByMember( temp, "total_sum" );
	for i = 1, 30, 1 do
		if temp[i] then
			local player_data = GAMBLE.GetPlayerData(temp[i].steamid64);
			table.insert(top30, {steamid64 = temp[i].steamid64, total_sum = temp[i].total_sum, nickname = player_data.nickname});
		end
	end
	GAMBLE.TOP.Top30 = top30;
	GAMBLE.TOP.Broadcast();
end

GAMBLE.TOP.Send = function(ply)
	net.Start("gamble_sendtop");
	net.WriteTable(GAMBLE.TOP.Top30);
	net.Send(ply);
end

GAMBLE.TOP.Broadcast = function()
	net.Start("gamble_sendtop");
	net.WriteTable(GAMBLE.TOP.Top30);
	net.Broadcast();
end

timer.Create("Gamble_Top_Refresh", GAMBLE.CFG.GetValue("TopRefresh") * 60, 0, function()
	GAMBLE.TOP.Refresh();
end)

GAMBLE.TOP.Refresh();
