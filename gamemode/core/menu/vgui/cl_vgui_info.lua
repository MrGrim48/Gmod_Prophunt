/*
cl_vgui_info.lua

Copyright© Nekom Glew, 2017

*/

local PANEL = {}

local TeamButtons = {}

function PANEL:Init()
	

	local motd = vgui.Create( "HTML", self )
	motd:SetPos( 0, 0 )
	motd:SetSize( Menu.Width, Menu.Height-195 )
	motd:OpenURL( "http://casualidiots.com/motd/" )
	
	timer.Simple( 0.1, function()
		if IsValid(self) then self:UpdatePlayerList() end
	end )
end

function PANEL:UpdatePlayerList()

	if self.teamList and IsValid( self.teamList ) then
		self.teamList:Remove()
	end

	self.teamList = vgui.Create( "DPanel", self )
	self.teamList:SetPos( 0, Menu.Height-195 )
	self.teamList:SetSize( Menu.Width, 200 )
	
	function self.teamList:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 100,115,130 ) )
	end
	
	local i = 0
	for team_id, TeamInfo in pairs ( team.GetAllTeams() ) do
	
		if ( team_id != TEAM_CONNECTING && team_id != TEAM_UNASSIGNED ) then
			local TeamButton = vgui.Create( "DButton", self.teamList )
			TeamButton:SetMouseInputEnabled( true )
			TeamButton:SetSize( (self.teamList:GetWide()/2), 60 )
			TeamButton:SetText( TeamInfo.Name )
			TeamButton:SetPos( TeamButton:GetWide() * i, 0 )
			TeamButton:SetFont( "Menu.Main" )
			TeamButton:SetTextColor( Color(0,0,0) )
			function TeamButton.DoClick() 
				Menu.Close() 
				RunConsoleCommand("jointeam", team_id) 
			end
			
			if 	( IsValid( LocalPlayer() ) && LocalPlayer():Team() == team_id ) ||
				( team_id == TEAM_PROPS && #team.GetPlayers(TEAM_PROPS) > #team.GetPlayers(TEAM_HUNTERS) ) ||
				( team_id == TEAM_HUNTERS && #team.GetPlayers(TEAM_HUNTERS) > #team.GetPlayers(TEAM_PROPS) ) then
				TeamButton:SetDisabled( true )
			elseif IsValid( LocalPlayer() ) && TeamButton:GetDisabled() then
				TeamButton:SetDisabled( false )
			end
			
			function TeamButton:Paint( w, h )
				draw.RoundedBox( 0, 0, 0, w, h, team.GetColor(team_id) )
				if TeamButton:IsHovered() and !TeamButton:GetDisabled() then
					draw.RoundedBox( 0, 0, 0, w, h, Color( 40,40,40 ) )
				elseif TeamButton:GetDisabled() then
					draw.RoundedBox( 0, 0, 0, w, h, Color( 150,80,80 ) )
				end
			end
			
			TeamButton:SetText( team.GetName(team_id).." ( "..#team.GetPlayers(team_id).." )" )
			
			table.insert( TeamButtons, TeamButton )
			
			i = i + 1
		end
		
	end
end

--[[net.Receive( "PlayerUpdate", function()

	timer.Simple( 3, function()
		if IsValid(Menu.Info) then
			Menu.Info:UpdatePlayerList()
		end
	end )

end )]]

hook.Add( "PlayerChangedTeam", "Menu.Info.PlayerUpdate", function()
		timer.Simple( 3, function()
			if IsValid(Menu.Info) then
				Menu.Info:UpdatePlayerList()
			end
		end )
	end )

vgui.Register( "DMTabs.Info", PANEL, "DPanel" )