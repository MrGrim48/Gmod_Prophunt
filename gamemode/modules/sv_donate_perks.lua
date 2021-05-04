/*
sv_donate_perks.lua

Copyright© Nekom Glew, 2017

*/

--[[------------------------------------------------
	Name: PlayerSpawn()
	Desc: When a player spawns, they are given bonus 
		items based on their usergroup.
--]]------------------------------------------------
function PlayerSpawn( ply )

	if ply:Team() == TEAM_HUNTERS then
		
		if GameState && (GameState.IsState( "PreGame" ) || GameState.IsState( "Waiting" )) then return end
		if hook.Run( "HunterLoadoutDisabled" ) then return end
		
		timer.Simple( 3, function() 
			-- Donor
			if ply:CheckGroup( "donor_user" ) then
				ply:Give( "weapon_crossbow" )
				ply:GiveAmmo( 24, "XBowBolt", true )
			end
			
			-- VIP
			if ply:CheckGroup( "vip_user" ) then
				ply:Give( "weapon_physcannon" )
				ply:Give( "fingergun" )
			end
		end)
		
	end

end
hook.Add( "PlayerSpawn", "DonatePerks_PlayerSpawn", PlayerSpawn )