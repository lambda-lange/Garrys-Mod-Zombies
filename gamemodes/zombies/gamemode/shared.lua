include("config.lua")
--DeriveGamemode("sandbox")
GM.Name = "Zombies"
GM.Author = "76561198799619486"

team.SetUp(1, "Survivors", Color(55, 55, 255))
team.SetUp(2, "Zombies", Color(255, 55, 55))

function GM:Initialize()
    if SERVER then
        timer.Create("ServerHealthRegenTimer", 2, 0, RegenerateHealth)
        timer.Create("ServerAutoXPTimer", 60, 0, GiveTimedXP)
    end
end

function GM:InitPostEntity()
    // remove allways all doors we dont want them
    RemoveAllMapDoors()

    if SERVER then
        local spawns = ents.FindByClass("info_player_start")
        local ent = spawns[1]
        if IsValid( ent ) then
            local pos = ent:GetPos()
            SetGlobalVector( "MainSpawn", pos)
        end
    end

    if CLIENT then
        timer.Create( "TimerAddSurvivorHalos", 8, 0, AddSurvivorHalosFunc )

        // FIX SOME ANOYING CLIENT SHIT
        LocalPlayer():ConCommand("M9KGasEffect 0")
    end
end

function GM:PlayerConnect()
    return false
end

function GM:ScalePlayerDamage( client, hitgroup, dmginfo )
    local attacker = dmginfo:GetAttacker()
    if !attacker:IsPlayer() then return end
	if client:Team() == attacker:Team() then
		return true
	end

    dmginfo:ScaleDamage(1)
end

function GM:PlayerNoClip( client )
	return false
end

function FormatMoney(value)
    local strValue = tostring(value)
    local len = #strValue
    local formattedValue = ""

    for i = len, 1, -1 do
        local digit = strValue:sub(i, i)
        formattedValue = digit .. formattedValue
        if (len - i + 1) % 3 == 0 and i ~= 1 then
            formattedValue = "." .. formattedValue
        end
    end

    return formattedValue
end

function GetWeaponDataByIndex(category, index)
    if not category or not index then
        print("Invalid category or index")
        return nil
    end

    local categoryData = ZConfig.weapons[category]
    if categoryData and categoryData.weapons and categoryData.weapons[index] then
        return categoryData.weapons[index]
    else
        print("Error: Weapon with category " .. category .. " and index " .. index .. " not found in config.")
        return nil
    end
end

function RemoveAllMapDoors()
    for _, ent in pairs(ents.GetAll()) do
        if ent:GetClass() == "prop_door_rotating" then
            if IsValid( ent ) then
                ent:Remove()
            end
        end
    end
end

function GetMapVotes(id)
    local voteCount = 0
    for _, ply in ipairs(player.GetAll()) do
        local voteID = ply:GetMapVote()
        if voteID == id then
            voteCount = voteCount + 1
        end
    end
    return voteCount
end

function GetMapVoteResult()
    local maps = ZConfig.maps

    local maxVotes = 0
    local winningMaps = {}
    local totalVotes = 0

    for _, map in ipairs(maps) do
        local mapVotes = GetMapVotes(_)
        totalVotes = totalVotes + mapVotes
        if mapVotes > maxVotes then
            maxVotes = mapVotes
            winningMaps = {map}
        elseif mapVotes == maxVotes then
            table.insert(winningMaps, map)
        end
    end

    if totalVotes == 0 or #winningMaps == #maps then
        return maps[GetGlobalInt("MapVoteFallback")].map
    else
        return table.Random(winningMaps).map
    end
end

function GetZombieCount()
    return team.NumPlayers(2)
end

function GetHumanCount()
    return team.NumPlayers(1)
end

// DEV__________________________________________
if SERVER then
    hook.Add( "PlayerButtonDown", "QuickWeaponSwitch", function( client, button )
        if button == KEY_1 then
            for index, data in ipairs(ZConfig.shop.weapons) do
                if data.slot ~= 1 then continue end
                if client:HasWeapon(data.swep) then
                    client:SelectWeapon(data.swep)
                end
            end
        end
        if button == KEY_2 then
            for index, data in ipairs(ZConfig.shop.weapons) do
                if data.slot ~= 2 then continue end
                if client:HasWeapon(data.swep) then
                    client:SelectWeapon(data.swep)
                end
            end
        end
        if button == KEY_3 then
            for _, class in ipairs(ZConfig.classes.humans) do
                local weapon = class.swep
                if weapon then
                    if client:HasWeapon(weapon) then
                        client:SelectWeapon(weapon)
                    end
                end
            end
        end
    end)
end