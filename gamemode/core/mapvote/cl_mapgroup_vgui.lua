
local BASE = {}

function BASE:Init()

	self:SetPos( 50, 50 )
	self:SetSize( 600, 400 )
	
	-- Map List
	self.mList = vgui.Create( "DListView", self )
	self.mList:SetMultiSelect( false )
	self.mList:StretchToParent( 5, 30, 301, 5 )
	self.mList:AddColumn( "Map" )
	self.mList.OldOnClickLine = self.mList.OnClickLine
	self.mList.OnClickLine = function( parent, line, isSelected )
		self.mList.OldOnClickLine( parent, line, isSelected )
		if line then
			if MapGroups then
				self.mapGroup:SetValue( MapGroups[line:GetColumnText(1)] )				
				self.Info:SetVisible( true )
			end
		else
			self.Info:SetVisible( false )
		end
	end

	
	-- Populate List 
	for map, group in pairs( MapGroups ) do
		self.mList:AddLine( map )
	end
	
	-- Info Panel
	self.Info = vgui.Create( "DPanel", self )
	self.Info:StretchToParent( 306, 30, 5, 5 )
	self.Info:SetVisible( false )
	self.Info.Paint = function() end
	
	local currentMap = vgui.Create( "DLabel", self.Info )
	currentMap:SetText( "Current Map: " .. game.GetMap() )
	currentMap:SetPos( 0, 40 )
	currentMap:SizeToContents()
	
	local groupLabel = vgui.Create( "DLabel", self.Info )
	groupLabel:SetText( "Group: " )
	groupLabel:SetPos( 0, 60 )
	groupLabel:SizeToContents()
	
	self.mapGroup = vgui.Create( "DComboBox", self.Info )
	self.mapGroup:SetSize( 100, 20 )
	self.mapGroup:SetPos( 50, 60 )
	self.mapGroup:SetValue( "Group" )
	self.mapGroup:AddChoice( "Small" )
	self.mapGroup:AddChoice( "Medium" )
	self.mapGroup:AddChoice( "Large" )
	self.mapGroup.OnSelect = function( panel, index, value )
		local selectedLine = self.mList:GetSelectedLine()
		local selectedMap = self.mList:GetLine( selectedLine ):GetColumnText(1)
		
		MapGroups[selectedMap] = value
		
		net.Start( "ModifyMapGroup" )
		net.WriteString( selectedMap )
		net.WriteString( value )
		net.SendToServer()
	end

end

vgui.Register( "MapGroupsAdmin", BASE, "DFrame" )