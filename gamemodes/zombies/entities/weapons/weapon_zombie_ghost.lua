AddCSLuaFile()

SWEP.Base = "weapon_zombie_base"
SWEP.PrintName = "Zombie Ghost"
SWEP.Spawnable = true

SWEP.HitDistance = 60
SWEP.Damage = 20

SWEP.Cooldown = 10

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if SERVER then
        owner:EmitSound("npc/headcrab_poison/ph_scream".. math.random(1, 3).. ".wav", 75, math.random(70, 80), 1)
    end
    self:SetNextSecondaryFire( CurTime() + self.Cooldown )
end

local mat = Material("zombies/ui/mouse_right.png")
function SWEP:DrawHUD()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    local cooldown = math.Round(self:GetNextSecondaryFire() - CurTime())
    if cooldown > 0 then
        draw.SimpleText(cooldown, "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    else
        local text = "[Scream]"
        draw.SimpleText(text, "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        surface.SetFont("DisplayFontHUD")
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(ScrW() / 2 - ( surface.GetTextSize(text) - 16), ScrH() - 32, 24, 24)
    end
end