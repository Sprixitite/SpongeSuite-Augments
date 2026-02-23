local pluginSingleton = require(script.Parent.PluginSingleton)

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local SelectionService = game:GetService("Selection")

local pluginMenus = {}

local ToolsCommon = {}

local function RethemePluginElements()
	for _, menuInfo in pairs(pluginMenus) do
		menuInfo.Menu.Icon = ToolsCommon:SelectIcon(menuInfo.Icons.Dark, menuInfo.Icons.Light)
	end
end

function ToolsCommon:SelectIcon(dark, light)
	if self:CurrentStudioTheme() == "Light" then
		return light or dark -- or "rbxassetid://106247740984287"
	else
		return dark or light -- or "rbxassetid://106247740984287"
	end
end

function ToolsCommon:CurrentStudioTheme() return settings().Studio.Theme.Name end

function ToolsCommon:CreatePluginMenu(id, text, darkIconId, lightIconId)
	local menu = pluginSingleton:CreatePluginMenu(`SZT_IE_Menu_{id}`, text, self:SelectIcon(darkIconId, lightIconId))
	pluginMenus[id] = { Menu = menu, Icons = { Dark = darkIconId, Light = lightIconId } }
	return menu
end

function ToolsCommon:CreatePluginAction(id, text, tooltip, darkIconId, lightIconId, allowBinding)
	allowBinding = allowBinding ~= nil and allowBinding or true
	local action = pluginSingleton:CreatePluginAction(`SZT_IE_Action_{id}`, text, tooltip, ToolsCommon:SelectIcon(darkIconId, lightIconId), allowBinding)
	return action
end

--function ToolsCommon:GetPluginSetting(settingKey)
--	return pluginSingleton:GetSetting(`SZT_IE_{settingKey}`)
--end

--function ToolsCommon:SetPluginSetting(settingKey, value)
--	pluginSingleton:SetSetting(`SZT_IE_{settingKey}`, value)
--	return self:GetPluginSetting(settingKey) == value
--end

function ToolsCommon:GetGridSize()
	return pluginSingleton:GetGridSize()
end

local history = {}
function ToolsCommon:RecordChanges(name: string)
	local recording = ChangeHistoryService:TryBeginRecording(name)
	if recording == nil then warn("Failed to initialize history recording, doing nothing") return end
	history[recording] = true
	return recording
end

function ToolsCommon:CommitChanges(recording: string, enum: Enum.FinishRecordingOperation?)
	if enum == nil then enum = Enum.FinishRecordingOperation.Commit end
	ChangeHistoryService:FinishRecording(recording, enum)
	history[recording] = nil
end

function ToolsCommon:AbortAllChanges()
	for k, v in pairs(history) do
		if v ~= true then continue end
		if not ChangeHistoryService:IsRecordingInProgress(k) then continue end
		ChangeHistoryService:FinishRecording(k, Enum.FinishRecordingOperation.Cancel)
	end
end

function ToolsCommon:GetSelection() return SelectionService:Get() end

function ToolsCommon:LevelFolder()
	return workspace:FindFirstChild("DebugMission") or workspace:FindFirstChild("Level")
end

function ToolsCommon:NullableDescendantOf(instanceDescendant: Instance, childPath: {string}, searchRoot: Instance?)
	searchRoot = searchRoot or workspace
	local comparing = nil
	for _, name in pairs(childPath) do
		comparing = (comparing or searchRoot):FindFirstChild(name)
		if comparing == nil then break end
	end
	if comparing == nil then return false end
	return comparing:IsAncestorOf(instanceDescendant)
end

function ToolsCommon:AncestryCheck(instanceDescendant, ancestryNames, descendantCheck, idx)
	descendantCheck = if descendantCheck == nil then false else true
	idx = idx or #ancestryNames
	local parentName = ancestryNames[idx]
	if parentName == nil then return true end
	if instanceDescendant.Parent == nil then return false end
	if instanceDescendant.Parent == workspace then return false end
	if instanceDescendant.Parent.Name == parentName then return ToolsCommon:AncestryCheck(instanceDescendant.Parent, ancestryNames, descendantCheck, idx-1) end
	if instanceDescendant.Parent.Name ~= parentName and descendantCheck then return ToolsCommon:AncestryCheck(instanceDescendant.Parent, ancestryNames, descendantCheck, idx) end
	return false
end

function ToolsCommon:InstanceIsAny(instance: Instance, classNames: {string})
	for _, className in pairs(classNames) do
		if instance:IsA(className) then return true end
	end
	return false
end

function ToolsCommon:FindFirstChildWithNameAndClass(parent: Instance, name: string, classname: string): classname?
	for _, child in pairs(parent:GetChildren()) do
		if child.Name == name and child:IsA(classname) then return child end
	end
	return nil
end

function ToolsCommon:TableMerge(tblTo: {any}, tblFrom: {any}, preferExisting: boolean?)
	if tblTo == nil then return tblFrom or {} end
	if tblFrom == nil then return tblTo or {} end
	preferExisting = preferExisting or true
	for k, v in pairs(tblFrom) do
		if tblTo[k] == nil then
			tblTo[k] = v
			continue
		end
		if preferExisting then
			continue
		end
		tblTo[k] = v
	end
	return tblTo
end

function ToolsCommon:TableSlice(tblSrc: {any}, sliceStart: number, sliceEnd: number)
	local tblTo = {}
	for i=sliceStart, sliceEnd, 1 do
		tblTo[#tblTo+1] = tblSrc[i]
	end
	return tblTo
end

settings().Studio.ThemeChanged:Connect(RethemePluginElements)

return ToolsCommon