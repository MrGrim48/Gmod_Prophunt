/*
cl_vgui_scoreboard_player.lua

Copyright© Nekom Glew, 2017

*/

local PANEL = {}

local icon_shield = Material( "icon16/shield.png" )
local icon_muted = Material( "icon16/sound_mute.png" )

function PANEL:Paint()
end


function PANEL:SetupPlayer( ply )

	local plyButton = vgui.Create( "DButton", self )
	plyButton:SetText( "" )
	plyButton:SetPos( 0, 4 )
	plyButton:SetSize(self:GetWide(), 36)
	plyButton.ply = ply
	plyButton.Paint = function(self, w, h)
		draw.RoundedBox( 0, 0, 0, w, h, Color(40,40,40) ) 
		if (ply:IsSuperAdmin()) then
			draw.RoundedBoxEx(0, w-25, 0, 28, h, Color(0, 150, 255), true, false, true)
			surface.SetMaterial(icon_shield)
			surface.SetDrawColor(255,255,255)
			surface.DrawTexturedRect(w-15 - (28-16)/2, (36-16)/2, 16, 16)
		end				
		
		if not IsValid(ply) then return end
		
		local color = Color(0,200,50)
		if not ply:Alive() then color = Color(255,0,0) end
		if ply:Team() != TEAM_SPECTATOR then draw.RoundedBoxEx(0, 40, 0, 10, h, color, false, true, false, true) end
		draw.SimpleText(ply:Nick(), "Menu.ScoreBoard", 70, 10, Color(255,255,255), 0, 2)
		draw.SimpleText(ply:GetUserGroup(), "Menu.ScoreBoard", w - 300, 10, Color(255,255,255), 0, 2)
		draw.SimpleText(ply:Ping(), "Menu.ScoreBoard", w - 30, 10, Color(255,255,255), 2, 2)
		draw.SimpleText(ply:Frags().." / "..ply:Deaths(), "Menu.ScoreBoard", w - 110, 10, Color(255,255,255), 2, 2)
		
		if ply:IsMuted() then
			surface.SetMaterial( icon_muted )
			surface.SetDrawColor( Color( 255, 255, 255 ) )
			surface.DrawTexturedRect( 40, 4, 16, 16 )
		end
	end
	plyButton.DoRightClick = function( self )
		self:GetParent():playerMenu( self.ply )
	end
	
	local avatar = vgui.Create( "AvatarImage", self )
	avatar:SetSize( 40, 40 )
	avatar:SetPos( 0, 2 )
	avatar:SetPlayer( ply )	
	
	self:SizeToChildren( true, true )

end


function PANEL:playerMenu( ply )
	
	local PlayerlistMenu = DermaMenu()
	if not IsValid(ply) then return end
	if not IsValid(LocalPlayer()) then return end
	
	-- Mute / Unmute
	if ply != LocalPlayer() then
		local OptionTitleMute = "Mute"
		if ply:IsMuted() then
			OptionTitleMute = "Unmute"
		end
		local OptionMute = PlayerlistMenu:AddOption( OptionTitleMute )
		OptionMute:SetIcon("icon16/sound_mute.png")
		function OptionMute:DoClick()
			if IsValid(ply) then ply:SetMuted(!ply:IsMuted()) end
		end
		
		local ProfileButton = PlayerlistMenu:AddOption( "Profile" )
		ProfileButton:SetIcon("icon16/user.png")
		function ProfileButton:DoClick()
			if IsValid(ply) then ply:ShowProfile() end
		end
		
		local FriendButton = PlayerlistMenu:AddOption( "Friends" )
		FriendButton:SetIcon("icon16/group.png")
		function FriendButton:DoClick()
			RunConsoleCommand("GetFriends", ply:EntIndex())
		end
		
		PlayerlistMenu:AddSpacer()
	end
	
	-- Junior Staff Commands
	if LocalPlayer():CheckGroup( Menu.Enum.TRIALMODERATOR ) or LocalPlayer():IsAdmin() then
	
		-- Server Mute
		local muteCommand = "Mute"
		if ply:GetNWBool( "ulx_muted", false ) then muteCommand = "UnMute" end
		local ButtonServerMute = PlayerlistMenu:AddOption( "Server " .. muteCommand )
		ButtonServerMute:SetIcon( "icon16/user_comment.png" )
		function ButtonServerMute:DoClick()
			LocalPlayer():ConCommand( "ulx " .. string.lower(muteCommand) .. " $" .. ply:UniqueID() )
		end
		
		-- Server Gag
		local gagCommand = "Gag"
		if ply:GetNWBool( "ulx_gagged", false ) then gagCommand = "UnGag" end
		local ButtonServerGag = PlayerlistMenu:AddOption( "Server " .. gagCommand )
		ButtonServerGag:SetIcon( "icon16/sound_mute.png" )
		function ButtonServerGag:DoClick()
			LocalPlayer():ConCommand( "ulx " .. string.lower(gagCommand) .. " $" .. ply:UniqueID() )
		end
		
		PlayerlistMenu:AddSpacer()
		
		-- AWarn
		if AWarn then
			local ButtonAWarn = PlayerlistMenu:AddOption( "Warn" )
			ButtonAWarn:SetIcon( "icon16/exclamation.png" )
			function ButtonAWarn:DoClick()
				AWarn.activeplayer = ply:Name()
				awarn_playerwarnmenu()
			end
			
			PlayerlistMenu:AddSpacer()
		end
		
	end
	
	-- Staff Commands 
	if LocalPlayer():CheckGroup( Menu.Enum.MODERATOR ) or LocalPlayer():IsAdmin() then
	
		-- Force switch team
		if ply:Team() == TEAM_HUNTERS then

			local ButtonOptionMovePlayer = PlayerlistMenu:AddOption( "Move To Props" )
			ButtonOptionMovePlayer:SetIcon( "icon16/status_busy.png" )
			function ButtonOptionMovePlayer:DoClick()
				RunConsoleCommand("forcemoveteam", ply:EntIndex(), TEAM_PROPS)
			end

		elseif ply:Team() == TEAM_PROPS then

			local ButtonOptionMovePlayer = PlayerlistMenu:AddOption( "Move to Hunters" )
			ButtonOptionMovePlayer:SetIcon( "icon16/status_busy.png" )
			function ButtonOptionMovePlayer:DoClick()
				RunConsoleCommand("forcemoveteam", ply:EntIndex(), TEAM_HUNTERS)
			end
			
		end
		
		if ply:Team() == TEAM_PROPS or ply:Team() == TEAM_HUNTERS then

			local ButtonOptionMovePlayer = PlayerlistMenu:AddOption( "Move to Specator" )
			ButtonOptionMovePlayer:SetIcon( "icon16/status_busy.png" )
			function ButtonOptionMovePlayer:DoClick()
				RunConsoleCommand("forcemoveteam", ply:EntIndex(), TEAM_SPECTATOR)
			end

		end
		
	end
	
	PlayerlistMenu:Open()
	
end


vgui.Register( "DMTabs.ScoreBoard.Player", PANEL, "DPanel" )