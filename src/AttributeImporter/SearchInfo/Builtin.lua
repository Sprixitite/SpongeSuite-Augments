local validator = require("./Validator")

export type ClassSearchInfo = {
	Name:				string,
	FolderPath: 		{ { string } }|{string}|string,
	FolderRelation:		"child"|"descendant",
	ImportsGlobals:		boolean,
	IsDefault: 			boolean,
	IsAbstraction:		boolean,

	ValidClasses: 		{string},

	TypeIsAttribute: 	string?,
	TypeIsName: 		boolean?,
	TypeIsParentName: 	boolean?,

	AbstractionName:	string?,

	SubTypes:			{ClassSearchInfo}?,
}

local classSearchInfo: {ClassSearchInfo} = {
	StateComponent = {
		FolderPath 			= {
			{ "StateComponents" },
			{ "StateComponentTemplates" }
		},
		ValidClasses 		= {
			"BoolValue"
		},

		FolderRelation 		= "descendant",
		ImportsGlobals 		= false,
		TypeIsAttribute 	= "Type"
	},
	ConditionalGeometry = {
		FolderPath 		= { "ConditionalGeometry" },
		ValidClasses 	= { "Model", "Folder", "BasePart" },

		FolderChild		= true
	},
	Geometry = {
		FolderPath   = { "Geometry" },
		ValidClasses = { "BasePart" },
		
		FolderRelation = "descendant",
		ImportsGlobals = false
	},
	LoudSpawn = {
		FolderPath 			= { "LoudSpawns" },
		ValidClasses 		= { "BasePart" },

		FolderRelation 		= "descendant",
		TypeIsName 			= true,
		ImportsGlobals 		= false
	},
	Prop = {
		FolderPath 			= { "Props" },
		ValidClasses 		= { "BasePart" },

		FolderRelation = "descendant",
		TypeIsName 			= true
	},
	Glass = {
		FolderPath 			= { "Glass" },
		ValidClasses 		= { "BasePart" },

		FolderDescendant	= true
	},
	Cell = {
		FolderPath = { "Cells" },
		ValidClasses = { "Model" },
		
		FolderRelation = "child",
		ImportsGlobals = false
	},
	Link = {
		FolderPath 		= { "Cells", "Links" },
		ValidClasses 	= { "BasePart" },

		FolderRelation 	= "child",
		ImportsGlobals 	= false
	},
	Bot = { 
		FolderPath 			= { "Bots" },
		ValidClasses 		= { "BoolValue" },

		FolderRelation 		= "descendant",
		ImportsGlobals 		= false
	},
	CustomPropPart = {
		FolderPath 			= { "CustomProps" },
		ValidClasses 		= { "BasePart" },

		FolderRelation 		= "descendant",
		ImportsGlobals 		= false,
		
		SubTypes = {
			Motor = { 
				TypeIsName		= true,
				ImportsGlobals 	= false
			},
			Base = { 
				ValidClasses = { "BasePart" },

				ImportsGlobals = false, 
				TypeIsParentName = true
			}
		}
	},
	CustomItem = {
		FolderPath 		= { "CustomItems" },
		ValidClasses 	= { "Model" },

		FolderRelation 	= "child",
		ImportsGlobals	= false
	},
	CombatFlowNode = {
		FolderPath			= { "CombatFlowMap" },
		ValidClasses		= { "BasePart" },

		FolderRelation 		= "descendant",
		ImportsGlobals		= false
	}
}

validator.DefineSeachInfoRecurse(classSearchInfo)

return classSearchInfo