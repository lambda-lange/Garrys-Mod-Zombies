include("shared.lua")

local maxDistance = 800
local fadeDistance = 600
local vectorpos = Vector(0, 0, 25)

surface.CreateFont( "EntityDisplayFont", { font = "Roboto", extended = false, size = 24, weight = 1500 } )
function ENT:Draw()
    self:DrawModel()
    
    local ply = LocalPlayer()
    local distance = LocalPlayer():GetPos():Distance(self:GetPos())

    if (distance < maxDistance) then 
        local offset = vectorpos
        local ang = LocalPlayer():EyeAngles()
        local pos = self:GetPos() + offset + ang:Up()

        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        local alpha = math.Clamp((fadeDistance - distance) / fadeDistance * 255, 0, 255)

        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.25)
            cam.IgnoreZ(true)  -- Ignore depth buffer to draw text on top
            local health = self:Health() or 0
            local healthp = ( health / 200 ) * 100
            if ply:IsZombie() then
                draw.SimpleTextOutlined(healthp.. "%", "EntityDisplayFont", 0, 0, Color(255, 55, 55, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
            else
                draw.SimpleTextOutlined(healthp.. "%", "EntityDisplayFont", 0, 0, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, alpha))
            end
            cam.IgnoreZ(false)  -- Re-enable depth buffer
        cam.End3D2D()
    end
end