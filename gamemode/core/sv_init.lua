--[[
sv_init.lua

MrGrimm

--]]


--[[------------------------------------------------
	Name: Initialize()
	Desc: Called when the gamemode loads and starts.
--]]------------------------------------------------
function GM:Initialize()

end

--[[------------------------------------------------
	Name: InitPostEntity()
	Desc: Removes items and weapons from the map
		after entities have spawned.
--]]------------------------------------------------
function GM:InitPostEntity()
	
	if !(GAMEMODE.RemoveWeaponsFromMap or true) then
		for _, wep in pairs(ents.FindByClass("weapon_*")) do
			wep:Remove()
		end
	end
	
	if !(GAMEMODE.RemoveItemsFromMap or true) then
		for _, item in pairs(ents.FindByClass("item_*")) do
			item:Remove()
		end
	end
	
end

--[[------------------------------------------------
	Name: PlayerInitialSpawn()
	Desc: Sets the player as a spectator.
--]]------------------------------------------------
function GM:PlayerInitialSpawn( ply )
	
	ply:SetTeam( TEAM_SPECTATOR )

end