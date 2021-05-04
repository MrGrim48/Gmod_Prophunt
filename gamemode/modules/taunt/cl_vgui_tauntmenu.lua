
local BASE = {}

local Player = FindMetaTable( "Player" )
function Player:PlayTaunt( Group, TauntID, Duration )
	net.Start( "PlayTaunt" )
	net.WriteString( Group or "normal" )
	net.WriteInt( self:Team(), 32 )
	net.WriteInt( TauntID or 0, 32 )
	net.WriteInt( Duration or 0, 32 )
	net.WriteInt( GetConVar("taunt_pitch"):GetInt(), 32 ) 
	net.SendToServer()
end

function BASE:PlayTaunt( Group, TauntID )
	if CurTime() < LocalPlayer():GetNWInt("LastTauntTime")+LocalPlayer():GetNWInt("TauntDelay",5) then return end

	self.oldCurTime = CurTime()
	local duration = 0
	if TauntID && TauntID > 0 then duration = self.Taunts[Group][LocalPlayer():Team()][TauntID].duration end
	LocalPlayer():PlayTaunt( Group, TauntID, duration )
	
	local leaveOpen = GetConVar("taunt_leaveopen"):GetInt() == 1
	if !leaveOpen then
		self:Hide()
	end
end

function BASE:LoadTaunts()

	local width, height = self:GetSize()
	self.Taunts = self.Taunts or { ["normal"] = {} }

	for Group, gTable in pairs( self.Taunts ) do
		if !self.Tabs then 
			self.Tabs = vgui.Create( "DPropertySheet", self )
			self.Tabs:SetPos( 5, 30 )
			self.Tabs:SetSize( width-10, height-130 )
		end
		
		local gList = vgui.Create( "DListView", self.Tabs )
		gList:SetMultiSelect( false )
		--gList:SetPaintBackground( true )
		--gList:SetBackgroundColor( Color( 100, 100, 100 ) )
		gList:StretchToParent( 2, 2, 2, 2 )
		gList:AddColumn( "Taunt Name" )
		gList:AddColumn( "Duration" )
		self.Tabs:AddSheet( Group, gList )
		
		if self.Taunts[Group][LocalPlayer():Team()] then
			for _, Taunt in pairs( self.Taunts[Group][LocalPlayer():Team()] ) do
				local fileName = string.StripExtension(string.GetFileFromFilename(Taunt.taunt))
				fileName = string.gsub( fileName, "_", " " )
				gList:AddLine( fileName, Taunt.duration )
			end
		end
	end
	
	local pitchBack = vgui.Create( "DPanel", self )
	pitchBack:SetSize( width, 25 )
	pitchBack:SetPos( 0, height-85 )
	function pitchBack:Paint(w,h)
		draw.RoundedBox( 0, 0, 0, w, h, Color(170,170,170) )
	end
	local pitchSlider = vgui.Create( "DNumSlider", self )
	pitchSlider:SetText( "Pitch" )
	pitchSlider:SetSize( width-50, 16 )
	pitchSlider:SetPos( 10, height-80 )
	pitchSlider:SetMinMax( 70, 150 )
	pitchSlider:SetDecimals( 0 )
	pitchSlider:SetValue( 100 )
	pitchSlider.Label:SetTextColor( Color( 0,0,0 ) )
	pitchSlider.Label:SetWide( 20 )
	pitchSlider:SetConVar( "taunt_pitch" )
	
	local resetPitch = vgui.Create( "DButton", self )
	resetPitch:SetText( "Reset" )
	resetPitch:SetSize( 34, 18 )
	resetPitch:SetPos( width-resetPitch:GetWide()-5, height-80 )
	resetPitch.DoClick = function()
		pitchSlider:SetValue( 100 )
	end
	
	local playButton = vgui.Create( "DButton", self )
	playButton:SetSize( (width*0.5)-7, 30 )
	playButton:SetPos( 5, height-35 )
	playButton:SetText( "Play Taunt" )
	playButton.DoClick = function()
		if !self.Tabs then return end
		local activeTab = self.Tabs:GetActiveTab()
		local selectedLine = activeTab:GetPanel():GetSelectedLine()
		if selectedLine then
			self:PlayTaunt( activeTab:GetText(), selectedLine )
		end
	end
	
	local randomButton = vgui.Create( "DButton", self )
	randomButton:SetSize( (width*0.5)-7, 30 )
	randomButton:SetPos( (width*0.5)+2, height-35 )
	randomButton:SetText( "Random Taunt" )
	randomButton.DoClick = function()
		if !self.Tabs then return end
		local activeTab = self.Tabs:GetActiveTab()
		self:PlayTaunt( activeTab:GetText(), 0 )
	end
	
	local leaveOpen = vgui.Create( "DCheckBoxLabel", self )
	leaveOpen:SetPos( 10, height-55 )
	leaveOpen:SetText( "Leave Menu Open" )
	leaveOpen:SetConVar( "taunt_leaveopen" )
	leaveOpen:SetValue( GetConVar("taunt_leaveopen"):GetInt() )

end


function BASE:Paint( w, h )

	draw.RoundedBox( 0, 0, 0, w, h, Color( 50,50,50 ) )
	
	if CurTime() <= LocalPlayer():GetNWFloat("LastTauntTime")+LocalPlayer():GetNWInt("TauntDelay",5) then
	
		self.oldCurTime = self.oldCurTime or CurTime()
		local maxDuration = math.Round( (LocalPlayer():GetNWFloat("LastTauntTime")+LocalPlayer():GetNWInt("TauntDelay",5)) - self.oldCurTime, 1 )
		local curDuration = CurTime()-self.oldCurTime
		local iProgress = curDuration / maxDuration
		surface.SetDrawColor( Color( 255,255,0 ) )
		surface.DrawRect( 0, h-3, w*(1-iProgress), 3 )
		
	end

end

vgui.Register( "TauntMenu", BASE, "DFrame" )