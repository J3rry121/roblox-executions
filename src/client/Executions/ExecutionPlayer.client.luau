-- ExecutionPlayer.client.luau
-- When the server starts an execution, this plays it on this player's
-- screen: moves both bodies, runs the cinematic camera (only for the killer
-- and the victim) and fires the effects.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared.Executions.Registry)
local Kit = require(Shared.Executions.Kit)
local Effects = require(script.Parent:WaitForChild("Effects"))

local player = Players.LocalPlayer
local playExecution = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayExecution")

local JOINT_SEED = { Torso = 1, Head = 2, RArm = 3, LArm = 4, RLeg = 5, LLeg = 6 }
local cameraBusy = false

local function stopAnimations(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		for _, track in animator:GetPlayingAnimationTracks() do
			track:Stop(0)
		end
	end
end

local function poseRig(rig, anchor: CFrame, track, t: number)
	local root, pose, struggle = Kit.sample(track, t)
	rig.Root.CFrame = anchor * Kit.rootCFrame(root)
	if struggle > 0 then
		-- shaky limbs (struggling, or a chainsaw vibrating)
		local clock = os.clock() * 7
		for name, angles in pose do
			if name ~= "Torso" then
				local seed = JOINT_SEED[name]
				angles[1] += math.noise(clock, seed, 0.5) * struggle * 2
				angles[2] += math.noise(clock, seed, 10.5) * struggle
				angles[3] += math.noise(clock, seed, 20.5) * struggle
			end
		end
	end
	Kit.applyPose(rig, pose)
end

local function play(id: string, killer: Model, victim: Model, anchor: CFrame, startTime: number)
	local move = Registry.Moves[id]
	local killerRig, victimRig = Kit.getRig(killer), Kit.getRig(victim)
	if not (move and killerRig and victimRig) then
		return
	end

	stopAnimations(killer)
	stopAnimations(victim)

	local character = player.Character
	local involved = character == killer or character == victim
	local fx = Effects.new(involved, killer, victim)
	local nextEvent = 1

	local function now(): number
		return workspace:GetServerTimeNow() - startTime
	end

	-- Bodies: runs right after the default animations, so ours win
	local bodyConnection
	bodyConnection = RunService.PreSimulation:Connect(function()
		local t = now()

		while nextEvent <= #move.Events and move.Events[nextEvent].t <= t do
			fx:Run(move.Events[nextEvent])
			nextEvent += 1
		end

		if killer.Parent then
			poseRig(killerRig, anchor, move.Killer, t)
		end
		if t < move.KillTime and victim.Parent then
			poseRig(victimRig, anchor, move.Victim, t)
		end
	end)

	-- Camera
	local camera = workspace.CurrentCamera
	local useCamera = involved and not cameraBusy
	local oldFov = camera.FieldOfView
	if useCamera then
		cameraBusy = true
		camera.CameraType = Enum.CameraType.Scriptable
		RunService:BindToRenderStep("ExecutionCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
			local pos, look, fov = Kit.sampleCamera(move.Camera, now())
			camera.CFrame = anchor * CFrame.lookAt(pos, look) * fx:CameraShake(dt)
			camera.FieldOfView = fov
		end)
	end

	-- Wait until it's over, then clean up
	while now() < move.Duration do
		task.wait()
	end

	bodyConnection:Disconnect()
	if killer.Parent then
		Kit.clearPose(killerRig)
	end
	if useCamera then
		RunService:UnbindFromRenderStep("ExecutionCamera")
		camera.CameraType = Enum.CameraType.Custom
		camera.FieldOfView = oldFov
		local myHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if myHumanoid then
			camera.CameraSubject = myHumanoid
		end
		cameraBusy = false
	end
	fx:Destroy()
end

playExecution.OnClientEvent:Connect(function(...)
	local ok, err = pcall(play, ...)
	if not ok then
		warn("Execution playback failed:", err)
	end
end)
