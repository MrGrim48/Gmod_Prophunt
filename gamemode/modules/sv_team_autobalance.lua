/*
sv_team_autobalance.lua

Copyright© Nekom Glew, 2017

Works specifically for Prop Hunt.
Moves a random player from a team that is unbalanced.
Further work could be done to choose a player based on their kills
and balance the teams to a matching average of kills.

*/

local function BalanceTeam()

	local numProps = team.NumPlayers( TEAM_PROPS )
	local numHunters = team.NumPlayers( TEAM_HUNTERS )
	local HighestPlayerTeam = nil
	local LowestPlayerTeam = nil
	
	if !numProps || numProps == 0 then return end
	if !numHunters || numHunters == 0 then return end
	
	if numProps > (numHunters+1) then
		HighestPlayerTeam = TEAM_PROPS
		LowestPlayerTeam = TEAM_HUNTERS
	elseif numHunters > (numProps+1) then
		HighestPlayerTeam = TEAM_HUNTERS
		LowestPlayerTeam = TEAM_PROPS
	end
	
	if HighestPlayerTeam && LowestPlayerTeam then
		
		// Moves a random player to the team with the least amount of players
		// until it evens out or the previously lowest numbered team is no longer
		// the lowest.		
		local hardLimit = 10
		local i = 1
		while team.NumPlayers(HighestPlayerTeam) > (team.NumPlayers(LowestPlayerTeam)+1) && i < hardLimit do
			local players = team.GetPlayers( HighestPlayerTeam )
			local randIndex = math.random(team.NumPlayers(HighestPlayerTeam))
			local ply = players[randIndex]
			--ply:ConCommand("jointeam " .. LowestPlayerTeam .. " true" )
			ply:KillSilent()
			ply:SetTeam( LowestPlayerTeam )
			util.Broadcast( Color( 255, 255, 0 ), "[AutoBalance] ", Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), " has switched teams." )
			i = i + 1
		end
		
		if i == hardLimit then
			print( "[AutoBalance] Loop Limit Reached" )
			print( debug.traceback() )
		end
		
	end

end
hook.Add( "PreRoundStart", "Team.AutoBalance.BalanceTeam", BalanceTeam )