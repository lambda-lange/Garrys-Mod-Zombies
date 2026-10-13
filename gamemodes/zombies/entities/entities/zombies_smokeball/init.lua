AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
    self:SetModel( "models/weapons/w_bugbait.mdl" )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:SetInitialVelocity(direction, force)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        local forceVector = direction * force
        phys:ApplyForceCenter(forceVector)
    end
end

function ENT:PhysicsCollide()
    if self:IsValid() then
        self:PopSmoke()
    end
    self:Remove()
end

function ENT:PopSmoke()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    util.Effect("effect_zombiesmoke", effectdata)

    if SERVER then
        self:EmitSound("physics/flesh/flesh_squishy_impact_hard" .. math.random(1, 4) .. ".wav", 60, math.random(90, 110), 0.8)

        local owner = self:GetOwner()
        local entities = ents.FindInSphere(self:GetPos(), 110)
        for _, ent in ipairs(entities) do
            if ent:IsPlayer() then
                if !ent:IsZombie() then
                    ent:PoisonSmoke(owner)
                end
            end
        end
    end
end