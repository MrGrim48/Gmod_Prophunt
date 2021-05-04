--[[
sh_playerthink_handler.lua

MrGrimm

In order to reduce the amount of loops through all players
in each Think function, you can add a hook which in one loop
will call the functions added.
Don't know if this would make any difference.

--]]

PlayerThink = {}
local hookFunctions = {}

--[[------------------------------------------------
	Name: Think()
	Desc: Iterates all players and calls all hooked functions.
--]]------------------------------------------------
local function Think()

	for i=1, #player.GetAll() do
		for k, func in pairs(hookFunctions) do
			if func then
				func( player.GetAll()[i] )
			end
		end
	end

end
hook.Add( "Think", "PlayerThinkHandler.Think", Think )

--[[------------------------------------------------
	Name: hookAdd()
	Desc: Adds the function to the table with the given key.
--]]------------------------------------------------
function PlayerThink.hookAdd( key, func )

	print( "[PlayerThink] Added", key )
	
	hookFunctions[ key ] = func
	
	
end