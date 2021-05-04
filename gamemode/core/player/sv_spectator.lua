--[[
sv_spectator.lua

MrGrimm

--]]

local Player = FindMetaTable( "Player" )

local CanOnlySpectateOwnTeam = true; // you can only spectate players on your own team

-- Entities we can spectate, players being the obvious default choice.
local ValidSpectatorEntities = { 
	player = true, 
	ph_prop = true, 
}	

--[[---------------------------------------------------------
   Name: Player:GetValidSpectatorModes()
   Desc: Gets a table of the allowed spectator modes (OBS_MODE_INEYE, etc)
--]]---------------------------------------------------------
function Player:GetValidSpectatorModes()
	
	local modes = { OBS_MODE_CHASE }
	if self:Team() != TEAM_HUNTERS then
		table.Add( modes, {OBS_MODE_ROAMING} )
	end
	
	return modes

end

--[[--------------------------------------------------------
   Name: Player:IsValidSpectator()
   Desc: Is our player spectating - and valid?
--]]--------------------------------------------------------
function Player:IsValidSpectator()
	
	return self:Team() == TEAM_SPECTATOR || self:IsObserver()

end

--[[--------------------------------------------------------
   Name: Player:IsValidSpectatorTarget( Entity ent )
   Desc: Checks to make sure a spectated entity is valid.
		 You can change CanOnlySpectateOwnTeam if you want to
		 allow players to spectate the other team.
--]]--------------------------------------------------------
function Player:IsValidSpectatorTarget( target )

	if ( !IsValid( target ) || target == self ) then return false end
	if ( !ValidSpectatorEntities[target:GetClass()] ) then return false end
	if ( target:IsPlayer() && !target:Alive() ) then return false end
	if ( target:IsPlayer() && target:IsObserver() ) then return false end
	if ( self:Team() != TEAM_SPECTATOR && target:IsPlayer() && GAMEMODE.CanOnlySpectateOwnTeam && self:Team() != target:Team() ) then return false end
	if ( target:IsPlayer() && target:Team() == TEAM_PROPS ) then return false end -- Prevent hunters from spectating props
	
	return true

end


--[[--------------------------------------------------------
   Name: Player:GetSpectatorTargets()
   Desc: Returns a table of entities the player can spectate.
--]]--------------------------------------------------------
function Player:GetSpectatorTargets()
	
	local targets = {}
	
	if self:Team() != TEAM_HUNTERS then
		table.Add( targets, ents.FindByClass( "ph_prop" ) )
	end
	if self:Team() != TEAM_PROPS then
		table.Add( targets, team.GetPlayers( TEAM_HUNTERS ) )
	end	
	
	return targets

end


--[[--------------------------------------------------------
   Name: Player:GetValidSpectatorTargets()
   Desc: Returns a table of valid entities the player can spectate.
--]]--------------------------------------------------------
function Player:GetValidSpectatorTargets()

	local targets = self:GetSpectatorTargets()
	if !targets || targets == {} then return end
	
	local validTargets = {}
	for _,specTarget in pairs( targets ) do
		if self:IsValidSpectatorTarget( specTarget ) then
			table.insert( validTargets, specTarget )
		end
	end
	
	return validTargets

end


--[[---------------------------------------------------------
   Name: Player:FindRandomSpectatorTarget()
   Desc: Finds a random player/ent we can spectate.
		 This is called when a player is first put in spectate.
--]]---------------------------------------------------------
function Player:FindRandomSpectatorTarget()

	local targets = self:GetValidSpectatorTargets()	
	return table.Random( targets )

end


--[[-------------------------------------------------------
   Name: Player:StartEntitySpectate()
   Desc: Called to spectate an entity
--]]-------------------------------------------------------
function Player:StartEntitySpectate( ent )
	
	if !self:IsValidSpectatorTarget( ent ) then
		ent = self:FindRandomSpectatorTarget()
	end
	
	self:SpectateEntity( ent )
	self:SetEyeAngles( Angle(self:EyeAngles().p,self:EyeAngles().y,0) )

end

--[[--------------------------------------------------------
   Name: Player:NextEntitySpectate()
   Desc: Called when we want to spec the next entity.
--]]--------------------------------------------------------
function Player:NextEntitySpectate()

	local target = self:GetObserverTarget()
	self:StartEntitySpectate( target )
	
	local specTargets = self:GetValidSpectatorTargets()
	for i,SpecT in ipairs( specTargets ) do
		if target == SpecT then
			i = i+1
			if i > #specTargets then i = 1 end
			self:StartEntitySpectate( specTargets[i] )
			return
		end
	end

end


--[[--------------------------------------------------------
   Name: Player:PrevEntitySpectate()
   Desc: Called when we want to spec the previous entity.
--]]--------------------------------------------------------
function Player:PrevEntitySpectate()

	local target = self:GetObserverTarget()
	self:StartEntitySpectate( target )
	
	local specTargets = self:GetValidSpectatorTargets()
	for i,SpecT in ipairs( specTargets ) do
		if target == SpecT then
			i = i-1
			if i < 1 then i = #specTargets end
			self:StartEntitySpectate( specTargets[i] )
			return
		end
	end

end


--[[-------------------------------------------------------
   Name: Player:ChangeObserverMode()
   Desc: Change the observer mode of a player.
--]]-------------------------------------------------------
function Player:ChangeObserverMode( mode )
	
	self:Spectate( mode )
	if ( mode == OBS_MODE_IN_EYE || mode == OBS_MODE_CHASE ) then
		self:StartEntitySpectate()
	else
		-- Player might sometimes leave chase mode on an entiy with odd angles
		-- Resets the angle up-right
		self:SetEyeAngles( Angle(self:EyeAngles().p,self:EyeAngles().y,0) )
	end

end


--[[--------------------------------------------------------
   Name: Player:BecomeObserver()
   Desc: Called when we first become a spectator.
--]]--------------------------------------------------------
function Player:BecomeObserver()

	local mode = self:GetValidSpectatorModes()[1]
	self:ChangeObserverMode( mode )

end


local function spec_mode( pl, cmd, args )

	if ( !pl:IsValidSpectator() ) then return end
	
	local mode = pl:GetObserverMode()
	local nextmode = table.SFindNext( pl:GetValidSpectatorModes(), mode )
	
	pl:ChangeObserverMode( nextmode )

end
concommand.Add( "spec_mode",  spec_mode )


local function spec_next( pl, cmd, args )

	if ( !pl:IsValidSpectator() ) then return end	
	if ( !table.HasValue( pl:GetValidSpectatorModes(), pl:GetObserverMode() ) ) then spec_mode(pl) end
	
	pl:NextEntitySpectate()

end
concommand.Add( "spec_next",  spec_next )


local function spec_prev( pl, cmd, args )

	if ( !pl:IsValidSpectator() ) then return end
	if ( !table.HasValue( pl:GetValidSpectatorModes(), pl:GetObserverMode() ) ) then spec_mode(pl) end
	
	pl:PrevEntitySpectate()

end
concommand.Add( "spec_prev",  spec_prev )

local function KeyPress( ply, key )

	if ply:IsObserver() && !ply.InvismMenuOpen then
		if key == IN_ATTACK then
			spec_next( ply )
		elseif key == IN_ATTACK2 then
			spec_prev( ply )
		elseif key == IN_JUMP then
			spec_mode( ply )
		end
	end

end
hook.Add( "KeyPress", "Players.Spectator,KeyPress", KeyPress )



-- I'm just adding these just in case
function table.SFindNext( tab, val )
	local bfound = false
	for k, v in pairs( tab ) do
		if ( bfound ) then return v end
		if ( val == v ) then bfound = true end
	end

	return tab[1]
end

function table.SFindPrev( tab, val )
	local last = tab[#tab]
	for k, v in pairs( tab ) do
		if ( val == v ) then return last end
		last = v
	end

	return last
end