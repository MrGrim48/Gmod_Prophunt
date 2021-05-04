--[[
sh_superspeed.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Super Speed"
ROUND.Speed = 500
ROUND.MinRadius = 10

function ROUND:Init()
	if SERVER then 
		timer.Simple( 1, function()
			for _, ply in pairs( player.GetAll() ) do
				if IsValid(ply) and ply:Alive() and (ply:Team() == TEAM_HUNTERS or ply:Team() == TEAM_PROPS) then
					GAMEMODE:SetPlayerSpeed( ply, ROUND.Speed, ROUND.Speed )
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