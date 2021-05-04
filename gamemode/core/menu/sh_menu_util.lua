--[[
sh_menu_util.lua

MrGrimm

--]]

if SERVER then

	util.AddNetworkString( "PlayerUpdate" )
	util.AddNetworkString( "FriendsList" )

	hook.Add( "PlayerDisconnected", "Menu.PlayerDisconnected", function( ply )
		net.Start( "PlayerUpdate" )
		net.Broadcast()
	end )
	
	net.Receive( "FriendsList", function( len, ply )
		local listFriends = net.ReadTable()
		local playerRequest = net.ReadEntity()
		if !listFriends then return end
		if !playerRequest then return end
		local players = "no one."
		local playerColor = Color( 255, 255, 255 )
		if #listFriends > 0 then
			players = table.concat( listFriends, ", " )
			playerColor = Color(45, 147, 181)
		end
		playerRequest:PlayerMsg( Color( 255, 255, 0 ), "[PRIVATE] ", Color(45, 147, 181), ply:GetName(), Color( 255, 255, 255 ), " is friends with ", playerColor, players )
	end )
		
	--[[---------------------------------------------------------
	   Name: gamemode:CanJoinTeam()
	   Desc: Returns true if the player can join without unbalancing the teams
	-----------------------------------------------------------]]
	local function CanJoinTeam( ply, newTeam )
	
		for _, pl in pairs( team.GetPlayers( newTeam ) ) do
			if pl:IsBot() then return true end
		end

		local numTeamProps = #team.GetPlayers( TEAM_PROPS ) or 0
		local numTeamHunters = #team.GetPlayers( TEAM_HUNTERS ) or 0
		
		if numTeamHunters == nil || numTeamProps == nil then return false end
		
		if ply:Team() == TEAM_PROPS then 
			numTeamProps = numTeamProps - 1
		elseif ply:Team() == TEAM_HUNTERS then 
			numTeamHunters = numTeamHunters - 1 
		end
		
		-- Team is full
		if (newTeam == TEAM_HUNTERS and numTeamHunters > numTeamProps) or 
		   (newTeam == TEAM_PROPS and numTeamProps > numTeamHunters) then
			return false
		end

		return true

	end

	concommand.Add("jointeam", function (ply, com, args)
		if #args < 1 then return end
		
		local newTeam = tonumber(args[1] or "") or 0
		local forced = tobool(args[2] or false) or false
		
		if newTeam == TEAM_CONNECTING || newTeam == TEAM_UNASSIGNED then return end
		if !team.Valid( newTeam ) then return end
		
		if !CanJoinTeam( ply, newTeam ) && !forced then
			ply:PlayerMsg( Color( 255, 255, 0 ), "[PRIVATE] ", Color( 255, 255, 255 ), "That team is full.")
			return 
		end

		if newTeam != TEAM_SPECTATOR && ( ply.timerLastChanged or 0 ) > CurTime() && !forced && !ply:IsBot() then
			ply:PlayerMsg( Color( 255, 255, 0 ), "[PRIVATE] ", Color( 255, 255, 255 ), "You must wait ", Color(45, 147, 181), math.Round(ply.timerLastChanged - CurTime()) .." more seconds", Color( 255, 255, 255 ), " before changing teams again.")
			return 
		end

		if newTeam != ply:Team() then
			if ply:Team() == TEAM_PROPS then 
				ply:RemoveProp()
			end
		
			ply:KillSilent()
			ply:SetTeam(newTeam)
			if !forced then
				util.Broadcast( Color( 255, 255, 0 ), "[SERVER] ", Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), " has switched teams." )
			end
			ply.timerLastChanged = CurTime() + 5
			
			hook.Run( "PlayerChangedTeam", ply, newTeam )
			
			net.Start( "PlayerUpdate" )
			net.WriteEntity( ply )
			net.WriteInt( newTeam, 32 )
			net.Broadcast()
		end
	end)


	concommand.Add( "autoteam", function (ply, com, args)
		local teams = {
			TEAM_HUNTERS,
			TEAM_PROPS
		}
		
		for i=0, #teams, 1 do
			if ply:Team() == teams[i] then
				table.remove( teams, i )
			end
		end
		
		for i=0, #teams, 1 do
			if !CanJoinTeam(ply, teams[i]) then
				table.remove( teams, i )
				i = i - 1
			end
		end
		
		if !(#teams > 0) then return end
		
		local randTeam = teams[math.random( #teams )]
		ply:ConCommand("jointeam " .. randTeam )
	end)


	concommand.Add("forcemoveteam", function (ply, com, args)
		if #args < 1 then return end

		if not ply:CheckGroup("moderator") then
			ply:PlayerMsg( Color( 255, 255, 0 ), '[PRIVATE] ', Color( 255, 255, 255 ), "You don't have permission to do this." )
			return
		end

		local ent = Entity(tonumber(args[1]) or -1)
		if !IsValid(ent) || !ent:IsPlayer() then return end

		local curTeam = ent:Team()
		local newTeam = tonumber(args[2] or "") or 0
		if newTeam != curTeam then
			ent:SetTeam(newTeam)
			ent:KillSilent()
			if ent.RemoveProp then
				ent:RemoveProp()
			end
			util.Broadcast( Color( 255, 255, 0 ), '[SERVER] ', Color( 255, 0, 0 ), ply:Nick(), Color( 255, 255, 255 ), ' forced team-switch on player ', Color(45, 147, 181), ent:Nick() )
			ply.timerLastChanged = CurTime() + 30 -- Prevent the player from changing teams again too soon
		end
	end)
	
	
	concommand.Add("GetFriends", function( ply, com, args )
		if #args < 1 then return end
		
		local target = Entity(tonumber(args[1]) or -1)
		
		net.Start( "FriendsList" )
		net.WriteEntity( ply )
		net.Send( target )
	end)

else --CLIENT

	net.Receive( "FriendsList", function( len, ply )
		local playerRequest = net.ReadEntity()
		local listFriends = {}
		for _,p in pairs( player.GetAll() ) do
			if p:GetFriendStatus() == "friend" then
				table.insert( listFriends, p:GetName() )
			end
		end
		net.Start( "FriendsList" )
		net.WriteTable( listFriends )
		net.WriteEntity( playerRequest )
		net.SendToServer()
	end )

end