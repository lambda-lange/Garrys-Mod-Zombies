
/*
net.Receive( "NdadadadetSendRoundStats", function()

end )
*/

function TestShitStuffReward()
    if IsValid(Reward) then
        Reward:Remove()
    end
	Reward = vgui.Create("DFrame")
	Reward:SetSize(ScrW() / 2, ScrH() / 4)
    Reward:Center()
    Reward:MakePopup()
    Reward:SetAlpha(0)
    Reward:AlphaTo( 255, 1, 0 )
	Reward:SetTitle("")
    Reward:ShowCloseButton(true)
    Reward:SetDraggable(true)

    Reward.Paint = function(self, w, h)
        DrawBlur(self, 8)
        draw.RoundedBox(12, 0, 0, w, h, Color(30, 33, 36, 225))
    end
end