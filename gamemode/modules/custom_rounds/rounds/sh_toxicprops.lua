--[[
sh_toxicprops.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Toxic Props"
ROUND.Range = 150
ROUND.Damage = 1

function ROUND:Init()
	if SERVER then 
		timer.Create( "CRounds.ToxicProps", GAMEMODE.HunterBlindLockTime, 0, function()
			timer.Adjust( "CRounds.ToxicProps", 0.5, 0, function()
				for _, ply in pairs( team.GetPlayers(TEAM_PROPS) ) do
					if IsValid(ply) and ply:Alive() then
						local entsInRange = ents.FindInSphere( ply:GetPos(), ROUND.Range )
						for _, ent in pairs( entsInRange ) do
							if IsValid( ent ) and ent:IsPlayer() and ent:Alive() and ent:Team() == TEAM_HUNTERS and ent:Health() > 1 then
								ent:SetHealth( ent:Health() - ROUND.Damage )
								if ent:Health() <= 0 then
									ent:SetHealth( 1 )
								end
							end
						end
					end
				end
			end )
		end )
	end
end

function ROUND:EndRound()
	if timer.Exists( "CRounds.ToxicProps" ) then
		timer.Remove( "CRounds.ToxicProps" )
	end
end


CRounds.AddRound( ROUND )