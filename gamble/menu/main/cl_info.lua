local TAB = {}

TAB.Title = "information"
TAB.Material = "info"
TAB.About = {
	{"GAMBLE", {["Script Page"] = "https://scriptfodder.com/scripts/view/2250/", ["Support"] = "https://scriptfodder.com/dashboard/support/tickets/create/2250/"}},
	{"Authors", {["krekeris"] = "http://steamcommunity.com/profiles/76561198079040229/", ["Pyroman"] = "http://steamcommunity.com/profiles/76561197997600622/"}}
}
TAB.Credits = {
	{"pON: Penguin's Object Notation (by thelastpenguin™)", {
		["GitHub"] = "https://github.com/thelastpenguin",
		["Facepunch"] = "https://facepunch.com/showthread.php?t=1367349"
	}},
	{"Flat Icons (from flaticon.com, by Freepik, Pixabay and Google)", {
		["Profile Icon"] = "http://www.flaticon.com/free-icon/user-avatar_16363",
		["Games Icon"] = "http://www.flaticon.com/free-icon/poker-full_107589",
		["Admin Icon"] = "http://www.flaticon.com/free-icon/admin-with-cogwheels_78948",
		["Top Icon"] = "http://www.flaticon.com/free-icon/first-prize-trophy_47844",
		["Info Icon"] = "http://www.flaticon.com/free-icon/round-info-button_61093",
		["Back Icon"] = "http://www.flaticon.com/free-icon/back-arrow_60577",
		["Roulette Icon"] = "http://www.flaticon.com/free-icon/casino-roulette_82952",
		["Wreath Icon"] = "https://pixabay.com/en/laurel-wreath-accolade-winner-award-304839/"
	}}
}

local linkClr = Color(58, 83, 155)
TAB.Function = function(frame, layout)
	layout:SetSpaceY(5)

	local pnl = layout:Add("DPanel")
	pnl:SetSize(layout:GetWide(), 24)
	pnl.Paint = function(self, w, h)
		ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250)
		ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50)
		ui.DrawRect(6, 24, w - 12, 1, 0, 0, 0, 50)
		draw.SimpleText("About:", "gamble_os_18", 10, 12, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	for k, v in ipairs(TAB.About) do
		local pnl = layout:Add("DPanel")
		pnl:SetSize(layout:GetWide(), 60)
		pnl.Paint = function(self, w, h)
			ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250)
			ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50)
			ui.DrawRect(6, 24, w - 12, 1, 0, 0, 0, 50)
			draw.SimpleText(v[1], "gamble_os_18", 10, 12, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local pos = 28
		for k, v in pairs(v[2]) do
			local link = vgui.Create("DLabel", pnl)
			link:SetPos(10, pos)
			link:SetText(k .. ": " .. v)
			//link:SetFont("gamble_os_16")
			link:SizeToContents()
			link:SetMouseInputEnabled(true)
			link:SetColor(linkClr)
			link.DoClick = function()
				gui.OpenURL(v)
			end
			pos = pos + link:GetTall() + 2
		end

		pnl:SetTall(pos + 3)
	end

	local pnl = layout:Add("DPanel")
	pnl:SetSize(layout:GetWide(), 24)
	pnl.Paint = function(self, w, h)
		ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250)
		ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50)
		ui.DrawRect(6, 24, w - 12, 1, 0, 0, 0, 50)
		draw.SimpleText("Credits:", "gamble_os_18", 10, 12, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	for k, v in ipairs(TAB.Credits) do
		local pnl = layout:Add("DPanel")
		pnl:SetSize(layout:GetWide(), 60)
		pnl.Paint = function(self, w, h)
			ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250)
			ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50)
			ui.DrawRect(6, 24, w - 12, 1, 0, 0, 0, 50)
			draw.SimpleText(v[1], "gamble_os_18", 10, 12, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end

		local pos = 28
		for k, v in pairs(v[2]) do
			local link = vgui.Create("DLabel", pnl)
			link:SetPos(10, pos)
			link:SetText(k .. ": " .. v)
			//link:SetFont("gamble_os_16")
			link:SizeToContents()
			link:SetMouseInputEnabled(true)
			link:SetColor(linkClr)
			link.DoClick = function()
				gui.OpenURL(v)
			end
			pos = pos + link:GetTall() + 2
		end

		pnl:SetTall(pos + 3)
	end
end

GAMBLE._MenuTabs[4] = TAB