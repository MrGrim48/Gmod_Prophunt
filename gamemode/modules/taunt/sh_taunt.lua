
Taunt = {}

local function GetPlayer( ent )
	if !IsValid(ent) then return end
	if !IsValid(ent:GetOwner()) then return ent end
	return ent:GetOwner()
end

--[[--------------------------------------------------------------
	Name: PlayTaunt
	Desc: Plays the given taunt on the specified entity
--]]--------------------------------------------------------------
function Taunt.PlayTaunt( ent, taunt, pitch, duration )
	if !IsValid( ent ) then return end
	if !taunt then return end
	duration = duration or 5
	pitchMod = duration * ((100-pitch)/100)
	
	-- In the event we want a prop to taunt that's owned by the player
	local ply = GetPlayer(ent)
	
	if ply:IsPlayer() then
		ply:SetNWInt( "LastTauntTime", CurTime() + duration + pitchMod )
		ply:SetNWString( "LastTauntName", taunt )
	end
	
	ent:EmitSound( taunt, 100, pitch or 100 )
end


--[[--------------------------------------------------------------
	Name: PlayRandomTaunt
	Desc: Plays a random taunt on specified entity
--]]--------------------------------------------------------------
function Taunt.PlayRandomTaunt( ent, pitch )
	local Group = { "normal" }
	local ply = GetPlayer( ent )
	
	for group,_ in pairs( Taunt.Taunts ) do
		if ply:IsPlayer() && ply:CheckGroup( group ) then
			table.insert( Group, group )
		end
	end
	
	local randTaunt = Taunt.GetRandomTaunt( ent, Group )
	local tauntEnt = ent.ph_prop || ent
	
	Taunt.PlayTaunt( tauntEnt, randTaunt, pitch or math.random( 70, 150 ) )
end


--[[--------------------------------------------------------------
	Name: GetRandomTaunt
	Desc: Returns a random taunt file string
--]]--------------------------------------------------------------
function Taunt.GetRandomTaunt( ent, Group )

	if !IsValid( ent ) then return end	
	if !Taunt.Taunts || table.Count(Taunt.Taunts) == 0 then return end
	
	local Team = nil
	local ply = GetPlayer( ent )
	local Group = (Group && Group[math.random(#Group)]) || "normal"
	
	if ply:IsPlayer() then
		Team = ply:Team()
	elseif Taunt.Taunts[Group] && #Taunt.Taunts[Group] > 0 then
		Team = Taunt.Taunts[Group][ math.random(#Taunt.Taunts[Group]) ]
	end
	
	if !Team then return end
	local randTaunt = Taunt.Taunts[Group][Team][ math.random(#Taunt.Taunts[Group][Team]) ]
	return randTaunt
	
end