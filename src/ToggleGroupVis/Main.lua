local common = require(script.Parent.Parent.ToolsCommon)

local GROUP_VIS_ATTR_NAME = "_SpongeGroupVisibility"
local ELMNT_VIS_ATTR_NAME = "_SpongeElmntVisibility"

local function IsGroup(inst: Instance)
	local instType = inst.ClassName
	return instType == "Folder" or instType == "Model", instType
end

local function StoreElementProperty(element: Instance, property: string, newVal: any)
	element:SetAttribute(`_SpongeElmnt{property}`, element[property])
	element[property] = newVal
end

local function RestoreElementProperty(element: Instance, property: string, expected: any)
	if element[property] ~= expected then
		warn(`{element.Name}{property} set to unexpected value after being toggled, assuming new value to be intentional`)
		return element[property]
	end
	local stored = element:GetAttribute(`_SpongeElmnt{property}`)
	element[property] = stored
	return stored
end

local function ToggleElementVisibility(element: BasePart, nextVisState: boolean)
	if nextVisState == element:GetAttribute(ELMNT_VIS_ATTR_NAME) then
		--print(`{element.Name} already in desired state, leaving as-is`)
		return
	end

	if nextVisState and (element:GetAttribute(ELMNT_VIS_ATTR_NAME) == nil) then
		warn("Element in disabled visgroup had no visibility metadata - likely added after disable. Skipping")
		return
	end

	if nextVisState == false then
		StoreElementProperty(element, "Transparency", 1)
		StoreElementProperty(element, "Locked",       true)
		StoreElementProperty(element, "CanCollide",   false)
		StoreElementProperty(element, "CanTouch",     false)
		StoreElementProperty(element, "CanQuery",     false)
	else
		RestoreElementProperty(element, "Transparency", 1)
		RestoreElementProperty(element, "Locked",       true)
		RestoreElementProperty(element, "CanCollide",   false)
		RestoreElementProperty(element, "CanTouch",     false)
		RestoreElementProperty(element, "CanQuery",     false)
	end
	
	element:SetAttribute(ELMNT_VIS_ATTR_NAME, nextVisState)
end

local function CalculateGroupParentsRecurse(parent: Instance, tbl: table?)
	tbl = tbl or {}
	if parent == nil then warn("Group's root parent was nil!?") return tbl end
	if parent == workspace.Parent then return tbl end
	if IsGroup(parent) then
		if parent:GetAttribute(GROUP_VIS_ATTR_NAME) == nil then
			parent:SetAttribute(GROUP_VIS_ATTR_NAME, true)
		end
		tbl[#tbl+1] = parent:GetAttribute(GROUP_VIS_ATTR_NAME)
	end
	return CalculateGroupParentsRecurse(parent.Parent, tbl)
end

local function CalculateGroupVisibility(group)
	local visTbl = CalculateGroupParentsRecurse(group)
	for _, v in pairs(visTbl) do
		if not v then return false end
	end
	return true
end

local function ToggleGroupVisibility(group: Instance, invert: boolean)
	-- Invert the selected group's visibility
	-- Assume group is visible if no group vis is set
	if group:GetAttribute(GROUP_VIS_ATTR_NAME) == nil then group:SetAttribute(GROUP_VIS_ATTR_NAME, true) end
	if invert then group:SetAttribute(GROUP_VIS_ATTR_NAME, not group:GetAttribute(GROUP_VIS_ATTR_NAME)) end

	local thisGroupIsVisible = CalculateGroupVisibility(group)

	for _, child in pairs(group:GetChildren()) do
		local isBasePart = child:IsA("BasePart")
		local isGroup = IsGroup(child)
		if not (isBasePart or isGroup) then continue end
		if isBasePart then ToggleElementVisibility(child, thisGroupIsVisible) end 
		if isGroup then ToggleGroupVisibility(child, false) end
	end
end

local function GroupVisTogglePressed()
	local selection = common:GetSelection()

	local selectionIsValid = true
	for instName, inst in pairs(selection) do
		local instValid, instType = IsGroup(inst)
		if not instValid then
			warn(`GroupVisToggle only works on Models & Folders, deselect {instType} {instName} before running!`)
			selectionIsValid = false
		end
	end

	if not selectionIsValid then return end

	local recording = common:RecordChanges("Toggle Group Visibility")
	if not recording then return end

	for _, inst in pairs(selection) do
		ToggleGroupVisibility(inst, true)
	end

	common:CommitChanges(recording)

end

return {
	ClickedCallback = GroupVisTogglePressed,
	ID = "Toggle Group Visibility", 
	Tooltip = "Toggle the visibility of a folder/model", 
	IconAssetID = "rbxassetid://86288177650040",
	LightIconAssetID = "rbxassetid://137463386400446",
	UseWithoutViewport = false
}