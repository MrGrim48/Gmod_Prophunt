--[[
sh_crounds.lua

Copyright© Nekom Glew, 2017

--]]

CRounds = {}

CRounds.ActiveRound = nil 

CRounds.Chance = 0.2 --Chance of a custom round starting. 0-1. 1 being 100%
CRounds.Rounds = {} -- Store the custom rounds 

--[[------------------------------------------------
	Name: AddRound()
	Desc: Adds the data of a round with the name as the key
--]]------------------------------------------------
function CRounds.AddRound( round )

	if !round or type(round) != "table" then return end
	round.Name = round.Name or "Unknown"
	
	print( "[Custom Rounds] Adding Round", round.Name )
	
	for funcName, funcBody in pairs(round) do
		if type(funcBody) == "function" then 
			hook.Add(funcName, 'CRounds.' .. round.Name .. '.' .. funcName, function(...)
				if CRounds and CRounds.ActiveRound and CRounds.ActiveRound.Name == round.Name then
					return round[funcName]( round, unpack({...}) )
				end
			end)
		end
	end
	
	CRounds.Rounds[round.Name] = round

end

--[[------------------------------------------------
	Name: SetRound()
	Desc: Set the ActiveRound with the given roundID
--]]------------------------------------------------
function CRounds.SetRound( roundID )
	
	if SERVER then 
		net.Start( "CRounds.ActiveRound" )
		if roundID then net.WriteString( roundID ) end
		net.Broadcast()
	end
	
	if (!roundID or string.len(roundID)==0) and CRounds.ActiveRound and CRounds.ActiveRound.EndRound then
		CRounds.ActiveRound:EndRound()
	end

	CRounds.ActiveRound = CRounds.Rounds[roundID]
	if !CRounds.ActiveRound then return end
	
	if CRounds.ActiveRound.Init then
		CRounds.ActiveRound:Init()
	end
	
	CRounds.ActiveRound.TimeStart = CurTime()
	
end

-- Server to Client StartRound and EndRound
if CLIENT then net.Receive( "CRounds.ActiveRound", function()
	CRounds.SetRound( net.ReadString() ) -- Start the new custom round
end ) end