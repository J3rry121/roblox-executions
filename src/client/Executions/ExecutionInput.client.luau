-- ExecutionInput.client.luau
-- Walk up to another character (or the Test Dummy) and press:
--   E       = a random execution
--   1, 2, 3 = a specific one (same order as Registry.Order)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared.Executions.Registry)

local player = Players.LocalPlayer
local requestExecution = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestExecution")

local RANDOM_KEY = Enum.KeyCode.E
local NUMBER_KEYS = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
}

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

local function tryExecution(id: string)
	local move = Registry.Moves[id]
	local target = move and findNearestTarget(move.Range)
	if target then
		requestExecution:FireServer(id, target)
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == RANDOM_KEY then
		tryExecution(Registry.Order[math.random(#Registry.Order)])
		return
	end
	local index = table.find(NUMBER_KEYS, input.KeyCode)
	if index and Registry.Order[index] then
		tryExecution(Registry.Order[index])
	end
end)

-- Small help text in the corner
local lines = { "E  random execution" }
for i, id in Registry.Order do
	table.insert(lines, `{i}  {Registry.Moves[id].DisplayName}`)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ExecutionHelp"
gui.ResetOnSpawn = false
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0, 1)
label.Position = UDim2.new(0, 12, 1, -12)
label.Size = UDim2.fromOffset(220, 20 * #lines)
label.BackgroundTransparency = 1
label.TextXAlignment = Enum.TextXAlignment.Left
label.TextYAlignment = Enum.TextYAlignment.Bottom
label.TextColor3 = Color3.fromRGB(220, 200, 200)
label.TextStrokeTransparency = 0.5
label.Font = Enum.Font.GothamMedium
label.TextSize = 16
label.Text = table.concat(lines, "\n")
label.Parent = gui
gui.Parent = player:WaitForChild("PlayerGui")
