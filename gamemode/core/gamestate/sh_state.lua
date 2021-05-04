--[[
sh_state.lua

MrGrimm

Used to identify what state the game is currently in.
i.e. "PreGame", "Playing", etc.

--]]

GameState = {}

--[[------------------------------------------------
	Name: GetState()
	Desc: Returns the current state.
--]]------------------------------------------------
function GameState.GetState()

	return GameState.State or "Error"
	
end

--[[------------------------------------------------
	Name: IsState()
	Desc: Returns true id the given state matches the current state.
--]]------------------------------------------------
function GameState.IsState( state )

	-- Accepts only string
	if ( state && TypeID(state) == TYPE_STRING ) then
		return GameState.GetState() == string.lower( state )
	end
	
	-- Fallback result 
	return false
	
end

--------------------
--	Client
--------------------

local function Initialize()
	net.Start("GameState")
	net.SendToServer()
end
hook.Add( "Initialize", "GameState.Initialize", Initialize )

net.Receive("GameState", function(len, ply)
	GameState.State = net.ReadString()
end )