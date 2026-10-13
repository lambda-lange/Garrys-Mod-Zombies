--[[GAMEMODE CONFIGURATION START]]--

LeadBot.RespawnAllowed = false
LeadBot.SetModel = false
LeadBot.Gamemode = "zombies"
LeadBot.TeamPlay = true
LeadBot.LerpAim = true
LeadBot.NoSprint = true
LeadBot.NoFlashlight = true

--[[GAMEMODE CONFIGURATION END]]--

local function selectRandomPlayer()
    local players = player.GetAll()
    if #players == 0 then return nil end
    return players[math.random(#players)]
end

function LeadBot.StartCommand(bot, cmd)
    local buttons = IN_SPEED
    local botWeapon = bot:GetActiveWeapon()
    local controller = bot.ControllerBot
    local target = controller.Target

    if !IsValid(controller) then return end

    if IsValid(target) and target:GetPos():DistToSqr(bot:GetPos()) <= 10000 then
        buttons = buttons + IN_ATTACK
        buttons = buttons + IN_ATTACK2
    end

    if IsValid(target) and target:GetPos():DistToSqr(bot:GetPos()) <= 150000 then
        buttons = buttons + IN_ATTACK2
    end

    local dt = util.QuickTrace(bot:EyePos(), bot:GetForward() * 45, bot)
    if IsValid(dt.Entity) and dt.Entity:GetClass() == "zombies_barricade" then
        buttons = buttons + IN_ATTACK
    end

    if bot:GetMoveType() == MOVETYPE_LADDER then
        local pos = controller.goalPos
        local ang = ((pos + bot:GetCurrentViewOffset()) - bot:GetShootPos()):Angle()

        if pos.z > controller:GetPos().z then
            controller.LookAt = Angle(-30, ang.y, 0)
        else
            controller.LookAt = Angle(30, ang.y, 0)
        end

        controller.LookAtTime = CurTime() + 0.1
        controller.NextJump = -1
        buttons = buttons + IN_FORWARD
    end

    if controller.NextDuck > CurTime() then
        buttons = buttons + IN_DUCK
    elseif controller.NextJump == 0 then
        controller.NextJump = CurTime() + 1
        buttons = buttons + IN_JUMP
    end

    if !bot:IsOnGround() and controller.NextJump > CurTime() then
        buttons = buttons + IN_DUCK
    end

    cmd:ClearButtons()
    cmd:ClearMovement()
    cmd:SetButtons(buttons)
end

function LeadBot.PlayerMove(bot, cmd, mv)
    local controller = bot.ControllerBot

    if !IsValid(controller) then
        bot.ControllerBot = ents.Create("leadbot_navigator")
        bot.ControllerBot:Spawn()
        bot.ControllerBot:SetOwner(bot)
        controller = bot.ControllerBot
    end

    --[[local min, max = controller:GetModelBounds()
    debugoverlay.Box(controller:GetPos(), min, max, 0.1, Color(255, 0, 0, 0), true)]]

    -- force a recompute
    if controller.PosGen and controller.P and controller.TPos ~= controller.PosGen then
        controller.TPos = controller.PosGen
        controller.P:Compute(controller, controller.PosGen)
    end

    if controller:GetPos() ~= bot:GetPos() then
        controller:SetPos(bot:GetPos())
    end

    if controller:GetAngles() ~= bot:EyeAngles() then
        controller:SetAngles(bot:EyeAngles())
    end

    mv:SetForwardSpeed(1200)

    if !IsValid(controller.Target) or controller.Target:IsZombie() or !controller.Target:Alive() then
        controller.Target = nil
    end

    if not IsValid(controller.Target) then
        local validPlayers = {}
        
        for _, ply in pairs(player.GetAll()) do
            if ply ~= bot and not ply:IsBot() and not ply:IsZombie() and ply:Alive() then
                table.insert(validPlayers, ply)
            end
        end

        if #validPlayers > 0 then
            local randomIndex = math.random(1, #validPlayers)
            controller.Target = validPlayers[randomIndex]
        end
    end

    if !IsValid(controller.Target) and (!controller.PosGen or bot:GetPos():DistToSqr(controller.PosGen) < 1000 or controller.LastSegmented < CurTime()) then
        -- find a random spot on the map, and in 10 seconds do it again!
        controller.PosGen = controller:FindSpot("random", {radius = 30000})
        controller.LastSegmented = CurTime() + 20 --10
    elseif IsValid(controller.Target) then
        -- move to our target
        local distance = controller.Target:GetPos():DistToSqr(bot:GetPos())
        controller.PosGen = controller.Target:GetPos()
        -- back up if the target is really close
        -- TODO: find a random spot rather than trying to back up into what could just be a wall
        -- something like controller.PosGen = controller:FindSpot("random", {pos = bot:GetPos() - bot:GetForward() * 350, radius = 1000})?
        
        if distance <= 350 then
            mv:SetForwardSpeed(-1200)
        end
        /*
        if distance <= 2000 then
            cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_ATTACK))
            mv:SetForwardSpeed(-1200)
        end
        */
    end

    -- movement also has a similar issue, but it's more severe...
    if !controller.P then
        return
    end

    local segments = controller.P:GetAllSegments()

    if !segments then return end

    local cur_segment = controller.cur_segment
    local curgoal = segments[cur_segment]

    -- got nowhere to go, why keep moving?
    if !curgoal then
        mv:SetForwardSpeed(0)
        return
    end

    -- think every step of the way!
    if segments[cur_segment + 1] and Vector(bot:GetPos().x, bot:GetPos().y, 0):DistToSqr(Vector(curgoal.pos.x, curgoal.pos.y)) < 100 then
        controller.cur_segment = controller.cur_segment + 1
        curgoal = segments[controller.cur_segment]
    end

    local goalpos = curgoal.pos

    if bot:GetVelocity():Length2DSqr() <= 225 then
        if controller.NextCenter < CurTime() then
            controller.strafeAngle = ((controller.strafeAngle == 1 and 2) or 1)
            controller.NextCenter = CurTime() + math.Rand(0.3, 0.65)
        elseif controller.nextStuckJump < CurTime() then
            if !bot:Crouching() then
                controller.NextJump = 0
            end
            controller.nextStuckJump = CurTime() + math.Rand(1, 2)
        end
    end

    if controller.NextCenter > CurTime() then
        if controller.strafeAngle == 1 then
            mv:SetSideSpeed(1500)
        elseif controller.strafeAngle == 2 then
            mv:SetSideSpeed(-1500)
        else
            mv:SetForwardSpeed(-1500)
        end
    end

    -- jump
    if controller.NextJump ~= 0 and curgoal.type > 1 and controller.NextJump < CurTime() then
        controller.NextJump = 0
    end

    -- duck
    if curgoal.area:GetAttributes() == NAV_MESH_CROUCH then
        controller.NextDuck = CurTime() + 0.1
    end

    controller.goalPos = goalpos

    if GetConVar("developer"):GetBool() then
        controller.P:Draw()
    end

    -- eyesight
    local lerp = FrameTime() * math.random(8, 10)
    local lerpc = FrameTime() * 8

    if !LeadBot.LerpAim then
        lerp = 1
        lerpc = 1
    end

    local mva = ((goalpos + bot:GetCurrentViewOffset()) - bot:GetShootPos()):Angle()

    mv:SetMoveAngles(mva)

    if !IsValid(controller.UseTarget) and !IsValid(controller.Target) and controller.LookAtTime < CurTime() then
        controller.LookAt = Angle(math.random(-5, 5), math.random(-30, 30), 0)
        controller.LookAtTime = CurTime() + math.Rand(0.5, 1)
    end

    if IsValid(controller.Target) then
        bot:SetEyeAngles(LerpAngle(lerp, bot:EyeAngles(), (controller.Target:EyePos() - bot:GetShootPos()):Angle()))
        return
    else
        if controller.LookAtTime > CurTime() then
            local ang = LerpAngle(lerpc, bot:EyeAngles(), mva + controller.LookAt)
            bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
        else
            local ang = LerpAngle(lerpc, bot:EyeAngles(), mva)
            bot:SetEyeAngles(Angle(ang.p, ang.y, 0))
        end
    end
end

local function BalanceZombiesBots()
    for _, bot in pairs(player.GetBots()) do
        bot:Kick()
    end

    local real_players = #player.GetHumans() or 0
    if real_players == 1 then
        game.ConsoleCommand("leadbot_add 2\n")
    elseif real_players == 2 then
        game.ConsoleCommand("leadbot_add 3\n")
    elseif real_players == 3 then
        game.ConsoleCommand("leadbot_add 5\n")
    end
end

hook.Add( "PlayerInitialSpawn", "PlayerBotSpawnAutoBalance", function( ply )
    if not ply:IsBot() then
        BalanceZombiesBots()
    end
end)

hook.Add( "PlayerDisconnected", "PlayerDisconnectedAutoBalance", function( ply )
    if not ply:IsBot() then
        timer.Simple(1, function()
            BalanceZombiesBots()
        end)
    end
end)

hook.Add( "PlayerDeath", "PlayerDeathBotAutoClass", function( ply, inf, att )
    if ply:IsBot() then
        local controller = ply.ControllerBot
        if IsValid(controller) and IsValid(controller.Target) then
            if IsValid(att) and att:IsPlayer() and not att:IsZombie() then
                controller.Target = att
            end
        end
        local classes = #ZConfig.classes.zombies
        local class = math.random(1, classes)
        timer.Simple(1, function()
            if IsValid(ply) then
                ply:SetNWInt("player_class_zombie", class)
            end
        end)
    end
end)

hook.Add( "PlayerSpawn", "PlayerBotSpawnAutoBalance", function( ply )
    local state = GetGlobalBool( "Round_Status" )
    if state then return end
    if ply:IsBot() then
        ply:KillSilent()
    end
end)