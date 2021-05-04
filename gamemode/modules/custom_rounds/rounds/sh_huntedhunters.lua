--[[
sh_huntedhunters.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Hunters become Hunted"
ROUND.Cooldown = 2
ROUND.Force = 2000
ROUND.DamageMultiplier = 0.8
ROUND.DamageMin = 1
ROUND.DamageMax = 50
ROUND.Speed = 290
ROUND.Range = 100
ROUND.PhysicsCooldown = 2
ROUND.PickupCooldown = 4
ROUND.PuntCooldown = 4

function ROUND:Condition()
	return math.random() < 0.2 // 20% chance?
end

function ROUND:PostRoundStart()
	UTIL_FreezeAllPlayers()
	UTIL_StripAllPlayers()
	
	for _,ply in pairs( team.GetPlayers( TEAM_PROPS ) ) do
		ply:Blind(true)
		timer.Simple( 0.1, function() ply:Lock() end )
		timer.Simple( 30, function()
			if IsValid( ply ) and ply:GetNWBool( "Blind" ) then
				ply:Blind( false )
				ply:UnLock()
			end
		end )
	end
	
	for _,ply in pairs( team.GetPlayers( TEAM_HUNTERS ) ) do
		ply:Blind(false)
		ply:Freeze( false )
		timer.Simple( 30, function()
			if IsValid( ply ) then
				ply:Give( "weapon_physcannon" )
				GAMEMODE:SetPlayerSpeed( ply, ROUND.Speed, ROUND.Speed )
			end
		end )
	end
end

function ROUND:KeyPress( ply, key )
	if IsValid(ply) and ply:Team()==TEAM_PROPS then
		-- Turn physics mode on and launch the prop.
		if SERVER and key==IN_ATTACK2 and CurTime() > ply:GetNWFloat("PropsPhysicsTime",0) then
			ply:SetNWFloat( "PropsPhysicsTime", CurTime() + ROUND.Cooldown )
			if !ply:GetNWBool("PhysicsMode") then SetPhysicsMode( ply, true ) end
			timer.Simple( 0.1, function()
				if IsValid(ply) and ply.ph_prop then
					local physObj = ply.ph_prop:GetPhysicsObject()
					if physObj then
						local lookVec = ply:EyeAngles():Forward()
						--lookVec = Vector(lookVec.x, lookVec.y, math.Clamp(lookVec.z,-1,1)):GetNormalized()
						local vel = lookVec * ((physObj:GetMass()*0.8)*ROUND.Force)
						physObj:ApplyForceCenter( vel )
					end
				end
			end )
		end
		if key==IN_RELOAD and CurTime() > (ply.PhysicsCooldown or 0) then
			ply.PhysicsCooldown = CurTime() + ROUND.PhysicsCooldown
			ply:Spawn()
		end
	end	
end

function ROUND:HUDPaint()
	if LocalPlayer():Team() == TEAM_PROPS && LocalPlayer():Alive() then	
		-- Draw Physics Launch
		local x = ScrW() - 220
		local y = ScrH() - 80
		local width = 190
		local height = 55
		
		draw.RoundedBox( 0, x-50, y, width+50, height, Color( 50,50,50,200 ) )
		draw.SimpleText( "PHYSICS", "Hud.Name", x+15, y+5, Color(255,255,60) )
		draw.SimpleText( "LAUNCH", "Hud.Name", x+15, y+20, Color(255,255,60) )
		draw.SimpleText( "Right-Click", "Hud.NameSmall", x+15, y+35, Color(255,255,60) )
		
		local text = "..."
		local color = Color(255,255,60)
		draw.SimpleText( text, "Hud.Number", x+170, y, color, TEXT_ALIGN_RIGHT )
		
		if CurTime() <= LocalPlayer():GetNWFloat("PropsPhysicsTime",0) then				
			self.oldCurTime = self.oldCurTime or CurTime()
			local curDuration = ROUND.Cooldown - (CurTime()-self.oldCurTime)
			local iProgress = curDuration / ROUND.Cooldown
	
			surface.SetDrawColor( Color( 255,255,0 ) )
			surface.DrawRect( x-50, y+height, (width+50)*iProgress, 3 )
		elseif self.oldCurTime then
			self.oldCurTime = nil
		end
		
		local arrow = {
			{ x = x-40, y = y+10 },
			{ x = x, y = y+26 },
			{ x = x-40, y = y+45 }

		}
		surface.SetDrawColor( Color( 255,255,0 ) )
		draw.NoTexture()
		surface.DrawPoly( arrow )
		------------------------
		
		-- Draw Respawn
		local x = ScrW() - 220
		local y = ScrH() - 140
		local width = 190
		local height = 55
		
		draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
		draw.SimpleText( "RESPAWN", "Hud.Name", x+15, y+5, Color(255,255,60) )
		draw.SimpleText( "R", "Hud.NameSmall", x+15, y+35, Color(255,255,60) )
		
		local text = "..."
		local color = Color(255,255,60)
		draw.SimpleText( text, "Hud.Number", x+170, y, color, TEXT_ALIGN_RIGHT )
		
		if CurTime() <= (LocalPlayer().PhysicsCooldown or 0) then				
			self.oldSpawnTime = self.oldSpawnTime or CurTime()
			local curDuration = ROUND.PhysicsCooldown - (CurTime()-self.oldSpawnTime)
			local iProgress = curDuration / ROUND.PhysicsCooldown
	
			surface.SetDrawColor( Color( 255,255,0 ) )
			surface.DrawRect( x, y+height, (width)*iProgress, 3 )
		elseif self.oldSpawnTime then
			self.oldSpawnTime = nil
		end
	end
end

function ROUND:OverrideHunterDamage( target, dmg_info, attacker )
	-- Prevent damage spam
	if ((target.lastHit or 0) + 0.2) > CurTime() then return false end
	target.lastHit = CurTime()
	
	--local physObj = attacker:GetPhysicsObject()
	--local damage = (IsValid(physObj) and math.Clamp( physObj:GetMass()*ROUND.DamageMultiplier, ROUND.DamageMin, ROUND.DamageMax )) or ROUND.DamageMin
	local damage = math.Clamp( dmg_info:GetDamage()*ROUND.DamageMultiplier, ROUND.DamageMin, ROUND.DamageMax )
	print( damage )
	
	target:SetHealth( target:Health() - damage )
	if target:Health() <= 0 then
		net.Start( "PlayerKilledByPlayer" )
		net.WriteEntity( target )
		net.WriteString( "prop_physics" )
		net.WriteEntity( attacker:GetOwner() )
		net.Broadcast()
		target:Kill()
	end
	
	return true
end

function ROUND:OverrideBonusPoints( team_id )
	for _, ply in pairs( player.GetAll() ) do
		if team_id == TEAM_HUNTERS && IsValid(ply) && ply:Team() == team_id then
			if ply:Alive() then
				ply:PS_GivePoints( BonusPSPoints.PropWinPointsAlive )
				ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.PropWinPointsAlive, Color(100,255,100), ' points for staying alive' )
			else
				ply:PS_GivePoints( BonusPSPoints.PropWinPoints )
				ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.PropWinPoints, Color(100,255,100), ' points for being on the winning team' )
			end
		elseif team_id == TEAM_PROPS && IsValid(ply) && ply:Team() == team_id then
			if ply:Alive() then
				ply:PS_GivePoints( BonusPSPoints.HunterWinPointsAlive )
				ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.HunterWinPointsAlive, Color(100,255,100), ' points for winning the round' )
			else
				ply:PS_GivePoints( BonusPSPoints.HunterWinPoints )
				ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.HunterWinPoints, Color(100,255,100), ' points for being on the winning team' )
			end
		end
	end
	return true
end

function ROUND:GravGunPickupAllowed( ply, ent )
	if IsValid( ent ) and ent:GetClass() == "ph_prop" and ent:GetPos():Distance(ply:GetPos()) <= ROUND.Range and CurTime() > (ent.PickupCooldown or 0) then
		if !ent:GetOwner():GetNWBool("PhysicsMode") then 
			ent:GetOwner():SetNWFloat( "PhysicsTime", CurTime() + 2 )
			ent:GetOwner():SetNWFloat( "PropsPhysicsTime", CurTime() + 2 )
			if SERVER then SetPhysicsMode( ent:GetOwner(), true ) end
		end
		ent.PickUpCooldown = CurTime() + ROUND.PickupCooldown
		return true
	elseif IsValid( ent ) and ent:GetClass() == "ph_prop" then
		return false
	end
end

function ROUND:GravGunPunt( ply, ent )
	if IsValid(ent) and ent:GetClass() == "ph_prop" and ent:GetOwner() and ent:GetOwner():Alive() and CurTime() > (ent.PuntCooldown or 0) then
		if !ent:GetOwner():GetNWBool("PhysicsMode") then 
			ent:GetOwner():SetNWFloat( "PhysicsTime", CurTime() + 2 )
			if SERVER then SetPhysicsMode( ent:GetOwner(), true ) end
		end
		ent.PuntCooldown = CurTime() + ROUND.PuntCooldown
		return true
	elseif IsValid( ent ) and ent:GetClass() == "ph_prop" then
		return false
	end
end

	
function ROUND:TeamWinEndRoundTimer()
	return TEAM_HUNTERS
end


function ROUND:PropPhysicsDamage()
	return true
end

function ROUND:PropDummyDisabled()
	return true
end

function ROUND:PropShadowDisabled()
	return true
end

function ROUND:HunterLoadoutDisabled()
	return true
end

function ROUND:HunterBlindDisabled()
	return true
end


CRounds.AddRound( ROUND )