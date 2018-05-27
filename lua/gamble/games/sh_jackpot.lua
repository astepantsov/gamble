local SCENE = {}

SCENE.ID = "jackpot"
SCENE.Name = "Jackpot"
SCENE.Material = "games/jackpot"
SCENE.Bets = {}
SCENE.GameLogs = {}
SCENE.History = {Bets = {}, Wins = {}}
SCENE.Delay = 100
SCENE.CrashSave = {"Bets", "Pause", "CanBet", "TotalValue", "History"}
 
function SCENE:Initialize()
	self:Debug("Initialized...")

	self:RegisterNetMessage("AddLog", "client")
	self:RegisterNetMessage("SetFloatValue", "client")
	self:RegisterNetMessage("PlaceBet", "server")
	self:RegisterNetMessage("SendHistory", "client")
	self:RegisterNetMessage("LogHistory", "client")

	if CLIENT then
		self.bet = 0
		self.total = 0
		self.start_time = -1
	else
		self.TotalValue = 0
		self.StartTime = -1
		self.Pause = true
		self.CanBet = true
	end
end

local lget, lformat = GAMBLE.LANG.GetString, GAMBLE.LANG.FormatString

if SERVER then
	GAMBLE.CFG.CreateField("jackpot_maxbet", "shared", 0, "Max Jackpot Bet (0 - to disable the limit)")
end

if CLIENT then

	function SCENE:SetupScene(frame, layout)
		local curr = GAMBLE.CONFIG.gamble_currency or "CR"
		local pnl = vgui.Create("DPanel", layout)
		pnl:SetSize(layout:GetWide(), layout:GetTall() - 20)
		
		local wg_w, wg_h = 400, 70
		local sw, sh = (pnl:GetWide() - wg_w - 40) / 2, pnl:GetTall() - 20
		local clrTranspBlue = Color(ui.Colors.Blue.r, ui.Colors.Blue.g, ui.Colors.Blue.b, 150)
		pnl.Paint = function(pnl, w, h)
			local x, y = sw + 20, 10
			local timeLeft = self.start_time - CurTime()
			
			ui.DrawRect(x, y, wg_w, wg_h, 255, 255, 255, 200)
			ui.DrawOutlinedRect(x, y, wg_w, wg_h, ui.Colors.Blue)

			local roundedTime = math.Round(timeLeft)
			local textTime = ""
			if self.start_time == -1 then
				textTime = lget("waiting_for_a_bet")
			elseif roundedTime < 0 then
				textTime = lget("wait")
			else
				textTime = lformat("game_starts_in", roundedTime)
			end

			draw.SimpleText(textTime, "DermaDefault", w / 2, y + 15, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ui.DrawRect(x + 10, y + 33, self.start_time == -1 and (wg_w - 20) or (((wg_w - 20) / self.Delay) * timeLeft), 25, 230, 230, 230, 200)
			ui.DrawOutlinedRect(x + 10, y + 33, wg_w - 20, 25, 190, 190, 190)
			
			y = wg_h + 20

			ui.DrawRect(x, y, wg_w, 65, 255, 255, 255, 200)
			ui.DrawOutlinedRect(x, y, wg_w, 65, ui.Colors.Blue)
			local _, texth = ui.DrawText(lget("total") .. ": " .. self.total .. " " .. curr, "gamble_os_24", w / 2, y + 5, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			ui.DrawRect(x + 30, y + 10 + texth, wg_w - 60, 1, 130, 130, 130, 150)
			draw.SimpleText(lget("your_bet") .. ": " .. self.bet .. " " .. curr .. (self.bet != 0 && " (" .. math.Round(self.bet / self.total * 100) .. "%)" || ""), "gamble_os_18", w / 2, y + 15 + texth, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		end

		local placebet = vgui.Create("mDesignButton", pnl)
		placebet:SetSize(wg_w, 25)
		placebet:SetPos(pnl:GetWide() / 2 - wg_w / 2, 165)
		placebet:SetText(lget("place_a_bet"))
		placebet.DoClick = function()
			if self.bet > 0 then return end

			local bf = vgui.Create("mDesignFrame")
			bf:SetSize(250, 90)
			bf:SetTitle(lget("bet"))
			bf:Center()
			bf:DoModal(true)
			bf:MakePopup()
			bf:SetBackgroundBlur(true)

			local entry = vgui.Create("mDesignTextEntrySimple", bf)
			entry:SetPos(10, 30)
			entry:SetSize(230, 25)
			entry:SetNumeric(true)
			entry:SetValue(0)

			local bet = vgui.Create("mDesignButton", bf)
			bet:SetPos(10, 60)
			bet:SetSize(230, 25)
			bet:SetText(lget("place"))
			bet.DoClick = function()
				local value = tonumber(math.floor(entry:GetValue()) or 0)
				if value <= 0 then return end

				self:Network(_, "PlaceBet", value)
				bf:Remove()
			end
		end

		local chatpnl = vgui.Create("DPanel", pnl)
		chatpnl:SetPos(sw + 20, pnl:GetTall() - 210)
		chatpnl:SetSize(wg_w, 200)
		chatpnl.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, 24, 225, 225, 225, 150)
			ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.LightGreen)
			ui.DrawRect(0, 24, w, 1, ui.Colors.LightGreen)

			draw.SimpleText(lget("logs") .. ":", "gamble_os_18", 5, 12, Color(80, 80, 80), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		self.chat = vgui.Create("RichText", chatpnl)
		self.chat:SetPos(3, 27)
		self.chat:SetSize(wg_w - 6, 170)
		self.chat.clr = self.chat.InsertColorChange
		self.chat.txt = self.chat.AppendText
		self.chat:SetFontInternal("DermaDefault")

		local latestbets = vgui.Create("DPanel", pnl)
		latestbets:SetPos(11, 11)
		latestbets:SetSize(sw - 2, sh - 1)
		latestbets.Paint = function(self, w, h) 
			ui.DrawRect(0, 0, w, h, 255, 255, 255, 200)
			ui.DrawOutlinedRect(0, 0, w, h, clrTranspBlue)
			local _, th = ui.DrawText(lget("latest_bets"), "gamble_os_18", w / 2, 3, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			ui.DrawRect(1, th + 6, w - 2, 1, clrTranspBlue)
		end

		local winners = vgui.Create("DPanel", pnl)
		winners:SetPos(pnl:GetWide() - sw - 10, 10)
		winners:SetSize(sw, sh)
		winners.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, 255, 255, 255, 200)
			ui.DrawOutlinedRect(0, 0, w, h, clrTranspBlue)
			local _, th = ui.DrawText(lget("winners"), "gamble_os_18", w / 2, 3, Color(100, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			ui.DrawRect(1, th + 6, w - 2, 1, clrTranspBlue)
		end

		local function LoadLatestBets()
			for k, v in pairs(latestbets:GetChildren()) do
				if !IsValid(v) then continue end

				v:Remove()
			end

			local bh = (latestbets:GetTall() - 24) / 15
			local ypos = 24

			for k, v in ipairs(self.History.Bets) do
				local bet = vgui.Create("DButton", latestbets)
				bet:SetPos(0, ypos)
				bet:SetText("")
				bet:SetTooltip(lget("open_profile"))
				bet:SetSize(latestbets:GetWide(), bh)
				bet.Paint = function(self, w, h)
					if self.Hovered then
						ui.DrawRect(0, 0, w, h, 230, 230, 230, 100)
					end

					draw.SimpleText(v.nick .. ": " .. v.bet .. " " .. curr, "gamble_os_18",  bh - 2, h / 2, Color(100, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					if i == 15 then return end

					ui.DrawRect(1, h - 2, w - 2, 1, 230, 230, 230)
					ui.DrawRect(1, h - 1, w - 2, 1, 240, 240, 240)
				end
				bet.DoClick = function()
					gui.OpenURL("http://steamcommunity.com/profiles/" .. v.steamid .. "/")
				end

				local avatar = vgui.Create("AvatarImage", bet)
				avatar:SetPos(5, 5)
				avatar:SetSize(bh - 12, bh - 12)
				avatar:SetSteamID(v.steamid, 64)
				avatar.PaintOver = function(self, w, h)
					ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.Indigo)
				end

				ypos = ypos + bh
			end
		end

		local function LoadWinners()
			for k, v in pairs(winners:GetChildren()) do
				if !IsValid(v) then continue end

				v:Remove()
			end

			local bh = (winners:GetTall() - 24) / 8
			local ypos = 24

			for k, v in ipairs(self.History.Wins) do
				local bet = vgui.Create("DButton", winners)
				bet:SetPos(0, ypos)
				bet:SetText("")
				bet:SetTooltip(lget("open_profile"))
				bet:SetSize(winners:GetWide(), bh)
				bet.Paint = function(self, w, h)
					if self.Hovered then
						ui.DrawRect(0, 0, w, h, 230, 230, 230, 100)
					end

					draw.SimpleText(v.nick .. " " .. lget("won") .. " " .. v.won .. " " .. curr, "gamble_os_18", bh, h / 2, Color(100, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

					if i == 8 then return end

					ui.DrawRect(1, h - 2, w - 2, 1, 230, 230, 230)
					ui.DrawRect(1, h - 1, w - 2, 1, 240, 240, 240)
				end
				bet.DoClick = function()
					gui.OpenURL("http://steamcommunity.com/profiles/" .. v.steamid .. "/")
				end

				local avatar = vgui.Create("AvatarImage", bet)
				avatar:SetPos(5, 5)
				avatar:SetSize(bh - 12, bh - 12)
				avatar:SetSteamID(v.steamid, 64)
				avatar.PaintOver = function(self, w, h)
					if i == 1 then
						ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.Orange)
					else
						ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.Indigo)
					end
				end

				ypos = ypos + bh
			end
		end

		LoadLatestBets()
		LoadWinners()

		SCENE.LoadHistory = function()
			LoadLatestBets()
			LoadWinners()
		end
	end

	function SCENE:AddLog(time, ...)
		local chat = self.chat

		if !IsValid(chat) then return end

		if time && time != "nil" then
			local date = os.date("<%X>: ", time)
			chat:clr(226, 106, 106, 255)
			chat:txt(date)
		end

		chat:clr(120, 120, 120, 255)

		for k, v in ipairs({...}) do
			if IsColor(v) then
				chat:clr(v.r, v.g, v.b, v.a || 255)
			else
				chat:txt(v)
			end
		end

		chat:txt("\n")
	end

	function SCENE:Net_LogHistory()
		if !IsValid(self.chat) then return end
		self.chat:SetText("")
		for k, v in pairs(net.ReadTable()) do
			self:AddLog(v[1], unpack(v[2]))
		end 
	end

	function SCENE:Net_SetFloatValue()
		self[net.ReadString()] = net.ReadFloat()
	end

	function SCENE:Net_AddLog()
		local time = net.ReadFloat()

		self:AddLog(time != 0 && time || "nil", unpack(net.ReadTable()))
	end

	function SCENE:Net_SendHistory()
		self.History = net.ReadTable()
		self:LoadHistory()
	end
end

if SERVER then

	function SCENE:PlaceBet(ply, amount)
		amount = math.floor(amount)
		self.Bets[ply:SteamID64()] = {bet = amount, nick = ply:Nick()}
		self.TotalValue = self.TotalValue + amount

		self:Network(ply, "SetFloatValue", "bet", amount)
		self:UpdateTotalValue()

		self:Log(ply, " bet ", amount, " CR")
	end

	function SCENE:PlayerCanEnter(ply)
		return true
	end

	function SCENE:SendLog(ply, ...)
		if ply then
			self:Network(ply, "AddLog", 0, {...})
		else
			local time = os.time()

			table.insert(self.GameLogs, {[1] = time, [2] = {...}})

			for k, v in pairs(self:GetPlayers()) do
				self:Network(v, "AddLog", time, {...})
			end
		end
	end

	function SCENE:PlayerEntered(ply)
		self:Network(ply, "SetFloatValue", "bet", self.Bets[ply:SteamID64()] and self.Bets[ply:SteamID64()].bet || 0)
		self:Network(ply, "SetFloatValue", "total", self.TotalValue)
		self:Network(ply, "SetFloatValue", "start_time", self.StartTime)
		self:UpdateHistory(ply)
		self:Network(ply, "LogHistory", self.GameLogs)
	end

	function SCENE:UpdateTotalValue()
		for k, v in ipairs(self:GetPlayers()) do
			self:Network(v, "SetFloatValue", "total", self.TotalValue)
		end
	end

	function SCENE:UpdateStartTime()
		for k, v in ipairs(self:GetPlayers()) do
			self:Network(v, "SetFloatValue", "start_time", self.StartTime)
		end
	end

	function SCENE:Net_PlaceBet(_, ply)
		local bet = net.ReadFloat()
		local max_bet = GAMBLE.CFG.GetValue("jackpot_maxbet")

		if max_bet != 0 and bet > max_bet then
			self:SendLog(ply, ui.Colors.Red, "Max. Bet: " .. max_bet .. GAMBLE.CFG.GetValue("gamble_currency"))
			return
		elseif bet < 0 then
			self:SendLog(ply, ui.Colors.Red, "Nah. You can't exploit this system.")
			return
		elseif self.Bets[ply:SteamID64()] then
			self:SendLog(ply, ui.Colors.Red, lget("already_placed"))
			return
		elseif !self.CanBet then
			self:SendLog(ply, ui.Colors.Red, lget("unable"))
			return
		elseif !ply:Gamble_CanAfford(bet) then
			self:SendLog(ply, ui.Colors.Red, lget("cant_afford"))
			return
		end

		ply:Gamble_AddCredits(-bet)
		self:PlaceBet(ply, bet)

		table.insert(self.History.Bets, 1, {nick = ply:Nick(), bet = bet, steamid = ply:SteamID64()})
		if #self.History.Bets > 15 then self.History.Bets[16] = nil end
		self:UpdateHistory()

		self:cSave()

		self:SendLog(false, lformat("j_msg_placed", ply:Nick(), bet, GAMBLE.CFG.GetValue("gamble_currency")))
	end

	function SCENE:UpdateHistory(ply)
		for k, v in pairs(ply and {ply} or self:GetPlayers()) do
			self:Network(v, "SendHistory", self.History)
		end
	end

	function SCENE:HandleCrash()
		if self.Pause then
			self.StartTime = -1
		else
			self.StartTime = CurTime() + self.Delay
		end
	end

	function SCENE:Think()
		if self.Pause then
			if table.Count(self.Bets) > 1 then
				self.GameLogs = {}
				self:SendLog(false, lformat("j_start_in", self.Delay))
				self.StartTime = CurTime() + self.Delay
				self:UpdateStartTime()
				self.Pause = false
				self:Log("Starting new game...")
			end

			return
		end
		if self.StartTime <= CurTime() then
			self.CanBet = false

			self:cSave()

			local bets = self.Bets
			local total = self.TotalValue
			local temp = {}
			local pos = 0
			local nicks = {}

			for k, v in pairs(bets) do
				temp[k] = {pos, pos + v.bet}
				nicks[k] = v.nick
				pos = pos + v.bet + 1
			end

			local random = math.random(0, pos - 1)
			self:SendLog(false, lget("j_winning_ticket") .. ": " .. random)

			local winner, winner_nick, w1, w2
			for k, v2 in pairs(temp) do
				if random >= v2[1] && random <= v2[2] then
					winner, winner_nick, w1, w2 = k, nicks[k], v2[1], v2[2]
				end
			end

			table.insert(self.History.Wins, 1, {nick = (winner_nick or "null"), won = self.TotalValue, steamid = winner})
			if #self.History.Wins > 8 then self.History.Wins[9] = nil end

			self:SendLog(false, (winner_nick or "null") .. "[" .. w1 .. ", " .. w2 .. "]" .. " " .. lget("won") .. " " .. self.TotalValue .. " " .. GAMBLE.CFG.GetValue("gamble_currency") .. ".")
			self:Log(GAMBLE.FormatString("{1} [{2}]", winner_nick, winner), " won ", self.TotalValue, " CR ", GAMBLE.FormatString("([{1}, {2}], random: {3}])", w1, w2, random))

			GAMBLE.AddCreditsSteamID64(winner, self.TotalValue)
			GAMBLE.AddTotalWins(winner, self.TotalValue)
			self:cClear()

			for k, v in pairs(bets) do
				if k != winner then
					GAMBLE.AddTotalWins(k, -v.bet)
				end
			end

			self.StartTime = -1
			self.TotalValue = 0
			self.Bets = {}
			self.History.Bets = {}

			self.GameLogs = {}
			self:UpdateHistory()

			for k, v in ipairs(self:GetPlayers()) do
				self:Network(v, "SetFloatValue", "bet", 0)
				self:Network(v, "SetFloatValue", "total", 0)
				self:Network(v, "SetFloatValue", "start_time", -1)
			end

			self:Log("GAME OVER. Pause, waiting for the bets...\n\n")
			self:PushLogs()

			self.Pause = true
			self.CanBet = true
		end
	end
	hook.Add("Think", "gamble_jackpot", function() SCENE:Think() end)
end

GAMBLE.Games.Register(SCENE)