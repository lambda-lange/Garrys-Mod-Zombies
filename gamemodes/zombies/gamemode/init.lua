AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

AddCSLuaFile("config.lua")
AddCSLuaFile("meta/sh_meta.lua")
AddCSLuaFile("hooks/sh_hooks.lua")

AddCSLuaFile("derma/cl_shop.lua")
AddCSLuaFile("derma/cl_stats.lua")
AddCSLuaFile("derma/cl_scoreboard.lua")
AddCSLuaFile("derma/cl_mapvote.lua")
AddCSLuaFile("derma/cl_reward.lua")
AddCSLuaFile("hooks/cl_hooks.lua")

AddCSLuaFile("hud/cl_hud.lua")
AddCSLuaFile("hud/cl_3d2d.lua")
AddCSLuaFile("hud/cl_effects.lua")

include("shared.lua")
include("core/net.lua")
include("core/autoload.lua")
include("meta/sv_meta.lua")
include("meta/sh_meta.lua")

include("hooks/sv_hooks.lua")
include("hooks/sh_hooks.lua")

function GM:PlayerInitialSpawn(client)
    //kill the player before we do anything
    client:KillSilent()
    client:SetZombie(false) -- always a survivor on start

    // give default items if not existent
    client:GiveDefaultItems()

    // sync player information
    client:LoadPlayerData()

    // after a player joins we check if we have enough to start the game
    StartRoundSystemCheck()
end

function GM:PlayerDisconnected(client)
    client:SavePlayerData()

    // check if the round should end
    EndRoundCheck()

    AddServerLog(client:Nick().. " ".. client:SteamID().. " has left the server")
end

function GM:ShutDown()
    for _, client in pairs(player.GetAll()) do
        client:SavePlayerData()
    end
    AddServerLog("Server Shutdown")
end

/*
function GM:PlayerCanHearPlayersVoice(listener, talker)
    if talker:IsZombie() then
        if listener:IsZombie() then
            return true, false
        end
    end

    if not talker:IsZombie() then
        if not listener:IsZombie() then
            if listener:GetPos():DistToSqr(talker:GetPos()) <= 250000 then
                return true, true
            end
        end
    end

    return false, false
end
*/

function GM:PlayerSpawn(client)
    client:SetupHands()

    client:SetupClass()

    // important stuff for team collsion
    client:SetNoCollideWithTeammates( true )
    client:SetAvoidPlayers(true)
end

function GM:EntityTakeDamage( ent, dmginfo )
    local attacker = dmginfo:GetAttacker()

    if ent:IsValid() and ent:IsPlayer() then
        if attacker:IsValid() and attacker:IsPlayer() then
            if ent:IsZombie() ~= attacker:IsZombie() then
                net.Start("NetPlayerTakeDamageIndicator")
                net.Send(ent)

                net.Start("NetPlayerDrawHitmarker")
                net.Send(attacker)
            end
        end
    end

    if ( IsValid(ent) and ent:IsPlayer() ) then
        local attacker = dmginfo:GetAttacker()
        if attacker:IsPlayer() and ent:IsPlayer() and ( ent:IsZombie() and attacker:IsZombie() or !ent:IsZombie() and !attacker:IsZombie() ) then return end
        if ( not ent.LastPainSoundTime or CurTime() - ent.LastPainSoundTime >= 2 ) then
            if ent:IsZombie() then
                ent:EmitSound("npc/zombie/zombie_pain".. math.random(1,6).. ".wav", 90, math.random(90,110), 1, CHAN_AUTO)
            else
                ent:EmitSound("vo/npc/Barney/ba_pain0".. math.random(1,9).. ".wav", 90, math.random(90,110), 1, CHAN_AUTO)
            end
            ent.LastPainSoundTime = CurTime()
        end
    end

    if ( IsValid(ent) and ent:IsPlayer() ) then
        local attacker = dmginfo:GetAttacker()
        if ( IsValid(attacker) and attacker:IsPlayer() ) then
            attacker:PlaySound("zombies/hitmarker.wav")
        end
    end
end

function GM:PlayerAuthed( ply )
    for _, v in pairs(player.GetAll()) do
        v:Info(ply:Name().. " has connected")
    end

    AddServerLog(ply:Name().. " has connected")
end

function GM:PlayerSelectSpawn( ply )
	local spawns = ents.FindByClass("info_player_start")

    // allawys spawn on spawn #1 (no random spawns)
	return spawns[1]
end

function GM:PlayerShouldTakeDamage( client, attacker)
    if attacker:IsPlayer() then
        if client:Team() == attacker:Team() then
            return false
        end
    end
    return true
end

function GM:PlayerDeath(client, inflictor, attacker)
    local state = GetGlobalBool( "Round_Status" )
    local points = 0
    if !state then return end
    if attacker:IsPlayer() then
        if client ~= attacker then
            if client:IsZombie() then
                points = 100 -- 50 before 2026
                if client:IsBot() then
                    points = 50 --30 before 2026
                end
                attacker:AddPoints(points)
                attacker:AddXP(10)
                attacker:PlaySound("zombies/kill.wav")

                client:EmitSound("npc/zombie/zombie_die".. math.random(1, 3).. ".wav", 75, 100, 0.8)
            else
                points = 100
                attacker:AddPoints(points)
                attacker:AddXP(100)
            end
            net.Start("NetPlayerDrawKillEffect")
            net.WriteEntity(client)
            net.WriteInt(points, 16)
            net.Send(attacker)
        end
    end

    if GetGlobalBool( "Round_Status" ) then
        --client:Info("Your died and turned into a zombie!")
        client:SetZombie(true)
    end

    timer.Create("respawn_cooldown".. client:SteamID64(), 3, 1, function()
        if !GetGlobalBool( "Round_Status" ) then return end
        if IsValid(client) then
            if !client:Alive() then
                client:Spawn()
            end
        end
    end)

    // check if the round should end
    EndRoundCheck()
end

function GM:ShowTeam( client )
    client:SyncBoughtWeapons()
    net.Start("NetOpenMenu")
    net.Send(client)
end

function GM:PlayerSetHandsModel( ply, ent )

	local simplemodel = player_manager.TranslateToPlayerModelName( ply:GetModel() )
	local info = player_manager.TranslatePlayerHands( simplemodel )
	if ( info ) then
		ent:SetModel( info.model )
		ent:SetSkin( info.skin )
		ent:SetBodyGroups( info.body )
	end

end

function GM:AllowPlayerPickup( client )
    return !client:IsZombie()
end

function GM:IsSpawnpointSuitable(client)
    return false
end

function GM:PlayerDeathSound()
    return true
end

function GM:GetFallDamage( client, speed )
    if client:IsZombie() then
        return
    end

    return ( speed / 16 )
end

// check player connects to start the session
local round_started = false
function StartRoundSystemCheck()
    if !round_started then
        if player.GetCount() > 1 then
            round_started = true
            StartRoundPrep()
        end
    end
end

function BalancePlayerZombies()

    local real_players = #player.GetHumans() or 0
    if real_players > 3 then

        local players = player.GetAll()
        local playerCount = #players
        local killCount = math.Round(playerCount * 0.49 )

        // 2 vs 1 player fix
        if playerCount == 3 then
            killCount = 2
        end

        local playerChances = {}

        for _, ply in pairs(players) do
            local chance = ply:GetNWFloat("RoundDeathChance", 0.5)
            table.insert(playerChances, {player = ply, chance = chance})
        end

        table.sort(playerChances, function(a, b) return a.chance < b.chance end)

        local playersToKill = {}

        for i = 1, killCount do
            table.insert(playersToKill, playerChances[i].player)
        end

        for _, ply in pairs(playersToKill) do
            ply:Kill()
            local newChance = math.max(ply:GetNWFloat("RoundDeathChance", 0.5) * 1.5, 0.1)
            ply:SetNWFloat("RoundDeathChance", newChance)
        end
    else
        // not enough players, we play with bots
        for _, ply in pairs(player.GetAll()) do
            if ply:IsBot() then
                ply:Kill()
            end
        end
    end
end

function StartRoundPrep()
    if timer.Exists("RoundTimerPrep") then
        return print("Round Already started!")
    end

    // start the prep timer
    SetGlobalInt("Round_PrepTime", ZConfig.roundtimerprep)
    timer.Create("RoundTimerPrep", 1, ZConfig.roundtimerprep, function()
        if timer.RepsLeft("RoundTimerPrep") <= 0 then
            StartRound()
        end
        // share timer to client
        local time_left = timer.RepsLeft("RoundTimerPrep") or 0
        SetGlobalInt("Round_PrepTime", time_left)
        
        if timer.RepsLeft("RoundTimerPrep") <= 3 and timer.RepsLeft("RoundTimerPrep") > 0 then
            for k, v in pairs(player.GetAll()) do
                v:PlaySound("zombies/timer.wav")
            end
        end
        
    end)

    for k, v in pairs(player.GetAll()) do
        v:SetZombie(false)
        v:KillSilent()
        v:Spawn()
    end

    game.CleanUpMap()
end


function GetRandomExtractionVector()
    local currentMap = game.GetMap()

    for _, mapInfo in ipairs(ZConfig.maps) do
        if mapInfo.map == currentMap then
            local extractionPoints = mapInfo.extraction
            return tostring(extractionPoints[math.random(#extractionPoints)])
        end
    end

    return "Vector(0, 0, 0)"
end

function StartRound()
    if timer.Exists("RoundTimer") then
        return print("Round Already started!")
    end

    for _, ply in pairs(player.GetAll()) do
        ply:PlaySound("ambient/creatures/town_zombie_call1.wav")
        if !ply:Alive() then 
            ply:Spawn()
        end
    end

    SetGlobalBool( "Round_Status", true )

    //set the evac zone for this round
    SetGlobalVector(GetRandomExtractionVector())

    // start round timer
    SetGlobalInt("Round_Time", ZConfig.roundtimer)
    timer.Create("RoundTimer", 1, ZConfig.roundtimer, function()
        local time_left = timer.RepsLeft("RoundTimer") or 0
        SetGlobalInt("Round_Time", time_left)
        if time_left <= 0 then
            EndRound()
        else
            EndRoundCheck()
        end
    end)

    for _, client in pairs(player.GetAll()) do
        local current_rounds = tostring(GetGlobalInt("Round_Count") + 1)
        client:Info("Starting Round! (".. current_rounds.. "/".. ZConfig.maxrounds.. ")")
    end

    // add zombies to the game
    BalancePlayerZombies()
end

function ResetRound()
    if timer.Exists("RoundTimerPrep") then
        timer.Remove("RoundTimerPrep")
    end
    if timer.Exists("RoundTimer") then
        timer.Remove("RoundTimer")
    end
    SetGlobalInt("Round_PrepTime", 0)
    SetGlobalInt("Round_Time", 0)
end

function EndRoundCheck()
    if !GetGlobalBool( "Round_Status" ) then
        return
    end
    local status = true
    if player.GetCount() >= 2 then
        for _, client in ipairs(player.GetAll()) do
            if !client:IsZombie() then
                status = false
                break
            end
        end
    else
        status = true
    end
    
    if status then
        ResetRound()
        EndRound() -- zombies won end the round
    end
end

function RoundEndHandling()
    -- Play start sound for all players
    for _, client in ipairs(player.GetAll()) do
        client:PlaySound("zombies/slow_motion_start.wav")
    end

    -- Slow down time
    game.SetTimeScale(0.25)

    local steps = 10
    local duration = 3

    -- Define a function to set time scale based on step
    local function setTimeScale(step)
        local scale = 0.25 + 0.75 * (step^2) / 100
        game.SetTimeScale(scale)
    end

    -- Create timers for time scale transition
    for i = 1, steps do
        local delay = duration * (i / steps)
        timer.Simple(delay, function() setTimeScale(i) end)
    end

    -- Restore normal time scale after transition
    timer.Simple(duration + 0.05, function() game.SetTimeScale(1) end)

    -- Play end sound for all players
    timer.Simple(duration * 0.75, function()
        for _, client in ipairs(player.GetAll()) do
            client:PlaySound("zombies/slow_motion_end.wav")
        end
    end)
end



function EndRound()
    SetGlobalBool( "Round_Status", false )
    SetGlobalInt( "Round_Count", GetGlobalInt( "Round_Count") + 1 )

    // create a slowdown effect and show the scoreboard
    RoundEndHandling()

    if timer.Exists("RoundTimer") then
        timer.Remove("RoundTimer")
    end

    // check if we have enough players to start a new round
    timer.Simple(ZConfig.roundidle, function()
        if GetGlobalInt( "Round_Count") >= ZConfig.maxrounds then
            StartMapVoting()
        else
            timer.Create("RoundStartCheckTimer", 1, 0, function()
                if player.GetCount() > 1 then
                    if timer.Exists("RoundStartCheckTimer") then
                        timer.Remove("RoundStartCheckTimer")
                    end
                    StartRoundPrep()
                end
            end)
        end
    end)

    local status = true
    for _, client in ipairs(player.GetAll()) do
        if !client:IsZombie() then
            status = false
            break
        end
    end

    if !status then
        for _, client in ipairs(player.GetAll()) do
            if client:IsZombie() then
                client:Kill()
            end
        end     
    end

    if status then
        SaveRoundWin("zombies_wins")
    else
        SaveRoundWin("humans_wins")
    end

    net.Start("NetSendRoundStats")
    net.WriteBool(status)
    net.Broadcast()
end

function StartMapVoting()
    local numMaps = #ZConfig.maps

    if numMaps < 2 then
        return
    end

    local currentMap = game.GetMap()
    local mapIndex1 = math.random(1, numMaps)

    while ZConfig.maps[mapIndex1] == currentMap do
        mapIndex1 = math.random(1, numMaps)
    end

    local mapIndex2 = math.random(1, numMaps)

    while mapIndex2 == mapIndex1 or ZConfig.maps[mapIndex2] == currentMap do
        mapIndex2 = math.random(1, numMaps)
    end

    for _, client in pairs(player.GetAll()) do
        client:StartMapVote(mapIndex1, mapIndex2)
    end

    SetGlobalInt("MapVoteFallback", mapIndex1)

    timer.Create("MapVoteTimerServer", ZConfig.mapvotetimer, 1, function()
        local map = GetMapVoteResult()
        game.ConsoleCommand("changelevel " .. map.. "\n")
    end)
end

/*
function StartMapVoting()
    local numMaps = #ZConfig.maps

    if numMaps < 2 then
        return
    end

    local mapIndex1 = math.random(1, numMaps)
    local mapIndex2 = math.random(1, numMaps)

    while mapIndex2 == mapIndex1 do
        mapIndex2 = math.random(1, numMaps)
    end

    for _, client in pairs(player.GetAll()) do
        client:StartMapVote(mapIndex1, mapIndex2)
    end

    SetGlobalInt("MapVoteFallback", mapIndex1)

    timer.Create("MapVoteTimerServer", ZConfig.mapvotetimer, 1, function()
        local map = GetMapVoteResult()
        game.ConsoleCommand("changelevel " .. map.. "\n")
    end)
end
*/

function RegenerateHealth()
    for _, client in ipairs(player.GetAll()) do
        if client:Alive() and client:Health() < client:GetMaxHealth() then
            if !client:IsZombie() then
                client:SetHealth(math.min(client:GetMaxHealth(), client:Health() + 1))
            end
        end
    end
end

function GiveTimedXP()
    if player.GetCount() < 2 then return end
    for _, client in ipairs(player.GetAll()) do
        client:AddXP(50)
    end
end

function SaveRoundWin(side)
    local dataFolder = "zombies/"
    local fileName = side.. ".txt"
    local filePath = dataFolder .. fileName
    
    if not file.Exists(dataFolder, "DATA") then
        file.CreateDir(dataFolder)
    end
    
    local currentWins = 0
    if file.Exists(filePath, "DATA") then
        local fileHandle = file.Open(filePath, "r", "DATA")
        if fileHandle then
            currentWins = tonumber(fileHandle:ReadLine()) or 0
            fileHandle:Close()
        end
    end
    
    currentWins = currentWins + 1
    
    local fileHandle = file.Open(filePath, "w", "DATA")
    
    if fileHandle then
        fileHandle:Write(tostring(currentWins))
        fileHandle:Close()
        print("Wins for team " .. side .. " updated to " .. currentWins)
    else
        print("Error: Couldn't open file for writing.")
    end
end

function AddServerLog(log)
    local dataFolder = "zombies/logs/"
    local date = os.time()
    local datestring = os.date( "%d-%m-%Y" , date )
    local fileName = datestring.. ".txt"
    local filePath = dataFolder .. fileName
    
    if not file.Exists(dataFolder, "DATA") then
        file.CreateDir(dataFolder)
    end
    
    -- Append log message to the log file
    local logFile = file.Open(filePath, "a", "DATA")
    if logFile then
        logFile:Write(os.date("[%H:%M:%S] ") .. log .. "\n")
        logFile:Close()
    else
        print("Error: Couldn't open log file for writing.")
    end
end

net.Receive( "NetSendMapVote", function(len, client)
    local id = net.ReadInt(16)
    client:SetMapVote(id)
    client:PlaySound("zombies/ui/click.wav")
end )

net.Receive( "NetBuyWeapon", function(len, client)
    local index = net.ReadInt(16)
    client:BuyWeapon(index)
end )

net.Receive( "NetSelectClassHuman", function(len, client)
    local id = net.ReadInt(16)
    local class = ZConfig.classes.humans[id]

    if !class then
        print("trying to apply invalid id for human class, with id: ".. tostring(id))
        return
    end

    if client:GetLevel() >= class.level then
        client:SetNWInt("player_class_human", id)
        if !GetGlobalBool("Round_Status") then
            client:SetupClass() // we dont wanna respawn him so we set the class stuff directly
        end
    end
end )

net.Receive( "NetSelectClassZombie", function(len, client)
    local id = net.ReadInt(16)
    local class = ZConfig.classes.zombies[id]

    if !class then
        print("trying to apply invalid id for zombie class, with id: ".. tostring(id))
        return
    end

    if client:GetLevel() >= class.level then
        client:SetNWInt("player_class_zombie", id)
        if client:IsZombie() and GetGlobalBool("Round_Status") then
            client:Spawn()
        end
    end
end )

net.Receive( "NetEquipPrimary", function(len, client)
    local index = net.ReadInt(16)

    if !client:HasBoughtWeapon(index) then
        return
    end

    if !ZConfig.shop.weapons[index].slot == 1 then
        return
    end

    client:SetPData("primary_weapon_index", index)
    if !GetGlobalBool( "Round_Status" ) and !client:IsZombie() then
        client:SetupClass()
    end
end )

net.Receive( "NetEquipSecondary", function(len, client)
    local index = net.ReadInt(16)

    if !client:HasBoughtWeapon(index) then
        return
    end

    if !ZConfig.shop.weapons[index].slot == 2 then
        return
    end

    client:SetPData("secondary_weapon_index", index)
    if !GetGlobalBool( "Round_Status" ) and !client:IsZombie() then
        client:SetupClass()
    end
end )

concommand.Add("setxp", function(ply, cmd, args)
    local value = tonumber(args[1]) or 0
    for k, v in pairs(player.GetAll()) do
        v:SetXP(value)
    end
end)

concommand.Add("setpoints", function(ply, cmd, args)
    local value = tonumber(args[1]) or 0
    for k, v in pairs(player.GetAll()) do
        v:SetPoints(value)
    end
end)

concommand.Add("mapvote_start", function(ply, cmd, args)
    StartMapVoting()
end)

/*
concommand.Add("setxp", function(ply, cmd, args)
    local value = tonumber(args[1]) or 0
    for k, v in pairs(player.GetAll()) do
        v:SetXP(value)
    end
end)
concommand.Add("round_start", function()
    StartRound()
end)

concommand.Add("round_end", function()
    EndRound()
end)

concommand.Add("round_check", function()
    print(EndRoundCheck())
end)

concommand.Add( "bought_weapon_server", function()  
    for index, data in ipairs(ZConfig.shop.weapons) do
        for k, v in pairs(player.GetAll()) do
            if v:HasBoughtWeapon(index) then
                print(index)
            end
        end
    end
end )
*/

if SERVER then
    -- Function to modify the player's weapon properties... i think
    local function ModifyWeaponProperties(ply, cmd, args)
        if not IsValid(ply) then return end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) then
            ply:ChatPrint("You are not holding a valid weapon.")
            return
        end

        if weapon.Base ~= "bobs_gun_base" then
            ply:ChatPrint("This command only works with M9K weapons.")
            return
        end

        local fireRateMultiplier = tonumber(args[1]) or 1
        local clipMultiplier = tonumber(args[2]) or 1

        -- Modify reload speed (Primary.RPM may vary based on the weapon)
        if weapon.Primary.RPM then
            weapon.Primary.RPM = weapon.Primary.RPM * fireRateMultiplier
        else
            ply:ChatPrint("This weapon does not have a Primary.RPM property.")
        end

        -- Modify fire rate
        if weapon.Primary.ClipSize then
            weapon.Primary.ClipSize = weapon.Primary.ClipSize * clipMultiplier
            weapon.Primary.DefaultClip = weapon.Primary.DefaultClip * clipMultiplier
        else
            ply:ChatPrint("This weapon does not have a Primary.Delay property.")
        end

        ply:ChatPrint("Weapon properties have been modified.")
    end

    -- Register the console command
    concommand.Add("modify_weapon", ModifyWeaponProperties)
end