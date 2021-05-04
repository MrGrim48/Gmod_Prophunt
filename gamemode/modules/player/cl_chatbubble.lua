
ChatBubble = {}

ChatBubble.iconTalk = Material("chatbubbles/talking.png")
ChatBubble.iconType = Material("chatbubbles/typing.png")


hook.Add( "PostDrawTranslucentRenderables", "ChatBubble", function()

	for _,ply in pairs( player.GetAll() ) do
		if IsValid(ply) && ply:Alive() then
			if LocalPlayer() == ply then continue end
			if LocalPlayer():Team() == TEAM_HUNTERS && ply:Team() == TEAM_PROPS then continue end
			if ply:Team() == TEAM_SPECTATOR then continue end
			
			if ply:IsSpeaking() then
				ChatBubble.RenderBubble( ply, ChatBubble.iconTalk )
			elseif ply:GetNWBool( "Typing", false ) || ply:IsTyping() then
				ChatBubble.RenderBubble( ply, ChatBubble.iconType )
			end
			
		end
	end
	
end )


function ChatBubble.RenderBubble( ply, icon )

	local min, max = ply:GetHull()
	local offset = Vector( 0, 0, max.z )
	local ang = LocalPlayer():EyeAngles()
	local pos = ply:GetPos() + offset + ang:Up()
	local color = Color( 255, 255, 255, 255 )
	
	if ply:Team() == TEAM_PROPS then
		offset = Vector(0,0,ply:GetNWInt("PropHeight",85)+15)
		pos = ply:GetPos() + offset + ang:Up()
		color = Color( 255, 255, 255, 255 )
	end
 
	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )
 
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
		surface.SetDrawColor( color )
		surface.SetMaterial( icon )
		surface.DrawTexturedRect( -80, 0, 50, 50 )
	cam.End3D2D()

end