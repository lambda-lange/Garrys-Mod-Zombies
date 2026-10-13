net.Receive( "NetStartMapVote", function()
    local v1 = net.ReadInt(16)
    local v2 = net.ReadInt(16)
    local scrw, scrh = ScrW(), ScrH()

    timer.Create("MapVoteTimerClient", ZConfig.mapvotetimer, 1, function() end)

    if IsValid(Frame) then Frame:Remove() end

	Frame = vgui.Create("DFrame")
    Frame:SetPos(0, 0)
	Frame:SetSize(scrw, scrh)
    Frame:SetAlpha(0)
    Frame:AlphaTo( 255, 1, 0 )
    Frame:MakePopup()
	Frame:SetTitle("")
    Frame:ShowCloseButton(false)
    Frame:SetDraggable(false)

    Frame.Paint = function(self, w, h)
        DrawBlur(self)
        surface.SetDrawColor(Color(18, 18, 18, 75))
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("Vote for a new map!", "DisplayFontStats", w / 2, 128, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        if timer.Exists("MapVoteTimerClient") then
            local time = math.Round(timer.TimeLeft("MapVoteTimerClient"))
            draw.SimpleText("Map change in ".. time, "DisplayFontStats", w / 2, h - 128, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local size = Frame:GetWide() / 2
	local Panel = vgui.Create("DPanel", Frame)
	Panel:SetSize(size + 16, size / 2)
    Panel:Center()
    Panel.Paint = function(self, w, h)
        return
    end

    local function VoteForMap(id)
        net.Start("NetSendMapVote")
        net.WriteInt(id, 16)
        net.SendToServer()
    end


	local Vote1 = vgui.Create("DButton", Panel)
	Vote1:SetSize(Panel:GetWide() / 2 - 8, Panel:GetTall())
    Vote1:SetText("")
    Vote1.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(ZConfig.maps[v1].png)
        surface.DrawTexturedRect(0, 0, w, h)
        local vote = LocalPlayer():GetMapVote()
        if vote == v1 then
            surface.SetDrawColor(0, 0, 0, 155)
            surface.DrawRect(0, h - 64, w, 64)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
        else
            surface.SetDrawColor(0, 0, 0, 155)
            surface.DrawRect(0, h - 64, w, 64)

            surface.SetDrawColor(155, 155, 155, 55)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        draw.SimpleText(ZConfig.maps[v1].title, "DisplayFontHUD", w / 2, h - 32, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local votes = GetMapVotes(v1)
        draw.SimpleText("Votes ".. "(".. votes.. ")", "DisplayFontHUD", 16, 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    Vote1.DoClick = function(self)
        VoteForMap(v1)
    end

	local Vote2 = vgui.Create("DButton", Panel)
    Vote2:SetPos(Panel:GetWide() / 2, 0)
	Vote2:SetSize(Panel:GetWide() / 2, Panel:GetTall())
    Vote2:SetText("")
    Vote2.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(ZConfig.maps[v2].png)
        surface.DrawTexturedRect(0, 0, w, h)
        local vote = LocalPlayer():GetMapVote()
        if vote == v2 then
            surface.SetDrawColor(0, 0, 0, 155)
            surface.DrawRect(0, h - 64, w, 64)

            surface.SetDrawColor(255, 255, 255, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
        else
            surface.SetDrawColor(0, 0, 0, 155)
            surface.DrawRect(0, h - 64, w, 64)

            surface.SetDrawColor(155, 155, 155, 55)
            surface.DrawOutlinedRect(0, 0, w, h)
        end
        draw.SimpleText(ZConfig.maps[v2].title, "DisplayFontHUD", w / 2, h - 32, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local votes = GetMapVotes(v2)
        draw.SimpleText("Votes ".. "(".. votes.. ")", "DisplayFontHUD", 16, 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    Vote2.DoClick = function(self)
        VoteForMap(v2)
    end
end )