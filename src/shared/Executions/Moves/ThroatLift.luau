-- ThroatLift.luau
-- The killer drags the victim in by the throat, lifts them off the floor,
-- lets them kick for a moment, snaps their neck with the other hand and
-- throws the body aside.
--
-- How to read this file: see the notes at the top of Kit.luau.

return {
	DisplayName = "Throat Lift",
	Range = 10, -- how close (studs) the killer must be to start it
	Duration = 3.6, -- total length in seconds
	KillTime = 2.85, -- when the victim actually dies

	Killer = {
		{ t = 0, root = { 0, 0, 0 } },
		{ t = 0.2, ease = "out", pose = {
			RArm = { 95, 0, -10 },
			Torso = { -10, 0, 0 },
			Head = { -10, 0, 0 },
		} },
		-- lift
		{ t = 0.9, pose = {
			RArm = { 140, 0, -20 },
			LArm = { -15, 0, -10 },
			Torso = { 8, 0, 0 },
			Head = { 15, 0, 0 },
			RLeg = { 10, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		-- creepy head tilt while they struggle
		{ t = 1.9, pose = { Head = { 15, 0, -15 } } },
		-- other hand reaches for the head
		{ t = 2.0, ease = "out", pose = { LArm = { 150, 0, 30 } } },
		-- SNAP
		{ t = 2.12, ease = "out", pose = {
			LArm = { 150, -20, 50 },
			Torso = { 5, -15, 0 },
		} },
		{ t = 2.6, pose = { LArm = { 20, 0, 0 }, Torso = { 5, 0, 0 } } },
		-- throw the body to the right
		{ t = 2.85, ease = "in", pose = {
			RArm = { 100, 0, 40 },
			Torso = { 0, -25, 0 },
		} },
		-- back to standing, looking down at the body
		{ t = 3.6, pose = {
			RArm = { 0, 0, 0 },
			LArm = { 0, 0, 0 },
			Torso = { 0, 0, 0 },
			Head = { -15, -20, 0 },
			RLeg = { 0, 0, 0 },
			LLeg = { 0, 0, 0 },
		} },
	},

	Victim = {
		{ t = 0, root = { 0, 0, -6, 0, 180, 0 } },
		-- yanked in
		{ t = 0.2, ease = "out", root = { 0.6, 0.2, -2.6, 5, 180, 0 }, pose = {
			Head = { 20, 0, 0 },
			RArm = { 40, 0, 20 },
			LArm = { 40, 0, -20 },
		} },
		-- lifted off the floor, clawing at the killer's arm
		{ t = 0.9, root = { 0.9, 1.1, -2.1, 8, 180, 0 }, struggle = 10, pose = {
			Head = { 35, 0, 0 },
			RArm = { 150, 0, -15 },
			LArm = { 150, 0, 15 },
			RLeg = { 15, 0, 0 },
			LLeg = { -10, 0, 0 },
		} },
		{ t = 1.9, struggle = 14, pose = { Head = { 30, 10, 0 } } },
		{ t = 2.0, struggle = 6, pose = { Head = { 25, 0, 0 } } },
		-- SNAP
		{ t = 2.12, ease = "out", struggle = 0, pose = {
			Head = { -20, 115, 0 },
			RArm = { 60, 0, 0 },
			LArm = { 50, 0, 0 },
		} },
		-- limp
		{ t = 2.6, root = { 0.9, 1.0, -2.1, 12, 180, 0 }, pose = {
			Head = { -45, 115, 10 },
			RArm = { 5, 0, 5 },
			LArm = { 5, 0, -5 },
			RLeg = { 5, 0, 0 },
			LLeg = { -3, 0, 0 },
		} },
		-- thrown
		{ t = 2.85, ease = "in", root = { 5, -1, -3.5, 50, 230, 30 } },
	},

	-- pos = where the camera is, look = what it looks at (same x/y/z as above)
	Camera = {
		{ t = 0, pos = { 5, 1.5, 2 }, look = { 0, 1, -4 }, fov = 70 },
		{ t = 0.25, ease = "out", pos = { 4.5, 1, 0.5 }, look = { 0.5, 1.5, -2.5 }, fov = 60 },
		{ t = 1.9, pos = { 5.5, 0.5, -3.5 }, look = { 0.7, 2.2, -2.2 }, fov = 45 },
		{ t = 2.12, ease = "out", pos = { 3.5, 2.5, -1.5 }, look = { 0.9, 2.6, -2.1 }, fov = 40 },
		{ t = 3.0, pos = { 7, 4, 1 }, look = { 3, -1, -3 }, fov = 60 },
	},

	-- Effects that fire at a moment in time. See client/Executions/Effects.luau
	Events = {
		{ t = 0, fx = "Eyes", on = true },
		{ t = 0, fx = "Darken", amount = 0.4, time = 0.4 },
		{ t = 0, fx = "Sound", sound = "Sting" },
		{ t = 0.2, fx = "Shake", power = 0.5 },
		{ t = 0.2, fx = "Sound", sound = "Grab" },
		{ t = 0.9, fx = "Darken", amount = 0.7, time = 1 },
		{ t = 2.12, fx = "Shake", power = 1.4 },
		{ t = 2.12, fx = "Flash", color = Color3.fromRGB(255, 255, 255), alpha = 0.25, time = 0.25 },
		{ t = 2.12, fx = "Sound", sound = "Snap" },
		{ t = 2.12, fx = "Blood", who = "Victim", part = "Head", amount = 8 },
		{ t = 2.85, fx = "Shake", power = 0.6 },
		{ t = 3.3, fx = "Eyes", on = false },
	},
}
