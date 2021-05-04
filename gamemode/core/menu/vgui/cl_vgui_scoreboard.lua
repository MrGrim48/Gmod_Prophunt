/*
cl_vgui_scoreboard.lua

Copyright© Nekom Glew, 2017

*/

local PANEL = {}

local Columns = 2

function PANEL:Init()

	self:RefreshList()

end


function PANEL:RefreshList()

	if self.scrollPanel and IsValid( self.scrollPanel ) then
		self.scrollPanel:Remove()
	end

	local width = self:GetParent():GetWide() - 10
	local height = self:GetParent():GetTall() - 45
	
	self.scrollPanel = vgui.Create("DScrollPanel", self)
	self.scrollPanel:SetSize(width, height)
	self.scrollPanel:SetPos(5,5)
	self.scrollPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(100,115,130,225) ) 
	end

	local teamList = vgui.Create("DListLayout", self.scrollPanel)
	teamList:SetWide( self.scrollPanel:GetWide() - 6 )
	teamList:SetPos( 3, 3 )

	local teamPanel
	for Team, teamData in pairs( team.GetAllTeams() ) do
		-- Ignore teams
		if Team == TEAM_CONNECTING or Team == TEAM_UNASSIGNED or Team == TEAM_SPECTATOR then
			continue
		end
	
		-- Create a new panel to add the team to if it doesn't exist
		if not teamPanel then
			teamPanel = vgui.Create("DPanel")
			teamPanel:SetWide( width )
			teamPanel.Paint = function() end
		end
		
		-- Increment the number of teams that will be displaying on this panel
		teamPanel.numTeams = (teamPanel.numTeams or 0) + 1
		
		local x = (width/Columns) * (teamPanel.numTeams-1) + (5 * (teamPanel.numTeams-1))
		local w = (width/Columns) - (5 * Columns)
		
		local plyList = vgui.Create( "DMTabs.ScoreBoard.PlayerList", teamPanel )
		plyList:SetPos( x, 0 )
		plyList:SetSize( w, 0 )
		plyList:SetupList( Team )
		
		-- Add the teamPanel to the teamList when it has reached the limit on how many teams to display
		if teamPanel.numTeams >= Columns or teamPanel.numTeams >= #team.GetAllTeams() then
			teamPanel:SizeToChildren( false, true )
			teamList:Add( teamPanel )
			teamPanel = nil
		end
	end
	
	-- Spectators --
	teamPanel = vgui.Create("DPanel")
	teamPanel.Paint = function() end
	
	local plyList = vgui.Create( "DMTabs.ScoreBoard.PlayerList", teamPanel )
	plyList:SetSize( width, 0 )
	plyList:SetupList( TEAM_SPECTATOR )
	
	teamPanel:SizeToChildren( false, true )
	teamList:Add( teamPanel )
		
end

net.Receive( "PlayerUpdate", function()
	timer.Simple( 0.1, function()
		if IsValid(Menu.ScoreBoard) then
			Menu.ScoreBoard:RefreshList()
		end
	end )
end )

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 0, 0, 0, w, h, Color(55,55,55) )
	
end

vgui.Register( "DMTabs.ScoreBoard", PANEL, "DPanel" )