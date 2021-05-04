--[[
sh_slowprops.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Slow Props | Crowbars Only"

function ROUND:Init()
	
	if SERVER then 
		timer.Simple( 10, function()
			-- Strip hunters and give them the crowbar
			for _, ply in pairs( team.GetPlayers(TEAM_HUNTERS) ) do
				if IsValid(ply) and ply:Alive() then
					ply:StripWeapons()
					ply:Give( "weapon_crowbar" )
				end
			end
			
			-- Slow the props and lower the jump height
			for _, ply in pairs( team.GetPlayers(TEAM_PROPS) ) do
				if IsValid(ply) and ply:Alive() then
					GAMEMODE:SetPlayerSpeed( ply, 200, 200 )
					ply:SetJumpPower( 160 )
				end
			end
		end )
	end
	
end

function ROUND:HunterLoadoutDisabled()
	return true
end


CRounds.AddRound( ROUND )