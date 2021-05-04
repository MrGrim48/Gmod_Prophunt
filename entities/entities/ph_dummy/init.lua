
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()

	self:SetModel("models/player/kleiner.mdl")
	
end 


function ENT:OnTakeDamage( dmg )
	
	if dmg:GetAttacker():IsPlayer() && dmg:GetDamage() > 0 then

		self:Remove()
		
	end
	
end 


function ENT:Think()
	
	-- Enables collision with the owner when they are no longer intersecting
	if IsValid( self.Owner ) then
		
		if self.Owner:Alive() then
			local min, max = self:WorldSpaceAABB()
			local pmin, pmax = self.Owner:GetHull()
			if self.Owner:GetPos():WithinAABox( min+pmin-Vector(0,0,1), max+pmax+Vector(0,0,1) ) then
				return
			end
		end
		
		-- Disables no collide with the owner
		self:SetOwner( nil )
	
	end
	
	-- Freeze the prop when it stops moving
	if self:GetVelocity() == Vector() && !self.Frozen then		
		local physObj = self:GetPhysicsObject()
		if IsValid( physObj ) then
			physObj:EnableMotion( false )
		end
		self.Frozen = true
	end

end


function ENT:Use( activator, caller, useType, value )

	if ( self:IsPlayerHolding() ) then return end
	
	--[[if self:GetPhysicsObject():GetMass() <= 40 && IsValid(caller) && caller:Alive() && caller:Team() == TEAM_HUNTERS then
		caller:PickupObject( self )
	end]]

end

util.AddNetworkString( "SendEffect.Balloon" )

function ENT:OnRemove()

	net.Start( "SendEffect.Balloon" )
	net.WriteEntity( self )
	net.Broadcast()

end