/*
cl_vgui_changeteam.lua

Copyright© Nekom Glew, 2017

*/

local PANEL = {}

local TeamButtons = {}

function PANEL:Init()
	
	local teamList = vgui.Create( "DPanel", self )
	teamList:SetSize( 250, Menu.Height )
	function teamList:Paint( w,h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(55,55,55) )
		draw.RoundedBox( 0, w-1, 0, 1, h, Color(200,80,80) )
	end
	
	local teamInfo = vgui.Create( "HTML", self )
	teamInfo:SetPos( 250, 0 )
	teamInfo:SetSize( Menu.Width - 250, Menu.Height )
	teamInfo:OpenURL( "http://motd.cookiex.net/prophunt/teams/props.php" )
	
	local i = 0
	for team_id, TeamInfo in pairs ( team.GetAllTeams() ) do
	
		if ( team_id != TEAM_CONNECTING && team_id != TEAM_UNASSIGNED ) then
			local TeamButton = vgui.Create( "DButton", teamList )
			TeamButton:SetMouseInputEnabled( true )
			TeamButton:SetSize( teamList:GetWide(), 40 )
			TeamButton:SetText( TeamInfo.Name )
			TeamButton:SetPos( 0, TeamButton:GetTall() * i + (10*i) + 10 )
			TeamButton:SetFont( "Menu.Main" )
			TeamButton:SetTextColor( Color(240,240,240) )
			function TeamButton.DoClick() 
				Menu.Close() 
				RunConsoleCommand("jointeam", team_id) 
			end
			function TeamButton:Paint( w, h )
				--draw.RoundedBox( 0, 0, 0, w, h, Color(120,135,150) )
				if TeamButton:IsHovered() and !TeamButton:GetDisabled() then
					draw.RoundedBox( 0, 0, 0, w-1, h, Color( 40,40,40 ) )
				elseif TeamButton:GetDisabled() then
					draw.RoundedBox( 0, 0, 0, w-1, h, Color( 150,80,80 ) )
				end
				draw.RoundedBox( 0, 0, 0, 10, h, team.GetColor(team_id) )
			end
			
			TeamButton.team_id = team_id
			function TeamButton:UpdateInfo()
				if 	( IsValid( LocalPlayer() ) && LocalPlayer():Team() == self.team_id ) ||
					( self.team_id == TEAM_PROPS && #team.GetPlayers(TEAM_PROPS) > #team.GetPlayers(TEAM_HUNTERS) ) ||
					( self.team_id == TEAM_HUNTERS && #team.GetPlayers(TEAM_HUNTERS) > #team.GetPlayers(TEAM_PROPS) ) then
					self:SetDisabled( true )
				elseif IsValid( LocalPlayer() ) && self:GetDisabled() then
					self:SetDisabled( false )
				end
				
				self:SetText( team.GetName(self.team_id).." ( "..#team.GetPlayers(self.team_id).." )" )
			end
			
			timer.Simple( 0.1, function()
				if IsValid( TeamButton ) then
					TeamButton:UpdateInfo()
				end
			end )
			
			table.insert( TeamButtons, TeamButton )
			
			i = i + 1
		end
		
	end

end

vgui.Register( "DMTabs.ChangeTeam", PANEL, "DPanel" )


net.Receive( "PlayerUpdate", function()
	timer.Simple( 0.1, function()
		for _, button in pairs( TeamButtons ) do
			if IsValid(button) then
				button:UpdateInfo()
			end
		end
	end )
end )