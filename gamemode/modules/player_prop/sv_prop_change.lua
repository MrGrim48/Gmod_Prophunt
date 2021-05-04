
UsableEntities = {
	prop_physics = true,
	prop_physics_multiplayer = true
}

BannedProps = {
	["models/props/cs_assault/dollar.mdl"] = true,
	["models/props/cs_assault/money.mdl"] = true,
	["models/props/cs_office/snowman_arm.mdl"] = true,
	["models/props/cs_office/computer_mouse.mdl"] = true,
	["models/props/cs_office/projector_remote.mdl"] = true,
	["models/props/cs_office/computer_caseb_p2a.mdl"] = true,
	["models/foodnhouseholditems/mcdfriedchickenleg.mdl"] = true,
}

function ChangeProp( ply, ent )

	if !IsValid(ply.ph_prop) or !IsValid(ent) then return end

	-- If player is a Prop, set their prop entity to whatever they are looking at.
	if (ply:OnGround() || ply:WaterLevel() > 0) && !ply:Crouching() && UsableEntities[ent:GetClass()] && ent:GetModel() then
	
		local isValid = hook.Run( "IsValidPropChange",  ply, ent )
		if isValid != nil then
			if isValid == false then
				ply:ChatPrint("That prop is currently disabled.")
			elseif type(isValid)=="string" then
				ply:ChatPrint(isValid)
			end
			return false
		end

		-- Make sure the prop hasn't been banned by the server.
		if BannedProps[ent:GetModel()] then
			ply:ChatPrint("That prop has been banned by the server.")
			return false
		end

		-- Check for valid entity.
		if IsValid(ent:GetPhysicsObject()) && ply.ph_prop:GetModel() != ent:GetModel() then
		
			local entVolume = ent:GetPhysicsObject():GetVolume()

			-- Calculate the entity's max health based on size. Then calculate the players's new health based on existing health percentage.
			local ent_health = math.Clamp( entVolume / 250, 1, 200 )
			local new_health = math.Clamp( (ply:Health() / ply.max_health) * ent_health, 1, 200 )
		
			-- Set prop entity health and max health.
			ply.max_health = ent_health
			ply:SetHealth( new_health )
			
			-- Setup new model/texture.			
			ply.ph_prop:SetAngles( Angle(0, ply:EyeAngles().y, 0) )
			ply.ph_prop:SetModel(ent:GetModel())
			ply.ph_prop:SetSkin(ent:GetSkin())
			
			ply.ph_prop:SetLocalPos( -Vector(0,0,ply.ph_prop:OBBMins().z) )
			
			-- Set the players view offset
			local propHeight = math.Round(ent:OBBMaxs().z-ent:OBBMins().z)
			ply:SetViewOffset( Vector(0,0,propHeight*0.95) )
			ply:SetViewOffsetDucked( Vector(0,0,propHeight*0.95) )
			
			ply:SetNWInt( "PropHeight", propHeight )
			
			timer.Simple(0.1, function() 
				ply:SetPropHull( ply.ph_prop ) 
			end )
			
			hook.Run( "PropChangedModel", ply )
			
		end
	end
	
end

-- Change prop when a player presses "Use" while looking at a valid prop
local function PlayerKeyPress( ply, key )

	if ply:Team() == TEAM_PROPS && key == IN_USE && !ply:GetNWBool("PhysicsMode",false) then
		local startPos = ply:EyePos()
		local endPos = startPos + ply:EyeAngles():Forward()*80
		local filter = table.Add( player.GetAll(), ents.FindByClass("ph_prop") )
		local tr = util.TraceLine({ 
			start = startPos, 
			endpos = endPos, 
			filter = filter,
		})
		if !tr.Hit then
			tr = util.TraceHull({
				start = startPos,
				endpos = endPos,
				filter = filter,
				ignoreworld = true,
				maxs = Vector(2,2,2),
				mins = Vector(-2,-2,-2)
			})
		end
		
		if IsValid(tr.Entity) && UsableEntities[tr.Entity:GetClass()] then 
			local filter = player.GetAll()
			table.Add( filter, ents.FindByClass("ph_prop") )
			table.Add( filter, ents.FindByClass("prop_physics") )
			table.Add( filter, ents.FindByClass("prop_physics_multiplayer") )
		
			local trHeight = util.TraceLine({ 
				start = ply:GetPos(), 
				endpos = ply:GetPos() + Vector(0,0,tr.Entity:OBBMaxs().z-tr.Entity:OBBMins().z), 
				filter = filter
			})
			
			if trHeight.Hit then
				ply:ChatPrint( "[FAILED] Not enough head room to change into prop" )
				return 
			end
			
			ChangeProp( ply, tr.Entity )
		end
	end

end
hook.Add( "KeyPress", "PropChange.KeyPress", PlayerKeyPress )