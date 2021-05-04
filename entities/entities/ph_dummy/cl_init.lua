
-- Include needed files.
include("shared.lua")


-- Draw the model.
function ENT:Draw()

	self.Entity:DrawModel()
	
end 

net.Receive( "SendEffect.Balloon", function()
	
	local ent = net.ReadEntity()
	if IsValid( ent ) then
		local effectdata = EffectData()
		effectdata:SetOrigin( ent:WorldSpaceCenter() )
		util.Effect( "balloon_pop", effectdata )
	end

end)