-- ExecutionService.server.luau
-- Listens for execution requests from players, checks they are allowed,
-- then runs the right execution module from the Registry.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Registry = require(ReplicatedStorage.Shared.Executions.Registry)

-- Create the RemoteEvents the client uses
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
remotes.Parent = ReplicatedStorage

local requestExecution = Instance.new("RemoteEvent")
requestExecution.Name = "RequestExecution"
requestExecution.Parent = remotes

local executionFx = Instance.new("RemoteEvent")
executionFx.Name = "ExecutionFx"
executionFx.Parent = remotes

local IN_EXECUTION = "InExecution" -- attribute set on characters while busy

local function isAlive(character: Model?): boolean
	if not character then
		return false
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	return humanoid ~= nil and root ~= nil and humanoid.Health > 0
end

local function fireFx(name: string, killer: Model, victim: Model)
	executionFx:FireAllClients(name, killer, victim)
end

requestExecution.OnServerEvent:Connect(function(player, executionId, target)
	-- Never trust the client: check everything
	local info = Registry[executionId]
	if not info then
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
	if distance > info.Range then
		return
	end

	local moduleScript = script.Parent:FindFirstChild(info.ServerModule)
	if not moduleScript then
		warn("Execution module not found:", info.ServerModule)
		return
	end
	local executionModule = require(moduleScript)

	killer:SetAttribute(IN_EXECUTION, true)
	target:SetAttribute(IN_EXECUTION, true)

	local ok, err = pcall(executionModule.Run, killer, target, fireFx)
	if not ok then
		warn("Execution failed:", err)
	end

	-- Always unfreeze the killer, even if something broke
	if killer.Parent then
		killer:SetAttribute(IN_EXECUTION, nil)
		local root = killer:FindFirstChild("HumanoidRootPart")
		if root then
			root.Anchored = false
		end
	end
	if target.Parent then
		target:SetAttribute(IN_EXECUTION, nil)
	end
end)
