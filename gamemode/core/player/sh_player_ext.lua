--[[
sh_player_ext.lua

MrGrimm

--]]

local Player = FindMetaTable("Player")
local PointShopModels = {
	["Player Models"] = true,
	["Staff Player Models"] = true
}

--[[------------------------------------------------
	Name: Player:Blind()
	Desc: Blinds the player by setting the view into the void.
--]]------------------------------------------------
function Player:Blind(bool)
	
	if !IsValid( self ) then return end
	
	-- Set the networked bool
	self:SetNWBool( "Blind", bool )
	
end
-- Cover the screen to prevent weird effects that can occur when blinded
hook.Add( "PreDrawHUD", "PH.Blind.PreDrawHUD", function()
	if LocalPlayer():GetNWBool("Blind",false) then
		draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0,0,0 ) )
	end
end )

--[[------------------------------------------------
	Name: Player:IsObserver()
	Desc: Returnd whether or not the player is a spectator.
--]]------------------------------------------------
function Player:IsObserver()

	return ( self:GetObserverMode() > OBS_MODE_NONE )
	
end

--[[------------------------------------------------
	Name: Player:RemoveProp()
	Desc: Removes the players prop if it exists.
--]]------------------------------------------------
function Player:RemoveProp()

	-- If we are executing from client side or the player/player's prop isn't valid, terminate.
	if CLIENT || !IsValid(self) || !self.ph_prop || !IsValid(self.ph_prop) then
		return
	end
	
	-- Set Player position to prevent ragdolls spawning in the ground
	self:SetPos( self.ph_prop:WorldSpaceCenter() )
	
	-- Set the players model to get ready to create a ragdoll
	self:SetModel( "models/player/Kleiner.mdl" )
	
	-- Set the players model to the PointShop one if it is equipped
	if self.PS_Items then
		for item_id, item in pairs(self.PS_Items) do
			local ITEM = PS.Items[item_id]
			if item.Equipped && PointShopModels[ITEM.Category] then
				self:SetModel( ITEM.Model )
			end
		end
	end
	
	-- Create the ragdoll of the model that's set
	self:CreateRagdoll()
	self.PlayerRagdoll = self:GetRagdollEntity()
	if !timer.Exists( self:SteamID64() ) then
		timer.Create( self:SteamID64(), 10, 1, function()
			
			if IsValid(self.PlayerRagdoll) then
				local dissolver = ents.Create( "env_entity_dissolver" )
				dissolver:SetPos( self.PlayerRagdoll:LocalToWorld(self.PlayerRagdoll:OBBCenter()) )
				dissolver:SetKeyValue( "dissolvetype", 0 )
				dissolver:Spawn()
				dissolver:Activate()
				
				local name = "Dissolving_"..self:SteamID64()
				self.PlayerRagdoll:SetName( name )
				dissolver:Fire( "Dissolve", name, 0 )
				dissolver:Fire( "Kill", self.PlayerRagdoll, 0.10 )
			end
			
		end )
	end
	
	-- Remove the player's prop and set the variable to nil.
	self:SetNWEntity( "prop", nil )
	self.ph_prop:Remove()
	self.ph_prop = nil
		
end