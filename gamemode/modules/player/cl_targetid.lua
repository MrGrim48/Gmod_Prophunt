
-- Modified of the original to allow prop players showing their name when looking at their prop
function GM:HUDDrawTargetID()
	
	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if ( !trace.Hit ) then return end
	if ( !trace.HitNonWorld ) then return end
	
	local text = "ERROR"
	local font = "TargetID"
	
	if ( trace.Entity:IsPlayer() && trace.Entity:Team() == TEAM_HUNTERS	) then
		text = trace.Entity:Nick()
	elseif ( trace.Entity:GetClass() == "ph_prop" && IsValid(trace.Entity:GetOwner()) && trace.Entity:GetOwner() != LocalPlayer() && LocalPlayer():Team() != TEAM_HUNTERS ) then
		text = trace.Entity:GetOwner():Nick()
	else
		return
	end
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	
	local MouseX, MouseY = gui.MousePos()
	
	if ( MouseX == 0 && MouseY == 0 ) then
	
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	
	end
	
	local x = MouseX
	local y = MouseY
	
	x = x - w / 2
	y = y + 30
	
	-- The fonts internal drop shadow looks lousy with AA on
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
	y = y + h + 5
	
	local text = math.ceil(trace.Entity:Health()) .. "%"
	if trace.Entity:GetClass() == "ph_prop" then text = trace.Entity:GetOwner():Health() .. "%" end
	local font = "TargetIDSmall"
	
	surface.SetFont( font )
	local w, h = surface.GetTextSize( text )
	local x = MouseX - w / 2
	
	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, self:GetTeamColor( trace.Entity ) )
	
end