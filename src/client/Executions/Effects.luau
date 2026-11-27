-- Effects.luau
-- Screen and world effects for executions. Moves trigger these from their
-- Events list, e.g. { t = 1.2, fx = "Shake", power = 1 }.
--
--   Shake    power             camera shake (only for the killer and victim)
--   Flash    color alpha time  quick colour flash on screen
--   Darken   amount time       darker, redder picture (0 = normal, 1 = very dark)
--   Punch    amount            the camera lurches in for a moment (field of view kick)
--   HitStop  time              the animation freezes for a split second on a big hit
--   Splatter amount            blood splashes onto the screen and runs down
--   Blood    who part amount   blood spray from a body part ("Head", "Torso"...)
--   Gibs     who part amount   bloody chunks flying off a body part
--   Sparks   who part amount   sparks where the chainsaw hits bone
--   Smoke    amount            puff of exhaust smoke from the chainsaw
--   Wound    who part side x y size   a bleeding wound stuck on a body part
--                              (side = "Front" or "Back", x/y = where on it)
--   Pool     who size time     black pool growing on the floor under someone
--   Eyes     on                the killer's eyes glow red (on = true / false)
--   Crush    who part          squashes a body part flat (head stomps) with lots of blood
--   Sound    sound volume      plays a sound (names are in Shared/Executions/Sounds)
--   Voice    line              the victim's voice: "Scream", "Grunt", "Choke", "Gasp"
--   SawLoop  on                chainsaw running sound on / off

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Sounds = require(ReplicatedStorage:WaitForChild("Shared").Executions.Sounds)

local SMOKE_TEXTURE = "rbxasset://textures/particles/smoke_main.dds"
local SPARK_TEXTURE = "rbxasset://textures/particles/sparkles_main.dds"
local FLESH_COLOR = Color3.fromRGB(120, 20, 20)

local BLOOD_COLOR = Color3.fromRGB(95, 0, 0)
local EYE_COLOR = Color3.fromRGB(255, 30, 30)

local player = Players.LocalPlayer

local Effects = {}
Effects.__index = Effects

local function tween(instance: Instance, time: number, props)
	local t = TweenService:Create(instance, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function plainPart(props): Part
	local part = Instance.new("Part")
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props do
		part[key] = value
	end
	return part
end

-- involved = true if the local player is the killer or the victim
function Effects.new(involved: boolean, killer: Model, victim: Model)
	local self = setmetatable({}, Effects)
	self.Involved = involved
	self.Killer = killer
	self.Victim = victim
	self.ShakePower = 0
	self.PunchAmount = 0
	self.HoldUntil = -1 -- hit-stop: animation time stays frozen until this
	self.Leftovers = {}

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { killer, victim }
	self.RayParams = params

	if involved then
		local grade = Instance.new("ColorCorrectionEffect")
		grade.Name = "ExecutionGrade"
		grade.Parent = Lighting
		self.Grade = grade

		local gui = Instance.new("ScreenGui")
		gui.Name = "ExecutionOverlay"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.DisplayOrder = 50
		gui.Parent = player:WaitForChild("PlayerGui")
		self.Gui = gui

		-- black movie bars
		self.Bars = {}
		for _, bottom in { false, true } do
			local bar = Instance.new("Frame")
			bar.BackgroundColor3 = Color3.new(0, 0, 0)
			bar.BorderSizePixel = 0
			bar.AnchorPoint = Vector2.new(0, if bottom then 1 else 0)
			bar.Position = UDim2.fromScale(0, if bottom then 1 else 0)
			bar.Size = UDim2.fromScale(1, 0)
			bar.Parent = gui
			tween(bar, 0.3, { Size = UDim2.fromScale(1, 0.11) })
			table.insert(self.Bars, bar)
		end

		local flash = Instance.new("Frame")
		flash.BorderSizePixel = 0
		flash.Size = UDim2.fromScale(1, 1)
		flash.BackgroundTransparency = 1
		flash.Parent = gui
		self.FlashFrame = flash
	end

	return self
end

function Effects:_groundBelow(position: Vector3): RaycastResult?
	return workspace:Raycast(position + Vector3.new(0, 1, 0), Vector3.new(0, -25, 0), self.RayParams)
end

function Effects:_part(event, default: string): BasePart?
	local character = self[event.who or "Victim"]
	local part = character and character:FindFirstChild(event.part or default)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end

-- A one-off burst of particles at a spot. Built-in Roblox textures only.
local function burst(position: Vector3, count: number, props)
	local holder = Instance.new("Attachment")
	holder.Parent = workspace.Terrain
	holder.WorldPosition = position
	local emitter = Instance.new("ParticleEmitter")
	emitter.Enabled = false
	emitter.Rate = 0
	for key, value in props do
		emitter[key] = value
	end
	emitter.Parent = holder
	emitter:Emit(count)
	Debris:AddItem(holder, 3)
end

local function bloodSpray(position: Vector3, amount: number)
	-- fine mist
	burst(position, math.ceil(amount * 0.6), {
		Texture = SMOKE_TEXTURE,
		Color = ColorSequence.new(Color3.fromRGB(110, 0, 0), Color3.fromRGB(50, 0, 0)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.3), NumberSequenceKeypoint.new(1, 1.4) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1) }),
		Lifetime = NumberRange.new(0.25, 0.6),
		Speed = NumberRange.new(3, 8),
		SpreadAngle = Vector2.new(70, 70),
		Drag = 6,
		LightInfluence = 1,
		Rotation = NumberRange.new(0, 360),
		Acceleration = Vector3.new(0, -10, 0),
	})
	-- droplets that arc and fall
	burst(position, amount * 2, {
		Texture = SMOKE_TEXTURE,
		Color = ColorSequence.new(Color3.fromRGB(120, 0, 0)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 0.06) }),
		Transparency = NumberSequence.new(0.05),
		Lifetime = NumberRange.new(0.5, 1),
		Speed = NumberRange.new(6, 16),
		SpreadAngle = Vector2.new(55, 55),
		Acceleration = Vector3.new(0, -workspace.Gravity * 0.35, 0),
		Drag = 1,
		LightInfluence = 1,
	})
end

local handlers = {}

function handlers.Shake(self, event)
	self.ShakePower = math.max(self.ShakePower, event.power or 0.5)
end

function handlers.Flash(self, event)
	if not self.FlashFrame then
		return
	end
	self.FlashFrame.BackgroundColor3 = event.color or Color3.new(1, 1, 1)
	self.FlashFrame.BackgroundTransparency = 1 - (event.alpha or 0.3)
	tween(self.FlashFrame, event.time or 0.3, { BackgroundTransparency = 1 })
end

function handlers.Darken(self, event)
	if not self.Grade then
		return
	end
	local a = event.amount or 0.5
	tween(self.Grade, event.time or 0.5, {
		Brightness = -0.15 * a,
		Contrast = 0.3 * a,
		Saturation = -0.7 * a,
		TintColor = Color3.new(1, 1 - 0.35 * a, 1 - 0.35 * a),
	})
end

function handlers.Blood(self, event)
	local character = self[event.who or "Victim"]
	local part = character and character:FindFirstChild(event.part or "Torso")
	if not (part and part:IsA("BasePart")) then
		return
	end
	local origin = part.Position
	bloodSpray(origin, event.amount or 8)
	for _ = 1, math.ceil((event.amount or 8) * 0.6) do
		local drop = plainPart({
			Name = "Blood",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * (0.15 + math.random() * 0.2),
			Color = BLOOD_COLOR,
			CFrame = CFrame.new(origin),
		})
		drop.CanCollide = true
		drop.Parent = workspace
		drop.AssemblyLinearVelocity = Vector3.new(math.random(-8, 8), math.random(4, 14), math.random(-8, 8))
		Debris:AddItem(drop, 2.5)
	end
	-- a splat on the floor
	local hit = self:_groundBelow(origin)
	if hit then
		local size = 0.8 + math.random() * 1.2
		local splat = plainPart({
			Name = "BloodSplat",
			Anchored = true,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(0.05, size, size),
			Color = BLOOD_COLOR,
			CFrame = CFrame.new(hit.Position + Vector3.new(math.random() - 0.5, 0.03, math.random() - 0.5))
				* CFrame.Angles(0, 0, math.rad(90)),
		})
		splat.Parent = workspace
		Debris:AddItem(splat, 10)
	end
end

function handlers.Pool(self, event)
	local character = self[event.who or "Victim"]
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local hit = root and self:_groundBelow(root.Position)
	if not hit then
		return
	end
	local size = event.size or 7
	local pool = plainPart({
		Name = "DarkPool",
		Anchored = true,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(0.06, 0.5, 0.5),
		Color = Color3.fromRGB(6, 0, 0),
		CFrame = CFrame.new(hit.Position + Vector3.new(0, 0.04, 0)) * CFrame.Angles(0, 0, math.rad(90)),
	})
	pool.Parent = workspace
	tween(pool, event.time or 0.8, { Size = Vector3.new(0.06, size, size) })
	table.insert(self.Leftovers, pool)
end

function handlers.Eyes(self, event)
	if event.on == false then
		self:_removeEyes()
		return
	end
	if self.EyeParts then
		return
	end
	local head = self.Killer:FindFirstChild("Head")
	if not (head and head:IsA("BasePart")) then
		return
	end
	self.EyeParts = {}
	-- put two glowing eyes just in front of the face
	local front = -(head.Size.Z / 2) - 0.22
	for _, x in { -0.25, 0.25 } do
		local eye = plainPart({
			Name = "GlowEye",
			Shape = Enum.PartType.Ball,
			Size = Vector3.one * 0.16,
			Color = EYE_COLOR,
			Material = Enum.Material.Neon,
			Massless = true,
			CFrame = head.CFrame * CFrame.new(x, 0.2, front),
		})
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = head
		weld.Part1 = eye
		weld.Parent = eye
		eye.Parent = head
		table.insert(self.EyeParts, eye)
	end
	local light = Instance.new("PointLight")
	light.Color = EYE_COLOR
	light.Range = 8
	light.Brightness = 3
	light.Parent = self.EyeParts[1]
end

function handlers.Crush(self, event)
	local character = self[event.who or "Victim"]
	local part = character and character:FindFirstChild(event.part or "Head")
	if not (part and part:IsA("BasePart")) then
		return
	end
	local squash = Vector3.new(1.4, 0.25, 1.4)
	local mesh = part:FindFirstChildOfClass("SpecialMesh")
	if mesh then
		mesh.Scale *= squash
	else
		part.Size *= squash
	end
	-- hide the face and anything worn on that part (hats, hair)
	for _, item in part:GetChildren() do
		if item:IsA("Decal") then
			item.Transparency = 1
		end
	end
	for _, accessory in character:GetChildren() do
		local handle = accessory:IsA("Accessory") and accessory:FindFirstChild("Handle")
		local weld = handle and handle:FindFirstChildWhichIsA("JointInstance")
		if weld and (weld.Part0 == part or weld.Part1 == part) then
			handle.Transparency = 1
		end
	end
	handlers.Blood(self, { who = event.who, part = part.Name, amount = event.amount or 30 })
end

function handlers.Gibs(self, event)
	local part = self:_part(event, "Torso")
	if not part then
		return
	end
	for _ = 1, event.amount or 6 do
		local size = 0.15 + math.random() * 0.3
		local chunk = plainPart({
			Name = "Gib",
			Size = Vector3.new(size, size * (0.6 + math.random() * 0.6), size),
			Color = if math.random() < 0.5 then FLESH_COLOR else BLOOD_COLOR,
			Material = Enum.Material.Glass,
			Reflectance = 0.05,
			CFrame = part.CFrame * CFrame.new((math.random() - 0.5) * 0.8, (math.random() - 0.5) * 0.8, 0)
				* CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6),
		})
		chunk.CanCollide = true
		chunk.Parent = workspace
		chunk.AssemblyLinearVelocity = Vector3.new(math.random(-10, 10), math.random(6, 16), math.random(-10, 10))
		chunk.AssemblyAngularVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
		Debris:AddItem(chunk, 4)
	end
	bloodSpray(part.Position, 10)
end

function handlers.Sparks(self, event)
	local part = self:_part(event, "Torso")
	if not part then
		return
	end
	burst(part.Position, event.amount or 25, {
		Texture = SPARK_TEXTURE,
		Color = ColorSequence.new(Color3.fromRGB(255, 220, 120), Color3.fromRGB(255, 90, 20)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.18), NumberSequenceKeypoint.new(1, 0) }),
		LightEmission = 1,
		Lifetime = NumberRange.new(0.15, 0.45),
		Speed = NumberRange.new(12, 26),
		SpreadAngle = Vector2.new(80, 80),
		Acceleration = Vector3.new(0, -60, 0),
		Drag = 2,
	})
end

function handlers.Smoke(self, event)
	local engine = self.Killer:FindFirstChild("Engine", true) or self.Killer:FindFirstChild("Right Arm")
	if not (engine and engine:IsA("BasePart")) then
		return
	end
	burst(engine.Position, event.amount or 12, {
		Texture = SMOKE_TEXTURE,
		Color = ColorSequence.new(Color3.fromRGB(90, 90, 90), Color3.fromRGB(40, 40, 40)),
		Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 2.2) }),
		Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) }),
		Lifetime = NumberRange.new(0.8, 1.6),
		Speed = NumberRange.new(1.5, 4),
		SpreadAngle = Vector2.new(40, 40),
		Acceleration = Vector3.new(0, 2, 0),
		Drag = 2,
		Rotation = NumberRange.new(0, 360),
		RotSpeed = NumberRange.new(-60, 60),
	})
end

-- A wound stuck to the body: it moves with the body and keeps dripping
function handlers.Wound(self, event)
	local part = self:_part(event, "Torso")
	if not part then
		return
	end
	local size = event.size or 0.7
	local back = event.side == "Back"
	local depth = part.Size.Z / 2 + 0.02
	local spot = part.CFrame
		* CFrame.new(event.x or 0, event.y or 0, if back then depth else -depth)
		* CFrame.Angles(0, 0, math.rad(math.random(-30, 30)))
	local wound = plainPart({
		Name = "Wound",
		Size = Vector3.new(size * 0.55, size, 0.04),
		Color = Color3.fromRGB(40, 0, 0),
		Material = Enum.Material.Glass,
		Massless = true,
		CFrame = spot,
	})
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = part
	weld.Part1 = wound
	weld.Parent = wound
	local drip = Instance.new("ParticleEmitter")
	drip.Texture = SMOKE_TEXTURE
	drip.Color = ColorSequence.new(Color3.fromRGB(100, 0, 0))
	drip.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.12), NumberSequenceKeypoint.new(1, 0.05) })
	drip.Lifetime = NumberRange.new(0.4, 0.8)
	drip.Speed = NumberRange.new(0.5, 1.5)
	drip.SpreadAngle = Vector2.new(20, 20)
	drip.Acceleration = Vector3.new(0, -30, 0)
	drip.EmissionDirection = if back then Enum.NormalId.Back else Enum.NormalId.Front
	drip.Rate = 20
	drip.LightInfluence = 1
	drip.Parent = wound
	task.delay(6, function()
		drip.Enabled = false
	end)
	wound.Parent = part.Parent
	-- if the body part is hidden (pulled under the floor, cut away), hide the wound too
	part:GetPropertyChangedSignal("Transparency"):Connect(function()
		if part.Transparency >= 1 then
			wound:Destroy()
		end
	end)
end

function handlers.Punch(self, event)
	self.PunchAmount = math.max(self.PunchAmount, event.amount or 8)
end

function handlers.HitStop(self, event)
	self.HoldUntil = math.max(self.HoldUntil, event.t + (event.time or 0.08))
end

-- Blood splashed onto the screen; it runs down and fades
function handlers.Splatter(self, event)
	if not self.Gui then
		return
	end
	for _ = 1, event.amount or 5 do
		local size = math.random(40, 170)
		local drop = Instance.new("Frame")
		drop.BorderSizePixel = 0
		drop.AnchorPoint = Vector2.new(0.5, 0.5)
		drop.BackgroundColor3 = Color3.fromRGB(math.random(70, 110), 0, 0)
		drop.BackgroundTransparency = 0.15
		drop.Position = UDim2.fromScale(math.random(5, 95) / 100, math.random(10, 80) / 100)
		drop.Size = UDim2.fromOffset(size, size * (0.8 + math.random() * 0.5))
		drop.Rotation = math.random(0, 360)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0.5, 0)
		corner.Parent = drop
		drop.Parent = self.Gui
		local life = 1.2 + math.random() * 1.2
		TweenService:Create(drop, TweenInfo.new(life, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
			Position = drop.Position + UDim2.fromScale(0, 0.06 + math.random() * 0.08),
			Size = UDim2.fromOffset(size * 0.8, size * 1.6),
		}):Play()
		Debris:AddItem(drop, life + 0.1)
	end
end

local function pick(entry)
	if not entry or #entry[1] == 0 then
		return nil
	end
	return `rbxassetid://{entry[1][math.random(#entry[1])]}`, entry[2] or 1
end

function Effects:_playSound(entry, parent: Instance, volume: number?, looped: boolean?): Sound?
	local id, baseVolume = pick(entry)
	if not id then
		return nil
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = baseVolume * (volume or 1)
	sound.PlaybackSpeed = 0.93 + math.random() * 0.14
	sound.RollOffMaxDistance = 120
	sound.Looped = looped == true
	sound.Parent = parent
	sound:Play()
	if not looped then
		Debris:AddItem(sound, 10)
	end
	return sound
end

function handlers.Sound(self, event)
	-- old moves used Sound "Scream": that is a voice line now
	if not Sounds.Effects[event.sound] and Sounds.Voice.Female[event.sound] then
		handlers.Voice(self, { line = event.sound, volume = event.volume })
		return
	end
	local part = self:_part(event, "HumanoidRootPart") or self.Killer:FindFirstChild("HumanoidRootPart")
	if part then
		self:_playSound(Sounds.Effects[event.sound], part, event.volume)
	end
end

-- The victim's voice (Female / Male / Off, picked by the victim player with V)
function handlers.Voice(self, event)
	local owner = Players:GetPlayerFromCharacter(self.Victim)
	local voice = owner and owner:GetAttribute("Voice") or Sounds.DefaultVoice
	local lines = Sounds.Voice[voice]
	local head = self.Victim:FindFirstChild("Head") or self.Victim:FindFirstChild("HumanoidRootPart")
	if lines and head then
		self:_playSound(lines[event.line], head, event.volume)
	end
end

function handlers.SawLoop(self, event)
	if event.on == false then
		if self.SawSound then
			local sound = self.SawSound
			self.SawSound = nil
			tween(sound, 0.4, { Volume = 0 })
			Debris:AddItem(sound, 0.5)
		end
		return
	end
	if self.SawSound then
		return
	end
	local engine = self.Killer:FindFirstChild("Engine", true) or self.Killer:FindFirstChild("HumanoidRootPart")
	if engine then
		self.SawSound = self:_playSound(Sounds.SawLoop, engine, event.volume, true)
	end
end

function Effects:Run(event)
	local handler = handlers[event.fx]
	if handler then
		handler(self, event)
	else
		warn("Unknown execution effect:", event.fx)
	end
end

-- Called every frame by the camera: returns a small random wobble
function Effects:CameraShake(dt: number): CFrame
	self.ShakePower = math.max(0, self.ShakePower - dt * 3)
	local p = self.ShakePower
	if p <= 0 then
		return CFrame.identity
	end
	local clock = os.clock() * 25
	local x = math.noise(clock, 0.1) * p
	local y = math.noise(clock, 5.3) * p
	local roll = math.noise(clock, 9.7) * p
	return CFrame.new(x * 0.3, y * 0.3, 0) * CFrame.Angles(math.rad(y * 3), math.rad(x * 3), math.rad(roll * 4))
end

-- Called every frame by the camera: how much to zoom in for a "punch"
function Effects:CameraFov(dt: number): number
	self.PunchAmount *= math.exp(-dt * 7)
	return -self.PunchAmount
end

function Effects:_removeEyes()
	if self.EyeParts then
		for _, eye in self.EyeParts do
			eye:Destroy()
		end
		self.EyeParts = nil
	end
end

function Effects:Destroy()
	self:_removeEyes()
	handlers.SawLoop(self, { on = false })
	if self.Grade then
		local grade = self.Grade
		tween(grade, 0.8, { Brightness = 0, Contrast = 0, Saturation = 0, TintColor = Color3.new(1, 1, 1) })
		task.delay(0.9, function()
			grade:Destroy()
		end)
	end
	if self.Gui then
		local gui = self.Gui
		for _, bar in self.Bars do
			tween(bar, 0.4, { Size = UDim2.fromScale(1, 0) })
		end
		task.delay(0.5, function()
			gui:Destroy()
		end)
	end
	-- the pool fades away after a few seconds
	for _, item in self.Leftovers do
		task.delay(3, function()
			tween(item, 1.5, { Transparency = 1 })
			task.wait(1.6)
			item:Destroy()
		end)
	end
end

return Effects
