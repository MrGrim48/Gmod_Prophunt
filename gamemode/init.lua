-- Client download lua
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "module_loader.lua" )

-- Server include lua
include( "shared.lua" )
--include( "resource_loader.lua" )

--Resources.AddResources( "sound" )
--Resources.AddResources( "models" )
--Resources.AddResources( "materials" )
