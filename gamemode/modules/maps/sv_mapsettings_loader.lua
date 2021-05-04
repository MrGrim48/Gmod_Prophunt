
-- Include the configuration for this map
if file.Exists("gamemodes/prop_hunt/gamemode/modules/maps/"..game.GetMap()..".lua", "MOD") then
	print( "------Map settings loaded------" )
	include(game.GetMap()..".lua")
end