local common = require(script.Parent.Parent.Parent.ToolsCommon)

local function InstanceIsWedge(instance: Instance)
	return instance:IsA("WedgePart") or instance:IsA("Part") and instance.Shape == Enum.PartType.Wedge
end

local function GenSlopePart(wedge: BasePart)
	
	local slopePart = wedge:Clone()
	slopePart.Parent = wedge.Parent
	slopePart.Shape = Enum.PartType.Block
	
	-- For some forsaken reason, Instance.new("Part") generates a part with inlets/studs
	slopePart.TopSurface = Enum.SurfaceType.Smooth
	slopePart.BottomSurface = Enum.SurfaceType.Smooth
	
	slopePart.Size = Vector3.new( wedge.Size.X, 0.5, math.sqrt(wedge.Size.Y^2 + wedge.Size.Z^2) )
	
	slopePart.CFrame = slopePart.CFrame * CFrame.Angles(math.atan2(wedge.Size.Y, wedge.Size.Z), 0, 0):Inverse()
	
end

local function GenSlopeParts()
	
	local recording = common:RecordChanges("Generate Slope Part(s)")
	if not recording then return end
	
	for _, selected in ipairs(common:GetSelection()) do
		if not InstanceIsWedge(selected) then warn(`Selection {selected.Name} isn't a Wedge! Skipping`) continue end
		GenSlopePart(selected)
	end
	
	common:CommitChanges(recording)
	
end

return {
	ClickedCallback = GenSlopeParts,
	ID = "Generate Slope Part",
	Tooltip = "For each selected wedge, generates a part at the center of it's slope facing the normal vector of the slope.",
	IconAssetID = "rbxassetid://73761969919675",
	LightIconAssetID = "rbxassetid://80151075507740",
	UseWithoutViewport = false
}