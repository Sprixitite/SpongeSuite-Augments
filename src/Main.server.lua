local common = require(script.Parent.ToolsCommon)
local pluginSingleton = require(script.Parent.PluginSingleton)
pluginSingleton:_Initialize(plugin)

local spongeZoneToolbar = plugin:CreateToolbar("InfiltrationEngine // SpongeAugments")

local allTools = {
	AttributeImporter = script.Parent.AttributeImporter.Main,
	BatchAlter        = script.Parent.BatchAlter.Main,
	ToggleGroupVis    = script.Parent.ToggleGroupVis.Main,
	OneClickTools     = script.Parent.OneClickTools.Main,
}

local topLevelButtons = {}

local function IconFromInfo(info)
	if settings().Studio.Theme.Name == "Light" then
		return info.LightIconAssetID or info.IconAssetID or "rbxassetid://106247740984287"
	else
		return info.IconAssetID or info.LightIconAssetID or "rbxassetid://106247740984287"
	end
end

local function CreateTopLevelButton(info)
	local button = spongeZoneToolbar:CreateButton(
		`SZT_IE_Toolbar_{info.ID}`,
		info.Tooltip,
		IconFromInfo(info),
		info.Text or info.ID
	)
	button.ClickableWhenViewportHidden = info.UseWithoutViewport
	
	if info.BuildMenu ~= nil then
		info.BuildMenu()
	end
	
	if info.RethemeMenu ~= nil then
		settings().Studio.Theme.Changed:Connect(info.RethemeMenu)
	end
	
	button.Click:Connect(function()
		local success, errMsg = pcall(info.ClickedCallback)
		if not success then
			warn(`Tool {info.ID} encountered the following error: "{errMsg}"`)
			warn("Restoring ChangeHistoryService state...")
			common:AbortAllChanges()
		end
	end)
	topLevelButtons[info.ID] = { Info = info, Button = button }
end

local function BuildPluginToolbar(printInits)
	printInits = printInits or false
	for k, v in pairs(allTools) do
		local toolDetails = require(v)
		
		if toolDetails.SubActions ~= nil then
			for subactionName, subaction in pairs(toolDetails.SubActions) do
				if printInits then print(`Initializing SpongeZone tool {subactionName}...`) end
				CreateTopLevelButton(subaction)
			end
		end
		
		if toolDetails.SubActionsOnly then continue end
		
		if printInits then print(`Initializing SpongeZone tool {k}...`) end
		
		CreateTopLevelButton(toolDetails)
	end
end

local function WarnIfUnknownTheme()
	if settings().Studio.Theme.Name ~= "Light" and settings().Studio.Theme.Name ~= "Dark" then
		warn("Using unknown studio theme, defaulting to dark mode icons.")
	end
end

local function RethemeTopLevelButtons()
	WarnIfUnknownTheme()
	
	for id, buttonInfo in pairs(topLevelButtons) do
		buttonInfo.Button.Icon = IconFromInfo(buttonInfo.Info)
	end
	
	warn("Due to how plugins function (arbitrary roblox limitations) some icons will be broken until studio is restarted!")
end

BuildPluginToolbar(true)
WarnIfUnknownTheme()

settings().Studio.ThemeChanged:Connect(RethemeTopLevelButtons)