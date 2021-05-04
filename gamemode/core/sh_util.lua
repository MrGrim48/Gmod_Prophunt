--[[
sh_util.lua

MrGrimm

--]]


-- Returns the time limit
function GM:GetTimeLimit()

	if (GAMEMODE.GameLength > 0) then
		return GAMEMODE.GameLength * 60;
	end
	
	return -1;
	
end


function util.ToMinutesSeconds(seconds)
	local minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60

    return string.format("%02d:%02d", minutes, math.floor(seconds))
end


function GM:PlayerFootstep( ply, pos, foot, sound, volume, filter )
	return ply:Team() == TEAM_PROPS
end


-- Respawn all non-spectators, providing they are allowed to spawn. 
function UTIL_SpawnAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:Spawn()
		end
	end

end


-- Clears all weapons and ammo from all players.
function UTIL_StripAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:StripWeapons()
			v:StripAmmo()
		end
	end

end


-- Freeze all non-spectators.
function UTIL_FreezeAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:Freeze( true )
		end
	end

end


--  Removes frozen flag from all players.
function UTIL_UnFreezeAllPlayers()

	for k,v in pairs( player.GetAll() ) do
		if ( v:Team() != TEAM_SPECTATOR && v:Team() != TEAM_CONNECTING ) then
			v:Freeze( false )
		end
	end

end

-- Prevent killing players when there is not enough players
hook.Add( "IsSpawnpointSuitable", "SpawnHandler.IsSpawnpointSuitable", function( ply, spawnpoint, makeSuitable )

	local Pos = spawnpoint:GetPos()
	local Ents = ents.FindInBox( Pos + Vector( -16, -16, 0 ), Pos + Vector( 16, 16, 72 ) )

	if ( ply:Team() == TEAM_SPECTATOR || ply:Team() == TEAM_UNASSIGNED ) then return true end

	local Blockers = 0

	for k, v in pairs( Ents ) do
		if ( IsValid( v ) && v:GetClass() == "player" && v:Alive() ) then

			Blockers = Blockers + 1

			if ( makeSuitable ) then
				--v:Kill() --This line ends up killing the player to make room.
				-- Since hunters do not collide with each other, this is not needed.
				return true
			end

		end
	end

	if ( bMakeSuitable ) then return true end
	if ( Blockers > 0 ) then return false end
	return true

end )