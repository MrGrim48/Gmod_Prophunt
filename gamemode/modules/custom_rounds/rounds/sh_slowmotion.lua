--[[
sh_slowmotion.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Slow Jumps"
ROUND.Gravity = 0.15
ROUND.PhysTimeScale = 0.35
ROUND.JumpPower = 90

hook.Add( "Initialize", "CRounds.SlowMotion.Initialize", function()
	if SERVER then RunConsoleCommand( "phys_timescale", 1 ) end
end )

function ROUND:Init()
	if SERVER then 
		RunConsoleCommand( "phys_timescale", ROUND,PhysTimeScale )
		timer.Simple( 2, function()
			for _, ply in pairs( player.GetAll() ) do
				if IsValid(ply) then
					ply:SetGravity( ROUND.Gravity )
					ply:SetJumpPower( ROUND.JumpPower )
				end
			end
		end )
	else 
		LocalPlayer():SetGravity( ROUND.Gravity )
		LocalPlayer():SetJumpPower( ROUND.JumpPower )
	end
end

-- Ladders reset the gravity
function ROUND:KeyPress( ply, key )
	if key and ply:GetMoveType(MOVETYPE_LADDER) then
		ply:SetGravity( ROUND.Gravity )
	end
end

function ROUND:EndRound()
	if SERVER then
		RunConsoleCommand( "phys_timescale", 1 )
		for _, ply in pairs( player.GetAll() ) do
			if IsValid(ply) then
				ply:SetGravity( 1 )
			end
		end
	else
		LocalPlayer():SetGravity( 1 )
	end
end


CRounds.AddRound( ROUND )