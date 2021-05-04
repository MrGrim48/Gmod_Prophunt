/*
cl_vgui_options.lua

Copyright© Nekom Glew, 2017

*/

local PANEL = {}

PANEL.NumOptions = 0

function PANEL:Init()

end

function PANEL:AddNewConVar( convarName, desc )

	local newConVar = vgui.Create( "DCheckBoxLabel", self )
	newConVar:SetPos( 10, (25*self.NumOptions)+20 )
	newConVar:SetTextColor( Color( 50,50,50 ) )
	newConVar:SetText( desc )
	newConVar:SetConVar( convarName )
	newConVar:SetValue( GetConVar(convarName):GetInt() )
	newConVar:SizeToContents()
	
	self.NumOptions = self.NumOptions + 1

end

vgui.Register( "DMTabs.Options", PANEL, "DPanel" )