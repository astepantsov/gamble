local TAB = {}

TAB.Title = "adminmenu"
TAB.Material = "admin"

TAB.AdminOnly = true;

local lget = GAMBLE.LANG.GetString

TAB.Categories = TAB.Categories or {
	[1] = {Title = lget("configuration"), Color = Color(33, 150, 243), Function = function(pnl, frame, layout)
		local count = 0;
		local temp = {};
		local scroll_panel = vgui.Create("mDesignScrollPanel", pnl);
		scroll_panel:SetPos(0, 0);
		scroll_panel:SetSize(pnl:GetWide(), pnl:GetTall()-34);
		for k,v in pairs(GAMBLE.CONFIG) do
			count = count + 1;
			local pnl_config = vgui.Create("DPanel", scroll_panel);
			pnl_config:SetPos(0, 5 + (count-1) * 65);
			pnl_config:SetSize(pnl:GetWide(), 60);
			local translatedText = GAMBLE.LANG.GetString("config_" .. k)
			pnl_config.Paint = function(self, w, h)
				ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250);
				ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50);
				ui.DrawOutlinedRect(5, 0, w - 10, h/2 - 5, 0, 0, 0, 50);
				ui.DrawRect(6, 60, w - 12, 1, 0, 0, 0, 50);
				draw.SimpleText(translatedText, "gamble_os_18", 10, 12, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
			end
			local t = type(v)
			if (t == "string" or t == "number") and k != "language" then
				local text = vgui.Create("mDesignTextEntrySimple", pnl_config);
				text:SetPos(10, 30);
				text:SetSize(150, 24);
				text:SetValue(v);
				if t == "number" then
					text:SetNumeric(true);
					text.Think = function(self)
						local v = tonumber(self:GetValue()) or 0;
						self:SetValue(math.max(v,0));
					end
					text.OnValueChange = function(self, value)
						temp[k] = tonumber(value)
					end
				else
					text.Think = function(self)
						temp[k] = self:GetValue()
					end
				end
			elseif k == "language" then 
				local box = vgui.Create("DComboBox", pnl_config)
				box:SetPos(10, 30);
				box:SetSize(150, 24);
				box:SetValue(v)
				for k, v in pairs(GAMBLE.LANG._List) do
					box:AddChoice(k)
				end
				box.Think = function()
					local selected, _ = box:GetSelected()
					if !selected then return end
					temp[k] = selected
				end
			end
			scroll_panel:AddItem(pnl_config);
		end
		local btn_save = vgui.Create("mDesignFlatButton", pnl);
		btn_save:SetSize(pnl:GetWide() - 10, 24);
		btn_save:SetPos(5, pnl:GetTall() - 30);
		btn_save:SetText(lget("save"));
		btn_save:SetColor(Color(76, 175, 80));
		btn_save.DoClick = function()
			net.Start("gamble_changeconfig");
			net.WriteTable(temp);
			net.SendToServer();
		end
	end},
	[2] = {Title = lget("player_management"), Color = Color(255, 152, 0), Function = function(pnl, frame, layout)
		local pnl_steamid = vgui.Create("DPanel", pnl); 
		pnl_steamid:SetPos(0, 5);
		pnl_steamid:SetSize(pnl:GetWide(), 60);
		pnl_steamid.Paint = function(self, w, h)
			ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250);
			ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50);
			ui.DrawOutlinedRect(5, 0, w - 10, h/2 - 5, 0, 0, 0, 50);
			ui.DrawRect(6, 60, w - 12, 1, 0, 0, 0, 50);
			draw.SimpleText(lget("find_by_steamid") .. ": ", "gamble_os_18", 10, 12, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
		end
		local steamid_entry = vgui.Create("mDesignTextEntrySimple", pnl_steamid);
		steamid_entry:SetPos(10, 30);
		steamid_entry:SetSize(150, 24);
		local btn_find = vgui.Create("mDesignButton", pnl);
		btn_find:SetSize(100, 24);
		btn_find:SetPos(165, 35);
		btn_find:SetText(lget("find"));
		btn_find:SetColor(Color(76, 175, 80));
		btn_find.DoClick = function()
			net.Start("gamble_findplayer");
			net.WriteString(steamid_entry:GetValue());
			net.SendToServer();
		end
		local scroll = vgui.Create("mDesignScrollPanel", pnl);
		scroll:SetPos(6, 70);
		scroll:SetSize(pnl:GetWide() - 12, pnl:GetTall() - 75);
		local count = 0;
		for k,v in pairs(player.GetAll()) do
			count = count + 1;
			local pnl_player = vgui.Create("DButton", scroll);
			pnl_player:SetPos(0, 5 + (count-1)*55);
			pnl_player:SetSize(scroll:GetWide(), 50);
			pnl_player:SetText("");
			pnl_player.Paint = function(self, w, h)
				if self.Hovered then
					ui.DrawRect(0, 0, w - 2, h, 240, 240, 240, 250);
				else
					ui.DrawRect(0, 0, w - 2, h, 235, 235, 235, 250);
				end
				ui.DrawOutlinedRect(0, 0, w, h, 0, 0, 0, 50);
				ui.DrawRect(0, 50, w - 2, 1, 0, 0, 0, 50);
				draw.SimpleText(v:Name(), "gamble_os_18", 55, 25, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
			end
			pnl_player.DoClick = function()
				net.Start("gamble_findplayer");
				net.WriteString(v:SteamID());
				net.SendToServer();
			end
			local avatar = vgui.Create("AvatarImage", pnl_player)
			avatar:SetSize(38, 38)
			avatar:SetPos(6, 6)
			avatar:SetPlayer(v, 64)
			avatar.PaintOver = function(self, w, h)
				ui.DrawOutlinedRect(1, 1, w - 2, h - 2, color_white)
				ui.DrawOutlinedRect(0, 0, w, h, 180, 180, 180)
			end
			scroll:AddItem(pnl_player);
		end
		net.Receive("gamble_findplayer", function()
			local data = net.ReadTable();
			if pnl then pnl:Remove() end
			local fields = {
				[1] = {Name = (lget("nickname") .. ": "), Data = data.nickname},
				[2] = {Name = "SteamID32: ", Data = util.SteamIDFrom64(data.steamid64)},
				[3] = {Name = "SteamID64: ", Data = data.steamid64},
				[4] = {Name = (lget("total_amount_of_wins") .. ": "), Data = data.total_wins},
				[5] = {Name = (lget("amount_of_credits") .. ": "), Data = data.credits}
			}
			TAB.ContentPanel = layout:Add("DPanel");
			TAB.ContentPanel:SetSize(layout:GetWide(), frame.scroll:GetTall() - 20 - 34);
			TAB.ContentPanel.Paint = function() end
			for k,v in ipairs(fields) do
				layout:SetSpaceY(5);
				local pnl_mng = vgui.Create("DPanel", TAB.ContentPanel);
				pnl_mng:SetPos(0, 5 + 29 * (k-1));
				pnl_mng:SetSize(layout:GetWide(), 24);
				pnl_mng.Paint = function(self, w, h)
					ui.DrawRect(6, 0, w - 12, h, 240, 240, 240, 250);
					ui.DrawOutlinedRect(5, 0, w - 10, h, 0, 0, 0, 50);
					ui.DrawRect(6, 60, w - 12, 1, 0, 0, 0, 50);
					draw.SimpleText(v.Name .. v.Data, "gamble_os_18", 10, h/2, Color(60, 60, 60), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
				end
				if k == 5 or k == 4 then
					surface.SetFont("gamble_os_18");
					pnl_mng:SetSize(layout:GetWide(), 34);
					if k == 5 then
						local x, y = pnl_mng:GetPos()
						pnl_mng:SetPos(x, y + 10)
					end
					local btn_change = vgui.Create("mDesignButton", pnl_mng);
					btn_change:SetSize(100, 24);
					btn_change:SetPos(15 + surface.GetTextSize(v.Name .. v.Data), 5);
					btn_change:SetText(lget("change"));
					btn_change:SetColor(Color(76, 175, 80));
					btn_change.DoClick = function()
						local sm = vgui.Create("mDesignFrame");
						sm:SetSize(250, 90);
						sm:SetTitle(lget("set_credits_for") .. " " .. data.nickname);
						sm:Center();
						sm:DoModal(true);
						sm:MakePopup();
						sm:SetBackgroundBlur(true);

						local entry = vgui.Create("mDesignTextEntrySimple", sm);
						entry:SetPos(10, 30);
						entry:SetSize(230, 25);
						entry:SetNumeric(true);
						entry:SetValue(k == 5 and data.credits or data.total_wins);

						local bet = vgui.Create("mDesignButton", sm);
						bet:SetPos(10, 60);
						bet:SetSize(230, 25);
						bet:SetText(lget("set"));
						bet.DoClick = function()
							local value = tonumber(math.floor(entry:GetValue()) or 0)
							if value < 0 then return end

							net.Start(k == 5 and "gamble_setmoney" or "gamble_setwins");
							net.WriteTable({steamid64 = data.steamid64, amount = value});
							net.SendToServer();
							fields[k].Data = value;
							surface.SetFont("gamble_os_18");
							btn_change:SetPos(15 + surface.GetTextSize(v.Name .. v.Data), 5);
							
							sm:Remove()
						end
					end
				end
			end
			local btn_back = vgui.Create("mDesignFlatButton", TAB.ContentPanel);
			btn_back:SetSize(TAB.ContentPanel:GetWide() - 10, 24);
			btn_back:SetPos(5, TAB.ContentPanel:GetTall() - 30);
			btn_back:SetText(lget("back"));
			btn_back:SetColor(Color(76, 175, 80));
			btn_back.DoClick = function()
				if TAB.ContentPanel then TAB.ContentPanel:Remove(); end
				TAB.ContentPanel = layout:Add("DPanel");
				TAB.ContentPanel:SetSize(layout:GetWide(), frame.scroll:GetTall() - 20 - 34);
				TAB.ContentPanel.Paint = function() end
				TAB.Categories[2].Function(TAB.ContentPanel, frame, layout);
			end
		end)
	end}
}

TAB.Function = function(frame, layout)
	layout:SetSpaceY(5);
	local pnl = layout:Add("DPanel");
	pnl:SetSize(layout:GetWide(), 24);
	pnl.Paint = function() end
	for k,v in pairs(TAB.Categories) do
		local btn = vgui.Create("mDesignFlatButton", pnl);
		btn:SetSize((pnl:GetWide()-10)/#TAB.Categories - 5*(#TAB.Categories - 1), 24);
		btn:SetPos(5 + (k-1)*(btn:GetWide()+5));
		btn:SetText(v.Title);
		btn:SetColor(v.Color);
		btn.DoClick = function()
			if TAB.ContentPanel then TAB.ContentPanel:Remove(); end
			TAB.ContentPanel = layout:Add("DPanel");
			TAB.ContentPanel:SetSize(layout:GetWide(), frame.scroll:GetTall() - 20 - 34);
			TAB.ContentPanel.Paint = function() end
			v.Function(TAB.ContentPanel, frame, layout);
		end;

		if k == 1 then btn:DoClick() end;
	end
end

GAMBLE._MenuTabs[5] = TAB;