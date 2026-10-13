local mat_speaker = Material("zombies/ui/speaker.png")
local mat_speaker_muted = Material("zombies/ui/mute.png")

function ToggleScoreboard(state)
    if state then
        if IsValid(Scoreboard) then return end
        local ply = LocalPlayer()
        local scrw, scrh = ScrW(), ScrH()
        Scoreboard = vgui.Create("DFrame")
        Scoreboard:SetSize(scrw, scrh)
        Scoreboard:SetTitle("")
        Scoreboard:SetMouseInputEnabled( true )
        Scoreboard:ShowCloseButton(false)
        Scoreboard:Center()
        Scoreboard:SetDraggable(false)
        Scoreboard:SetAlpha(0)
        Scoreboard:AlphaTo( 255, 0.2, 0 )
        Scoreboard.Paint = function(self, w, h)
            DrawBlur(self)
            surface.SetDrawColor(Color(18, 18, 18, 75))
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("Zombies", "DisplayFontStats", w / 2, 48, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        end

        local SubScoreboard = vgui.Create("DPanel", Scoreboard)
        SubScoreboard:SetSize(scrw * 0.6, scrh * 0.6)
        SubScoreboard:Center()
        SubScoreboard.Paint = function(self, w, h)
            return
        end

        local ScrollList = vgui.Create("DScrollPanel", SubScoreboard)
        ScrollList:Dock(FILL)
        ScrollList.Paint = function(self, w, h)
            return
        end

        local InfoPanel = ScrollList:Add( "DPanel" )
        InfoPanel:Dock(TOP)
        InfoPanel:SetTall(48)
        InfoPanel:SetText("")
        InfoPanel.Paint = function(self, w, h)
            draw.SimpleText("NAME", "DisplayFontHUD", 64, h - 4, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("CLASS", "DisplayFontHUD", w / 3, h - 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("LEVEL", "DisplayFontHUD", w / 1.5, h - 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("PING", "DisplayFontHUD", w - 128, h - 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        end

        for _, user in pairs(player.GetHumans()) do
            local SubPanel = ScrollList:Add( "DPanel" )
            SubPanel:Dock(TOP)
            SubPanel:SetTall(48)
            SubPanel:SetText("")
            SubPanel:DockMargin(0, 0, 0, 4)
            SubPanel.Paint = function(self, w, h)
                if IsValid(user) then
                    DrawBlur(self, 4)
                    surface.SetDrawColor(0, 0, 0, 155)
                    if user:IsZombie() then
                        surface.SetDrawColor(155, 0, 0, 155)
                    end
                    surface.DrawRect(0, 0, w, h)

                    draw.SimpleText(user:Nick(), "DisplayFontHUD", 64, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText(user:GetCurrentClassName(), "DisplayFontHUD", w / 3, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(user:GetLevel(), "DisplayFontHUD", w / 1.5, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText(user:Ping(), "DisplayFontHUD", w - 128, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            local Avatar = vgui.Create( "AvatarImage", SubPanel )
            Avatar:SetSize( 40, 40 )
            Avatar:SetPos( 4, 4 )
            Avatar:SetPlayer( user, 40 )

            local Profile = vgui.Create( "DButton", Avatar )
            Profile:Dock(FILL)
            Profile:SetText("")
            Profile.Paint = function()
                return
            end
            Profile.DoClick = function()
                user:ShowProfile()
            end

            local Mute = vgui.Create( "DButton", SubPanel )
            Mute:Dock(RIGHT)
            Mute:SetWide(48)
            Mute:SetText("")
            Mute.Paint = function(self, w, h)
                if IsValid(user) then
                    local muted = user:IsMuted()
                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(mat_speaker)
                    if muted then
                        surface.SetMaterial(mat_speaker_muted)
                    end

                    surface.DrawTexturedRect(8, 8, w - 16, h - 16)
                end
            end
            Mute.DoClick = function(self)
                local muted = user:IsMuted()
                user:SetMuted(!muted)
                chat.PlaySound()
            end
        end
    else
        if IsValid(Scoreboard) then
            Scoreboard:Remove()
        end
    end
end

hook.Add("ScoreboardShow", "OpenScoreboard", function()
    ToggleScoreboard(true)
    gui.EnableScreenClicker( true )
    return false
end)

hook.Add("ScoreboardHide", "HideScoreboard", function()
    ToggleScoreboard(false)
    gui.EnableScreenClicker( false )
end)