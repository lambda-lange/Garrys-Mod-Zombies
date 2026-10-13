local meta = FindMetaTable("Player")

function meta:Info(msg, prefix, color)
    local msg = msg or "Invalid Message"
    local prefix = prefix or "[SERVER]"
    local color = color or Color(255, 0, 0)
    net.Start( "NetSendText" )
    net.WriteString( msg ) 
    net.WriteString( prefix ) 
    net.WriteColor( color )
    net.Send( self )
end

function meta:SetXP(value)
    self:SetNWInt("player_xp", value)
end

function meta:AddXP(value)
    local currentXP = self:GetXP()
    local currentLevel, _, _ = self:GetLevel()
    
    local newXP = currentXP + value
    self:SetXP(newXP)
    
    local newLevel, nextLevelXP, xpObtained = self:GetLevel()
    
    if newLevel > currentLevel then
        self:OnLevelUp(newLevel)
    end
end

function meta:OnLevelUp(newLevel)
    self:Info("Level up! New level: " .. newLevel, "[ZOMBIES]", Color(255, 128, 55))
end

function meta:SavePlayerData()
    local points = self:GetPoints()
    self:SetPData("player_points", points)

    local xp = self:GetXP()
    self:SetPData("player_xp", xp)

    local zombie = self:GetZombieClass()
    self:SetPData("player_class_zombie", zombie)

    local human = self:GetHumanClass()
    self:SetPData("player_class_human", human)

    self:SyncBoughtWeapons()
end

function meta:LoadPlayerData()
    local points = self:GetPData("player_points", 1000)
    self:SetPoints(points)

    local xp = self:GetPData("player_xp", 0)
    self:SetXP(xp)

    local zombie = self:GetPData("player_class_zombie", 1)
    self:SetNWInt("player_class_zombie", zombie)

    local human = self:GetPData("player_class_human", 1)
    self:SetNWInt("player_class_human", human)
end


function meta:PlaySound(sound)
    net.Start( "NetSendSound" )
    net.WriteString( sound ) 
    net.Send( self )
end

function meta:SetZombie(state)
    if state == true then
        self:SetTeam( 2 )
    elseif state == false then
        self:SetTeam( 1 )
    end
end

function meta:GiveLoadout()
    self:StripWeapons()
    self:RemoveAllAmmo()
    local primary = tonumber(self:GetPData("primary_weapon_index", 1))
    if primary then
        if ZConfig.shop.weapons[primary] then
            local wep_primary = ZConfig.shop.weapons[primary].swep
            self:Give(wep_primary)
        end
    end

    local secondary = tonumber(self:GetPData("secondary_weapon_index", 2))
    if secondary then
        if ZConfig.shop.weapons[secondary] then
            local wep_secondary = ZConfig.shop.weapons[secondary].swep
            self:Give(wep_secondary)
        end
    end
end

function meta:SetPoints(value)
    self:SetNWInt("player_points", math.Clamp(value, 0, 1000000)) -- 1 million max
end

function meta:AddPoints(value)
    self:SetPoints(self:GetNWInt("player_points") + value)
end

function meta:TakePoints(value)
    self:SetPoints(self:GetNWInt("player_points") - value)
end

function meta:GetRoundStatistics(data)
    return tonumber(self:GetNWInt("round_stats_".. data, 0))
end

function meta:AddRoundStatistics(data, value)
    self:SetNWInt("round_stats_".. data, self:GetRoundStatistics(data))
end

function meta:ResetRoundStatistics(data)
    self:SetNWInt("round_stats_".. data, 0)
end

function meta:SyncBoughtWeapons()
    local weapons = {}
    for index, data in pairs(ZConfig.shop.weapons) do
        if self:HasBoughtWeapon(index) then
            table.insert(weapons, index)
        end
    end
    net.Start("NetSyncBoughtWeapons")
    net.WriteTable(weapons)
    net.Send(self)
end

function meta:PoisonSmoke(attacker)
    if !attacker:IsPlayer() then return end

    local identifier = "zombie_damage_poison_".. attacker:SteamID64()
    if timer.Exists(identifier) then
        local reps = timer.RepsLeft(identifier) or 1
        print("reps left: ".. reps)
        timer.Adjust(identifier, 2, reps + 2, nil)
    else
        timer.Create(identifier, 4, 5, function()
            if IsValid(self) and IsValid(attacker) then
                if !self:IsZombie() then
                    self:TakeDamage(3, attacker)
                end
            end
        end)
    end
end

function meta:BuyWeapon(index)
    if not index or index < 1 or index > #ZConfig.shop.weapons then
        print("Invalid weapon index: ".. index)
        return
    end
    
    local weaponInfo = ZConfig.shop.weapons[index]
    
    if self:GetPoints() < weaponInfo.price and !weaponInfo.default then
        return
    end

    if self:HasBoughtWeapon(index) then
        return
    end  
    
    self:TakePoints(weaponInfo.price)
    self:SetPData("bought_weapon_" .. index, true)
    self:SyncBoughtWeapons()

    self:Info("Successfully bought: ".. weaponInfo.name, "[MARKET]", Color(55, 255, 55))
    self:PlaySound("zombies/shop.wav")
end

function meta:GiveDefaultItems()
    for index, data in ipairs(ZConfig.shop.weapons) do
        if data.default then
            self:BuyWeapon(index)
        end
    end
end

function meta:SetupClass()
    if GetGlobalBool( "Round_Status" ) then
        self:StripWeapons()
        self:SetZombie(true)
        
        local class_index = self:GetZombieClass()
        local class = ZConfig.classes.zombies[class_index]
        if class then
            self:SetWalkSpeed(class.speed)
            self:SetRunSpeed(class.speed)
            self:SetSlowWalkSpeed(class.speed)
            self:SetJumpPower(class.jump)
            if class.swep then
                self:Give(class.swep)
            end
            if class.model then
                self:SetModel(class.model)
            end
            if class.health then
                self:SetMaxHealth(class.health)
                self:SetHealth(class.health)
            else
                self:SetMaxHealth(100)
                self:SetHealth(100)
            end
        end
    else
        self:GiveLoadout()

        local class_index = self:GetHumanClass()
        local class = ZConfig.classes.humans[class_index]
        if class then
            self:SetWalkSpeed(class.speed)
            self:SetRunSpeed(class.speed)
            self:SetSlowWalkSpeed(class.speed)
            self:SetJumpPower(class.jump)
            if class.swep then
                self:Give(class.swep)
            end
            if class.model then
                self:SetModel(class.model)
            end
            if class.health then
                self:SetMaxHealth(class.health)
                self:SetHealth(class.health)
            else
                self:SetMaxHealth(100)
                self:SetHealth(100)
            end
        end
    end
end

function meta:StartMapVote(vote1, vote2)
    net.Start("NetStartMapVote")
    net.WriteInt(vote1, 16)
    net.WriteInt(vote2, 16)
    net.Broadcast()
end