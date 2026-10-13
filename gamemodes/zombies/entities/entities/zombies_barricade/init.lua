AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/props_c17/concrete_barrier001a.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

    self:EmitSound("physics/wood/wood_solid_impact_soft2.wav")

    self:SetHealth(200) -- base
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    local attacker = dmginfo:GetAttacker()

    if !attacker:IsZombie() then
        damage = damage / 8
    end

    self:EmitSound("physics/concrete/rock_impact_hard".. math.random(1, 6).. ".wav", 75, math.random(80, 100), 0.8)

    local newHealth = self:Health() - damage
    self:SetHealth(newHealth)

    if self:Health() <= 0 then
        self:EmitSound("physics/concrete/boulder_impact_hard".. math.random(1, 3).. ".wav", 85, math.random(80, 100), 0.8)
        self:Remove()
    end
end