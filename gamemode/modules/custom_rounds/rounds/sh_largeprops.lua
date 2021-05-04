--[[
sh_largeprops.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Large Props Only"
ROUND.MinRadius = 20

function ROUND:Init()
	
	if SERVER then 
		timer.Simple( 5, function()
			-- Increase prop speed
			for _, ply in pairs( team.GetPlayers(TEAM_PROPS) ) do
				if IsValid(ply) and ply:Alive() then
					GAMEMODE:SetPlayerSpeed( ply, 300, 300 )
				end
			end
		end )
		
		net.Start( "HighlightProp.ClearCache" )
		net.Broadcast()
	end
	
end

function ROUND:IsValidPropChange( ply, ent )
	if IsValid(ent) and ent:BoundingRadius() <= ROUND.MinRadius then
		return "That prop is too small"
	end
end


function ROUND:EndRound()
	if SERVER then
		net.Start( "HighlightProp.ClearCache" )
		net.Broadcast()
	end
end


CRounds.AddRound( ROUND )