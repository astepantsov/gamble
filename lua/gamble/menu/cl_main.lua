local frame

surface.CreateFont("gamble_os_24", {font = "Open Sans", size = 24})
surface.CreateFont("gamble_os_18", {font = "Open Sans", size = 18})
surface.CreateFont("gamble_os_16_bold", {font = "Open Sans", size = 16, weight = 1000})

GAMBLE._MenuTabs = GAMBLE._MenuTabs or {
	[1] = {Title = "Profile", Material = "profile", Description = "View and manage your profile settings."},
	[2] = {Title = "Games", Material = "games", Description = "Participate in a lot of incredible games."},
	[3] = {Title = "Top", Material = "top", Description = "View the top players."},
	[4] = {Title = "Information", Material = "info", Description = "Read information about the script."},
	[5] = {Title = "Admin Menu", Material = "admin", Description = "Manage the script."}
}

function GAMBLE.ClientMenu()
	//if !GAMBLE.CheckDatabase(GAMBLE.ClientMenu) then return end
	if IsValid(frame) then return end
	if !GAMBLE.__LOADED then chat.AddText("[GAMBLE] DRM Authentication Failed."); return end
	
	frame = vgui.Create("mDesignFrame")
	frame:SetSize(1024, 768)
	frame:Center()
	frame:SetTitle("Gamble")
	frame:MakePopup()
	frame:DrawBig(true)  
	
	local freegame = GAMBLE.CONFIG["freegame"] == 1
	local header = vgui.Create("DPanel", frame)
	header:SetPos(1, 35)
	header:SetSize(1022, 30)
	header.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 255, 255, 255, 40)
		ui.DrawRect(0, h - 1, w, 1, 205, 205, 205, 250)
		
		draw.SimpleText(GAMBLE.LANG.GetString("balance") .. ": " .. (freegame and "∞" or GAMBLE.Client.credits) .. " " .. (GAMBLE.CONFIG.gamble_currency or "CR"), "mDesign_FrameTitle", 5, h / 2, Color(140, 140, 140), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
	
	frame.Clear = function(self)
		for k, v in pairs(self:GetChildren()) do
			if v == header || v == self.CloseButton || !IsValid(v) then continue end
			
			v:Remove()
		end
	end
	
	frame.SetupPage = function(self)
		self:Clear()
		
		self.CurrentScene = nil
		
		self.scroll = vgui.Create("mDesignScrollPanel", self)
		self.scroll:SetPos(1, 65)
		self.scroll:SetSize(self:GetWide() - 2, self:GetTall() - 66)
		
		self.layout = vgui.Create("DIconLayout", self.scroll)
		self.layout:SetSize(self.scroll:GetSize())
		self.layout:SetSpaceX(0)
		self.layout:SetSpaceY(0)
		
		local bmat = GAMBLE.MAT.GetMaterial("main/back")
		self.back = self.layout:Add("DButton")
		self.back:SetSize(self.layout:GetWide(), 20)
		self.back:SetText("")
		self.back.DoClick = function()
			self:SetupMainPage()
		end
		self.back.Paint = function(self, w, h)
			ui.DrawRect(0, 0, w, h, self.Hovered && Color(225, 225, 255) || Color(230, 230, 230))
			ui.DrawTexturedRect(4, 1, 16, 16, bmat, 120, 120, 120)
			draw.SimpleText(GAMBLE.LANG.GetString("back_to") .. " " .. (self.backto || "Main Menu"), "gamble_os_16_bold", 25, h / 2 - 1, Color(120, 120, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			ui.DrawRect(0, h - 1, w, 1, 205, 205, 205, 250)
		end
	end
	
	frame.SetupMainPage = function(self)
		self:Clear()
		
		self.CurrentScene = nil
	
		local scroll = vgui.Create("mDesignScrollPanel", self)
		scroll:SetPos(20, 85)
		scroll:SetSize(self:GetWide() - 40, self:GetTall() - 105)
		
		local btnw = (self:GetWide() - 60) / 2
		local layout = vgui.Create("DIconLayout", scroll)
		layout:SetSize(scroll:GetSize())
		layout:SetSpaceX(20)
		layout:SetSpaceY(20)
		
		for k, v in SortedPairs(GAMBLE._MenuTabs) do
			if !v.AdminOnly or (v.AdminOnly and LocalPlayer():IsSuperAdmin()) then
				local mat = GAMBLE.MAT.GetMaterial("main/" .. v.Material)
				local btn = layout:Add("DButton")
				btn:SetSize(btnw, 100)
				btn:SetText("")
				local title, desc = GAMBLE.LANG.GetString(v.Title), GAMBLE.LANG.GetString(v.Title .. "_desc")
				btn.Paint = function(self, w, h)
					ui.DrawRect(0, 0, w, h, 235, 235, 235)
					
					if self.Hovered then
						ui.DrawRect(h, 0, w - h, h, 230, 230, 230)
					end
					
					if v.Material == "admin" then
						ui.DrawTexturedRect(10, 10, 80, 80, mat, ui.Colors.Red)
					else
						ui.DrawTexturedRect(10, 10, 80, 80, mat, 140, 140, 140)
					end
					
					draw.SimpleText(title, "gamble_os_24", h + (w - h) / 2, h / 2 - 5, Color(130, 130, 130), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					ui.DrawRect(190, h / 2, w - 280, 1, 190, 190, 190)
					draw.SimpleText(desc, "gamble_os_18", h + (w - h) / 2, h / 2 + 5, Color(130, 130, 130), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
					
					ui.DrawOutlinedRect(0, 0, w, h, 190, 190, 190)
					ui.DrawOutlinedRect(0, 0, h, h, 190, 190, 190)
				end
				btn.DoClick = function()
					self:SetupPage()
					
					if v.Function then
						v.Function(self, self.layout)
					end
				end
			end
		end
	end
	
	frame:SetupMainPage()
end

net.Receive("gamble_game_error", function()
	if IsValid(frame) then
		frame:SetupMainPage()
	end

	GAMBLE_CURRENT_SCENE = nil
end)

concommand.Add("gamble_menu", function()
	if GAMBLE.CONFIG.npc_only == 1 and !LocalPlayer():IsSuperAdmin() then return end
	GAMBLE.ClientMenu()
end)