ITEM.Name = 'Double Jump'
ITEM.Price = 5000
ITEM.Model = 'models/items/battery.mdl'
ITEM.Bone = 'ValveBiped.Bip01_Pelvis'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.5, 0)
	pos = pos - (ang:Right() * 4) - (ang:Forward() * 7) - (ang:Up() * 6)
	ang:RotateAroundAxis( ang:Forward(), 90 )
	--ang:RotateAroundAxis( ang:Right(), 45 )
	ang:RotateAroundAxis( ang:Up(), -125 )
	
	return model, pos, ang
end

function ITEM:KeyPress(ply, modifications, pl, k)
	if ply != pl then return end

	if not pl or not pl:IsValid() or k~=2 then
		return
	end
		
	if not pl.Jumps or pl:IsOnGround() then
		pl.Jumps=0
	end
	
	if pl.Jumps==2 then return end
	
	pl.Jumps = pl.Jumps + 1
	if pl.Jumps==2 then
		local ang = pl:GetAngles()
		local forward, right = ang:Forward(), ang:Right()
		
		local vel = -1 * pl:GetVelocity() -- Nullify current velocity
		vel = vel + Vector(0, 0, 200) -- Add vertical force
		
		local spd = pl:GetMaxSpeed()
		
		if pl:KeyDown(IN_FORWARD) then
			vel = vel + forward * spd
		elseif pl:KeyDown(IN_BACK) then
			vel = vel - forward * spd
		end
		
		if ConVarExists("map_mirror_forced") && GetConVar("map_mirror_forced"):GetInt() == 1 then
			right = -right
		end
		
		if pl:KeyDown(IN_MOVERIGHT) then
			vel = vel + right * spd
		elseif pl:KeyDown(IN_MOVELEFT) then
			vel = vel - right * spd
		end
		
		pl:SetVelocity(vel)
	end
end
