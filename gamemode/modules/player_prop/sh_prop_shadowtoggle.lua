
if SERVER then
	-- Reset the variable to enable shadows.
	-- Prop players spawn with a new prop with shadows on anyway.
	local function PlayerSpawn( ply )

		timer.Simple( 0.2, function()
			ply:SetNWBool( "ShadowToggle", true )
		end )
		
	end
	hook.Add( "PlayerSpawn", "ShadowToggle.PlayerSpawn", PlayerSpawn )

	-- Toggle shadow when key combinations are pressed.
	local function PlayerKeyPress( ply, key )

		if ply:Team() == TEAM_PROPS && IsValid(ply.ph_prop) && !hook.Run("PropShadowDisabled") then
			if ply:KeyDown(IN_SPEED) && key == IN_RELOAD then
				ply:SetNWBool( "ShadowToggle", !ply:GetNWBool("ShadowToggle", true) )
				ply.ph_prop:DrawShadow( ply:GetNWBool( "ShadowToggle", true ) )
			end
		end

	end
	hook.Add( "KeyPress", "ShadowToggle.KeyPress", PlayerKeyPress )

else

	local function HUDPaint()
		if LocalPlayer():Team() == TEAM_PROPS && LocalPlayer():Alive() && !hook.Run("PropShadowDisabled") then			
			local x = ScrW() - 220
			local y = ScrH() - 140
			local width = 190
			local height = 55
			
			draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
			draw.SimpleText( "SHADOW", "Hud.Name", x+15, y+5, Color(255,255,60) )
			draw.SimpleText( "Shift+R", "Hud.NameSmall", x+15, y+35, Color(255,255,60) )
			
			local text = ""
			local color = Color(255,255,60)
			if LocalPlayer():GetNWBool( "ShadowToggle", true ) then
				text = "On"
				color = Color( 100,255,100 )
			else
				text = "Off"
				color = Color( 255,100,100 )
			end
			draw.SimpleText( text, "Hud.Number", x+170, y, color, TEXT_ALIGN_RIGHT )
		end
	end
	hook.Add( "HUDPaint", "Props.ShadowToggle.HUDPaint", HUDPaint )

end