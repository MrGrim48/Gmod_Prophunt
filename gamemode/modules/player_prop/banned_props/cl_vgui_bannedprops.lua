
local BASE = {}

function BASE:Initialize()
		
	-- Model List
	self.mList = vgui.Create( "DListView", self )
	self.mList:SetMultiSelect( false )
	self.mList:StretchToParent( 5, 30, 301, 5 )
	self.mList:AddColumn( "Model" )
	self.mList.OldOnClickLine = self.mList.OnClickLine
	self.mList.OnClickLine = function( parent, line, isSelected )
		self.mList.OldOnClickLine( parent, line, isSelected )
		if line then
			if BannedPropsData then
				self.bannedIndicator.SetBanned( BannedPropsData[line:GetColumnText(1)] )
				
				self.mModel:SetModel( line:GetColumnText(1) )
				local min, max = self.mModel.Entity:GetModelBounds()
				self.mModel:SetLookAt( Vector(0,0,(max.z-min.z)) )
				
				self.Info:SetVisible( true )
			end
		else
			self.Info:SetVisible( false )
		end
	end
	
	-- Populate List 
	for _, model in pairs( PropModels ) do
		self.mList:AddLine( model )
	end
	
	-- Info Panel
	self.Info = vgui.Create( "DPanel", self )
	self.Info:StretchToParent( 306, 30, 5, 5 )
	self.Info:SetVisible( false )
	self.Info.Paint = function() end
	
	local bannedLabel = vgui.Create( "DLabel", self.Info )
	bannedLabel:SetText( "Accepted: " )
	bannedLabel:SetPos( 0, self.Info:GetTall()-40 )
	bannedLabel:SizeToContents()
	
	self.bannedIndicator = vgui.Create( "DImage", self.Info )
	self.bannedIndicator:SetSize( 16, 16 )
	self.bannedIndicator:SetPos( 50, self.Info:GetTall()-40 )
	self.bannedIndicator.SetBanned = function( isBanned )
		if isBanned then
			self.bannedIndicator:SetImage( "icon16/cross.png" )
		else
			self.bannedIndicator:SetImage( "icon16/tick.png" )
		end
	end
	
	local toggleBanned = vgui.Create( "DButton", self.Info )
	toggleBanned:SetPos( 0, self.Info:GetTall() - 22 )
	toggleBanned:SetText( "Toggle Ban" )
	toggleBanned.DoClick = function()
		local selectedLine = self.mList:GetSelectedLine()
		local selectedModel = self.mList:GetLine( selectedLine ):GetColumnText(1)
		
		BannedPropsData[selectedModel] = !BannedPropsData[selectedModel]
		self.bannedIndicator.SetBanned( BannedPropsData[selectedModel] )
		
		net.Start( "ModifyBannedPropData" )
		net.WriteString( selectedModel )
		net.WriteBool( BannedPropsData[selectedModel] )
		net.SendToServer()
	end
	
	
	-- Model Panel
	local modelPanel = vgui.Create( "DPanel", self.Info )
	modelPanel:StretchToParent( 1, 1, 1, 50 )
	self.mModel = vgui.Create( "DAdjustableModelPanel", modelPanel )
	self.mModel:StretchToParent( 1, 1, 1, 1 )
	
end

vgui.Register( "BannedPropsAdmin", BASE, "DFrame" )