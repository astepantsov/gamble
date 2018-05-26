surface.CreateFont("gamble_os_32", {font = "Open Sans", size = 32})

local TAB = {}

TAB.Title = "top"
TAB.Material = "top"

TAB.Function = function(frame, layout)
	local sizex, sizey = frame.scroll:GetSize();
	sizex = (sizex - 90)/5;
	sizey = (sizey - 120)/6;
	local posx, posy = 15, 15;
	local count = 0;
	local pnl = layout:Add("DPanel", layout);
	pnl:SetSize(layout:GetWide(), layout:GetTall() - 20);
	pnl.Paint = function() end
	for k,v in pairs(GAMBLE.TOP30) do
		count = count + 1;
		
		if count > 5 then
			count = 1;
			posx = 15;
			posy = posy + 15 + sizey;
		end
		
		local box = vgui.Create("DButton", pnl);
		box:SetSize(sizex, sizey);
		box:SetPos(posx, posy);
		box:SetText("");
		local avatar = vgui.Create("AvatarImage", box)
		avatar:SetSize(45, 45)
		avatar:SetPos(5, 5)
		avatar:SetSteamID(v.steamid64, 64)
		avatar.PaintOver = function(self, w, h)
			ui.DrawOutlinedRect(1, 1, w - 2, h - 2, color_white)
			ui.DrawOutlinedRect(0, 0, w, h, 180, 180, 180)
		end
		//local gradient = Material("gui/gradient.vtf");
		local wreath = GAMBLE.MAT.GetMaterial("main/top/wreath");
		box.Paint = function(self, w, h)
			if self.Hovered or avatar.Hovered then
				ui.DrawRect(0, 0, w, h, 240, 240, 240);
			else
				ui.DrawRect(0, 0, w, h, 235, 235, 235);
			end
		
			local custom_colors = {Color(255, 82, 82), Color(255, 168, 82), ui.Colors.Green};
			ui.DrawRect(0, 0, w, h, self.Hovered && 230 or 245, self.Hovered && 230 or 245, self.Hovered && 230 or 245, 144);
			ui.DrawRect(0, h - 1, w - 1, 1, 205, 205, 205, 250);
			ui.DrawOutlinedRect(0, 0, w, h, custom_colors[k] or Color(190, 190, 190));
			
			local _, th = ui.DrawText(GAMBLE.MaxLength(v.nickname, 14), "gamble_os_24", 50 + (w - 50) / 2, 55 / 2, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(k < 4 and k or (k .. STNDRD(k)), "gamble_os_32", 5 + 45/2, 55 + ((self:GetTall() - 60)/2), custom_colors[k] or Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ui.DrawRect(50 + (w - 50) / 2 - 50, 55 / 2 + th / 2 + 5, 100, 1, 190, 190, 190)
			draw.SimpleText(GAMBLE.MaxLength(v.total_sum, 14) .. " " .. (GAMBLE.CONFIG.gamble_currency or "CR"), "gamble_os_18", 50 + (w - 50) / 2, 55 / 2 + th / 2 + 5, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			if custom_colors[k] then
				ui.DrawTexturedRect(7, 55, 42, 40, wreath, 255, 255, 255, 255);
			end
		end
		box.DoClick = function()
			gui.OpenURL("http://steamcommunity.com/profiles/" .. v.steamid64);
		end
		posx = posx + 15 + sizex;
	end
end

GAMBLE._MenuTabs[3] = TAB