# Roblox Executions

Chain-style execution (kill) animations for Roblox, and later a QTE hub game that collects them.

The code lives in normal files in this repo. **Rojo** syncs those files into Roblox Studio live, so you can edit in VS Code (or any editor) and see changes in Studio right away.

## What you need first

- [Roblox Studio](https://create.roblox.com/)
- [Git for Windows](https://git-scm.com/download/win) (pick the default options in the installer)
- A code editor. [VS Code](https://code.visualstudio.com/) is a good pick.

## One-time setup: install Rokit

Rokit is a small tool that installs the right version of Rojo for this project.

1. Go to the [Rokit releases page](https://github.com/rojo-rbx/rokit/releases/latest).
2. Download the file ending in `windows-x86_64.zip` and unzip it.
3. Double-click `rokit.exe` once. It installs itself.
4. Close any open PowerShell windows so the new command is picked up.

To check it worked, open **PowerShell** and run `rokit --version`. You should see a version number.

## Get the project running

Open **PowerShell** and run these one at a time:

```powershell
# 1. Make a folder for your Roblox projects and go into it
mkdir C:\RobloxDev
cd C:\RobloxDev

# 2. Download this repo
git clone https://github.com/J3rry121/roblox-executions.git

# 3. Go into the project folder
cd roblox-executions

# 4. Install Rojo (if it asks whether to trust rojo-rbx/rojo, type y)
rokit install

# 5. Install the Rojo plugin into Roblox Studio
rojo plugin install

# 6. Start syncing (leave this window open while you work)
rojo serve
```

Then in **Roblox Studio**:

1. Open a new **Baseplate** place.
2. Go to the **Plugins** tab and click **Rojo**.
3. Click **Connect**. The scripts from this repo now show up in Studio.
4. Press **Play**, walk up to the **Test Dummy**, and press **E** to run the chain execution.

> If you get "rojo is not recognized", close PowerShell, open a new one, `cd C:\RobloxDev\roblox-executions`, and try again.
>
> If Studio doesn't show the Rojo button, restart Studio after step 5.

Next time you only need to `cd C:\RobloxDev\roblox-executions`, run `rojo serve`, and click Connect in Studio.

## Where things go

| Folder in this repo | Shows up in Studio as | What goes there |
| --- | --- | --- |
| `src/shared` | `ReplicatedStorage.Shared` | Code both server and client use |
| `src/server` | `ServerScriptService.Server` | Server-only code (damage, kills, checks) |
| `src/client` | `StarterPlayer.StarterPlayerScripts.Client` | Player code (input, camera, effects) |

Each of those has three sub-folders:

- `Executions/` the kill animations themselves
- `QTE/` the quick-time-event system (coming later)
- `Hub/` the hub game that ties it all together (coming later)

File name endings tell Rojo what to make:

- `Name.server.luau` becomes a **Script**
- `Name.client.luau` becomes a **LocalScript**
- `Name.luau` becomes a **ModuleScript**

## The starter chain execution

| File | What it does |
| --- | --- |
| `src/shared/Executions/Registry.luau` | List of all executions (name, range, which module runs it) |
| `src/shared/Executions/ChainBuilder.luau` | Builds the metal chain between two parts and keeps it attached |
| `src/server/Executions/ChainExecution.luau` | The execution itself: hook, yank up, slam, kill |
| `src/server/Executions/ExecutionService.server.luau` | Checks requests are legit, then runs the execution |
| `src/server/Executions/TestDummy.server.luau` | Spawns a dummy to practise on (Studio only) |
| `src/client/Executions/ExecutionInput.client.luau` | Press E to execute, plus camera shake |

To change how it feels, edit the `TIMING` numbers at the top of `ChainExecution.luau`.

To add a new execution, copy `ChainExecution.luau`, rename it, change the moves, and add it to `Registry.luau`.

## Saving your work

When you change files, save them to GitHub with:

```powershell
git add .
git commit -m "Describe what you changed"
git push
```
