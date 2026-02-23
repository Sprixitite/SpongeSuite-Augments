local common = require(script.Parent.Parent.ToolsCommon)
local ba = require("./BatchAlter")

local function submenu_def(name)
	return {
		ID = name
	}
end

local submenus = {
	submenu_def("Appearance"),
	submenu_def("Physics"),
	submenu_def("Studio")
}

local function subroutine_def(btnname, propname, val, submenu)
	return {
		ClickedCallback = ba(propname, val),
		ID = btnname,
		Tooltip = `Sets the "{propname}" of all selected parts to {val}`,
		SubMenu = submenu,
	}
end

local subroutinesList = {
	subroutine_def("CastShadow On",    "CastShadow",   true , "Appearance"),
	subroutine_def("CastShadow Off",   "CastShadow",   false, "Appearance"),
	subroutine_def("Make Transparent", "Transparency", 1    , "Appearance"),
	subroutine_def("Make Translucent", "Transparency", 0.5  , "Appearance"),
	subroutine_def("Make Opaque",      "Transparency", 0    , "Appearance"),
	subroutine_def("Anchor",           "Anchored",     true , "Physics"   ),
	subroutine_def("Unanchor",         "Anchored",     false, "Physics"   ),
	subroutine_def("CanCollide On",    "CanCollide",   true , "Physics"   ),
	subroutine_def("CanCollide Off",   "CanCollide",   false, "Physics"   ),
	subroutine_def("Lock",             "Locked",       true , "Studio"    ),
	subroutine_def("Unlock",           "Locked",       false, "Studio"    ),
}

local batchMenu: PluginMenu? = nil

local function BuildMenu()
	batchMenu = common:CreatePluginMenu("BatchTools", "Batch Alter", "rbxassetid://96486857890444", "rbxassetid://96486857890444")

	local submenuDict = {}
	for _, submenu in ipairs(submenus) do
		submenuDict[submenu.ID] = common:CreatePluginMenu(`BALTS_{submenu.ID}`, submenu.ID)
		batchMenu:AddMenu(submenuDict[submenu.ID])
	end

	for _, tool in ipairs(subroutinesList) do
		local toolAction = common:CreatePluginAction(`BALT_{tool.ID}`, tool.ID, tool.Tooltip, nil, nil)

		toolAction.Triggered:Connect(function()
			local success, errMsg = pcall(tool.ClickedCallback)
			if not success then
				warn(`Tool {tool.ID} encountered the following error: "{errMsg}"`)
				warn("Restoring ChangeHistoryService state...")
				common:AbortAllChanges()
			end
		end)
		
		if submenuDict[tool.SubMenu] ~= nil then
			submenuDict[tool.SubMenu]:AddAction(toolAction)
		else
			batchMenu:AddAction(toolAction)
		end
	end
end

local function OpenWindow()
	batchMenu:ShowAsync()
end

return {

	ID = "Batch Alter",
	Tooltip = "Tools for batch-edits to parts",
	IconAssetID = "rbxassetid://96486857890444",
	LightIconAssetID = "rbxassetid://96486857890444",

	ClickedCallback = OpenWindow,
	BuildMenu = BuildMenu,
	UseWithoutViewport = true
}