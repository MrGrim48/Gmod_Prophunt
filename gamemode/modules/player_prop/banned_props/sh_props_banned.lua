
if SERVER then 

	util.AddNetworkString( "SendBannedPropData" )
	util.AddNetworkString( "OpenBannedPropsWindow" )
	util.AddNetworkString( "ModifyBannedPropData" )
	util.AddNetworkString( "SendPropModelFromServer" )
	

	hook.Add( "InitPostEntity", "BannedProps.InitPostEntity", function()
		
		-- Load Data
		if file.Exists( "banned_props.txt", "DATA" ) then
			BannedProps = util.JSONToTable( file.Read( "banned_props.txt", "DATA" ) )
		end

	end )
	
	
	concommand.Add( "banned_props", function( ply, cmd, args )
		
		if IsValid(ply) && ply:CheckGroup( "admin" ) then
			-- Send Banned Props Data
			for model, banned in pairs( BannedProps ) do
				net.Start( "SendBannedPropData" )
				net.WriteString( model )
				net.WriteBool( banned )
				net.Send( ply )
			end
			
			-- Send the model of the props in the map because calling this clientside only lists props near the player
			local propModels = {}
			for _, ent in pairs( ents.FindByClass( "prop_phys*" ) ) do
				if !propModels[ent:GetModel()] then
					propModels[ent:GetModel()] = true
					
					net.Start( "SendPropModelFromServer" )
					net.WriteString( ent:GetModel() )
					net.Send( ply )
				end
			end
			
			-- Create Window
			net.Start( "OpenBannedPropsWindow" )
			net.Send( ply )
		end
		
	end )
	
	
	net.Receive( "ModifyBannedPropData", function( len, ply )
	
		if IsValid( ply ) && ply:CheckGroup( "admin" ) then
			local model = net.ReadString()
			local isBanned = net.ReadBool()
			
			BannedProps[model] = isBanned
			
			file.Write( "banned_props.txt", util.TableToJSON(BannedProps) )
		end
	
	end )
	
else --Client	

	net.Receive( "OpenBannedPropsWindow", function( len, ply )
		BannedPropsWindow = vgui.Create( "BannedPropsAdmin" )
		BannedPropsWindow:SetPos( 50, 50 )
		BannedPropsWindow:SetSize( 600, 400 )
		BannedPropsWindow:Initialize()
		BannedPropsWindow:MakePopup()
	end )
	
	net.Receive( "SendBannedPropData", function( len, ply )
		local model = net.ReadString()
		local banned = net.ReadBool()
		
		if !BannedPropsData then 
			BannedPropsData = {} 
		end
		
		BannedPropsData[model] = banned
	end )
	
	net.Receive( "SendPropModelFromServer", function( len, ply )
		local model = net.ReadString()
		if !PropModels then PropModels = {} end
		if !table.HasValue( PropModels, model ) then
			table.insert( PropModels, model )
		end
	end )
	
end