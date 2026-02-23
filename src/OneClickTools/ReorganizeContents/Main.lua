local common = require(script.Parent.Parent.Parent.ToolsCommon)

local function FakeChild(fakeParent, name)
	local fake = fakeParent:FindFirstChild(name)
	if fake ~= nil then return fake end
	
	fake = Instance.new("Folder")
	fake.Parent = fakeParent
	fake.Name = name
	return fake
end

local function ReorganizeContents()
	
	local recording = common:RecordChanges("Generate Prop Base #1")
	if not recording then return end
	
	local fakeParent = Instance.new("Part")
	fakeParent.Parent = workspace
	
	for _, parent in ipairs(common:GetSelection()) do
		local vChildren = parent:GetChildren()
		table.sort(vChildren, function(c1, c2) return c1.Name:lower() < c2.Name:lower() end)
		
		for _, child in ipairs(vChildren) do
			print(child.Name)
			child.Parent = FakeChild(fakeParent, child.Name)
		end
		
		for _, nameFolder in ipairs(fakeParent:GetChildren()) do
			for _, child in ipairs(nameFolder:GetChildren()) do
				local newChild = child:Clone()
				newChild.Parent = parent
			end
		end
		
	end
	
	fakeParent:Destroy()
	
	common:CommitChanges(recording)
	
end

return {
	ClickedCallback = ReorganizeContents,
	ID = "Child Organizer",
	Tooltip = "For each selected instance, reorganizes it's children to be listed in alphabetical order",
	IconAssetID = "rbxassetid://73267947291883",
	LightIconAssetID = "rbxassetid://96120579208421",
	UseWithoutViewport = true
}