if SERVER then
	util.AddNetworkString( "DoubleJumpSmoke" )

	hook.Add( "KeyPress", "DoubleJump.KeyPress", function( ply, key )

		if !IsValid( ply ) or key != IN_JUMP then return end
		if not ply.Jumps then ply.Jumps = 0 end
		ply.Jumps = ply.Jumps + 1
		
		if ply.Jumps == 2 then
			local ang = ply:GetAngles()
			local forward, right = ang:Forward(), ang:Right()
			
			local vel = -1 * ply:GetVelocity() -- Nullify current velocity
			vel = vel + Vector(0, 0, ply:GetJumpPower()) -- Add vertical force
			
			local spd = ply:GetMaxSpeed() * 0.8
			
			if ply:KeyDown(IN_FORWARD) then
				vel = vel + forward * spd
			elseif ply:KeyDown(IN_BACK) then
				vel = vel - forward * spd
			end
			
			if GetGlobalBool("MapMirrored") then
				right = -right
			end
			
			if ply:KeyDown(IN_MOVERIGHT) then
				vel = vel + right * spd
			elseif ply:KeyDown(IN_MOVELEFT) then
				vel = vel - right * spd
			end
			
			ply:SetVelocity(vel)

			sound.Play( "player/suit_sprint.wav", ply:GetPos(), 60, math.random( 150, 170 ) )
			net.Start( "DoubleJumpSmoke" )
			net.WriteEntity( ply )
			net.Broadcast()
		end
		
	end )
end

net.Receive( "DoubleJumpSmoke", function()
	local ply = net.ReadEntity()
	if IsValid(ply) then
		ply:DoCustomAnimEvent(PLAYERANIMEVENT_JUMP , -1)
		local emitter = ParticleEmitter( ply:GetPos())
		for  i = 0, 10 do
			local particle = emitter:Add( "particles/smokey", ply:GetPos() )
			local Pos = Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), math.Rand( -0.1, 0.1 ) )
			particle:SetVelocity( Pos * 20 )
			particle:SetLifeTime( 0 )
			particle:SetDieTime( 1.5 )
			particle:SetStartAlpha( 100 )
			particle:SetEndAlpha( 0 )
			local Size = math.Rand( 5, 8 )
			particle:SetStartSize( Size )
			particle:SetEndSize( Size*2 )
			particle:SetRoll( math.Rand( 0, 360 ) )
			particle:SetRollDelta( math.Rand( -2, 2 ) )
			particle:SetAirResistance( 50 )
			particle:SetCollide( false )
			particle:SetLighting( false )
		end
		emitter:Finish()
	end
end )

hook.Add( "OnPlayerHitGround", "DoubleJump.OnPlayerHitGround", function( ply, inWater, onFloater, speed )
	ply.Jumps = 0
end )