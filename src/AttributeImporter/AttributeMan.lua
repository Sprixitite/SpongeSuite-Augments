local attributeType = require(script.Parent.NotMinePleaseDontSueMe.PropAttributeTypes)

local AttributeMan = {}

local attributeTypeDefaults = {
	[attributeType.NUMBER					] = 0,
	[attributeType.INT						] = 0,
	[attributeType.OPTIONAL_INT				] = 0,

	[attributeType.EXPRESSION				] = "",
	[attributeType.STATE_VALUE				] = "",
	[attributeType.STRING					] = "",
	[attributeType.OPTIONAL_MATERIAL		] = "Neon",

	[attributeType.NETWORK_ID				] = 0,
	[attributeType.NETWORK_ID_STRING		] = "",

	[attributeType.BOOL						] = false,
	[attributeType.OPTIONAL_BOOL			] = false,

	[attributeType.OPTIONAL_MISSION_COLOR	] = Color3.new(0,1,0),
	[attributeType.VECTOR3					] = Vector3.new(),

	[attributeType.CFRAME					] = CFrame.new(),
}

local attributeTypeNativeTypes = {}
for k, v in pairs(attributeTypeDefaults) do attributeTypeNativeTypes[k] = typeof(v) end

local nativeTypesToAttributeTypes = {}
for k, v in pairs(attributeTypeNativeTypes) do
	if nativeTypesToAttributeTypes[v] ~= nil then continue end
	nativeTypesToAttributeTypes[v] = k
end

function AttributeMan.AttributeTypeFromNativeType(nativeType)
	return nativeTypesToAttributeTypes[nativeType]
end

function AttributeMan.ValueOrDefault(attrDetails)
	if attrDetails[2] == nil or typeof(attrDetails[2]) ~= attributeTypeNativeTypes[attrDetails[1]] then
		-- Use default from above table if AttributesMap provides no default
		-- Or if default is of wrong type
		return attributeTypeDefaults[attrDetails[1]]
	else
		return attrDetails[2]
	end
end

function AttributeMan.ApplyAttributes(to, attrs, deleting)
	for attrName, attrDetails in pairs(attrs) do
		if deleting then to:SetAttribute(attrName, nil) continue end
		if to:GetAttribute(attrName) ~= nil then continue end
		
		local newAttrVal = AttributeMan.ValueOrDefault(attrDetails)
		if type(attrDetails[2]) == "function" then
			local success, attrVal = pcall(attrDetails[2], to)
			if success and typeof(attrVal) == typeof(newAttrVal) then
				newAttrVal = attrVal
			elseif success then
				warn(`Attribute function {attrName} returned value of type {typeof(attrVal)}, expected {typeof(newAttrVal)} - will use safe default`)
			else
				warn(`Attribute function {attrName} failed with reason: {attrVal}`)
			end
		end
		to:SetAttribute(attrName, newAttrVal)
	end
end

return AttributeMan
