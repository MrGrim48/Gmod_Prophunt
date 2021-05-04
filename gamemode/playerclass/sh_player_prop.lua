
local PLAYER = {}

PLAYER.DisplayName			= "Prop"
PLAYER.WalkSpeed 			= 230
PLAYER.CrouchedWalkSpeed 	= 0.2
PLAYER.RunSpeed				= 230
PLAYER.DuckSpeed			= 0.2
PLAYER.JumpPower			= 250
PLAYER.DrawTeamRing			= false


function PLAYER:Loadout()

end


function PLAYER:Spawn()
	
	-- Make sure player model doesn't show up to anyone else.
	self.Player:SetNoDraw(true)
	self.Player:SetCustomCollisionCheck( true )
	
	self.Player.ph_prop = ents.Create("ph_prop")
	self.Player.ph_prop:SetPos( self.Player:GetPos() )
	self.Player.ph_prop:SetAngles( self.Player:GetAngles() )
	self.Player.ph_prop:Spawn()	
	self.Player.ph_prop:SetParent(self.Player)
	self.Player.ph_prop:SetOwner(self.Player)
	
	self.Player.max_health = 100
	
	self.Player:SetViewOffset( Vector(0,0,(self.Player.ph_prop:OBBMaxs().z)*0.95) )
	self.Player:SetViewOffsetDucked( Vector(0,0,(self.Player.ph_prop:OBBMaxs().z)*0.95) )
	
	local propHeight = math.Round(self.Player.ph_prop:OBBMaxs().z-self.Player.ph_prop:OBBMins().z)
	self.Player:SetNWInt( "PropHeight", propHeight )
	
end

-- Called when a player dies.
function PLAYER:Death(attacker, dmginfo)

	self.Player:RemoveProp()
	
end


-- Register our array of settings and functions as a new class.
player_manager.RegisterClass("player_prop", PLAYER, "player_default")