
iDummyStartWith = 1
iMaxDummyProps = 5
iAddDummyRate = 30 -- Seconds to get a new dummy prop

if SERVER then 

	local function PlayerThink( ply )

		if IsValid(ply) && ply:Alive() && ply:Team() == TEAM_PROPS && ply:GetNWInt("DummyProps",0) < iMaxDummyProps then			
			if CurTime() > ply:GetNWFloat("DummyNextTime",0) then
				ply:SetNWFloat( "DummyNextTime", CurTime()+ply:GetNWInt("DummyRateOverride",iAddDummyRate) )
				ply:SetNWFloat( "DummyTime", CurTime() )
				ply:SetNWInt( "DummyProps", ply:GetNWInt("DummyProps", 0) + 1 )
			end
		end

	end
	_G.PlayerThink.hookAdd( "Props.DummyProps", PlayerThink )


	local function PlayerSpawn( ply )

		ply:SetNWFloat( "DummyNextTime", CurTime()+iAddDummyRate )
		ply:SetNWInt( "DummyProps", iDummyStartWith )
		ply:SetNWInt( "DummyRateOverride", iAddDummyRate )

	end
	hook.Add( "PlayerSpawn", "Props.DummyProps.PlayerSpawn", PlayerSpawn )

	
	local function CanPlaceDummy( ply )
	
		if !IsValid(ply) || !ply:Alive() then return false end
		if !IsValid(ply.ph_prop) then return false end
		if !(ply:GetNWInt("DummyProps", 0) > 0) then return false end
		if ply:Team() != TEAM_PROPS then return false end
		if ply:GetNWBool( "PhysicsMode", false) then return false end
		
		if hook.Run( "PropDummyDisabled" ) then return false end
		
		local mins, maxs = ply:GetHull()
		mins:Add( ply:GetPos() )
		maxs:Add( ply:GetPos() )
		local entsInBox = ents.FindInBox( mins, maxs )
		for _, ent in pairs( entsInBox ) do
			if ent:GetClass() == "ph_dummy" && ent.Creator && ent.Creator == ply then
				return false
			end
		end
		
		return true
	
	end
	

	local function KeyPress( ply, key )

		if key == IN_ATTACK2 && CanPlaceDummy( ply ) then
			ply:SetNWInt( "DummyProps", ply:GetNWInt("DummyProps", 0) - 1 )
			
			local dummy = ents.Create( "ph_dummy" )			
			dummy:Spawn()
			dummy:SetOwner( ply )
			dummy.Creator = ply 
			
			dummy:SetPos( ply.ph_prop:GetPos() )			
			--dummy:SetAngles( (ply.ph_prop.angle or Angle()) )---Angle(0,ply:EyeAngles().y,0) )			
			dummy:SetModel( ply.ph_prop:GetModel() )
			dummy:SetSkin( ply.ph_prop:GetSkin() )
			
			local ang = ply.ph_prop.angle or Angle()
			if ply:GetNWBool("PhysicsMode",false) then
				ang = ply.ph_prop:GetAngles()
			end
			dummy:SetAngles( ang )
			
			dummy:PhysicsInit( SOLID_VPHYSICS )
			dummy:SetMoveType( MOVETYPE_VPHYSICS )
			dummy:SetSolid( SOLID_VPHYSICS )
			
			--dummy:Activate()			
			dummy:GetPhysicsObject():Wake()
			
			timer.Simple( 0.1, function()
				net.Start( "SendEffect.Balloon" )
				net.WriteEntity( dummy )
				net.Broadcast()
			end )
		end
		
		if ply:Team() == TEAM_PROPS && key == IN_USE then
			local tr = util.TraceLine({
				start = ply:EyePos(),
				endpos = ply:EyePos() + ply:EyeAngles():Forward() * 80,
				filter = function(ent) if ent:GetClass() == "ph_dummy" then return true end end
			})
			
			if IsValid(tr.Entity) then 
				tr.Entity:Remove()
			end
		end

	end
	hook.Add( "KeyPress", "Props.DummyProps.KeyPress", KeyPress )

else -- Client

	local function HUDPaint()
		
		if LocalPlayer():Alive() && LocalPlayer():Team() == TEAM_PROPS and !hook.Run( "PropDummyDisabled" ) then
			local x = ScrW() - 220
			local y = ScrH() - 80
			local width = 190
			local height = 55
			
			draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
			draw.SimpleText( "DUMMY", "Hud.Name", x+15, y+5, Color(255,255,60) )
			draw.SimpleText( "PROPS", "Hud.Name", x+15, y+20, Color(255,255,60) )
			draw.SimpleText( "Right-Click", "Hud.NameSmall", x+15, y+35, Color(255,255,60) )
			
			draw.SimpleText( tostring(LocalPlayer():GetNWInt("DummyProps")), "Hud.Number", x+160, y+2, Color(255,255,60), TEXT_ALIGN_RIGHT )
			
			if CurTime() <= LocalPlayer():GetNWFloat("DummyNextTime",0) then
				local progressBar = (CurTime()-LocalPlayer():GetNWFloat("DummyTime",0)) / (LocalPlayer():GetNWFloat("DummyNextTime",0)-LocalPlayer():GetNWFloat("DummyTime",0))
				surface.SetDrawColor( Color( 255,255,0 ) )
				surface.DrawRect( x, y+height, width*(1-progressBar), 3 )
			end
		end
	
	end
	hook.Add( "HUDPaint", "Props.DummyProps.HUDPaint", HUDPaint )

end