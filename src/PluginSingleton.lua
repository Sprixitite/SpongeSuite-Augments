local PluginSingleton = {}

local _plugin = nil
function PluginSingleton:_Initialize(singleton)
	_plugin = singleton
end

function PluginSingleton:CreatePluginMenu(id, text, iconId)
	return _plugin:CreatePluginMenu(id, text, iconId)
end

function PluginSingleton:CreatePluginAction(id, text, tooltip, iconId, allowBinding)
	return _plugin:CreatePluginAction(id, text, tooltip, iconId, allowBinding)
end

function PluginSingleton:GetSetting(settingKey)
	return _plugin:GetSetting(settingKey)
end

function PluginSingleton:SetSetting(settingKey, value)
	_plugin:SetSetting(settingKey, value)
end

function PluginSingleton:GetGridSize()
	return _plugin.GridSize
end

function PluginSingleton:Underlying()
	return _plugin
end

return PluginSingleton