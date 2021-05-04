
local function PlayerThink( ply )

	-- Hunters drop item when off the ground
	if IsValid(ply) && ply:Team() == TEAM_HUNTERS && !ply:OnGround() then
		ply:DropObject()
	end
	
end
_G.PlayerThink.hookAdd( "Hunters.DropProp", PlayerThink )