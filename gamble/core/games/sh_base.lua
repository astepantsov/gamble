GAMBLE.Games = GAMBLE.Games or {list = {}, players = {}}

local send = {
	["string"] = "WriteString",
	["number"] = "WriteFloat",
	["boolean"] = "WriteBool",
	["table"] = "WriteTable",
	["Entity"] = "WriteEntity",
	["Player"] = "WriteEntity"
}

file.CreateDir("gamble/games")

hook.Add("GambleGameInit", "createdir", function(scene)
	file.CreateDir("gamble/games/" .. scene.ID)
	local dirs = {"logs"}
	for k, v in ipairs(dirs) do
		file.CreateDir("gamble/games/" .. scene.ID .. "/" .. v)
	end
end)

// TODO: polish the code

GAMBLE.Games._MetaTableScene = {
	__values = {players = {}, logs = {}},
	__callbacks = {},
	CrashSave = {},
	
	GetID = function(self)
		return self.ID
	end,
	GetName = function(self)
		return self.Name
	end,
	GetPlayers = function(self)
		return self.__values.players
	end,
	AddCallback = function(self, callname, name, func)
		self.__callbacks[callname] = self.__callbacks[callname] or {}
		self.__callbacks[callname][name] = func
	end,
	RemoveCallback = function(self, callname, name)
		self.__callbacks[callname][name] = nil
	end,
	// makes networking a lot easier
	RegisterNetMessage = function(self, name, side)
		local msgname = "gamble_scene_" .. self:GetID() .. "_" .. name:lower()
		
		if SERVER then
			util.AddNetworkString(msgname)
		end
		if side then
			if side == "client" && CLIENT then
				net.Receive(msgname, function(len, ply)
					if !GAMBLE_CURRENT_SCENE or GAMBLE_CURRENT_SCENE != self.ID then return end
					self:Call("Net_" .. name, len, ply)
				end)
			elseif side == "server" && SERVER then
				net.Receive(msgname, function(len, ply)
					self:Call("Net_" .. name, len, ply)
				end)
			end
		else
			net.Receive(msgname, function(len, ply)
				if CLIENT and (!GAMBLE_CURRENT_SCENE or GAMBLE_CURRENT_SCENE != self.ID) then return end
				self:Call("Net_" .. name, len, ply)
			end)
		end
	end,
	Network = function(self, ply, msg, ...)
		net.Start("gamble_scene_" .. self:GetID() .. "_" .. msg:lower())
		for k, v in ipairs({...}) do
			local t = type(v)
			net[send[t]](v)
		end
		if CLIENT then
			net.SendToServer()
		else
			net.Send(ply)
		end
	end,
	// call hook on client without arguments
	CallOnClient = function(self, ply, name)
		net.Start("gamble_scene_broadcast")
		net.WriteString(name)
		net.Send(ply)
	end,
	Call = function(self, name, ...)
		if CLIENT and name != "Initialize" and (!GAMBLE_CURRENT_SCENE or GAMBLE_CURRENT_SCENE != self.ID) then return end
		local toreturn = false
		
		if self[name] then
			toreturn = self[name](self, ...)
		end
		
		for k, v in pairs(self.__callbacks[name] or {}) do
			v(self, ...)
		end
		
		return toreturn
	end,
	Print = function(self, ...)
		local tbl = {...}
		
		for k, v in ipairs(tbl) do
			if !IsColor(v) then
				tbl[k] = GAMBLE.ObjectToString(v)
			end
		end

		table.insert(tbl, "\n")
		
		MsgC("(Gamble Scene) " .. self:GetName() .. ": ", unpack(tbl))
	end,
	Error = function(self, ...)
		local str = ""

		for k, v in ipairs({...}) do
			str = str .. GAMBLE.ObjectToString(v)
		end

		MsgC(Color(255, 0, 0), "(Gamble Scene) " .. self:GetName() .. ": ERROR: ", str, "\n")
	end,
	// logs are saved
	Log = function(self, ...)
		local str = ""
		
		for k, v in pairs({...}) do
			str = str .. GAMBLE.ObjectToString(v)
		end
		
		table.insert(self.__values.logs, {time = os.time(), log = str})
	end,
	PushLogs = function(self)
		local str = ""
		for k, v in SortedPairsByMemberValue(self.__values.logs, "time") do
			local date = os.date("[%X]: ", v.time)
			str = str .. date .. v.log .. "\n"
		end
		file.Append("gamble/games/" .. self.ID .. "/logs/" .. os.date("%d_%m_%Y", os.time()) .. ".txt", str)
		self.__values.logs = {}
	end,
	Debug = function(self, ...)
		if GAMBLE._VERSION == 0 then
			self:Print(...)
		end
	end,
	PlayerCanEnter = function() return true end,
	Leave = function(self)
		if !CLIENT then return end
		
		GAMBLE.Games.LeaveGame()
	end,
	Kick = function(self, ply, reason, showmsg)
		if !SERVER then return end

		if reason and showmsg then
			ui.Notify(ply, {Text = ("Kicked: " .. reason), TextColor = ui.Colors.Red})
		end
		
		GAMBLE.Games.Leave(ply, reason or "kicked")
	end,
	cSave = function(self)
		local temp = {}

		for _, v in ipairs(self.CrashSave) do
			temp[v] = self[v]
		end

		local data = pon.encode(temp)
		file.Write("gamble/games/temp_" .. self.ID .. ".dat", data)
	end,
	cClear = function(self)
		file.Delete("gamble/games/temp_" .. self.ID .. ".dat")
	end
} 

if SERVER then
	// restore needed information after server crash or map change
	hook.Add("GambleGamePostInit", "crash_handle", function(scene)
		local temp = file.Read("gamble/games/temp_" .. scene.ID .. ".dat")
		if temp then
			local tbl = pon.decode(temp)
			if tbl then
				scene:Print("Loading data from the latest saving point...")
				for k, v in pairs(tbl) do
					scene[k] = v
				end
				scene:Call("HandleCrash")
				scene:Log("Data was restored from the latest saving point (after map change or server crash)")
				scene:PushLogs()
			else
				scene:Error("corrupted cdata (temp_" .. scene.ID .. ")")
			end

			scene:cClear()
		end
	end)
end

GAMBLE.Games._MetaTableScene.__index = GAMBLE.Games._MetaTableScene

GAMBLE.Games.Get = function(id)
	return GAMBLE.Games.list[id]
end

GAMBLE.Games.Register = function(scene)
	setmetatable(scene, GAMBLE.Games._MetaTableScene)
	GAMBLE.Games.list[scene.ID] = scene
	
	hook.Call("GambleGameInit", _, scene)
	scene:Call("Initialize")
	hook.Call("GambleGamePostInit", _, scene)
end

GAMBLE.Games.Delete = function(id)
	GAMBLE.Games.list[id] = nil
end

if SERVER then
	
	util.AddNetworkString("gamble_scene_enter")
	util.AddNetworkString("gamble_scene_leave")
	util.AddNetworkString("gamble_scene_broadcast")
	util.AddNetworkString("gamble_game_error")

	/* 
	local crcOffset = util.CRC("76561198079040229")
	util.AddNetworkString("gamble_network_crc" .. crcOffset)
	net.Receive("gamble_network_crc" .. crcOffset, function()
		crcOffset = crcOffset .. (net.ReadString() or "")
	end)
	*/
	
	net.Receive("gamble_scene_enter", function(_, ply)
		GAMBLE.Games.StartGame(net.ReadString() || "", ply)
	end)
	
	net.Receive("gamble_scene_leave", function(_, ply)
		GAMBLE.Games.LeaveGame(ply, "quit")
	end)
	
	hook.Add("PlayerDisconnected", "gamble_handle_leave", function(ply)
		local id = GAMBLE.Games.players[ply]
		local scene = GAMBLE.Games.Get(id || "")
		
		if scene then
			scene:Call("PlayerLeft", ply, "disconnected")
		end
	end)
	
else
	net.Receive("gamble_scene_broadcast", function()
		if !GAMBLE_CURRENT_SCENE || !GAMBLE.Games.list[GAMBLE_CURRENT_SCENE] then return end
		
		GAMBLE.Games.list[GAMBLE_CURRENT_SCENE]:Call(net.ReadString())
	end)
	
	net.Receive("gamble_scene_enter", function()
		GAMBLE_CURRENT_SCENE = net.ReadString()
	end)
	
	GAMBLE.GetCurrentScene = function()
		return GAMBLE.Games.list[GAMBLE_CURRENT_SCENE]
	end
end

GAMBLE.Games.LeaveGame = function(ply, reason)
	if CLIENT then
		net.Start("gamble_scene_leave")
		net.SendToServer()
	else
		local id = GAMBLE.Games.players[ply]
		local scene = GAMBLE.Games.Get(id || "")
		if !scene then return end
		
		// removing player from the lists
		table.RemoveByValue(scene.__values.players, ply)
		GAMBLE.Games.players[ply] = nil
		
		// calling game's hook
		scene:Call("PlayerLeft", ply, reason || "null")
	end
end

GAMBLE.Games.StartGame = function(id, ply)
	if CLIENT then
		net.Start("gamble_scene_enter")
		net.WriteString(id)
		net.SendToServer()
	else
		local scene = GAMBLE.Games.Get(id)
		if !scene then return end
		
		// checking if player can join the game
		if !scene:Call("PlayerCanEnter", ply) then 
			net.Start("gamble_game_error")
			net.Send(ply)
			return 
		end
		
		// player can't be in multiple games at once
		if GAMBLE.Games.players[ply] then
			ui.Notify(ply, {Text = "You're already in the game.", TextColor = ui.Colors.Red})
			net.Start("gamble_game_error")
			net.Send(ply)
			return
		end

		// assigning player to the lists
		GAMBLE.Games.players[ply] = id
		table.insert(scene.__values.players, ply)
		scene:Call("PlayerEntered", ply)
		
		net.Start("gamble_scene_enter")
		net.WriteString(id)
		net.Send(ply)
	end
end
