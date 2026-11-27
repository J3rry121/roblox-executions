-- CharacterSpawner.server.luau
-- Makes every player spawn as their own avatar in R6, even if the game is
-- set to R15. Players are the victims; the killer is KillerNPC.
--
-- Tip: once your game is published you can also set R6 in
-- Home > Game Settings > Avatar. This script still works either way.

local Players = game:GetService("Players")

local RESPAWN_DELAY = 3

Players.CharacterAutoLoads = false

local function getDescription(player: Player): HumanoidDescription
	-- Test players in Studio have negative ids, so fall back to a real one
	local ok, description = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(math.max(player.UserId, 1))
	end)
	if ok and description then
		return description
	end
	return Instance.new("HumanoidDescription")
end

local function getSpawnCFrame(): CFrame
	local spawns = {}
	for _, item in workspace:GetDescendants() do
		if item:IsA("SpawnLocation") and item.Enabled then
			table.insert(spawns, item)
		end
	end
	if #spawns == 0 then
		return CFrame.new(0, 5, 0)
	end
	local spawn = spawns[math.random(#spawns)]
	return CFrame.new(spawn.Position + Vector3.new(0, spawn.Size.Y / 2 + 3, 0))
end

local function spawnCharacter(player: Player)
	if not player.Parent then
		return
	end

	local character = Players:CreateHumanoidModelFromDescription(getDescription(player), Enum.HumanoidRigType.R6)
	character.Name = player.Name
	character:PivotTo(getSpawnCFrame())

	local old = player.Character
	player.Character = character
	character.Parent = workspace
	if old and old ~= character then
		old:Destroy()
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Once(function()
		task.wait(RESPAWN_DELAY)
		if player.Character == character then
			spawnCharacter(player)
		end
	end)
end

Players.PlayerAdded:Connect(spawnCharacter)
for _, player in Players:GetPlayers() do
	task.spawn(spawnCharacter, player)
end
