
local cooldown = 1

if SERVER then

	local function PlayerSpawn( ply )

		ply:SetNWBool( "PhysicsMode", false)
		
	end
	hook.Add( "PlayerSpawn", "PhysicsMode.PlayerSpawn", PlayerSpawn )
	
	
	function SetPhysicsMode( ply, enablePhysics )
	
		if !IsValid( ply ) then return end
		if !IsValid( ply.ph_prop ) then return end
		
		ply:SetNWBool( "PhysicsMode", enablePhysics )
	
		if enablePhysics then
			--Remove any dummy props nearby
			local min, max = ply:GetHull()
			local entities = ents.FindInBox( min + ply:GetPos(), max + ply:GetPos() )
			for _, ent in pairs( entities ) do
				if ent:GetClass() == "ph_dummy" then
					ent:Remove()
				end
			end
		
			ply.ph_prop:SetParent( nil )
			ply:SetMoveType( MOVETYPE_CUSTOM )
			ply:SetSolid( SOLID_NONE )
			
			ply.ph_prop:PhysicsInit( SOLID_VPHYSICS )
			ply.ph_prop:SetMoveType( MOVETYPE_VPHYSICS )
			ply.ph_prop:SetSolid( SOLID_VPHYSICS )					
			ply.ph_prop:SetUseType( SIMPLE_USE )
			
			local physObj = ply.ph_prop:GetPhysicsObject()
			if IsValid( physObj ) then
				physObj:Wake()
				if !hook.Run("PropPhysicsDamage") then physObj:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG ) end
				physObj:SetAngles( (ply.ph_prop.angle or Angle()) )
			end
			
			ply.ph_prop:SetLagCompensated( true )
		else			
			ply:SetSolid( SOLID_BBOX )
			ply:SetMoveType( MOVETYPE_WALK )
			ply.ph_prop:SetParent( ply )
			
			ply.ph_prop:SetMoveType( MOVETYPE_NONE )
			ply.ph_prop:SetSolid( SOLID_BBOX )
			
			local zOffset = Vector(0,0,ply.ph_prop:OBBMins().z)
			zOffset:Rotate( ply.ph_prop:GetAngles() )
			
			ply:SetPos( ply.ph_prop:GetPos() + zOffset + Vector(0,0,1))
			ply.ph_prop:SetLocalPos( -Vector(0,0,ply.ph_prop:OBBMins().z) )
			ply.ph_prop:SetAngles( (ply.ph_prop.angle or Angle())*2 )
			
			local minBound, maxBound = ply:GetHull()
			if Unstuck and !Unstuck.CollisionBoxClear( ply, ply:GetPos(), minBound, maxBound ) then
				Unstuck.Queue( ply )
			end
		end
				
	end
	

	-- Toggle Physics when key combinations are pressed.
	local function PlayerKeyPress( ply, key )

		if ply:Team() == TEAM_PROPS && IsValid(ply.ph_prop) && GameState.IsState( "Playing" ) then
			if ply:KeyDown(IN_SPEED) && key == IN_ATTACK && CurTime() > ply:GetNWFloat("PhysicsTimeEnd",0) then
				ply:SetNWFloat( "PhysicsTimeEnd", CurTime() + cooldown )
				ply:SetNWFloat( "PhysicsTimeStart", CurTime() )
				SetPhysicsMode( ply, !ply:GetNWBool("PhysicsMode") )
			end
		end

	end
	hook.Add( "KeyPress", "PhysicsMode.KeyPress", PlayerKeyPress )

else

	local function HUDPaint()
		if LocalPlayer():Team() == TEAM_PROPS && LocalPlayer():Alive() then			
			local x = ScrW() - 220
			local y = ScrH() - 200
			local width = 190
			local height = 55
			
			draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
			draw.SimpleText( "PHYSICS", "Hud.Name", x+15, y+5, Color(255,255,60) )
			draw.SimpleText( "Shift+", "Hud.NameSmall", x+15, y+24, Color(255,255,60) )
			draw.SimpleText( "LeftClick", "Hud.NameSmall", x+15, y+35, Color(255,255,60) )
			
			local text = ""
			local color = Color(255,255,60)
			if LocalPlayer():GetNWBool( "PhysicsMode", false ) then
				text = "On"
				color = Color( 100,255,100 )
			else
				text = "Off"
				color = Color( 255,100,100 )
			end
			draw.SimpleText( text, "Hud.Number", x+170, y, color, TEXT_ALIGN_RIGHT )
			
			if CurTime() <= LocalPlayer():GetNWFloat("PhysicsTimeEnd",0) then
				local progress = (CurTime()-LocalPlayer():GetNWFloat("PhysicsTimeStart")) / (LocalPlayer():GetNWFloat("PhysicsTimeEnd")-LocalPlayer():GetNWFloat("PhysicsTimeStart"))
				surface.SetDrawColor( Color( 255,255,0 ) )
				surface.DrawRect( x, y+height, width*progress, 3 )
			end
		end
	end
	hook.Add( "HUDPaint", "Props.PhysicsMode.HUDPaint", HUDPaint )

end