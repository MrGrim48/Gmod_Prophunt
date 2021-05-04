
net.Receive( "ps_playersethull", function( len, ply )

	local min = net.ReadVector()
	local max = net.ReadVector()
	
	LocalPlayer():SetHull( min, max )

end)

local function Initialize()
	function PS:ToggleMenu()
		if not PS.ShopMenu then
			PS.ShopMenu = vgui.Create('DPointShopMenu')
			PS.ShopMenu:SetVisible(false)
		end
		
		if PS.ShopMenu:IsVisible() then
			PS.ShopMenu:Remove()
			PS.ShopMenu = nil
			gui.EnableScreenClicker(false)
		else
			PS.ShopMenu:Show()
			gui.EnableScreenClicker(true)
		end
	end
end
hook.Add( "Initialize", "PSOverride.Initialize", Initialize )