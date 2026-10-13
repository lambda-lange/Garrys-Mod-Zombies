AddCSLuaFile()

SWEP.Base = "weapon_zombie_base"
SWEP.PrintName = "Zombie Smoker"
SWEP.Spawnable = true

SWEP.HitDistance = 60
SWEP.Damage = 30

SWEP.Cooldown = 15

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if SERVER then
        local forward = owner:GetForward()
        local startPosition = owner:GetPos() + forward * 2 + Vector(0, 0, 56)
        local smoke = ents.Create( "zombies_smokeball" )
        smoke:SetPos( startPosition )
        smoke:Spawn()
        smoke:SetOwner(owner)
        smoke:SetInitialVelocity(forward, 1500)
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
        local text = "[Smoke]"
        draw.SimpleText(text, "DisplayFontHUD", ScrW() / 2, ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)

        surface.SetFont("DisplayFontHUD")
        surface.DrawTexturedRect(ScrW() / 2 - surface.GetTextSize(text) + 14, ScrH() - 32, 24, 24)
    end
end