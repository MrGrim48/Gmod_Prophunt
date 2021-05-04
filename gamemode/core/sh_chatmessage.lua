--[[
sh_chatmessage.lua

MrGrimm

Utility to allow sending/broadcasting messages
with the use of colors, etc.

--]]


if SERVER then 

	util.AddNetworkString( "ChatMessage" )
	local Player = FindMetaTable( "Player" )
	
	--[[------------------------------------------------
		Name: Broadcast()
		Desc: Sends a message to all players.
	--]]------------------------------------------------
	function util.Broadcast(...)
		local args = {...}
		net.Start( "ChatMessage" )
		net.WriteTable( args )
		net.Broadcast()
	end

	--[[------------------------------------------------
		Name: PlayerMsg()
		Desc: Sends a message to a single player.
	--]]------------------------------------------------
	function Player:PlayerMsg(...)
		local args = {...}
		net.Start( "ChatMessage" )
		net.WriteTable( args )
		net.Send( self )
	end

else -- CLIENT 

	net.Receive( "ChatMessage", function( len ) 
		local msg = net.ReadTable()
		chat.AddText( unpack( msg ) )
	end)

end
