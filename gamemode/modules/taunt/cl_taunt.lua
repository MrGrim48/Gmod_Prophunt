
CreateClientConVar( "taunt_random", "0", true, true )
CreateClientConVar( "taunt_leaveopen", "0", true, true )
CreateClientConVar( "taunt_pitch", "100", true, true )

-- Add ConVar option in the menu
hook.Add( "Menu.Opened", "Player.HighlightPlayers", function()
	Menu.Options:AddNewConVar( "taunt_random", "F3 plays a random taunt instead of menu" )
end)

local Taunts = {}
local TauntsMenu = nil

-- Open taunt menu
net.Receive( "TauntOpenMenu", function()
	if !TauntsMenu then
		TauntsMenu = vgui.Create( "TauntMenu" )
		TauntsMenu:SetTitle( "Taunts Menu" )
		TauntsMenu:SetSize( 400, 500 )
		TauntsMenu:SetPos( 50, 100 )
		TauntsMenu:SetDraggable( true )
		TauntsMenu:SetDeleteOnClose( false )
		TauntsMenu.Taunts = Taunts
		TauntsMenu:LoadTaunts()
	else
		if TauntsMenu:IsVisible() then
			TauntsMenu:Hide()
		else
			TauntsMenu:Show()
		end
	end
	
	TauntsMenu:MakePopup()
end )

net.Receive( "TauntMenuDestroy", function() 
	print( "Destroy Menu" )
	if IsValid( TauntsMenu ) then TauntsMenu:Remove() end
	TauntsMenu = nil
end )


net.Receive( "SendTauntInfo", function()

	local Group = net.ReadString()
	local Team = net.ReadInt( 32 )
	local ID = net.ReadInt( 32 )
	local taunt = net.ReadString()
	local fileName = net.ReadString()
	
	if !Taunts[Group] then Taunts[Group] = {} end
	if !Taunts[Group][Team] then Taunts[Group][Team] = {} end
	if !Taunts[Group][Team][ID] then Taunts[Group][Team][ID] = {} end
	
	Taunts[Group][Team][ID].taunt = taunt
	Taunts[Group][Team][ID].duration = math.Round(SoundDuration(taunt),5)

end )