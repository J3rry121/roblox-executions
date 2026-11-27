-- DragBelow.luau
-- The killer yanks the victim in, spins them round and locks an arm round
-- their neck from behind, bites into it, then drives the chainsaw down into
-- their shoulder and forces them into a black pool in the floor until
-- they're gone.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Drag Below",
	Range = 10,
	Duration = 4.0,
	KillTime = 3.3,
	HideBodyOnKill = true, -- the body is under the floor, so don't leave it there

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, pose = { RArm = { 20, 0, 0 } } },
		-- arm locks round the neck, saw held out to the side
		{ t = 0.3, ease = "out", pose = {
			LArm = { 85, 0, 50 },
			RArm = { 20, 0, 30 },
			Torso = { -10, 0, 0 },
			Head = { -5, 0, 0 },
		} },
		{ t = 1.1, pose = { Head = { -15, 0, 35 }, Torso = { -15, 0, 0 } } },
		-- bite
		{ t = 1.25, ease = "out", pose = { Head = { -35, 10, 25 }, Torso = { -25, 0, 0 } } },
		{ t = 1.5, pose = { Head = { -20, 0, 30 }, Torso = { -15, 0, 0 } } },
		-- raise the saw
		{ t = 1.85, struggle = 3, pose = { RArm = { 175, 0, 10 }, Head = { 10, 0, 20 } } },
		-- drive it down into the shoulder
		{ t = 2.05, ease = "in", struggle = 6, pose = {
			RArm = { 70, 0, -15 },
			Torso = { -35, 0, 0 },
			Head = { -10, 0, 20 },
		} },
		-- push them down into the floor
		{ t = 3.0, ease = "in", root = { 0, -0.8, -0.3 }, pose = {
			Torso = { -55, 0, 0 },
			RArm = { 75, 0, -15 },
			LArm = { 75, 0, 20 },
			Head = { 20, 0, 30 },
			RLeg = { 30, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		{ t = 3.3 },
		-- stand back up and stare at the pool
		{ t = 4.0, struggle = 2, root = { 0, 0, -0.3 }, pose = {
			Torso = { 0, 0, 0 },
			RArm = { 15, 0, 0 },
			LArm = { 0, 0, 0 },
			Head = { -30, 0, 15 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0, 0, -6, 0, 180, 0 } },
		-- yanked in and spun round to face away
		{ t = 0.3, ease = "out", root = { -0.3, 0, -2.1, 0, 0, 0 }, pose = {
			RArm = { 40, 0, 40 },
			LArm = { 40, 0, -40 },
			Head = { 20, 0, 0 },
		} },
		-- pulling at the arm round their neck
		{ t = 0.5, struggle = 12, pose = {
			RArm = { 150, 0, -20 },
			LArm = { 150, 0, 20 },
			Head = { 25, 0, 0 },
		} },
		{ t = 1.1, struggle = 15 },
		-- bitten
		{ t = 1.25, ease = "out", struggle = 20, pose = { Head = { 10, 0, -50 }, RArm = { 120, 0, 30 } } },
		{ t = 1.5, struggle = 12 },
		-- saw in the shoulder: buckles
		{ t = 2.05, ease = "out", struggle = 20, root = { -0.3, -0.6, -2.2, -10, 0, 0 }, pose = {
			Head = { -20, 0, -40 },
			RArm = { 60, 0, 40 },
			LArm = { 120, 0, -20 },
			RLeg = { 20, 0, 0 },
			LLeg = { -20, 0, 0 },
		} },
		-- sinking, reaching up
		{ t = 3.0, ease = "in", struggle = 14, root = { -0.3, -4.2, -2.6, -10, 0, 0 }, pose = {
			RArm = { 175, 0, -5 },
			LArm = { 175, 0, 5 },
			Head = { 35, 0, 0 },
		} },
		-- gone
		{ t = 3.3, ease = "in", root = { -0.3, -7.5, -2.6, -10, 0, 0 } },
	},

	Camera = {
		{ t = 0, pos = { -5, 1.5, -10 }, look = { 0, 1, -2 }, fov = 62 },
		{ t = 0.3, pos = { -5.5, 2, -10 }, look = { -0.2, 1, -1.5 }, fov = 60 },
		{ t = 1.25, ease = "out", pos = { -4.5, 2.5, -8.5 }, look = { -0.2, 1.5, -1.5 }, fov = 50 },
		{ t = 2.05, ease = "out", pos = { -6.5, 1.5, -5.5 }, look = { -0.2, 0.5, -1.8 }, fov = 50 },
		{ t = 3.3, pos = { -4.5, 4, -7.5 }, look = { -0.2, -3, -2.6 }, fov = 55 },
		{ t = 4.0, pos = { -4.5, 4.5, -8 }, look = { 0, -2.5, -2.3 }, fov = 58 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.3, fx = "Shake", power = 0.5 },
		{ t = 0.3, fx = "Sound", sound = "Grab" },
		{ t = 1.25, fx = "Shake", power = 1 },
		{ t = 1.25, fx = "Flash", color = Color3.fromRGB(150, 0, 0), alpha = 0.3, time = 0.3 },
		{ t = 1.25, fx = "Sound", sound = "Bite" },
		{ t = 1.25, fx = "Sound", sound = "Scream" },
		{ t = 1.25, fx = "Blood", who = "Victim", part = "Head", amount = 12 },
		{ t = 1.7, fx = "Sound", sound = "Rev" },
		{ t = 2.05, fx = "Shake", power = 1.4 },
		{ t = 2.05, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.45, time = 0.3 },
		{ t = 2.05, fx = "Sound", sound = "Saw" },
		{ t = 2.05, fx = "Blood", who = "Victim", part = "Torso", amount = 20 },
		{ t = 2.1, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 1, every = 0.1 },
		{ t = 2.1, fx = "Shake", power = 0.4, repeatFor = 1, every = 0.12 },
		{ t = 2.0, fx = "Darken", amount = 0.9, time = 1 },
		{ t = 2.1, fx = "Pool", who = "Victim", size = 8, time = 0.8 },
		{ t = 2.3, fx = "Sound", sound = "Drag" },
		{ t = 3.3, fx = "Shake", power = 0.8 },
		{ t = 3.7, fx = "Eyes", on = false },
	},
}
