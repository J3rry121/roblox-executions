-- TestDummy.server.luau
-- Spawns a dummy to practice executions on when playing in Studio.
-- It respawns a few seconds after dying. Does nothing in a live game.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	return
end

local SPAWN_POSITION = Vector3.new(0, 5, -20)
local RESPAWN_DELAY = 3

local function spawnDummy()
	local dummy = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
	dummy.Name = "Test Dummy"
	dummy:PivotTo(CFrame.new(SPAWN_POSITION))
	dummy.Parent = workspace

	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	humanoid.Died:Once(function()
		task.wait(RESPAWN_DELAY)
		dummy:Destroy()
		spawnDummy()
	end)
end

spawnDummy()
