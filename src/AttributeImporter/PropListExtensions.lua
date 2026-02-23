local AttributeType = require(script.Parent.NotMinePleaseDontSueMe.PropAttributeTypes)

local stateScriptInfo = {
	DebugLineVariable 	= { AttributeType.STRING, nil },
	DebugLogId			= { AttributeType.STRING, nil },
	DebugVariable		= { AttributeType.STRING, nil },
	Run 			= { AttributeType.STRING, "Mission_Started" },
	ScriptSource 	= { AttributeType.STRING, nil },
	TriggerEvent	= { AttributeType.STRING, nil }
}

return {
	Bot = {
		AvoidInvestigation 			= { AttributeType.BOOL		, false 	},
		BodyguardTarget 			= { AttributeType.STRING	, nil 		},
		Behavior 					= { AttributeType.STRING	, "PatrolWalk" 	},
		CameraArea 					= { AttributeType.STRING	, nil 		},
		CharName 					= { AttributeType.STRING	, "Mr. Unlocalized String" },
		-- CharNameGroup 			= { AttributeType.INT		, 1 		}, Undocumented, dunno what to use for default
		CivilianHighlight 			= { AttributeType.BOOL		, false 	},
		Class 						= { AttributeType.STRING	, "Sec" 	},
		ClientTag 					= { AttributeType.STRING	, nil 		},
		CustomHairColor 			= { AttributeType.OPTIONAL_MISSION_COLOR, nil },
		CustomHairStyle				= { AttributeType.STRING	, nil 		},
		CustomPantsId				= { AttributeType.STRING	, nil 		},
		CustomShirtId				= { AttributeType.STRING	, nil 		},
		CustomSkinTone				= { AttributeType.OPTIONAL_MISSION_COLOR, nil },
		DespawnBlocked				= { AttributeType.STRING	, "0" 		},
		DespawnCondition			= { AttributeType.STRING	, nil 		},
		DetectionSpeed				= { AttributeType.NUMBER	, 1   		},
		EnforceClass				= { AttributeType.STRING	, "Alert1" 	},
		HeadTracking				= { AttributeType.BOOL		, false 	},
		HostageDifficulty			= { AttributeType.NUMBER	, 0 		},
		InterrogationNotification 	= { AttributeType.STRING	, nil 		},
		InterrogationVariable		= { AttributeType.STRING	, nil 		},
		Inv							= { AttributeType.STRING	, nil 		},
		MaxHealth					= { AttributeType.NUMBER	, 100 		},
		NeverIgnoreConversations	= { AttributeType.BOOL		, false 	},
		Nodes						= { AttributeType.STRING	, nil 		},
		NodesBreak					= { AttributeType.STRING	, nil 		},
		NoHostageDownInCombat		= { AttributeType.BOOL		, false 	},
		NoInvestigation				= { AttributeType.BOOL		, false 	},
		ObjectiveHighlight			= { AttributeType.BOOL		, false 	},
		OnlyHideWhenDead			= { AttributeType.BOOL		, false 	},
		Outfit						= { AttributeType.STRING	, "BasicSecurity" 	},
		PatrolCycleLength			= { AttributeType.NUMBER	, 1 		},
		PowerArea					= { AttributeType.STRING	, nil 		},
		Profile						= { AttributeType.STRING	, "BasicSecurity" 	},
		SearchArea					= { AttributeType.STRING	, nil 		},
		Seed						= { AttributeType.NUMBER	, 4736251 	},
		ServerTag					= { AttributeType.STRING	, nil 		},
		SpeakerId					= { AttributeType.STRING	, "Speaker.Unset" 	},
		Title						= { AttributeType.STRING	, "Name.Unset" 		},
		Weapon						= { AttributeType.STRING	, "K45" 	},
	},

	Geometry = {
		WallStrength = { AttributeType.INT, 1 }
	},
	
	ConditionalGeometry = {
		IsSpawned = { AttributeType.EXPRESSION, "1" }
	},
	
	DoorGlass = {
		CanShatter = { AttributeType.BOOL, true },
	},
	
	DirectionalSpawnV2 = {
		BlockRange 			= { AttributeType.INT		,  2 	},
		EnabledCondition 	= { AttributeType.EXPRESSION, "1" 	}
	},
	
	FixedSpawn = {
		Enabled 		= { AttributeType.EXPRESSION, "1" 	},
		IgnoreProximity = { AttributeType.BOOL		, false },
		Range 			= { AttributeType.INT		, 3 	},
		SpawnTag 		= { AttributeType.STRING	, nil 	}
	},
	
	Glass = {
		StateValue = { AttributeType.EXPRESSION, nil 	},
		NoAutoSize = { AttributeType.BOOL	   , false 	}, -- No idea what this actually does, all I know is the templates use it
		BreakAlarm = { AttributeType.STRING    , nil    }
	},
	
	Cell = {
		ServerTag   = { AttributeType.STRING, nil },
		ClientTag   = { AttributeType.STRING, nil },
		Location    = { AttributeType.STRING, function(cell) return `Location.{cell}` end },
		Preposition = { AttributeType.STRING, "Preposition.On" },
	},
	
	Link = {
		Move = 	{ AttributeType.EXPRESSION, "1" },
		Open = 	{ AttributeType.EXPRESSION, "1" },
		Path = 	{ AttributeType.EXPRESSION, "1" },
		Sound = { AttributeType.NUMBER	  ,  1  },
	},

	StateScript = stateScriptInfo,
	StateScriptPart = stateScriptInfo,
	
	Motor = {
		Link			= { AttributeType.STRING, 	nil 	},
		Offset			= { AttributeType.CFRAME, 	nil 	},
		Rotation 		= { AttributeType.VECTOR3, 	nil 	},
		AnimType		= { AttributeType.INT	, 	1 		},
		AnimTime		= { AttributeType.NUMBER, 	1 		},
		ClampMax		= { AttributeType.NUMBER, 	1 		},
		ClampMin		= { AttributeType.NUMBER, 	0 		},
		ClampLoop		= { AttributeType.BOOL	, 	false 	},
	},
	
	CustomPropPart = {
		PropDamage 		= { AttributeType.BOOL, 	true 		},
		CollisionGroup	= { AttributeType.STRING, 	"Default"	}
	},
	
	CustomItem = {
		Icon			= { AttributeType.STRING, "76726389841345"  								},
		Class 			= { AttributeType.STRING, "None" 											},
		DescKey 		= { AttributeType.STRING, function(item) return `ItemDesc.{item.Name}` end 	},
		InvSizeX		= { AttributeType.INT,	  1 												},
		InvSizeY		= { AttributeType.INT,	  1 												},
		IsOffhand		= { AttributeType.BOOL,	  false 											},
		IsOffhandOnly	= { AttributeType.BOOL,	  false 											},
		NameKey			= { AttributeType.STRING, function(item) return `Item.{item.Name}` end 		},
		Volume			= { AttributeType.INT,	  4 												},
		Weight			= { AttributeType.INT,	  0 												}
	},
	
	CombatFlowNode = {
		BlockedLinks	= { AttributeType.STRING, "{}" },
		FilteredLinks	= { AttributeType.STRING, "[]" },
		Id				= { AttributeType.STRING, function(n) return n.Name end },
		LinkedIds		= { AttributeType.STRING, "[]" },
	}
}