
-- Network String to play taunts from taunt menu
util.AddNetworkString( "TauntOpenMenu" )
util.AddNetworkString( "TauntMenuDestroy" )
util.AddNetworkString( "SendTauntInfo" )

util.AddNetworkString( "PlayTaunt" )

Taunt.TauntDelay = 5
Taunt.Taunts = {}

local function ResetTauntDelayOnSpawn( ply )
	ply:SetNWInt( "TauntDelay", TauntDelay ) --For the client
	ply:SetNWInt( "TauntRateOverride", nil )
end
hook.Add( "PlayerSpawn", "Taunt.ResetTauntDelayOnSpawn", ResetTauntDelayOnSpawn )

local function InitializeTaunts()
	SearchTauntFiles( TEAM_HUNTERS, "prophunt_taunts/hunters" )
	SearchTauntFiles( TEAM_PROPS, "prophunt_taunts/props" )
	
	--SearchTauntFiles( TEAM_HUNTERS, "huntersvip", "vip_user" )
	--SearchTauntFiles( TEAM_PROPS, "propsvip", "vip_user" )
end
hook.Add( "Initialize", "Taunt.InitializeTaunts", InitializeTaunts )


--[[--------------------------------------------------------------
	Name: SearchTauntFiles
	Desc: Searches the specified folder for taunt .wav files
--]]--------------------------------------------------------------
function SearchTauntFiles( Team, folder, group )
	if !team.Valid( Team ) then return end
	if Team == TEAM_SPECTATOR || Team == TEAM_UNASSIGNED || Team == TEAM_CONNECTING then return end
	if !folder || type(folder) != "string" then return end
	
	local files, folders = file.Find( "sound/"..folder.."/*.wav", "GAME" )
	if files && #files > 0 then
		local newFiles = {}
		for _, name in pairs( files ) do
			local filePath = folder.."/"..name
			table.insert( newFiles, filePath )
			resource.AddSingleFile( "sound/"..filePath )
		end
		
		group = group || "normal"
		if !Taunt.Taunts[group] then Taunt.Taunts[group] = {} end
		if !Taunt.Taunts[group][Team] then Taunt.Taunts[group][Team] = {} end
		Taunt.Taunts[group][Team] = newFiles
	end
end


--[[--------------------------------------------------------------
	Name: PlayerInitialSpawn
	Desc: Send the player the taunts info
--]]--------------------------------------------------------------
local queuedPlayers = {}
local function PlayerInitialSpawn( ply )
	if !table.HasValue(queuedPlayers,ply) then
		timer.Simple( 5, function()
			print( ply, IsValid(ply) )
			if IsValid( ply ) then table.insert( queuedPlayers, ply ) end
		end )
	end
end
hook.Add( "PlayerInitialSpawn", "Taunt.PlayerInitialSpawn", PlayerInitialSpawn )

local coroutineTaunts
hook.Add( "Think", "Taunt.SendingTaunts", function()
	 if next(queuedPlayers) && (!coroutineTaunts || !coroutine.resume( coroutineTaunts )) then
		coroutineTaunts = coroutine.create( function()
		
			for _, ply in pairs( queuedPlayers ) do
				for Group,gTable in pairs( Taunt.Taunts ) do
					for Team,tTable in pairs( Taunt.Taunts[Group] ) do
						for ID,taunt in pairs( Taunt.Taunts[Group][Team] ) do
							net.Start( "SendTauntInfo" )
							net.WriteString( Group )
							net.WriteInt( Team, 32 )
							net.WriteInt( ID, 32 )
							net.WriteString( taunt )
							net.Send( ply )
							coroutine.yield()
						end
					end
				end
				table.RemoveByValue( queuedPlayers, ply )
			end
			
		end )
	end
end )


--[[--------------------------------------------------------------
	Name: PlayTaunt
	Desc: Called when a player plays a taunt from the taunt menu
--]]--------------------------------------------------------------
net.Receive( "PlayTaunt", function( len, ply ) 

	local Group = net.ReadString()
	local Team = net.ReadInt(32)
	local ID = net.ReadInt(32)
	local Duration = net.ReadInt(32)
	local Pitch = net.ReadInt(32)
	
	if Taunt.Taunts[Group] && Taunt.Taunts[Group][Team] && ply:GetNWInt("LastTauntTime") + ply:GetNWInt("TauntRateOverride",TauntDelay) <= CurTime() then
		
		if Group != "normal" && !ply:CheckGroup( Group ) then
			ply:PlayerMsg( Color(255,255,0), "[PRIVATE] ", Color(255,255,255), "Cannot play taunts from this list." )
			return
		end
		
		if ID && ID != 0 && Taunt.Taunts[Group][Team][ID] && ply:GetNWString("LastTauntName") == Taunt.Taunts[Group][Team][ID] then
			ply:PlayerMsg( Color(255,255,0 ), "[PRIVATE] ", Color(255,255,255), "Cannot play the same taunt in a row." )
			return
		end
		
		if ply:Team() != Team then
			ply:PlayerMsg( Color(255,255,0 ), "[PRIVATE] ", Color(255,255,255), "Wrong team for that taunt." )
			return
		end
	
		local targetEnt = ply
		if ply:IsPlayer() && ply:Team() == TEAM_PROPS && ply.ph_prop then
			targetEnt = ply.ph_prop
		end
		
		if !ID || ID == 0 then
			Taunt.PlayRandomTaunt( targetEnt, Pitch )
		elseif Taunt.Taunts[Group][Team][ID] then
			Taunt.PlayTaunt( targetEnt, Taunt.Taunts[Group][Team][ID], Pitch, Duration )
		end
	end

end )

--[[--------------------------------------------------------------
	Name: TauntButton
	Desc: When a player presses F3 to Taunt
--]]--------------------------------------------------------------
local function TauntButton( ply )

	if ply:Alive() && (ply:Team() == TEAM_HUNTERS || ply:Team() == TEAM_PROPS) then
		if ply:GetInfoNum( "taunt_random", 1 ) == 1 then
			if (ply:GetNWInt("LastTauntTime")) + ply:GetNWInt("TauntRateOverride",TauntDelay) <= CurTime() then
				Taunt.PlayRandomTaunt( ply )
			end
		else
			net.Start( "TauntOpenMenu" )
			net.Send( ply )
		end
	end	
	
end
hook.Add( "ShowSpare1", "Players.TauntButton", TauntButton )
hook.Add( "PlayerSay", "Players.TauntCommand", function( ply, msg, teamChat )
	if msg == "!taunt" or msg == "!taunts" then TauntButton( ply ) end
end )

--[[--------------------------------------------------------------
	Name: CloseMenuOnDeath
	Desc: Destroys the taunt menu on death so it loads the taunts relavent to their team
--]]--------------------------------------------------------------
local function CloseMenuOnDeath( ply )
	if IsValid(ply) then
		net.Start( "TauntMenuDestroy" )
		net.Send( ply )
	end
end
hook.Add( "PlayerDeath", "Taunt.RemoveOnDeath", CloseMenuOnDeath )
hook.Add( "PlayerChangedTeam", "Taunt.RemoveOnChangeTeam", CloseMenuOnDeath )
hook.Add( "PreRoundStart", "Taunt.RemoveOnNewRound", CloseMenuOnDeath )