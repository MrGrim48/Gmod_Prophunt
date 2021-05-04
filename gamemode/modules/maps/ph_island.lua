
if SERVER then

	last_hurt_interval = 0
	
	hook.Add("Think", "PropHunt_ph_island_Think", function()
		if last_hurt_interval + 1 < CurTime() then
			for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do
				if IsValid(pl) && pl:WaterLevel() >= 1 && pl:Alive() && pl:Health() > 1 then
					pl:SetHealth(pl:Health() - 1)
				end
			end
			
			last_hurt_interval = CurTime()
		end
	end)
	
end