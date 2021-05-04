
MapGroups = {}

if SERVER then

	util.AddNetworkString( "SendMapGroupData" )
	util.AddNetworkString( "OpenMapGroupsWindow" )
	util.AddNetworkString( "ModifyMapGroup" )

	hook.Add( "InitPostEntity", "MapGroups.InitPostEntity", function()
		-- Load Data
		if file.Exists( "map_groups.txt", "DATA" ) then
			MapGroups = util.JSONToTable( file.Read( "map_groups.txt", "DATA" ) )
		end
		
		local maps = file.Find("maps/*.bsp", "GAME")
		for _, map in pairs( maps ) do
			if !MapGroups[map] then MapGroups[map] = "Large" end
		end
	end )
	
	
	concommand.Add( "map_groups", function( ply, cmd, args )
	
		if IsValid(ply) && ply:CheckGroup( "admin" ) then
			-- Send map groups data
			for map, group in pairs( MapGroups ) do
				net.Start( "SendMapGroupData" )
				net.WriteString( map )
				net.WriteString( group ) 
				net.Send( ply )
			end
			
			-- Create Window
			net.Start( "OpenMapGroupsWindow" )
			net.Send( ply )
		end
	
	end )
	
	
	net.Receive( "ModifyMapGroup", function( len, ply )
	
		if IsValid( ply ) && ply:CheckGroup( "admin" ) then
			local map = net.ReadString()
			local group = net.ReadString()
			
			MapGroups[map] = group
			
			file.Write( "map_groups.txt", util.TableToJSON(MapGroups) )
		end
	
	end )
	
else -- CLIENT

	net.Receive( "OpenMapGroupsWindow", function( len, ply )
		MapGroupsWindow = vgui.Create( "MapGroupsAdmin" )
		MapGroupsWindow:MakePopup()
	end )
	
	net.Receive( "SendMapGroupData", function( len, ply )
		local map = net.ReadString()
		local group = net.ReadString()
		
		MapGroups[map] = group
	end )

end
