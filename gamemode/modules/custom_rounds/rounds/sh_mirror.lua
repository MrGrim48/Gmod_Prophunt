--[[
sh_mirror.lua

Copyright© Nekom Glew, 2017

--]]

local ROUND = {}

ROUND.Name = "Mirrored Map"

function ROUND:Condition()
	return math.random() < 0.2 // 20% chance?
end

function ROUND:Init()
	if SERVER then SetGlobalBool( "MapMirrored", true ) end
end

function ROUND:RoundEndWithResult()
	if SERVER then SetGlobalBool( "MapMirrored", false ) end
end

if CLIENT then
-- Code taken from the map mirror addon
-- Variables
local View;
local rtPrev;
local rtMirror = render.GetMorphTex0();

-- Set up the render target and material to do the transformation
local MirroredMaterial = CreateMaterial("MirroredMaterial",	"UnlitGeneric",	{
		[ '$basetexture' ] = rtMirror,
		[ '$basetexturetransform' ] = "center .5 .5 scale -1 1 rotate 0 translate 0 0",
		[ '$nocull' ] = "1",
});

-- Render our mirrored scene
function ROUND:RenderScene( pos, ang )
	-- Save our previous RT
	rtPrev = render.GetRenderTarget();

	-- Setup the view table
	View = {x=0,y=0,w=ScrW(),h=ScrH(),origin=pos,angles=ang};

	-- Push the RT and render
	render.SetRenderTarget( rtMirror );
	render.Clear( 0, 0, 0, 255, true );
	render.ClearDepth();
	render.ClearStencil();

	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )

	render.RenderView( View );

	render.PopFilterMag()
	render.PopFilterMin()

	--if _G:GetMirrorWorld_HUD() then
		--render.RenderHUD(0,0,ScrW(),ScrH());
	--end
	-- Go back to the previous RT we stored earlier
	render.SetRenderTarget( oldrt );

	-- Setup our MirroredMaterial.
	MirroredMaterial:SetTexture( "$basetexture", rtMirror );

	-- Draw
	render.SetMaterial( MirroredMaterial );
	render.DrawScreenQuad();

	--if not _G:GetMirrorWorld_HUD() then
		-- We don't want the HUD to get mirrored too, so we draw it here.
		render.RenderHUD(0,0,ScrW(),ScrH());
	--end

	-- Supress RenderScene
	return true;
end

-- Apply some transformations to the Vector.ToScreen method.
local VECTOR = FindMetaTable("Vector")
local oldToScreen = VECTOR.ToScreen
function VECTOR:ToScreen()
	if not GetGlobalBool("MapMirrored") then return oldToScreen(self) end

	local pos = oldToScreen(self)
	pos.x = pos.x * -1 + ScrW()
	return pos
end

-- Parse input from the mouse and keyboard to work with out new view.
function ROUND:InputMouseApply( cmd, x, y, angle )
	local pitchchange = y * GetConVar( "m_pitch" ):GetFloat()
	local yawchange = x * -GetConVar( "m_yaw" ):GetFloat()

	angle.p = angle.p + pitchchange * 1
	angle.y = angle.y + yawchange * -1

	cmd:SetViewAngles( angle )

	return true
end

function ROUND:CreateMove( cmd )
	local forward = 0
	local right = 0
	local maxspeed = LocalPlayer():GetMaxSpeed()

	if cmd:KeyDown( IN_FORWARD ) then
		forward = forward + maxspeed
	end
	if cmd:KeyDown( IN_BACK ) then
		forward = forward - maxspeed
	end
	if cmd:KeyDown( IN_MOVERIGHT ) then
		right = right - maxspeed
	end
	if cmd:KeyDown( IN_MOVELEFT ) then
		right = right + maxspeed
	end

	cmd:SetForwardMove( forward )
	cmd:SetSideMove( right )
end
end

CRounds.AddRound( ROUND )