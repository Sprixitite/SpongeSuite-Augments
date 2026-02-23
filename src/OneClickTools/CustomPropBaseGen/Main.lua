local common = require(script.Parent.Parent.Parent.ToolsCommon)

local function BaseGen()
	
	local recording = common:RecordChanges("Generate Prop Base")
	if not recording then return end
	
	for _, v in pairs(common:GetSelection()) do
		if not v:IsA("Model") then warn(`Selection {v.Parent.Name}.{v.Name} is not a Model! Skipping`) continue end
		
		local basePart = common:FindFirstChildWithNameAndClass(v, "Base", "BasePart") 
		
		if basePart ~= nil then
			-- Ignore existing Base when getting bounds
			basePart.Parent = nil
		end
		
		local transform, size = v:GetBoundingBox()
		
		basePart = basePart or Instance.new("Part")
		basePart.Parent = v
		basePart.Transparency = 1
		basePart.CFrame = transform
		basePart.Size = size
		basePart.Name = "Base"
		basePart.Anchored = true
		
		basePart.TopSurface = Enum.SurfaceType.Smooth
		basePart.BottomSurface = Enum.SurfaceType.Smooth
		
	end
	
	common:CommitChanges(recording)
	
end

return {
	ClickedCallback = BaseGen,
	ID = "Generate Prop Base",
	Tooltip = "Generate the 'Base' part for the selected custom prop",
	IconAssetID = "rbxassetid://73246176602542",
	LightIconAssetID = "rbxassetid://101352653431755",
	UseWithoutViewport = true
}