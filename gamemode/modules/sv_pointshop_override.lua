/*
sv_pointshop_override.lua

Copyright© Nekom Glew, 2017

*/

local Player = FindMetaTable('Player')

local function Initialize()
	
	
	--[[------------------------------------------------
		Desc: Prevent items equiping on props when they spawn.
	--]]------------------------------------------------
	function Player:PS_PlayerSpawn()
		if not self:PS_CanPerformAction() then return end

		-- TTT ( and others ) Fix
		if TEAM_SPECTATOR != nil and self:Team() == TEAM_SPECTATOR then return end
		if TEAM_SPEC != nil and self:Team() == TEAM_SPEC then return end

		-- Murder Spectator Fix (they don't specify the above enums when making teams)
		-- https://github.com/mechanicalmind/murder/blob/master/gamemode/sv_spectate.lua#L15
		if self.Spectating then return end
		if !self:Alive() then return end
		if self:Team() != TEAM_HUNTERS then return end -- Prevent excecution on props
		
		timer.Simple(1, function()
			if !IsValid(self) then return end
			for item_id, item in pairs(self.PS_Items) do
				local ITEM = PS.Items[item_id]
				if item.Equipped then
					ITEM:OnEquip(self, item.Modifiers)
				end
			end
		end)
		
	end
	
	--[[------------------------------------------------
		Desc: Removes items after custom death event
	--]]------------------------------------------------
	hook.Add( "PostPlayerDeath", "PS.OverridePlayerDeath", function( ply )
		ply:PS_PlayerDeath()
	end )
	
	
	--[[------------------------------------------------
		Desc: Override to allow players to buy and equip while dead.
	--]]------------------------------------------------
	function Player:PS_CanPerformAction(itemname)
		local allowed = true
		local itemexcept = false
		if itemname then itemexcept = PS.Items[itemname].Except end

		if (self.IsSpec and self:IsSpec()) and not itemexcept then allowed = false end
		--if not self:Alive() and not itemexcept then allowed = false end


		if not allowed then
			self:PS_Notify('You\'re not allowed to do that at the moment!')
		end

		return allowed
	end
	
	
	--[[------------------------------------------------
		Desc: Override to prevent calling items "Equip" function as a spectator or dead.
	--]]------------------------------------------------
	function Player:PS_EquipItem(item_id)
		if not PS.Items[item_id] then print( "Not valid" ) return false end
		if not self:PS_HasItem(item_id) then print( "Not has item" ) return false end
		if not self:PS_CanPerformAction(item_id) then print( "Cannot perform" ) return false end

		local ITEM = PS.Items[item_id]

		if type(ITEM.CanPlayerEquip) == 'function' then
			allowed, message = ITEM:CanPlayerEquip(self)
		elseif type(ITEM.CanPlayerEquip) == 'boolean' then
			allowed = ITEM.CanPlayerEquip
		end

		if not allowed then
			self:PS_Notify(message or 'You\'re not allowed to equip this item!')
			return false
		end

		local cat_name = ITEM.Category
		local CATEGORY = PS:FindCategoryByName(cat_name)

		if CATEGORY and CATEGORY.AllowedEquipped > -1 then
			if self:PS_NumItemsEquippedFromCategory(cat_name) + 1 > CATEGORY.AllowedEquipped then
				self:PS_Notify('Only ' .. CATEGORY.AllowedEquipped .. ' item' .. (CATEGORY.AllowedEquipped == 1 and '' or 's') .. ' can be equipped from this category!')
				return false
			end
		end

		if PS.Items[item_id].Slot then
			for id, item in pairs(self.PS_Items) do
				if item_id != id and PS.Items[id].Slot and PS.Items[id].Slot == PS.Items[item_id].Slot and self.PS_Items[id].Equipped then
					self:PS_HolsterItem(id)
				end
			end
		end


		if CATEGORY.SharedCategories then
			local ConCatCats = CATEGORY.Name
			for p, c in pairs( CATEGORY.SharedCategories ) do
				if p ~= #CATEGORY.SharedCategories then
					ConCatCats = ConCatCats .. ', ' .. c
				else
					if #CATEGORY.SharedCategories ~= 1 then
						ConCatCats = ConCatCats .. ', and ' .. c
					else
						ConCatCats = ConCatCats .. ' and ' .. c
					end
				end
			end
			local NumEquipped = self.PS_NumItemsEquippedFromCategory
			for id, item in pairs(self.PS_Items) do
				if not self:PS_HasItemEquipped(id) then continue end
				local CatName = PS.Items[id].Category
				local Cat = PS:FindCategoryByName( CatName )
				if not Cat.SharedCategories then continue end
				for _, SharedCategory in pairs( Cat.SharedCategories ) do
					if SharedCategory == CATEGORY.Name then
						if Cat.AllowedEquipped > -1 and CATEGORY.AllowedEquipped > -1 then
							if NumEquipped(self,CatName) + NumEquipped(self,CATEGORY.Name) + 1 > Cat.AllowedEquipped then
								self:PS_Notify('Only ' .. Cat.AllowedEquipped .. ' item'.. (Cat.AllowedEquipped == 1 and '' or 's') ..' can be equipped over ' .. ConCatCats .. '!')
								return false
							end
						end
					end
				end
			end
		end

		self.PS_Items[item_id].Equipped = true

		-- Copied the whole function just to add this. :/
		if self:Team() == TEAM_HUNTERS && self:Alive() then
			ITEM:OnEquip(self, self.PS_Items[item_id].Modifiers)
		end

		self:PS_Notify('Equipped ', ITEM.Name, '.')
		
		hook.Call( "PS_ItemUpdated", nil, self, item_id, PS_ITEM_EQUIP )

		PS:SavePlayerItem(self, item_id, self.PS_Items[item_id])

		self:PS_SendItems()
	end
	
	--[[------------------------------------------------
		Desc: Override to use ulx CheckGroup function
	--]]------------------------------------------------
	function Player:PS_BuyItem(item_id)
		local ITEM = PS.Items[item_id]
		if not ITEM then return false end

		local points = PS.Config.CalculateBuyPrice(self, ITEM)

		if not self:PS_HasPoints(points) then return false end
		if not self:PS_CanPerformAction(item_id) then return end

		if ITEM.AdminOnly and not self:IsAdmin() then
			self:PS_Notify('This item is Admin only!')
			return false
		end

		local cat_name = ITEM.Category
		local CATEGORY = PS:FindCategoryByName(cat_name)

		-- Modified to use ulx CheckGroup function
		-- Too lazy to edit all the items to just have one usergroup
		-- so I am just looping through them
		if  (CATEGORY.AllowedUserGroups and #CATEGORY.AllowedUserGroups > 0) ||
			(ITEM.AllowedUserGroups and #ITEM.AllowedUserGroups > 0) then
			--if not table.HasValue(CATEGORY.AllowedUserGroups, self:PS_GetUsergroup()) then
			local allowedToBuy = false
			for _,group in pairs( CATEGORY.AllowedUserGroups ) do
				if self:CheckGroup( group ) then
					allowedToBuy = true
					break
				end
			end
			for _,group in pairs( ITEM.AllowedUserGroups ) do
				if self:CheckGroup( group ) then
					allowedToBuy = true
					break
				end
			end
			if !allowedToBuy then
				self:PS_Notify('You\'re not in the right group to buy this item!')
				return false
			end
		end

		if CATEGORY.CanPlayerSee then
			if not CATEGORY:CanPlayerSee(self) then
				self:PS_Notify('You\'re not allowed to buy this item!')
				return false
			end
		end

		if ITEM.CanPlayerBuy then -- should exist but we'll check anyway
			local allowed, message
			if ( type(ITEM.CanPlayerBuy) == "function" ) then
				allowed, message = ITEM:CanPlayerBuy(self)
			elseif ( type(ITEM.CanPlayerBuy) == "boolean" ) then
				allowed = ITEM.CanPlayerBuy
			end

			if not allowed then
				self:PS_Notify(message or 'You\'re not allowed to buy this item!')
				return false
			end
		end

		self:PS_TakePoints(points)

		self:PS_Notify('Bought ', ITEM.Name, ' for ', points, ' ', PS.Config.PointsName)

		ITEM:OnBuy(self)
		
		hook.Call( "PS_ItemPurchased", nil, self, item_id )

		if ITEM.SingleUse then
			self:PS_Notify('Single use item. You\'ll have to buy this item again next time!')
			return
		end

		self:PS_GiveItem(item_id)
		self:PS_EquipItem(item_id)
	end

end

hook.Add( "Initialize", "Pointshop.Override.PlayerSpawn", Initialize )

--[[------------------------------------------------
	Name: PlayerSpawn()
	Desc: After a player spawns; Checks if the player has a model
		equiped and changes the view height.
--]]------------------------------------------------
hook.Add( "PlayerSpawn", "PSO.PlayerSpawn", function( ply )
	if PS and ply.PS_Items then
		for item_id, item in pairs(ply.PS_Items) do
			local ITEM = PS.Items[item_id]
			if ITEM.Category == "Player Models" or ITEM.Category == "Staff Player Models" then
				timer.Simple(1, function()
					PlayerViewToModelHeight( ply, item_id )
				end)
			end	
		end
	end
end)

util.AddNetworkString( "ps_playersethull" )
-- When called; Will set the players viewpoint and collision box to the player model bounds
--[[------------------------------------------------
	Name: PlayerViewToModelHeight()
	Desc: Sets the players viewpoint and collision box to he player model bounds.
--]]------------------------------------------------
function PlayerViewToModelHeight( ... )

	local args = { ... }
	local ply = args[1]
	if !IsValid(ply) or ply:Team() != TEAM_HUNTERS then return end
	local ITEM = PS.Items[args[2]]
	local item = ply.PS_Items[args[2]]
	
	timer.Simple(2, function()
		if !IsValid(ply) then return end --Who knows what could happen in 2 seconds
		if (ITEM.Category == "Player Models" or ITEM.Category == "Staff Player Models") and item.Equipped then
			local min, max = ply:GetModelBounds()
			max.x = 16--math.min( max.x, 16 )
			max.y = 16--math.min( max.y, 16 )
			max.z = math.min( max.z, 72 )
			min.x = -16--math.max( min.x, -16 )
			min.y = -16--math.max( min.y, -16 )
			min.z = 0
			-- Left X and Y to the default 16 because it for some reason offsets the
			-- players position when they duck. Even into walls/props.
			
			ply:SetHull( min, max )
			ply:SetCollisionBounds( min, max )
			
			net.Start( "ps_playersethull" )
			net.WriteVector( min )
			net.WriteVector( max )
			net.Send( ply )
			
			if ITEM.EyeHeight then
				ply:SetViewOffset( Vector(0,0,ITEM.EyeHeight) )
				ply:SetViewOffsetDucked( Vector(0,0,ITEM.EyeHeight*0.5) )
			else
				ply:SetViewOffset( Vector(0,0,max.z*0.9) )
				ply:SetViewOffsetDucked( Vector(max.x-16,max.y-16,max.z*0.55) )
			end
		end
	end)
	
end
hook.Add( "PS_ItemUpdated", "PSO.PS_ItemUpdated", PlayerViewToModelHeight )
