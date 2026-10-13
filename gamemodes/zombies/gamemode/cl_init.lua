include("shared.lua")

// shit
include("config.lua")
include("meta/sh_meta.lua")

include("derma/cl_shop.lua")
include("derma/cl_stats.lua")
include("derma/cl_scoreboard.lua")
include("derma/cl_mapvote.lua")
include("derma/cl_reward.lua")

include("hud/cl_hud.lua")
include("hud/cl_3d2d.lua")
include("hud/cl_effects.lua")

include("hooks/sh_hooks.lua")
include("hooks/cl_hooks.lua")

surface.CreateFont( "DisplayFontStats", { font = "Roboto-Light", extended = false, size = 42, weight = 2500 } )
surface.CreateFont( "DisplayFontHUD", { font = "Roboto-Light", extended = false, size = 24, weight = 500, outline = false } )
surface.CreateFont( "DisplayFontTitle", { font = "Roboto-Light", extended = false, size = 32, weight = 500 } )
surface.CreateFont( "DisplayFontHeader", { font = "Roboto-Light", extended = false, size = 28, weight = 500 } )
surface.CreateFont( "DisplayFontText", { font = "Roboto-Light", extended = false, size = 16, weight = 1500 } )

// new fonts
surface.CreateFont( "ZombiesFontTimer", { font = "Roboto-Light", extended = false, size = 42, weight = 500 } )
surface.CreateFont( "ZombiesFontTitle", { font = "Roboto-Light", extended = false, size = 22, weight = 0 } )

mat_grad_center = Material("gui/center_gradient")
mat_grad_down = Material("vgui/gradient-d")
mat_grad = Material("gui/gradient")

sound_click = "zombies/ui/click.wav"
sound_hover = "zombies/ui/hover.wav"

local mat_hitmarker = Material("zombies/ui/hitmarker.png")
local mat_kill = Material("zombies/ui/kill.png")
local mat_zombie = Material("zombies/ui/zombie.png")

Bought_Weapons = {}

function GM:PostDrawViewModel( vm, ply, weapon )
	if ( weapon.UseHands || !weapon:IsScripted() ) then
		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end
	end
end

function GM:HUDDrawTargetID()
	return false
end

function GM:HUDDrawPickupHistory()
	return false
end

net.Receive( "NetOpenMenu", function()
    ShopMenu()
end )

net.Receive( "NetSyncBoughtWeapons", function()
    local weapons = net.ReadTable()
    print("printing synced weapons...")
    for _, data in ipairs(weapons) do
        if !table.HasValue(Bought_Weapons, data) then
            table.insert(Bought_Weapons, data)
        end
    end
end )

net.Receive( "NetSendText", function()
    local msg = net.ReadString()
    local prefix = net.ReadString()
    local color = net.ReadColor()
    chat.AddText( color, prefix.. " ", color_white, msg  )
    chat.PlaySound()
end )

net.Receive( "NetSendSound", function()
    local sound = net.ReadString()
    surface.PlaySound(sound)
end )

local lastDamageTime = 0
local damageDuration = 1
hook.Add("HUDPaint", "DrawDamageIndicator", function()
    local color = Color(255, 0, 0)
    local timeSinceDamage = CurTime() - lastDamageTime

    local alpha = 255 * math.max(0, (damageDuration - timeSinceDamage) / damageDuration)

    surface.SetDrawColor(color.r, color.g, color.b, alpha)
    surface.DrawOutlinedRect( 0, 0, ScrW(), ScrH(), 2 )
end)

net.Receive("NetPlayerTakeDamageIndicator", function()
    lastDamageTime = CurTime()
end)

local lastHitmarkerTime = 0
local hitDuration = 1
hook.Add("HUDPaint", "DrawHitmarkerIndicator", function()
    local timeSinceDamage = CurTime() - lastHitmarkerTime

    local alpha = 255 * math.max(0, (hitDuration - timeSinceDamage) / hitDuration)

    surface.SetDrawColor(255, 255, 255, alpha)
    surface.SetMaterial(mat_hitmarker)
    surface.DrawTexturedRect( ScrW() / 2 -16, ScrH() / 2 - 16, 32, 32 )
end)

net.Receive("NetPlayerDrawHitmarker", function()
    lastHitmarkerTime = CurTime()
end)

local gainedpoints = 0
local lastKillTime = 0
local KillDuration = 3
local killedPlayer
hook.Add("HUDPaint", "DrawNetPlayerDrawKillEffectIndicator", function()
    local timeSinceDamage = CurTime() - lastKillTime

    local alpha = 255 * math.max(0, (KillDuration - timeSinceDamage) / KillDuration)

    if IsValid(killedPlayer) then
        local text = "You Killed " .. killedPlayer:Nick().. " +".. gainedpoints.. "p"
        surface.SetFont("DisplayFontHUD")
        local textWidth, textHeight = surface.GetTextSize(text)
        local screenCenterX = ScrW() / 2
        local screenBottomY = ScrH() - 64

        draw.SimpleText(text, "DisplayFontHUD", screenCenterX, screenBottomY, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local iconSize = 32
        local iconX = screenCenterX - (textWidth / 2 + iconSize)
        local iconY = screenBottomY - (iconSize / 2)

        surface.SetDrawColor(255, 0, 0, alpha)
        surface.SetMaterial(mat_kill)
        surface.DrawTexturedRect(iconX, iconY, iconSize, iconSize)
    end
end)

net.Receive("NetPlayerDrawKillEffect", function()
    killedPlayer = net.ReadEntity()
    local points = net.ReadInt(16)
    gainedpoints = points or 0
    lastKillTime = CurTime()
end)