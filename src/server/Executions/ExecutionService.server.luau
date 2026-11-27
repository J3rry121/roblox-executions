-- ExecutionService.server.luau
-- Testing keys: when a player presses 1-9 (or E for random) near the killer,
-- the killer executes them with that move right away. If the killer is too
-- far away, the choice is saved and used the next time it catches them.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Registry = require(Shared.Executions.Registry)
local Sounds = require(Shared.Executions.Sounds)
local Runner = require(script.Parent.ExecutionRunner)

local TEST_RANGE = 15 -- studs

local function nearestKiller(position: Vector3): Model?
	local best, bestDistance = nil, TEST_RANGE
	for _, killer in CollectionService:GetTagged("Killer") do
		local root = killer:FindFirstChild("HumanoidRootPart")
		if root and Runner.isFree(killer) then
			local distance = (root.Position - position).Magnitude
			if distance <= bestDistance then
				best, bestDistance = killer, distance
			end
		end
	end
	return best
end

Runner.RequestExecution.OnServerEvent:Connect(function(player, executionId)
	-- Never trust the client: check everything
	if executionId ~= "Random" and not (typeof(executionId) == "string" and Registry.Moves[executionId]) then
		return
	end
	player:SetAttribute("NextExecution", if executionId == "Random" then nil else executionId)

	local victim = player.Character
	if not Runner.isFree(victim) then
		return
	end
	local killer = nearestKiller(victim.HumanoidRootPart.Position)
	if not killer then
		return
	end
	local id = if executionId == "Random" then Registry.Order[math.random(#Registry.Order)] else executionId
	Runner.run(Registry.Moves[id], killer, victim)
end)

-- The V key: which voice your character screams with (Female / Male / Off)
Runner.SetVoice.OnServerEvent:Connect(function(player, voice)
	if typeof(voice) == "string" and table.find(Sounds.VoiceOptions, voice) then
		player:SetAttribute("Voice", voice)
	end
end)
