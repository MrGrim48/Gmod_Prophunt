/*
sv_mapvote.lua

Copyright© Nekom Glew, 2017

This was not made by me, I don't remember whom.

*/

module( "MapVote", package.seeall )

util.AddNetworkString("RAM_MapVoteStart")
util.AddNetworkString("RAM_MapVoteUpdate")
util.AddNetworkString("RAM_MapVoteCancel")

net.Receive("RAM_MapVoteUpdate", function(len, ply)
    if(Allow) then
        if(IsValid(ply)) then
            local update_type = net.ReadUInt(3)
            
            if(update_type == UPDATE_VOTE) then
                local map_id = net.ReadUInt(32)
                
                if(CurrentMaps[map_id]) then
                    Votes[ply:SteamID()] = map_id
                    
                    net.Start("RAM_MapVoteUpdate")
                        net.WriteUInt(UPDATE_VOTE, 3)
                        net.WriteEntity(ply)
                        net.WriteUInt(map_id, 32)
                    net.Broadcast()
                end
            end
        end
    end
end)


function Start(length, current, limit, prefix, callback)
    current = current or Config.AllowCurrentMap or false
    length = length or Config.TimeLimit or 28
    limit = limit or Config.MapLimit or 24

    local is_expression = false

    if not prefix then
        local info = file.Read(GAMEMODE.Folder.."/"..GAMEMODE.FolderName..".txt", "GAME")

        if(info) then
            local info = util.KeyValuesToTable(info)
            prefix = info.maps
        else
            error("MapVote Prefix can not be loaded from gamemode")
        end

        is_expression = true
    else
        if prefix and type(prefix) ~= "table" then
            prefix = {prefix}
        end
    end
    
    local maps = file.Find("maps/*.bsp", "GAME")
    
    local vote_maps = {}
    
    local amt = 0
	
	if false then --MapGroups then
		local targetGroup = "Large"
		if #player.GetAll() <= 6 then
			targetGroup = "Small"
		elseif #player.GetAll() <= 16 then 
			targetGroup = "Medium"
		end
		for map, group in pairs( MapGroups ) do
			if group == targetGroup then
				local mapstr = map:sub(1, -5):lower()
				if(not current and game.GetMap():lower()..".bsp" == map) then continue end
				
				if is_expression then
					if(string.find(map, prefix)) then -- This might work (from gamemode.txt)
						vote_maps[#vote_maps + 1] = map:sub(1, -5)
						amt = amt + 1
					end
				else
					for k, v in pairs(prefix) do
						if string.find(map, "^"..v) then
							vote_maps[#vote_maps + 1] = map:sub(1, -5)
							amt = amt + 1
							break
						end
					end
				end
			end
			if(limit and amt >= limit) then break end
		end
	end

    for k, map in RandomPairs(maps) do
		if(limit and amt >= limit) then break end
		
        local mapstr = map:sub(1, -5):lower()
        if(not current and game.GetMap():lower()..".bsp" == map) then continue end
		
		local alreadyAdded = false
		for i, addedMap in pairs( vote_maps ) do
			if map == addedMap then alreadyAdded = true break end
		end
		if alreadyAdded then continue end

        if is_expression then
            if(string.find(map, prefix)) then -- This might work (from gamemode.txt)
                vote_maps[#vote_maps + 1] = map:sub(1, -5)
                amt = amt + 1
            end
        else
            for k, v in pairs(prefix) do
                if string.find(map, "^"..v) then
                    vote_maps[#vote_maps + 1] = map:sub(1, -5)
                    amt = amt + 1
                    break
                end
            end
        end
    end
    
    net.Start("RAM_MapVoteStart")
        net.WriteUInt(#vote_maps, 32)
        
        for i = 1, #vote_maps do
            net.WriteString(vote_maps[i])
        end
        
        net.WriteUInt(length, 32)
    net.Broadcast()
    
    Allow = true
    CurrentMaps = vote_maps
    Votes = {}
    
    timer.Create("RAM_MapVote", length, 1, function()
        Allow = false
        local map_results = {}
        
        for k, v in pairs(Votes) do
            if(not map_results[v]) then
                map_results[v] = 0
            end
            
            for k2, v2 in pairs(player.GetAll()) do
                if(v2:SteamID() == k) then
                    if(HasExtraVotePower(v2)) then
                        map_results[v] = map_results[v] + 2
                    else
                        map_results[v] = map_results[v] + 1
                    end
                end
            end
            
        end
        
        local winner = table.GetWinningKey(map_results) or 1
        
        net.Start("RAM_MapVoteUpdate")
            net.WriteUInt(UPDATE_WIN, 3)
            
            net.WriteUInt(winner, 32)
        net.Broadcast()
        
        local map = CurrentMaps[winner]

        
        timer.Simple(4, function()
            if (hook.Run("MapVoteChange", map) != false) then
                if (callback) then
                    callback(map)
                else
                    RunConsoleCommand("changelevel", map)
                end
            end
        end)
    end)
end

function Cancel()
    if Allow then
        Allow = false

        net.Start("RAM_MapVoteCancel")
        net.Broadcast()

        timer.Destroy("RAM_MapVote")
    end
end
