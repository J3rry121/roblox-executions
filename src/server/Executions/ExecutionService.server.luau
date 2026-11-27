-- ExecutionService.server.luau
-- Listens for execution requests from players, checks they are allowed,
-- then runs the execution: freezes both bodies, tells every player to play
-- the animation, kills the victim at the right moment, and frees the killer.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared.Executions.Registry)
local Kit = require(Shared.Executions.Kit)

-- Create the RemoteEvents players use
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local requestExecution = Instance.new("RemoteEvent")
requestExecution.Name = "RequestExecution"
requestExecution.Parent = remotes

local playExecution = Instance.new("RemoteEvent")
playExecution.Name = "PlayExecution"
playExecution.Parent = remotes

local IN_EXECUTION = "InExecution" -- attribute set on characters while busy

local function isAlive(character: Model?): boolean
	if not character then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return humanoid ~= nil and root ~= nil and humanoid.Health > 0
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

local function runExecution(move, killer: Model, victim: Model, killerRig, victimRig)
	local anchor = flatten(killerRig.Root.CFrame)

	-- 1. Freeze both and put them at their starting spots
	killerRig.Root.Anchored = true
	victimRig.Root.Anchored = true
	killerRig.Root.CFrame = anchor * Kit.rootCFrame(move.Killer[1].root)
	victimRig.Root.CFrame = anchor * Kit.rootCFrame(move.Victim[1].root)

	-- 2. Everyone's computer plays the animation, all starting at the same moment
	local startTime = workspace:GetServerTimeNow()
	playExecution:FireAllClients(move.Id, killer, victim, anchor, startTime)

	-- 3. Kill the victim at KillTime
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

	-- 4. Wait for the end, leave the killer where the animation finished
	task.wait(move.Duration - move.KillTime)
	if killer.Parent then
		local root = Kit.sample(move.Killer, move.Duration)
		killerRig.Root.CFrame = anchor * Kit.rootCFrame(root)
	end
end

requestExecution.OnServerEvent:Connect(function(player, executionId, target)
	-- Never trust the client: check everything
	local move = typeof(executionId) == "string" and Registry.Moves[executionId]
	if not move then
		return
	end
	if typeof(target) ~= "Instance" or not target:IsA("Model") then
		return
	end

	local killer = player.Character
	if not isAlive(killer) or not isAlive(target) or killer == target then
		return
	end
	if killer:GetAttribute(IN_EXECUTION) or target:GetAttribute(IN_EXECUTION) then
		return
	end

	local distance = (killer.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
	if distance > move.Range then
		return
	end

	local killerRig, victimRig = Kit.getRig(killer), Kit.getRig(target)
	if not (killerRig and victimRig) then
		warn("Executions only work on R6 characters")
		return
	end

	killer:SetAttribute(IN_EXECUTION, true)
	target:SetAttribute(IN_EXECUTION, true)

	local ok, err = pcall(runExecution, move, killer, target, killerRig, victimRig)
	if not ok then
		warn("Execution failed:", err)
	end

	-- Always unfreeze the killer, even if something broke
	if killer.Parent then
		killer:SetAttribute(IN_EXECUTION, nil)
		killerRig.Root.Anchored = false
	end
	if target.Parent then
		target:SetAttribute(IN_EXECUTION, nil)
		victimRig.Root.Anchored = false
	end
end)
