local glut = require("../GLUt")

local Validator = {}

function Validator.FullyDefineSearchEntry(entry, optName)
	if type(optName) == "string" then entry.Name = optName end
	entry.FolderRelation = glut.default_typed(entry.FolderRelation, "descendant")
	entry.ImportsGlobals = glut.default_typed(entry.ImportsGlobals, true)
	entry.TypeIsDefault = glut.default_typed(entry.TypeIsDefault, false)
	entry.IsAbstraction = glut.default_typed(entry.IsAbstraction, false)
	return entry
end

local function type_check(arg, expectedType)
	return glut.type_check(arg, expectedType, nil, nil, glut.severity.SILENT)
end

local function table_type_check(tbl, ...)
	local first = select(1, ...)
	local n = select('#', ...)
	local anyTableValid = false
	for _, v in ipairs(first) do if v == "table" then anyTableValid = true break end end
	for _, v in pairs(tbl) do
		local vValid = false
		local vType = type(v)
		for _, validType in ipairs(first) do
			vValid = vValid or (type(v) == validType)
		end
		if not anyTableValid and vType == "table" and n > 1 then
			vValid = vValid or table_type_check(tbl, select(2, ...))
		end
		if not vValid then return false end
	end
	return true
end

function Validator.EntryIsValid(entry, optName)
	entry = Validator.FullyDefineSearchEntry(entry, optName)
	local invalid = false
	if type(entry.FolderPath) == "table" then
		invalid = not table_type_check(entry.FolderPath, {"string"}, {"string"})
	elseif type(entry.FolderPath) ~= "string" then
		invalid = true
	end
	invalid = invalid or not table_type_check(entry.ValidClasses, {"string"})
	invalid = invalid or not type_check(entry.FolderRelation, "string?")
	invalid = invalid or not type_check(entry.TypeIsAttribute, "string?")
	invalid = invalid or not type_check(entry.TypeIsName, "boolean?")
	invalid = invalid or not type_check(entry.TypeIsParentName, "boolean?")
	if entry.IsAbstraction then
		invalid = invalid or not type_check(entry.AbstractionName, "string")
	end
	invalid = invalid or not type_check(entry.SubTypes, "table?")
	return not invalid
end

function Validator.DefineSeachInfoRecurse(searchInfoGroup)
	for k, v in pairs(searchInfoGroup) do
		Validator.FullyDefineSearchEntry(v, k)
		if v.SubTypes == nil then continue end
		Validator.DefineSeachInfoRecurse(v.SubTypes)
	end
end

return Validator