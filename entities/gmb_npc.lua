AddCSLuaFile()
ENT.Base = "base_ai"
ENT.Type = "ai"
ENT.AutomaticFrameAdvance = true
ENT.Model = "models/gman_high.mdl"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Gamble"

function ENT:Initialize()
	if SERVER then
		self:SetModel(GAMBLE.CFG.GetValue("npc_model") or self.Model)
		self:SetHullType(HULL_HUMAN)
		self:SetHullSizeNormal( )
		self:SetNPCState(NPC_STATE_SCRIPT)
		self:SetSolid(SOLID_BBOX)
		self:CapabilitiesAdd( bit.bor(CAP_ANIMATEDFACE, CAP_TURN_HEAD))
		self:SetUseType(SIMPLE_USE)
		self:DropToFloor()
		self:SetMaxYawSpeed(90)
	end
end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end

if CLIENT then
	surface.CreateFont("gmb_npc_title", {font = "Roboto", size = 80})
end

function ENT:Draw()
	self:DrawModel()

	local ang = self:GetAngles()
	local offset = self:GetUp() * 80

	ang:RotateAroundAxis(self:GetUp(), 90)
	ang:RotateAroundAxis(self:GetRight(), -90)

	cam.Start3D2D(self:GetPos() + offset, ang, 0.1)
		local pos = 15 * math.cos(CurTime() * 2)
		draw.SimpleText(GAMBLE.CONFIG.npc_name or "Casino Employee", "gmb_npc_title", 0, pos + 1, Color(0, 0, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(GAMBLE.CONFIG.npc_name or "Casino Employee", "gmb_npc_title", 0, pos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end

function ENT:AcceptInput(inp, ply)
	if inp != "Use" then return end
	ply:SendLua("GAMBLE.ClientMenu()")
end

if SERVER then
	local function LoadNPCs()
		local content = file.Read("gamble/npc.dat") or "{}"
		for k, v in ipairs(ents.GetAll()) do
			if v:GetClass() == "gmb_npc" then
				v:Remove()
			end
		end
		for k, v in ipairs(pon.decode(content)) do
			local ent = ents.Create("gmb_npc")
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
		end
	end
	concommand.Add("gamble_save_npc", function(ply)
		if !ply:IsSuperAdmin() then return end
		local temp = {}
		for k, v in ipairs(ents.GetAll()) do
			if v:GetClass() == "gmb_npc" then
				table.insert(temp, {pos = v:GetPos(), ang = v:GetAngles()})
			end
		end
		file.Write("gamble/npc.dat", pon.encode(temp))
		LoadNPCs()
		ply:ChatPrint("[GAMBLE] NPC: Saved " .. #temp .. " NPCs.")
	end)
	concommand.Add("gamble_remove_npc", function(ply)
		if !ply:IsSuperAdmin() then return end
		for k, v in ipairs(ents.GetAll()) do
			if v:GetClass() == "gmb_npc" then
				v:Remove()
			end
		end
		file.Write("gamble/npc.dat", "{}")
		ply:ChatPrint("[GAMBLE] NPC: Deleted.")
	end)
	hook.Add("InitPostEntity", "gamble_npc_create", function()
		LoadNPCs()
	end)
end