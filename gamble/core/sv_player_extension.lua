local Player = FindMetaTable('Player');
function Player:Gamble_UpdateNickname()
	GAMBLE.ConnectedUsers[self:SteamID64()].nickname = self:Name();
	file.Write( "gamble/users/" .. self:SteamID64() .. ".txt", pon.encode(GAMBLE.ConnectedUsers[self:SteamID64()]) );
	GAMBLE.SendUser(self);
end
function Player:Gamble_LoadData()
	local data = pon.decode(file.Read( "gamble/users/" .. self:SteamID64() .. ".txt", "DATA" )) or {credits = 0, nickname = self:Name()};
	GAMBLE.ConnectedUsers[self:SteamID64()] = data;
	GAMBLE.SendUser(self);
	GAMBLE.TOP.Send(self);
	self:Gamble_UpdateNickname();
	MsgN("[GAMBLE] Data has been successfully loaded for the player " .. self:Name() .. ".");
end
function Player:Gamble_CreateRecord()
	file.Write( "gamble/users/" .. self:SteamID64() .. ".txt", pon.encode({nickname = self:Name(), credits = 0}) );
	MsgN("[GAMBLE] Player " .. self:Name() .. " has joined for the first time. A new record has been created.");
	self:Gamble_CheckData();
end
function Player:Gamble_CheckData()
	if file.Exists( "gamble/users/" .. self:SteamID64() .. ".txt", "DATA" ) then
		self:Gamble_LoadData();
	else
		self:Gamble_CreateRecord();
	end
end
function Player:Gamble_GetCredits()
	return GAMBLE.ConnectedUsers[self:SteamID64()].credits;
end

function Player:Gamble_CanAfford(value)
	if GAMBLE.CFG.GetValue("freegame") == 1 then return true end
	return self:Gamble_GetCredits() >= value
end

function Player:Gamble_SetCredits(amount)
	GAMBLE.ConnectedUsers[self:SteamID64()].credits = amount;
	file.Write( "gamble/users/" .. self:SteamID64() .. ".txt", pon.encode(GAMBLE.ConnectedUsers[self:SteamID64()]) );
	GAMBLE.SendUser(self);
end

function Player:Gamble_AddCredits(amount)
	self:Gamble_SetCredits(self:Gamble_GetCredits() + amount)
end

GAMBLE.GetCreditsSteamID64 = function(steamid64)
	if GAMBLE.ConnectedUsers[steamid64] then
		return GAMBLE.ConnectedUsers[steamid64].credits;
	else
		if file.Exists( "gamble/users/" .. steamid64 .. ".txt", "DATA" ) then
			local data = pon.decode(file.Read( "gamble/users/" .. steamid64 .. ".txt", "DATA" ));
			return data.credits;
		else
			return 0;
		end
	end
end

GAMBLE.SetCreditsSteamID64 = function(steamid64, amount)
	if GAMBLE.ConnectedUsers[steamid64] then
		GAMBLE.ConnectedUsers[steamid64].credits = amount;
		file.Write( "gamble/users/" .. steamid64 .. ".txt", pon.encode(GAMBLE.ConnectedUsers[steamid64]) );
		GAMBLE.SendUser(player.GetBySteamID64(steamid64));
	else
		if file.Exists( "gamble/users/" .. steamid64 .. ".txt", "DATA" ) then
			local data = pon.decode(file.Read( "gamble/users/" .. steamid64 .. ".txt", "DATA" ));
			data.credits = amount;
			file.Write( "gamble/users/" .. steamid64 .. ".txt", pon.encode(data) );
		else
			file.Write( "gamble/users/" .. steamid64 .. ".txt", pon.encode({nickname = self:Name(), credits = amount}) );
		end
	end
end

GAMBLE.AddCreditsSteamID64 = function(steamid64, amount)
	GAMBLE.SetCreditsSteamID64(steamid64, GAMBLE.GetCreditsSteamID64(steamid64) + amount)
end

GAMBLE.GetTotalWins = function(steamid64)
	if file.Exists( "gamble/top.txt", "DATA" ) then
		local data = pon.decode(file.Read( "gamble/top.txt", "DATA" ));
		return data[steamid64] or 0;
	else
		return 0;
	end
end

GAMBLE.SetTotalWins = function(steamid64, amount)
	if file.Exists( "gamble/top.txt", "DATA" ) then
		local data = pon.decode(file.Read( "gamble/top.txt", "DATA" ));
		data[steamid64] = amount;
		file.Write( "gamble/top.txt", pon.encode(data) );
	else
		file.Write( "gamble/top.txt", pon.encode({}) );
	end
	if GAMBLE.ConnectedUsers[steamid64] then
		GAMBLE.SendUser(player.GetBySteamID64(steamid64));
	end
end

GAMBLE.AddTotalWins = function(steamid64, amount)
	GAMBLE.SetTotalWins(steamid64, GAMBLE.GetTotalWins(steamid64) + amount)
end

GAMBLE.GetPlayerData = function(steamid64)
	if file.Exists( "gamble/users/" .. steamid64 .. ".txt", "DATA" ) then
		return pon.decode(file.Read( "gamble/users/" .. steamid64 .. ".txt", "DATA" )) or {};
	end
	return false;
end