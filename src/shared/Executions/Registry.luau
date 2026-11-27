-- Registry.luau
-- Every execution in the game is listed here. The server uses this to find
-- the right module, and later the QTE hub can use it to show a menu.
--
-- To add a new execution:
--   1. Make a ModuleScript in src/server/Executions (copy ChainExecution.luau)
--   2. Add an entry below with the same ServerModule name

local Registry = {
	Chain = {
		DisplayName = "Chain Yank",
		ServerModule = "ChainExecution", -- name of the module in src/server/Executions
		Range = 12, -- how close (in studs) you must be to the target
	},
}

return Registry
