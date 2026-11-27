-- Effects.luau
-- Screen and world effects for executions. Moves trigger these from their
-- Events list, e.g. { t = 1.2, fx = "Shake", power = 1 }.
--
--   Shake  power            camera shake (only for the killer and victim)
--   Flash  color alpha time quick colour flash on screen
--   Darken amount time      darker, redder picture (0 = normal, 1 = very dark)
--   Blood  who part amount  blood spray from a body part ("Head", "Torso"...)
--   Pool   who size time    black pool growing on the floor under someone
--   Eyes   on               the killer's eyes glow red (on = true / false)
--   Sound  sound            plays a sound from the Sounds list below

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Paste sound ids here, like "rbxassetid://1234567890". Find free sounds in
-- Studio: View > Toolbox > Audio. Leave "" for no sound.
local SOUNDS = {
	Sting = "", -- horror sting when it starts
	Grab = "",
	Snap = "",
	Bite = "",
	Drag = "",
	Rev = "", -- chainsaw starting up
	Saw = "", -- chainsaw cutting
}

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
	for _ = 1, event.amount or 8 do
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

function handlers.Sound(self, event)
	local id = SOUNDS[event.sound]
	if not id or id == "" then
		return
	end
	local root = self.Victim:FindFirstChild("HumanoidRootPart") or self.Killer:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end
	local sound = Instance.new("Sound")
	sound.SoundId = id
	sound.Volume = event.volume or 1
	sound.Parent = root
	sound:Play()
	Debris:AddItem(sound, 8)
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
