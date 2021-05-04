
if SERVER then

	resource.AddFile("resource/fonts/dolce_vita.ttf")
	resource.AddFile("resource/fonts/dolce_vita_light.ttf")
	resource.AddFile("resource/fonts/dolce_vita_heavy.ttf")

else

	local function InitPostEntity()

		surface.CreateFont("NametagFont", {
			font = "Dolce Vita",
			size = 28
		});	

	end
	hook.Add("InitPostEntity", "Nametag.InitPostEntity", InitPostEntity);


	local function DrawName( ply )

		local min, max = ply:GetModelBounds()
		local offset = Vector( 0, 0, 20 )
		local ang = LocalPlayer():EyeAngles()
		local pos = Vector( 0, 0, max.z ) + ply:GetPos() + offset + ang:Up()
		local color = Color( 100, 100, 200, 255 )
		
		if ply:Team() == TEAM_PROPS then
			offset = Vector(0,0,ply:GetNWInt("PropHeight",95) + 20)
			pos = ply:GetPos() + offset + ang:Up()
			color = Color( 200, 100, 100, 255 )
		end
	 
		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
	 
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
			draw.SimpleTextOutlined( ply:GetName(), "NametagFont", 2, 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		cam.End3D2D()
		
		pos = pos - Vector(0,0,8)
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.25 )
			draw.SimpleTextOutlined( math.ceil(ply:Health()).."%", "NametagFont", 2, 2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255) )
		cam.End3D2D()
		
	end


	local function DrawNameTag( bDrawingDepth, bDrawingSkybox )

		if !bDrawingSkybox then
			
			if LocalPlayer():Team() == TEAM_SPECTATOR then
				cam.IgnoreZ( true )
			end
			
			for _, hunter in pairs( team.GetPlayers( TEAM_HUNTERS ) ) do
				if IsValid(hunter) && hunter:Alive() && hunter != LocalPlayer() then
					DrawName( hunter )
				end
			end
			
			for _, prop in pairs( team.GetPlayers( TEAM_PROPS ) ) do
				if IsValid(prop) && prop:Alive() && prop != LocalPlayer() then
					if LocalPlayer():Team() != TEAM_HUNTERS then
						DrawName( prop )
					end
				end
			end
			
			if LocalPlayer():Team() == TEAM_SPECTATOR then
				cam.IgnoreZ( false )
			end
		end

	end
	hook.Add( "PostDrawTranslucentRenderables", "Nametag.DrawNameTag", DrawNameTag )
	
end