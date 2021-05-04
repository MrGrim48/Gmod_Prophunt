--[[
sh_lastpropstanding.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Last Prop Standing"
ROUND.MaxHunters = 3
ROUND.NumPlayersPerHunter = 10
ROUND.MinPlayers = 4

function ROUND:Condition()
	return (#team.GetPlayers(TEAM_HUNTERS) + #team.GetPlayers(TEAM_PROPS)) > ROUND.MinPlayers
end

function ROUND:OverridePreRound()
	self.OldHunters = team.GetPlayers( TEAM_HUNTERS )
	self.OldProps = team.GetPlayers( TEAM_PROPS )
	self.SettingUpTeam = true
	
	local allPlayers = self.OldHunters
	table.Add( allPlayers, self.OldProps )
	local numHunters = math.Clamp( math.floor(#allPlayers / ROUND.NumPlayersPerHunter), 1, ROUND.MaxHunters )
	
	// I'm too stupid to remember how lua loops work
	local i = 1
	while i <= numHunters do
		local hunter = table.remove( allPlayers, math.Round( math.random(1, #allPlayers) ) )
		if hunter:Team() != TEAM_HUNTERS then
			hunter:KillSilent()
			hunter:SetTeam( TEAM_HUNTERS )
			hunter:Spawn()
		end
		
		i = i + 1
	end
	
	for _, ply in pairs( allPlayers ) do
		if ply:Team() != TEAM_PROPS then
			ply:KillSilent()
			ply:SetTeam( TEAM_PROPS )
			ply:Spawn()
		end
	end
	
	self.SettingUpTeam = false
	
	return true
end 

function ROUND:PropKilled( ply, inflictor, attacker )
	if GameState.IsState("Playing") and !self.SettingUpTeam then timer.Simple( 3, function() -- Check if we are in round before the timer
		if IsValid(ply) and ply:Team() == TEAM_PROPS and GameState.IsState("Playing") then -- Check if we are still in the round after
			ply:SetTeam( TEAM_HUNTERS )
			ply:Spawn()
		end
	end ) end
end

function ROUND:EndRound()
	-- Group the players to how they were before.
	local allPlayers = team.GetPlayers(TEAM_HUNTERS)
	table.Add( allPlayers, team.GetPlayers(TEAM_PROPS) )
	for _, ply in pairs( allPlayers ) do
		if self.OldHunters and table.HasValue( self.OldHunters, ply ) and ply:Team() != TEAM_HUNTERS then
			ply:SetTeam( TEAM_HUNTERS )
		elseif self.OldProps and table.HasValue( self.OldProps, ply ) and ply:Team() != TEAM_PROPS then 
			ply:SetTeam( TEAM_PROPS )
		end
	end	
end


CRounds.AddRound( ROUND )