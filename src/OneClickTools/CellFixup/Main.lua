local common = require(script.Parent.Parent.Parent.ToolsCommon)
local crossTool = require(script.Parent.Parent.Parent.CrossTool)

-- Hash politely borrowed from the official Cell tools
local function hashName(name)
	if name == "Default" then
		return Color3.new(0, 0, 0)
	end

	local h = 5^7
	local n = 0
	for i = 1, #name do
		n = (n * 257 + string.byte(name, i, i)) % h 
	end
	local color = Color3.fromHSV((n % 1000) / 1000, 0.5, 0.5)
	return color
end

local function FixCell(cell, cellPart, cellCol)
	cellPart.Color = cellCol
	cellPart.CastShadow = false
	cellPart.Material = Enum.Material.Plastic
	cellPart.Transparency = 0.5
	cellPart.TopSurface = Enum.SurfaceType.Studs
	cellPart.BottomSurface = Enum.SurfaceType.Inlet
	cellPart.Anchored = true

	if cellPart.Shape ~= Enum.PartType.Block then warn(`Cell Part {cell.Name}.{cellPart.Name} is non-block shape {tostring(cellPart.Shape)}!`) end
end

local function LinkTexture(normal)
	local tex = Instance.new("Texture")
	tex.Texture = "rbxassetid://124542772943020"
	tex.StudsPerTileU = 3
	tex.StudsPerTileV = 1
	tex.Face = normal
	tex.Name = `Texture{normal.Name}`
	return tex
end

local function FixLink(linkPart)
	linkPart.Color = Color3.fromRGB(127, 63, 65)
	linkPart.CastShadow = false
	linkPart.Material = Enum.Material.Plastic
	linkPart.Transparency = 0.5
	linkPart.TopSurface = Enum.SurfaceType.Smooth
	linkPart.BottomSurface = Enum.SurfaceType.Smooth

	if linkPart:FindFirstChild("TextureFront") == nil then
		local frontTex = LinkTexture(Enum.NormalId.Front)
		frontTex.Parent = linkPart
	end

	if linkPart:FindFirstChild("TextureBack") == nil then
		local backTex = LinkTexture(Enum.NormalId.Back)
		backTex.Parent = linkPart
	end

	for k, v in next, linkPart:GetChildren() do
		if typeof(v) ~= "Instance" then continue end
		if v.Name == "TextureFront" then continue end
		if v.Name == "TextureBack" then continue end
		v:Destroy()
	end
end

local function CellFixup_Public(cells)
	for _, cell in ipairs(cells) do
		local cellColour = hashName(cell.Name)
		if cell.Name == "Links" then
			for _, linkPart in next, cell:GetChildren() do
				if not linkPart:IsA("BasePart") then continue end
				FixLink(linkPart)
			end
		else
			for _, cellPart in next, cell:GetChildren() do
				if not cellPart:IsA("BasePart") then continue end
				FixCell(cell, cellPart, cellColour)
			end
		end
	end
end

crossTool.Register("CellFixup", CellFixup_Public)

local function CellFixup()
	local missionFolder = common:LevelFolder()
	if missionFolder == nil then warn("Failed to find Custom Mission folder!") return end
	
	if missionFolder:FindFirstChild("Cells") == nil then warn("Custom Mission folder does not contain Cells folder!") return end
	
	local recording = common:RecordChanges("Cell Fixup")
	if not recording then return end
	
	CellFixup_Public(missionFolder.Cells:GetChildren())
	
	common:CommitChanges(recording)
end

return {
	ClickedCallback = CellFixup,
	ID = "Cell Fixup",
	Tooltip = "Fix cell styling",
	IconAssetID = "rbxassetid://115706109343056",
	LightIconAssetID = "rbxassetid://95343720267369",
	UseWithoutViewport = true
}