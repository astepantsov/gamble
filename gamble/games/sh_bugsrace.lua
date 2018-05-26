local SCENE = {}

SCENE.ID = "bugsrace"
SCENE.Name = "Bugs' Race"
SCENE.Material = "games/bugsrace"
SCENE.ChatHistory = {}
SCENE.Bets = {}
SCENE.CrashSave = {"Bets"}
SCENE.Delay = 80
SCENE.Multiplier = 3

local dop = {"st", "nd", "rd", "th"}
local lformat, lget = GAMBLE.LANG.FormatString, GAMBLE.LANG.GetString

function SCENE:Initialize()
	self:RegisterNetMessage("ChatMsgSend", "server")
	self:RegisterNetMessage("ChatMsg", "client")
	self:RegisterNetMessage("ChatHistory", "client")
	self:RegisterNetMessage("StartRace", "client")
	self:RegisterNetMessage("StartTime", "client")
	self:RegisterNetMessage("PlaceBet")

	self.StartTime = CurTime() + self.Delay
end

if CLIENT then
	surface.CreateFont("gamble_r_48", {font = "Roboto", size = 48, weight = 1000})

	function SCENE:SetupScene(frame, layout)
		local mFinish, mBug = GAMBLE.MAT.GetMaterial("games/bugsrace/finish"), GAMBLE.MAT.GetMaterial("games/bugsrace/bug1")
		local curr = GAMBLE.CONFIG.gamble_currency or "CR"
		local pnl = vgui.Create("DPanel", layout)
		pnl:SetSize(layout:GetWide(), layout:GetTall() - 20)
		pnl.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, 162, 222, 208, 100)
		end

		local rpnl = vgui.Create("DPanel", pnl)
		rpnl:SetPos(5, 5)
		rpnl:SetSize(pnl:GetWide() - 10, pnl:GetTall() - 316)
		rpnl.Race = {}
		rpnl.StartTime = {}
		rpnl.StartRace = function(self, tbl)
			self.Race.bugs = tbl
		end
		self.RacePanel = rpnl
		local height = (rpnl:GetTall() - 10) / 4
		local startTime = CurTime() + 10
		rpnl.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, 245, 245, 245)
			ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.Green)
			ui.DrawOutlinedRect(1, 1, w - 2, h - 2, ui.Colors.Green)

			local startTime = SCENE.StartTime - CurTime()
			local text = ""
			if self.Race.bugs and self.Race.bugs[1] then text = "" elseif startTime > 1 then text = lformat("game_starts_in", math.Round(startTime)) else text = lget("wait") end

			draw.SimpleText(text, "gamble_os_24", w / 2, 10, Color(60, 60, 60), TEXT_ALIGN_CENTER)

			for i = 1, 4 do
				local pos = (height + 2) * i - height
				if i < 4 then
					ui.DrawRect(2, pos + height, w - 4, 2, 180, 180, 180, 100)
				end
				local delta = 0 
				local bugPos = 0
				local bug = rpnl.Race.bugs and rpnl.Race.bugs[i]
				if bug then
					delta = math.cos(CurTime() * bug.speed)
					bugPos = (w - 80) * (1 - (bug.finishTime - CurTime()) / bug.time)
				end
				ui.DrawRect(2 + height, pos, 2, height, 180, 180, 180, 100)
				ui.DrawTexturedRectRotated((height - 80) / 2 + 40 + bugPos, pos + (height - 54) / 2 + 27, 80, 54, mBug, 5 * delta, 255, 255, 255, bug and 255 or 100)
				draw.SimpleText(i, "gamble_r_48", 2 + height / 2, pos + height / 2, Color(60, 60, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				ui.DrawTexturedRect(w - 2 - height, pos, height, height, mFinish, 255, 255, 255, 100)
			end
		end

		local chatpnl = vgui.Create("DPanel", pnl)
		chatpnl:SetSize(300, 300)
		chatpnl:SetPos(5, pnl:GetTall() - 305)
		chatpnl.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, 235, 235, 235)
			ui.DrawRect(0, 0, w, 25, 250, 250, 250)
			ui.DrawRect(0, 25, w, 1, 225, 225, 225)
			draw.SimpleText(lget("chat"), "gamble_os_18", 5, 13, Color(110, 110, 110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.Blue)
		end

		self.chat = vgui.Create("RichText", chatpnl)
		self.chat:SetPos(3, 29)
		self.chat:SetSize(chatpnl:GetWide() - 6, chatpnl:GetTall() - 88)

		local entry = vgui.Create("mDesignTextEntrySimple", chatpnl)
		entry:SetSize(chatpnl:GetWide() - 6, 25)
		entry:SetPos(3, chatpnl:GetTall() - 56)
		entry:SetGhostText(lget("enter_msg"))

		local function sendfunc()
			local v = entry:GetValue()
			entry:SetValue("")
			if !v or v == "" then return end
			self:Network(_, "ChatMsgSend", v)
		end

		entry.OnEnter = function(self) sendfunc(); timer.Simple(0.01, function() if IsValid(self) then self:SetValue("") end end) end

		local send = vgui.Create("mDesignButton", chatpnl)
		send:SetSize(chatpnl:GetWide() - 6, 25)
		send:SetPos(3, chatpnl:GetTall() - 28)
		send:SetText(lget("send"))
		send.DoClick = sendfunc

		local betpnl = vgui.Create("DPanel", pnl)
		betpnl:SetSize(pnl:GetWide() - 316, 300)
		betpnl:SetPos(310, pnl:GetTall() - 305)
		betpnl.Paint = function(pnl, w, h)
			ui.DrawRect(0, 0, w, h, 235, 235, 235)
			ui.DrawRect(0, 0, w, 25, 250, 250, 250)
			ui.DrawRect(0, 25, w, 1, 225, 225, 225)
			draw.SimpleText((self.Bet and self.Bet.amount) and (lget("your_bet") .. ": " .. self.Bet.amount .. " " .. curr) or lget("who_will_win"), "gamble_os_18", w / 2, 13, Color(110, 110, 110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ui.DrawOutlinedRect(0, 0, w, h, ui.Colors.Green)
		end

		local width = (betpnl:GetWide() - 1) / 4
		for i = 1, 4 do
			local btn = vgui.Create("DButton", betpnl)
			btn:SetSize(width, betpnl:GetTall() - 28)
			btn:SetPos(1 + width * i - width, 27)
			btn:SetText("")
			btn:SetTooltip(lformat("payout", self.Multiplier))
			btn.Paint = function(self, w, h)
				ui.DrawRect(0, 0, w, h, self.Hovered and Color(240, 240, 240) or Color(245, 245, 245))
				if i < 4 then
					ui.DrawRect(w - 1, 0, 1, h, 225, 225, 225)
				end
				ui.DrawTexturedRectRotated(w / 2, h / 2, 80, 54, mBug, 90, 255, 255, 255, 100)
				draw.SimpleText(i, "gamble_r_48", w / 2, h / 2, Color(60, 60, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
			btn.DoClick = function()
				if self.Bet and self.Bet.bet then return end
				local bf = vgui.Create("mDesignFrame")
				bf:SetSize(250, 90)
				bf:SetTitle(lformat("bug_bet", i .. dop[i]))
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

					self:Network(_, "PlaceBet", i, value)
					bf:Remove()
				end
			end
		end
	end

	function SCENE:Net_StartRace()
		if !IsValid(self.RacePanel) then return end
		self.RacePanel:StartRace(net.ReadTable())
	end

	function SCENE:Net_StartTime()
		self.StartTime = net.ReadFloat()
	end

	function SCENE:Net_ChatHistory()
		self.chat:SetText("")
		for k, v in SortedPairs(net.ReadTable(), true) do
			local clr = v[3] and ui.Colors.Red or ui.Colors.Blue
			self.chat:InsertColorChange(clr.r, clr.g, clr.b, 255)
			self.chat:AppendText((v[3] and "Bugs' Race" or v[1]) .. ": ")
			self.chat:InsertColorChange(120, 120, 120, 255)
			self.chat:AppendText(v[2] .. "\n")
		end
	end

	function SCENE:Net_ChatMsg()
		local nick, msg, sys = net.ReadString(), net.ReadString(), net.ReadBool()
		local clr = sys and ui.Colors.Red or ui.Colors.Blue
		if !IsValid(self.chat) then return end
		self.chat:InsertColorChange(clr.r, clr.g, clr.b, 255)
		self.chat:AppendText((sys and "Bugs' Race" or nick) .. ": ")
		self.chat:InsertColorChange(120, 120, 120, 255)
		self.chat:AppendText(msg .. "\n")

		self:Print((sys and "Bugs' Race" or nick) .. " said " .. msg)
	end

	function SCENE:Net_PlaceBet()
		self.Bet = net.ReadTable()
	end

end

if SERVER then

	function SCENE:PlayerEntered(ply)
		self:Network(ply, "ChatHistory", self.ChatHistory)
		self:Network(ply, "StartRace", self.Race or {})
		self:Network(ply, "StartTime", self.StartTime)
		self:Network(ply, "PlaceBet", self.Bets[ply:SteamID64()] or {})
	end

	function SCENE:Net_PlaceBet(_, ply)
		local sid64 = ply:SteamID64()
		local bet, amount = net.ReadFloat(), net.ReadFloat()
		amount = math.floor(amount)

		if self.Started or amount <= 0 then return end
		if self.Bets[sid64] then
			self:Network(ply, "ChatMsg", "", lget("already_placed"), true)
			return
		elseif !ply:Gamble_CanAfford(amount) then
			self:Network(ply, "ChatMsg", "", lget("cant_afford"), true)
			return
		elseif !dop[bet] then
			return
		end
		local curr = GAMBLE.CFG.GetValue("gamble_currency")
		ply:Gamble_AddCredits(-amount)
		self.Bets[sid64] = {bet = bet, amount = amount, nick = ply:Nick()}
		self:cSave()
		self:SendChatMsg(lformat("bug_msg_placed", ply:Nick(), amount, curr, bet .. dop[bet]))
		self:Network(ply, "PlaceBet", self.Bets[sid64])
		self:Log(ply, " bet ", amount, " CR on the " .. bet .. dop[bet] .. " bug.")
	end

	function SCENE:Net_ChatMsgSend(_, ply)
		if ply.gambleRoulette_nextChatMsg and ply.gambleRoulette_nextChatMsg >= CurTime() then return end

		local msg = net.ReadString()
		if !msg or msg == "" then return end
		msg = msg:Left(120)
		msg = msg:Replace("\n", "")

		self:Log(ply, " said: ", msg)

		for k, v in pairs(self:GetPlayers()) do
			self:Network(v, "ChatMsg", ply:Nick(), msg)
		end

		table.insert(self.ChatHistory, 1, {ply:Nick(), msg})
		self.ChatHistory[31] = nil

		ply.gambleRoulette_nextChatMsg = CurTime() + 1
	end

	function SCENE:SendChatMsg(text)
		for k, v in pairs(self:GetPlayers()) do
			self:Network(v, "ChatMsg", "", text, true)
		end

		table.insert(self.ChatHistory, 1, {"", text, true})
	end

	function SCENE:StartRace()
		self.Started = true
		local winTime = math.random(8, 15)
		local bugWinner = math.random(1, 4)
		local bugSpeed = math.random(6, 12)
		local bugs = {}

		for i = 1, 4 do
			if bugWinner == i then
				bugs[i] = {time = winTime, speed = bugSpeed, finishTime = CurTime() + winTime}
				self.FinishTime = bugs[i].finishTime
				self.Winner = bugWinner
			else
				local bTime = winTime + math.random(1, 4)
				local speed = bugSpeed * (winTime / bTime)
				bugs[i] = {time = bTime, speed = speed, finishTime = CurTime() + bTime}
			end
		end  
		self.Race = bugs
		for k, v in ipairs(self:GetPlayers()) do
			self:Network(v, "StartRace", self.Race)
		end
	end

	function SCENE:Think()
		local curr = GAMBLE.CFG.GetValue("gamble_currency")
		if self.StartTime <= CurTime() and !self.Started then
			if table.Count(self.Bets) > 0 then
				self:StartRace()
			else
				self.StartTime = CurTime() + self.Delay
				for k, v in ipairs(self:GetPlayers()) do
					self:Network(v, "StartTime", self.StartTime)
				end
			end
		elseif self.Started then
			if self.FinishTime <= CurTime() then
				local winner = self.Winner
				self:SendChatMsg(lformat("bug_won", winner .. dop[winner]))
				self:Log(winner .. dop[winner] .. " bug won the race!")

				for k, v in pairs(self.Bets) do
					if v.bet == winner then
						local prize = v.amount * self.Multiplier
						GAMBLE.AddCreditsSteamID64(k, prize)
						GAMBLE.AddTotalWins(k, v.amount)
						self:SendChatMsg(v.nick .. " " .. lget("won") .. " " .. prize .. " " .. curr .. ".")
						self:Log(v.nick .. "[" .. k .. "] won " .. prize .. " " .. curr .. ".")
					else
						GAMBLE.AddTotalWins(k, -v.amount)
					end
				end

				self:cClear()
				self.Started = false
				self.Race = nil
				self.Bets = {}
				self.StartTime = CurTime() + self.Delay
				self:PushLogs()

				for k, v in ipairs(self:GetPlayers()) do
					self:Network(v, "StartRace", {})
					self:Network(v, "StartTime", self.StartTime)
					self:Network(v, "PlaceBet", {})
				end
			end
		end
	end
	hook.Add("Think", "gamble_bugsrace", function() SCENE:Think() end)
end


GAMBLE.Games.Register(SCENE)