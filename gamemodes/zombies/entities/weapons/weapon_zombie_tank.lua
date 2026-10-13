AddCSLuaFile()

SWEP.Base = "weapon_zombie_base"
SWEP.PrintName = "Zombie Tank"
SWEP.Spawnable = true

SWEP.HitDistance = 60
SWEP.Damage = 50

SWEP.Cooldown = 10
SWEP.DashRadius = 250
SWEP.DashForce = Vector(0, 0, 300)

function SWEP:TranslateActivity(act)
    self.ActivityTranslate[ACT_MP_STAND_IDLE] = ACT_HL2MP_IDLE_ZOMBIE
    self.ActivityTranslate[ACT_MP_WALK] = ACT_HL2MP_WALK_ZOMBIE_01
    self.ActivityTranslate[ACT_MP_RUN] = ACT_HL2MP_WALK_ZOMBIE_05
    self.ActivityTranslate[ACT_MP_CROUCH_IDLE] = ACT_HL2MP_IDLE_CROUCH_ZOMBIE
    self.ActivityTranslate[ACT_MP_CROUCHWALK] = ACT_HL2MP_WALK_CROUCH_ZOMBIE_01
    self.ActivityTranslate[ACT_MP_ATTACK_STAND_PRIMARYFIRE] = ACT_GMOD_GESTURE_RANGE_ZOMBIE
    self.ActivityTranslate[ACT_MP_ATTACK_CROUCH_PRIMARYFIRE] = ACT_GMOD_GESTURE_RANGE_ZOMBIE
    self.ActivityTranslate[ACT_MP_JUMP] = ACT_ZOMBIE_LEAPING
    self.ActivityTranslate[ACT_RANGE_ATTACK1] = ACT_GMOD_GESTURE_RANGE_ZOMBIE

    return self.ActivityTranslate[act] or -1
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local sfx = EffectData()
    sfx:SetOrigin( owner:GetPos() + Vector(0, 0, 16) )
    sfx:SetEntity( owner )
    sfx:SetScale(128)
    util.Effect("ThumperDust", sfx)

    if SERVER then
        owner:EmitSound("npc/env_headcrabcanister/launch.wav", 75, math.random(60, 70), 0.2)

        local entities = ents.FindInSphere(owner:GetPos(), self.DashRadius)
        for _, ent in ipairs(entities) do
            if ent:IsPlayer() and ent ~= owner then
                local direction = (ent:GetPos() - owner:GetPos()):GetNormalized()
                ent:SetVelocity(direction * 300 + self.DashForce)  -- Adjust the 300 for horizontal push as needed
            else
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    local direction = (ent:GetPos() - owner:GetPos()):GetNormalized()
                    phys:SetVelocity(direction * 300 + self.DashForce)
                end
            end
        end
    end

    self:SetNextSecondaryFire(CurTime() + self.Cooldown)
end

local mat = Material("zombies/ui/mouse_right.png")
function SWEP:DrawHUD()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local cooldown = math.Round(self:GetNextSecondaryFire() - CurTime())
    if cooldown > 0 then
        draw.SimpleText(cooldown, "DisplayFontHUD", ScrW() / 2, ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    else
        surface.SetFont("DisplayFontHUD")
        local text = "[Stun]"
        draw.SimpleText(text, "DisplayFontHUD", ScrW() / 2, ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(ScrW() / 2 - surface.GetTextSize(text), ScrH() - 32, 24, 24)
    end
end