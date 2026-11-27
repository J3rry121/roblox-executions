-- MuteDeathSound.client.luau
-- Turns off Roblox's built-in "oof" death sound for every character.
-- (Roblox makes a sound called "Died" inside each character's root part.)

local function mute(item: Instance)
	if item:IsA("Sound") and item.Name == "Died" then
		item.Volume = 0
		item:Stop()
	end
end

workspace.DescendantAdded:Connect(mute)
for _, item in workspace:GetDescendants() do
	mute(item)
end
