-- ChestCarve.luau
-- Face to face. The killer carves two slashes across the victim's chest,
-- then rams the whole chainsaw into it. The victim drops to their knees on
-- the bar, trembling, until the saw is ripped out and they fall on their face.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Chest Carve",
	Range = 10,
	Duration = 5.4,
	KillTime = 4.6,

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, struggle = 2, pose = { RArm = { 20, 0, 0 } } },
		-- wind up slash 1 (up and out to the right)
		{ t = 0.5, struggle = 3, pose = {
			RArm = { 150, 0, 45 },
			LArm = { 20, 0, -20 },
			Torso = { 0, 30, 0 },
			Head = { -10, 0, 0 },
		} },
		-- slash 1, down across the chest
		{ t = 0.75, ease = "in", pose = { RArm = { 60, 0, -40 }, Torso = { -10, -25, 0 } } },
		-- wind up slash 2 (up on the left side)
		{ t = 1.15, ease = "out", pose = { RArm = { 150, 0, -35 }, Torso = { 0, -30, 0 } } },
		-- slash 2, the other way
		{ t = 1.4, ease = "in", pose = { RArm = { 60, 0, 40 }, Torso = { -10, 25, 0 } } },
		-- pull back for the thrust
		{ t = 1.9, pose = {
			RArm = { 45, 0, 0 },
			LArm = { 40, 0, -25 },
			Torso = { 5, 0, 0 },
			Head = { 0, 0, 0 },
		} },
		-- THRUST: the whole bar goes in
		{ t = 2.15, ease = "back", root = { 0, 0, -0.8 }, struggle = 6, pose = {
			RArm = { 90, 0, -10 },
			LArm = { 85, 0, -35 },
			Torso = { 0, 0, 0 },
			RLeg = { 25, 0, 0 },
			LLeg = { -25, 0, 0 },
		} },
		-- push down as they sink to their knees
		{ t = 3.0, struggle = 5, pose = {
			RArm = { 65, 0, -10 },
			LArm = { 60, 0, -30 },
			Torso = { -10, 0, 0 },
			Head = { -25, 0, 15 },
			RLeg = { 15, 0, 0 },
			LLeg = { -15, 0, 0 },
		} },
		{ t = 4.0, pose = { Head = { -30, 0, -15 } } },
		-- rip it out
		{ t = 4.3, ease = "out", root = { 0, 0, -0.3 }, struggle = 2, pose = {
			RArm = { 40, 0, 30 },
			LArm = { 10, 0, -10 },
			Torso = { 5, -15, 0 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
		{ t = 5.4, pose = {
			RArm = { 15, 0, 0 },
			LArm = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -35, 0, 0 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0.9, 0, -4, 0, 180, 0 } },
		-- hands up, frozen in fear
		{ t = 0.4, pose = { RArm = { 120, 0, -15 }, LArm = { 120, 0, 15 }, Head = { -10, 0, 0 } } },
		-- slash 1 hits
		{ t = 0.75, ease = "out", root = { 0.9, 0, -4.2, 12, 170, 0 }, struggle = 6, pose = {
			Head = { 25, -30, 0 },
			RArm = { 40, 0, 50 },
			LArm = { 60, 0, -40 },
		} },
		{ t = 1.15, struggle = 4, root = { 0.9, 0, -4.2, 5, 180, 0 }, pose = { Head = { 0, 0, 0 }, RArm = { 70, 0, -20 }, LArm = { 70, 0, 20 } } },
		-- slash 2 hits
		{ t = 1.4, ease = "out", root = { 0.9, 0, -4.3, 14, 190, 0 }, struggle = 8, pose = {
			Head = { 25, 30, 0 },
			RArm = { 60, 0, 40 },
			LArm = { 40, 0, -50 },
		} },
		{ t = 1.9, struggle = 5, root = { 0.9, 0, -4.2, 5, 180, 0 }, pose = { Head = { -15, 0, 0 }, RArm = { 50, 0, -10 }, LArm = { 50, 0, 10 } } },
		-- impaled, folded over the bar
		{ t = 2.15, ease = "out", root = { 0.9, 0, -4.7, -10, 180, 0 }, struggle = 16, pose = {
			Head = { -35, 0, 0 },
			RArm = { 80, 0, -25 },
			LArm = { 80, 0, 25 },
		} },
		-- sinks to the knees, trembling, hands on the bar
		{ t = 3.0, root = { 0.9, -1.5, -4.5, -5, 180, 0 }, struggle = 10, pose = {
			RLeg = { -90, 0, 0 },
			LLeg = { -90, 0, 0 },
			RArm = { 70, 0, -20 },
			LArm = { 70, 0, 20 },
			Head = { -30, 0, 0 },
		} },
		{ t = 4.0, struggle = 12, pose = { Head = { -40, 15, 0 } } },
		-- saw ripped out
		{ t = 4.3, ease = "out", struggle = 4, root = { 0.9, -1.5, -4.6, 15, 180, 0 }, pose = {
			Head = { 30, 0, 0 },
			RArm = { 30, 0, 30 },
			LArm = { 30, 0, -30 },
		} },
		-- falls on their face
		{ t = 4.6, ease = "in", struggle = 0, root = { 0.9, -2.5, -3.5, -90, 180, 0 }, pose = {
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
			RArm = { 10, 0, 10 },
			LArm = { 10, 0, -10 },
			Head = { 10, 30, 0 },
		} },
	},

	Camera = {
		{ t = 0, pos = { 7, 1.5, -1 }, look = { 0.5, 0.5, -2.5 }, fov = 60 },
		{ t = 0.75, pos = { 7.5, 1, -2.5 }, look = { 0.6, 0.8, -3 }, fov = 55 },
		{ t = 1.9, pos = { 7, 0.8, -2.5 }, look = { 0.8, 0.5, -3.5 }, fov = 50 },
		{ t = 2.15, ease = "out", pos = { 6.5, 0.5, -3 }, look = { 0.8, 0.3, -3.8 }, fov = 45 },
		{ t = 3.0, pos = { 6.5, -0.5, -7 }, look = { 0.9, -1, -4.3 }, fov = 48 },
		{ t = 4.0, pos = { 5, -1, -8.5 }, look = { 0.9, -1, -4.5 }, fov = 45 },
		{ t = 4.6, pos = { 4.5, 3, -9 }, look = { 0.9, -2, -3.5 }, fov = 58 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.1, fx = "Sound", sound = "Rev" },
		{ t = 0.75, fx = "Sound", sound = "Slash" },
		{ t = 0.75, fx = "Shake", power = 0.8 },
		{ t = 0.75, fx = "Flash", color = Color3.fromRGB(150, 0, 0), alpha = 0.3, time = 0.25 },
		{ t = 0.75, fx = "Blood", who = "Victim", part = "Torso", amount = 14 },
		{ t = 1.4, fx = "Sound", sound = "Slash" },
		{ t = 1.4, fx = "Shake", power = 0.9 },
		{ t = 1.4, fx = "Flash", color = Color3.fromRGB(150, 0, 0), alpha = 0.35, time = 0.25 },
		{ t = 1.4, fx = "Blood", who = "Victim", part = "Torso", amount = 16 },
		{ t = 2.15, fx = "Shake", power = 1.4 },
		{ t = 2.15, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.5, time = 0.35 },
		{ t = 2.15, fx = "Sound", sound = "Saw" },
		{ t = 2.15, fx = "Sound", sound = "Scream" },
		{ t = 2.15, fx = "Blood", who = "Victim", part = "Torso", amount = 20 },
		{ t = 2.2, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 2.1, every = 0.1 },
		{ t = 2.2, fx = "Shake", power = 0.4, repeatFor = 2.1, every = 0.12 },
		{ t = 2.3, fx = "Darken", amount = 0.9, time = 1.2 },
		{ t = 4.3, fx = "Blood", who = "Victim", part = "Torso", amount = 16 },
		{ t = 4.3, fx = "Shake", power = 0.8 },
		{ t = 4.6, fx = "Shake", power = 0.6 },
		{ t = 5.0, fx = "Eyes", on = false },
	},
}
