-- OverheadSplit.luau
-- The killer kicks the victim down onto their knees, raises the running
-- chainsaw over its head and brings it straight down through their head and
-- into their chest, grinding it deeper while they shake, then rips it out
-- and lets them slump onto their face.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Overhead Split",
	Range = 10,
	Duration = 4.2,
	KillTime = 3.0,

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, struggle = 2, pose = { RArm = { 20, 0, 0 } } },
		-- kick to the knees
		{ t = 0.3, ease = "out", pose = { LLeg = { 70, 0, 0 }, Torso = { 10, 0, 0 }, LArm = { -20, 0, -15 } } },
		{ t = 0.55, pose = { LLeg = { 0, 0, 0 }, Torso = { 0, 0, 0 }, LArm = { 0, 0, 0 } } },
		-- raise the saw high over the head with both hands
		{ t = 1.0, struggle = 3, pose = {
			RArm = { 190, 0, -10 },
			LArm = { 185, 0, 25 },
			Torso = { 15, 0, 0 },
			Head = { 20, 0, 0 },
		} },
		-- CHOP: straight down into the head
		{ t = 1.25, ease = "in", struggle = 6, pose = {
			RArm = { 100, 0, -12 },
			LArm = { 95, 0, 30 },
			Torso = { -15, 0, 0 },
			Head = { -20, 0, 0 },
			RLeg = { 20, 0, 0 },
			LLeg = { -15, 0, 0 },
		} },
		-- grind it down deeper
		{ t = 2.0, pose = { RArm = { 92, 0, -12 }, LArm = { 88, 0, 30 }, Torso = { -20, 0, 0 } } },
		{ t = 2.8, pose = { RArm = { 85, 0, -12 }, LArm = { 80, 0, 30 }, Torso = { -28, 0, 0 }, Head = { -30, 0, 15 } } },
		-- rip it out and kick the body over
		{ t = 3.0, ease = "out", struggle = 2, pose = {
			RArm = { 120, 0, 20 },
			LArm = { 30, 0, -10 },
			Torso = { 5, 0, 0 },
			Head = { -10, 0, 0 },
			RLeg = { -20, 0, 0 },
			LLeg = { 20, 0, 0 },
		} },
		{ t = 3.3, pose = { RLeg = { 0, 0, 0 }, LLeg = { 0, 0, 0 } } },
		{ t = 4.2, pose = {
			RArm = { 15, 0, 0 },
			LArm = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -30, 0, 10 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0.55, 0, -4.5, 0, 180, 0 } },
		{ t = 0.2 },
		-- legs kicked out from under them
		{ t = 0.38, ease = "out", root = { 0.55, -0.6, -4.4, -5, 180, 0 }, pose = {
			RLeg = { -60, 0, 0 },
			LLeg = { -55, 0, 0 },
			Head = { 25, 0, 0 },
			RArm = { 50, 0, 40 },
			LArm = { 50, 0, -40 },
		} },
		-- kicked down onto the knees
		{ t = 0.45, ease = "in", root = { 0.55, -1.5, -4.2, 0, 180, 0 }, pose = {
			RLeg = { -90, 0, 0 },
			LLeg = { -90, 0, 0 },
			Head = { 15, 0, 0 },
			RArm = { 40, 0, 20 },
			LArm = { 40, 0, -20 },
		} },
		-- arms up to shield the head
		{ t = 0.9, struggle = 6, pose = {
			RArm = { 160, 0, -20 },
			LArm = { 160, 0, 20 },
			Head = { 25, 0, 0 },
		} },
		-- CHOP: arms knocked away, head split, body shaking
		{ t = 1.25, ease = "out", struggle = 20, pose = {
			RArm = { 70, 0, 50 },
			LArm = { 70, 0, -50 },
			Head = { -25, 0, -35 },
		} },
		{ t = 2.0, struggle = 16, root = { 0.55, -1.7, -4.2, -5, 180, 0 }, pose = { Head = { -35, 0, -45 } } },
		{ t = 2.8, struggle = 10, root = { 0.55, -1.9, -4.2, -8, 180, 0 }, pose = {
			Head = { -45, 0, -55 },
			RArm = { 20, 0, 20 },
			LArm = { 20, 0, -20 },
		} },
		-- saw ripped out: slumps forward onto the face
		{ t = 2.9, ease = "in", struggle = 0, root = { 0.55, -1.6, -4.0, -45, 180, 0 }, pose = {
			RLeg = { -45, 0, 0 },
			LLeg = { -45, 0, 0 },
			RArm = { 30, 0, 20 },
			LArm = { 30, 0, -20 },
		} },
		{ t = 3.0, ease = "in", root = { 0.55, -2.4, -3.3, -90, 180, 0 }, pose = {
			RLeg = { 0, 0, 5 },
			LLeg = { 0, 0, -5 },
			Head = { 10, 40, 0 },
			RArm = { 10, 0, 25 },
			LArm = { 5, 0, -20 },
		} },
	},

	Camera = {
		{ t = 0, pos = { 6, 1.5, -1 }, look = { 0.3, 0, -3 }, fov = 62 },
		{ t = 0.45, pos = { 6.5, 0.5, -2 }, look = { 0.5, -0.5, -3.5 }, fov = 55 },
		-- low, looking up at the raised saw
		{ t = 1.0, pos = { 4, -1.5, -8.5 }, look = { 0.3, 1.5, -2.5 }, fov = 60 },
		{ t = 1.25, ease = "out", pos = { 6, 0, -6 }, look = { 0.6, -0.5, -3.8 }, fov = 48 },
		{ t = 2.8, pos = { 5.5, -0.5, -7 }, look = { 0.6, -0.8, -4 }, fov = 44 },
		{ t = 3.2, pos = { 4.5, 3.5, -10 }, look = { 1, -2, -4.5 }, fov = 58 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.3, fx = "Shake", power = 0.6 },
		{ t = 0.45, fx = "Shake", power = 0.5 },
		{ t = 0.6, fx = "Sound", sound = "Rev" },
		{ t = 0.6, fx = "Shake", power = 0.2, repeatFor = 0.6, every = 0.15 },
		{ t = 1.25, fx = "Shake", power = 1.5 },
		{ t = 1.25, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.5, time = 0.35 },
		{ t = 1.25, fx = "Sound", sound = "Saw" },
		{ t = 1.25, fx = "Sound", sound = "Scream" },
		{ t = 1.25, fx = "Blood", who = "Victim", part = "Head", amount = 22 },
		{ t = 1.3, fx = "Blood", who = "Victim", part = "Head", amount = 3, repeatFor = 1.6, every = 0.1 },
		{ t = 1.3, fx = "Blood", who = "Victim", part = "Torso", amount = 2, repeatFor = 1.6, every = 0.15 },
		{ t = 1.3, fx = "Shake", power = 0.45, repeatFor = 1.6, every = 0.12 },
		{ t = 1.4, fx = "Darken", amount = 0.9, time = 1 },
		{ t = 3.0, fx = "Shake", power = 0.8 },
		{ t = 3.0, fx = "Blood", who = "Victim", part = "Head", amount = 14 },
		{ t = 3.8, fx = "Eyes", on = false },
	},
}
