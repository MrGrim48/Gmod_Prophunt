--[[
cl_player.lua

MrGrimm

--]]

module( "Players", package.seeall )

--[[------------------------------------------------
	Name: ResetHull()
	Desc: Resets the player hull.
--]]------------------------------------------------
local function ResetHull()

	if IsValid( LocalPlayer() ) then
		LocalPlayer():ResetHull()
	end
	
end
net.Receive( "ResetHull", ResetHull )

--[[------------------------------------------------
	Name: CalcView()
	Desc: Decide where the player view should be.
--]]------------------------------------------------
function GM:CalcView( ply, origin, angles, fov )
	
	-- Create empty array to store view information in.
	local view = {} 
	
	-- If the player is supposed blind, set their view off the map.
	if ply:GetNWBool( "Blind" ) then
		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
		view.fov 	= fov
		
		return view
	end
	
	-- Set view variables to given function arguements.
 	view.origin = origin 
 	view.angles	= angles 
 	view.fov 	= fov 
 	
 	-- If the player is a Prop, we know they won't have a weapon so just set their view to third person.
	if ply:Team() == TEAM_PROPS && ply:Alive() then
		local bounds = 4
		local minTraceBounds, maxTraceBounds = Vector(-bounds,-bounds,-bounds), Vector(bounds,bounds,bounds)
		local prop = ply.ph_prop
		if ( IsValid(prop) ) then
			local propSize = Vector( prop:OBBMaxs().x-prop:OBBMins().x, prop:OBBMaxs().y-prop:OBBMins().y, prop:OBBMaxs().z-prop:OBBMins().z ) * 0.5
			minTraceBounds = Vector( math.max(-bounds,-propSize.x), math.max(-bounds,-propSize.y), math.max(-bounds,-propSize.z) )
			maxTraceBounds = Vector( math.min(bounds,propSize.x), math.min(bounds,propSize.y), math.min(bounds,propSize.z) )
		end
		
		-- Trace to prevent camera looking through walls etc.
		local traceFilter = {}
		table.Add( traceFilter, player.GetAll() )
		table.Add( traceFilter, ents.FindByClass("ph_prop") )
		table.Add( traceFilter, ents.FindByClass("ph_dummy") )
		local tr = util.TraceHull({ start = view.origin,
									endpos = view.origin + angles:Forward() * -80,
									maxs = maxTraceBounds,
									mins = minTraceBounds,
									filter = traceFilter,
									mask = MASK_SHOT_HULL})
						 
		view.origin = tr.HitPos
	else
		-- Give the active weapon a go at changing the viewmodel position.
	 	local wep = ply:GetActiveWeapon() 
		
	 	if wep && wep != NULL then 
			-- Try ViewModelPosition first.
	 		local func = wep.GetViewModelPosition 
			
	 		if func then 
	 			view.vm_origin, view.vm_angles = func(wep, origin * 1, angles * 1)
	 		end
	 		 
			-- But let the weapon's CalcView override.
	 		local func = wep.CalcView 
			
	 		if func then 
				view.origin, view.angles, view.fov = func(wep, ply, origin * 1, angles * 1, fov)
	 		end 
	 	end
	end
	
	hook.Call( "PostCalcView" )
 	
 	return view
	
end