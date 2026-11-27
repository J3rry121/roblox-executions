-- SawImpale.luau
-- The killer revs the chainsaw, lunges and drives it through the victim,
-- grinds, lifts them up on the bar, then rips it out and lets them drop.
-- Needs the killer to be holding a chainsaw in the right hand (the default
-- killer does; see server/Executions/KillerBuilder.luau).
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Saw Impale",
	Range = 10,
	Duration = 4.0,
	KillTime = 3.1,

	Killer = {
		{ t = 0, root = { 0, 0, 0 } },
		-- rev it
		{ t = 0.6, struggle = 3, pose = {
			RArm = { 20, 0, 0 },
			LArm = { 30, 0, -10 },
			Torso = { -5, 0, 0 },
			Head = { -10, 0, 0 },
		} },
		-- lunge and stab
		{ t = 0.9, ease = "back", root = { 0, 0, -1 }, struggle = 4, pose = {
			RArm = { 60, 0, -15 },
			LArm = { 50, 0, -20 },
			RLeg = { 25, 0, 0 },
			LLeg = { -20, 0, 0 },
		} },
		-- grind
		{ t = 2.0, struggle = 6, pose = { Head = { -15, 0, 10 } } },
		-- lift them up on the bar
		{ t = 2.6, struggle = 5, pose = {
			RArm = { 85, 0, -15 },
			LArm = { 80, 0, -25 },
			Torso = { 10, 0, 0 },
			Head = { 10, 0, 10 },
		} },
		{ t = 2.9 },
		-- rip it out
		{ t = 3.1, ease = "out", struggle = 2, pose = {
			RArm = { 30, 0, 30 },
			LArm = { 10, 0, -10 },
			Torso = { 0, -20, 0 },
		} },
		-- lower the saw, still idling
		{ t = 3.9, pose = {
			RArm = { 10, 0, 0 },
			LArm = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -20, 0, 0 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0, 0, -6, 0, 180, 0 } },
		-- backing away, hands up
		{ t = 0.6, ease = "out", root = { 0, 0, -6.5, 8, 180, 0 }, pose = {
			RArm = { 110, 0, -10 },
			LArm = { 110, 0, 10 },
			Head = { 10, 0, 0 },
		} },
		-- stabbed, doubled over the bar
		{ t = 0.9, ease = "out", root = { 1, 0.1, -4.9, -15, 180, 0 }, struggle = 16, pose = {
			RArm = { 60, 0, 30 },
			LArm = { 60, 0, -30 },
			Head = { -25, 0, 0 },
		} },
		{ t = 2.0, struggle = 12, pose = { Head = { -10, 15, 0 } } },
		-- lifted on the bar
		{ t = 2.6, root = { 1, 1.7, -4.8, 25, 180, 0 }, struggle = 8, pose = {
			Head = { 40, 0, 0 },
			RArm = { 20, 0, 50 },
			LArm = { 20, 0, -50 },
			RLeg = { 20, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		-- going limp
		{ t = 2.9, struggle = 2, pose = {
			Head = { 50, 10, 0 },
			RArm = { 5, 0, 20 },
			LArm = { 5, 0, -20 },
		} },
		-- dropped
		{ t = 3.1, ease = "in", struggle = 0, root = { 1.6, -2.5, -5.6, 90, 180, 0 } },
	},

	Camera = {
		{ t = 0, pos = { -5, 1.5, -9 }, look = { 0, 0.5, -1 }, fov = 65 },
		{ t = 0.6, pos = { -3.5, 0.5, -8.5 }, look = { 0.8, 0, -1 }, fov = 55 },
		{ t = 0.9, ease = "out", pos = { 5.5, 0.8, -3 }, look = { 1, 0, -4.5 }, fov = 50 },
		{ t = 2.0, pos = { 5, 0, -5.5 }, look = { 1, 0.5, -4.5 }, fov = 45 },
		{ t = 2.6, pos = { 4.5, -0.5, -7.5 }, look = { 1, 2, -4.5 }, fov = 50 },
		{ t = 3.1, pos = { 6, 3, -2 }, look = { 1, -1.5, -5 }, fov = 60 },
	},

	-- repeatFor / every = keep firing this effect for a while
	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.2, fx = "Sound", sound = "Rev" },
		{ t = 0.2, fx = "Shake", power = 0.25, repeatFor = 0.6, every = 0.15 },
		{ t = 0.9, fx = "Shake", power = 1.2 },
		{ t = 0.9, fx = "Flash", color = Color3.fromRGB(150, 0, 0), alpha = 0.4, time = 0.3 },
		{ t = 0.9, fx = "Sound", sound = "Saw" },
		{ t = 0.9, fx = "Blood", who = "Victim", part = "Torso", amount = 14 },
		{ t = 0.95, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 1.6, every = 0.1 },
		{ t = 0.95, fx = "Shake", power = 0.45, repeatFor = 1.9, every = 0.12 },
		{ t = 1.0, fx = "Darken", amount = 0.85, time = 1 },
		{ t = 3.1, fx = "Shake", power = 0.8 },
		{ t = 3.1, fx = "Blood", who = "Victim", part = "Torso", amount = 10 },
		{ t = 3.6, fx = "Eyes", on = false },
	},
}
