--
-- ph_prop/shared.lua
-- Prop Hunt
--	
-- Created by Andrew Theis on 2013-03-09.
-- Copyright (c) 2010-2013 Andrew Theis. All rights reserved.
--
 

-- Entity information.
ENT.Type = "anim"
ENT.Base = "base_anim"


-- Called when the entity initializes.
function ENT:Initialize()

	if SERVER then
		self:SetModel("models/kleiner_prop/kleiner.mdl")
	else
		if IsValid( self.Owner ) then
			self.Owner.ph_prop = self
		end
	end
	
end 