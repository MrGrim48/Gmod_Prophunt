--[[
sv_round_controller.lua

MrGrimm

--]]

RoundController = {}

function RoundController.SetInRound( b ) SetGlobalBool( "InRound", b ) end
function RoundController.InRound() return GetGlobalBool( "InRound", false ) end

--[[------------------------------------------------
	Name: SetRoundResult
	Desc: Sets the text to display when the round ends
--]]------------------------------------------------
function RoundController.SetRoundResult( i, resulttext ) 
	SetGlobalInt( "RoundResult", i ) 
	SetGlobalString( "RRText", tostring(resulttext) ) 
end

--[[------------------------------------------------
	Name: ClearRoundResult
	Desc: Removes the post round results text
--]]------------------------------------------------
function RoundController.ClearRoundResult() 
	SetGlobalEntity( "RoundWinner", NULL ) 
	SetGlobalInt( "RoundResult", 0 ) 
	SetGlobalString( "RRText", "" ) 
end

--[[----------------------------------------------
	Name: IsEnoughPlayers()
	Desc: Starts the game if there is at least 1 player in each team.
--]]------------------------------------------------
function RoundController.IsEnoughPlayers()

	if not GameState.IsState( "Waiting" ) then return end

	local function teamHumanPlayers(id)
		local humans = {}
		for _, ply in pairs( team.GetPlayers(id) ) do
			if !ply:IsBot() then
				table.insert( humans, ply )
			end
		end
		return humans
	end
	
	if ( team.NumPlayers( TEAM_PROPS ) > 0 && team.NumPlayers( TEAM_HUNTERS ) > 0 &&
		( #teamHumanPlayers(TEAM_PROPS) > 0 || #teamHumanPlayers(TEAM_HUNTERS) > 0 ) ) then
		RoundController.StartPreGame()
	end

end
hook.Add( "PlayerChangedTeam", "RoundController.IsEnoughPlayers", RoundController.IsEnoughPlayers )


--[[------------------------------------------------
	Name: StartPreGame()
	Desc: Called before the game starts and creates a timer.
--]]------------------------------------------------
function RoundController.StartPreGame()

	GameState.SetState( "PreGame" )
	
	-- PreRoundStart has an additional timer
	SetGlobalFloat( "PreGameStartTime", CurTime() + GAMEMODE.RoundPreGameLength + GAMEMODE.RoundPreStartTime )
	
	timer.Simple( GAMEMODE.RoundPreGameLength, function()
		RoundController.PreRoundStart( GetGlobalInt("RoundNumber",1) )
		SetGlobalFloat( "PreGameStartTime", 0 )
	end )
	
end


--[[------------------------------------------------
	Name: OnPreRoundStart()
	Desc: Called before the start of each round.
		Custom code goes here
--]]------------------------------------------------
function RoundController.OnPreRoundStart( num )

	GameState.SetState( "PreRound" )
	
	game.CleanUpMap()
	hook.Call( "PreRoundStart" )
	
	-- Prevent team swap on the first round
	if GetGlobalInt("RoundNumber") != 1 && !hook.Run("OverridePreRound") then
		for _, ply in pairs(player.GetAll()) do
			if ply:Team() == TEAM_PROPS || ply:Team() == TEAM_HUNTERS then
				if ply:Team() == TEAM_PROPS then
					ply:SetTeam(TEAM_HUNTERS)
				else
					ply:SetTeam(TEAM_PROPS)
				end
				
				ply:ChatPrint("Teams have been swapped!")
			end
		end
		
		--Swap score
		local tempHunterScore = team.GetScore( TEAM_HUNTERS )
		local tempPropScore = team.GetScore( TEAM_PROPS )
		
		team.SetScore( TEAM_HUNTERS, tempPropScore )
		team.SetScore( TEAM_PROPS, tempHunterScore )
	end
	
	-- Reset players.
	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()
	UTIL_FreezeAllPlayers()

end

--[[------------------------------------------------
	Name: PreRoundStart()
	Desc: Called at the start of each round.
--]]------------------------------------------------
function RoundController.PreRoundStart( round )

	if( round > (GAMEMODE.RoundLimit or 10) ) then
		RoundController.EndOfGame( true )
		return
	end

	timer.Simple( GAMEMODE.RoundPreStartTime, function() RoundController.RoundStart() end )
	SetGlobalInt( "RoundNumber", round )
	SetGlobalFloat( "RoundStartTime", CurTime() + GAMEMODE.RoundPreStartTime )
	
	RoundController.ClearRoundResult()
	RoundController.OnPreRoundStart( GetGlobalInt( "RoundNumber" ) )
	RoundController.SetInRound( true )

end

--[[------------------------------------------------
	Name: RoundStart()
	Desc: When the round is ready to start.
--]]------------------------------------------------
function RoundController.RoundStart()

	GameState.SetState( "Playing" )

	local roundNum = GetGlobalInt( "RoundNumber" )
	local roundDuration = GAMEMODE.RoundLength
	
	UTIL_UnFreezeAllPlayers()

	timer.Create( "RoundEndTimer", roundDuration, 0, function() RoundController.RoundTimerEnd() end )
	
	SetGlobalFloat( "RoundEndTime", CurTime() + roundDuration )
	
	hook.Call( "PostRoundStart" )
	
end


--[[------------------------------------------------
	Name: RoundEndWithResult()
	Desc: Round ended with the winning Team.
--]]------------------------------------------------
function RoundController.RoundEndWithResult( Team, resulttext )

	resulttext = resulttext or ""
	
	RoundController.SetRoundResult( Team, resulttext )
	RoundController.RoundEnd()
	
	team.AddScore( Team, 1 )
	
	hook.Run( "RoundEndWithResult", Team )
	
end

--[[------------------------------------------------
	Name: RoundEnd()
	Desc: Round has ended. Start of cleanup.
--]]------------------------------------------------
function RoundController.RoundEnd()

	if ( !RoundController.InRound() ) then 
		-- if someone uses RoundEnd incorrectly then do a trace.
		MsgN("WARNING: RoundEnd being called while gamemode not in round...")
		debug.Trace()
		return 
	end
	
	GameState.SetState( "endround" )

	RoundController.SetInRound( false )
	
	timer.Remove( "RoundEndTimer" )
	timer.Remove( "CheckRoundEnd" )
	SetGlobalFloat( "RoundEndTime", -1 )
	
	-- Remove the dependancy the prop player may have on their prop
	timer.Simple( GAMEMODE.RoundPostLength*0.5, function() 
		for _,ply in pairs( player.GetAll() ) do
			if IsValid( ply.ph_prop ) && ply:GetNWBool( "PhysicsMode", false ) then
				ply:SetNWBool( "PhysicsMode", false )
				SetPhysicsMode( ply, false )
				ply.ph_prop:Remove()
			end
		end
	end )
	timer.Simple( GAMEMODE.RoundPostLength, function() RoundController.PreRoundStart( GetGlobalInt( "RoundNumber" )+1 ) end )
	
	for _, pl in pairs(team.GetPlayers(TEAM_HUNTERS)) do
	
		pl:Blind(false)
		pl:UnLock()
		
	end
	
end

--[[------------------------------------------------
	Name: GetTeamAliveCounts()
	Desc: Returns the number of players still alive in total.
--]]------------------------------------------------
function RoundController.GetTeamAliveCounts()

	local TeamCounter = {}

	for k,v in pairs( player.GetAll() ) do
		if ( v:Alive() && v:Team() > 0 && v:Team() < 1000 ) then
			TeamCounter[ v:Team() ] = TeamCounter[ v:Team() ] or 0
			TeamCounter[ v:Team() ] = TeamCounter[ v:Team() ] + 1
		end
	end

	return TeamCounter

end

--[[------------------------------------------------
	Name: CheckPlayerDeathRoundEnd()
	Desc: For round based games that end when a team is dead.
--]]------------------------------------------------
function RoundController.CheckPlayerDeathRoundEnd()

	if !RoundController.InRound() then return end

	local teams = RoundController.GetTeamAliveCounts()

	if table.Count(teams) == 0 then
	
		RoundController.RoundEndWithResult(1001, "Draw, everyone loses!")
		return
		
	end

	if table.Count(teams) == 1 then
	
		local team_id = table.GetFirstKey(teams)
		RoundController.RoundEndWithResult(team_id, team.GetName(team_id).." win!")
		return
		
	end
	
end
hook.Add( "PlayerDisconnected", "RoundCheck_PlayerDisconnect", function() timer.Simple( 0.2, function() RoundController.CheckPlayerDeathRoundEnd() end ) end )
hook.Add( "PostPlayerDeath", "RoundCheck_PostPlayerDeath", function() timer.Simple( 0.2, function() RoundController.CheckPlayerDeathRoundEnd() end ) end )

--[[------------------------------------------------
	Name: RoundTimerEnd()
	Desc: This is called when the round time ends (props win).
--]]------------------------------------------------
function RoundController.RoundTimerEnd()

	if !RoundController.InRound() then
		return
	end
	
	-- If the timer reached zero, then we know the Props team won beacause they didn't all die.
	local endRoundTeam = hook.Run( "TeamWinEndRoundTimer" )
	endRoundTeam = endRoundTeam or TEAM_PROPS
	RoundController.RoundEndWithResult( endRoundTeam, team.GetName(endRoundTeam).." win!" )
	
end

--[[------------------------------------------------
	Name: EndOfGame()
	Desc: End of the game. Call for a map vote.
--]]------------------------------------------------
function RoundController.EndOfGame()

	GameState.SetState( "EndGame" )
	
	if RTV then 
		RTV.Start()
	else
		RunConsoleCommand("changelevel", game.GetMap())
	end
	
end