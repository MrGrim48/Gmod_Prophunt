--[[
sv_player.lua

MrGrimm

--]]

module( "Players", package.seeall )

util.AddNetworkString( "ResetHull" )
util.AddNetworkString( "SetPropHull" )

local DeathLingerTime = 4

--[[------------------------------------------------
	Name: PlayerDeath()
	Desc: Run the OnDeath function for the class.
--]]------------------------------------------------
hook.Add( "PlayerDeath", "PH.Players.PlayerDeath", function( victim, inflicter, attacker )
	player_manager.RunClass( victim, "Death", attacker )
end )

--[[------------------------------------------------
	Name: RemoveProp()
	Desc: Removes the prop of a player if it exists.
--]]------------------------------------------------
local function RemoveProp( ply )
	if IsValid( ply ) then
		ply:RemoveProp()
	end
end
hook.Add( "PlayerDisconnected", "PH.Players.PlayerDisconnected", RemoveProp)

--[[------------------------------------------------
	Name: PlayerShouldTakeDamage()
	Desc: Prevent team kills.
--]]------------------------------------------------
function GM:PlayerShouldTakeDamage( ply, attacker )

	if IsValid(ply) && ply:IsPlayer() && IsValid(attacker) && attacker:IsPlayer() && ply:Team() == attacker:Team() then
		return false
	end
	
end

--[[------------------------------------------------
	Name: PlayerCanPickupWeapon()
	Desc: Allow only hunters to pick up weapons.
--]]------------------------------------------------
function GM:PlayerCanPickupWeapon( ply, ent )
	
	local pickup = hook.Run( "WeaponPickup", ply, ent )
	if pickup then return pickup end
 	return ply:Team() == TEAM_HUNTERS
	
end

--[[------------------------------------------------
	Name: PlayerSetModel()
	Desc: Sets the players model.
--]]------------------------------------------------
function GM:PlayerSetModel( ply )

	local player_model = "models/Gibs/Antlion_gib_small_3.mdl"
	--local player_model = "models/kleiner_prop/kleiner.mdl"
	
	if ply:Team() == TEAM_HUNTERS then
		player_model = "models/player/combine_super_soldier.mdl"
	end
	
	util.PrecacheModel(player_model)
	ply:SetModel(player_model)
	
end

--[[------------------------------------------------
	Name: PlayerSpawn()
	Desc: Called when a player spawns.
--]]------------------------------------------------
function PlayerSpawn( ply )

	-- Set the player class based on team
	if ply:Team() == TEAM_HUNTERS then
		player_manager.SetPlayerClass( ply, "player_hunter" )
	elseif ply:Team() == TEAM_PROPS then
		player_manager.SetPlayerClass( ply, "player_prop" )
	end
	
	ply:Blind(false)
	ply:RemoveProp()
	ply:UnLock()
	ply:ResetHull()
	local mins,maxs = ply:GetHull()
	ply:SetViewOffset( Vector(0,0,maxs.z) )
	ply:SetViewOffsetDucked( Vector(0,0,maxs.z*0.4) )
	
	-- Reset the hull clientside.
	net.Start( "ResetHull" )
	net.Send( ply )
	
end
hook.Add("PlayerSpawn", "PH.Players.PlayerSpawn", PlayerSpawn)

--[[------------------------------------------------
	Name: PlayerDeathThink()
	Desc: Allow players to spawn PreGame.
		Make the dead player an observer.
--]]------------------------------------------------
function GM:PlayerDeathThink( ply )	

	if GameState && (GameState.IsState( "Waiting" ) || GameState.IsState( "PreGame" )) && !ply:Alive() && ply:KeyDown( IN_JUMP ) then
		ply:Spawn()
	end

	ply.DeathTime = ply.DeathTime or CurTime()
	local timeDead = CurTime() - ply.DeathTime
	
	-- If we're in deathcam mode, promote to a generic spectator mode
	if ( DeathLingerTime > 0 && timeDead > DeathLingerTime && ( ply:GetObserverMode() == OBS_MODE_FREEZECAM || ply:GetObserverMode() == OBS_MODE_DEATHCAM ) ) then
		ply:BecomeObserver()
	end
	
end

--[[------------------------------------------------
	Name: PostPlayerDeath()
	Desc: Sets a player into deathcam mode when they die.
--]]------------------------------------------------
function GM:PostPlayerDeath( ply )

	if ( ply:GetObserverMode() == OBS_MODE_NONE ) then
		ply:Spectate( OBS_MODE_DEATHCAM )
	end	
	
end

--[[------------------------------------------------
	Name: GetFallDamage()
	Desc: Prevent Fall Damage.
--]]------------------------------------------------
function GM:GetFallDamage( ply, flFallSpeed )
	return 0
end

--[[------------------------------------------------
	Name: CanPlayerSuicide()
	Desc: Prevent Suicide.
--]]------------------------------------------------
function GM:CanPlayerSuicide( ply )
	local nearby = ents.FindInSphere( ply:GetPos(), 500 )
	for _, ent in pairs( nearby ) do
		if IsValid(ent) and ent:IsPlayer() and ent:Team() == TEAM_HUNTERS and IsValid(ply) and ply:Team()==TEAM_PROPS then
			return false
		end
	end
	return true
end

--[[------------------------------------------------
	Name: PlayerShouldTaunt()
	Desc: Prevent dancing during a round.
--]]------------------------------------------------
function GM:PlayerShouldTaunt( ply, act )
	return !GameState.IsState( "Playing" )
end
