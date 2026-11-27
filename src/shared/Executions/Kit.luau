-- Kit.luau
-- The engine that plays executions. Every execution in the Moves folder is
-- just a list of keyframes, and this module turns those keyframes into
-- moving R6 bodies. Both the server and every player use it.
--
-- HOW KEYFRAMES WORK
--   Everything is measured from the killer's starting spot ("the anchor"):
--     x = right(+) / left(-), y = up(+) / down(-), z = behind(+) / in front(-)
--   So a victim standing 6 studs in front of the killer is at z = -6.
--   The floor is at y = -3 (a standing R6 body's middle is 3 studs up).
--
--   root = { x, y, z, pitch, turn, roll }   where the whole body is
--     turn 180 = facing back towards the killer
--     pitch 90 = falling over backwards (lying on their back)
--
--   pose = { Head = {x, y, z}, RArm = {...}, ... }   joint angles in degrees
--     Joints: Head, Torso, RArm, LArm, RLeg, LLeg
--     x  = swing forward (arms/legs up in front), Head/Torso: + leans back
--     y  = twist (Head + turns to the left)
--     z  = out to the side (RArm/RLeg + goes right, LArm/LLeg - goes left)
--
--   ease = how it moves INTO this keyframe. Leave it out for smooth flowing
--          motion. Use "in" (speeds up into a hit), "out" (fast then settles),
--          "back" (overshoots a little), "inOut" or "linear" for sharp moments.
--   struggle = how much the limbs shake (degrees). 0 = still. It fades
--              smoothly between keyframes.
--
--   Anything you leave out of a keyframe stays the same as the keyframe
--   before it, so you only write what changes.

local Kit = {}

-- Short joint name -> Motor6D name in an R6 rig
Kit.JOINTS = {
	Head = "Neck",
	Torso = "RootJoint",
	RArm = "Right Shoulder",
	LArm = "Left Shoulder",
	RLeg = "Right Hip",
	LLeg = "Left Hip",
}

local ZERO3 = { 0, 0, 0 }

Kit.Ease = {
	linear = function(t)
		return t
	end,
	["in"] = function(t)
		return t * t * t
	end,
	out = function(t)
		return 1 - (1 - t) ^ 3
	end,
	inOut = function(t)
		if t < 0.5 then
			return 4 * t * t * t
		end
		return 1 - (-2 * t + 2) ^ 3 / 2
	end,
	back = function(t)
		local c1 = 1.70158
		local c3 = c1 + 1
		return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
	end,
}

local function pad(values, count: number)
	local out = table.create(count, 0)
	for i = 1, count do
		out[i] = values[i] or 0
	end
	return out
end

local function lerpArray(a, b, alpha: number)
	local out = table.create(#a)
	for i = 1, #a do
		out[i] = a[i] + (b[i] - a[i]) * alpha
	end
	return out
end

local function anglesToCFrame(angles): CFrame
	return CFrame.fromEulerAnglesYXZ(math.rad(angles[1]), math.rad(angles[2]), math.rad(angles[3]))
end

-- Turns a root array { x, y, z, pitch, turn, roll } into a CFrame
function Kit.rootCFrame(root): CFrame
	return CFrame.new(root[1], root[2], root[3])
		* CFrame.fromEulerAnglesYXZ(math.rad(root[4]), math.rad(root[5]), math.rad(root[6]))
end

-- Fills in the gaps in a body track so every keyframe has everything
local function prepareTrack(moveId: string, label: string, track)
	table.sort(track, function(a, b)
		return a.t < b.t
	end)
	local root = { 0, 0, 0, 0, 0, 0 }
	local struggle = 0
	local current = {}
	for name in Kit.JOINTS do
		current[name] = ZERO3
	end
	for _, key in track do
		if key.root then
			root = pad(key.root, 6)
		end
		struggle = key.struggle or struggle
		if key.pose then
			for name, angles in key.pose do
				if Kit.JOINTS[name] then
					current[name] = pad(angles, 3)
				else
					warn(`[Executions] {moveId}.{label} at t={key.t}: unknown joint "{name}"`)
				end
			end
		end
		local full = {}
		for name in Kit.JOINTS do
			full[name] = current[name]
		end
		key.root, key.struggle, key.pose = root, struggle, full
	end
end

local function prepareCamera(track)
	table.sort(track, function(a, b)
		return a.t < b.t
	end)
	local pos, look, fov = { 6, 2, 2 }, { 0, 1, -3 }, 70
	for _, key in track do
		pos = key.pos and pad(key.pos, 3) or pos
		look = key.look and pad(key.look, 3) or look
		fov = key.fov or fov
		key.pos, key.look, key.fov = pos, look, fov
	end
end

-- Called once per move by the Registry
function Kit.prepareMove(id: string, move)
	move.Id = id
	move.DisplayName = move.DisplayName or id
	move.Range = move.Range or 10
	assert(move.Killer and #move.Killer > 0, `{id} needs Killer keyframes`)
	assert(move.Victim and #move.Victim > 0, `{id} needs Victim keyframes`)
	assert(move.KillTime and move.Duration and move.KillTime <= move.Duration, `{id}: KillTime must be <= Duration`)
	prepareTrack(id, "Killer", move.Killer)
	prepareTrack(id, "Victim", move.Victim)
	move.Camera = move.Camera or { { t = 0 } }
	prepareCamera(move.Camera)
	-- Expand repeating events ({ repeatFor = 1, every = 0.1 }) into copies
	local events = {}
	for _, event in move.Events or {} do
		if event.repeatFor and event.every and event.every > 0 then
			local offset = 0
			while offset <= event.repeatFor + 1e-6 do
				local copy = table.clone(event)
				copy.t = event.t + offset
				table.insert(events, copy)
				offset += event.every
			end
		else
			table.insert(events, event)
		end
	end
	move.Events = events
	table.sort(move.Events, function(a, b)
		return a.t < b.t
	end)
	-- Things only the server does, e.g. { t = 1.4, action = "Detach", joint = "RArm" }
	move.ServerEvents = move.ServerEvents or {}
	for _, event in move.ServerEvents do
		assert(event.action == "Detach", `{id}: unknown server action {event.action}`)
		assert(Kit.JOINTS[event.joint], `{id}: Detach needs a joint name, got {event.joint}`)
	end
	return move
end

-- HOW IN-BETWEEN FRAMES ARE MADE
-- Keyframes with no ease (or ease = "smooth") are joined by a smooth curve
-- that flows through them without stopping, like a real animator's spline.
-- Keyframes with an ease ("in", "out", "inOut", "back", "linear") are hits:
-- the motion snaps into them and settles there, which keeps impacts sharp.

local function isSmooth(key): boolean
	return key.ease == nil or key.ease == "smooth"
end

-- Finds the keyframes around time t: index before, index after, 0-1 between
local function locate(track, t: number): (number, number, number)
	local count = #track
	if t <= track[1].t then
		return 1, 1, 0
	end
	if t >= track[count].t then
		return count, count, 0
	end
	for i = 1, count - 1 do
		local nextKey = track[i + 1]
		if t < nextKey.t then
			local span = nextKey.t - track[i].t
			return i, i + 1, if span > 0 then (t - track[i].t) / span else 1
		end
	end
	return count, count, 0
end

-- How fast the values are changing at keyframe k (nil = not moving)
local function tangent(track, k: number, get)
	local key = track[k]
	if k == 1 or k == #track or not isSmooth(key) then
		return nil
	end
	local before, after = track[k - 1], track[k + 1]
	local span = after.t - before.t
	if span <= 0 then
		return nil
	end
	local a, b = get(before), get(after)
	local out = table.create(#a)
	for n = 1, #a do
		out[n] = (b[n] - a[n]) / span
	end
	return out
end

local function interpolate(track, i: number, j: number, s: number, get)
	local a = get(track[i])
	if i == j then
		return table.clone(a)
	end
	local key = track[j]
	local b = get(key)
	if not isSmooth(key) then
		local ease = Kit.Ease[key.ease] or Kit.Ease.inOut
		return lerpArray(a, b, ease(s))
	end
	-- smooth curve (cubic Hermite)
	local dt = key.t - track[i].t
	local m1, m2 = tangent(track, i, get), tangent(track, j, get)
	local s2, s3 = s * s, s * s * s
	local h00, h10, h01, h11 = 2 * s3 - 3 * s2 + 1, s3 - 2 * s2 + s, -2 * s3 + 3 * s2, s3 - s2
	local out = table.create(#a)
	for n = 1, #a do
		local v = h00 * a[n] + h01 * b[n]
		if m1 then
			v += h10 * dt * m1[n]
		end
		if m2 then
			v += h11 * dt * m2[n]
		end
		out[n] = v
	end
	return out
end

local getRoot = function(key)
	return key.root
end
local getJoint = {}
for name in Kit.JOINTS do
	getJoint[name] = function(key)
		return key.pose[name]
	end
end
local getPos = function(key)
	return key.pos
end
local getLook = function(key)
	return key.look
end
local getFov = function(key)
	return { key.fov }
end

-- Returns root array, pose table, struggle amount at time t
function Kit.sample(track, t: number)
	local i, j, s = locate(track, t)
	local pose = {}
	for name in Kit.JOINTS do
		pose[name] = interpolate(track, i, j, s, getJoint[name])
	end
	local struggle = track[i].struggle + (track[j].struggle - track[i].struggle) * s
	return interpolate(track, i, j, s, getRoot), pose, struggle
end

-- Returns camera position, look-at point (both in anchor space) and field of view
function Kit.sampleCamera(track, t: number): (Vector3, Vector3, number)
	local i, j, s = locate(track, t)
	local pos = interpolate(track, i, j, s, getPos)
	local look = interpolate(track, i, j, s, getLook)
	local fov = interpolate(track, i, j, s, getFov)[1]
	return Vector3.new(pos[1], pos[2], pos[3]), Vector3.new(look[1], look[2], look[3]), fov
end

-- Finds the joints of an R6 character. Returns nil if it isn't R6.
function Kit.getRig(character: Model?)
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	local torso = character:FindFirstChild("Torso")
	if not (root and torso) then
		return nil
	end
	local rig = { Root = root, Motors = {}, Base = {} }
	for name, motorName in Kit.JOINTS do
		local parent = if name == "Torso" then root else torso
		local motor = parent:FindFirstChild(motorName)
		if not (motor and motor:IsA("Motor6D")) then
			return nil
		end
		rig.Motors[name] = motor
		rig.Base[name] = motor.C0.Rotation
	end
	return rig
end

-- The joint angles are written from the body's point of view, but each
-- R6 joint is turned a different way inside. This converts between them.
local function jointTransform(rig, name: string, angles): CFrame
	local base = rig.Base[name]
	return base:Inverse() * anglesToCFrame(angles) * base
end

-- Shows a pose (used every frame by players' computers).
-- blendFrom/blend: optional starting joint CFrames to fade in from (0 to 1)
function Kit.applyPose(rig, pose, blendFrom, blend: number?)
	for name, angles in pose do
		local motor = rig.Motors[name]
		if motor and motor.Parent then
			local target = jointTransform(rig, name, angles)
			if blendFrom and blend and blend < 1 and blendFrom[name] then
				target = blendFrom[name]:Lerp(target, blend)
			end
			motor.Transform = target
		end
	end
end

-- The joints' current CFrames, to blend from
function Kit.capturePose(rig)
	local out = {}
	for name, motor in rig.Motors do
		out[name] = motor.Transform
	end
	return out
end

-- Puts every joint back to normal
function Kit.clearPose(rig)
	for _, motor in rig.Motors do
		if motor.Parent then
			motor.Transform = CFrame.identity
		end
	end
end

-- Where a body part would be for a given root CFrame and pose (the server
-- uses this when it tears a limb off, so the limb starts where players saw it)
function Kit.partCFrame(rig, rootCFrame: CFrame, pose, name: string): CFrame
	local function step(parentCFrame: CFrame, jointName: string): CFrame
		local motor = rig.Motors[jointName]
		return parentCFrame * motor.C0 * jointTransform(rig, jointName, pose[jointName]) * motor.C1:Inverse()
	end
	local torso = step(rootCFrame, "Torso")
	if name == "Torso" then
		return torso
	end
	return step(torso, name)
end

-- Locks a pose into the joints for everyone (the server uses this right
-- before a kill so the body falls apart from the right position)
function Kit.bakePose(rig, pose)
	for name, angles in pose do
		local motor = rig.Motors[name]
		if motor and motor.Parent then
			motor.C0 = motor.C0 * jointTransform(rig, name, angles)
		end
	end
end

return Kit
