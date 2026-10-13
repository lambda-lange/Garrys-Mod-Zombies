local vectorpos = Vector(0, 0, 85)
local maxDistance = 800
local function DrawName(ply)
    if (!IsValid(ply)) then return end
    if (ply == LocalPlayer()) then return end
    if (!ply:Alive() or !LocalPlayer():Alive()) then return end

    //disable for ghost
    if ply:IsZombieClass(5) then return end

    local distance = LocalPlayer():GetPos():Distance(ply:GetPos())

    if (distance < maxDistance) then 
        local offset = vectorpos
        local ang = LocalPlayer():EyeAngles()
        local pos = ply:GetPos() + offset + ang:Up()

        ang:RotateAroundAxis(ang:Forward(), 90)
        ang:RotateAroundAxis(ang:Right(), 90)

        local alpha = math.Clamp((maxDistance - distance) / maxDistance * 255, 0, 255)

        cam.Start3D2D(pos, Angle(0, ang.y, 90), 0.25)
            if !LocalPlayer():IsZombie() and ply:IsZombie() then
                local health = (ply:Health() / ply:GetMaxHealth()) * 128
                surface.SetDrawColor(75, 75, 75, 155)
                surface.DrawRect(-64, 32, 128, 8)
                surface.SetDrawColor(255, 0, 0, 255)
                surface.DrawRect(-64, 32, health, 8)
                surface.SetDrawColor(0, 0, 0, 255)
                surface.DrawOutlinedRect(-64, 32, 128, 8, 1)
            end


            if (!ply:IsZombie() and !LocalPlayer():IsZombie()) or (ply:IsZombie() and LocalPlayer():IsZombie()) then
                surface.SetFont("DisplayFontHeader")
                local textWidth = surface.GetTextSize(ply:GetName())
                draw.RoundedBox(8, 0 - textWidth / 2 - 8, 0, textWidth + 16, 32, Color(0, 0, 0, alpha * 0.1))
                draw.DrawText(ply:GetName(), "DisplayFontHeader", 2, 2, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
                local health = ( ply:Health() / ply:GetMaxHealth() ) * 100
                draw.SimpleTextOutlined(health.. "%", "DisplayFontHeader", 2, -30, Color(55, 255, 55, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, alpha))
            end
        cam.End3D2D()
    end
end
hook.Add("PostPlayerDraw", "DrawName", DrawName)

local mat_spawn = Material("zombies/ui/zombiespawn.png")
hook.Add("HUDPaint", "DrawMainSpawnPosInformation", function()
    if LocalPlayer():IsZombie() then return end -- !GetGlobalBool("Round_Status")
    local spawn = GetGlobalVector("MainSpawn")
    if spawn then
        local distance = spawn:Distance(LocalPlayer():GetPos())
        local textPos = spawn + Vector(0, 0, 50)
        local alpha = math.Clamp(255 - (distance - 800), 0, 155)
        local pos = textPos:ToScreen()
        draw.DrawText("Zombie Spawn", "DisplayFontTitle", pos.x, pos.y, Color(255, 55, 55, alpha), TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255, 55, 55, alpha)
        surface.SetMaterial(mat_spawn)
        surface.DrawTexturedRect(pos.x - 16, pos.y - 32, 32, 32)
    end
end)