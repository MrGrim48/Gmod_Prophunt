

local function EntityTakeDamage( target, dmg_info )
	
	attacker = dmg_info:GetAttacker()
	
	if GameState.IsState("playing") && target && target:IsPlayer() && target:Alive() && target:Team() == TEAM_PROPS && target.ph_prop then
		if ( dmg_info:GetAttacker():IsPlayer() && dmg_info:GetAttacker():Team() == target:Team() && dmg_info:GetDamageType() != DMG_CRUSH ) then return end
        target.ph_prop:TakeDamageInfo(dmg_info)
        return
    end

	if  IsValid(target) && target:IsPlayer() && target:Team() == TEAM_HUNTERS && IsValid(attacker) && 
		hook.Run( "OverrideHunterDamage", target, dmg_info, attacker ) then
	elseif RoundController.InRound() &&
		target && (target:GetClass() == "prop_physics" || target:GetClass() == "prop_physics_multiplayer") && !target:IsPlayer() && 
		attacker && attacker:IsPlayer() && attacker:Team() == TEAM_HUNTERS && attacker:Alive() && 
		dmg_info:GetDamageType() != DMG_CRUSH then -- Added damage type to prevent dying by walking over props.
	
		attacker:SetHealth(attacker:Health() - GAMEMODE.HunterFirePenalty)
		
		if attacker:Health() <= 0 and attacker:Alive() then
			MsgAll(attacker:Name() .. " felt guilty for hurting so many innocent props and committed suicide\n")
			attacker:Kill()
			net.Start( "PlayerKilledSelf" )
			net.WriteEntity( attacker )
			net.Broadcast()
		end
	end
	
end
hook.Add( "EntityTakeDamage", "Hunters.EntityTakeDamage", EntityTakeDamage )