// ensure the material exists before we start the hook
local materialPath = "zombies/effects/vignette01.vmt"
if file.Exists("materials/" .. materialPath, "GAME") then
    hook.Add("RenderScreenspaceEffects", "PostProcessingVignette", function()
        DrawMaterialOverlay(materialPath, 1)
    end)
end

// takes a lot of performance, fix later
// note 2026, yeah your problem now
function AddSurvivorHalosFunc()
    if !LocalPlayer():IsZombie() then return end

    local dist = 500 ^ 2
    local humans = {}

    for _, ply in ipairs(player.GetAll()) do
        if ply:Alive() and !ply:IsZombie() and LocalPlayer():GetPos():DistToSqr(ply:GetPos()) >= dist then
            humans[#humans + 1] = ply
        end
    end

    local startTime = CurTime()

    hook.Add("PreDrawHalos", "AddSurvivorHalos", function()
        local elapsedTime = CurTime() - startTime
        local alpha = 255 * math.max(1 - (elapsedTime / 3), 0)
        local white = Color(255, 255, 255, alpha)

        for i = #humans, 0, -1 do
            if not humans[i] or not humans[i]:Alive() then
                table.remove(humans, i)
            end
        end
        
        halo.Add(humans, white, 0, 0, 1, true, true)

        if elapsedTime >= 3 then
            hook.Remove("PreDrawHalos", "AddSurvivorHalos")
        end
    end)
end