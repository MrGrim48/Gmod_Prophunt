/*
cl_vgui_header.lua

Copyright© Nekom Glew, 2017

*/

local PANEL = {}

function PANEL:Init()

	if Menu.LogoURL then
		local logo = vgui.Create("DHTML", self)
		logo:DockMargin(8, 8, 8, 0)
		logo:SetSize( Menu.LogoWidth, Menu.LogoHeight )
		logo:SetHTML([[
			<style>
				img {
					position: absolute;
					top: 50%;
					left: 50%;
					max-width: 100%;
					-webkit-transform: translate(-50%, -50%);
				}
			</style>
			<img src="]] .. Menu.LogoURL .. [[">
		]])

		local _logo = vgui.Create("EditablePanel", logo) -- Avoid weird glitch by disabling clicking on the logo
		_logo:Dock(FILL)
	end

end

--[[------------------------------------------------
	Name: Paint()
	Desc: Paint the header
--]]------------------------------------------------
function PANEL:Paint( w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color(55,55,55) )
	
	draw.SimpleText("Total players : "..#player.GetAll().." / "..game.MaxPlayers(), "Menu.Header", w-10, 55, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
	draw.SimpleText("Map : "..game.GetMap(), "Menu.Header", w-10, 75, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

end


vgui.Register( "DMHeader", PANEL, "DPanel" )