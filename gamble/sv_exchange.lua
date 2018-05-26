GAMBLE.CFG.CreateField("exchange_ps1", "shared", 1)
GAMBLE.CFG.CreateField("exchange_ps2", "shared", 1)
GAMBLE.CFG.CreateField("exchange_ps2_premium", "shared", 1)
GAMBLE.CFG.CreateField("exchange_darkrpmoney", "shared", 1) 
GAMBLE.CFG.CreateField("exchange_payandplay", "shared", 1) 

util.AddNetworkString("gamble_buy_credits")
util.AddNetworkString("gamble_sell_credits") 

local funcs = {
	["ps1"] = {Get = function(ply) return ply:PS_GetPoints() end, Add = function(ply, amount) ply:PS_GivePoints(amount) end}, 
	["ps2"] = {Get = function(ply) return ply.PS2_Wallet and ply.PS2_Wallet.points or 0 end, Add = function(ply, amount) ply:PS2_AddStandardPoints(amount) end}, 
	["ps2_premium"] = {Get = function(ply) return ply.PS2_Wallet and ply.PS2_Wallet.premiumPoints or 0 end, Add = function(ply, amount) ply:PS2_AddPremiumPoints(amount) end}, 
	["darkrpmoney"] = {Get = function(ply) return ply:getDarkRPVar("money") or 0 end, Add = function(ply, amount) ply:addMoney(amount) end}, 
	["payandplay"] = {Get = function(ply) return ply:DS_GetMoney() or 0 end, Add = function(ply, amount) ply:DS_SetMoney(ply:DS_GetMoney() + amount) end},
}

GAMBLE.EXCHANGE = GAMBLE.EXCHANGE or {}
 
GAMBLE.EXCHANGE.Enabled = function(type)
	if GAMBLE.CFG.GetValue("freegame") == 1 then return false end
	if !funcs[type] or GAMBLE.CFG.GetValue("exchange_" .. type) == 0 then
		return false
	end

	return true
end  

GAMBLE.EXCHANGE.ToCredits = function(ply, currency, amount)
	if !GAMBLE.EXCHANGE.Enabled(currency) then return end

	local rate = GAMBLE.CFG.GetValue("exchange_" .. currency) 
	local price = amount * rate
	local M = funcs[currency]

	if amount < 1 then
		ui.Notify(ply, {Text = "You have entered incorrect amount.", TextColor = ui.Colors.Red})
		return
	elseif M.Get(ply) < price then
		ui.Notify(ply, {Text = "You can't afford this.", TextColor = ui.Colors.Red})
		return
	end

	M.Add(ply, -price)
	ply:Gamble_AddCredits(amount)
end 

GAMBLE.EXCHANGE.ToAnotherCurrency = function(ply, currency, credits)
	if !GAMBLE.EXCHANGE.Enabled(currency) then return end

	local rate = GAMBLE.CFG.GetValue("exchange_" .. currency) 
	local togive = credits * rate
	local M = funcs[currency]

	if credits < 1 then
		ui.Notify(ply, {Text = "You have entered incorrect amount.", TextColor = ui.Colors.Red})
		return
	elseif !ply:Gamble_CanAfford(credits) then
		ui.Notify(ply, {Text = "You can't afford this.", TextColor = ui.Colors.Red})
		return
	end

	M.Add(ply, togive)
	ply:Gamble_AddCredits(-credits)
end

net.Receive("gamble_buy_credits", function(_, ply)
	local currency, amount = net.ReadString(), net.ReadFloat()

	GAMBLE.EXCHANGE.ToCredits(ply, currency, amount)
end)

net.Receive("gamble_sell_credits", function(_, ply)
	local currency, amount = net.ReadString(), net.ReadFloat()

	GAMBLE.EXCHANGE.ToAnotherCurrency(ply, currency, amount)
end)