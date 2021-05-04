
module( "Players.PlayerPickup", package.seeall )


-- Why do I have this?
hook.Add( "Initialize", "PlayerPickupOverride", function()

	local BaseAllowPickup = GAMEMODE.AllowPlayerPickup
	function GAMEMODE:AllowPlayerPickup( ply, ent )
		
		local bCanPickUp = BaseAllowPickup()
		
		if ( bCanPickUp ) then
			hook.Run( "PlayerPickup", ply, ent )
		end
		
		return bCanPickUp
		
	end
	
end )