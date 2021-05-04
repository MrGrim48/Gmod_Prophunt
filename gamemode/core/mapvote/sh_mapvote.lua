/*
sh_mapvote.lua

Copyright© Nekom Glew, 2017

This was not made by me, I don't remember whom.

*/

module( "MapVote", package.seeall )

Config = {
	MapLimit = 22,
	TimeLimit = 28,
	AllowCurrentMap = false,
}

function HasExtraVotePower( ply )
	-- Example that gives admins more voting power
	if ply:IsAdmin() then
		return true
	end

	return false
end


CurrentMaps = {}
Votes = {}

Allow = false

UPDATE_VOTE = 1
UPDATE_WIN = 3

