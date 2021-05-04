
local ScanCoolDown = 2 -- Time between scans.
local ResultTime = 3 -- Time to leave the result on screen

local HostileColor = Color( 255,0,0 )
local NonHostileColor = Color( 0,255,0 )

local Enum = {
	NON_HOSTILE = 1,
	HOSTILE = 2
}

local tableScanTargets = {
	prop_physics = true,
	prop_physics_multiplayer = true,
	ph_prop = true,
	ph_dummy = true
}
	
if SERVER then

	util.AddNetworkString( "StartPropScanner" )
	
	
	local function PlayerButtonDown( ply, button )
	
		if button == KEY_Q && IsValid(ply) && ply:Team() == TEAM_HUNTERS && ply:Alive() && CurTime() > (ply.ScanCoolDown or 0) then
			ply.ScanCoolDown = CurTime() + ScanCoolDown
			
			local tr = util.TraceLine({ 
				start = ply:EyePos(), 
				endpos = ply:EyePos() + ply:EyeAngles():Forward() * 150, 
				filter = function(ent) 
					if IsValid(ent) && tableScanTargets[ent:GetClass()] && ent:GetNWInt("Scanned",0) == 0 then 
						return true
					end
					return false
			end })
			
			if IsValid(tr.Entity) then
				local isHostile = tr.Entity:GetClass() == "ph_prop" || tr.Entity:GetClass() == "ph_dummy"
				local enum = Enum.NON_HOSTILE
				if isHostile then enum = Enum.HOSTILE end
				
				net.Start( "StartPropScanner" )
				net.WriteBool( isHostile )
				net.WriteFloat( CurTime() )
				net.Send( ply )
			
				ply:Freeze(true)
				timer.Simple( ScanCoolDown, function()
					ply:Freeze(false)					
					tr.Entity:SetNWInt( "Scanned", enum )
				end)
			end
		end
	
	end
	hook.Add( "PlayerButtonDown", "PropScanner.ButtonDown", PlayerButtonDown )
	
	-- Reset scan result if the prop player changed models
	local function PropChangedModel( ply )
		if IsValid(ply) && IsValid(ply.ph_prop) then
			ply.ph_prop:SetNWInt("Scanned", 0)
		end
	end
	hook.Add( "PropChangedModel", "PropScanner.PropChanged", PropChangedModel )
	
else --Client

	-- Colourize props that have been scanned every second
	timer.Create( "PropScanner", 1, 0, function() 
		-- Find all entities of the valid class
		local validTargets = {}
		for class, _ in pairs( tableScanTargets ) do
			table.Add( validTargets, ents.FindByClass(class) )
		end
	
		-- Go through all the valid entities and change their color if they have been scanned
		for _, ent in pairs( validTargets ) do
			if ent:GetNWInt("Scanned",0) > 0 then
				local color = NonHostileColor
				if ent:GetNWInt("Scanned",0)==Enum.HOSTILE then color = HostileColor end
				ent:SetColor( color )
				ent:SetRenderMode( RENDERMODE_TRANSALPHA )
			elseif ent:GetNWInt("Scanned",0) == 0 then
				ent:SetColor( Color(255,255,255) )
				ent:SetRenderMode( RENDERMODE_NORMAL )
			end
		end
	end )

	-- Set a cooldown visualiser 
	net.Receive( "StartPropScanner", function()
		local propIsHostile = net.ReadBool()
		PropScanTime = net.ReadFloat()
		PropScanCooldown = PropScanTime + ScanCoolDown
		
		timer.Remove( "Hunter.PropScanner.Cooldown" )
		timer.Create( "Hunter.PropScanner.Cooldown", ScanCoolDown, 1, function()
			PropIsHostile = propIsHostile
		end )
		
		timer.Remove( "Hunters.PropScanner.ResultTimer" ) 
		timer.Create( "Hunters.PropScanner.ResultTimer", ResultTime + ScanCoolDown, 1, function()
			PropIsHostile = nil
		end )
	end )
	
	
	local function HUDPaint()
		
		if LocalPlayer():Alive() && LocalPlayer():Team() == TEAM_HUNTERS then
			local text = "..."
			local color = Color(255,255,60)
			local x = ScrW() - 280
			local y = ScrH() - 140
			local width = 245
			local height = 55
			
			draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
			
			if CurTime() < (PropScanCooldown or 0) then
				local cooldown = (CurTime() - PropScanTime) / (PropScanCooldown - PropScanTime)
				surface.SetDrawColor( Color( 255,255,0 ) )
				surface.DrawRect( x, y+height, width*(1-cooldown), 3 )
			end
			
			if PropIsHostile == true then
				text = "Hostile"
				color = Color( 255,100,100 )
			elseif PropIsHostile == false then
				text = "Clear"
				color = Color( 100,255,100 )
			end
			
			draw.SimpleText( "PROP", "Hud.Name", x+10, y+5, Color(255,255,60) )
			draw.SimpleText( "SCANNER", "Hud.Name", x+10, y+20, Color(255,255,60) )
			draw.SimpleText( "Press Q on Target", "Hud.NameSmall", x+10, y+35, Color(255,255,60) )
			
			draw.SimpleText( text, "Hud.Number", x+240, y, color, TEXT_ALIGN_RIGHT )
		end
		
	end
	hook.Add( "HUDPaint", "Hunters.PropScanner", HUDPaint )
	
	local function Think()
		
		-- Remove scanned entities if they have a different model
		if PropScanner && PropScanner.scannedTargets then
			for i, ent in pairs( PropScanner.scannedTargets ) do
				if IsValid(ent) && ent:GetModel() != ent.scannedModel then
					local target = PropScanner.scannedTargets[i]
					target:SetRenderMode( RENDERMODE_NORMAL )
					target:SetColor( target.oldColor )
					table.remove( PropScanner.scannedTargets, i )
				elseif IsValid(ent) && ent:GetColor() != ent.newColor then
					ent:SetColor( ent.newColor )
					ent:SetRenderMode( RENDERMODE_TRANSALPHA )
				elseif !IsValid(ent) then
					table.remove( PropScanner.scannedTargets, i )
				end
			end
		end
	
	end
	hook.Add( "Think", "Hunters.PropScanner.Think", Think )

end
