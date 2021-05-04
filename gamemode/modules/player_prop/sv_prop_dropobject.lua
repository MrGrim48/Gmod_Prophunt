
module( "Props.DropObject", package.seeall )

local function PlayerThink( ply )

	if IsValid(ply) && ply:Team() == TEAM_PROPS then
		if ply:Alive() && !ply:OnGround() then
			ply:DropObject()
		end
	end
	
end
_G.PlayerThink.hookAdd( "Props.DropObject.PlayerThink", PlayerThink )