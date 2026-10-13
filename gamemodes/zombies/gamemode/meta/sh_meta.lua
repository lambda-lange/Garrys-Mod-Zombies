local meta = FindMetaTable("Player")

function meta:IsZombie()
    if self:Team() == 2 then
        return true
    end
    return false
end

function meta:GetPoints()
    return tonumber(self:GetNWInt("player_points"))
end

function meta:GetXP()
    return self:GetNWInt("player_xp")
end

function meta:GetLevel()
    local baseXP = 1000
    local growthFactor = ZConfig.xpMultiplier or 1
    local xp = tonumber ( self:GetXP() )
    
    local level = 0
    while xp >= baseXP do
        xp = xp - baseXP
        baseXP = baseXP * growthFactor
        level = level + 1
    end
    
    local nextLevelXP = math.floor( baseXP )
    local xpObtained = math.floor( xp )
    
    return level, nextLevelXP, xpObtained
end

function meta:IsZombieClass(classid)
    if self:IsZombie() and self:GetZombieClass() == classid then
        return true
    end

    return false
end

function meta:IsHumanClass(classid)
    if !self:IsZombie() and self:GetHumanClass() == classid then
        return true
    end

    return false
end

function meta:GetCurrentClassName()
    if self:IsZombie() then
        local id = self:GetZombieClass()
        return ZConfig.classes.zombies[id].name
    else
        local id = self:GetHumanClass()
        return ZConfig.classes.humans[id].name
    end

    return "INVALID"
end


function meta:GetZombieClass()
    return tonumber(self:GetNWInt("player_class_zombie", 1))
end

function meta:GetHumanClass()
    return tonumber(self:GetNWInt("player_class_human", 1))
end

function meta:CanAfford(value)
    return self:GetPoints() >= value
end

function meta:HasBoughtWeapon(index)
    if SERVER then
        return self:GetPData("bought_weapon_" .. index)
    end
    if CLIENT then
        return table.HasValue(Bought_Weapons, index)
    end
end

function meta:SetMapVote(value)
    self:SetNWInt("map_vote", value)
end

function meta:GetMapVote()
    return self:GetNWInt("map_vote", 0)
end