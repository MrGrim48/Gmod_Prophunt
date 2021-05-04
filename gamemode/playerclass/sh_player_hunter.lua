

DEFINE_BASECLASS("player_default")


-- Create an array to store the player class settings and functions in.
local PLAYER = {}


-- Some settings for the class.
PLAYER.DisplayName			= "Hunter"
PLAYER.WalkSpeed 			= 230
PLAYER.CrouchedWalkSpeed 	= 0.2
PLAYER.RunSpeed				= 230
PLAYER.DuckSpeed			= 0.2
PLAYER.JumpPower			= 250
PLAYER.TeammateNoCollide	= true
PLAYER.DrawTeamRing			= false


-- Called after OnSpawn. Sets the player loadout.
function PLAYER:Loadout()

	if GameState && (GameState.IsState( "PreGame" ) || GameState.IsState( "Waiting" )) then return end
	if hook.Run( "HunterLoadoutDisabled" ) then return end
	
	timer.Simple( 3, function() 
		self.Player:GiveAmmo(64, "Buckshot")
		self.Player:GiveAmmo(255, "SMG1")
		
		self.Player:Give("weapon_shotgun")
		self.Player:Give("weapon_smg1")
		self.Player:Give("weapon_crowbar")
		
		self.Player:SwitchToDefaultWeapon()
		
		timer.Remove( "HunterSpawnGrenade"..self.Player:SteamID64() )		
		timer.Create( "HunterSpawnGrenade"..self.Player:SteamID64(), 57, 1, function()
			if IsValid(self.Player) and self.Player:Alive() then
				self.Player:Give("item_ar2_grenade")
			end
		end)
	end)
	
end


-- Called when player spawns.
function PLAYER:Spawn()
	
	self.Player:SetCustomCollisionCheck( true )

	local oldhands = self.Player:GetHands();
	if (IsValid(oldhands)) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if (IsValid(hands)) then
		hands:DoSetup(self.Player)
		hands:Spawn()
	end	

	local unlock_time = math.Clamp(GAMEMODE.HunterBlindLockTime - (CurTime() - GetGlobalFloat("RoundStartTime", 0)), 10, GAMEMODE.HunterBlindLockTime)
	if GameState && (GameState.IsState( "PreGame" ) || GameState.IsState( "Waiting" )) then unlock_time = 0 end
	if hook.Run( "HunterBlindDisabled" ) then unlock_time = 0 end
	
	if unlock_time > 2 then
		self.Player:Blind(true)
		
		timer.Remove( "HunterLock"..self.Player:SteamID64() )
		timer.Create( "HunterLock"..self.Player:SteamID64(), 0.1, 1, function() self.Player:Lock() end )
		
		timer.Remove( "HunterUnlock"..self.Player:SteamID64() )
		timer.Create( "HunterUnlock"..self.Player:SteamID64(), unlock_time, 1, function()
			if IsValid( self.Player ) and self.Player:GetNWBool( "Blind" ) then
				self.Player:Blind( false )
				self.Player:UnLock()
			end
		end )
	end
	
end


-- Called when a player dies.
function PLAYER:Death(attacker, dmginfo)

	self.Player:CreateRagdoll()
	self.Player:UnLock()
	
	self.Player.PlayerRagdoll = self.Player:GetRagdollEntity()
	timer.Remove( "RagdollDisolve"..self.Player:SteamID64() )
	timer.Create( "RagdollDisolve"..self.Player:SteamID64(), 10, 1, function()
		if IsValid(self.Player.PlayerRagdoll) then
			local dissolver = ents.Create( "env_entity_dissolver" )
			dissolver:SetPos( self.Player.PlayerRagdoll:LocalToWorld(self.Player.PlayerRagdoll:OBBCenter()) )
			dissolver:SetKeyValue( "dissolvetype", 0 )
			dissolver:Spawn()
			dissolver:Activate()
			
			local name = "Dissolving_"..self.Player:SteamID64()
			self.Player.PlayerRagdoll:SetName( name )
			dissolver:Fire( "Dissolve", name, 0 )
			dissolver:Fire( "Kill", self.Player.PlayerRagdoll, 0.10 )
		end
	end )
	
end


-- Register our array of settings and functions as a new class.
player_manager.RegisterClass("player_hunter", PLAYER, "player_default")