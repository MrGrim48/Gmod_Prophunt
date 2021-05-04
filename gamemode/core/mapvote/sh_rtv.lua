/*
sh_rtv.lua

Copyright© Nekom Glew, 2017

This was not made by me, I don't remember whom.

*/

RTV = RTV or {}

RTV.ChatCommands = {
	"!rtv",
	"/rtv",
	"rtv"
}

RTV.Maps = {
	"ph_","css_","des_",
}

RTV.TotalVotes = 0

RTV.Wait = 60 -- The wait time in seconds. This is how long a player has to wait before voting when the map changes. 
			  -- If the "extend" option is picked, you have to wait double this before voting again.


RTV._ActualWait = CurTime() + RTV.Wait

if SERVER then
util.AddNetworkString( "ForceMapVote" )
net.Receive( "ForceMapVote", function( len, ply )
	if IsValid(ply) && ply:IsPlayer() && ply:CheckGroup( "admin" ) then
		RTV.Start()
	end
end )
end

concommand.Add( "force_mapvote", function( ply, cmd, args )
	if CLIENT then
		net.Start( "ForceMapVote" )
		net.SendToServer()
	else
		RTV.Start()
	end
end )


function RTV.ShouldChange()
	return RTV.TotalVotes >= math.Round(#player.GetAll()*0.66)
end

function RTV.RemoveVote()
	RTV.TotalVotes = math.Clamp( RTV.TotalVotes - 1, 0, math.huge )
end

function RTV.Start()

	MapVote.Start( 20, false, 30, RTV.Maps )

end


function RTV.AddVote( ply )

	if RTV.CanVote( ply ) then
		RTV.TotalVotes = RTV.TotalVotes + 1
		ply.RTVoted = true
		--MsgN( ply:Nick().." has voted to Rock the Vote." )
		util.Broadcast(Color( 255, 255, 0 ), "[!RTV] ", Color(45, 147, 181), ply:Nick(), Color( 255, 255, 255 ),  " has rocked the vote. (", RTV.TotalVotes, "/", math.Round(#player.GetAll()*0.66), ")")
		--PrintMessage( HUD_PRINTTALK, ply:Nick().." has voted to Rock the Vote. ("..RTV.TotalVotes.."/"..math.Round(#player.GetAll()*0.66)..")" )

		if RTV.ShouldChange() then
			RTV.Start()
		end
	end

end

hook.Add( "PlayerDisconnected", "Remove RTV", function( ply )

	if ply.RTVoted then
		RTV.RemoveVote()
	end

	timer.Simple( 0.1, function()

		if RTV.ShouldChange() then
			RTV.Start()
		end

	end )

end )

function RTV.CanVote( ply )

	if RTV._ActualWait >= CurTime() then
		return false, "You must wait a bit before voting!"
	end

	if GetGlobalBool( "In_Voting" ) then
		return false, "There is currently a vote in progress!"
	end

	if ply.RTVoted then
		return false, "You have already voted to Rock the Vote!"
	end

	if RTV.ChangingMaps then
		return false, "There has already been a vote, the map is going to change!"
	end

	return true

end

function RTV.StartVote( ply )

	local can, err = RTV.CanVote(ply)

	if not can then
		ply:PrintMessage( HUD_PRINTTALK, err )
		return
	end

	RTV.AddVote( ply )

end

concommand.Add( "rtv_start", RTV.StartVote )

hook.Add( "PlayerSay", "RTV Chat Commands", function( ply, text )

	if table.HasValue( RTV.ChatCommands, string.lower(text) ) then
		RTV.StartVote( ply )
		return ""
	end

end )