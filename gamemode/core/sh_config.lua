
-- Information about the gamemode.
GM.Name		= "Prop Hunt"
GM.Author	= "MrGrimm"
GM.Email	= ""
GM.Website	= ""


-- Gamemode configuration.
-- Game
GM.GameLength				= 30 -- Time in minutes for a game on each map to last (Default: 30)
GM.RoundBased				= true
GM.RoundLimit				= 10 -- Maximum number of rounds per map (Default: 10)
GM.RoundLength 				= 300 -- Time (in seconds) for each round (Default: 300)
GM.RoundPreStartTime		= 1 -- (Default: 1)
GM.RoundPostLength 			= 5	-- Seconds to show the 'x team won!' screen at the end of a round (Default:5 )
GM.RoundPreGameLength		= 30 -- Seconds to wait before starting the game if waiting for players to join (Default: 30)

-- Teams
GM.TeamBased 				= true
GM.AutomaticTeamBalance		= true
GM.AllowAutoTeam 			= true
GM.AddFragsToTeamScore		= true
GM.CanOnlySpectateOwnTeam 	= true
GM.SwapTeamsEveryRound		= true

-- Player
GM.EnableFreezeCam			= true
GM.NoAutomaticSpawning		= true
GM.NoNonPlayerPlayerDamage	= true
GM.NoPlayerPlayerDamage 	= true
GM.HunterBlindLockTime		= 30 -- Seconds for hunters to be blinded each round (Default: 30)
GM.HunterFirePenalty		= 5 -- Damage hunters take when damaging non-player props (Default: 5)
GM.HunterKillBonus			= 20 -- How much to heal the hunter after killing a prop (Default: 20)

-- ???
GM.Data 					= {} 
GM.SelectModel				= false

GM.SuicideString			= "couldn't take the pressure and committed suicide."
GM.HudSkin 					= "PropHuntSkin" -- The Derma skin to use for the HUD components
GM.RemoveWeaponsFromMap		= false
GM.RemoveItemsFromMap		= false


-- If you win, one of these will be played. Set blank to disable.
GM.VictorySounds = {
	"vo/announcer_success.wav"
}


-- If you loose one of these will be played. Set blank to disable.
GM.LossSounds = {
	"vo/announcer_failure.wav"
}