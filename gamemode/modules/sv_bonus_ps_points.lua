/*
sv_bonus_ps_points.lua

Copyright© Nekom Glew, 2017

*/

BonusPSPoints = {}

BonusPSPoints.PropWinPointsAlive = 50
BonusPSPoints.PropWinPoints = 20

BonusPSPoints.HunterWinPointsAlive = 40
BonusPSPoints.HunterWinPoints = 15
BonusPSPoints.HunterKillPoints = 5

BonusPSPoints.PointsMultiplier = 2

--[[--------------------------------------------------------
	Name: RoundEnd
	Desc: Gives bonus points the players when the round ends
--]]--------------------------------------------------------
function BonusPSPoints.RoundEnd( team_id )

	if !hook.Run( "OverrideBonusPoints", team_id ) then
		for _, ply in pairs( player.GetAll() ) do
			if team_id == TEAM_PROPS && IsValid(ply) && ply:Team() == team_id then
				if ply:Alive() then
					ply:PS_GivePoints( BonusPSPoints.PropWinPointsAlive*BonusPSPoints.PointsMultiplier )
					ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.PropWinPointsAlive*BonusPSPoints.PointsMultiplier, Color(100,255,100), ' points for staying alive' )
				else
					ply:PS_GivePoints( BonusPSPoints.PropWinPoints*BonusPSPoints.PointsMultiplier )
					ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.PropWinPoints*BonusPSPoints.PointsMultiplier, Color(100,255,100), ' points for being on the winning team' )
				end
			elseif team_id == TEAM_HUNTERS && IsValid(ply) && ply:Team() == team_id then
				if ply:Alive() then
					ply:PS_GivePoints( BonusPSPoints.HunterWinPointsAlive*BonusPSPoints.PointsMultiplier )
					ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.HunterWinPointsAlive*BonusPSPoints.PointsMultiplier, Color(100,255,100), ' points for winning the round' )
				else
					ply:PS_GivePoints( BonusPSPoints.HunterWinPoints*BonusPSPoints.PointsMultiplier )
					ply:PlayerMsg( Color(100,255,100), 'You got ', Color(100,100,255), BonusPSPoints.HunterWinPoints*BonusPSPoints.PointsMultiplier, Color(100,255,100), ' points for being on the winning team' )
				end
			end
		end
	end

end
hook.Add( "RoundEndWithResult", "BonusPSPoints.RoundEnd", BonusPSPoints.RoundEnd )


--[[--------------------------------------------------------
	Name: RoundEnd
	Desc: Gives bonus points the players when the round ends
--]]--------------------------------------------------------
function BonusPSPoints.PropKilled( ply, inflictor, attacker )

	if attacker:Team() == TEAM_HUNTERS then
		attacker:PS_GivePoints( BonusPSPoints.HunterKillPoints*BonusPSPoints.PointsMultiplier )
		attacker:PlayerMsg( Color(100,255,100), 'Prop Kill: ', Color(100,100,255), BonusPSPoints.HunterKillPoints*BonusPSPoints.PointsMultiplier, Color(100,255,100), ' points' )
	end

end
hook.Add( "PropKilled", "BonusPSPoints.PropKilled", BonusPSPoints.PropKilled )

