--
-- ph_prop/init.lua
-- Prop Hunt
--	
-- Created by Andrew Theis on 2013-03-09.
-- Copyright (c) 2010-2013 Andrew Theis. All rights reserved.
--


-- Send required files to client.
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")


-- Include needed files.
include("shared.lua")


-- Called when the entity takes damage.
function ENT:OnTakeDamage(dmg)
	
	-- Store dmg information in easier to use variables.
	local ply 		= self:GetOwner()
	local attacker 	= dmg:GetAttacker()
	local inflictor = dmg:GetInflictor()
	
	-- Check to make sure the player and attacker are valid.
	if IsValid(ply) && ply:Alive() && ply:IsPlayer() && attacker:IsPlayer() && dmg:GetDamage() > 0 then
	
		-- Set new player health.
		ply:SetHealth( math.ceil(ply:Health() - dmg:GetDamage()) )
		
		-- Check to see if the player should be dead.
		if ply:Health() <= 0 then
			
			-- Kill the player and remove their prop.
			ply:KillSilent()
			ply:RemoveProp()
			
			-- Find out what player should take credit for the kill.
			if IsValid(inflictor) && inflictor == attacker && inflictor:IsPlayer() then
				inflictor = inflictor:GetActiveWeapon()
				if !IsValid(inflictor) || inflictor == NULL then
					inflictor = attacker
				end
			end
			
			-- Let everyone else know of the kill.
			net.Start( "PlayerKilledByPlayer" )
				net.WriteEntity( ply )
				net.WriteString( inflictor:GetClass() )
				net.WriteEntity( attacker )
			net.Broadcast()
			
			hook.Run( "PropKilled", ply, inflictor, attacker )
			
			MsgAll(attacker:Name() .. " found and killed " .. ply:Name() .. "\n") 
			
			-- Add points to the attacker's score and up their health.
			attacker:AddFrags(1)
			attacker:SetHealth(math.Clamp(attacker:Health() + GAMEMODE.HunterKillBonus, 1, 100))
			
		end
		
	end
	
end 

function ENT:Use( activator, caller, useType, value )

	if ( self:IsPlayerHolding() ) then return end
	
	if self.Owner:GetNWBool( "PhysicsMode", false ) && self:GetPhysicsObject():GetMass() <= 40 && IsValid(caller) && caller:Alive() && caller:Team() == TEAM_HUNTERS then
		caller:PickupObject( self )
	end

end

