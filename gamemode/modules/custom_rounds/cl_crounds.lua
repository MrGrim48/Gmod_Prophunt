--[[
cl_crounds.lua

Copyright© Nekom Glew, 2017

--]]

local HangTime = 3
local TransitionTime = 1

hook.Add( "Initialize", "CRounds.Initialize", function()
	surface.CreateFont( "CRounds.Name", {
		font = "Trebuchet",
		size = 16,
		weight = 600
	})
	
	surface.CreateFont( "CRounds.NameSmall", {
		font = "Trebuchet",
		size = 14,
		weight = 100
	})
	
	surface.CreateFont( "CRounds.NameZoomed", {
		font = "Trebuchet",
		size = 32,
		weight = 600
	})
	
	surface.CreateFont( "CRounds.NameSmallZoomed", {
		font = "Trebuchet",
		size = 28,
		weight = 100
	})
end )

local function HUDPaint()

	if CRounds and CRounds.ActiveRound and CRounds.ActiveRound.TimeStart then	
		local width = 260
		local height = 50
		local x = (ScrW()*0.5) - (width*0.5)
		local y = ScrH() - 140
		local zoomed = false
		
		local mat
		if CurTime() < CRounds.ActiveRound.TimeStart+HangTime+TransitionTime then
			width = width*2
			height = height*2
			x = (ScrW()*0.5) - (width*0.5)
			y = y - 100 --(ScrH()*0.5) -- (height*0.5)
			zoomed = true
			if CurTime() > CRounds.ActiveRound.TimeStart+HangTime then 
				-- Zoom stuff or something
			end
		end
		
		draw.RoundedBox( 0, x, y, width, height, Color( 50,50,50,200 ) )
		draw.RoundedBox( 0, x, y+height, width, 3, Color( 255,255,0 ) )
		
		draw.SimpleText( "Special Round", (zoomed and "CRounds.NameZoomed") or "CRounds.Name", x+(width*0.5), y+5, Color(255,255,60), TEXT_ALIGN_CENTER )
		draw.SimpleText( CRounds.ActiveRound.Name, (zoomed and "CRounds.NameSmallZoomed") or "CRounds.NameSmall", x+(width*0.5), y+30 + ((zoomed and 30 or 0)), Color(255,255,255), TEXT_ALIGN_CENTER )
		
		--[[local text = "Special Round"
		surface.SetFont( "Hud.Name" )
		local w,h = surface.GetTextSize( text )
		surface.SetTextColor( Color(255,255,60) )
		surface.SetTextPos( x+(width*0.5)-(w*0.5), y+5 )
		surface.DrawText( text )
		
		text = CRounds.ActiveRound.Name
		surface.SetFont( "Hud.NameSmall" )
		w,h = surface.GetTextSize( text )
		surface.SetTextColor( Color(255,255,255) )
		surface.SetTextPos( x+(width*0.5)-(w*0.5), y+30 )
		surface.DrawText( text )]]
		
	end

end
hook.Add( "HUDPaint", "CRounds.HUDPaint", HUDPaint )