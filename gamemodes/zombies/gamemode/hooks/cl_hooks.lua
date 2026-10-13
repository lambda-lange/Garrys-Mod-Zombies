hook.Add( "ChatText", "hide_joinleave", function( index, name, text, type )
	if ( type == "joinleave" ) then
		return true
	end
end )

hook.Add("PlayerBindPress", "PreventAttackBeforeRoundStart", function(ply, bind, pressed)
    if (bind == "+attack" or bind == "+attack2") and not GetGlobalBool("Round_Status", false) then
        return true
    end
end)