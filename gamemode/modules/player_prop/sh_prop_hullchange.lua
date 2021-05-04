
local PlayerMeta = FindMetaTable( "Player" )


-- Code from MechanicalMind's PropHunters with some tweaks
local function checkCorner(mins, maxs, corner, ang)
	corner:Rotate(ang)
	mins.x = math.min(mins.x, corner.x)
	mins.y = math.min(mins.y, corner.y)
	maxs.x = math.max(maxs.x, corner.x)
	maxs.y = math.max(maxs.y, corner.y)
end

function PlayerMeta:CalculateRotatedDisguiseMinsMaxs( ent, ang )
	--local maxs = self:GetNWVector("disguiseMaxs")
	--local mins = self:GetNWVector("disguiseMins")
	local mins, maxs = ent:GetModelBounds()
	
	local ang = ang or self.ph_prop.angle or Angle() --self.ph_prop:GetAngles() -- self:EyeAngles()
	ang.p = 0
	ang.r = 0
	
	--[[if SERVER then
		--ang.y = ang.y * 0.5
		ang = self.ph_prop.angle or Angle()
	end]]
	
	local nmins, nmaxs = Vector(), Vector(0, 0, maxs.z-mins.z)
	checkCorner(nmins, nmaxs, Vector(maxs.x, maxs.y), ang)
	checkCorner(nmins, nmaxs, Vector(maxs.x, mins.y), ang)
	checkCorner(nmins, nmaxs, Vector(mins.x, mins.y), ang)
	checkCorner(nmins, nmaxs, Vector(mins.x, maxs.y), ang)

	-- print(mins, maxs, nmins, nmaxs)

	return nmins, nmaxs
end
---------------------------------------

function PlayerMeta:SetPropHull( ent )

	if !IsValid( ent ) then return end
		
	-- Just Because
	if ent:GetModel() == "models/kleiner_prop/kleiner.mdl" then return end
		
	local vecHullMin, vecHullMax = self:CalculateRotatedDisguiseMinsMaxs( ent )
	
	self:SetHull( vecHullMin, vecHullMax )
	self:SetHullDuck( vecHullMin, vecHullMax )
	self:SetPos( self:GetPos() - Vector(0,0,vecHullMin.z) )
	self:SetCollisionBounds( vecHullMin, vecHullMax )
	
	if SERVER then
		net.Start( "SetPropHull" )
		net.WriteVector( vecHullMin )
		net.WriteVector( vecHullMax )
		net.Send( self )
	end

end

function PlayerMeta:SetPlayerHull( min, max )

	self:SetHull( min, max )
	self:SetHullDuck( min, max )
	self:SetPos( self:GetPos() - Vector(0,0,min.z) )
	self:SetCollisionBounds( min, max )

end

net.Receive( "SetPropHull", function()

	local min = net.ReadVector()
	local max = net.ReadVector()
	LocalPlayer():SetPlayerHull( min, max )

end )