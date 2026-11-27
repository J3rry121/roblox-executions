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
4. Press **Play**. You spawn as yourself (in R6) and the killer, **Sackhead**, hunts you down. When it catches you it executes you. Press **1** to **6** to pick which execution it does next (if it's close it does it straight away), or **E** for a random one.

> If you get "rojo is not recognized", close PowerShell, open a new one, `cd C:\RobloxDev\roblox-executions`, and try again.
>
> If Studio doesn't show the Rojo button, restart Studio after step 5.
>
> **The Rojo version in Studio must match the one in `rokit.toml` (currently 7.7.1).** If Connect fails with a `protocolVersion` or version mismatch error, check the version shown in the Rojo plugin window. Either change the number in `rokit.toml` to match it and run `rokit install` again, or run `rojo plugin install` so the plugin matches the server. Only keep one Rojo plugin installed (don't mix the Creator Store one with `rojo plugin install`).

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

## The executions

Everything is **R6**. `CharacterSpawner` makes every player spawn as their own avatar in R6, even if the place is set to R15. You are the victim; the killer is an NPC.

| Key | Execution | What happens |
| --- | --- | --- |
| 1 | Back Saw | Chainsaw through the back and out the chest, lifted on the bar, shoved face down, head stomped until it caves in |
| 2 | Chest Carve | Two chainsaw slashes across the chest, the whole bar rammed in, drops to the knees trembling, falls on their face |
| 3 | Overhead Split | Kicked in the gut onto their knees, chainsaw brought down into the skull and ground all the way down, the body falls apart in two halves |
| 4 | Arm Rip | Arm torn clean off, then the head taken off with one swing |
| 5 | Throat Lift | Lifted by the throat, chainsaw in the gut, hoisted and slammed down |
| 6 | Drag Below | Grabbed from behind, bitten, saw driven into the shoulder, forced down into a black pool |

Each one has a cinematic camera with a handheld feel, movie bars, screen shake, a dark red picture and glowing eyes. Motion flows smoothly through the keyframes, both bodies blend in from where they were standing, and the victim's body drops as a ragdoll instead of falling apart. The Roblox "oof" death sound is turned off (`MuteDeathSound.client.luau`).

Effects: blood spray and mist particles, bloody chunks, chainsaw sparks on bone, exhaust smoke, bleeding wounds that stick to the body, blood splashing onto the screen, a camera "punch" and a split-second freeze (hit-stop) on the big hits. Sounds: chainsaw revs, a running saw loop, cutting, bone snaps, gore, rips, stomps, body falls and a horror sting, each picked at random from a few options.

**Voice:** the victim screams, grunts, chokes and gasps. Press **V** to switch your voice between **Female**, **Male** and **Off**. The default is at the top of `src/shared/Executions/Sounds.luau`.

> Roblox only allows this much blood and gore in experiences rated for older players. Before publishing, fill in the **Maturity & Compliance** questionnaire on the Creator Dashboard honestly.

| File | What it does |
| --- | --- |
| `src/shared/Executions/Moves/*.luau` | One file per execution: keyframes for both bodies, the camera, effects, and limbs torn off |
| `src/shared/Executions/Kit.luau` | The engine that plays keyframes on R6 bodies (read the notes at the top) |
| `src/shared/Executions/Registry.luau` | The list of executions and their order (keys 1, 2, 3...) |
| `src/server/Executions/ExecutionRunner.luau` | Runs one execution: freezes both bodies, tears off limbs, kills the victim |
| `src/server/Executions/KillerNPC.server.luau` | Spawns the killer and makes it chase players (speed and range at the top) |
| `src/server/Executions/ExecutionService.server.luau` | The 1-6 / E testing keys and the V voice switch |
| `src/server/Player/CharacterSpawner.server.luau` | Spawns players as their own avatar in R6 |
| `src/server/Player/KillerBuilder.luau` | Builds the killer and its chainsaw out of parts |
| `src/client/Executions/ExecutionPlayer.client.luau` | Plays the execution on each player's screen |
| `src/shared/Executions/Sounds.luau` | Every sound id and voice line, and the default voice |
| `src/client/Executions/Effects.luau` | All the effects (blood, sparks, wounds, screen blood, hit-stop, sounds, voice...). The list is at the top |
| `src/client/Executions/ExecutionInput.client.luau` | The keys and the help text in the corner |
| `tools/preview/preview.py` | Draws rough pictures of each execution and warns about cameras inside bodies or limbs going through the floor |

### Using your own killer model

1. Make (or get permission to use) an **R6** model with a Humanoid.
2. In Studio, drag it into **ReplicatedStorage** and rename it to **KillerModel**.
3. Press Play. The killer now looks like that model. If it has no part or model named `Chainsaw`, the default chainsaw goes in its right hand.

Delete `KillerModel` to go back to the built-in killer.

### Adding sounds

All sound ids are in `src/shared/Executions/Sounds.luau`. They are free sounds from the Roblox Creator Store, picked by their names, so some may not fit. To swap one: in Studio open **View > Toolbox > Audio**, find a sound, right click it, choose **Copy Asset ID** and paste the number into the list. Each name can have several ids; one is picked at random each time.

### Making a new execution

1. Copy a file in `src/shared/Executions/Moves`, for example `ThroatLift.luau`, and rename it (e.g. `MyMove.luau`).
2. Add `"MyMove"` to `Order` in `Registry.luau`. It gets the next number key.
3. Change the keyframes. Each keyframe says where the body is (`root`) and how the joints are bent (`pose`) at a time `t` in seconds. The notes at the top of `Kit.luau` explain every number.
4. Save. Rojo syncs it into Studio, so just press Play again to try it.

## Saving your work

When you change files, save them to GitHub with:

```powershell
git add .
git commit -m "Describe what you changed"
git push
```
