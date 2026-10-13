hook.Add("PlayerSpawn", "SetPlayerRenderSkelleton", function( client )
    if client:IsZombieClass(5) then
        client:SetRenderMode(RENDERMODE_TRANSALPHA)
        client:SetColor(Color(255, 255, 255, 70))
    else
        client:SetRenderMode(RENDERMODE_NORMAL)
    end
end)

hook.Add("PlayerSpawn", "PlayerSpawnProtectionNoDraw", function( client )
    client:SetNoDraw(true)
    timer.Simple(1, function()
        if IsValid(client) then
            client:SetNoDraw(false)
        end
    end)
end)

hook.Add( "PlayerFootstep", "CustomFootstep", function( ply, pos, foot, sound, volume, rf )
    if ply:IsZombie() then
        if SERVER then
            ply:EmitSound( "npc/zombie/foot".. math.random(1, 3).. ".wav", 80, math.random(80, 100), 0.4, CHAN_BODY )
        end
        return true
    end
end )

hook.Add( "PostCleanupMap", "RemoveAllMapDoors", function()
    RemoveAllMapDoors()
end )