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
Runner.SetVoice = remote("SetVoice")
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

-- Swaps the joints for loose ball joints so the body slumps like a ragdoll
-- instead of the classic Roblox fall-apart-in-pieces death.
-- newParent (optional): name -> part to hang that limb from instead of the torso
local function ragdoll(rig, collide: boolean, newParent: { [string]: BasePart }?)
	for name, motor in rig.Motors do
		if name ~= "Torso" and motor.Parent and motor.Part0 and motor.Part1 then
			local part0 = newParent and newParent[name] or motor.Part0
			local a0 = Instance.new("Attachment")
			a0.Name = "RagdollJoint"
			a0.CFrame = part0.CFrame:ToObjectSpace(motor.Part0.CFrame * motor.C0)
			a0.Parent = part0
			local a1 = Instance.new("Attachment")
			a1.Name = "RagdollJoint"
			a1.CFrame = motor.C1
			a1.Parent = motor.Part1
			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = a0
			socket.Attachment1 = a1
			socket.LimitsEnabled = true
			socket.UpperAngle = if name == "Head" then 40 else 70
			socket.TwistLimitsEnabled = true
			socket.TwistLowerAngle = -30
			socket.TwistUpperAngle = 30
			socket.Parent = part0
			motor.Part1.CanCollide = collide
			motor:Destroy()
		end
	end
end

local GORE_COLOR = Color3.fromRGB(90, 0, 0)

local function halfPart(name: string, size: Vector3, cframe: CFrame, look: BasePart, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = look.Color
	part.Material = look.Material
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

-- A raw red cut face, stuck on the inside of a half
local function cutFace(half: BasePart, side: number)
	local face = Instance.new("Part")
	face.Name = "CutFace"
	face.Size = Vector3.new(0.05, half.Size.Y * 0.96, half.Size.Z * 0.92)
	face.CFrame = half.CFrame * CFrame.new(-side * (half.Size.X / 2 + 0.02), 0, 0)
	face.Color = GORE_COLOR
	face.Material = Enum.Material.Glass
	face.CanCollide = false
	face.CanQuery = false
	face.Massless = true
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = half
	weld.Part1 = face
	weld.Parent = face
	face.Parent = half
end

local function hide(part: BasePart)
	part.Transparency = 1
	part.CanCollide = false
	part.CanQuery = false
	for _, item in part:GetChildren() do
		if item:IsA("Decal") then
			item.Transparency = 1
		end
	end
end

-- Cuts the body in half straight down the middle. Each half keeps its own
-- arm and leg (on loose ragdoll joints) and the two halves fall apart.
local function splitBody(victim: Model, rig)
	local torso = rig.Motors.Torso.Part1
	local head = rig.Motors.Head.Part1
	local headSize = math.min(head.Size.Y, head.Size.Z) * 1.2
	local halves = {}
	local limbs = {}
	for _, side in { -1, 1 } do
		local name = if side < 0 then "Left" else "Right"
		local body = halfPart(`{name}Half`, Vector3.new(torso.Size.X / 2, torso.Size.Y, torso.Size.Z),
			torso.CFrame * CFrame.new(side * torso.Size.X / 4, 0, 0), torso, victim)
		local skull = halfPart(`{name}HeadHalf`, Vector3.new(headSize / 2, headSize, headSize),
			head.CFrame * CFrame.new(side * headSize / 4, 0, 0), head, victim)
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = body
		weld.Part1 = skull
		weld.Parent = body
		cutFace(body, side)
		cutFace(skull, side)
		halves[side] = body
		limbs[name:sub(1, 1) .. "Arm"] = body
		limbs[name:sub(1, 1) .. "Leg"] = body
	end
	-- the real head comes off its joint first, so it isn't ragdolled
	local neck = rig.Motors.Head
	if neck.Parent then
		neck:Destroy()
	end
	head.Anchored = true
	ragdoll(rig, true, limbs)

	-- hats and hair go with whichever half they sit on
	for _, accessory in victim:GetChildren() do
		local handle = accessory:IsA("Accessory") and accessory:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			local side = if torso.CFrame:PointToObjectSpace(handle.Position).X < 0 then -1 else 1
			for _, joint in handle:GetChildren() do
				if joint:IsA("JointInstance") or joint:IsA("WeldConstraint") then
					joint:Destroy()
				end
			end
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = halves[side]
			weld.Part1 = handle
			weld.Parent = handle
		end
	end

	-- the real torso and head stay where they were, invisible and frozen
	hide(torso)
	hide(head)
	rig.Root.CanCollide = false -- it sits right where the halves start
	rig.Root:SetAttribute("StayFrozen", true)

	-- push the halves apart and tip them over outwards
	for side, half in halves do
		half.AssemblyLinearVelocity = torso.CFrame:VectorToWorldSpace(Vector3.new(side * 6, 2, 0))
		half.AssemblyAngularVelocity = torso.CFrame:VectorToWorldSpace(Vector3.new(0, 0, -side * 5))
	end
end

local function play(move, killer: Model, victim: Model, killerRig, victimRig)
	local anchor = flatten(killerRig.Root.CFrame)
	local killerFrom, victimFrom = killerRig.Root.CFrame, victimRig.Root.CFrame

	-- Keep the body in one piece when it dies (we ragdoll it ourselves)
	local victimHumanoid = victim:FindFirstChildOfClass("Humanoid")
	if victimHumanoid then
		victimHumanoid.BreakJointsOnDeath = false
		victimHumanoid.RequiresNeck = false
	end

	-- 1. Freeze both and put them at their starting spots
	killerRig.Root.Anchored = true
	victimRig.Root.Anchored = true
	killerRig.Root.CFrame = anchor * Kit.rootCFrame(move.Killer[1].root)
	victimRig.Root.CFrame = anchor * Kit.rootCFrame(move.Victim[1].root)

	-- 2. Everyone's computer plays the animation, all starting at the same moment
	local startTime = workspace:GetServerTimeNow()
	-- (where they were before, so players' screens can blend in smoothly)
	playExecution:FireAllClients(move.Id, killer, victim, anchor, startTime, killerFrom, victimFrom)

	-- 3. Limbs torn off during the move
	for _, event in move.ServerEvents do
		task.delay(event.t, function()
			if victim.Parent then
				detach(move, victimRig, anchor, event.joint, event.t)
			end
		end)
	end

	-- 4. Kill the victim at KillTime (ragdoll, or cut in half for SplitOnKill)
	task.wait(move.KillTime)
	if victim.Parent then
		local root, pose = Kit.sample(move.Victim, move.KillTime)
		victimRig.Root.CFrame = anchor * Kit.rootCFrame(root)
		Kit.bakePose(victimRig, pose) -- so the body drops from where players saw it
		if move.HideBodyOnKill then
			hideBody(victim)
		end
		RunService.Heartbeat:Wait() -- let the joints move the limbs into that pose
		if move.SplitOnKill then
			splitBody(victim, victimRig)
		else
			ragdoll(victimRig, not move.HideBodyOnKill)
		end
		if victimHumanoid then
			victimHumanoid.Health = 0
		end
		victimRig.Root.Anchored = victimRig.Root:GetAttribute("StayFrozen") == true
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
		victimRig.Root.Anchored = victimRig.Root:GetAttribute("StayFrozen") == true
	end
	RunService.Heartbeat:Wait()
	return ok
end

return Runner
