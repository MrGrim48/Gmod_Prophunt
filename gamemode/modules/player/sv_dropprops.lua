
--[[
	Makes the player drop the prop they are holding to prevent prop surfing
--]]
local function DropProp( ply )
	if IsValid(ply) && !ply:OnGround() then
		ply:DropObject()
	end
end
PlayerThink.hookAdd( "Player.DropProp", DropProp )