GAMBLE.CFG = GAMBLE.CFG or {List = {}, _loaded = false}

util.AddNetworkString("gamble_sync_config")

local cl, sv, sh = "client", "server", "shared"

GAMBLE.CFG.Load = function()
	local data = file.Read("gamble/config.dat", "DATA")
	if !data then GAMBLE.CFG._loaded = true; return end
	GAMBLE.CFG.List = pon.decode(data)
	GAMBLE.CFG._loaded = true
	GAMBLE.CFG.Network()
end 

GAMBLE.CFG.Save = function()
	file.Write("gamble/config.dat", pon.encode(GAMBLE.CFG.List))
end

GAMBLE.CFG.Network = function(ply, id)
	net.Start("gamble_sync_config")

	if id then
		net.WriteTable({[id] = GAMBLE.CFG.List[id].Value})
	else
		local temp = {}
		for k, v in pairs(GAMBLE.CFG.List) do
			if v.Realm == cl or v.Realm == sh then
				temp[k] = v.Value
			end
		end
		net.WriteTable(temp)
	end

	if ply then net.Send(ply)
	else net.Broadcast() end 
end

GAMBLE.CFG.CreateField = function(id, realm, default)
	if !GAMBLE.CFG._loaded then
		timer.Simple(0.1, function() GAMBLE.CFG.CreateField(id, realm, default) end)
		return
	end

	if GAMBLE.CFG.List[id] then return end

	local temp = {
		ID = id,
		Realm = realm,
		Default = default,
		Value = default
	}

	GAMBLE.CFG.List[id] = temp
	GAMBLE.CFG.Network(_, id)
	GAMBLE.CFG.Save()
end

GAMBLE.CFG.SetValue = function(id, value)
	GAMBLE.CFG.List[id].Value = value
	GAMBLE.CFG.Save()
end

GAMBLE.CFG.GetValue = function(id)
	return GAMBLE.CFG.List[id].Value or GAMBLE.CFG.List[id].Default
end

GAMBLE.CFG.Load()

if SERVER then
	timer.Simple(60, function()
		local tocheck = {darkrpmoney = (DarkRP or "invalid"), ps1 = (PS or "invalid"), ps2 = (Pointshop2 or "invalid"), ps2_premium = (Pointshop2 or "invalid"), payandplay = (DS or "invalid")}
		for k, v in pairs(tocheck) do
			if v == "invalid" and GAMBLE.CFG.List["exchange_" .. k] then
				GAMBLE.CFG.List["exchange_" .. k].Value = 0
				GAMBLE.CFG.Network(_, "exchange_" .. k)
				print("[GAMBLE] exchange_" .. k .. " => 0 (required script isn't installed on this server)")
			end
		end
	end)
end

GAMBLE.CFG.CreateField("npc_model", "shared", "models/breen.mdl")
GAMBLE.CFG.CreateField("npc_only", "shared", 0)
GAMBLE.CFG.CreateField("npc_name", "shared", "Casino Employee")
GAMBLE.CFG.CreateField("freegame", "shared", 0, "Unlimited Credits (1 - to enable)")