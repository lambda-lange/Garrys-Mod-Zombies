
SWEP.PrintName = "Barricade"
SWEP.Author = "Bot01"
SWEP.Instructions = ""
SWEP.Category = "Zombies"

SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Slot = 0
SWEP.SlotPos = 0

SWEP.Spawnable = true

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.ViewModelFOV = 54
SWEP.UseHands = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.DrawAmmo = false

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Barricades")
    self:NetworkVar("Angle", 1, "BarricadeAngle")
end

function SWEP:Initialize()
    self:SetHoldType("slam")
    if SERVER then
        self:SetBarricades(4)
    end
end

function SWEP:PrimaryAttack()
    if self:GetBarricades() > 0 then
        local ply = self:GetOwner()
        local trace = ply:GetEyeTrace()

        if trace.Hit and trace.HitPos:Distance(ply:GetPos()) <= 128 and trace.HitPos:Distance(ply:GetPos()) >= 48 then
            local hitEntity = trace.Entity
            local hitSurfaceNormal = trace.HitNormal

            if (hitEntity:IsWorld() or hitEntity:GetClass() == "zombies_barricade") and hitSurfaceNormal.z > 0.7 then
                if SERVER then
                    local pos = trace.HitPos
                    local ang = self:GetBarricadeAngle()
                    ang:RotateAroundAxis(ang:Right(), 0)

                    
                    local prop = ents.Create("zombies_barricade")
                    local offset = Vector(0, 0, 0) -- 0, 0, 20
                    prop:SetPos(pos + offset)
                    prop:SetAngles(ang)
                    prop:Spawn()

                    self.Owner:EmitSound("physics/wood/wood_solid_impact_soft".. math.random(1, 3).. ".wav", 55, math.random(90, 100), 0.5)

                    self:SetBarricades(self:GetBarricades() - 1)
                end
            end
        end
    end
    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Reload()
    self:SetBarricadeAngle(self:GetBarricadeAngle() + Angle(0, 1, 0) )
end

local mat = Material("zombies/ui/mouse_left.png")
local mat2 = Material("zombies/ui/key_r.png")
function SWEP:DrawHUD()
    local barricades = self:GetBarricades()
    
    if barricades > 0 then
        local ply = self:GetOwner()
        local trace = ply:GetEyeTrace()

        if trace.Hit and trace.HitPos:Distance(ply:GetPos()) <= 128 then
            if trace.HitPos:Distance(ply:GetPos()) >= 48 then
                local hitEntity = trace.Entity
                local hitSurfaceNormal = trace.HitNormal

                if (hitEntity:IsWorld() or hitEntity:GetClass() == "zombies_barricade") and hitSurfaceNormal.z > 0.7 then
                    local text = "[Place Barricades] ".. barricades.. "/4"
                    local text2 = "[Rotate]"
                    draw.SimpleText(text, "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                    draw.SimpleText(text2, "DisplayFontHUD", ScrW() / 2,  ScrH() - 42, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                    surface.SetFont("DisplayFontHUD")
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(mat)

                    local textWidth, _ = surface.GetTextSize(text)
                    local offsetX = ScrW() / 2 - (textWidth / 2) - 24
                    surface.DrawTexturedRect(offsetX, ScrH() - 32, 24, 24)

                    surface.SetMaterial(mat2)
                    local textWidth, _ = surface.GetTextSize(text2)
                    local offsetX = ScrW() / 2 - (textWidth / 2) - 24
                    surface.DrawTexturedRect(offsetX, ScrH() - 64, 24, 24)

                    local pos = trace.HitPos
                    local ang = self:GetBarricadeAngle()
                    ang:RotateAroundAxis(ang:Right(), 0)

                    if not IsValid(self.CSModel) then
                        self.CSModel = ClientsideModel("models/props_c17/concrete_barrier001a.mdl")
                        self.CSModel:SetNoDraw(true)
                        self.CSModel:SetMaterial("models/wireframe")
                    end

                    local offset = Vector(0, 0, 0) -- 0, 0, 20
                    self.CSModel:SetPos(pos + offset)
                    self.CSModel:SetAngles(ang)

                    cam.Start3D()
                        self.CSModel:DrawModel()
                    cam.End3D()
                else
                    draw.SimpleText("You can only place a barricade on the floor", "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, Color(225, 225, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
                end
            else
                draw.SimpleText("Too close", "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, Color(225, 225, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
        else
            draw.SimpleText("Look at the floor to place a barricade", "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, Color(225, 225, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
    else
        draw.SimpleText("Out Of Barricades", "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
end

function SWEP:OnRemove()
    if IsValid(self.CSModel) then
        self.CSModel:Remove()
    end
end