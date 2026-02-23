local common = require(script.Parent.Parent.ToolsCommon)

local oneClickMenuEnabled = true
if oneClickMenuEnabled == nil then oneClickMenuEnabled = true end

local oneClickMenuDisabled = not oneClickMenuEnabled

local toolsList = {
	AutoCell = script.Parent.AutoCell.Main,
	CellFixup = script.Parent.CellFixup.Main,
	CustomPropBaseGen = script.Parent.CustomPropBaseGen.Main,
	GenSlopePart = script.Parent.GenSlopePart.Main,
	ReorganizeContents = script.Parent.ReorganizeContents.Main,
}

local subActions = {}
for k, tool in pairs(toolsList) do
	subActions[k] = require(tool)
end

local oneClickMenu: PluginMenu? = nil

local function BuildMenu()
	oneClickMenu = common:CreatePluginMenu("OneClickTools", "One-Click Tools", "rbxassetid://125187645185104", "rbxassetid://80115599628137")
	
	for toolName, toolModule in pairs(toolsList) do
		print(`\tInitializing {toolName}...`)
		
		local actionInfo = require(toolModule)
		local toolAction = common:CreatePluginAction(`OCT_{actionInfo.ID}`, actionInfo.ID, actionInfo.Tooltip, actionInfo.IconAssetID, actionInfo.LightIconAssetID)
		
		toolAction.Triggered:Connect(function()
			local success, errMsg = pcall(actionInfo.ClickedCallback)
			if not success then
				warn(`Tool {actionInfo.ID} encountered the following error: "{errMsg}"`)
				warn("Restoring ChangeHistoryService state...")
				common:AbortAllChanges()
			end
		end)
		oneClickMenu:AddAction(toolAction)
	end
end

local function OpenWindow()
	oneClickMenu:ShowAsync()
end

if not oneClickMenuDisabled then subActions = nil end

return {
	SubActionsOnly = oneClickMenuDisabled,
	SubActions = subActions,
	
	ID = "One-Click Tools",
	Tooltip = "A collection of tools activated by a single click.\nExists to avoid cluttering your plugin bar :3",
	IconAssetID = "rbxassetid://125187645185104",
	LightIconAssetID = "rbxassetid://80115599628137",
	
	ClickedCallback = OpenWindow,
	BuildMenu = BuildMenu,
	UseWithoutViewport = true
}