local TAB = {}

TAB.Title = "profile"
TAB.Material = "profile"

surface.CreateFont("gamble_os_18_bold", {font = "Open Sans", size = 18, weight = 1000})

local currencies = {
	["darkrpmoney"] = {"DarkRP Money", "$"},
	["ps1"] = {"Pointshop Points", " points"},
	["ps2"] = {"Pointshop 2 Points", " PS2 points"},
	["ps2_premium"] = {"Pointshop 2 Premium Points", " premium points"},
	["payandplay"] = {"Donation system money", " " .. (DS and DS.CONFIG.CurrencySymbol or "$")},
}

TAB.Function = function(frame, layout)
	local curr = GAMBLE.CONFIG.gamble_currency or "CR"
	net.Start("gamble_get_total_gain")
	net.SendToServer()

	local pnl = layout:Add("DPanel", layout)
	pnl:SetSize(layout:GetWide(), 96)
	local balance, totalgain = GAMBLE.LANG.GetString("balance"), GAMBLE.LANG.GetString("total_gain")
	pnl.Paint = function() 
		local ply = LocalPlayer()
		draw.SimpleText(ply:Nick() .. " (" .. ply:SteamID64() .. ")", "gamble_os_18_bold", 96, 5, Color(120, 120, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(balance .. ": " .. GAMBLE.Client.credits .. " " .. curr, "gamble_os_18", 96, 23, Color(120, 120, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		draw.SimpleText(totalgain .. ": " .. tostring(GAMBLE.Client.total_gain) .. " " .. curr, "gamble_os_18", 96, 41, Color(120, 120, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	end

	local avatar = vgui.Create("AvatarImage", pnl)
	avatar:SetSize(86, 86)
	avatar:SetPos(5, 5)
	avatar:SetPlayer(LocalPlayer(), 64)
	avatar.PaintOver = function(self, w, h)
		ui.DrawOutlinedRect(1, 1, w - 2, h - 2, color_white)
		ui.DrawOutlinedRect(0, 0, w, h, 180, 180, 180)
	end

	if GAMBLE.CONFIG.freegame == 1 then return end

	local width = (layout:GetWide() - 15) / 2
	layout:SetSpaceX(10)

	local strb, strs = GAMBLE.LANG.GetString("buy"), GAMBLE.LANG.GetString("sell")
	local buy = layout:Add("DPanel")
	buy:SetSize(width, 125)
	buy.Paint = function(self, w, h)
		draw.SimpleText(strb .. " " .. curr, "gamble_os_18", 13, 11.5, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		ui.DrawOutlinedRect(6, 1, w - 6, 23, color_white)
		ui.DrawOutlinedRect(5, 0, w - 5, 25 , 180, 180, 180)
	end

	local box = vgui.Create("DComboBox", buy)
	box:SetSize(width - 5, 25)
	box:SetPos(5, 30)
	box:SetValue(GAMBLE.LANG.GetString("select_a_currency"))
	for k, v in pairs(currencies) do
		if GAMBLE.CONFIG["exchange_" .. k] == 0 then continue end
		box:AddChoice(v[1] .. " (" .. tostring(GAMBLE.CONFIG["exchange_" .. k]) .. ":1)", k)
	end

	local amount = vgui.Create("DNumberWang", buy)
	amount:SetPos(5, 60)
	amount:SetSize(width - 5, 25)
	amount:SetValue(1)
	amount:SetMin(1)
	amount:SetMax(666666)

	local btn = vgui.Create("mDesignButton", buy)
	btn:SetPos(5, 90)
	btn:SetSize(width - 5, 25)
	btn:SetText(strb)
	local tosend, currency
	btn.Think = function(self)
		local selected, selected_data = box:GetSelected()
		amount:SetDisabled(selected == nil)
		amount:SetEditable(selected != nil)
		self:SetDisabled(selected == nil)

		if !selected or !selected_data then return end
		local value = amount:GetValue()
		if !value then return end
		value = math.Max(tonumber(value), 1)
		tosend = value
		currency = selected_data
		btn:SetText(strb .. " " .. value .. " " .. curr .. " (" .. GAMBLE.CONFIG["exchange_" .. selected_data] * value .. currencies[selected_data][2] .. ")")
	end
	btn.DoClick = function()
		if !tosend or !currency then return end

		net.Start("gamble_buy_credits")
		net.WriteString(currency)
		net.WriteFloat(tosend)
		net.SendToServer()

		amount:SetValue(1)
	end

	local sell = layout:Add("DPanel")
	sell:SetSize(width, 125)
	sell.Paint = function(self, w, h)
		draw.SimpleText(strs .. " " .. curr, "gamble_os_18", 13, 11.5, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		ui.DrawOutlinedRect(6, 1, w - 6, 23, color_white)
		ui.DrawOutlinedRect(5, 0, w - 5, 25 , 180, 180, 180)
	end

	local box = vgui.Create("DComboBox", sell)
	box:SetSize(width - 5, 25)
	box:SetPos(5, 30)
	box:SetValue(GAMBLE.LANG.GetString("select_a_currency"))
	for k, v in pairs(currencies) do
		if GAMBLE.CONFIG["exchange_" .. k] == 0 then continue end
		box:AddChoice(v[1] .. " (" .. tostring(GAMBLE.CONFIG["exchange_" .. k]) .. ":1)", k)
	end

	local amount = vgui.Create("DNumberWang", sell)
	amount:SetPos(5, 60)
	amount:SetSize(width - 5, 25)
	amount:SetValue(1)
	amount:SetMin(1)
	amount:SetMax(666666)

	local btn = vgui.Create("mDesignButton", sell)
	btn:SetPos(5, 90)
	btn:SetSize(width - 5, 25)
	btn:SetText(strs)
	local tosend, currency
	btn.Think = function(self)
		local selected, selected_data = box:GetSelected()
		amount:SetDisabled(selected == nil)
		amount:SetEditable(selected != nil)
		self:SetDisabled(selected == nil)

		if !selected or !selected_data then return end
		local value = amount:GetValue()
		if !value then return end
		value = math.Max(tonumber(value), 1)
		tosend = value
		currency = selected_data
		btn:SetText(strs .. " " .. value .. " " .. curr .. " (" .. GAMBLE.CONFIG["exchange_" .. selected_data] * value .. currencies[selected_data][2] .. ")")
	end
	btn.DoClick = function()
		if !tosend or !currency then return end

		net.Start("gamble_sell_credits")
		net.WriteString(currency)
		net.WriteFloat(tosend)
		net.SendToServer()

		amount:SetValue(1)
	end
end

GAMBLE._MenuTabs[1] = TAB