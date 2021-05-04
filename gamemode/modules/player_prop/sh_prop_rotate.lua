
if SERVER then
	
	local RequestRotateHullChange = {}

	local function RotateProp( ply )
		
		if ply:Team() == TEAM_PROPS && IsValid( ply.ph_prop ) && ply:KeyDown( IN_ATTACK ) && !ply:GetNWBool("PhysicsMode",false) && !ply:KeyDown(IN_SPEED) then
			--ply.ph_prop.angle = Angle(0,ply:EyeAngles().y+ply:EyeAngles().y,0)
			ply.ph_prop.angle = Angle(0,ply:EyeAngles().y,0)
			ply.ph_prop:SetAngles( Angle(0,ply:EyeAngles().y+ply:EyeAngles().y,0) )
			--ply.ph_prop:SetAngles( Angle(0,ply:EyeAngles().y,0) )
			ply.ph_prop.rotating = true
			RequestRotateHullChange[ply] = false
		elseif ply.ph_prop && ply.ph_prop.rotating then
			--ply:SetPropHull( ply.ph_prop )
			ply.ph_prop.rotating = false
			RequestRotateHullChange[ply] = true
		end
		
		if RequestRotateHullChange[ply] && IsValid(ply.ph_prop) then
		
			local mins, maxs = ply:CalculateRotatedDisguiseMinsMaxs( ply.ph_prop )
			local filter = {ply, ply.ph_prop}
			--local filter = player.GetAll()
			--table.Add( filter, ents.FindByClass( "ph_prop" ) )
			
			local tr = util.TraceHull( {
				start = ply:GetPos()+Vector(0,0,1),
				endpos = ply:GetPos()+Vector(0,0,1), 
				maxs = maxs,
				mins = mins,
				filter = filter,
				mask = MASK_ALL
			} )
			
			if (!tr.StartSolid || !tr.AllSolid) && ply.ph_prop then
				ply:SetPropHull( ply.ph_prop )
				RequestRotateHullChange[ply] = false
			end
		end
		
	end
	PlayerThink.hookAdd( "Props.Rotate", RotateProp )

else

	local function Think()
		
		if IsValid( LocalPlayer() ) && LocalPlayer():Team() == TEAM_PROPS and LocalPlayer():KeyDown( IN_ATTACK ) && IsValid(LocalPlayer().ph_prop) && !LocalPlayer():GetNWBool("PhysicsMode",false) && !LocalPlayer():KeyDown(IN_SPEED) then
			LocalPlayer().ph_prop.angle = Angle( 0, EyeAngles().y, 0 )
		end		
		
	end
	hook.Add( "Think", "Props.Rotate.Think", Think )

	
	local function RotateProp( ply, pos, angles, fov )
	
		if IsValid(LocalPlayer()) && LocalPlayer():IsPlayer() && LocalPlayer():Team() == TEAM_PROPS && !LocalPlayer():GetNWBool("PhysicsMode",false) then
			local prop = LocalPlayer().ph_prop
			if IsValid( prop ) then
				prop:SetAngles( prop.angle or Angle() )
				
				local min, max = prop:GetModelBounds()
				local newPos = Vector()
				
				newPos.z = newPos.z - min.z
				
				newPos.x = newPos.x - (max.x + min.x)*0.5
				newPos.y = newPos.y - (max.y + min.y)*0.5
				
				newPos:Rotate( (prop.angle or Angle()) )
				
				prop:SetPos( LocalPlayer():GetPos() + newPos )
			end
		end
	
	end
	hook.Add( "PostCalcView", "Props.Rotate.RotateProp", RotateProp )
	
end