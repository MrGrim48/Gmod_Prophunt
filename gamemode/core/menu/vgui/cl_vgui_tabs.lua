/*
cl_vgui_tabs.lua

Copyright© Nekom Glew, 2017

*/

local TabHeight = 35

local PANEL = {}

function PANEL:Paint( w, h )
end

--[[------------------------------------------------
	Name: PaintTabs()
	Desc: This will setup custom paint for each tab
--]]------------------------------------------------
function PANEL:PaintTabs()

	for _, item in pairs( self.Items ) do
		if !item.Tab then continue end
		
		item.Tab:SetContentAlignment( 8 )
		item.Tab:SetTextInset( 0, 0 )
		item.Tab:SetFont( "Menu.Tabs" )
		
		item.Tab.GetTabHeight = function() return TabHeight end
		item.Tab.Paint = function( self, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(100,115,130) )
			if item.Tab:IsDown() || item.Tab:IsActive() then
				draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
			end
		end
		
		item.Panel:SetPos( self:GetPadding(), self:GetPadding() + item.Tab:GetTabHeight() )
	end

end

vgui.Register( "DMTabs", PANEL, "DPropertySheet" )