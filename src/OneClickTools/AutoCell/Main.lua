local common = require(script.Parent.Parent.Parent.ToolsCommon)
local cross = require(script.Parent.Parent.Parent.CrossTool)

local DEFAULT_ROOF_HEIGHT = 50
local INFLATE_STUDS = 1

local function InstanceIsWedge(instance: Instance)
	return instance:IsA("WedgePart") or instance:IsA("Part") and instance.Shape == Enum.PartType.Wedge
end

local function GenSlopePart(wedge: BasePart)
	
	local slopePart = wedge:Clone()
	slopePart.Shape = Enum.PartType.Block
	
	-- For some forsaken reason, Instance.new("Part") generates a part with inlets/studs
	slopePart.TopSurface = Enum.SurfaceType.Smooth
	slopePart.BottomSurface = Enum.SurfaceType.Smooth
	
	slopePart.Size = Vector3.new( wedge.Size.X, 0.5, math.sqrt(wedge.Size.Y^2 + wedge.Size.Z^2) )
	slopePart.Size = Vector3.new( slopePart.Size.X, slopePart.Size.Z * 0.5, slopePart.Size.Z )
	
	slopePart.CFrame = slopePart.CFrame * CFrame.Angles(math.atan2(wedge.Size.Y, wedge.Size.Z), 0, 0):Inverse()
	
	slopePart.Position = slopePart.Position - ( slopePart.CFrame:VectorToWorldSpace(Vector3.new(0, slopePart.Size.Z, 0)) * 0.25 )
	
	return slopePart
	
end

local function PartNormalize(part: BasePart, inflateSize: boolean)
	if inflateSize == nil then inflateSize = true end
	local noY = CFrame.new(part.CFrame.Position) * CFrame.fromEulerAnglesXYZ(math.rad(part.Rotation.X), 0, math.rad(part.Rotation.Z))
	part.Size = noY:VectorToWorldSpace(part.Size):Abs()
	part.CFrame = CFrame.new(part.CFrame.Position) * CFrame.fromEulerAnglesXYZ(0, math.rad(part.Rotation.Y), 0)
	part.Anchored = true
	
	local inflateAmt = 0
	if inflateSize then
		inflateAmt = INFLATE_STUDS * 2
	end
	part.Size = Vector3.new(part.Size.X + inflateAmt, 0.05, part.Size.Z + inflateAmt)
end

local function BasePartToCellPart(part)
	if InstanceIsWedge(part) then
		part = GenSlopePart(part)
	elseif part.Shape == Enum.PartType.Block then
		part = part:Clone()
	else
		return nil
	end
	PartNormalize(part)
	return part
end

local roofFindRaycast = RaycastParams.new()
roofFindRaycast.FilterType = Enum.RaycastFilterType.Include

local function FindRoof(part, filter)
	if type(filter) ~= "table" then filter = { filter } end
	roofFindRaycast.FilterDescendantsInstances = filter
	
	local result = workspace:Raycast(part.Position, Vector3.yAxis * DEFAULT_ROOF_HEIGHT, roofFindRaycast)
	if result == nil then return DEFAULT_ROOF_HEIGHT end
	
	local hitDist = result.Distance
	if hitDist < 6 and result.Instance:IsA("BasePart") then
		return FindRoof(result.Instance, filter)
	end
	
	return hitDist + 0.1
end

local function GenCells()
	
	local missionFolder = common:LevelFolder()
	if missionFolder == nil then
		warn("Failed to find DebugMission folder!")
		return
	end

	local cellsFolder = missionFolder:FindFirstChild("Cells")
	if cellsFolder == nil then
		warn("Failed to find Cells folder!")
		return
	end

	local geomFolder = missionFolder:FindFirstChild("Geometry")
	if geomFolder == nil then
		warn("Failed to find Geometry folder!")
		return
	end
	
	local recording = common:RecordChanges("Generate Cell")
	if not recording then return end
	
	local newCell = Instance.new("Model")
	newCell.Name = "Default"
	
	local selection = common:GetSelection()
	if #selection == 1 then
		local selected = selection[1]
		if selected:IsA("Folder") or selected:IsA("Model") then
			print("AutoCell : Selection was a single container, will create cell from container's children with same name as the container!")
			selection = selected:GetChildren()
			newCell.Name = selected.Name
		end
	end
	
	local minCellHeight =  math.huge
	local maxCellHeight = -math.huge
	for _, selected in ipairs(selection) do
		local roofPart = BasePartToCellPart(selected)
		if roofPart == nil then
			if not selected:IsA("Folder") and not selected:IsA("Model") then
				warn(`Instance {selected} is not valid for automatic cell generation, only Block/Wedge parts are supported!`)
			end
			continue
		end
		
		roofPart.Parent = newCell
		roofPart.Name = "Roof"
		
		minCellHeight = math.min(selected.Position.Y, minCellHeight)
		maxCellHeight = math.max(FindRoof(selected, geomFolder), maxCellHeight)
	end
	
	for _, p in ipairs(newCell:GetChildren()) do
		p.Position = Vector3.new(p.Position.X, minCellHeight + maxCellHeight, p.Position.Z)
	end
	
	local cfr, s = newCell:GetBoundingBox()
	local floor = Instance.new("Part")
	floor.Parent = newCell
	floor.Name = "Floor"
	floor.CFrame = cfr
	floor.Size = s
	floor.Position = Vector3.new(floor.Position.X, minCellHeight, floor.Position.Z)
	PartNormalize(floor, false)
	
	newCell.Parent = cellsFolder
	
	cross.TryRun("CellFixup", {newCell})
	game:GetService("Selection"):Set({newCell})
	
	common:CommitChanges(recording)
	
end

return {
	ClickedCallback = GenCells,
	ID = "Auto Cell",
	Tooltip = "Automatically generate a cell from the selected parts. Supports block/wedge parts only.",
	IconAssetID = "rbxassetid://97216440144955",
	LightIconAssetID = "rbxassetid://97216440144955",
	UseWithoutViewport = false
}