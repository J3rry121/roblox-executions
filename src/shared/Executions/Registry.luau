-- Registry.luau
-- The list of every execution in the game. The server and players both
-- read it, and later the QTE hub can use it to build a menu.
--
-- To add a new execution:
--   1. Copy one of the files in the Moves folder and give it a new name
--   2. Change the keyframes
--   3. Add the file's name to Order below

local Kit = require(script.Parent.Kit)
local Moves = script.Parent:WaitForChild("Moves")

local Registry = {
	-- Keys 1, 2, 3... in game follow this order
	Order = {
		"BackSaw",
		"ChestCarve",
		"OverheadSplit",
		"ArmRip",
		"ThroatLift",
		"DragBelow",
	},
	Moves = {},
}

for _, id in Registry.Order do
	local module = Moves:WaitForChild(id)
	Registry.Moves[id] = Kit.prepareMove(id, require(module))
end

return Registry
