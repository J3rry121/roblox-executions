-- KillerBuilder.luau
-- Makes the killer's body.
--
-- WANT YOUR OWN KILLER?
--   Put an R6 model in ReplicatedStorage and name it "KillerModel".
--   It needs a Humanoid, a HumanoidRootPart and the normal R6 parts
--   (Head, Torso, Left Arm, Right Arm, Left Leg, Right Leg).
--   If it has no part or model called "Chainsaw", the default chainsaw
--   is put in its right hand.
--   Only use a model you made yourself or have permission to use.
--
-- If there is no KillerModel, the built-in killer ("Sackhead") is made
-- out of parts: a big body with a sack mask, glowing eyes and a chainsaw.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KillerBuilder = {}

local function addPart(parent: BasePart, name: string, size: Vector3, offset: CFrame, props)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	for key, value in props or {} do
		part[key] = value
	end
	part.CFrame = parent.CFrame * offset

	local weld = Instance.new("Weld")
	weld.Part0 = parent
	weld.Part1 = part
	weld.C0 = offset
	weld.Parent = part
	part.Parent = parent

	return part
end

-- The chainsaw, built from parts, held in the right hand.
-- The bar carries on from the arm like a sword, so wherever the arm points
-- the saw points (arm down = saw dragging by the feet, arm forward = thrust).
function KillerBuilder.addChainsaw(character: Model)
	local arm = character:FindFirstChild("Right Arm") :: BasePart
	if not arm then
		return
	end
	local saw = Instance.new("Model")
	saw.Name = "Chainsaw"
	saw.Parent = character

	-- grip space: -Z runs along the bar, +Y is the top of the saw
	local grip = CFrame.new(0, -1, 0) * CFrame.Angles(math.rad(-90), 0, 0)
	local function piece(name, size, offset, props)
		local part = addPart(arm, name, size, grip * offset, props)
		part.Parent = saw
		return part
	end

	local rust = { Color = Color3.fromRGB(120, 38, 22), Material = Enum.Material.CorrodedMetal }
	local dark = { Color = Color3.fromRGB(35, 35, 38), Material = Enum.Material.Metal }
	local steel = { Color = Color3.fromRGB(150, 150, 155), Material = Enum.Material.Metal }

	local engine = piece("Engine", Vector3.new(0.75, 0.95, 1.1), CFrame.new(0, 0.25, -0.35), rust)
	-- thin exhaust smoke drifting off the engine all the time
	local exhaust = Instance.new("ParticleEmitter")
	exhaust.Name = "Exhaust"
	exhaust.Texture = "rbxasset://textures/particles/smoke_main.dds"
	exhaust.Color = ColorSequence.new(Color3.fromRGB(70, 70, 70))
	exhaust.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1.2) })
	exhaust.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 1) })
	exhaust.Lifetime = NumberRange.new(1, 2)
	exhaust.Speed = NumberRange.new(0.5, 1.5)
	exhaust.Acceleration = Vector3.new(0, 1.5, 0)
	exhaust.Rotation = NumberRange.new(0, 360)
	exhaust.RotSpeed = NumberRange.new(-40, 40)
	exhaust.Rate = 6
	exhaust.EmissionDirection = Enum.NormalId.Top
	exhaust.Parent = engine
	piece("Cover", Vector3.new(0.78, 0.25, 0.8), CFrame.new(0, 0.8, -0.35), dark)
	piece("Handle", Vector3.new(0.15, 0.6, 0.15), CFrame.new(0, 0.95, 0.05), dark)
	piece("Bar", Vector3.new(0.12, 0.5, 3.6), CFrame.new(0, 0, -2.7), steel)
	piece("ChainTop", Vector3.new(0.18, 0.08, 3.7), CFrame.new(0, 0.29, -2.7), dark)
	piece("ChainBottom", Vector3.new(0.18, 0.08, 3.7), CFrame.new(0, -0.29, -2.7), dark)
	piece("Tip", Vector3.new(0.18, 0.66, 0.66), CFrame.new(0, 0, -4.55) * CFrame.Angles(0, math.rad(90), 0), {
		Shape = Enum.PartType.Cylinder,
		Color = dark.Color,
		Material = dark.Material,
	})
	-- old stains on the bar
	piece("Stain", Vector3.new(0.14, 0.3, 0.9), CFrame.new(0, -0.05, -3.5), {
		Color = Color3.fromRGB(70, 0, 0),
		Material = Enum.Material.SmoothPlastic,
	})
end

local function makeDefaultKiller(): Model
	local description = Instance.new("HumanoidDescription")
	local skin = Color3.fromRGB(105, 100, 92)
	description.HeadColor = skin
	description.LeftArmColor = skin
	description.RightArmColor = skin
	description.TorsoColor = Color3.fromRGB(45, 38, 32)
	description.LeftLegColor = Color3.fromRGB(30, 28, 26)
	description.RightLegColor = Color3.fromRGB(30, 28, 26)

	local killer = Players:CreateHumanoidModelFromDescription(description, Enum.HumanoidRigType.R6)
	killer.Name = "Sackhead"

	local head = killer:FindFirstChild("Head") :: BasePart
	local torso = killer:FindFirstChild("Torso") :: BasePart
	local face = head:FindFirstChildOfClass("Decal")
	if face then
		face:Destroy()
	end

	local burlap = { Color = Color3.fromRGB(122, 98, 66), Material = Enum.Material.Fabric }
	local leather = { Color = Color3.fromRGB(40, 30, 24), Material = Enum.Material.Leather }
	local blood = { Color = Color3.fromRGB(80, 0, 0), Material = Enum.Material.SmoothPlastic }
	local iron = { Color = Color3.fromRGB(60, 60, 64), Material = Enum.Material.Metal }

	-- sack mask with stitched eye holes and mouth
	addPart(head, "Sack", Vector3.new(1.35, 1.4, 1.35), CFrame.new(0, 0.1, 0), burlap)
	addPart(head, "SackTie", Vector3.new(1.45, 0.18, 1.45), CFrame.new(0, -0.45, 0), { Color = Color3.fromRGB(70, 55, 35), Material = Enum.Material.Fabric })
	for _, x in { -0.25, 0.25 } do
		addPart(head, "EyeHole", Vector3.new(0.3, 0.3, 0.05), CFrame.new(x, 0.2, -0.68), { Color = Color3.new(0, 0, 0) })
		addPart(head, "Eye", Vector3.new(0.12, 0.12, 0.05), CFrame.new(x, 0.2, -0.7), {
			Color = Color3.fromRGB(255, 40, 30),
			Material = Enum.Material.Neon,
		})
	end
	for i = -2, 2 do
		addPart(head, "Stitch", Vector3.new(0.05, 0.2, 0.05), CFrame.new(i * 0.12, -0.2, -0.69), { Color = Color3.fromRGB(20, 15, 10) })
	end
	addPart(head, "Mouth", Vector3.new(0.6, 0.04, 0.05), CFrame.new(0, -0.2, -0.69), { Color = Color3.fromRGB(20, 15, 10) })

	-- bulk: heavy body, apron, hunched shoulders
	addPart(torso, "Bulk", Vector3.new(2.3, 2.1, 1.4), CFrame.new(0, 0, 0.05), leather)
	addPart(torso, "Hump", Vector3.new(2.0, 0.9, 0.8), CFrame.new(0, 0.75, 0.6), leather)
	addPart(torso, "Apron", Vector3.new(1.9, 2.4, 0.1), CFrame.new(0, -0.3, -0.76), { Color = Color3.fromRGB(150, 140, 120), Material = Enum.Material.Fabric })
	addPart(torso, "ApronStain", Vector3.new(0.9, 0.7, 0.05), CFrame.new(0.3, -0.6, -0.82), blood)
	addPart(torso, "ApronStain2", Vector3.new(0.4, 0.9, 0.05), CFrame.new(-0.5, 0.1, -0.82), blood)
	-- a heavy iron chain across the chest
	for i = 0, 7 do
		local x = -1 + i * 0.28
		local y = 0.8 - i * 0.24
		addPart(torso, "ChestChain", Vector3.new(0.3, 0.12, 0.22), CFrame.new(x, y, -0.86) * CFrame.Angles(0, 0, math.rad(40)), iron)
	end

	for _, side in { "Left Arm", "Right Arm" } do
		local arm = killer:FindFirstChild(side) :: BasePart
		addPart(arm, "ShoulderPad", Vector3.new(1.3, 0.9, 1.3), CFrame.new(0, 0.6, 0), leather)
		addPart(arm, "Wrap", Vector3.new(1.1, 0.4, 1.1), CFrame.new(0, -0.6, 0), { Color = Color3.fromRGB(110, 100, 80), Material = Enum.Material.Fabric })
	end
	for _, side in { "Left Leg", "Right Leg" } do
		local leg = killer:FindFirstChild(side) :: BasePart
		addPart(leg, "Boot", Vector3.new(1.15, 0.7, 1.25), CFrame.new(0, -0.7, -0.05), { Color = Color3.fromRGB(25, 22, 20), Material = Enum.Material.Leather })
	end

	return killer
end

-- Copies the walking animations from a normal R6 body if the model has none
local function ensureAnimate(character: Model)
	if character:FindFirstChild("Animate") then
		return
	end
	local temp = Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R6)
	local animate = temp:FindFirstChild("Animate")
	if animate then
		animate.Parent = character
	end
	temp:Destroy()
end

local function hasChainsaw(character: Model): boolean
	return character:FindFirstChild("Chainsaw", true) ~= nil
end

-- Returns a fresh killer body (custom KillerModel if there is one)
function KillerBuilder.build(): Model
	local custom = ReplicatedStorage:FindFirstChild("KillerModel")
	local killer
	if custom and custom:IsA("Model") and custom:FindFirstChildOfClass("Humanoid") and custom:FindFirstChild("Torso") then
		killer = custom:Clone()
		ensureAnimate(killer)
	else
		if custom then
			warn("ReplicatedStorage.KillerModel must be an R6 model with a Humanoid. Using the default killer.")
		end
		killer = makeDefaultKiller()
	end
	if not hasChainsaw(killer) then
		KillerBuilder.addChainsaw(killer)
	end
	return killer
end

return KillerBuilder
