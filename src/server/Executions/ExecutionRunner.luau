-- ExecutionRunner.luau
-- Runs one execution from start to finish on the server: freezes both
-- bodies, tells every player to play the animation, tears off limbs when the
-- move says so, kills the victim at KillTime and frees the killer at the end.
-- Used by ExecutionService (key presses) and KillerNPC (the killer AI).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Kit = require(Shared.Executions.Kit)

local Runner = {}

Runner.BUSY = "InExecution" -- attribute set on characters while busy

-- RemoteEvents (made once, the first time this module is required)
local remotes = ReplicatedStorage:FindFirstChild("Remotes")
if not remotes then
	remotes = Instance.new("Folder")
	remotes.Name = "Remotes"
	remotes.Parent = ReplicatedStorage
end
local function remote(name: string): RemoteEvent
	local existing = remotes:FindFirstChild(name)
	if existing then
		return existing
	end
	local event = Instance.new("RemoteEvent")
	event.Name = name
	event.Parent = remotes
	return event
end
Runner.RequestExecution = remote("RequestExecution")
local playExecution = remote("PlayExecution")

function Runner.isAlive(character: Model?): boolean
	if not character or not character.Parent then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return humanoid ~= nil and root ~= nil and humanoid.Health > 0
end

function Runner.isFree(character: Model?): boolean
	return Runner.isAlive(character) and not character:GetAttribute(Runner.BUSY)
end

-- The killer's position, but standing straight (no tilt)
local function flatten(cframe: CFrame): CFrame
	local look = Vector3.new(cframe.LookVector.X, 0, cframe.LookVector.Z)
	if look.Magnitude < 1e-3 then
		look = -Vector3.zAxis
	end
	return CFrame.lookAt(cframe.Position, cframe.Position + look.Unit)
end

local function hideBody(character: Model)
	for _, item in character:GetDescendants() do
		if item:IsA("BasePart") then
			item.Transparency = 1
			item.CanCollide = false
		elseif item:IsA("Decal") then
			item.Transparency = 1
		end
	end
end

-- Rips a limb (or the head) off: it falls from where players saw it
local function detach(move, victimRig, anchor: CFrame, joint: string, t: number)
	local motor = victimRig.Motors[joint]
	if not (motor and motor.Parent and motor.Part1) then
		return
	end
	local root, pose = Kit.sample(move.Victim, t)
	local rootCFrame = anchor * Kit.rootCFrame(root)
	local partCFrame = Kit.partCFrame(victimRig, rootCFrame, pose, joint)
	local part = motor.Part1
	motor:Destroy()
	part.CFrame = partCFrame
	part.CanCollide = true
	part.AssemblyLinearVelocity = anchor:VectorToWorldSpace(Vector3.new(math.random(-4, 4), 10, 6))
end

local function play(move, killer: Model, victim: Model, killerRig, victimRig)
	local anchor = flatten(killerRig.Root.CFrame)

	-- 1. Freeze both and put them at their starting spots
	killerRig.Root.Anchored = true
	victimRig.Root.Anchored = true
	killerRig.Root.CFrame = anchor * Kit.rootCFrame(move.Killer[1].root)
	victimRig.Root.CFrame = anchor * Kit.rootCFrame(move.Victim[1].root)

	-- 2. Everyone's computer plays the animation, all starting at the same moment
	local startTime = workspace:GetServerTimeNow()
	playExecution:FireAllClients(move.Id, killer, victim, anchor, startTime)

	-- 3. Limbs torn off during the move
	for _, event in move.ServerEvents do
		task.delay(event.t, function()
			if victim.Parent then
				detach(move, victimRig, anchor, event.joint, event.t)
			end
		end)
	end

	-- 4. Kill the victim at KillTime
	task.wait(move.KillTime)
	if victim.Parent then
		local root, pose = Kit.sample(move.Victim, move.KillTime)
		victimRig.Root.CFrame = anchor * Kit.rootCFrame(root)
		Kit.bakePose(victimRig, pose) -- so the body falls apart from where it is
		if move.HideBodyOnKill then
			hideBody(victim)
		end
		local humanoid = victim:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
		victimRig.Root.Anchored = false
	end

	-- 5. Wait for the end, leave the killer where the animation finished
	task.wait(move.Duration - move.KillTime)
	if killer.Parent then
		local root = Kit.sample(move.Killer, move.Duration)
		killerRig.Root.CFrame = anchor * Kit.rootCFrame(root)
	end
end

-- Runs a whole execution. Yields until it's over. Returns true if it ran.
function Runner.run(move, killer: Model, victim: Model): boolean
	if not (Runner.isFree(killer) and Runner.isFree(victim)) or killer == victim then
		return false
	end
	local killerRig, victimRig = Kit.getRig(killer), Kit.getRig(victim)
	if not (killerRig and victimRig) then
		warn("Executions only work on R6 characters")
		return false
	end

	killer:SetAttribute(Runner.BUSY, true)
	victim:SetAttribute(Runner.BUSY, true)

	local ok, err = pcall(play, move, killer, victim, killerRig, victimRig)
	if not ok then
		warn("Execution failed:", err)
	end

	-- Always unfreeze, even if something broke
	if killer.Parent then
		killer:SetAttribute(Runner.BUSY, nil)
		killerRig.Root.Anchored = false
	end
	if victim.Parent then
		victim:SetAttribute(Runner.BUSY, nil)
		victimRig.Root.Anchored = false
	end
	RunService.Heartbeat:Wait()
	return ok
end

return Runner
