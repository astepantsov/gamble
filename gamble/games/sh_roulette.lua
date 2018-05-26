local SCENE = {}

SCENE.ID = "roulette"
SCENE.Name = "Roulette"
SCENE.Material = "games/roulette1"
SCENE.Match = {evens = {}, odds = {}, dozen1 = {}, dozen2 = {}, dozen3 = {}, row1 = {}, row2 = {}, row3 = {}, half1 = {}, black = {}, red = {}, half2 = {}, ["00"] = {"00"}, ["0"] = {"0"}}
SCENE.Multiplier = {dozen1 = 3, dozen2 = 3, dozen3 = 3, black = 2, red = 2, evens = 2, odds = 2, half1 = 2, half2 = 2, row1 = 3, row2 = 3, row3 = 3, ["0"] = 36, ["00"] = 36}
SCENE.List = {"0", "00"}
SCENE.Angles = {["00"] = {2, 8}}
SCENE.ChatHistory = {}
SCENE.Bets = {}
SCENE.CrashSave = {"Bets"}
SCENE.Delay = 80

local prettyNames = {}
local order = {"00", 27, 10, 25, 29, 12, 8, 19, 31, 18, 6, 21, 33, 16, 4, 23, 35, 14, 2, 0, 28, 9, 26, 30, 11, 7, 20, 32, 17, 5, 22, 34, 15, 3, 24, 36, 13, 1}
local lformat, lget = GAMBLE.LANG.FormatString, GAMBLE.LANG.GetString

for k, v in ipairs(order) do
	v = tostring(v)
	local start = 9.5 * k - 9.5
	SCENE.Angles[v] = {start + 1, start + 5}
end

local reds = {1, 3, 5, 7, 9, 12, 14, 16, 18, 21, 19, 23, 25, 27, 30, 32, 34, 36}
for i = 1, 36 do
	local str = tostring(i)

	SCENE.Match[str] = {str}
	table.insert(i % 2 == 0 and SCENE.Match.evens or SCENE.Match.odds, str)
	table.insert(table.HasValue(reds, i) and SCENE.Match.red or SCENE.Match.black, str)

	if i <= 12 then table.insert(SCENE.Match.dozen1, str)
	elseif i <= 24 then table.insert(SCENE.Match.dozen2, str)
	else table.insert(SCENE.Match.dozen3, str) end

	if i <= 18 then table.insert(SCENE.Match.half1, str)
	else table.insert(SCENE.Match.half2, str) end

	local r = i % 3
	if r == 1 then table.insert(SCENE.Match.row3, str)
	elseif r == 2 then table.insert(SCENE.Match.row2, str)
	else table.insert(SCENE.Match.row1, str) end

	SCENE.Multiplier[str] = 36
	table.insert(SCENE.List, str)
end

if CLIENT then
	surface.CreateFont("gamble_os_36", {font = "Open Sans", size = 36})
end

/* SHARED */

function SCENE:IsWinningBet(bet, res)
	return table.HasValue(SCENE.Match[bet], res)
end
 
function SCENE:Initialize()
 	self:RegisterNetMessage("ChatMsgSend", "server")
 	self:RegisterNetMessage("ChatMsg", "client")
 	self:RegisterNetMessage("ChatHistory", "client")
 	self:RegisterNetMessage("PlaceBet")
 	self:RegisterNetMessage("SpinTheWheel", "client")
 	self:RegisterNetMessage("StartTime", "client")

 	self.StartTime = CurTime() + self.Delay
end    

/* CLIENT */ 
local green, black, red = Color(76, 175, 80), Color(0, 0, 0), Color(244, 67, 54)
local table_btns = {
	{x = 0, y = 40, w = 40, h = 60, color = green, text = "00", cmd = "00"},
	{x = 0, y = 100, w = 40, h = 60, color = green, text = "0", cmd = "0"},

	{x = 40, y = 0, w = 160, h = 40, text = "Dozen #1", cmd = "dozen1"},
	{x = 200, y = 0, w = 160, h = 40, text = "Dozen #2", cmd = "dozen2"},
	{x = 360, y = 0, w = 160, h = 40, text = "Dozen #3", cmd = "dozen3"},

	{x = 520, y = 40, w = 80, h = 40, text = "Row #1", cmd = "row1"},
	{x = 520, y = 80, w = 80, h = 40, text = "Row #2", cmd = "row2"},
	{x = 520, y = 120, w = 80, h = 40, text = "Row #3", cmd = "row3"},

	{x = 40, y = 160, w = 240, h = 40, text = "Half #1", cmd = "half1"},
	{x = 40, y = 200, w = 120, h = 40, color = black, text = "Black", cmd = "black"},
	{x = 160, y = 200, w = 120, h = 40, color = red, text = "Red", cmd = "red"},

	{x = 280, y = 160, w = 240, h = 40, text = "Half #2", cmd = "half2"},
	{x = 280, y = 200, w = 120, h = 40, text = "Evens", cmd = "evens"},
	{x = 400, y = 200, w = 120, h = 40, text = "Odds", cmd = "odds"},
}

local xpos, col = 40, 0
for i = 1, 36 do
	col = col + 1
	if col > 3 then col = 1; xpos = xpos + 40 end
	isred = table.HasValue(reds, i)
	table.insert(table_btns, {x = xpos, y = (160 - col * 40), w = 40, h = 40, text = i, cmd = tostring(i), color = (isred and red or black)})
end

for k, v in ipairs(table_btns) do
	prettyNames[v.cmd] = v.text
end

local wheelAngle, ballAngle
function SCENE:SetupScene(frame, layout)
	local curr = GAMBLE.CONFIG.gamble_currency or "CR"
	local mWheel, mBall = GAMBLE.MAT.GetMaterial("games/roulette/wheel1"), GAMBLE.MAT.GetMaterial("games/roulette/ball")

	local pnl = vgui.Create("DPanel", layout)
	pnl:SetSize(layout:GetWide(), layout:GetTall() - 20)
	pnl.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 60, 60, 60)
	end

	local whpnl = vgui.Create("DPanel", pnl)
	whpnl:SetPos(5, 5)
	whpnl:SetSize(layout:GetWide() - 350, 427)
	whpnl.WheelAngle = 0
	whpnl.BallAngle = 0
	whpnl.curWheelAngle = 0
	whpnl.curBallAngle = 0
	whpnl.PickNumber = function(self, str)
		local angles = SCENE.Angles[str]
		local angle = -math.random(angles[1], angles[2])
		local wheelrotate = math.random(300, 500)
		self.WheelAngle = self.WheelAngle + wheelrotate
		local newangle = self.BallAngle + math.abs(self.WheelAngle - self.BallAngle) + angle - 360
		self.BallAngle = self.WheelAngle + angle

		wheelAngle = self.WheelAngle
		ballAngle = self.BallAngle
	end
	whpnl.Paint = function(pnl, w, h)
		pnl.curWheelAngle = Lerp(FrameTime() * 1, pnl.curWheelAngle, pnl.WheelAngle)
		pnl.curBallAngle = Lerp(FrameTime() * 3, pnl.curBallAngle, pnl.BallAngle)

		ui.DrawTexturedRectRotated(w / 2, 10 + 192, 384, 384, mWheel, pnl.curWheelAngle)
		ui.DrawTexturedRectRotated(w / 2, 10 + 192, 384, 384, mBall, pnl.curBallAngle)

		local time = ""
		local timeLeft = self.StartTime - CurTime()
		if self.StartTime <= 0 or timeLeft <= 0 then time = "00:00"
		else time = string.ToMinutesSeconds(timeLeft) end

		draw.SimpleText(time, "gamble_os_36", 5, 5, Color(160, 160, 160))

		if self.Bet then
			draw.SimpleText(lget("your_bet") .. ": " .. self.Bet.amount .. " " .. curr .. " (" .. prettyNames[self.Bet.bet] .. ")", "gamble_os_24", w / 2, h - 5, Color(160, 160, 160), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	end
	if wheelAngle and ballAngle then
		whpnl.BallAngle = ballAngle
		whpnl.WheelAngle = wheelAngle
		whpnl.curWheelAngle = wheelAngle
		whpnl.curBallAngle = ballAngle
	end
	self.Wheel = whpnl

	local table_panel = vgui.Create("DPanel", pnl)
	table_panel:SetSize(600, 240)
	table_panel:SetPos((pnl:GetWide() - 350 - 600) / 2, pnl:GetTall() - table_panel:GetTall() - 5)
	table_panel.Paint = function() end

	local chatpnl = vgui.Create("DPanel", pnl)
	chatpnl:SetSize(350, pnl:GetTall() - 10)
	chatpnl:SetPos(pnl:GetWide() - 355, 5)
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
	entry:SetSize(344, 25)
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
	send:SetSize(344, 25)
	send:SetPos(3, chatpnl:GetTall() - 28)
	send:SetText(lget("send"))
	send.DoClick = sendfunc

	local hovered
	for k, v in ipairs(table_btns) do
		local btn = vgui.Create("DButton", table_panel)
		btn:SetPos(v.x, v.y)
		btn:SetSize(v.w, v.h)
		btn:SetText("")
		btn:SetTooltip(v.text .. "\n\n" .. lget("click_to_place") .. "\n" .. lformat("payout", self.Multiplier[v.cmd]))
		btn.Paint = function(self, w, h)
			if self.Hovered then hovered = v.cmd
			elseif hovered == v.cmd then hovered = nil end
			local glow = hovered and SCENE:IsWinningBet(hovered, v.cmd) or self.Hovered
			ui.DrawRect(0, 0, w, h, v.color or Color(160, 160, 160))
			if glow then ui.DrawRect(0, 0, w, h, 255, 255, 255, 50) end
			draw.SimpleText(v.text, "gamble_os_24", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ui.DrawOutlinedRect(1, 1, w - 2, h - 2, glow and ui.Colors.Blue or color_white)
			ui.DrawOutlinedRect(0, 0, w, h, color_white)
		end
		btn.DoClick = function()
			local bf = vgui.Create("mDesignFrame")
			bf:SetSize(250, 90)
			bf:SetTitle(lget("bet_on") .. " " .. v.text .. " (x" .. self.Multiplier[v.cmd].. ")")
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

				self:Network(_, "PlaceBet", v.cmd, value)
				bf:Remove()
			end
		end
	end
end

function SCENE:Net_SpinTheWheel()
	if !IsValid(self.Wheel) then return end

	self.Wheel:PickNumber(net.ReadString())
end

function SCENE:Net_StartTime()
	self.StartTime = net.ReadFloat()
end

function SCENE:Net_ChatHistory()
	if !IsValid(self.chat) then return end
	self.chat:SetText("")
	for k, v in SortedPairs(net.ReadTable(), true) do
		local clr = v[3] and ui.Colors.Red or ui.Colors.Blue
		self.chat:InsertColorChange(clr.r, clr.g, clr.b, 255)
		self.chat:AppendText((v[3] and "Roulette" or v[1]) .. ": ")
		self.chat:InsertColorChange(120, 120, 120, 255)
		self.chat:AppendText(v[2] .. "\n")
	end
end

function SCENE:Net_PlaceBet()
	local tbl = net.ReadTable()
	if !tbl.bet then self.Bet = nil; return end
	self.Bet = tbl
end

function SCENE:Net_ChatMsg()
	if !IsValid(self.chat) then return end
	local nick, msg, sys = net.ReadString(), net.ReadString(), net.ReadBool()
	local clr = sys and ui.Colors.Red or ui.Colors.Blue
	self.chat:InsertColorChange(clr.r, clr.g, clr.b, 255)
	self.chat:AppendText((sys and "Roulette" or nick) .. ": ")
	self.chat:InsertColorChange(120, 120, 120, 255)
	self.chat:AppendText(msg .. "\n")

	self:Print((sys and "Roulette" or nick) .. " said " .. msg)
end

if CLIENT then GAMBLE.Games.Register(SCENE); return end

function SCENE:PlayerEntered(ply)
	self:Network(ply, "ChatHistory", self.ChatHistory)

	local sid64 = ply:SteamID64()
	self:Network(ply, "StartTime", self.StartTime)
	if self.Bets[sid64] then
		self:Network(ply, "PlaceBet", self.Bets[sid64])
	else
		self:Network(ply, "PlaceBet", {})
	end
end

function SCENE:Net_PlaceBet(_, ply)
	local bet, amount = net.ReadString(), net.ReadFloat()
	amount = math.floor(amount)
	if amount <= 0 then return end
	if !self.Match[bet] then return end
	if self.Pause then return end

	local sid64 = ply:SteamID64()
	if self.Bets[sid64] then
		self:Network(ply, "ChatMsg", "", lget("already_placed"), true)
		return
	elseif !ply:Gamble_CanAfford(amount) then
		self:Network(ply, "ChatMsg", "", lget("cant_afford"), true)
		return
	end

	ply:Gamble_AddCredits(-amount)
	self.Bets[sid64] = {bet = bet, amount = amount, nick = ply:Nick()}
	self:cSave()
	self:SendChatMsg(lformat("r_msg_placed", ply:Nick(), amount, GAMBLE.CFG.GetValue("gamble_currency"), prettyNames[bet]))
	self:Network(ply, "PlaceBet", self.Bets[sid64])

	self:Log(ply, " bet " .. amount .. " on " .. bet)
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

function SCENE:Think()
	if self.StartTime <= CurTime() and !self.Pause then
		if table.Count(self.Bets) == 0 then
			self.StartTime = CurTime() + self.Delay
			for k, v in ipairs(self:GetPlayers()) do
				self:Network(v, "StartTime", self.StartTime)
			end
			return
		end

		self.Pause = true

		local randomNum = self.List[math.random(1, #self.List)]
		self:Log("The winning number is " .. randomNum)

		for k, v in ipairs(self:GetPlayers()) do
			self:Network(v, "SpinTheWheel", randomNum)
		end

		timer.Simple(1.5, function()
			self:SendChatMsg(lget("winning_number") .. " " .. randomNum)

			for k, v in pairs(self.Bets) do
				if self:IsWinningBet(v.bet, randomNum) then
					local prize = v.amount * self.Multiplier[v.bet]
					GAMBLE.AddCreditsSteamID64(k, prize)
					GAMBLE.AddTotalWins(k, prize - v.amount)
					self:SendChatMsg(v.nick .. " " .. lget("won") .. " " .. prize .. " " .. GAMBLE.CFG.GetValue("gamble_currency"))
					self:Log(GAMBLE.FormatString("{1} [{2}] won " .. prize .. " CR", v.nick, k))
				else
					GAMBLE.AddTotalWins(k, -v.amount)
				end
			end

			self:cClear()
			self.Bets = {}
			self.StartTime = CurTime() + self.Delay
			self:PushLogs()

			for k, v in ipairs(self:GetPlayers()) do
				self:Network(v, "StartTime", self.StartTime)
				self:Network(v, "PlaceBet", {})
			end

			self.Pause = false
		end)
	end
end
hook.Add("Think", "gamble_roulette", function() SCENE:Think() end)


GAMBLE.Games.Register(SCENE)