local httpService = game:GetService("HttpService")

local common = require(script.Parent.Parent.ToolsCommon)
local plugin = require(script.Parent.Parent.PluginSingleton):Underlying()

local InfilClassInfo = {}

local APIConsumer = require(script.Parent.APIConsumer)
local internalAttributesMap = require(script.Parent.NotMinePleaseDontSueMe.AttributesMap)
local attrMan = require("./AttributeMan")

local searchInfoValidator = require(script.Parent.SearchInfo.Validator)
local builtinSearchInfo = require(script.Parent.SearchInfo.Builtin)
local foreignSeachInfo = {}

InfilClassInfo.BuiltinSearchInfo = builtinSearchInfo
InfilClassInfo.ForeignSearchInfo = foreignSeachInfo

local infilEngineAttributes = {
	Global = require(script.Parent.NotMinePleaseDontSueMe.GlobalAttributes),
	Extensions = require(script.Parent.PropListExtensions),
	PluginExtensions = {}
}

local function GetUserExtensions()
	local userExtensionsScript = game.ReplicatedStorage:FindFirstChild("AttributesMapExtensions")
	if not userExtensionsScript then return {} end
	if not userExtensionsScript:IsA("ModuleScript") then warn(`AttributesMapExtensions is of invalid class {userExtensionsScript.ClassName}!`) return {} end
	local success, extensions = pcall(function() return require(userExtensionsScript) end)
	if not success then warn(`AttributesMapExtensions failed to execute, failed with: `, extensions) return {} end
	return extensions
end

local function onAPILoaded(api: APIConsumer.APIReference, state)
	state.APIHooks = state.APIHooks or {}
	state.APIExtensions = state.APIExtensions or {}
	state.APIExtensions[1] = api.AddAPIExtension(
		"AttributeImporter",
		"Sprix",
		{
			AddAbstractionImporter = function(abstractionName, searchInfo, importCallback)
				if type(searchInfo) ~= "table" then return nil end
				if type(importCallback) ~= "function" then return nil end
				if type(abstractionName) ~= "string" then return nil end
				
				local infoValid = searchInfoValidator.EntryIsValid(searchInfo, abstractionName)
				if not infoValid then return nil end
				
				local token = httpService:GenerateGUID(false)
				
				searchInfo.IsAbstraction = true
				searchInfo.AbstractionName = abstractionName
				
				InfilClassInfo.ForeignSearchInfo[abstractionName] = searchInfo
				infilEngineAttributes.PluginExtensions[token] = {
					Name = abstractionName,
					Callback = importCallback
				}
				return token
			end,
			RemoveAbstractionImporter = function(token)
				local abstractionName = infilEngineAttributes.PluginExtensions[token].Name 
				InfilClassInfo.ForeignSearchInfo[abstractionName] = nil
				infilEngineAttributes.PluginExtensions[token] = nil
			end,
		}
	)
	
end

local function onAPIUnloaded(api: APIConsumer.APIReference, state)
	for _, token in ipairs(state.APIHooks) do
		api.RemoveHook(token)
	end
	
	for _, extensionToken in ipairs(state.APIExtensions) do
		api.RemoveAPIExtension(extensionToken)
	end
end

task.spawn(function()
	APIConsumer.DoAPILoop(plugin, "SpongeZoneTools-AttributeImporter", onAPILoaded, onAPIUnloaded, {})
end)

setmetatable(
	infilEngineAttributes,
	{
		__index = function(tbl, k)
			if k == "Private" then
				local success, api = APIConsumer.TryGetAPI()
				if not success then return internalAttributesMap end
				return api.GetAttributesMap()
			elseif k == "UserExtensions" then
				return GetUserExtensions()
			end
		end,
	}
)

local function GetExactClass(instance, arch)
	local exactClass = nil
	local failReason = nil
	if arch.TypeIsName then
		exactClass = instance.Name
	elseif arch.TypeIsAttribute then
		exactClass = instance:GetAttribute(arch.TypeIsAttribute)
		failReason = (type(exactClass) ~= "string") and arch.TypeIsAttribute .. " attribute is of non-string datatype on " .. tostring(instance.Parent) .. '.' .. instance.Name
	elseif arch.TypeIsParentName then
		exactClass = instance.Parent.Name
	else
		exactClass = arch.Name
	end
	return exactClass, failReason
end

local function FindExactClassRecurse(instance: Instance, knownClass: builtinSearchInfo.ClassSearchInfo, recurse_tpath: {string}?)
	recurse_tpath = recurse_tpath or {}
	local exactClass, failReason = GetExactClass(instance, knownClass)
	if exactClass == nil then
		return nil, failReason
	end
	
	recurse_tpath[#recurse_tpath+1] = knownClass.Name
	if knownClass.SubTypes == nil then
		return exactClass, recurse_tpath
	end
	
	local defaultSubType = nil
	for k, subType in pairs(knownClass.SubTypes) do
		if subType.IsDefault then defaultSubType = subType continue end
		local subTypeClass = GetExactClass(instance, subType)
		if subType.Name ~= subTypeClass then continue end
		return FindExactClassRecurse(instance, subType, recurse_tpath)
	end
	
	if defaultSubType then return FindExactClassRecurse(instance, defaultSubType, recurse_tpath) end
	
	return exactClass, recurse_tpath
end

local function folderPathCheck(instance, folderPath, descendant)
	if type(folderPath) ~= "table" then folderPath = { folderPath } end
	if type(folderPath[1]) ~= "table" then folderPath = { folderPath } end
	local checkPassed = false
	for _, validPath in ipairs(folderPath) do
		if validPath[1] == "@LevelRoot" then
			checkPassed = instance.Parent == common:LevelFolder()
		else
			checkPassed = common:AncestryCheck(instance, validPath, descendant)
		end
		if checkPassed then break end
	end
	return checkPassed
end

function InfilClassInfo.FindInstanceClass(instance)
	for _, v in pairs(InfilClassInfo.BuiltinSearchInfo) do	
		if not folderPathCheck(instance, v.FolderPath, v.FolderRelation == "descendant") then continue end
		
		if v.ValidClasses ~= nil and not common:InstanceIsAny(instance, v.ValidClasses) then 
			warn(`Instance {instance.Name} is not a valid {v.Name}! Skipping`) 
			return nil 
		end
		
		return FindExactClassRecurse(instance, v)
	end
	
	for _, v in pairs(InfilClassInfo.ForeignSearchInfo) do
		if not folderPathCheck(instance, v.FolderPath, v.FolderRelation == "descendant") then continue end

		if v.ValidClasses ~= nil and not common:InstanceIsAny(instance, v.ValidClasses) then 
			warn(`Instance {instance.Name} is not a valid {v.Name}! Skipping`) 
			return nil 
		end

		return FindExactClassRecurse(instance, v)
	end
	
	warn(`{instance.Parent.Name}.{instance.Name} is of unknown class!`)
	return instance.Name, nil
end

function InfilClassInfo.GetPrivateAttributes(className, classPath)
	local classSearchInfo = InfilClassInfo.ClassInfoFromPath(classPath)
	local privateAttrList = {}
	common:TableMerge(privateAttrList, infilEngineAttributes.Extensions[className])
	common:TableMerge(privateAttrList, infilEngineAttributes.Private[className])
	common:TableMerge(privateAttrList, infilEngineAttributes.UserExtensions[className])
	
	if type(classSearchInfo) == "table" and classSearchInfo.IsAbstraction then
		for _, abstraction in pairs(infilEngineAttributes.PluginExtensions) do
			if abstraction.Name ~= classSearchInfo.AbstractionName then continue end
			local abstractionAttrs = {}
			local success, attrs = pcall(abstraction.Callback, className)
			if not success then
				warn(`Attribute Importer : {abstraction.Name} Callback : Failed with {attrs} : Will Ignore`)
				continue
			end
			for k, attr in pairs(attrs) do
				abstractionAttrs[k] = { attrMan.AttributeTypeFromNativeType(attr[1]), attr[2] }
			end
			common:TableMerge(privateAttrList, abstractionAttrs)
		end
	end

	return privateAttrList
end

function InfilClassInfo.GetGlobalAttributes() return infilEngineAttributes.Global end

local function tostringClassPath(classPath, classPathStr)
	if #classPath < 1 then return classPathStr end
	classPathStr = classPathStr or ""
	classPathStr = `{classPathStr}/{classPath[1]}`
	return tostringClassPath(common:TableSlice(classPath, 2, #classPath), classPathStr)
end

local function traverseClassPath(classPath, classSrc: {builtinSearchInfo.ClassSearchInfo})
	if classPath == nil then return nil end
	if classPath[1] == nil then return nil end
	local nextInPath = classSrc[classPath[1]] 
	if nextInPath == nil then return nil end
	if #classPath < 2 then
		return nextInPath
	else
		return traverseClassPath(common:TableSlice(classPath, 2, #classPath), nextInPath.SubTypes)
	end
end

function InfilClassInfo.ClassInfoFromPath(classPath)
	return traverseClassPath(classPath, InfilClassInfo.BuiltinSearchInfo) 
		or traverseClassPath(classPath, InfilClassInfo.ForeignSearchInfo)
end

function InfilClassInfo.ClassHasPrivateAttrs(exactClass, classPath)
	local classSearchInfo = InfilClassInfo.ClassInfoFromPath(classPath)
	if type(classSearchInfo) == "table" and classSearchInfo.IsAbstraction then
		for _, pluginExtension in pairs(infilEngineAttributes.PluginExtensions) do
			if pluginExtension.Name == classSearchInfo.AbstractionName then return true end
		end
	end
	return infilEngineAttributes.Private[exactClass] ~= nil 
		or infilEngineAttributes.Extensions[exactClass] ~= nil
		or infilEngineAttributes.UserExtensions[exactClass] ~= nil
end

function InfilClassInfo.ClassAcceptsGlobalAttrs(class: builtinSearchInfo.ClassSearchInfo)
	if class == nil then return true end
	return class.ImportsGlobals
end

return InfilClassInfo