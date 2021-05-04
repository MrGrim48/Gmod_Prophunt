/*
sv_disable_props.lua

Copyright© Nekom Glew, 2017

Don't know if this even works.
Idea is to freeze the listed props.

*/

local disableProps = {
	["models/props_c17/shelfunit01a.mdl"] = true,
	["models/props_interiors/furniture_shelf01a.mdl"] = true,
	["models/props_interiors/vendingmachinesoda01a.mdl"] = true,
	["models/props_wasteland/kitchen_fridge001a.mdl"] = true,
	["models/props_wasteland/laundry_dryer001.mdl"] = true,
	["models/props_wasteland/laundry_dryer002.mdl"] = true,
}


hook.Add( "InitPostEntity", "DisableProps.InitPostEntity", function()

	for _, ent in pairs( ents.GetAll() ) do
		if disableProps[ent:GetModel()] then
			local physObj = ent:GetPhysicsObject()
			if physObj then
				physObj:EnableMotion( false )
			end
		end
	end

end )