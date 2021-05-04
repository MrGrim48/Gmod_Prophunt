-- Copying the code from the Cinema gamemode
-- Credits to their team (or to the person(s) who worked on it)

module( "Loader", package.seeall )

BaseGamemode = GM.FolderName

local function GetFileList( strDirectory )
	
	local files = {}

	local realDirectory = BaseGamemode .. "/gamemode/" .. strDirectory .. "/*"
	local findFiles, findFolders = file.Find( realDirectory, "LUA" )

	for k, v in pairs( table.Add(findFiles, findFolders) ) do
	
		if ( v == "." || v == ".." || v == ".svn" ) then continue end
		
		table.insert( files, v )
		
	end
	
	return files
	
end

local function IsLuaFile( strFile )
	return ( string.sub( strFile, -4 ) == ".lua" )
end

local function IsDirectory( strDir )
	return ( string.GetExtensionFromFilename( strDir ) == nil )
end

local function LoadFile( strDirectory, strFile )
	
	local prefix = string.sub( strFile, 0, 3 )
	local realFile = BaseGamemode .. "/gamemode/" .. strDirectory .. "/" .. strFile

	if ( prefix == "cl_" ) then
		
		if SERVER then
			AddCSLuaFile( realFile )
		else
			include( realFile )
		end
	
	elseif ( prefix == "sh_" ) then
	
		if SERVER then
			AddCSLuaFile( realFile )
		end
		
		include( realFile )
		
	elseif ( prefix == "sv_" || strFile == "init.lua" ) then
	
		if SERVER then
			include( realFile )
		end
		
	end
	
end

function LoadAction( strDirectory, funcAction )

	local entList = GetFileList( strDirectory )
	
	for _, v in pairs( entList ) do
	
		local entDir = strDirectory .. "/" .. v
		local entFiles = GetFileList( entDir )

		funcAction( entDir, entFiles, v )
		
	end
	
end

function LoadEntities( entDir, entFiles, entName )

	_G.ENT = {}
	
	for _, entFile in pairs( entFiles ) do
		LoadFile( entDir, entFile )
	end
	
	if _G.ENT.Type then
		scripted_ents.Register( _G.ENT, entName, false )
	end
	
	_G.ENT = nil
	
end

function LoadEnts( strDirectory )

	local strDirectory = strDirectory .. "/ents"
	local fileList = GetFileList( strDirectory )
	Sort( fileList )

	for _, v in pairs( fileList ) do

		local entFolder = strDirectory .. "/" .. v
		
		if ( v == "entities" ) then
			LoadAction( entFolder, LoadEntities )
		end
		
	end
	
end

function Load( strDirectory )
	
	local fileList = GetFileList( strDirectory )
	Sort( fileList )

	if table.HasValue( fileList, "ents" ) then
		LoadEnts( strDirectory )
	end

	for k, v in pairs( fileList ) do
	
		if ( IsLuaFile( v ) ) then
			LoadFile( strDirectory, v )
		elseif ( v != "ents" ) then // we won't go into ents folders
			local strNextDir = strDirectory .. "/" .. v
			if IsDirectory( strNextDir ) then
				Load( strNextDir ) // go deeper. BWOOOOOONG!!
			end
		end
	end
	
end

-- Sort the files to load the sh_ files first
function Sort( fileList )
	
	local sorteddTable = {}
	local strFiles = table.concat( fileList, " " )
	
	local function gMatch( strFiles, prefix )
		local matches = {}
		for word in string.gmatch( strFiles, "("..prefix.."+%w+%.lua)" ) do
			table.insert( matches, word )
		end
		return matches
	end
	
	table.Add( sorteddTable, gMatch(strFiles, "sh_" ) )
	table.Add( sorteddTable, gMatch(strFiles, "sv_" ) )
	table.Add( sorteddTable, gMatch(strFiles, "cl_" ) )
	
	fileList = sorteddTable
	
end