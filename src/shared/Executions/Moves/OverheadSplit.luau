-- OverheadSplit.luau
-- The killer kicks the victim in the gut so they crumple onto their knees,
-- raises the running chainsaw high over its head and brings it straight down
-- into their skull, then grinds it all the way down through their body. When
-- it rips the saw out, the body falls apart in two halves.
--
-- SplitOnKill = true makes the server cut the body in half at KillTime.
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Overhead Split",
	Range = 10,
	Duration = 4.6,
	KillTime = 3.15,
	SplitOnKill = true,

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, struggle = 2, pose = { RArm = { 20, 0, 0 } } },
		-- wind up the kick
		{ t = 0.15, pose = { LLeg = { -25, 0, 0 }, Torso = { 5, 0, 0 }, LArm = { 20, 0, -10 } } },
		-- kick to the gut
		{ t = 0.3, ease = "out", pose = { LLeg = { 75, 0, 0 }, Torso = { 12, 0, 0 }, LArm = { -25, 0, -20 } } },
		{ t = 0.6, pose = { LLeg = { 0, 0, 0 }, Torso = { 0, 0, 0 }, LArm = { 0, 0, 0 } } },
		-- raise the saw high over the head with both hands
		{ t = 1.0, struggle = 3, pose = {
			RArm = { 185, 0, -10 },
			LArm = { 180, 0, 25 },
			Torso = { 12, 0, 0 },
			Head = { 15, 0, 0 },
		} },
		-- hold it up there for a heartbeat
		{ t = 1.15, struggle = 4, pose = {
			RArm = { 195, 0, -10 },
			LArm = { 190, 0, 25 },
			Torso = { 18, 0, 0 },
			Head = { 22, 0, 0 },
		} },
		-- CHOP: straight down into the skull
		{ t = 1.3, ease = "in", struggle = 7, pose = {
			RArm = { 100, 0, -12 },
			LArm = { 95, 0, 30 },
			Torso = { -15, 0, 0 },
			Head = { -20, 0, 0 },
			RLeg = { 20, 0, 0 },
			LLeg = { -15, 0, 0 },
		} },
		-- grind it down, leaning its weight on it
		{ t = 2.0, struggle = 6, pose = { RArm = { 92, 0, -12 }, LArm = { 87, 0, 30 }, Torso = { -22, 0, 0 } } },
		{ t = 2.9, pose = {
			RArm = { 80, 0, -12 },
			LArm = { 75, 0, 30 },
			Torso = { -34, 0, 0 },
			Head = { -30, 0, 15 },
			RLeg = { 30, 0, 0 },
			LLeg = { -25, 0, 0 },
		} },
		-- rip it out
		{ t = 3.1, ease = "out", struggle = 3, pose = {
			RArm = { 130, 0, 30 },
			LArm = { 40, 0, -20 },
			Torso = { 8, 0, 0 },
			Head = { -5, 0, 0 },
			RLeg = { -15, 0, 0 },
			LLeg = { 10, 0, 0 },
		} },
		{ t = 3.5, pose = { RArm = { 40, 0, 10 }, RLeg = { 0, 0, 0 }, LLeg = { 0, 0, 0 } } },
		-- stands over the two halves, saw still running
		{ t = 4.6, struggle = 3, pose = {
			RArm = { 20, 0, 5 },
			LArm = { 0, 0, 0 },
			Torso = { -5, 0, 0 },
			Head = { -35, 0, 10 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0.55, 0, -4.5, 0, 180, 0 } },
		{ t = 0.2 },
		-- kicked in the gut: doubles over, pushed back
		{ t = 0.3, ease = "out", root = { 0.55, -0.3, -4.7, -18, 180, 0 }, pose = {
			Torso = { -10, 0, 0 },
			Head = { -15, 0, 0 },
			RArm = { 35, 0, -25 },
			LArm = { 35, 0, 25 },
			RLeg = { 10, 0, 0 },
			LLeg = { 15, 0, 0 },
		} },
		-- knees give way
		{ t = 0.42, ease = "in", root = { 0.55, -0.7, -4.5, -12, 180, 0 }, pose = {
			RLeg = { -35, 0, 5 },
			LLeg = { -40, 0, -5 },
		} },
		-- knees hit the floor
		{ t = 0.52, ease = "in", root = { 0.55, -1.05, -4.3, -8, 180, 0 }, pose = {
			RLeg = { -66, 0, 8 },
			LLeg = { -66, 0, -8 },
			Torso = { -8, 0, 0 },
			Head = { -12, 0, 0 },
			RArm = { 30, 0, -10 },
			LArm = { 30, 0, 10 },
		} },
		-- the body settles onto the knees
		{ t = 0.65, ease = "out", root = { 0.55, -0.95, -4.3, -4, 180, 0 }, pose = { Torso = { -4, 0, 0 } } },
		-- looks up at the saw
		{ t = 0.85, struggle = 3, pose = { Head = { 25, 0, 0 }, Torso = { 4, 0, 0 }, RArm = { 90, 0, 0 }, LArm = { 90, 0, 0 } } },
		-- arms up to shield the head
		{ t = 1.1, struggle = 7, pose = {
			RArm = { 160, 0, -20 },
			LArm = { 160, 0, 20 },
			Head = { 30, 0, 0 },
			Torso = { 8, 0, 0 },
		} },
		-- CHOP: arms thrown out, the whole body locks up and shakes
		{ t = 1.3, ease = "out", struggle = 22, root = { 0.55, -1.1, -4.25, 0, 180, 0 }, pose = {
			RLeg = { -70, 0, 9 },
			LLeg = { -70, 0, -9 },
			RArm = { 50, 0, 35 },
			LArm = { 50, 0, -35 },
			Head = { 5, 0, 0 },
			Torso = { 0, 0, 0 },
		} },
		{ t = 2.0, struggle = 18, root = { 0.55, -1.2, -4.25, -2, 180, 0 }, pose = {
			RArm = { 20, 0, 20 },
			LArm = { 20, 0, -20 },
			RLeg = { -74, 0, 10 },
			LLeg = { -74, 0, -10 },
		} },
		{ t = 2.9, struggle = 12, root = { 0.55, -1.3, -4.25, -3, 180, 0 }, pose = {
			RArm = { 10, 0, 14 },
			LArm = { 10, 0, -14 },
			Head = { -5, 0, 0 },
			RLeg = { -80, 0, 14 },
			LLeg = { -80, 0, -14 },
		} },
		-- saw ripped out: one last jolt, then it comes apart
		{ t = 3.1, ease = "out", struggle = 6, root = { 0.55, -1.25, -4.3, 3, 180, 0 }, pose = {
			RArm = { 25, 0, 30 },
			LArm = { 25, 0, -30 },
			Head = { 8, 0, 0 },
		} },
		{ t = 3.15, struggle = 0 },
	},

	Camera = {
		{ t = 0, pos = { 6, 1.5, -1 }, look = { 0.3, 0, -3 }, fov = 62 },
		{ t = 0.55, pos = { 6.5, 0.5, -2 }, look = { 0.5, -0.4, -3.6 }, fov = 55 },
		-- low, looking up at the raised saw
		{ t = 1.1, pos = { 4, -1.5, -8.5 }, look = { 0.3, 1.5, -2.5 }, fov = 60 },
		{ t = 1.3, ease = "out", pos = { 7, 0.3, -5.5 }, look = { 0.6, -0.1, -3.6 }, fov = 48 },
		{ t = 2.9, pos = { 6.8, -0.3, -6.8 }, look = { 0.6, -0.6, -3.8 }, fov = 44 },
		{ t = 3.1, ease = "linear", pos = { 6.7, -0.3, -6.9 }, look = { 0.6, -0.7, -3.8 }, fov = 46 },
		-- cut to the front to see it fall apart
		{ t = 3.12, ease = "linear", pos = { -6, 3, -1.5 }, look = { 0.5, -1.4, -4.4 }, fov = 55 },
		{ t = 4.6, pos = { -6.5, 4.5, -2 }, look = { 0.5, -2.2, -4.6 }, fov = 58 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.5, time = 0.5 },
		{ t = 0, fx = "Sound", sound = "Sting" },
		{ t = 0, fx = "SawLoop", on = true },
		-- kick
		{ t = 0.3, fx = "Shake", power = 0.7 },
		{ t = 0.3, fx = "Punch", amount = 4 },
		{ t = 0.3, fx = "Sound", sound = "Kick" },
		{ t = 0.3, fx = "Voice", line = "Grunt" },
		{ t = 0.52, fx = "Shake", power = 0.5 },
		{ t = 0.52, fx = "Sound", sound = "Fall", volume = 0.7 },
		{ t = 0.75, fx = "Sound", sound = "Rev" },
		{ t = 0.75, fx = "Smoke", amount = 14 },
		{ t = 0.75, fx = "Shake", power = 0.2, repeatFor = 0.5, every = 0.15 },
		{ t = 1.05, fx = "Voice", line = "Scream" },
		-- CHOP
		{ t = 1.3, fx = "HitStop", time = 0.1 },
		{ t = 1.3, fx = "Shake", power = 1.6 },
		{ t = 1.3, fx = "Punch", amount = 10 },
		{ t = 1.3, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.55, time = 0.35 },
		{ t = 1.3, fx = "Splatter", amount = 7 },
		{ t = 1.3, fx = "Sound", sound = "Saw" },
		{ t = 1.3, fx = "Sound", sound = "Snap" },
		{ t = 1.3, fx = "Sound", sound = "Gore" },
		{ t = 1.3, fx = "Blood", who = "Victim", part = "Head", amount = 24 },
		{ t = 1.3, fx = "Sparks", who = "Victim", part = "Head", amount = 30 },
		-- grinding down
		{ t = 1.35, fx = "Blood", who = "Victim", part = "Head", amount = 3, repeatFor = 1.0, every = 0.1 },
		{ t = 1.35, fx = "Shake", power = 0.45, repeatFor = 1.7, every = 0.12 },
		{ t = 1.4, fx = "Sparks", who = "Victim", part = "Head", amount = 8, repeatFor = 0.8, every = 0.2 },
		{ t = 1.45, fx = "Darken", amount = 0.9, time = 1 },
		{ t = 1.6, fx = "Voice", line = "Choke" },
		{ t = 1.8, fx = "Wound", who = "Victim", part = "Torso", side = "Front", y = 0.6, size = 0.8 },
		{ t = 1.9, fx = "Sound", sound = "Gore", volume = 0.7 },
		{ t = 2.0, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 1.1, every = 0.1 },
		{ t = 2.2, fx = "Sparks", who = "Victim", part = "Torso", amount = 10, repeatFor = 0.6, every = 0.2 },
		{ t = 2.3, fx = "Wound", who = "Victim", part = "Torso", side = "Front", y = 0, size = 0.9 },
		{ t = 2.4, fx = "Splatter", amount = 3 },
		{ t = 2.5, fx = "Sound", sound = "Saw", volume = 0.8 },
		{ t = 2.8, fx = "Wound", who = "Victim", part = "Torso", side = "Front", y = -0.6, size = 0.8 },
		-- ripped out, falls apart in two
		{ t = 3.1, fx = "HitStop", time = 0.08 },
		{ t = 3.1, fx = "Shake", power = 1.2 },
		{ t = 3.1, fx = "Punch", amount = 7 },
		{ t = 3.1, fx = "Flash", color = Color3.fromRGB(170, 0, 0), alpha = 0.45, time = 0.3 },
		{ t = 3.1, fx = "Sound", sound = "Rip" },
		{ t = 3.15, fx = "Sound", sound = "Gore" },
		{ t = 3.15, fx = "Blood", who = "Victim", part = "Torso", amount = 30 },
		{ t = 3.15, fx = "Gibs", who = "Victim", part = "Torso", amount = 10 },
		{ t = 3.15, fx = "Splatter", amount = 6 },
		{ t = 3.6, fx = "Sound", sound = "Fall" },
		{ t = 3.6, fx = "Shake", power = 0.4 },
		{ t = 3.7, fx = "Pool", who = "Victim", size = 7, time = 1.2 },
		{ t = 3.9, fx = "Sound", sound = "Rev", volume = 0.7 },
		{ t = 3.9, fx = "Smoke", amount = 10 },
		{ t = 4.3, fx = "Eyes", on = false },
	},
}
