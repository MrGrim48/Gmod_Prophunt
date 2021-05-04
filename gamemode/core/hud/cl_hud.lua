--
-- cl_hud.lua
-- Prop Hunt
--	
-- Created by Andrew Theis on 2013-10-31. Modified from original Facepunch fretta file.
-- Copyright (c) 2013 Andrew Theis. All rights reserved.
--


local hudScreen = nil
local Alive = false
local Class = nil
local Team = 0
local WaitingToRespawn = false
local InRound = false
local RoundResult = 0
local RoundWinner = nil
local IsObserver = false
local ObserveMode = 0
local ObserveTarget = NULL
local InVote = false

function GM:AddHUDItem( item, pos, offset, parent )
	hudScreen:AddItem( item, parent, pos, offset )
end

function GM:HUDNeedsUpdate()

	if ( !IsValid( LocalPlayer() ) ) then return false end

	if ( Class != LocalPlayer():GetNWString( "Class", "Default" ) ) then return true end
	if ( Alive != LocalPlayer():Alive() ) then return true end
	if ( Team != LocalPlayer():Team() ) then return true end
	if ( WaitingToRespawn != ( (LocalPlayer():GetNWFloat( "RespawnTime", 0 ) > CurTime()) && LocalPlayer():Team() != TEAM_SPECTATOR && !LocalPlayer():Alive()) ) then return true end
	if ( InRound != GetGlobalBool( "InRound", false ) ) then return true end
	if ( RoundResult != GetGlobalInt( "RoundResult", 0 ) ) then return true end
	if ( RoundWinner != GetGlobalEntity( "RoundWinner", nil ) ) then return true end
	if ( LocalPlayer().IsObserver && IsObserver != LocalPlayer():IsObserver() ) then return true end
	if ( ObserveMode != LocalPlayer():GetObserverMode() ) then return true end
	if ( ObserveTarget != LocalPlayer():GetObserverTarget() ) then return true end
	if ( StateGame != GameState.GetState() ) then return true end
	
	return false
end

function GM:OnHUDUpdated()
	Class = LocalPlayer():GetNWString( "Class", "Default" )
	Alive = LocalPlayer():Alive()
	Team = LocalPlayer():Team()
	WaitingToRespawn = (LocalPlayer():GetNWFloat( "RespawnTime", 0 ) > CurTime()) && LocalPlayer():Team() != TEAM_SPECTATOR && !Alive
	InRound = GetGlobalBool( "InRound", false )
	RoundResult = GetGlobalInt( "RoundResult", 0 )
	RoundWinner = GetGlobalEntity( "RoundWinner", nil )
	IsObserver = LocalPlayer():IsObserver()
	ObserveMode = LocalPlayer():GetObserverMode()
	ObserveTarget = LocalPlayer():GetObserverTarget()
	StateGame = GameState.GetState()
end

function GM:OnHUDPaint()

end

function GM:RefreshHUD()

	if ( !GAMEMODE:HUDNeedsUpdate() ) then return end
	GAMEMODE:OnHUDUpdated()
	
	if ( IsValid( hudScreen ) ) then hudScreen:Remove() end
	hudScreen = vgui.Create( "DHudLayout" )
	
	if ( InVote ) then return end
	
	if ( GAMEMODE.RoundBased && GameState && (GameState.IsState("Waiting") || GameState.IsState("PreGame")) ) then
		GAMEMODE:UpdateHUD_PreGame()
	elseif ( RoundWinner and RoundWinner != NULL ) then
		GAMEMODE:UpdateHUD_RoundResult( RoundWinner, Alive )
	elseif ( RoundResult != 0 ) then
		GAMEMODE:UpdateHUD_RoundResult( RoundResult, Alive )
	elseif ( IsObserver ) then
		GAMEMODE:UpdateHUD_Observer( WaitingToRespawn, InRound, ObserveMode, ObserveTarget )
	elseif ( !Alive ) then
		GAMEMODE:UpdateHUD_Dead( WaitingToRespawn, InRound )
	else
		GAMEMODE:UpdateHUD_Alive( InRound )
	end
	
end

function GM:HUDPaint()

	self.BaseClass:HUDPaint()
	
	GAMEMODE:OnHUDPaint()
	GAMEMODE:RefreshHUD()
	
end

function GM:UpdateHUD_RoundResult( RoundResult, Alive )

	local txt = GetGlobalString( "RRText" )
	
	if ( type( RoundResult ) == "number" ) && ( team.GetAllTeams()[ RoundResult ] && txt == "" ) then
		local TeamName = team.GetName( RoundResult )
		if ( TeamName ) then txt = TeamName .. " Wins!" end
	elseif ( type( RoundResult ) == "Player" && IsValid( RoundResult ) && txt == "" ) then
		txt = RoundResult:Name() .. " Wins!"
	end

	local RespawnText = vgui.Create( "DHudElement" );
		RespawnText:SizeToContents()
		RespawnText:SetText( txt )
	GAMEMODE:AddHUDItem( RespawnText, 2 )

end

function GM:UpdateHUD_PreGame()

	if GameState && GameState.IsState( "PreGame" ) then
		local PreGameText = vgui.Create( "DHudCountdown" )
			PreGameText:SizeToContents()
			PreGameText:SetValueFunction( function() return GetGlobalFloat( "PreGameStartTime", 0 ) end )
			PreGameText:SetLabel( "GAME STARTING IN" )
		GAMEMODE:AddHUDItem( PreGameText, 2 )
	else
		local RespawnText = vgui.Create( "DHudElement" );
			RespawnText:SizeToContents()
			RespawnText:SetText( "Waiting for round start" )
		GAMEMODE:AddHUDItem( RespawnText, 2 )
	end

end

function GM:UpdateHUD_Observer( bWaitingToSpawn, InRound, ObserveMode, ObserveTarget )

	local lbl = nil
	local txt = nil
	local col = Color( 255, 255, 255 );
	
	if IsValid(ObserveTarget) && ObserveTarget:GetClass() == "ph_prop" && IsValid(ObserveTarget:GetOwner()) then 
		ObserveTarget = ObserveTarget:GetOwner()
	end

	if ( IsValid( ObserveTarget ) && ObserveTarget:IsPlayer() && ObserveTarget != LocalPlayer() && ObserveMode != OBS_MODE_ROAMING ) then
		lbl = "SPECTATING"
		txt = ObserveTarget:Nick()
		col = team.GetColor( ObserveTarget:Team() );
	end
	
	if ( ObserveMode == OBS_MODE_DEATHCAM || ObserveMode == OBS_MODE_FREEZECAM ) then
		txt = "You Died!" // were killed by?
	end
	
	if ( txt ) then
		local txtLabel = vgui.Create( "DHudElement" );
		txtLabel:SetText( txt )
		if ( lbl ) then txtLabel:SetLabel( lbl ) end
		txtLabel:SetTextColor( col )
		
		local offset = 60
		if CRounds and CRounds.ActiveRound then offset = 120 end
		GAMEMODE:AddHUDItem( txtLabel, 2, offset )		
	end
	
	
	if LocalPlayer():Team() == TEAM_SPECTATOR then
		local txtLabel = vgui.Create( "DHudElement" )
		txtLabel:SetText( "Press F2 or type !team to Join a team" )
		txtLabel:SetTextColor( Color( 100, 200, 200 ) )
		GAMEMODE:AddHUDItem( txtLabel, 8, 100 )
	end

	
	GAMEMODE:UpdateHUD_Dead( bWaitingToSpawn, InRound )

end

function GM:UpdateHUD_Dead( bWaitingToSpawn, InRound )

	if ( bWaitingToSpawn ) then

		local RespawnTimer = vgui.Create( "DHudCountdown" );
			RespawnTimer:SizeToContents()
			RespawnTimer:SetValueFunction( function() return LocalPlayer():GetNWFloat( "RespawnTime", 0 ) end )
			RespawnTimer:SetLabel( "SPAWN IN" )
		GAMEMODE:AddHUDItem( RespawnTimer, 2 )
		return

	end
	
	GAMEMODE:UpdateHUD_Alive( InRound )

end

function GM:UpdateHUD_Alive( InRound )

	if ( GAMEMODE.RoundBased || GAMEMODE.TeamBased ) then
	
		local Bar = vgui.Create( "DHudBar" )
		GAMEMODE:AddHUDItem( Bar, 2 )

		if ( GAMEMODE.TeamBased && GAMEMODE.ShowTeamName ) then
		
			local TeamIndicator = vgui.Create( "DHudUpdater" );
				TeamIndicator:SizeToContents()
				TeamIndicator:SetValueFunction( function() 
													return team.GetName( LocalPlayer():Team() )
												end )
				TeamIndicator:SetColorFunction( function() 
													return team.GetColor( LocalPlayer():Team() )
												end )
				TeamIndicator:SetFont( "HudSelectionText" )
			Bar:AddItem( TeamIndicator )
			
		end
		
		if ( GAMEMODE.RoundBased ) then 
		
			local RoundNumber = vgui.Create( "DHudUpdater" );
				RoundNumber:SizeToContents()
				RoundNumber:SetValueFunction( function() return GetGlobalInt( "RoundNumber", 0 ) end )
				RoundNumber:SetLabel( "ROUND" )
			Bar:AddItem( RoundNumber )
			
			local RoundTimer = vgui.Create( "DHudCountdown" );
				RoundTimer:SizeToContents()
				RoundTimer:SetValueFunction( function() 
												if ( GetGlobalFloat( "RoundStartTime", 0 ) > CurTime() ) then return GetGlobalFloat( "RoundStartTime", 0 )  end 
												return GetGlobalFloat( "RoundEndTime" ) end )
				RoundTimer:SetLabel( "TIME" )
			Bar:AddItem( RoundTimer )

		end
		
	end

end


local hide = {
	CHudHealth = true,
	CHudBattery = true,
	CHudAmmo = true,
	CHudSecondaryAmmo = true,
}
hook.Add( "HUDShouldDraw", "PH_HideHUD", function( name ) 
	if hide[name] then return false end 
end )

-- Draw round timeleft and hunter release timeleft.
function HUDPaint()

	-- Draw new Health
	local y = ScrH() - 80
	draw.RoundedBox( 0, 30, y, 190, 55, Color( 50,50,50,200 ) )
	draw.SimpleText( "Health", "Hud.Name", 45, y+5, Color(255,255,60) )
	draw.SimpleText( tostring(LocalPlayer():Health()), "Hud.Number", 190, y+2, Color(255,255,60), TEXT_ALIGN_RIGHT )
	
	-- Draw new ammo
	local x = ScrW() - 280
	local y = ScrH() - 80
	local wep = LocalPlayer():GetActiveWeapon()
	if ( IsValid( wep ) ) then
		local ammo = LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType() )
		local clip = wep:Clip1()
		local alt = LocalPlayer():GetAmmoCount( wep:GetSecondaryAmmoType() )
		if wep:GetSecondaryAmmoType() >= 0 then
			x = x - 110
			local x2 = x + 255
			draw.RoundedBox( 0, x2, y, 100, 55, Color( 50,50,50,200 ) )
			draw.SimpleText( "Alt", "Hud.Name", x2+15, y+5, Color(255,255,60) )
			draw.SimpleText( tostring(alt), "Hud.Number", x2+80, y+2, Color(255,255,60), TEXT_ALIGN_RIGHT )
		end
		if ammo > 0 then
			draw.RoundedBox( 0, x, y, 245, 55, Color( 50,50,50,200 ) )
			draw.SimpleText( "Ammo", "Hud.Name", x+15, y+5, Color(255,255,60) )
			draw.SimpleText( tostring(clip), "Hud.Number", x+140, y+2, Color(255,255,60), TEXT_ALIGN_RIGHT )
			draw.SimpleText( tostring(ammo), "Hud.NumberSmall", x+220, y+23, Color(255,255,60), TEXT_ALIGN_RIGHT )
		end
	end

	-- If we aren't in a round, don't paint anything.
	if !GetGlobalBool("InRound") then 
		return
	end
	
	-- Caculate the time left for blindlock.
	local blindlock_time_left = (GAMEMODE.HunterBlindLockTime - (CurTime() - GetGlobalFloat("RoundStartTime", 0))) + 1
	
	-- Decide what text to display on the hud based on the time left.
	if blindlock_time_left < 1 && blindlock_time_left > -6 then
		blindlock_time_left_msg = "Hunters have been released!"
	elseif blindlock_time_left > 0 then
		blindlock_time_left_msg = "Hunters will be unblinded and released in "..string.ToMinutesSeconds(blindlock_time_left)
	else
		blindlock_time_left_msg = nil
	end
	
	-- If there is text to display, display it.
	if blindlock_time_left_msg then
		surface.SetFont("ph_arial")
		local tw, th = surface.GetTextSize(blindlock_time_left_msg)
		
		draw.RoundedBox(8, 20, 20, tw + 20, 26, Color(0, 0, 0, 75))
		draw.DrawText(blindlock_time_left_msg, "ph_arial", 31, 26, Color(255, 255, 0, 255), TEXT_ALIGN_LEFT)
	end
	
end
hook.Add("HUDPaint", "PH_HUDPaint", HUDPaint)