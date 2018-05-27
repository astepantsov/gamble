/*
mDesign: VGUI Framework (version 1)
Authors:
	- Pyroman (http://steamcommunity.com/profiles/76561197997600622/)
	- krekeris (http://steamcommunity.com/profiles/76561198079040229/)

You're not allowed to use this framework without permission.
*/


ui = ui or {}

ui.Colors = {
	["Blue"] = Color(33, 150, 243),
	["Orange"] = Color(255, 152, 0),
	["Green"] = Color(76, 175, 80),
	["LightGreen"] = Color(139, 195, 74),
	["DeepOrange"] = Color(255, 87, 34),
	["Red"] = Color(244, 67, 54),
	["Indigo"] = Color(63, 81, 181)
}

if SERVER then

	util.AddNetworkString("mDesign_Notify")
	util.AddNetworkString("mDesign_Query")

	ui.Notify = function(ply, tbl)
		net.Start("mDesign_Notify")
		net.WriteTable(tbl)
		net.Send(ply)
	end

	ui.Query = function(ply, tbl)
		net.Start("mDesign_Query")
		net.WriteTable(tbl)
		net.Send(ply)
	end
end

if CLIENT then
/* UTIL FUNCTIONS */
local SetColor = surface.SetDrawColor
local SetMaterial = surface.SetMaterial

local DrawRect = surface.DrawRect
local DrawOutlinedRect = surface.DrawOutlinedRect
local DrawTexturedRect = surface.DrawTexturedRect
local DrawTexturedRectRotated = surface.DrawTexturedRectRotated

local GetTextSize = surface.GetTextSize
local SetFont = surface.SetFont

local DrawText = draw.SimpleText

ui.DrawRect = function(x, y, w, h, ...)
    if (...) then
        SetColor(...)
    end

    DrawRect(x, y, w, h)
end

ui.DrawOutlinedRect = function(x, y, w, h, ...)
    if (...) then
        SetColor(...)
    end

    DrawOutlinedRect(x, y, w, h)
end

ui.DrawTexturedRect = function(x, y, w, h, material, ...)
    if (...) then
        SetColor(...)
    else
        SetColor(255, 255, 255, 255)
    end

    SetMaterial(material)
    DrawTexturedRect(x, y, w, h)
end

ui.DrawTexturedRectRotated = function(x, y, w, h, material, rotation, ...)
    if (...) then
        SetColor(...)
    else
        SetColor(255, 255, 255, 255)
    end

    SetMaterial(material)
    DrawTexturedRectRotated(x, y, w, h, rotation)
end

ui.DrawText = function(text, font, x, y, color, align_x, align_y)
    local w, h = DrawText(text, font, x, y, color, align_x, align_y)

    if !w || !h then
        SetFont(font)
        w, h = GetTextSize(text)
    end

    return w, h
end

ui.PaintText = function(x, y, font, align_x, align_y, ...)
	local currentColor = color_white
	local lasth = 0
	local initx = x
	local currentFont = font
	
	for _, v in ipairs({...}) do
		local t = type(v)
	
		if t == "table" then
			currentColor = v
		elseif t == "boolean" then
			if v then
				y = y + lasth + 2
				x = initx
			end
		elseif t == "string" then
			if v:StartWith("#f ") then
				currentFont = v:Right(#v - 3)
			else
				local w, h = ui.DrawText(v, currentFont, x, y, currentColor, align_x, align_y)
				lasth = h
				x = x + w
			end
		elseif t == "number" then
			x = x + v
		end
	end
end

file.CreateDir("mdesign/materials")
ui.DownloadMaterial = function(url, callback)
    local crc = util.CRC(url)
    
    if file.Exists("mdesign/materials/" .. crc .. ".png", "DATA") then
        local mat = Material("../data/mdesign/materials/" .. crc .. ".png", "smooth")
        callback(mat)
    end

    http.Fetch(url, function(body)
        file.Write("mdesign/materials/" .. crc .. ".png", body)
        
        local mat = Material("../data/mdesign/materials/" .. crc .. ".png", "smooth")
        callback(mat)
    end)
end 
/* VGUI: Slider */
local PANEL = {}

// Code from derma

AccessorFunc( PANEL, "NumSlider", 			"NumSlider" )

AccessorFunc( PANEL, "m_fSlideX", 			"SlideX" )
AccessorFunc( PANEL, "m_fSlideY", 			"SlideY" )

AccessorFunc( PANEL, "m_iLockX", 			"LockX" )
AccessorFunc( PANEL, "m_iLockY", 			"LockY" )

AccessorFunc( PANEL, "Dragging", 			"Dragging" )
AccessorFunc( PANEL, "m_bTrappedInside", 	"TrapInside" )
AccessorFunc( PANEL, "m_iNotches", 			"Notches" )

--[[---------------------------------------------------------

-----------------------------------------------------------]]
local smat = Material("mdesign/slider_circle.png")
ui.DownloadMaterial("http://i.imgur.com/ztmVewi.png", function(m) smat = m end)
function PANEL:Init()
	self.FilledColor = Color(0, 200, 200)
	self:SetMouseInputEnabled( true )

	self:SetSlideX( 0.5 )
	self:SetSlideY( 0.5 )

	self.Knob = vgui.Create( "DButton", self )
	self.Knob:SetText( "" )
	self.Knob:SetSize( 14, 14 )
	self.Knob:NoClipping( true )
	self.Knob.Paint = function(pnl, w, h)
		surface.SetDrawColor(self.FilledColor)
		surface.SetMaterial(smat)
		surface.DrawTexturedRect(0, 0, w, h)
	end
	self.Knob.OnCursorMoved = function( panel, x, y )
		x, y = panel:LocalToScreen(x, y)
		x, y = self:ScreenToLocal(x, y)
		self:OnCursorMoved(x, y)
	end

	self:SetLockY( 0.5 )
end

function PANEL:Paint(w, h)
	local slidex = self:GetSlideX()
	surface.SetDrawColor(190, 190, 190)
	surface.DrawRect(0, 0, w, h)

	surface.SetDrawColor(self.FilledColor)
	surface.DrawRect(0, 0, w * slidex, h)
end

PANEL.GetFloat = PANEL.GetSlideX

function PANEL:SetMin(value)
	self.fMinValue = value
end

function PANEL:SetMax(value)
	self.fMaxValue = value
end

function PANEL:SetMinMax(min, max)
	self.fMinValue = min
	self.fMaxValue = max
end

function PANEL:GetValue()
	local min, max = self.fMinValue or 0, self.fMaxValue or 100
	
	return (max - min) * self:GetFloat() + min
end

--
-- We we currently editing?
--
function PANEL:IsEditing()

	return self.Dragging or self.Knob.Depressed

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetBackground( img )

	if ( !self.BGImage ) then
		self.BGImage = vgui.Create( "DImage", self )
	end

	self.BGImage:SetImage( img )
	self:InvalidateLayout()

end


--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetImage( strImage )

	-- RETIRED

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetImageColor( color )

	-- RETIRED

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:OnCursorMoved( x, y )

	if ( !self.Dragging && !self.Knob.Depressed ) then return end

	local w, h = self:GetSize()
	local iw, ih = self.Knob:GetSize()

	if ( self.m_bTrappedInside ) then

		w = w - iw
		h = h - ih

		x = x - iw * 0.5
		y = y - ih * 0.5

	end

	x = math.Clamp( x, 0, w ) / w
	y = math.Clamp( y, 0, h ) / h

	if ( self.m_iLockX ) then x = self.m_iLockX end
	if ( self.m_iLockY ) then y = self.m_iLockY end

	x, y = self:TranslateValues( x, y )

	self:SetSlideX( x )
	self:SetSlideY( y )

	self:InvalidateLayout()

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:TranslateValues( x, y )

	-- Give children the chance to manipulate the values..
	return x, y

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:OnMousePressed( mcode )

	self:SetDragging( true )
	self:MouseCapture( true )

	local x, y = self:CursorPos()
	self:OnCursorMoved( x, y )

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:OnMouseReleased( mcode )

	self:SetDragging( false )
	self:MouseCapture( false )

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:PerformLayout()

	local w, h = self:GetSize()
	local iw, ih = self.Knob:GetSize()

	if ( self.m_bTrappedInside ) then

		w = w - iw;
		h = h - ih;
		self.Knob:SetPos( (self.m_fSlideX or 0) * w, (self.m_fSlideY or 0) * h )

	else

		self.Knob:SetPos( (self.m_fSlideX or 0) * w - iw * 0.5, (self.m_fSlideY or 0) * h - ih * 0.5 )

	end

	if ( self.BGImage ) then
		self.BGImage:StretchToParent(0,0,0,0)
		self.BGImage:SetZPos( -10 )
	end

end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetSlideX( i )
	self.m_fSlideX = i
	self:InvalidateLayout()
end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:SetSlideY( i )
	self.m_fSlideY = i
	self:InvalidateLayout()
end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:GetDragging()
	return self.Dragging or self.Knob.Depressed
end

derma.DefineControl( "mDesignSlider", "", PANEL, "Panel" )


/* VGUI: Query */
surface.CreateFont("mDesignQueryText", {font = "Roboto", size = 24, weight = 500})

ui.Query = function(title, btntext1, btnfunc1, btntext2, btnfunc2)
	local frame = vgui.Create("DFrame")
	frame:MakePopup() 
	frame:DoModal()
	frame:SetSize(100, 36)
	frame:ShowCloseButton(false)
	frame.Paint = function(self, w, h)
		Derma_DrawBackgroundBlur(self, 0)
		surface.SetDrawColor(250, 250, 250, 250)
		surface.DrawRect(0, 0, w, h)
	end
	frame.Anim = Derma_Anim("OveerseerFade", frame, function(pnl, anim, delta, data)
		if not pnl.toclose then
			pnl:SetAlpha(255*delta)
		else
			pnl:SetAlpha(255 - (255*delta))
			if delta == 1 and IsValid(pnl) then pnl:Remove() end
		end
	end)
	frame.Think = function(self)
		if self.Anim and self.Anim:Active() then
			self.Anim:Run()
		end
	end
	
	frame.Text = vgui.Create("DLabel", frame)
	frame.Text:SetPos(20, 20)
	frame.Text:SetFont("mDesignQueryText")
	frame.Text:SetText(title or "nil")
	frame.Text:SetColor(Color(114, 114, 114))
	frame.Text:SizeToContents()
	frame:SetSize(frame.Text:GetWide() + 40 + 168, frame.Text:GetTall() + 30 + 70)
	
	frame.btn2 = vgui.Create("DButton", frame)
	frame.btn2:SetText("")
	frame.btn2:SetSize(70, 36)
	frame.btn2:SetPos(frame:GetWide()-80, frame:GetTall()-40)
	frame.btn2.Paint = function(self, w, h)
		draw.SimpleText(btntext2 or "Label", "mDesignQueryText", w/2, h/2, Color(0, 120, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	frame.btn2.DoClick = function(self)
		if btnfunc2 then btnfunc2() end
		self:GetParent().toclose = true
		self:GetParent().Anim:Start(0.3)
	end
	
	frame.btn1 = vgui.Create("DButton", frame)
	frame.btn1:SetText("")
	frame.btn1:SetSize(70, 36)
	frame.btn1:SetPos(frame:GetWide()-160, frame:GetTall()-40)
	frame.btn1.Paint = function(self, w, h)
		draw.SimpleText(btntext1 or "Cancel", "mDesignQueryText", w/2, h/2, Color(0, 120, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	frame.btn1.DoClick = function(self)
		if btnfunc1 then btnfunc1() end
		self:GetParent().toclose = true
		self:GetParent().Anim:Start(0.3)
	end
	
	frame:Center()
	
	frame.Anim:Start(0.3)
end

net.Receive("mDesign_Query", function()
	local tbl = net.ReadTable()
	
	ui.Query(tbl.Text, tbl.ButtonText1, _, tbl.ButtonText2, _)
end)



/* VGUI: ListView_Column */
local PANEL = {}

function PANEL:Init()
	self.Header.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 240, 240, 240)
		ui.DrawOutlinedRect(0, 0, w, h, 180, 180, 180)
	end
end

vgui.Register("mDesignListView_Column", PANEL, "DListView_Column")

/* VGUI: Button */
local PANEL = {}

local gradient = Material("gui/gradient.vtf")

surface.CreateFont("mDesign_ButtonText", {font = "Roboto", size = 18})
surface.CreateFont("mDesign_ButtonTextDepressed", {font = "Roboto", size = 16})

function PANEL:Init()
    self.Alpha = 0

    local oldText = self.SetText

    oldText(self, "")

    function self:SetText(str)
        self.strText = tostring(str)
    end

    function self:GetText()
        return self.strText
    end
end

function PANEL:Paint(w, h)
    local clrRect = Color(230, 230, 230)
    local clrText = Color(100, 100, 100, 220)

    local start = 0
    if self:GetDisabled() then
        clrRect = Color(200, 200, 200)
        clrText = Color(100, 100, 100)
        self.Alpha = Lerp(FrameTime() * 3, self.Alpha, 200)
    elseif self.Depressed then
        clrRect = Color(235, 235, 235)
        clrText = Color(105, 105, 105)
        self.Alpha = Lerp(FrameTime() * 3, self.Alpha, 40)
        start = 1
    elseif self.Hovered then
        clrRect = Color(233, 233, 233)
        clrText = Color(120, 120, 120, 220)
        self.Alpha = Lerp(FrameTime() * 3, self.Alpha, 90)
    else
        self.Alpha = Lerp(FrameTime() * 3, self.Alpha, 80)
    end

    ui.DrawRect(start, start, w - (start * 2), h - (start * 2), clrRect)
    ui.DrawTexturedRectRotated(start + w / 2, h / 2 + 5 + start, h + 8, w - (start * 2), gradient, 90, 0, 0, 0, self.Alpha)
    ui.DrawOutlinedRect(start, start, w - (start * 2), h - (start * 2), 180, 180, 180)

    ui.DrawText(self:GetText() or "Label", "mDesign_ButtonText", w / 2, h / 2, clrText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("mDesignButton", PANEL, "DButton")


/* VGUI: FlatButton */
local PANEL = {}

local gradient = Material("gui/gradient.vtf")

surface.CreateFont("mDesign_ButtonText", {font = "Roboto", size = 18})

function PANEL:Init()
    local oldText = self.SetText

    oldText(self, "")

    function self:SetText(str)
        self.strText = tostring(str)
    end

    function self:GetText()
        return self.strText
    end

    self.MaterialColor = Color(255, 255, 255)
    self.ButtonColor = Color(102, 193, 220)
end

function PANEL:SetColor(clr)
    self.ButtonColor = clr
end

function PANEL:SetMaterial(mat)
    self.Material = mat
end

function PANEL:SetMaterialColor(clr)
    self.MaterialColor = clr
end

PANEL.SetImage = PANEL.SetMaterial
PANEL.SetIcon = PANEL.SetMaterial

PANEL.SetImageColor = PANEL.SetMaterialColor
PANEL.SetIconColor = PANEL.SetMaterialColor

function PANEL:Paint(w, h)
    local linesize = math.floor(h / 10)
    local boxsize = h - linesize
    local start = 0

    if self.Depressed then
        start = 1
    end

    ui.DrawRect(0, start, w, h, self.ButtonColor)
    ui.DrawRect(0, boxsize + start, w, linesize, 0, 0, 0, 100)

    if self.Material then
        ui.DrawRect(0, start, boxsize, boxsize, 0, 0, 0, 20)
        ui.DrawRect(boxsize, start, 1, boxsize, 255, 255, 255, 30)

        ui.DrawTexturedRect(4, start + 4, boxsize - 8, boxsize - 8, self.Material, self.MaterialColor)

        if self.Hovered then
            ui.DrawRect(boxsize + 1, start, w - boxsize - 1, boxsize, 0, 0, 0, 10)
        end

        ui.DrawText(self:GetText(), "mDesign_ButtonText", boxsize + (w - boxsize) / 2, boxsize / 2 + start, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        ui.DrawText(self:GetText(), "mDesign_ButtonText", w / 2, boxsize / 2 + start, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self.Hovered then
            ui.DrawRect(boxsize + 1, start, w - boxsize - 1, boxsize, 0, 0, 0, 10)
        end
    end
end

vgui.Register("mDesignFlatButton", PANEL, "DButton")


/* VGUI: TextEntrySimple */
local PANEL = {}

surface.CreateFont("mDesignTextEntry_GhostItalic", {font = "Roboto", size = 16, italic = true})
surface.CreateFont("mDesignTextEntry", {font = "Roboto", size = 16})

function PANEL:Init()
	self:SetFont("mDesignTextEntry")
end

function PANEL:OnLoseFocus()
	self.Focus = false
end

function PANEL:OnGetFocus()
	self.Focus = true
end

function PANEL:SetGhostText(str)
	self.mGhostText = str
end

function PANEL:GetGhostText()
	return self.mGhostText
end

function PANEL:Paint(w, h)
	local text = self:GetValue()


	if self.Focus then
		ui.DrawRect(0, 0, w, h, 245, 245, 220)
		ui.DrawOutlinedRect(0, 0, w, h, 41, 128, 185)
	else
		ui.DrawRect(0, 0, w, h, 250, 250, 250)
		if self.mGhostText and (!text or text == "") then
			draw.SimpleText(self.mGhostText, "mDesignTextEntry_GhostItalic", 5, h / 2, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
		ui.DrawOutlinedRect(0, 0, w, h, 180, 180, 180)
	end

	self:DrawTextEntryText(Color(100, 100, 100), Color(210, 210, 210), Color(0, 100, 153))
end


vgui.Register("mDesignTextEntrySimple", PANEL, "DTextEntry")


/* VGUI: Frame */
local PANEL = {}

local gradient = Material("gui/gradient.vtf")
local lines = Material("mdesign/frame_lines.png")
ui.DownloadMaterial("http://i.imgur.com/IcCGd2E.png", function(m) lines = m end)

surface.CreateFont("mDesign_FrameTitle", {font = "Roboto", size = 18})
surface.CreateFont("mDesign_FrameTitleBig", {font = "Roboto", size = 24})

function PANEL:Init()
    self.CloseButton = vgui.Create("mDesignCloseButton", self)
    self.CloseButton:SetSize(24, 24)
    self.CloseButton.ToClose = self

    self.btnClose:Remove()
    self.btnMaxim:Remove()
    self.btnMinim:Remove()
    self.lblTitle:Remove()
	
	self.clrHeader = ui.Colors.Blue
end

function PANEL:SetTitle(str)
    self.strTitle = str
end

function PANEL:GetTitle(str)
    return self.strTitle or "Frame"
end

function PANEL:DrawBig(bool)
    self.bDrawBig = bool
    self:PerformLayout()
end

function PANEL:IsBig()
    return self.bDrawBig == true
end

function PANEL:SetHeaderColor(clr)
	self.clrHeader = clr
end

function PANEL:Paint(w, h)
    if (self.m_bBackgroundBlur) then
        Derma_DrawBackgroundBlur(self, self.m_fCreateTime)
    end
	
    if self.bDrawBig then
        ui.DrawRect(0, 34, w, h - 34, 245, 245, 245)
        ui.DrawRect(0, 0, w, 34, self.clrHeader) // header
        ui.DrawOutlinedRect(0, 34, w, h - 34, 205, 205, 205, 250) // shadow-like line

        ui.DrawTexturedRect(0, 35, w / 4, h - 35, gradient, 0, 0, 0, 40)
        ui.DrawTexturedRectRotated(w - (w / 4), h / 2 + (35 / 2), w / 2, h - 35, gradient, 180, 0, 0, 0, 40)

        ui.DrawTexturedRect(2, 2, 32, 32, lines, 250, 250, 250, 255)

        ui.DrawText(self:GetTitle(), "mDesign_FrameTitleBig", w / 2 + 1, 35 / 2, Color(0, 0, 0, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        ui.DrawText(self:GetTitle(), "mDesign_FrameTitleBig", w / 2, 35 / 2 - 1, Color(250, 250, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
        ui.DrawRect(0, 25, w, h - 25, 245, 245, 245)
        ui.DrawRect(0, 0, w, 25, self.clrHeader) // header
        ui.DrawOutlinedRect(0, 25, w, h - 25, 205, 205, 205, 250) // shadow-like line

        ui.DrawTexturedRect(0, 26, w / 4, h - 26, gradient, 0, 0, 0, 40)
        ui.DrawTexturedRectRotated(w - (w / 4), h / 2 + 13, w / 2, h - 26, gradient, 180, 0, 0, 0, 40)

        ui.DrawText(self:GetTitle(), "mDesign_FrameTitle", 6, 13, Color(0, 0, 0, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        ui.DrawText(self:GetTitle(), "mDesign_FrameTitle", 5, 12, Color(250, 250, 250), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function PANEL:PerformLayout()
    if self.bDrawBig then
        self.CloseButton:SetPos(self:GetWide() - 29, 5)
    else
        self.CloseButton:SetPos(self:GetWide() - 25, 1)
    end
end

function PANEL:ShowCloseButton(bool)
    self.CloseButton:SetVisible(bool)
end

vgui.Register("mDesignFrame", PANEL, "DFrame")


/* VGUI: CloseButton */
local PANEL = {}

PANEL.Angle = 0

local bmat = Material("mdesign/close.png")
ui.DownloadMaterial("http://i.imgur.com/GsMZxkY.png", function(m) bmat = m end)

function PANEL:Init()
    self.Anim = Derma_Anim("OveerserButtonRotate", self, function(pnl, anim, delta, data)
    	if pnl.AngleAnotherWay then
    		pnl.Angle = 180 * delta
    	else
    		pnl.Angle = -180 * delta
        end
	end)

    self:SetSize(24, 24)
    self:SetText("")
end

function PANEL:DoClick()
    if self.ToClose then
        self.ToClose:Close()
    end
end

function PANEL:Paint(w, h)
    ui.DrawTexturedRectRotated(w / 2, h / 2, w, h, bmat, self.Angle)
end

function PANEL:OnCursorEntered()
    if self.Anim:Active() then self.Anim:Stop() end
    self.Anim:Start(0.4)
    self.AngleAnotherWay = false
end

function PANEL:OnCursorExited()
    if self.Anim:Active() then self.Anim:Stop() end
    self.Anim:Start(0.4)
    self.AngleAnotherWay = true
end

function PANEL:Think()
    if self.Anim and self.Anim:Active() then
        self.Anim:Run()
    end
end

vgui.Register("mDesignCloseButton", PANEL, "DButton")


/* VGUI: TextEntry */
local PANEL = {}

PANEL.Colors = {
	inactive = Color(210, 210, 210),
	invalid = Color(153, 0, 0),
	valid = Color(0, 180, 183)
}

surface.CreateFont("mDesignEntryText", {font = "Roboto", size = 18, weight = 500})

function PANEL:Init()
	self.mGhostText = ""
	self.Entry = vgui.Create("DTextEntry", self)
	self.Entry.Paint = function(pnl, w, h)
		pnl:DrawTextEntryText(Color(100, 100, 100), Color(210, 210, 210), Color(0, 100, 153))
		local text = pnl:GetValue()
		if !pnl.Focus and self.mGhostText and (!text or text == "") then
			draw.SimpleText(self.mGhostText, "mDesignEntryText", 5, h/2, Color(190, 190, 190), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
	self.Entry.IsEnabled = false
	self.Entry.OnLoseFocus = function(pnl)
		pnl.Focus = false
	end
	self.Entry.OnGetFocus = function(pnl)
		//pnl.IsEnabled = true
		pnl.Focus = true
	end
	self.Entry.OnChange = function(pnl)
		local str = pnl:GetValue()
		if #str == 0 then
			pnl.IsEnabled = false
		else
			pnl.IsEnabled = true
		end
	end
	self.Entry:SetFont("mDesignEntryText")
	
	self.SetRealSize = self.SetSize
	
	self.SetSize = function(self, w, h)
		self:SetRealSize(w, h)
		self.Entry:SetSize(w, h-2)
	end
end

function PANEL:SetGhostText(str)
	self.mGhostText = str
end

function PANEL:GetGhostText()
	return self.mGhostText
end

function PANEL:IsValidText()
	local str = (self.Entry:GetValue() or "")
	return #str > 1
end

function PANEL:SetRegex(pattern)
	self.IsValidText = function()
		local str = (self.Entry:GetValue() or "")
		
		return str:match(pattern)
	end
end

function PANEL:SetEditable(...)
	self.Entry:SetEditable(...)
end

function PANEL:SetDisabled(...)
	self.Entry:SetDisabled(...)
end

function PANEL:SetFont(...)
	self.Entry:SetFont(...)
end

function PANEL:SetValue(...)
	self.Entry:SetValue(...)
end

function PANEL:GetValue()
	return self.Entry:GetValue()
end

function PANEL:SetNumeric(...)
	self.Entry:SetNumeric(...)
end

function PANEL:Paint(w, h)
	if self:IsValidText() and self.Entry.IsEnabled then
		surface.SetDrawColor(self.Colors.valid)
		surface.DrawRect(0, h-2, w, 2)
	elseif !self.Entry.IsEnabled then
		surface.SetDrawColor(self.Colors.inactive)
		surface.DrawRect(0, h-2, w, 2)
	else
		surface.SetDrawColor(self.Colors.invalid)
		surface.DrawRect(0, h-2, w, 2)
	end
end

vgui.Register("mDesignTextEntry", PANEL, "Panel")


/* VGUI: VScrollBar */
local PANEL = {}

AccessorFunc( PANEL, "Padding", 	"Padding" )
AccessorFunc( PANEL, "pnlCanvas", 	"Canvas" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.pnlCanvas 	= vgui.Create( "Panel", self )
	self.pnlCanvas.OnMousePressed = function( self, code ) self:GetParent():OnMousePressed( code ) end
	self.pnlCanvas:SetMouseInputEnabled( true )
	self.pnlCanvas.PerformLayout = function( pnl )

		self:PerformLayout()
		self:InvalidateParent()

	end

	-- Create the scroll bar
	self.VBar = vgui.Create( "mDesignVScrollBar", self )
	self.VBar:Dock( RIGHT )

	self:SetPadding( 0 )
	self:SetMouseInputEnabled( true )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )
	self:SetPaintBackground( false )

end

--[[---------------------------------------------------------
   Name: AddItem
-----------------------------------------------------------]]
function PANEL:AddItem( pnl )

	pnl:SetParent( self:GetCanvas() )

end

function PANEL:OnChildAdded( child )

	self:AddItem( child )

end

--[[---------------------------------------------------------
   Name: SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents()

	self:SetSize( self.pnlCanvas:GetSize() )

end

--[[---------------------------------------------------------
   Name: GetVBar
-----------------------------------------------------------]]
function PANEL:GetVBar()

	return self.VBar

end

--[[---------------------------------------------------------
   Name: GetCanvas
-----------------------------------------------------------]]
function PANEL:GetCanvas()

	return self.pnlCanvas

end

function PANEL:InnerWidth()

	return self:GetCanvas():GetWide()

end

--[[---------------------------------------------------------
   Name: Rebuild
-----------------------------------------------------------]]
function PANEL:Rebuild()

	self:GetCanvas():SizeToChildren( false, true )

	-- Although this behaviour isn't exactly implied, center vertically too
	if ( self.m_bNoSizing && self:GetCanvas():GetTall() < self:GetTall() ) then

		self:GetCanvas():SetPos( 0, (self:GetTall()-self:GetCanvas():GetTall()) * 0.5 )

	end

end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	return self.VBar:OnMouseWheeled( dlta )

end

--[[---------------------------------------------------------
   Name: OnVScroll
-----------------------------------------------------------]]
function PANEL:OnVScroll( iOffset )

	self.pnlCanvas:SetPos( 0, iOffset )

end

--[[---------------------------------------------------------
   Name: ScrollToChild
-----------------------------------------------------------]]
function PANEL:ScrollToChild( panel )

	self:PerformLayout()

	local x, y = self.pnlCanvas:GetChildPosition( panel )
	local w, h = panel:GetSize()

	y = y + h * 0.5;
	y = y - self:GetTall() * 0.5;

	self.VBar:AnimateTo( y, 0.5, 0, 0.5 );

end


--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	local Wide = self:GetWide()
	local YPos = 0

	self:Rebuild()

	self.VBar:SetUp( self:GetTall(), self.pnlCanvas:GetTall() )
	YPos = self.VBar:GetOffset()

	if ( self.VBar.Enabled ) then Wide = Wide - self.VBar:GetWide() end

	self.pnlCanvas:SetPos( 0, YPos )
	self.pnlCanvas:SetWide( Wide )

	self:Rebuild()


end

function PANEL:Clear()

	return self.pnlCanvas:Clear()

end


derma.DefineControl( "mDesignScrollPanel", "", PANEL, "DPanel" )

local PANEL = {}

local btnUp = Material("mdesign/sb_btn_up.png", "noclamp smooth")
local btnDown = Material("mdesign/sb_btn_down.png", "noclamp smooth")

ui.DownloadMaterial("http://i.imgur.com/IK0QRME.png", function(m) btnUp = m end)
ui.DownloadMaterial("http://i.imgur.com/GxGX2yj.png", function(m) btnDown = m end)
 
function PANEL:Init()
	self.btnUp.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 215, 215, 215)
		
		local clr = Color(158, 158, 158)
		
		if self.Depressed then
			clr = Color(170, 170, 170)
		elseif self.Hovered then
			clr = Color(165, 165, 165)
		end
		
		ui.DrawTexturedRect(2, 2, 11, 11, btnUp, clr)
	end
	
	self.btnDown.Paint = function(self, w, h)
		ui.DrawRect(0, 0, w, h, 215, 215, 215)
		
		local clr = Color(158, 158, 158)
		
		if self.Depressed then
			clr = Color(170, 170, 170)
		elseif self.Hovered then
			clr = Color(165, 165, 165)
		end
		
		ui.DrawTexturedRect(2, 2, 11, 11, btnDown, clr)
	end
	
	self.btnGrip.Paint = function(self, w, h)
		local clr = Color(180, 180, 180)
		
		if self.Depressed then
			clr = Color(190, 190, 190)
		elseif self.Hovered then
			clr = Color(185, 185, 185)
		end
		
		ui.DrawRect(2, 0, w - 4, h, clr)
		ui.DrawOutlinedRect(2, 0, w - 4, h, 160, 160, 160)
	end
end

function PANEL:Paint(w, h)
	ui.DrawRect(0, 0, w, h, 215, 215, 215)
end

vgui.Register("mDesignVScrollBar", PANEL, "DVScrollBar")

/* VGUI: ListView */
--[[

	DListView
	
	Columned list view

	TheList = vgui.Create( "DListView" )
	
	local Col1 = TheList:AddColumn( "Address" )
	local Col2 = TheList:AddColumn( "Port" )
	
	Col2:SetMinWidth( 30 )
	Col2:SetMaxWidth( 30 )
	
	TheList:AddLine( "192.168.0.1", "80" )
	TheList:AddLine( "192.168.0.2", "80" )
	
	etc

--]]

local PANEL = {}

AccessorFunc( PANEL, "m_bDirty",		"Dirty", FORCE_BOOL )
AccessorFunc( PANEL, "m_bSortable",		"Sortable", FORCE_BOOL )

AccessorFunc( PANEL, "m_iHeaderHeight",	"HeaderHeight" )
AccessorFunc( PANEL, "m_iDataHeight",	"DataHeight" )

AccessorFunc( PANEL, "m_bMultiSelect",	"MultiSelect" )
AccessorFunc( PANEL, "m_bHideHeaders",	"HideHeaders" )

//Derma_Hook( PANEL, "Paint", "Paint", "ListView" )


--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetSortable( true )
	self:SetMouseInputEnabled( true )
	self:SetMultiSelect( true )
	self:SetHideHeaders( false )

	self:SetDrawBackground( true )
	self:SetHeaderHeight( 16 )
	self:SetDataHeight( 17 )

	self.Columns = {}

	self.Lines = {}
	self.Sorted = {}

	self:SetDirty( true )

	self.pnlCanvas = vgui.Create( "Panel", self )

	self.VBar = vgui.Create( "mDesignVScrollBar", self )
	self.VBar:SetZPos( 20 )

end

--[[---------------------------------------------------------
   Name: DisableScrollbar
-----------------------------------------------------------]]
function PANEL:DisableScrollbar()

	if ( IsValid( self.VBar ) ) then
		self.VBar:Remove()
	end

	self.VBar = nil

end

function PANEL:Paint(w, h)
	if self.VBar.Enabled then
		ui.DrawOutlinedRect(0, 0, w - 16, h, 180, 180, 180)
	else
		ui.DrawOutlinedRect(0, 0, w, h, 180, 180, 180)
	end
end

--[[---------------------------------------------------------
   Name: GetLines
-----------------------------------------------------------]]
function PANEL:GetLines()
	return self.Lines
end

--[[---------------------------------------------------------
   Name: GetInnerTall
-----------------------------------------------------------]]
function PANEL:GetInnerTall()
	return self:GetCanvas():GetTall()
end

--[[---------------------------------------------------------
   Name: GetCanvas
-----------------------------------------------------------]]
function PANEL:GetCanvas()
	return self.pnlCanvas
end

--[[---------------------------------------------------------
   Name: AddColumn
-----------------------------------------------------------]]
function PANEL:AddColumn( strName, iPosition )

	local pColumn = nil
	
	pColumn = vgui.Create( "mDesignListView_Column", self )

	pColumn:SetName( strName )
	pColumn:SetZPos( 10 )

	if ( iPosition ) then
	
		table.insert( self.Columns, iPosition, pColumn )
		
		for i = 1,#self.Columns do
			self.Columns[ i ]:SetColumnID( i )
		end
	
	else
	
		local ID = table.insert( self.Columns, pColumn )
		pColumn:SetColumnID( ID )
	
	end

	self:InvalidateLayout()

	return pColumn

end

--[[---------------------------------------------------------
   Name: RemoveLine
-----------------------------------------------------------]]
function PANEL:RemoveLine( LineID )

	local Line = self:GetLine( LineID )
	local SelectedID = self:GetSortedID( LineID )

	self.Lines[ LineID ] = nil
	table.remove( self.Sorted, SelectedID )

	self:SetDirty( true )
	self:InvalidateLayout()

	Line:Remove()

end

--[[---------------------------------------------------------
   Name: ColumnWidth
-----------------------------------------------------------]]
function PANEL:ColumnWidth( i )

	local ctrl = self.Columns[ i ]
	if ( !ctrl ) then return 0 end

	return ctrl:GetWide()

end

--[[---------------------------------------------------------
   Name: FixColumnsLayout
-----------------------------------------------------------]]
function PANEL:FixColumnsLayout()

	local NumColumns = #self.Columns
	if ( NumColumns == 0 ) then return end

	local AllWidth = 0
	for k, Column in pairs( self.Columns ) do
		AllWidth = AllWidth + Column:GetWide()
	end
	
	local ChangeRequired = self.pnlCanvas:GetWide() - AllWidth
	local ChangePerColumn = math.floor( ChangeRequired / NumColumns )
	local Remainder = ChangeRequired - (ChangePerColumn * NumColumns)
	
	for k, Column in pairs( self.Columns ) do

		local TargetWidth = Column:GetWide() + ChangePerColumn
		Remainder = Remainder + ( TargetWidth - Column:SetWidth( TargetWidth ) )
	
	end
	
	-- If there's a remainder, try to palm it off on the other panels, equally
	while ( Remainder != 0 ) do

		local PerPanel = math.floor( Remainder / NumColumns )
		
		for k, Column in pairs( self.Columns ) do
	
			Remainder = math.Approach( Remainder, 0, PerPanel )
			
			local TargetWidth = Column:GetWide() + PerPanel
			Remainder = Remainder + (TargetWidth - Column:SetWidth( TargetWidth ))
			
			if ( Remainder == 0 ) then break end
		
		end
		
		Remainder = math.Approach( Remainder, 0, 1 )
	
	end

	-- Set the positions of the resized columns
	local x = 0
	for k, Column in pairs( self.Columns ) do
	
		Column.x = x
		x = x + Column:GetWide()
		
		Column:SetTall( self:GetHeaderHeight() )
		Column:SetVisible( !self:GetHideHeaders() )
	
	end

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	-- Do Scrollbar
	local Wide = self:GetWide()
	local YPos = 0
	
	if ( IsValid( self.VBar ) ) then
	
		self.VBar:SetPos( self:GetWide() - 16, 0 )
		self.VBar:SetSize( 16, self:GetTall() )
		self.VBar:SetUp( self.VBar:GetTall() - self:GetHeaderHeight(), self.pnlCanvas:GetTall() )
		YPos = self.VBar:GetOffset()

		if ( self.VBar.Enabled ) then Wide = Wide - 16 end
	
	end

	if ( self.m_bHideHeaders ) then
		self.pnlCanvas:SetPos( 0, YPos )
	else
		self.pnlCanvas:SetPos( 0, YPos + self:GetHeaderHeight() )
	end

	self.pnlCanvas:SetSize( Wide, self.pnlCanvas:GetTall() )

	self:FixColumnsLayout()

	--
	-- If the data is dirty, re-layout
	--
	if ( self:GetDirty( true ) ) then
	
		self:SetDirty( false )
		local y = self:DataLayout()
		self.pnlCanvas:SetTall( y )
		
		-- Layout again, since stuff has changed..
		self:InvalidateLayout( true )
	
	end

end

--[[---------------------------------------------------------
   Name: OnScrollbarAppear
-----------------------------------------------------------]]
function PANEL:OnScrollbarAppear()

	self:SetDirty( true )
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: OnRequestResize
-----------------------------------------------------------]]
function PANEL:OnRequestResize( SizingColumn, iSize )
	
	-- Find the column to the right of this one
	local Passed = false
	local RightColumn = nil
	for k, Column in ipairs( self.Columns ) do
	
		if ( Passed ) then
			RightColumn = Column
			break
		end
	
		if ( SizingColumn == Column ) then Passed = true end
	
	end
	
	-- Alter the size of the column on the right too, slightly
	if ( RightColumn ) then
	
		local SizeChange = SizingColumn:GetWide() - iSize
		RightColumn:SetWide( RightColumn:GetWide() + SizeChange )
		
	end
	
	SizingColumn:SetWide( iSize )
	self:SetDirty( true )
	
	-- Invalidating will munge all the columns about and make it right
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: DataLayout
-----------------------------------------------------------]]
function PANEL:DataLayout()

	local y = 0
	local h = self.m_iDataHeight
	
	for k, Line in ipairs( self.Sorted ) do
	
		Line:SetPos( 1, y )
		Line:SetSize( self:GetWide()-2, h )
		Line:DataLayout( self ) 
		
		Line:SetAltLine( k % 2 == 1 )
		
		y = y + Line:GetTall()
	
	end
	
	return y

end

--[[---------------------------------------------------------
   Name: AddLine - returns the line number.
-----------------------------------------------------------]]
function PANEL:AddLine( ... )

	self:SetDirty( true )
	self:InvalidateLayout()

	local Line = vgui.Create( "DListView_Line", self.pnlCanvas )
	local ID = table.insert( self.Lines, Line )

	Line:SetListView( self ) 
	Line:SetID( ID )

	-- This assures that there will be an entry for every column
	for k, v in pairs( self.Columns ) do
		Line:SetColumnText( k, "" )
	end

	for k, v in pairs( {...} ) do
		Line:SetColumnText( k, v )
	end

	-- Make appear at the bottom of the sorted list
	local SortID = table.insert( self.Sorted, Line )
	
	if ( SortID % 2 == 1 ) then
		Line:SetAltLine( true )
	end

	return Line

end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:OnMouseWheeled( dlta )

	if ( !IsValid( self.VBar ) ) then return end
	
	return self.VBar:OnMouseWheeled( dlta )

end

--[[---------------------------------------------------------
   Name: OnMouseWheeled
-----------------------------------------------------------]]
function PANEL:ClearSelection( dlta )

	for k, Line in pairs( self.Lines ) do
		Line:SetSelected( false )
	end

end

--[[---------------------------------------------------------
   Name: GetSelectedLine
-----------------------------------------------------------]]
function PANEL:GetSelectedLine()

	for k, Line in pairs( self.Lines ) do
		if ( Line:IsSelected() ) then return k end
	end

end

--[[---------------------------------------------------------
   Name: GetLine
-----------------------------------------------------------]]
function PANEL:GetLine( id )

	return self.Lines[ id ]

end

--[[---------------------------------------------------------
   Name: GetSortedID
-----------------------------------------------------------]]
function PANEL:GetSortedID( line )

	for k, v in pairs( self.Sorted ) do
	
		if ( v:GetID() == line ) then return k end
	
	end

end

--[[---------------------------------------------------------
   Name: OnClickLine
-----------------------------------------------------------]]
function PANEL:OnClickLine( Line, bClear )

	local bMultiSelect = self.m_bMultiSelect
	if ( !bMultiSelect && !bClear ) then return end

	--
	-- Control, multi select
	--
	if ( bMultiSelect && input.IsKeyDown( KEY_LCONTROL ) ) then
		bClear = false
	end

	--
	-- Shift block select
	--
	if ( bMultiSelect && input.IsKeyDown( KEY_LSHIFT ) ) then
	
		local Selected = self:GetSortedID( self:GetSelectedLine() )
		if ( Selected ) then
		
			if ( bClear ) then self:ClearSelection() end
			
			local LineID = self:GetSortedID( Line:GetID() )
		
			local First = math.min( Selected, LineID )
			local Last = math.max( Selected, LineID )
			
			for id = First, Last do
			
				local line = self.Sorted[ id ]
				line:SetSelected( true )
			
			end
		
			return
		
		end
		
	end

	--
	-- Check for double click
	--
	if ( Line:IsSelected() && Line.m_fClickTime && (!bMultiSelect || bClear) ) then 
	
		local fTimeDistance = SysTime() - Line.m_fClickTime

		if ( fTimeDistance < 0.3 ) then
			self:DoDoubleClick( Line:GetID(), Line )
			return
		end
	
	end

	--
	-- If it's a new mouse click, or this isn't 
	--  multiselect we clear the selection
	--
	if ( !bMultiSelect || bClear ) then
		self:ClearSelection()
	end

	if ( Line:IsSelected() ) then return end

	Line:SetSelected( true )
	Line.m_fClickTime = SysTime()
	
	self:OnRowSelected( Line:GetID(), Line )

end

function PANEL:SortByColumns( c1, d1, c2, d2, c3, d3, c4, d4 )

	table.Copy( self.Sorted, self.Lines )
	
	table.sort( self.Sorted, function( a, b ) 

			if (!IsValid( a )) then return true end
			if (!IsValid( b )) then return false end
			
			if ( c1 && a:GetColumnText( c1 ) != b:GetColumnText( c1 ) ) then
				if ( d1 ) then a, b = b, a end
				return a:GetColumnText( c1 ) < b:GetColumnText( c1 )
			end
			
			if ( c2 && a:GetColumnText( c2 ) != b:GetColumnText( c2 ) ) then
				if ( d2 ) then a, b = b, a end
				return a:GetColumnText( c2 ) < b:GetColumnText( c2 )
			end
				
			if ( c3 && a:GetColumnText( c3 ) != b:GetColumnText( c3 ) ) then
				if ( d3 ) then a, b = b, a end
				return a:GetColumnText( c3 ) < b:GetColumnText( c3 )
			end
			
			if ( c4 && a:GetColumnText( c4 ) != b:GetColumnText( c4 ) ) then
				if ( d4 ) then a, b = b, a end
				return a:GetColumnText( c4 ) < b:GetColumnText( c4 )
			end
			
			return true
	end )

	self:SetDirty( true )
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: SortByColumn
-----------------------------------------------------------]]
function PANEL:SortByColumn( ColumnID, Desc )
	
	table.Copy( self.Sorted, self.Lines )
	
	table.sort( self.Sorted, function( a, b ) 

		if ( Desc ) then
			a, b = b, a
		end
		
		local aval = a:GetSortValue( ColumnID ) and a:GetSortValue( ColumnID ) or a:GetColumnText( ColumnID )
		local bval = b:GetSortValue( ColumnID ) and b:GetSortValue( ColumnID ) or b:GetColumnText( ColumnID )

		return aval < bval

	end )

	self:SetDirty( true )
	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: SelectFirstItem
   Selects the first item based on sort..
-----------------------------------------------------------]]
function PANEL:SelectItem( Item )

	if ( !Item ) then return end

	Item:SetSelected( true )
	self:OnRowSelected( Item:GetID(), Item )

end

--[[---------------------------------------------------------
   Name: SelectFirstItem
   Selects the first item based on sort..
-----------------------------------------------------------]]
function PANEL:SelectFirstItem()

	self:ClearSelection()
	self:SelectItem( self.Sorted[ 1 ] )

end

--[[---------------------------------------------------------
   Name: DoDoubleClick
-----------------------------------------------------------]]
function PANEL:DoDoubleClick( LineID, Line )

	-- For Override

end

--[[---------------------------------------------------------
   Name: OnRowSelected
-----------------------------------------------------------]]
function PANEL:OnRowSelected( LineID, Line )

	-- For Override

end

--[[---------------------------------------------------------
   Name: OnRowRightClick
-----------------------------------------------------------]]
function PANEL:OnRowRightClick( LineID, Line )

	-- For Override

end

--[[---------------------------------------------------------
   Name: Clear
-----------------------------------------------------------]]
function PANEL:Clear()

	for k, v in pairs( self.Lines ) do
		v:Remove()
	end

	self.Lines = {}
	self.Sorted = {}

	self:SetDirty( true )

end

--[[---------------------------------------------------------
   Name: GetSelected
-----------------------------------------------------------]]
function PANEL:GetSelected()

	local ret = {}

	for k, v in pairs( self.Lines ) do
		if ( v:IsLineSelected() ) then
			table.insert( ret, v )
		end
	end

	return ret

end

--[[---------------------------------------------------------
   Name: SizeToContents
-----------------------------------------------------------]]
function PANEL:SizeToContents( )

	self:SetHeight( self.pnlCanvas:GetTall() + self:GetHeaderHeight() )

end

--[[---------------------------------------------------------
   Name: GenerateExample
-----------------------------------------------------------]]
function PANEL:GenerateExample( ClassName, PropertySheet, Width, Height )

	local ctrl = vgui.Create( ClassName )
		
		local Col1 = ctrl:AddColumn( "Address" )
		local Col2 = ctrl:AddColumn( "Port" )
	
		Col2:SetMinWidth( 30 )
		Col2:SetMaxWidth( 30 )
	
		for i=1, 128 do
			ctrl:AddLine( "192.168.0."..i, "80" )
		end
		
		ctrl:SetSize( 300, 200 )
		
	PropertySheet:AddSheet( ClassName, ctrl, nil, true, true )

end

derma.DefineControl( "mDesignListView", "Data View", PANEL, "DPanel" )


/* VGUI: Snackbar */
local pnl

local math = math
local surface = surface
local draw = draw

local clrText = Color(200, 200, 200)
local clrButton = Color(255, 235, 59)
local clrFill = Color(50, 50, 50)
local font = "mDesignSnackbarText"
local TextSpace = 24

local queue = {}

surface.CreateFont("mDesignSnackbarText", {font = "Roboto Regular", size = 18, weight = 0})

local function GetTextWidth(text)
    surface.SetFont(font)
    local w, _ =  surface.GetTextSize(text)

    return w
end

local function CheckQueue()
    local Next = queue[1]

    if Next then
        ui.Notify(unpack(Next))
        table.remove(queue, 1)
    end
end

ui.Notify = function(text, duration, button_text, button_func, button_clr, text_clr)
    if pnl and IsValid(pnl) then table.insert(queue, {text, duration, button_text, button_func, button_clr}); return end
    if !text then return end

    pnl = vgui.Create("DPanel")

    duration = (duration and math.Max(duration, 1)) or 3

	pnl.clrText = text_clr
    pnl.TextToDraw = text
    pnl.ButtonText = button_text and button_text:upper()
    pnl.ButtonFunc = button_func
    pnl.ButtonClr = button_clr
    pnl.bClose = false
    pnl.EndTime = CurTime() + duration
    pnl.drawAlpha = 0

    pnl.animOpen = Derma_Anim("sb_Open", pnl, function(self, _, delta)
        local w, h = self:GetSize()
        local x = (ScrW() / 2) - (w / 2)
        local y = ScrH() - (h * delta) - 5

        self:SetPos(x, y)
        self.drawAlpha = 255 * delta
    end)

    pnl.animOpen:Start(0.3)

    pnl.animClose = Derma_Anim("sb_Close", pnl, function(self, _, delta)
        local w, h = self:GetSize()
        local x = (ScrW() / 2) - (w / 2)
        local y = ScrH() - h + (h * delta)

        self:SetPos(x, y)
        //self.drawAlpha = 255 - (255 * delta)

        if delta == 1 then
            self:Remove()
            CheckQueue()
        end
    end)

    pnl.Close = function(self)
        self.animClose:Start(0.3)

        self.bClose = true
    end

    local btn = vgui.Create("DButton", pnl)
    btn:SetText("")
    btn:SetTall(36)
    btn.Think = function(self)
        local text = pnl.ButtonText or ""
        local size = GetTextWidth(text)

        btn:SetPos(pnl:GetWide() - size - TextSpace, 0)
        btn:SetWide(size)
    end
    btn.DoClick = function(self)
        if pnl.ButtonFunc then
            pnl.ButtonFunc(pnl)
		elseif IsValid(pnl) then
			pnl:Close()
        end
    end
    btn.Paint = function(self, w, h)
        draw.SimpleText(pnl.ButtonText or "", font, w / 2, h / 2, pnl.ButtonClr or clrButton, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    pnl.Think = function(self)
        local w, h = (TextSpace * 2) + GetTextWidth(self.TextToDraw), 36

        if self.ButtonText then
            w = w + GetTextWidth(self.ButtonText) + (TextSpace * 2)
        end

        self:SetSize(w, h)

        self:SetDrawOnTop(true)

        if self.EndTime <= CurTime() and !self.bClose then
            self:Close()
        end

        if self.animClose:Active() then
            self.animClose:Run()
        end

        if self.animOpen:Active() then
            self.animOpen:Run()
        end
    end

    pnl.Paint = function(self, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(clrFill.r, clrFill.g, clrFill.b, self.drawAlpha))
        draw.SimpleText(self.TextToDraw, font, 24, h / 2, self.clrText or clrText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

ui.PlayNotifySound = function()
    surface.PlaySound("garrysmod/content_downloaded.wav")
end

net.Receive("mDesign_Notify", function()
	local tbl = net.ReadTable()
	
	ui.Notify(tbl.Text, tbl.Duration, tbl.ButtonText, _, tbl.ButtonColor, tbl.TextColor)
end)


/* VGUI: CheckBox */
local PANEL = {}

local mat = Material("mdesign/checkbox.png")
local matchecked = Material("mdesign/checkbox_checked.png")

ui.DownloadMaterial("http://i.imgur.com/FTRs5iF.png", function(m) mat = m end)
ui.DownloadMaterial("http://i.imgur.com/UxK4MJb.png", function(m) matchecked = m end)

function PANEL:Init()
	self:SetSize(18, 18)
	self:SetText("")
	self.mClr = Color(180, 180, 180)
	self.mClrChecked = Color(0, 200, 185)
end

function PANEL:SetColor(clr)
	self.mClr = clr
end

function PANEL:GetColor()
	return self.mClr
end

function PANEL:Paint(w, h)
	if self:GetChecked() then
		surface.SetDrawColor(self.mClrChecked)
		surface.SetMaterial(matchecked)
		surface.DrawTexturedRect(0, 0, w, h)
	else
		surface.SetDrawColor(self:GetColor())
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(0, 0, w, h)
	end
end

vgui.Register( "mDesignCheckBox", PANEL, "DCheckBox" )


/* VGUI: RoundedAvatar */
local PANEL = {}

local function DrawCircle(x, y, r, delta, color)
	local poly = {}
	local a = 220

	poly[1] = {x = x, y = y}

	for i = 0, a * delta + 0.5 do
		poly[i + 2] = {x = math.sin(-math.rad(i / a * 360)) * r + x, y = math.cos(-math.rad(i / a * 360)) * r + y}
	end

	draw.NoTexture()
	surface.SetDrawColor(color)
	surface.DrawPoly(poly)
end

function PANEL:GetBackgroundColor(clr)
	self.clrBackground = clr or Color(255, 255, 255)
end

function PANEL:SetBackgroundColor(clr)
	self.clrBackground = clr
end

function PANEL:PaintOver(w, h)
	render.ClearStencil()

	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
	render.SetStencilReferenceValue(1)

	DrawCircle(w / 2, h / 2, w / 2, 1, Color(0, 0, 0, 1))

	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilReferenceValue(0)

	surface.SetDrawColor(self.clrBackground or Color(255, 255, 255))
	surface.DrawRect(0, 0, w, h)

	render.SetStencilEnable(false)
end

vgui.Register("mDesignRoundedAvatar", PANEL, "AvatarImage")


end
