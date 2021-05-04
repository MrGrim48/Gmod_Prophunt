--[[
sh_menu.lua

MrGrimm

--]]

Menu = Menu or {} -- In case of in-game refresh

Menu.Width = 1536
Menu.Height = 837

Menu.LogoURL = "http://thecookiex.com/img/cxlogo.png"
Menu.LogoWidth = 400
Menu.LogoHeight = 100

Menu.Enum = {
	INFO = 1,
	CHANGETEAM = 1,
	SCOREBOARD = 2,
	OPTIONS = 3,
	ADMIN = 4
}

Menu.StaffPermission = {
	OWNER = "owner",
	SUPERADMIN = "superadmin",
	ADMIN = "admin",
	MODERATOR = "moderator",
	TRIALMODERATOR = "moderator"
}

if SERVER then
	resource.AddSingleFile( "resource/fonts/dolce_vita.tff" )
	resource.AddSingleFile( "resource/fonts/dolce_vita_light.tff" )
	resource.AddSingleFile( "resource/fonts/dolce_vita_heavy.tff" )
end

if CLIENT then

	-- Delay the close button on first time load
	Menu.FirstOpen = true

	surface.CreateFont( "Menu.Tabs", { font = "Dolce Vita Heavy", size = 24 } )
	surface.CreateFont( "Menu.Main", { font = "Dolce Vita", size = 24 } )
	surface.CreateFont( "Menu.Header", { font = "Dolce Vita Heavy", size = 14 } )
	surface.CreateFont( "Menu.ScoreBoard", { font = "Dolce Vita", size = 18 } )

	--[[------------------------------------------------
		Name: Open()
		Desc: This will make the menu visible if it exists.
			Else it will create the menu.
	--]]------------------------------------------------
	function Menu.Open( ply, tab )

		-- Open the menu at the specified tab or first tab by default.
		tab = tab or 1
		
		
		if !Menu.Panel then
			Menu.Create()
		end
		
		-- Set the active tab
		local sheet = Menu.Panel.Tabs.Sheets[tab]
		Menu.Panel.Tabs:SetActiveTab( sheet.Tab )

	end

	--[[------------------------------------------------
		Name: Create()
		Desc: This will create the menu with all it's components.
	--]]------------------------------------------------
	function Menu.Create()
		
		--if ScrW() < Menu.Width then Menu.Width = ScrW() end
		--if ScrH() < Menu.Height then Menu.Height = ScrH() end
		Menu.Width = ScrW()*0.8
		Menu.Height = ScrH()*0.9
		
		local panel = vgui.Create( "DPanel" )
		panel:SetSize( Menu.Width, Menu.Height )
		panel:Center()
		Menu.Panel = panel
		
		local header = vgui.Create( "DMHeader", panel )
		header:SetSize( Menu.Width, 100 )
		
		local tabs = vgui.Create( "DMTabs", panel )
		tabs:SetSize( Menu.Width, Menu.Height - 100 )
		tabs:SetPos( 0, 100 )
		tabs:SetPadding( 0 )
		tabs.tabScroller:DockMargin( 0, 0, 0, 0 )
		tabs.tabScroller:SetOverlap( 0 )
		panel.Tabs = tabs -- Can later reference with Menu.Panel.Tabs
		
		function tabs:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(100,115,130) )
		end
		
		Menu.Info = vgui.Create( "DMTabs.Info", tabs )
		--Menu.ChangeTeams = vgui.Create( "DMTabs.ChangeTeam", tabs )
		Menu.ScoreBoard = vgui.Create( "DMTabs.ScoreBoard", tabs )
		Menu.Options = vgui.Create( "DMTabs.Options", tabs )
		
		tabs.Sheets = {}
		tabs.Sheets[Menu.Enum.INFO] = tabs:AddSheet( "F1: Info", Menu.Info )
		--tabs.Sheets[Menu.Enum.CHANGETEAM] = tabs:AddSheet( "F2: Change Team", Menu.ChangeTeams )
		tabs.Sheets[Menu.Enum.SCOREBOARD] = tabs:AddSheet( "ScoreBoard", Menu.ScoreBoard )
		tabs.Sheets[Menu.Enum.OPTIONS] = tabs:AddSheet( "Options", Menu.Options )
		net.Start( "AddAdminTab" ) -- ULX CheckGroup command doesn't seem to like being called client side.
		net.SendToServer()
		
		tabs:PaintTabs()
		
		local function CreateCloseButton()
			local closeButton = vgui.Create( "DButton", panel )
			closeButton:SetText( "X" )
			closeButton:SetSize( 40, 40 )
			closeButton:SetPos( Menu.Width-40, 0 )
			closeButton.DoClick = function()
				Menu.Close()
			end
			
			function closeButton:Paint( w, h )			
				surface.SetDrawColor(Color(130,60,60))
				surface.DrawRect(0, 0, w, h)
				
				if self:IsHovered() and self:IsDown() then
					surface.SetDrawColor(Color(0, 0, 0, 48))
					surface.DrawRect(0, 0, w, h)
				elseif self:IsHovered() then
					surface.SetDrawColor(Color(255, 255, 255, 24))
					surface.DrawRect(0, 0, w, h)
				end
				
				surface.SetFont( "Menu.Tabs" )
				local txtW, txtH = surface.GetTextSize( self:GetText() )
				surface.SetTextColor(Color(255,255,255))
				surface.SetTextPos(w / 2 - txtW / 2, h / 2 - txtH / 2)
				surface.DrawText( self:GetText() )
				
				return true
			end
		end
		
		if Menu.FirstOpen then
			Menu.FirstOpen = false
			timer.Simple( 2, CreateCloseButton )
		else
			CreateCloseButton()
		end
		
		hook.Call( "Menu.Opened" )

		panel:MakePopup()

	end
	
	function Menu.Close()
		
		if Menu.Panel then
			Menu.Panel:Remove()
			Menu.Panel = nil
			Menu.Width = 1536
			Menu.Height = 837
		end
		
	end
	
	-- Open stuff
	net.Receive( "MenuOpen", function()
		Menu.Open( self, net.ReadInt( 4 ) )
	end )
	hook.Add( "Initialize", "MenuMOTD", function()
		if ulx then ulx.showMotdMenu = Menu.Open end 
	end )
	
	-- ScoreBoard
	function GM:ScoreboardShow()
		Menu.Open( nil, Menu.Enum.SCOREBOARD )
	end
	
	function GM:ScoreboardHide()
		if Menu && Menu.Panel && Menu.Panel.Tabs:GetActiveTab() == Menu.Panel.Tabs.Sheets[Menu.Enum.SCOREBOARD].Tab then
			Menu.Close()
		end
	end
	
	
	net.Receive( "AddAdminTab", function( len, ply )
		if Menu && Menu.Panel && Menu.Panel.Tabs && Menu.Panel.Tabs.Sheets then
			Menu.Panel.Tabs.Sheets[Menu.Enum.ADMIN] = Menu.Panel.Tabs:AddSheet( "Admin", vgui.Create( "DMTabs.Admin", Menu.Panel.Tabs ) )
			Menu.Panel.Tabs:PaintTabs()
		end
	end )
	
else

	util.AddNetworkString( "MenuOpen" )
	util.AddNetworkString( "AddAdminTab" )
	
	net.Receive( "AddAdminTab", function( len, ply )
		if ply:CheckGroup( "moderator" ) then
			net.Start( "AddAdminTab" )
			net.Send( ply )
		end
	end )
	
	local ulx_showMotd
	local function MenuOpen( ply, tab )
		net.Start( "MenuOpen" )	
		net.WriteInt( tab or 1, 4 )
		net.Send( ply )
	end
	
	hook.Add( "PlayerInitialSpawn", "MenuOpen", function(ply)
		MenuOpen( ply )
	end )
	
	hook.Add( "PlayerSay", "MenuOpenMotd", function(ply, say)
		if say:lower():match("^[%.!/]motd") then
			MenuOpen( ply )
		end
	end )
	
	hook.Add( "PlayerSay", "MenuOpenTeam", function(ply, say)
		if say:lower():match("^[%.!/]team") then
			MenuOpen( ply, Menu.Enum.CHANGETEAM )
		end
	end )
	
	
	--[[------------------------------------------------
		Name: ShowHelp()
		Desc: Open the menu on the info tab
	--]]------------------------------------------------
	function GM:ShowHelp( ply )
		ply:ConCommand( "ulx motd" )
	end
	hook.Add( "PlayerSay", "Menu.OpenMOTD", function( ply, msg, teamChat )
		if msg == "!help" then ply:ConCommand( "ulx motd" ) end
	end )
	
	--[[---------------------------------------------------------
	   Name: ShowTeam()
	   Desc: Open the menu on the ChangeTeam tab
	-----------------------------------------------------------]]
	function GM:ShowTeam( ply )
		MenuOpen( ply, Menu.Enum.CHANGETEAM )
	end

end


