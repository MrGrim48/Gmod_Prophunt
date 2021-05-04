if SERVER then

	util.AddNetworkString( "HighlightProp" )
	util.AddNetworkString( "HighlightProp.ClearCache" )
	
	net.Receive( "HighlightProp", function( len, ply )
		local ent = net.ReadEntity()
		if IsValid(ent) then
			local isValid = true
			if hook.Run( "IsValidPropChange",  ply, ent) != nil then isValid = false end
			if BannedProps[ent:GetModel()] then isValid = false end
			net.Start( "HighlightProp" )
			net.WriteString( ent:GetModel() )
			net.WriteBool( isValid )
			net.Send( ply )
		end
	end )
	
	function HighlightProp_ClearCache(ply)
		net.Start( "HighlightProp.ClearCache" )
		if ply then net.Send( ply )
		else net.Broadcast() end
	end

else
	CreateClientConVar( "prophunt_highlightprops", "1", true, true )
	
	hook.Add( "Menu.Opened", "Player.HighlightPlayers", function()
		Menu.Options:AddNewConVar( "prophunt_highlightprops", "Highlight Targeted Props" )
	end)
	
	local tableProps = {
		ph_prop = true,
		ph_dummy = true,
		prop_physics = true,
		prop_physics_multiplayer = true
	}
	
	local isValidProps  = {}
	
	net.Receive( "HighlightProp", function()
		isValidProps[net.ReadString()] = net.ReadBool()
	end )
	
	net.Receive( "HighlightProp.ClearCache", function()
		isValidProps = {}
	end )

	-- Draws a halo around valid props
	hook.Add( "PreDrawHalos", "Props.PreDrawHalos", function() 

		-- Prop Highlight
		if ( LocalPlayer():Team() == TEAM_PROPS ) && LocalPlayer():Alive() && GetConVar("prophunt_highlightprops"):GetInt() == 1 then
		
			-- Default trace values
			local startPos = LocalPlayer():GetPos() + LocalPlayer():GetViewOffset()
			local endPos = startPos + EyeAngles():Forward() * 80
			local color = Color(100,255,100) 
			
			-- Trace for valid props
			local tr = {}
			local props = {LocalPlayer()}
			table.Add( props, ents.FindByClass( "ph_prop" ) )
			tr = util.TraceLine({
				start = startPos,
				endpos = endPos,
				filter = props
			})
			if !tr.Hit then 
				tr = util.TraceHull({ 
					start = startPos, 
					endpos = endPos, 
					filter = props,
					ignoreworld = true,
					maxs = Vector(2,2,2),
					mins = Vector(-2,-2,-2)
				})
			end
				
			-- Add halo to valid prop
			if IsValid(tr.Entity) && tableProps[tr.Entity:GetClass()] then
				if isValidProps[tr.Entity:GetModel()] == nil then
					isValidProps[tr.Entity:GetModel()] = true 
					net.Start( "HighlightProp" )
					net.WriteEntity( tr.Entity )
					net.SendToServer()
				elseif !isValidProps[tr.Entity:GetModel()] then
					color = Color( 255,0,0 )
				end				
					
				if isValidProps[tr.Entity:GetModel()] then
					halo.Add( {tr.Entity}, color, 1, 1, 1, true, true )
				end
			end
		end

	end)
end