net.Receive( "NetSendRoundStats", function()
    local result = net.ReadBool()
    local scrw, scrh = ScrW(), ScrH()
    local idle_timer = ZConfig.roundidle or 15

	local Stats = vgui.Create("DFrame")
    Stats:SetPos(0, 0)
	Stats:SetSize(scrw, scrh)
    Stats:SetAlpha(0)
    Stats:AlphaTo( 255, 1, 0 )
    Stats:AlphaTo( 0, 1, idle_timer - 1 )
	Stats:SetTitle("")
    Stats:ShowCloseButton(false)
    Stats:SetDraggable(false)

    Stats.Paint = function(self, w, h)
        DrawBlur(self, 8)
        surface.SetDrawColor(Color(18, 18, 18, 75))
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(Color(0, 0, 0, 155))
        surface.DrawRect(0, 0, w, 128)
        if result then
            draw.SimpleText("Zombies Won!", "DisplayFontStats", w / 2, 64, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Humans Won!", "DisplayFontStats", w / 2, 64, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    timer.Simple(idle_timer, function()
        if IsValid(Stats) then
            Stats:Remove()
        end
    end )
end )