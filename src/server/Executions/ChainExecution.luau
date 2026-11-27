-- ChainExecution.luau
-- Starter "chain" execution:
--   1. Both characters freeze, victim is placed in front of the killer
--   2. Two chains shoot out from the killer's hands and hook the victim
--   3. The victim is yanked up into the air
--   4. The victim is slammed into the ground and dies
--   5. Chains pull back and the killer can move again
--
-- Tweak the numbers in TIMING to change the feel.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local ChainBuilder = require(ReplicatedStorage.Shared.Executions.ChainBuilder)

local TIMING = {
	ChainShoot = 0.25, -- chains fly out
	HookPause = 0.3, -- beat after the hook lands
	Lift = 0.5, -- victim gets yanked up
	HangPause = 0.35, -- hang in the air for a moment
	Slam = 0.15, -- slam down
	AfterSlam = 0.6, -- let the hit land before cleaning up
	ChainRetract = 0.3, -- chains pull back
}

local ChainExecution = {}

-- Runs `step(alpha)` every frame for `duration` seconds, alpha goes 0 -> 1.
-- Yields until finished.
local function animate(duration: number, step: (number) -> ())
	local elapsed = 0
	while elapsed < duration do
		elapsed += RunService.Heartbeat:Wait()
		step(math.min(elapsed / duration, 1))
	end
end

local function easeOut(t: number): number
	return 1 - (1 - t) ^ 3
end

local function easeIn(t: number): number
	return t ^ 3
end

-- R15 has RightHand, R6 has "Right Arm". Fall back to the root part.
local function findPart(character: Model, names: { string }): BasePart
	for _, name in names do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return character:FindFirstChild("HumanoidRootPart") :: BasePart
end

-- fireFx(name, killer, victim) tells clients to play effects (camera shake etc.)
function ChainExecution.Run(killer: Model, victim: Model, fireFx: (string, Model, Model) -> ())
	local killerRoot = killer:FindFirstChild("HumanoidRootPart") :: BasePart
	local victimRoot = victim:FindFirstChild("HumanoidRootPart") :: BasePart
	local victimHumanoid = victim:FindFirstChildOfClass("Humanoid") :: Humanoid

	local rightHand = findPart(killer, { "RightHand", "Right Arm" })
	local leftHand = findPart(killer, { "LeftHand", "Left Arm" })
	local victimTorso = findPart(victim, { "UpperTorso", "Torso" })

	local chains = {}

	-- 1. Freeze both and line them up
	killerRoot.Anchored = true
	victimRoot.Anchored = true

	local groundY = victimRoot.Position.Y
	local frontPos = (killerRoot.CFrame * CFrame.new(0, 0, -7)).Position
	frontPos = Vector3.new(frontPos.X, groundY, frontPos.Z)
	local lookAtKiller = Vector3.new(killerRoot.Position.X, groundY, killerRoot.Position.Z)
	victimRoot.CFrame = CFrame.lookAt(frontPos, lookAtKiller)

	fireFx("Start", killer, victim)

	-- 2. Chains shoot out and hook the victim
	table.insert(chains, ChainBuilder.new(rightHand, victimTorso))
	table.insert(chains, ChainBuilder.new(leftHand, victimTorso))
	animate(TIMING.ChainShoot, function(t)
		for _, chain in chains do
			chain:SetReach(easeOut(t))
		end
	end)
	fireFx("Hook", killer, victim)
	task.wait(TIMING.HookPause)

	-- 3. Yank the victim up and closer
	local startCF = victimRoot.CFrame
	local liftPos = (killerRoot.CFrame * CFrame.new(0, 6, -4.5)).Position
	local liftCF = CFrame.lookAt(liftPos, killerRoot.Position)
	animate(TIMING.Lift, function(t)
		victimRoot.CFrame = startCF:Lerp(liftCF, easeOut(t))
	end)
	task.wait(TIMING.HangPause)

	-- 4. Slam them down onto their back
	local slamPos = Vector3.new(liftPos.X, groundY - 1.5, liftPos.Z)
	local slamCF = CFrame.lookAt(slamPos, Vector3.new(killerRoot.Position.X, slamPos.Y, killerRoot.Position.Z))
		* CFrame.Angles(math.rad(80), 0, 0)
	animate(TIMING.Slam, function(t)
		victimRoot.CFrame = liftCF:Lerp(slamCF, easeIn(t))
	end)
	fireFx("Slam", killer, victim)

	victimHumanoid.Health = 0
	victimRoot.Anchored = false -- let the body fall apart naturally

	task.wait(TIMING.AfterSlam)

	-- 5. Pull the chains back in and clean up
	animate(TIMING.ChainRetract, function(t)
		for _, chain in chains do
			chain:SetReach(1 - t)
		end
	end)
	for _, chain in chains do
		chain:Destroy()
	end

	killerRoot.Anchored = false
end

return ChainExecution
