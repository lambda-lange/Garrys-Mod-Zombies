hook.Add( "PlayerDeathThink", "RespawnRestrictionHook", function( client )
    local state = GetGlobalBool( "Round_Status" )
    if timer.Exists("respawn_cooldown".. client:SteamID64() ) or !state then
        return false
    end
end )

hook.Add( "PlayerDeath", "PlayerExplodeOnDeath", function( client )
    if not IsValid(client) then return end
    
    if !client:IsZombieClass(6) then return end
    local sfx = EffectData()
    sfx:SetOrigin( client:GetPos() )
    util.Effect("effect_big_bloodcloud", sfx)
    client:EmitSound("ambient/explosions/explode_4.wav", 90, 60, 0.5)
    
    local radius = 180
    local damage = 40 
    
    for _, ent in pairs(ents.FindInSphere(client:GetPos(), radius)) do
        if ent:IsPlayer() or ent:IsNPC() then
            local dmg = DamageInfo()
            dmg:SetDamage(damage)
            dmg:SetAttacker(client)
            dmg:SetDamageType(DMG_BLAST)
            dmg:SetDamagePosition(ent:GetPos())
            ent:TakeDamageInfo(dmg)
        end
    end
end )