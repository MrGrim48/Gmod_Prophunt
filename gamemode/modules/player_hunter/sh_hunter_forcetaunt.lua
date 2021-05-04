
local TauntCooldown = 15
local ResultTime = 5
local PropTauntCooldown = 20
	
if SERVER then
	
	util.AddNetworkString( "ForcePropTaunt" )
	
	net.Receive( "ForcePropTaunt", function( len, ply )
	
		if IsValid(ply) && ply:Team() == TEAM_HUNTERS && ply:Alive() then
			if CurTime() > ply:GetNWFloat("ForceTauntTime",0) then
				ForcePropTaunt( ply )
				ply:SetNWFloat( "ForceTauntTime", CurTime() + ply:GetNWInt("TauntCooldownOverride",TauntCooldown) )
				ply:SetNWFloat( "ForceTimeTaunted", CurTime() )
			end
		end
		
	end )
	
	-- Resets the cooldown override when the player spawns
	local function PlayerSpawn( ply )
		
		ply:SetNWInt( "TauntCooldownOverride", TauntCooldown )
		ply:SetNWInt( "ForceTauntTime", 0 )
		ply:SetNWInt( "ForceTimeTaunted", 0 )
		
	end
	hook.Add( "PlayerSpawn", "Hunters.ForceTaunt.PlayerSpawn", PlayerSpawn )
	
	
	function ForcePropTaunt( hunter )
	
		local propPlayers = {}
		
		-- Get the valid and alive prop players and has not taunted recently
		for _,ply in pairs( team.GetPlayers(TEAM_PROPS) ) do
			if IsValid(ply) && ply:Alive() && ( !ply.lastTauntTime || (ply.lastTauntTime + PropTauntCooldown) <= CurTime() ) then
				table.insert( propPlayers, ply )
			end
		end
		
		local randPly = propPlayers[math.random(#propPlayers)]
		if IsValid( randPly ) then
		
			local tauntTargets = { randPly }
			
			-- Get the players dummy props as taunt targets if they have the powerup
			if randPly:GetNWBool( "DummyTauntTargets", false ) then
				for _,ent in pairs( ents.FindByClass("ph_dummy") ) do
					if ent.Creator == randPly then
						table.insert( tauntTargets, ent )
					end
				end
			end
			
			local randTarget = tauntTargets[math.random(#tauntTargets)]
			if IsValid( randTarget ) then
				randTarget:EmitSound( Taunt.GetRandomTaunt(randPly), 100 )
				hunter:SetNWBool( "ForceTauntTarget", true )
			else
				print( "Invalid player to force taunt", randTarget, table.ToString(tauntTargets,"TauntTargets",true) ) --Shouldn't happen
			end
			
		else
			--print( "Invalid player to force taunt", randPly, table.ToString(propPlayers,"PropPlayers",true) ) --Shouldn't happen
		end
	
	end
	
else --Client

	local function HUDPaint()
	
		if LocalPlayer():Team() == TEAM_HUNTERS && LocalPlayer():Alive() then
			local text = "..."
			local text2 = ""
			local font = "Hud.Number"
			local color = Color(255,255,60)
			
			local x = ScrW() - 280
			local y = ScrH() - 200
			local width = 245
			local height = 55
			
			draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
			draw.SimpleText( "FORCE", "Hud.Name", x+10, y+5, Color(255,255,60) )
			draw.SimpleText( "TAUNT", "Hud.Name", x+10, y+20, Color(255,255,60) )
			draw.SimpleText( "Hold R", "Hud.NameSmall", x+10, y+35, Color(255,255,60) )
			
			if CurTime() < (LocalPlayer():GetNWFloat("ForceTimeTaunted",0) + ResultTime) then
			
				font = "Hud.NumberSmall"
				if LocalPlayer():GetNWBool( "ForceTauntTarget", false ) then
					text = "Target"
					text2 = "Found"
					color = Color( 100,255,100 )
				else
					text = "Target"
					text2 = "Immune"
					color = Color( 255,100,100 )
				end
				
			end
			draw.SimpleText( text, font, x+240, y, color, TEXT_ALIGN_RIGHT )
			draw.SimpleText( text2, font, x+240, y+20, color, TEXT_ALIGN_RIGHT )
			
			if CurTime() <= LocalPlayer():GetNWFloat("ForceTauntTime",0) then
				local progressBar = (CurTime()-LocalPlayer():GetNWFloat("ForceTimeTaunted",0)) / TauntCooldown
				surface.SetDrawColor( Color( 255,255,0 ) )
				surface.DrawRect( x, y+height, width*(1-progressBar), 3 )
			end
		end
		
	end
	hook.Add( "HUDPaint", "Hunters.ForceTaunt.HUDPaint", HUDPaint )
	
	
	local function Think()
	
		if input.IsKeyDown( KEY_R ) then
			timeKeyDown = timeKeyDown or CurTime()+0.5 -- How long the key needs to be held down
			
			if CurTime() > timeKeyDown then
				timeKeyDown = nil
				net.Start( "ForcePropTaunt" )
				net.SendToServer()
			end
		elseif timeKeyDown then
			timeKeyDown = nil
			keyCoolDown = nil
		end
	
	end
	hook.Add( "Think", "Hunters.ForceTaunt.Think", Think )

end
