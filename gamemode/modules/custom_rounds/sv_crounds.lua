--[[
sv_crounds.lua

Copyright© Nekom Glew, 2017

--]]

util.AddNetworkString( "CRounds.ActiveRound" )

concommand.Add( "cround_setnextround", function(ply, cmd, args, argStr)
	if ply:CheckGroup( "superadmin" ) then
		if CRounds.Rounds[args[1]] then
			print( "Setting Round", args[1] )
			CRounds.NextRound = args[1]
		else
			print( "no such round" )
		end
	end
end )

local function RollChance()
	if CRounds.NextRound or math.Round(math.random(),1) <= (CRounds.Chance or 0.1) then
		local key, value = CRounds.NextRound, nil
		if !key then repeat //Ignore rolling if a round is forced set
			value, key = table.Random( CRounds.Rounds )
			local condition = nil
			if CRounds.Rounds[key].Condition then condition = CRounds.Rounds[key]:Condition() end
		until( key != CRounds.LastRound and condition != false) end
			
		CRounds.SetRound( key )
		CRounds.NextRound = nil
		CRounds.LastRound = key // Set as the current round to check with later
	end
end
hook.Add( "PreRoundStart", "CRounds.PreRoundStart", RollChance )


local function EndRound()
	timer.Simple( 0.1, function() CRounds.SetRound() end ) //Clear previous round
end
hook.Add( "RoundEndWithResult", "CRounds.RoundEndWithResult", EndRound )