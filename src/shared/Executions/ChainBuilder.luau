-- ChainBuilder.luau
-- Builds a chain out of small metal "link" parts between two parts,
-- and keeps it attached while those parts move.
--
-- Usage:
--   local chain = ChainBuilder.new(handPart, targetPart)
--   chain:SetReach(0.5) -- 0 = chain fully pulled in, 1 = touching the target
--   chain:Destroy()

local RunService = game:GetService("RunService")

local LINK_SPACING = 0.5 -- distance between links (studs)
local LINK_SIZE = Vector3.new(0.18, 0.4, 0.62)
local LINK_COLOR = Color3.fromRGB(70, 70, 75)

local ChainBuilder = {}
ChainBuilder.__index = ChainBuilder

local function makeLink(parent: Instance): BasePart
	local link = Instance.new("Part")
	link.Name = "Link"
	link.Size = LINK_SIZE
	link.Color = LINK_COLOR
	link.Material = Enum.Material.Metal
	link.Anchored = true
	link.CanCollide = false
	link.CanQuery = false
	link.CanTouch = false
	link.CastShadow = false
	link.Parent = parent
	return link
end

function ChainBuilder.new(fromPart: BasePart, toPart: BasePart)
	local self = setmetatable({}, ChainBuilder)
	self.From = fromPart
	self.To = toPart
	self.Reach = 0
	self.Links = {}

	self.Model = Instance.new("Model")
	self.Model.Name = "Chain"
	self.Model.Parent = workspace

	-- Re-draw the chain every frame so it follows moving characters
	self._connection = RunService.Heartbeat:Connect(function()
		self:_update()
	end)
	self:_update()

	return self
end

function ChainBuilder:SetReach(alpha: number)
	self.Reach = math.clamp(alpha, 0, 1)
	self:_update()
end

function ChainBuilder:_update()
	if not (self.From.Parent and self.To.Parent) then
		return
	end

	local startPos = self.From.Position
	local endPos = startPos:Lerp(self.To.Position, self.Reach)
	local offset = endPos - startPos
	local length = offset.Magnitude
	local needed = if length > 0.05 then math.floor(length / LINK_SPACING) else 0

	-- Make more links if we need them
	while #self.Links < needed do
		table.insert(self.Links, makeLink(self.Model))
	end

	local direction = if length > 0.05 then offset.Unit else Vector3.zAxis
	for i, link in self.Links do
		if i <= needed then
			local pos = startPos + direction * (LINK_SPACING * (i - 0.5))
			-- Every other link is turned 90 degrees, like a real chain
			local twist = if i % 2 == 0 then math.rad(90) else 0
			link.CFrame = CFrame.lookAt(pos, pos + direction) * CFrame.Angles(0, 0, twist)
			link.Transparency = 0
		else
			link.Transparency = 1
		end
	end
end

function ChainBuilder:Destroy()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
	self.Model:Destroy()
end

return ChainBuilder
