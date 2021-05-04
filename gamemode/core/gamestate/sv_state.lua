--[[
sv_state.lua

MrGrimm

Used to identify what state the game is currently in.
i.e. "PreGame", "Playing", etc.
Sets the strings to lowercase.

--]]

local States = {}

util.AddNetworkString( "GameState" )

--[[------------------------------------------------
	Name: Initialize()
	Desc: Sets the initial state to "waiting" when the 
		game first loads.
--]]------------------------------------------------
local function Initialize()

	GameState.SetState( "waiting" )

end
hook.Add( "Initialize", "GameState.Initialize", Initialize )

--[[---------------------------------------------------------
	Name: AddState()
	Desc: Adds a state (string) to the table if it does not yet exist.
-----------------------------------------------------------]]
function GameState.AddState( state )

	assert( state && TypeID(state) == TYPE_STRING, "GameState.AddState: Added state must be valid and a string" )
	States[string.lower( state )] = true

end

--[[---------------------------------------------------------
	Name: SetState()
	Desc: Sets the state based on the given string; Adds the state if it does not exist.
-----------------------------------------------------------]]
function GameState.SetState( state )

	assert( state && TypeID(state) == TYPE_STRING, "GameState.SetState: State must be valid and a string" )

	-- Lower case
	state = string.lower( state )
	
	-- Create state if it does not exist
	if ( !States[state] ) then
		GameState.AddState( state )
	end
	
	GameState.State = state
	GameState.SendCurrentState()
	
	print( " ---- State Changed:", state )
	hook.Run( "OnGameStateChange", state )
	
end

function GameState.SendCurrentState()
	net.Start("GameState")
	net.WriteString(GameState.State)
	net.Broadcast()
end

net.Receive( "GameState", function(len,ply)
	GameState.SendCurrentState()
end )