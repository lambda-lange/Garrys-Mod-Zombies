
SWEP.PrintName = "Proximity Mine"
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
    self:NetworkVar("Int", 0, "Mines")
end

function SWEP:Initialize()
    self:SetHoldType("slam")
    if SERVER then
        self:SetMines(8)
    end
end

function SWEP:PrimaryAttack()
    if self:GetMines() > 0 then
        local ply = self:GetOwner()
        local trace = ply:GetEyeTrace()

        if trace.Hit and trace.HitPos:Distance(ply:GetPos()) <= 100 then
            if SERVER then
                local pos = trace.HitPos
                local ang = trace.HitNormal:Angle()
                ang:RotateAroundAxis(ang:Right(), 270)

                local prop = ents.Create("zombies_mine")
                prop:SetPos(pos)
                prop:SetAngles(ang)
                prop:SetOwner(ply)
                prop:Spawn()

                self.Owner:EmitSound("physics/metal/metal_grenade_impact_soft".. math.random(1, 3).. ".wav", 55, math.random(90, 100), 0.5)

                self:SetMines(self:GetMines() - 1)
            end
        end
    end
    self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:Reload()
    return
end

local mat = Material("zombies/ui/mouse_left.png")
function SWEP:DrawHUD()
    local mines = self:GetMines()
    
    if mines > 0 then
        local ply = self:GetOwner()
        local trace = ply:GetEyeTrace()

        if trace.Hit and trace.HitPos:Distance(ply:GetPos()) <= 100 then
            local text = "[Place Mine] ".. mines.. "/8"
            draw.SimpleText(text, "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            surface.SetFont("DisplayFontHUD")
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(ScrW() / 2 - (surface.GetTextSize(text) - 48), ScrH() - 32, 24, 24)

            local pos = trace.HitPos
            local ang = trace.HitNormal:Angle()
            ang:RotateAroundAxis(ang:Right(), 270)

            if not IsValid(self.CSModel) then
                self.CSModel = ClientsideModel("models/props_combine/combine_mine01.mdl")
                self.CSModel:SetNoDraw(true)
                self.CSModel:SetMaterial("models/wireframe")
            end

            self.CSModel:SetPos(pos)
            self.CSModel:SetAngles(ang)

            cam.Start3D()
                self.CSModel:DrawModel()
            cam.End3D()
        else
            draw.SimpleText("Look at a surface to place a mine", "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, Color(225, 225, 225), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end
    else
        draw.SimpleText("Out Of Mines", "DisplayFontHUD", ScrW() / 2,  ScrH() - 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
    end
end

function SWEP:OnRemove()
    if IsValid(self.CSModel) then
        self.CSModel:Remove()
    end
end