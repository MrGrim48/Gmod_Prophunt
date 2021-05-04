
local function PlayerMove( ply, mData ) 

	if IsValid( ply ) && ply:Team() == TEAM_PROPS && IsValid(ply.ph_prop) && ply:Alive() && ply:GetNWBool("PhysicsMode",false) then
		
		mData:SetSideSpeed( 0 )
		mData:SetForwardSpeed( 0 )
		mData:SetUpSpeed( 0 )
		mData:SetMaxClientSpeed( 0 )
		mData:SetVelocity( Vector() )
		
		local worldCenter = ply.ph_prop:WorldSpaceCenter()
		local minVec, maxVec = ply.ph_prop:WorldSpaceAABB()
		local playerPos = Vector( worldCenter.x, worldCenter.y, minVec.z ) 
		
		mData:SetOrigin( playerPos )
		
	end

end
hook.Add( "Move", "Props.PlayerMove", PlayerMove )