-- ExecutionInput.client.luau
-- Press E near another character (or the Test Dummy) to execute them.
-- Also plays camera shake when the server says an execution hit.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Registry = require(ReplicatedStorage.Shared.Executions.Registry)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local requestExecution = remotes:WaitForChild("RequestExecution")
local executionFx = remotes:WaitForChild("ExecutionFx")

local EXECUTION_KEY = Enum.KeyCode.E
local EXECUTION_ID = "Chain"

-- Find the closest living character in range (not ourselves)
local function findNearestTarget(range: number): Model?
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return nil
	end

	local nearest, nearestDistance = nil, range
	for _, model in workspace:GetChildren() do
		if model ~= character and model:IsA("Model") then
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local targetRoot = model:FindFirstChild("HumanoidRootPart")
			if humanoid and targetRoot and humanoid.Health > 0 then
				local distance = (targetRoot.Position - root.Position).Magnitude
				if distance <= nearestDistance then
					nearest, nearestDistance = model, distance
				end
			end
		end
	end
	return nearest
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or input.KeyCode ~= EXECUTION_KEY then
		return
	end
	local target = findNearestTarget(Registry[EXECUTION_ID].Range)
	if target then
		requestExecution:FireServer(EXECUTION_ID, target)
	end
end)

-- Simple camera shake
local function shakeCamera(strength: number, duration: number)
	local camera = workspace.CurrentCamera
	local elapsed = 0
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed >= duration then
			connection:Disconnect()
			return
		end
		local fade = 1 - elapsed / duration
		local offset = Vector3.new(math.random() - 0.5, math.random() - 0.5, 0) * strength * fade
		camera.CFrame *= CFrame.new(offset)
	end)
end

executionFx.OnClientEvent:Connect(function(name, killer, victim)
	-- Only shake for people involved in the execution
	local character = player.Character
	if character ~= killer and character ~= victim then
		return
	end
	if name == "Hook" then
		shakeCamera(0.4, 0.2)
	elseif name == "Slam" then
		shakeCamera(1.2, 0.4)
	end
end)
