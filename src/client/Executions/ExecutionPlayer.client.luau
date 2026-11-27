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

local MIN_CAMERA_DISTANCE = 4 -- never let the camera get closer than this to what it looks at
local BLEND_IN = 0.3 -- seconds to blend from where the bodies were into the execution
local CAMERA_BLEND_IN = 0.45 -- seconds to blend the camera in
local HANDHELD = 0.5 -- degrees of gentle "handheld camera" sway (0 = rock steady)
local CATCH_UP = 1.6 -- how fast the animation catches up after a hit-stop
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

local function smoothstep(x: number): number
	x = math.clamp(x, 0, 1)
	return x * x * (3 - 2 * x)
end

local function poseRig(rig, anchor: CFrame, track, t: number, breathRate: number, fromRoot: CFrame?, fromPose)
	local root, pose, struggle = Kit.sample(track, t)
	local blend = smoothstep(t / BLEND_IN)
	local target = anchor * Kit.rootCFrame(root)
	rig.Root.CFrame = if fromRoot and blend < 1 then fromRoot:Lerp(target, blend) else target
	-- breathing: slow heavy breaths for the killer, fast panting for the victim
	local breath = math.sin(os.clock() * breathRate)
	pose.Torso[1] += breath * 1.2
	pose.Head[1] += math.sin(os.clock() * breathRate - 0.6) * 1.8
	pose.RArm[3] += breath * 1.5
	pose.LArm[3] -= breath * 1.5

	if struggle > 0 then
		-- shaky limbs (struggling, or a chainsaw vibrating); the body shakes a bit too
		local clock = os.clock() * 7
		for name, angles in pose do
			local seed = JOINT_SEED[name]
			local amount = if name == "Torso" then struggle * 0.35 else struggle
			angles[1] += math.noise(clock, seed, 0.5) * amount * 2
			angles[2] += math.noise(clock, seed, 10.5) * amount
			angles[3] += math.noise(clock, seed, 20.5) * amount
		end
	end
	Kit.applyPose(rig, pose, fromPose, blend)
end

local function play(id: string, killer: Model, victim: Model, anchor: CFrame, startTime: number, killerFrom: CFrame?, victimFrom: CFrame?)
	local move = Registry.Moves[id]
	local killerRig, victimRig = Kit.getRig(killer), Kit.getRig(victim)
	if not (move and killerRig and victimRig) then
		return
	end

	stopAnimations(killer)
	stopAnimations(victim)
	local killerPoseFrom = Kit.capturePose(killerRig)
	local victimPoseFrom = Kit.capturePose(victimRig)

	local character = player.Character
	local involved = character == killer or character == victim
	local fx = Effects.new(involved, killer, victim)
	local nextEvent = 1

	local function now(): number
		return workspace:GetServerTimeNow() - startTime
	end

	-- Animation time. Normally the same as now(), but a HitStop freezes it
	-- for a split second; afterwards it runs a bit faster until it catches up
	-- (so it never drifts away from what the server does).
	local animTime = math.max(now(), 0)
	local lastReal = animTime
	local function advance()
		local real = now()
		local dt = math.max(real - lastReal, 0)
		lastReal = real
		if real < fx.HoldUntil then
			return
		end
		local speed = if animTime < real - 1e-3 then CATCH_UP else 1
		animTime = math.min(animTime + dt * speed, real)
	end

	-- Bodies: runs right after the default animations, so ours win
	local bodyConnection
	bodyConnection = RunService.PreSimulation:Connect(function()
		local real = now()
		while nextEvent <= #move.Events and move.Events[nextEvent].t <= real do
			fx:Run(move.Events[nextEvent])
			nextEvent += 1
		end
		advance()
		local t = animTime

		if killer.Parent then
			poseRig(killerRig, anchor, move.Killer, t, 2.2, killerFrom, killerPoseFrom)
		end
		if real < move.KillTime and victim.Parent then
			poseRig(victimRig, anchor, move.Victim, t, 7, victimFrom, victimPoseFrom)
		end
	end)

	-- Camera
	local camera = workspace.CurrentCamera
	local useCamera = involved and not cameraBusy
	local oldFov = camera.FieldOfView
	local cameraFrom = camera.CFrame
	local seed = math.random() * 100
	if useCamera then
		cameraBusy = true
		camera.CameraType = Enum.CameraType.Scriptable
		RunService:BindToRenderStep("ExecutionCamera", Enum.RenderPriority.Camera.Value + 1, function(dt)
			local pos, look, fov = Kit.sampleCamera(move.Camera, animTime)
			local offset = pos - look
			if offset.Magnitude < MIN_CAMERA_DISTANCE then
				local direction = if offset.Magnitude > 1e-3 then offset.Unit else Vector3.new(0, 0.3, 1).Unit
				pos = look + direction * MIN_CAMERA_DISTANCE
			end
			local t = now()
			local clock = os.clock() * 0.7
			local sway = CFrame.Angles(
				math.rad(math.noise(clock, seed) * HANDHELD * 2),
				math.rad(math.noise(clock, seed + 7) * HANDHELD * 2),
				math.rad(math.noise(clock, seed + 13) * HANDHELD)
			)
			local shot = anchor * CFrame.lookAt(pos, look) * sway
			local blend = smoothstep(t / CAMERA_BLEND_IN)
			if blend < 1 then
				shot = cameraFrom:Lerp(shot, blend)
				fov = oldFov + (fov - oldFov) * blend
			end
			camera.CFrame = shot * fx:CameraShake(dt)
			camera.FieldOfView = fov + fx:CameraFov(dt)
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
