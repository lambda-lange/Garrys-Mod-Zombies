local mat_overview = Material("zombies/ui/humans.png")
local mat_zombiec = Material("zombies/ui/death.png")

hook.Add("HUDPaint", "ZombiesBaseHud", function()
    local client = LocalPlayer()
    if !IsValid(client) then return end
    --if !GetGlobalBool( "Round_Status" ) then return end
    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) then
        local ammoType = weapon:GetPrimaryAmmoType()
        if client:GetAmmoCount(ammoType) > 0 or weapon:Clip1() > 0 then
            local ammo = weapon:Clip1().. "/".. weapon:GetMaxClip1()
            if weapon:Clip1() ~= -1 then
                draw.SimpleTextOutlined(ammo, "ZombiesFontTitle", ScrW() - 16, ScrH() - 16, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
            end
        end
    end

    local maxHealth = client:GetMaxHealth()
    local health = math.Clamp(client:Health(), 0, maxHealth)
    
    client.lerpHealth = client.lerpHealth or health
    client.lerpHealth = Lerp(FrameTime() * 5, client.lerpHealth, health)
    
    local barWidth = 240
    local barHeight = 16
    local barX = 16 -- ScrW() / 2 - barWidth / 2
    local barY = ScrH() - 32
    
    surface.SetDrawColor(50, 50, 50, 155)
    surface.DrawRect(barX, barY, barWidth, barHeight)
    
    local healthLerp = math.Clamp( (client.lerpHealth / maxHealth) * barWidth, 0, barWidth)
	local healthWidth = (health / maxHealth) * barWidth
    surface.SetDrawColor(255, 0, 0, 255)
    surface.DrawRect(barX, barY, healthLerp, barHeight)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawRect(barX, barY, healthWidth, barHeight)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(barX, barY, barWidth, barHeight)
    
    draw.SimpleTextOutlined(math.ceil(health) .. " / " .. maxHealth, "ZombiesFontTitle", barX + 2, barY - 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))

    if GetGlobalInt("Round_PrepTime") ~= 0 then
        local time = string.FormattedTime( GetGlobalInt("Round_PrepTime"), "%01i:%02i" )
        local prep_color = Color(255, 255, 255)
        if GetGlobalInt("Round_PrepTime") <= 3 then
            prep_color = Color(255, 0, 0)
        end
        draw.SimpleTextOutlined(time, "ZombiesFontTimer", ScrW() / 2, 8, prep_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Preparation", "ZombiesFontTitle", ScrW() / 2, 48, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
    else
        if GetGlobalInt("Round_Time") ~= 0 then
            local time = string.FormattedTime( GetGlobalInt("Round_Time"), "%01i:%02i" )
            local round_color = Color(255, 255, 255)
            if GetGlobalInt("Round_Time") <= 10 then
                round_color = Color(255, 0, 0)
            end
            draw.SimpleTextOutlined(time, "ZombiesFontTimer", ScrW() / 2, 8, round_color, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
            draw.SimpleTextOutlined("Round ".. tostring(GetGlobalInt("Round_Count") + 1), "ZombiesFontTitle", ScrW() / 2, 48, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

            local humans = GetHumanCount()
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(mat_overview)
            surface.DrawTexturedRect(ScrW() / 2 - 80, 17, 24, 24)
            draw.SimpleTextOutlined(humans, "ZombiesFontTitle", ScrW() / 2 - 88, 17, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))

            local zombies = GetZombieCount()
            surface.SetMaterial(mat_zombiec)
            surface.DrawTexturedRect(ScrW() / 2 + 56, 17, 24, 24)
            draw.SimpleTextOutlined(zombies, "ZombiesFontTitle", ScrW() / 2 + 88, 17, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, Color(0, 0, 0))
        end
    end

    if !client:IsZombie() then
        local sweps = client:GetWeapons()
        local activeWeapon = client:GetActiveWeapon()

        surface.SetFont("ZombiesFontTitle")

        local x, y = 10, ScrH() / 2 - (#sweps * 30 / 2)

        for id, weapon in ipairs(sweps) do
            local weaponName = weapon:GetPrintName() or "Invalid"

            if weapon == activeWeapon then
                surface.SetTextColor(255, 255, 255, 255)
            else
                surface.SetTextColor(155, 155, 155, 255)
            end
            local textWidth, textHeight = surface.GetTextSize(weaponName)

            surface.SetTextPos(x, y)
            surface.DrawText(id.. " ".. weaponName)

            y = y + textHeight + 5
        end
    end

    if player.GetCount() < 2 then
        draw.SimpleText("Waiting for another player...", "DisplayFontHUD", ScrW() / 2, ScrH() / 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    draw.SimpleText("Zombies (Alpha Version 2024)", "DisplayFontHUD", ScrW() - 4, 4, Color(255, 255, 255, 55), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText("ver.".. ZConfig.version, "DisplayFontHUD", ScrW() - 4, 28, Color(255, 255, 255, 55), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    /*
    draw.SimpleText("You will eventually lose your progress as development is ongoing", "DisplayFontHUD", ScrW() - 4, 28, Color(255, 255, 255, 55), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    draw.SimpleText("ver.".. ZConfig.version, "DisplayFontHUD", ScrW() - 4, 52, Color(255, 255, 255, 55), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP) -- height 52
    */

    draw.SimpleText("Press F2 for the shop.", "DisplayFontHUD", 4, 4, Color(255, 255, 255, 55), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    // DEV
    if LocalPlayer():IsAdmin() then
        draw.SimpleTextOutlined("Dev Stuff", "ZombiesFontTitle", ScrW() - 16, ScrH() - 256 - 32, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Ping: " .. LocalPlayer():Ping(), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("FT: " .. ( 1 / FrameTime() ), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 + 16, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Speed: " .. LocalPlayer():GetWalkSpeed(), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 16, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Max Health: " .. LocalPlayer():GetMaxHealth(), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 32, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Human Class index: " .. LocalPlayer():GetHumanClass(), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 48, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Zombie Class Index: " .. LocalPlayer():GetZombieClass(), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 64, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Is Zombie: " .. tostring(LocalPlayer():IsZombie()), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 64 - 16, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Weapon Prim Index: " .. tostring(LocalPlayer():GetPData("primary_weapon_index", "not valid")), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 64 - 32, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Weapon Seco Index: " .. tostring(LocalPlayer():GetPData("secondary_weapon_index", "not valid")), "ZombiesFontTitle", ScrW() - 16, ScrH() - 128 - 64 - 48, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
        draw.SimpleTextOutlined("Round Active: " .. tostring(GetGlobalBool( "Round_Status" )), "ZombiesFontTitle", ScrW() - 16, ScrH() - 256, Color(155, 155, 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, Color(0, 0, 0))
    end
end)

local hideDefault = {
	["CHudHealth"] = true,
	["CHudAmmo"] = true,
    ["CHudBattery"] = true,
    ["CHudDamageIndicator"] = true,
    ["CHudSecondaryAmmo"] = true,
    ["CHudZoom"] = true,
    ["CHUDQuickInfo"] = true,
    ["CHudDeathNotice"] = true,
    ["CHudWeaponSelection"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hideDefault[ name ] ) then
		return false
	end
end )