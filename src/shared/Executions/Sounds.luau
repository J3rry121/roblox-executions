-- Sounds.luau
-- Every sound the executions use. Each name has a list of sound ids, and a
-- random one is picked each time (with a slightly random pitch) so the same
-- hit never sounds exactly the same twice.
--
-- These are free sounds from the Roblox Creator Store, picked by their names.
-- To swap one: find a sound in Studio (View > Toolbox > Audio), right click >
-- Copy Asset ID, and paste the number into the list. Empty list = no sound.

local Sounds = {}

-- The victim's voice. Players can switch it with the V key.
--   "Female", "Male" or "Off"
Sounds.DefaultVoice = "Female"
Sounds.VoiceOptions = { "Female", "Male", "Off" }

-- Effects: { ids, volume }
Sounds.Effects = {
	Sting = { { 1839909461, 1014740409, 94481318200921 }, 0.7 }, -- horror sting when it starts
	Grab = { { 92208526518943, 9113536416 }, 0.8 },
	Kick = { { 116869438971770, 122835931028321 }, 0.9 },
	Snap = { { 17032438711, 135076986499326, 121666760679562 }, 1 }, -- bone break
	Bite = { { 9113660936, 76532013655796, 9120113261 }, 1 },
	Drag = { { 9113536503, 9120113261 }, 0.8 },
	Rev = { { 9113764732, 84277510933049, 9125435873 }, 0.9 }, -- chainsaw starting up / revving
	Saw = { { 115734063892345, 138927123708012 }, 1 }, -- chainsaw cutting
	Slash = { { 102130734248356 }, 1 }, -- chainsaw swing
	Stall = { { 9113765861, 9113765839 }, 0.8 }, -- chainsaw dying down
	Stab = { { 76532013655796, 133858142626848 }, 1 },
	Gore = { { 137393437402856, 132699612162008, 9120113261 }, 1 }, -- wet squelch / blood
	Rip = { { 120339322927886, 9113536416, 124893077006041 }, 1 }, -- limb torn off
	Stomp = { { 85885086061086, 116869438971770 }, 1 },
	Crush = { { 17032438711, 103537113507597, 9113660936 }, 1 }, -- skull crushed
	Fall = { { 9113475819, 9113473249, 102132912452331 }, 0.9 }, -- body hitting the floor
}

-- Looping chainsaw sound while the killer holds the trigger
Sounds.SawLoop = { { 115734063892345 }, 0.45 }

-- Victim voice lines: Voice[voice][line] = { ids, volume }
Sounds.Voice = {
	Female = {
		Scream = { { 9114397739, 9114397912, 9114397935, 9118844076, 9113985848 }, 1 },
		Grunt = { { 9114399475, 9114399356, 9114400180, 94764118679590, 103203316474210 }, 0.9 },
		Choke = { { 114667334394962, 107511816483679 }, 1 },
		Gasp = { { 9114029789, 9114029889, 9114030325, 9114030290 }, 0.9 },
	},
	Male = {
		Scream = { { 9125652443, 9125652949 }, 1 },
		Grunt = { { 140239727415476, 86765830289261, 9114030165, 9114029940 }, 0.9 },
		Choke = { { 9114030411, 9114030432 }, 1 },
		Gasp = { { 9114030161, 9114029937, 9114030468 }, 0.9 },
	},
}

return Sounds
