-- BackSaw.luau
-- The killer creeps up behind the victim, revs the chainsaw and drives it
-- through their back until it comes out of their chest. It lifts them up on
-- the bar, rips it out, shoves them face down, walks over and stomps on
-- their head until it caves in.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Back Saw",
	Range = 10,
	Duration = 6.4,
	KillTime = 5.25,

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, struggle = 2, pose = { RArm = { 20, 0, 0 } } },
		-- rev it up
		{ t = 0.6, struggle = 3, pose = {
			RArm = { 55, 0, -5 },
			LArm = { 40, 0, -25 },
			Torso = { -5, 0, 0 },
			Head = { -10, 0, 0 },
		} },
		-- lunge: the saw goes in through the back
		{ t = 0.85, ease = "back", root = { 0, 0, -0.6 }, struggle = 6, pose = {
			RArm = { 90, 0, -8 },
			LArm = { 80, 0, -35 },
			Torso = { 0, 0, 0 },
			Head = { -5, 0, 0 },
			RLeg = { 25, 0, 0 },
			LLeg = { -25, 0, 0 },
		} },
		{ t = 2.2, pose = { Head = { 5, 0, 15 } } },
		-- lift them up on the bar
		{ t = 2.9, struggle = 5, pose = {
			RArm = { 120, 0, -8 },
			LArm = { 110, 0, -30 },
			Head = { 20, 0, 15 },
			RLeg = { 10, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		-- rip it out and shove them away
		{ t = 3.2, ease = "out", root = { 0, 0, -1.2 }, struggle = 2, pose = {
			RArm = { 40, 0, 25 },
			LArm = { 85, 0, 0 },
			Torso = { -15, 0, 0 },
			Head = { -10, 0, 0 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
		-- walk round to their head
		{ t = 3.45, ease = "linear", root = { -1.2, 0, -3.2 }, pose = {
			RArm = { 15, 0, 5 },
			LArm = { -20, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -25, 0, 0 },
			RLeg = { 30, 0, 0 },
			LLeg = { -30, 0, 0 },
		} },
		{ t = 3.7, ease = "linear", root = { -1.2, 0, -5.6 }, pose = {
			LArm = { 20, 0, 0 },
			RLeg = { -30, 0, 0 },
			LLeg = { 30, 0, 0 },
		} },
		{ t = 3.95, root = { 0.45, 0, -7.2 }, pose = {
			LArm = { 0, 0, 0 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
			Head = { -35, 0, 0 },
		} },
		-- stomp 1
		{ t = 4.2, ease = "out", pose = { RLeg = { 75, 0, 0 }, Torso = { 8, 0, 0 }, LArm = { 30, 0, -20 } } },
		{ t = 4.35, ease = "in", pose = { RLeg = { 10, 0, 0 }, Torso = { -12, 0, 0 } } },
		-- stomp 2
		{ t = 4.65, ease = "out", pose = { RLeg = { 75, 0, 0 }, Torso = { 8, 0, 0 } } },
		{ t = 4.8, ease = "in", pose = { RLeg = { 10, 0, 0 }, Torso = { -12, 0, 0 } } },
		-- stomp 3, higher
		{ t = 5.1, ease = "out", pose = { RLeg = { 90, 0, 0 }, Torso = { 14, 0, 0 }, LArm = { 45, 0, -30 } } },
		{ t = 5.25, ease = "in", pose = { RLeg = { 5, 0, 0 }, Torso = { -18, 0, 0 } } },
		-- grind the heel in, then stand and stare
		{ t = 5.6, pose = { RLeg = { 8, 10, 0 } } },
		{ t = 6.4, pose = {
			RLeg = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			LArm = { 0, 0, 0 },
			RArm = { 15, 0, 0 },
			Head = { -40, 0, 15 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0.95, 0, -4.6, 0, 0, 0 } },
		-- hears it, looks back over the shoulder
		{ t = 0.6, pose = { Head = { 0, -70, 0 }, RArm = { 15, 0, 10 }, LArm = { 15, 0, -10 } } },
		-- the saw goes through: arched back, head thrown back, arms flung out
		{ t = 0.85, ease = "out", root = { 0.95, 0.5, -4.5, 10, 0, 0 }, struggle = 18, pose = {
			Head = { 35, 0, 0 },
			RArm = { 55, 0, 45 },
			LArm = { 55, 0, -45 },
			RLeg = { 10, 0, 0 },
			LLeg = { -5, 0, 0 },
		} },
		{ t = 2.2, struggle = 14, pose = { Head = { 20, 20, 0 } } },
		-- lifted up on the bar
		{ t = 2.9, root = { 0.95, 2.4, -4.0, 15, 0, 0 }, struggle = 8, pose = {
			Head = { 40, -10, 0 },
			RArm = { 30, 0, 35 },
			LArm = { 30, 0, -35 },
			RLeg = { 15, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		-- shoved off the saw
		{ t = 3.2, ease = "out", root = { 0.95, 0.3, -5.3, -35, 0, 0 }, struggle = 4, pose = {
			Head = { 20, 0, 0 },
			RArm = { 120, 0, 20 },
			LArm = { 120, 0, -20 },
		} },
		-- face down on the floor
		{ t = 3.5, ease = "in", root = { 0.95, -2.5, -6.3, -90, 0, 0 }, pose = {
			Head = { 30, 0, 0 },
			RArm = { 160, 0, 25 },
			LArm = { 160, 0, -25 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
		-- trying to crawl away
		{ t = 3.8, struggle = 8, pose = { Head = { 40, 0, 0 }, RArm = { 175, 0, 15 } } },
		-- stomps
		{ t = 4.35, ease = "out", struggle = 14, pose = { Head = { 10, 0, -10 } } },
		{ t = 4.8, ease = "out", struggle = 10, pose = { Head = { 0, 0, 10 }, RArm = { 120, 0, 40 }, LArm = { 120, 0, -40 } } },
		{ t = 5.25, ease = "out", struggle = 0, pose = {
			Head = { -5, 0, 0 },
			RArm = { 100, 0, 60 },
			LArm = { 100, 0, -60 },
		} },
	},

	Camera = {
		{ t = 0, pos = { 6, 1.5, -10 }, look = { 0.8, 0.5, -3.5 }, fov = 60 },
		{ t = 0.85, ease = "out", pos = { 5.5, 1, -9.5 }, look = { 1, 0.8, -4 }, fov = 50 },
		{ t = 2.2, pos = { 8, 0.5, -3 }, look = { 1, 1, -3.5 }, fov = 50 },
		{ t = 2.9, pos = { 8, 0, -4 }, look = { 1, 1.8, -4 }, fov = 55 },
		{ t = 3.5, pos = { 7, 4, -2 }, look = { 0.5, -2, -6 }, fov = 60 },
		{ t = 4.1, pos = { 7, 0, -9.5 }, look = { 0.6, -1.6, -7.4 }, fov = 50 },
		{ t = 5.25, pos = { 6.5, -0.8, -9 }, look = { 0.7, -2, -7.6 }, fov = 45 },
		{ t = 6.4, pos = { 7, 3, -11 }, look = { 0.5, -2, -7 }, fov = 55 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.15, fx = "Sound", sound = "Rev" },
		{ t = 0.15, fx = "Shake", power = 0.25, repeatFor = 0.6, every = 0.15 },
		{ t = 0.85, fx = "Shake", power = 1.3 },
		{ t = 0.85, fx = "Flash", color = Color3.fromRGB(150, 0, 0), alpha = 0.45, time = 0.3 },
		{ t = 0.85, fx = "Sound", sound = "Saw" },
		{ t = 0.85, fx = "Sound", sound = "Scream" },
		{ t = 0.85, fx = "Blood", who = "Victim", part = "Torso", amount = 18 },
		{ t = 0.9, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 2.3, every = 0.1 },
		{ t = 0.9, fx = "Shake", power = 0.45, repeatFor = 2.2, every = 0.12 },
		{ t = 1.0, fx = "Darken", amount = 0.85, time = 1 },
		{ t = 3.2, fx = "Blood", who = "Victim", part = "Torso", amount = 14 },
		{ t = 3.5, fx = "Shake", power = 0.7 },
		{ t = 4.35, fx = "Shake", power = 0.9 },
		{ t = 4.35, fx = "Sound", sound = "Stomp" },
		{ t = 4.35, fx = "Blood", who = "Victim", part = "Head", amount = 6 },
		{ t = 4.8, fx = "Shake", power = 1.1 },
		{ t = 4.8, fx = "Sound", sound = "Stomp" },
		{ t = 4.8, fx = "Blood", who = "Victim", part = "Head", amount = 10 },
		{ t = 5.25, fx = "Shake", power = 1.7 },
		{ t = 5.25, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.55, time = 0.4 },
		{ t = 5.25, fx = "Sound", sound = "Crush" },
		{ t = 5.25, fx = "Crush", who = "Victim", part = "Head", amount = 30 },
		{ t = 5.25, fx = "Darken", amount = 1, time = 0.3 },
		{ t = 6.0, fx = "Eyes", on = false },
	},
}
