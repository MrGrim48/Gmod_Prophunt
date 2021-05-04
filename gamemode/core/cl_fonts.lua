--[[
cl_fonts.lua

--]]

Fonts = {}
 
-- Creating font
function surface.CreateLegacyFont(font, size, weight, antialias, additive, name, shadow, outline, blursize)
	surface.CreateFont(name, {font = font, size = size, weight = weight, antialias = antialias, additive = additive, shadow = shadow, outline = outline, blursize = blursize})
end


-- Fonts!
surface.CreateLegacyFont( "Trebuchet MS", 69, 700, true, false, "FRETTA_HUGE" )
surface.CreateLegacyFont( "Trebuchet MS", 69, 700, true, false, "FRETTA_HUGE_SHADOW", true )
surface.CreateLegacyFont( "Trebuchet MS", 40, 700, true, false, "FRETTA_LARGE" )
surface.CreateLegacyFont( "Trebuchet MS", 40, 700, true, false, "FRETTA_LARGE_SHADOW", true )
surface.CreateLegacyFont( "Trebuchet MS", 19, 700, true, false, "FRETTA_MEDIUM" )
surface.CreateLegacyFont( "Trebuchet MS", 19, 700, true, false, "FRETTA_MEDIUM_SHADOW", true )
surface.CreateLegacyFont( "Trebuchet MS", 16, 700, true, false, "FRETTA_SMALL" )
surface.CreateLegacyFont( "Trebuchet MS", ScreenScale( 10 ), 700, true, false, "FRETTA_NOTIFY", true )

-- Called immediately after starting the gamemode.
function Fonts.Initialize()

	surface.CreateFont("ph_arial", { 
		font = "Arial",
		size = 14, 
		weight = 1200, 
		antialias = true,
		shadow = false
	})
	
	surface.CreateFont( "Hud.Name", {
		font = "Trebuchet",
		size = 16,
		weight = 600
	})
	
	surface.CreateFont( "Hud.NameSmall", {
		font = "Trebuchet",
		size = 14,
		weight = 100
	})
	
	surface.CreateFont( "Hud.Number", {
		font = "Trebuchet MS",
		size = 52,
		weight = 100
	})
	
	surface.CreateFont( "Hud.NumberSmall", {
		font = "Trebuchet MS",
		size = 26,
		weight = 100
	})
	
end
hook.Add("Initialize", "Fonts.Initialize", Fonts.Initialize)