-- ExecutionInput.client.luau
-- Testing keys. You are the victim: the killer hunts you down.
--   1-9 = pick which execution the killer does to you (same order as
--         Registry.Order). Near the killer it happens right away.
--   E   = random execution

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

-- Tell the server which execution we want. If the killer is close it does
-- it right away, otherwise it remembers and uses it when it catches us.
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == RANDOM_KEY then
		requestExecution:FireServer("Random")
		return
	end
	local index = table.find(NUMBER_KEYS, input.KeyCode)
	if index and Registry.Order[index] then
		requestExecution:FireServer(Registry.Order[index])
	end
end)

-- Small help text in the corner
local lines = { "Pick how the killer gets you:", "E  random" }
for i, id in Registry.Order do
	table.insert(lines, `{i}  {Registry.Moves[id].DisplayName}`)
end

local gui = Instance.new("ScreenGui")
gui.Name = "ExecutionHelp"
gui.ResetOnSpawn = false
local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0, 1)
label.Position = UDim2.new(0, 12, 1, -12)
label.Size = UDim2.fromOffset(260, 20 * #lines)
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
