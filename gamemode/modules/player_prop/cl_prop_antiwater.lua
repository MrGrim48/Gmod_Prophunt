
local IgnoreMaps = {
	ph_underwataaa = true
}

if IgnoreMaps[game.GetMap()] then return end

-- Config
local timerCheck = 2


timer.Create( "PropAntiWater", timerCheck, 0, function()
	for _, ply in pairs( team.GetPlayers(TEAM_PROPS) ) do
		if IsValid(ply) && ply:Alive() && IsValid(ply.ph_prop) then
			
			if ply.ph_prop:WaterLevel() == 3 && !ply.IsSubmerged then
				ply.IsSubmerged = true
				
			elseif ply.ph_prop:WaterLevel() < 3 && ply.IsSubmerged then
				ply.IsSubmerged = false
				
			end
			
		end
	end
end )

hook.Add( "PreDrawHalos", "PropAntiWater.PreDrawHalos", function()

	for _, ply in pairs( team.GetPlayers(TEAM_PROPS) ) do
		if IsValid(ply) && ply:Alive() && IsValid(ply.ph_prop) && ply.IsSubmerged then
			halo.Add( {ply.ph_prop}, Color(255,255,255),2,2,1,true,true )
		end
	end

end )