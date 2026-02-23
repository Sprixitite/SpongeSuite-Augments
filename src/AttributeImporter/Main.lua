local common = require(script.Parent.Parent.ToolsCommon)
local attributeMan = require(script.Parent.AttributeMan)
local cinfoHandler = require(script.Parent.InfilClassInfo)

local function ValidBase(exact, archPath)
	if type(exact) == "string" and type(archPath) == "table" then return true end
	if exact == nil and type(archPath) == "string" then
		return false,
			"{vName} is invalid with reason : " .. archPath .. " : Instance will be skipped"
	elseif type(exact) == "string" and archPath == nil then
		return true,
			"{vName}'s class couldn't be inferred - will default to trying its name"
	else
		return false, 
			"Encountered unspecified error/bug in Class/Archetype deduction on {vName} - report this error message at your first convenience\n" ..
			`[DebugInfo] Exact: {exact}, ArchPath: {archPath}`
	end
end

local function HasPrivateAttrs(exact, archPath)
	local valid, warnMsg = ValidBase(exact, archPath)
	if not valid then return valid, warnMsg end
	valid = cinfoHandler.ClassHasPrivateAttrs(exact, archPath)
	return valid, (not valid) and `\{vName}'s class {exact} has no private attributes : Instance will be skipped`
end

local function AcceptsGlobalAttrs(exact, archPath)
	local valid, warnMsg = ValidBase(exact, archPath)
	if not valid then return valid, warnMsg end
	valid = cinfoHandler.ClassAcceptsGlobalAttrs(archPath)
	return valid, (not valid) and `\{vName}'s class {exact} does not import globals : Instance will be skipped`
end

local function ValidOfSelection(selection, includePrivate, includeGlobal)
	local validator = ((includePrivate == includeGlobal) and ValidBase) or (includePrivate and HasPrivateAttrs) or AcceptsGlobalAttrs
	
	local validSelection = {}
	for _, v in ipairs(selection) do 
		local exact, archPath = cinfoHandler.FindInstanceClass(v)
		local selectElemValid, warnMsg = validator(exact, archPath)
		if warnMsg then
			warnMsg = string.gsub(warnMsg, "{vName}", v.Name)
			warn(warnMsg)
		end
		
		if selectElemValid then
			validSelection[#validSelection+1] = v
		end
	end
	
	return validSelection
end

local function ImportAttributesForSelection(includePrivate, includeGlobal, deleting)
	local debugMission = common:LevelFolder()
	if debugMission == nil then warn("Couldn't find mission folder! Doing nothing") return end
	
	local selection = ValidOfSelection(game.Selection:Get(), includePrivate, includeGlobal)
	
	local recording = common:RecordChanges("Import Attributes For Selection")
	if not recording then return end
	
	-- Use pcall if sprix isn't in the session
	-- Just in case :3
	local runner
	if game.Players:FindFirstChild("Sprixitite") == nil then
		runner = function(fn)
			local success, errMsg = pcall(fn)
			if not success then warn(`Error importing attributes! Reason is as follows:\n{errMsg}`) end
			return success
		end
	else
		runner = function(fn) fn() return true end
	end
	
	local success = runner(function()
		for _, v in pairs(selection) do
			local instanceClass, classPath = cinfoHandler.FindInstanceClass(v)
			local attributeList = cinfoHandler.GetPrivateAttributes(instanceClass, classPath)
			if classPath == nil then attributeMan.ApplyAttributes(v, attributeList, deleting) continue end
			
			local classInfo = cinfoHandler.ClassInfoFromPath(classPath)
			attributeList = common:TableMerge(
				attributeList,
				includeGlobal and cinfoHandler.ClassAcceptsGlobalAttrs(classInfo) and cinfoHandler.GetGlobalAttributes() or {},
				true
			)
			
			attributeMan.ApplyAttributes(v, attributeList, deleting)
		end
	end)
	
	common:CommitChanges(recording, success and Enum.FinishRecordingOperation.Commit or Enum.FinishRecordingOperation.Cancel)
end

local function NonGlobalImport()
	ImportAttributesForSelection(true, false, false)
end

local function GlobalImport()
	ImportAttributesForSelection(false, true, false)
end

local function AllImport()
	ImportAttributesForSelection(true, true, false)
end

local function DeleteImported()
	ImportAttributesForSelection(true, true, true)
end

local function DeleteAll()
	local recording = common:RecordChanges("Import Attributes For Selection")
	if not recording then return end
	
	for _, v in pairs(common:GetSelection()) do
		for attrName, _ in pairs(v:GetAttributes()) do
			v:SetAttribute(attrName, nil)
		end
	end
	
	common:CommitChanges(recording)
end

local pluginMenu: PluginMenu? = nil

local function BuildMenu()
	local nonGlobalImport = common:CreatePluginAction(
		"AttributeImportNonGlobal", 
		"Import Non-Global Attributes",
		"Import all attributes specific to this Prop/StateComponent",
		"rbxassetid://73551897964793",
		"rbxassetid://132743443219803"
	)
	nonGlobalImport.Triggered:Connect(NonGlobalImport)
	
	local globalImport = common:CreatePluginAction(
		"AttributeImportGlobal", 
		"Import Global Attributes",
		"Import all attributes which aren't specific to a given Prop/StateComponent",
		"rbxassetid://109357542849581",
		"rbxassetid://133715331552259"
	)
	globalImport.Triggered:Connect(GlobalImport)
	
	local allImport = common:CreatePluginAction(
		"AttributeImportAll", 
		"Import All Attributes",
		"Import all global and relevant non-global attributes to this Prop/StateComponent",
		"rbxassetid://88889481728921",
		"rbxassetid://81720630505836"
	)
	allImport.Triggered:Connect(AllImport)
	
	local deleteImported = common:CreatePluginAction(
		"AttributeImportDelete",
		"Delete All Imported Attributes",
		"Delete all imported attributes from this Prop/StateComponent",
		"rbxassetid://120558084860550",
		"rbxassetid://94057149931568"
	)
	deleteImported.Triggered:Connect(DeleteImported)
	
	local deleteAll = common:CreatePluginAction(
		"AttributeImportDeleteAll",
		"Delete All Attributes",
		"Delete all attributes from this Instance",
		"rbxassetid://120558084860550",
		"rbxassetid://94057149931568"
	)
	deleteAll.Triggered:Connect(DeleteAll)
	
	pluginMenu = common:CreatePluginMenu("AttributeImporter", "Import Attributes", "rbxassetid://88889481728921", "rbxassetid://81720630505836")
	pluginMenu:AddAction(nonGlobalImport)
	pluginMenu:AddAction(globalImport)
	pluginMenu:AddAction(allImport)
	pluginMenu:AddAction(deleteImported)
	pluginMenu:AddAction(deleteAll)
end

local function OpenWindow()
	pluginMenu:ShowAsync()
end

return {
	ID = "Attribute Importer",
	Tooltip = "Automatically import all supported attributes to a prop",
	IconAssetID = "rbxassetid://88889481728921",
	LightIconAssetID = "rbxassetid://81720630505836",
	ClickedCallback = OpenWindow,
	BuildMenu = BuildMenu,
	UseWithoutViewport = true
}