AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_mine01.mdl")
    self:SetMaterial("models/props_c17/frostedglass_01a")
    self:SetSolid(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)

    self:EmitSound("npc/roller/mine/combine_mine_deploy1.wav")

    self.NextCheck = CurTime() + 1
end

function ENT:Explode()
    if self:IsValid() then
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        util.Effect("Explosion", effectdata)

        if self:GetOwner() then
            util.BlastDamage(self, self:GetOwner(), self:GetPos(), 200, 300)
        end
    end
    
    self:Remove()
end

function ENT:Think()
    if self.NextCheck and self.NextCheck <= CurTime() then
        if not self.Triggered then
            for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 100)) do
                if IsValid(ent) and ent:IsPlayer() then
                    if ent:IsZombie() and ent:Alive() then
                        self.Triggered = true
                        self:Explode()
                        return
                    end
                end
            end
        end
        self.NextCheck = CurTime() + 1
    end
end