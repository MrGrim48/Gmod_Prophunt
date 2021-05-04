--[[
sh_collisionhandler.lua

MrGrimm

This module allows prop players to move through 
the hunters before the hunters are released.

--]]

if SERVER then

	hook.Add( "PostRoundStart", "CollisionHandler.PostRoundStart", function() 

		SetGlobalBool( "RoundStartNoCollide", true )
		
		timer.Remove( "CollisionHandler.Timer" )
		timer.Create( "CollisionHandler.Timer",  HUNTER_BLINDLOCK_TIME || 30, 1, function()
			SetGlobalBool( "RoundStartNoCollide", false )
		end )

	end )
	
end

PlayerThink.hookAdd( "CollisionHandler", function( ply ) 

	if GetGlobalBool( "RoundStartNoCollide" ) then
	
		if ply:GetCollisionGroup() != COLLISION_GROUP_WEAPON then
			ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		elseif IsValid(ply.ph_prop) && ply.ph_prop:GetSolid() == SOLID_BBOX then
			ply.ph_prop:SetSolid( SOLID_NONE )
		end		
		
	elseif !GetGlobalBool( "RoundStartNoCollide" ) && (ply:GetCollisionGroup() == COLLISION_GROUP_WEAPON || (IsValid(ply.ph_prop) && ply.ph_prop:GetSolid() == SOLID_NONE)) then
		
		local mins, maxs = ply:GetHull()
		local filter = {ply, ply.ph_prop}
		
		local tr = util.TraceHull({
			start = ply:GetPos(),
			endpos = ply:GetPos(),
			maxs = maxs + Vector(0.1,0.1,0.1),
			mins = mins - Vector(0.1,0.1,0  ),
			filter = filter,
			mask = MASK_ALL
		})
			
		if !tr.StartSolid || ply.CollisionEnableOverride then
			ply:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			if IsValid(ply.ph_prop) then
				ply.ph_prop:SetSolid( SOLID_BBOX )
			end
			ply.CollisionEnableOverride = false
			return
		end
		
		-- Backup plan if the prop player does somehow manage to position themself to prevent enabling collision
		-- Force collision again after a few seconds
		ply.CollisionEnableDelay = ply.CollisionEnableDelay || (CurTime() + 5)
		if CurTime() > ply.CollisionEnableDelay then
			ply.CollisionEnableOverride = true
		end
		
	end

end )