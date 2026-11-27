-- ThroatLift.luau
-- The killer grabs the victim by the throat and lifts them off the floor.
-- While they kick, it rams the chainsaw into their gut, rips it out, hoists
-- the body up and slams it down on its back so hard the floor splatters.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Throat Lift",
	Range = 10,
	Duration = 4.0,
	KillTime = 2.8,

	Killer = {
		{ t = 0, root = { 0, 0, 0 }, pose = { RArm = { 20, 0, 0 } } },
		-- reach out with the free hand and grab the throat
		{ t = 0.2, ease = "out", pose = {
			LArm = { 95, 0, 12 },
			Torso = { -10, 0, 0 },
			Head = { -10, 0, 0 },
		} },
		-- lift
		{ t = 0.9, pose = {
			LArm = { 125, 0, 18 },
			RArm = { 15, 0, 10 },
			Torso = { 0, 0, 0 },
			Head = { 15, 0, 0 },
			RLeg = { 10, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		-- creepy head tilt while they struggle, saw pulled back
		{ t = 1.7, pose = { Head = { 15, 0, 20 }, RArm = { 30, 0, 30 } } },
		-- SAW into the gut
		{ t = 1.97, ease = "back", struggle = 6, pose = { RArm = { 85, 0, -40 }, Torso = { 0, -15, 0 } } },
		-- grind, then pull it out and hoist the body up
		{ t = 2.35, pose = { Torso = { 0, -10, 0 } } },
		{ t = 2.5, ease = "out", struggle = 1, pose = {
			RArm = { 30, 0, 25 },
			LArm = { 140, 0, 15 },
			Torso = { 10, 0, 0 },
			Head = { 20, 0, 0 },
		} },
		-- SLAM it down
		{ t = 2.8, ease = "in", root = { 0, -0.8, -1.6 }, pose = {
			LArm = { 80, 0, 10 },
			RArm = { 40, 0, 20 },
			Torso = { -50, 0, 0 },
			Head = { 30, 0, 0 },
			RLeg = { 40, 0, 0 },
			LLeg = { -20, 0, 0 },
		} },
		{ t = 3.2, pose = { Head = { 35, 0, -25 } } },
		-- stand back up, looking down at the body
		{ t = 4.0, root = { 0, 0, -1.6 }, pose = {
			RArm = { 15, 0, 0 },
			LArm = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -30, 0, -10 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
	},

	Victim = {
		{ t = 0, root = { -1, 0, -5.5, 0, 180, 0 } },
		-- yanked in by the throat
		{ t = 0.2, ease = "out", root = { -1, 0, -2.2, 5, 180, 0 }, pose = {
			Head = { 20, 0, 0 },
			RArm = { 40, 0, 20 },
			LArm = { 40, 0, -20 },
		} },
		-- lifted, clawing at the killer's arm, legs kicking
		{ t = 0.9, root = { -1, 0.5, -1.9, 8, 180, 0 }, struggle = 12, pose = {
			Head = { 35, 0, 0 },
			RArm = { 150, 0, -15 },
			LArm = { 150, 0, 15 },
			RLeg = { 20, 0, 0 },
			LLeg = { -15, 0, 0 },
		} },
		{ t = 1.7, struggle = 16, pose = { Head = { 30, 10, 0 } } },
		{ t = 1.85, struggle = 6, pose = { Head = { 25, 0, 0 } } },
		-- saw in the gut: doubled up, shaking
		{ t = 1.97, ease = "out", struggle = 20, pose = {
			Head = { -30, 0, 0 },
			RArm = { 60, 0, -10 },
			LArm = { 50, 0, 10 },
			RLeg = { 40, 0, 0 },
			LLeg = { 30, 0, 0 },
		} },
		{ t = 2.35, struggle = 10, pose = { Head = { -40, 20, 0 } } },
		-- hoisted, limp
		{ t = 2.5, ease = "out", struggle = 0, root = { -1, 0.9, -1.5, 15, 180, 0 }, pose = {
			Head = { -50, 40, 10 },
			RArm = { 10, 0, 10 },
			LArm = { 10, 0, -10 },
			RLeg = { 5, 0, 0 },
			LLeg = { -5, 0, 0 },
		} },
		-- slammed flat on the back
		{ t = 2.8, ease = "in", root = { -1, -2.5, -1.9, 90, 180, 0 }, pose = {
			Head = { 20, 40, 0 },
			RArm = { 90, 0, 60 },
			LArm = { 90, 0, -60 },
			RLeg = { 15, 0, 10 },
			LLeg = { 10, 0, -10 },
		} },
	},

	Camera = {
		{ t = 0, pos = { -6, 1.5, 2 }, look = { -0.5, 0.5, -3 }, fov = 65 },
		{ t = 0.25, ease = "out", pos = { -6.5, 1, 0 }, look = { -0.8, 1, -1.5 }, fov = 58 },
		{ t = 1.7, pos = { -6.5, 0, -3.5 }, look = { -0.9, 1.6, -1.6 }, fov = 48 },
		{ t = 1.97, ease = "out", pos = { -5.5, 2.5, -3 }, look = { -1, 1.8, -1.8 }, fov = 42 },
		{ t = 2.45, pos = { -6.5, 1.5, -4.5 }, look = { -0.8, 1, -1.5 }, fov = 50 },
		{ t = 2.8, ease = "in", pos = { -6, 2, -5.5 }, look = { -0.8, -1.8, -2.4 }, fov = 52 },
		{ t = 4.0, pos = { -6, 4, -6 }, look = { -0.5, -2, -2.5 }, fov = 58 },
	},

	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.4, time = 0.4 },
		{ t = 0, fx = "Sound", sound = "Sting" },
		{ t = 0.2, fx = "Shake", power = 0.5 },
		{ t = 0.2, fx = "Sound", sound = "Grab" },
		{ t = 0.9, fx = "Darken", amount = 0.75, time = 1 },
		{ t = 1.97, fx = "Shake", power = 1.4 },
		{ t = 1.97, fx = "Flash", color = Color3.fromRGB(160, 0, 0), alpha = 0.4, time = 0.3 },
		{ t = 1.97, fx = "Sound", sound = "Saw" },
		{ t = 1.97, fx = "Sound", sound = "Scream" },
		{ t = 1.97, fx = "Blood", who = "Victim", part = "Torso", amount = 18 },
		{ t = 2.0, fx = "Blood", who = "Victim", part = "Torso", amount = 3, repeatFor = 0.5, every = 0.1 },
		{ t = 2.0, fx = "Shake", power = 0.5, repeatFor = 0.4, every = 0.12 },
		{ t = 2.8, fx = "Shake", power = 1.8 },
		{ t = 2.8, fx = "Flash", color = Color3.fromRGB(160, 0, 0), alpha = 0.5, time = 0.35 },
		{ t = 2.8, fx = "Sound", sound = "Stomp" },
		{ t = 2.8, fx = "Blood", who = "Victim", part = "Head", amount = 22 },
		{ t = 2.8, fx = "Blood", who = "Victim", part = "Torso", amount = 14 },
		{ t = 3.5, fx = "Eyes", on = false },
	},
}
