--[[
cl_vgui_admin.lua

Copyright© Nekom Glew, 2017

--]]

local PANEL = {}

local ButtonList = {
	BannedProps = { group = "admin", func = function() RunConsoleCommand("banned_props") end },
}

function PANEL:Init()
	
	local butX = 10
	local butY = 10
	local butH = 30
	local butW = 200
	
	local i = 0
	for Name, Table in pairs( ButtonList ) do
	
		if LocalPlayer():CheckGroup( Table.group ) then
			local button = vgui.Create( "DButton", self )
			button:SetSize( butW, butH )
			button:SetPos( butX, butY + (butH * i) + (5 * i) )
			button:SetText( Name )
			function button:DoClick()
				Table.func()
			end
			
			i = i + 1
		end
	
	end

end

vgui.Register( "DMTabs.Admin", PANEL, "DPanel" )