
CreateClientConVar( "prophunt_highlightplayers", "1", true, true )

hook.Add( "Menu.Opened", "Player.HighlightPlayers", function()
	Menu.Options:AddNewConVar( "prophunt_highlightplayers", "Highlight Prop Players" )
end)
	
-- Draws a halo around prop players. Seen by Prop players and Spectators
hook.Add( "PreDrawHalos", "Player.PreDrawHalos", function() 
	
	if LocalPlayer():Team() != TEAM_HUNTERS && GetConVar("prophunt_highlightplayers"):GetInt() == 1 then -- Props or Specs
		halo.Add( ents.FindByClass("ph_prop"), Color( 150, 150, 255), 1, 1, 1, true, false )
		halo.Add( ents.FindByClass("ph_dummy"), Color( 255, 255, 100), 1, 1, 1, true, false )
	end

end)