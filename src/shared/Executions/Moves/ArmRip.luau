-- ArmRip.luau
-- The killer grabs the victim's arm, plants its feet and tears it clean off.
-- While the victim staggers, clutching the stump, it revs the saw and takes
-- their head off with one sideways swing.
--
-- ServerEvents tear real body parts off (everyone sees them fall).
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Arm Rip",
	Range = 10,
	Duration = 3.8,
	KillTime = 2.6,

	ServerEvents = {
		{ t = 1.3, action = "Detach", joint = "RArm" },
		{ t = 2.55, action = "Detach", joint = "Head" },
	},

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, struggle = 2, pose = { RArm = { 20, 0, 0 } } },
		-- grab their arm
		{ t = 0.3, ease = "out", pose = { LArm = { 90, 0, 0 }, Torso = { -5, 0, 0 }, Head = { -10, 0, 0 } } },
		-- plant and pull
		{ t = 1.2, pose = {
			LArm = { 75, 0, -35 },
			Torso = { 15, 25, 0 },
			Head = { 0, 20, 0 },
			RLeg = { -20, 0, 0 },
			LLeg = { 20, 0, 0 },
		} },
		-- RIP
		{ t = 1.3, ease = "out", pose = { LArm = { 60, 0, -95 }, Torso = { 20, 35, 0 } } },
		-- toss it, wind the saw back
		{ t = 1.75, pose = {
			LArm = { 10, 0, -40 },
			RArm = { 105, 0, 85 },
			Torso = { 0, -40, 0 },
			Head = { -5, 0, 0 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
		{ t = 2.35, struggle = 4 },
		-- one swing through the neck
		{ t = 2.55, ease = "in", struggle = 2, pose = { RArm = { 105, 0, -60 }, Torso = { 0, 35, 0 }, LArm = { 20, 0, -60 } } },
		{ t = 3.0, pose = { RArm = { 70, 0, -40 } } },
		{ t = 3.8, pose = {
			RArm = { 15, 0, 0 },
			LArm = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -30, 0, 0 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0, 0, -3.6, 0, 180, 0 } },
		-- arm grabbed and yanked out straight
		{ t = 0.3, ease = "out", root = { 0, 0, -3.2, -10, 180, 0 }, struggle = 6, pose = {
			RArm = { 95, 0, 0 },
			LArm = { 40, 0, -20 },
			Head = { 10, 0, 0 },
		} },
		-- pulled off balance, pushing back
		{ t = 1.2, root = { 0, 0, -3.0, -20, 170, 0 }, struggle = 14, pose = {
			RArm = { 100, 0, -15 },
			LArm = { 80, 0, 40 },
			Head = { 30, -20, 0 },
		} },
		-- RIP: thrown back, clutching the stump
		{ t = 1.3, ease = "out", root = { 0, 0, -3.5, 12, 190, 0 }, struggle = 20, pose = {
			LArm = { 80, 0, 75 },
			Head = { 35, 20, 0 },
			RLeg = { 15, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		{ t = 2.0, struggle = 12, root = { 0, 0, -3.4, 5, 185, 0 }, pose = { Head = { 15, 0, 0 } } },
		{ t = 2.55, struggle = 0 },
	},

	Camera = {
		{ t = 0, pos = { -7, 1.5, -0.5 }, look = { -0.5, 0.5, -2.5 }, fov = 60 },
		{ t = 1.2, pos = { -6.5, 1, -4.5 }, look = { -0.8, 0.5, -2 }, fov = 50 },
		{ t = 1.3, ease = "out", pos = { -6.5, 1.5, -5 }, look = { -0.8, 0.5, -2.2 }, fov = 46 },
		{ t = 2.3, pos = { -6.5, 1.5, -6.5 }, look = { 0, 0.8, -3 }, fov = 52 },
		{ t = 2.6, ease = "out", pos = { -7, 2.5, -7 }, look = { 0, 0, -3.2 }, fov = 56 },
		{ t = 3.8, pos = { -7, 4, -7.5 }, look = { 0, -1.5, -3.5 }, fov = 58 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0.3, fx = "Shake", power = 0.5 },
		{ t = 0.3, fx = "Sound", sound = "Grab" },
		{ t = 0.6, fx = "Shake", power = 0.2, repeatFor = 0.6, every = 0.15 },
		{ t = 1.3, fx = "Shake", power = 1.4 },
		{ t = 1.3, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.5, time = 0.35 },
		{ t = 1.3, fx = "Sound", sound = "Rip" },
		{ t = 1.3, fx = "Sound", sound = "Scream" },
		{ t = 1.3, fx = "Blood", who = "Victim", part = "Torso", amount = 22 },
		{ t = 1.35, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 1.2, every = 0.1 },
		{ t = 1.4, fx = "Darken", amount = 0.85, time = 0.8 },
		{ t = 1.8, fx = "Sound", sound = "Rev" },
		{ t = 2.55, fx = "Shake", power = 1.5 },
		{ t = 2.55, fx = "Sound", sound = "Slash" },
		{ t = 2.55, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.55, time = 0.35 },
		{ t = 2.55, fx = "Blood", who = "Victim", part = "Torso", amount = 26 },
		{ t = 2.6, fx = "Blood", who = "Victim", part = "Torso", amount = 4, repeatFor = 0.8, every = 0.1 },
		{ t = 3.4, fx = "Eyes", on = false },
	},
}
