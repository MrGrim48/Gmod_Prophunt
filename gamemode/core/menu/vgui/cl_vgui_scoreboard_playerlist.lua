/*
cl_vgui_scoreboard_playerlist.lua

Copyright© Nekom Glew, 2017

*/

local Exclude = {
	owner = false,
}

local PANEL = {}

function PANEL:SetupList( Team )
	
	local teamName = vgui.Create("DButton", self)
	teamName:SetSize(self:GetWide(), 34)
	teamName:SetText("")
	teamName:SetMouseInputEnabled( true )
	function teamName.DoClick()
		RunConsoleCommand("jointeam", Team)
	end
	
	teamName.Paint = function(self, w, h)
		--DrawBlur(self, 1)
		draw.RoundedBox( 0, 0, 0, w, h, Color(40,40,40) )
		local teamColor = team.GetColor( Team )
		teamColor.a = 10
		draw.RoundedBox( 0, 0, 0, w, h, teamColor )
		
		draw.SimpleText(team.GetName(Team), "Menu.ScoreBoard", 2, 2, Color(255,255,255), 0, 2)
		draw.SimpleText("Name", "Menu.ScoreBoard", 70, h-17, Color(255,255,255), 0, 2)
		draw.SimpleText("Rank", "Menu.ScoreBoard", w - 300, h-17, Color(255,255,255), 0, 2)
		draw.SimpleText("Ping", "Menu.ScoreBoard", w - 30, h-17, Color(255,255,255), 2, 2)
		draw.SimpleText("Kills / Death", "Menu.ScoreBoard", w - 90, h-17, Color(255,255,255), 2, 2)
		draw.SimpleText("Click to Join", "Menu.ScoreBoard", 300, 2, Color(255,255,255), 2, 2)
	end	
	self:Add(teamName)
	
	local teamPlayers = team.GetPlayers(Team)
	table.sort(  teamPlayers, function( a, b ) return a:Frags() > b:Frags() end )
	
	for k,ply in pairs(teamPlayers) do
	
		if Team == TEAM_SPECTATOR and Exclude[ply:GetUserGroup()] then continue end
	
		local plyPanel = vgui.Create( "DMTabs.ScoreBoard.Player", self )
		plyPanel:SetWide( self:GetWide() )
		plyPanel:SetupPlayer( ply )		
		self:Add(plyPanel)
		
	end
	self:SetTall( 44 + (44 * #teamPlayers) )

end

vgui.Register( "DMTabs.ScoreBoard.PlayerList", PANEL, "DListLayout" )