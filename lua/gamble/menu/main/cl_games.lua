local TAB = {}

TAB.Title = "games"
TAB.Material = "games"
 
TAB.Function = function(frame, layout)
	local size = (frame.scroll:GetSize() - 90) / 5
	local posx, posy = 15, 35
	local count = 0
	
	for k, v in pairs(GAMBLE.Games.list) do
		count = count + 1
		
		if count > 5 then
			posy = posy + 15 + size
			posx = 15
			count = 1
		end
		
		local mat = GAMBLE.MAT.GetMaterial(v.Material || "")
		local pnl = vgui.Create("DButton", frame.scroll)
		pnl:SetText("")
		pnl:SetPos(posx, posy)
		pnl:SetSize(size, size)
		local alpha = 0
		pnl.Paint = function(self, w, h)
			if self.Hovered then
				ui.DrawRect(0, 0, w, h, 240, 240, 240)
				
				alpha = Lerp(FrameTime() * 3, alpha, 255)
			else
				ui.DrawRect(0, 0, w, h, 235, 235, 235)
				
				alpha = Lerp(FrameTime() * 4, alpha, 0)
			end
			
			ui.DrawTexturedRect(35, 20, w - 70, h - 70, mat, 140, 140, 140)
			ui.DrawRect(1, h - 31, w - 2, 30, 0, 0, 0, 150)
			draw.SimpleText(v.Name, "gamble_os_24", w / 2, h - 16, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			ui.DrawRect(1, 1, w - 2, h - 32, 255, 255, 255, math.Min(alpha, 200))
			
			//34, 24
			ui.DrawRect(1, (h - 32) / 2 - 15, w - 2, 30, Color(0, 0, 0,  math.Min(alpha, 200)))
			draw.SimpleText("Play", "gamble_os_24", w / 2, (h - 32) / 2, Color(200, 230, 201, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			
			ui.DrawOutlinedRect(0, 0, w, h, 190, 190, 190)
		end
		pnl.DoClick = function()
			GAMBLE.Games.StartGame(k)
			
			GAMBLE_CURRENT_SCENE = k
			
			frame:SetupPage()
			frame.CurrentScene = k
			frame.back.backto = "Games"
			frame.back.DoClick = function()
				frame:SetupPage()
				TAB.Function(frame, frame.layout)
			end
			
			hook.Add("Think", "gamble_handle_leave", function()
				if !IsValid(frame) || frame.CurrentScene != GAMBLE_CURRENT_SCENE then
					GAMBLE.Games.LeaveGame()
					hook.Remove("Think", "gamble_handle_leave")
				end
			end)
			
			GAMBLE.GetCurrentScene():Call("SetupScene", frame, frame.layout)
		end
		
		posx = posx + 15 + size
	end
end 

GAMBLE._MenuTabs[2] = TAB