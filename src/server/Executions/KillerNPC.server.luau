-- KillerNPC.server.luau
-- Spawns the killer and makes it hunt players. When it reaches someone it
-- executes them (the move they picked with 1-9, or a random one).
--
-- Change the numbers below to make it faster, slower, or less aggressive.

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared.Executions.Registry)
local Runner = require(script.Parent.ExecutionRunner)
local KillerBuilder = require(script.Parent.Parent.Player.KillerBuilder)

local SPAWN_POSITION = Vector3.new(0, 5, -40)
local WALK_SPEED = 12 -- players walk at 16, so you can outrun it
local SIGHT_RANGE = 150 -- how far away it notices players
local GRAB_RANGE = 5 -- how close it has to get to start an execution
local REST_AFTER_KILL = 3 -- seconds it waits after an execution

-- Roblox's own R6 walk and idle animations
local WALK_ANIMATION = "rbxassetid://180426354"
local IDLE_ANIMATION = "rbxassetid://180435571"

local function setUpAnimations(killer: Model)
	local humanoid = killer:FindFirstChildOfClass("Humanoid")
	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)
	local function load(id)
		local animation = Instance.new("Animation")
		animation.AnimationId = id
		local ok, track = pcall(animator.LoadAnimation, animator, animation)
		return ok and track or nil
	end
	local walk, idle = load(WALK_ANIMATION), load(IDLE_ANIMATION)
	if idle then
		idle.Looped = true
		idle:Play()
	end
	humanoid.Running:Connect(function(speed)
		if not walk then
			return
		end
		if speed > 0.5 and not walk.IsPlaying then
			walk.Looped = true
			walk:Play(0.2)
		elseif speed <= 0.5 and walk.IsPlaying then
			walk:Stop(0.2)
		end
	end)
end

local function spawnKiller(): Model
	local killer = KillerBuilder.build()
	killer.Name = "Sackhead"
	CollectionService:AddTag(killer, "Killer")

	local humanoid = killer:FindFirstChildOfClass("Humanoid")
	humanoid.WalkSpeed = WALK_SPEED
	humanoid.MaxHealth = 1e6
	humanoid.Health = 1e6
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	-- the Animate script only works for players, the killer uses its own
	local animate = killer:FindFirstChild("Animate")
	if animate then
		animate:Destroy()
	end

	killer:PivotTo(CFrame.new(SPAWN_POSITION))
	killer.Parent = workspace
	killer.HumanoidRootPart:SetNetworkOwner(nil) -- the server moves it
	setUpAnimations(killer)
	return killer
end

local function nearestPlayer(killer: Model): (Player?, Model?, number)
	local root = killer.HumanoidRootPart
	local best, bestCharacter, bestDistance = nil, nil, SIGHT_RANGE
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local theirRoot = character and character:FindFirstChild("HumanoidRootPart")
		if theirRoot and Runner.isFree(character) then
			local distance = (theirRoot.Position - root.Position).Magnitude
			if distance < bestDistance then
				best, bestCharacter, bestDistance = player, character, distance
			end
		end
	end
	return best, bestCharacter, bestDistance
end

local killer = spawnKiller()

while true do
	task.wait(0.2)
	if not killer.Parent or not Runner.isAlive(killer) then
		killer = spawnKiller()
		continue
	end
	if killer:GetAttribute(Runner.BUSY) then
		continue
	end

	local humanoid = killer:FindFirstChildOfClass("Humanoid")
	local player, character, distance = nearestPlayer(killer)
	if not character then
		humanoid:MoveTo(killer.HumanoidRootPart.Position)
		continue
	end

	if distance <= GRAB_RANGE then
		humanoid:MoveTo(killer.HumanoidRootPart.Position)
		local chosen = player:GetAttribute("NextExecution")
		local id = if chosen and Registry.Moves[chosen] then chosen else Registry.Order[math.random(#Registry.Order)]
		if Runner.run(Registry.Moves[id], killer, character) then
			task.wait(REST_AFTER_KILL)
		end
	else
		humanoid:MoveTo(character.HumanoidRootPart.Position)
	end
end
