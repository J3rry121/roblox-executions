-- DragBelow.luau
-- The killer yanks the victim in, spins them round and wraps them up from
-- behind, bites into their neck, then forces them down into a black pool
-- in the floor until they're gone.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Drag Below",
	Range = 10,
	Duration = 3.6,
	KillTime = 3.0,
	HideBodyOnKill = true, -- the body is under the floor, so don't leave it there

	Killer = {
		{ t = 0, root = { 0, 0, 0 } },
		-- arms wrap round the victim
		{ t = 0.3, ease = "out", pose = {
			RArm = { 80, 0, -35 },
			LArm = { 80, 0, 35 },
			Torso = { -10, 0, 0 },
			Head = { -5, 0, 0 },
		} },
		{ t = 1.2, pose = { Head = { -15, 0, 35 }, Torso = { -15, 0, 0 } } },
		-- bite
		{ t = 1.35, ease = "out", pose = { Head = { -35, 10, 25 }, Torso = { -25, 0, 0 } } },
		{ t = 1.6, pose = { Head = { -20, 0, 30 }, Torso = { -20, 0, 0 } } },
		-- push them down
		{ t = 2.6, ease = "in", root = { 0, -0.6, -0.3 }, pose = {
			Torso = { -50, 0, 0 },
			RArm = { 70, 0, -15 },
			LArm = { 70, 0, 15 },
			Head = { 20, 0, 30 },
		} },
		{ t = 3.0 },
		-- stand back up and stare at the pool
		{ t = 3.6, root = { 0, 0, -0.3 }, pose = {
			Torso = { 0, 0, 0 },
			RArm = { 0, 0, 0 },
			LArm = { 0, 0, 0 },
			Head = { -30, 0, 15 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0, 0, -6, 0, 180, 0 } },
		-- yanked in and spun round to face away
		{ t = 0.3, ease = "out", root = { 0, 0, -2, 0, 0, 0 }, pose = {
			RArm = { 40, 0, 40 },
			LArm = { 40, 0, -40 },
			Head = { 20, 0, 0 },
		} },
		-- pulling at the killer's arms
		{ t = 0.5, struggle = 12, pose = {
			RArm = { 80, 0, -30 },
			LArm = { 80, 0, 30 },
			Head = { 10, 0, 0 },
		} },
		{ t = 1.2, struggle = 15 },
		-- bitten
		{ t = 1.35, ease = "out", struggle = 20, pose = {
			Head = { -10, 0, -50 },
			RArm = { 150, 0, 10 },
		} },
		{ t = 1.6, struggle = 10, root = { 0, -0.3, -2.1, 0, 0, 0 } },
		-- sinking, reaching up
		{ t = 2.6, ease = "in", struggle = 14, root = { 0, -4.2, -2.6, -10, 0, 0 }, pose = {
			RArm = { 175, 0, -5 },
			LArm = { 175, 0, 5 },
			Head = { 35, 0, 0 },
		} },
		-- gone
		{ t = 3.0, ease = "in", root = { 0, -7.5, -2.6, -10, 0, 0 } },
	},

	Camera = {
		{ t = 0, pos = { -4, 1.5, -10 }, look = { 0, 1, -2 }, fov = 65 },
		{ t = 0.3, pos = { -2.5, 1.5, -7 }, look = { 0, 1.5, -2 }, fov = 55 },
		{ t = 1.35, ease = "out", pos = { -1.5, 2, -4.6 }, look = { 0, 2, -1.8 }, fov = 40 },
		{ t = 2.0, pos = { -3, 0.5, -7 }, look = { 0, 0, -2.3 }, fov = 50 },
		{ t = 3.0, pos = { -2.5, 3.5, -6.5 }, look = { 0, -3, -2.6 }, fov = 55 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.3, fx = "Shake", power = 0.5 },
		{ t = 0.3, fx = "Sound", sound = "Grab" },
		{ t = 1.35, fx = "Shake", power = 1 },
		{ t = 1.35, fx = "Flash", color = Color3.fromRGB(150, 0, 0), alpha = 0.3, time = 0.3 },
		{ t = 1.35, fx = "Sound", sound = "Bite" },
		{ t = 1.35, fx = "Blood", who = "Victim", part = "Head", amount = 10 },
		{ t = 1.6, fx = "Darken", amount = 0.9, time = 1.2 },
		{ t = 1.7, fx = "Pool", who = "Victim", size = 7, time = 0.8 },
		{ t = 1.8, fx = "Sound", sound = "Drag" },
		{ t = 3.0, fx = "Shake", power = 0.8 },
		{ t = 3.3, fx = "Eyes", on = false },
	},
}
