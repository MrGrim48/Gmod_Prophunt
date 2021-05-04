if SERVER then
	
	hook.Add("Think", "PropHunt_PhPirateShip_Think", function()
		for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do
			if pl && pl:WaterLevel() > 0 && IsValid(pl.ph_prop) && pl:GetNWBool("PhysicsMode",false) then
				--pl:Spawn()
				pl.ph_prop:SetPos( Vector(669, -344, 169) )
			end
		end
	end)
	
end