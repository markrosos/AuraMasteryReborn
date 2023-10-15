-- control settings
AURAMASTERY_UNIT_TAG_PLAYER					= "Player"
AURAMASTERY_UNIT_TAG_RETICLEOVER			= "Target"
AURAMASTERY_UNIT_TAG_PET					= "Pet"
AURAMASTERY_TRIGGER_TYPE_BUFF_DEBUFF 		= "Buff / Debuff"
AURAMASTERY_TRIGGER_TYPE_FAKE_EFFECT 		= "Ability used"
AURAMASTERY_TRIGGER_TYPE_CUSTOM 			= "Custom"
AURAMASTERY_TRIGGER_TYPE_COMBAT_EVENT_BASED	= "Combat event"
AURAMASTERY_TRIGGER_TYPE_STATUS 			= "Status"
AURAMASTERY_TRIGGER_TYPE_EVENT 				= "Event"
AURAMASTERY_UNTRIGGER_TYPE_TIME_BASED		= "Time-based"

AURAMASTERY_ABILITY_IDS_MAX_VALUE = AuraMastery:GetAbilityIdsMaxValue()

AM_SINGLE_LINE_EDIT_CONTAINER_PADDING_LEFT	 = 4
AM_SINGLE_LINE_EDIT_CONTAINER_PADDING_RIGHT	 = 3
AM_SINGLE_LINE_EDIT_CONTAINER_PADDING_TOP	 = 1
AM_SINGLE_LINE_EDIT_CONTAINER_PADDING_BOTTOM = 2

-- modes
AM_MODE_NORMAL 	= 1
AM_MODE_EDIT 	= 2

-- events
AURAMASTERY_EVENT_CUSTOM_DURATION_CHANGED = 0

AM_IMPORT_TYPE_AURA = 1
AM_IMPORT_TYPE_AURA_GROUP = 2

AuraMastery.G = {
	['triggers'] = {
		['operators'] = {
			[1] = "<",
			[2] = ">",
			[3] = "<=",
			[4] = ">=",
			[5] = "==",
			[6] = "~=",
		},
		['unitTags'] = {
			[1] = AURAMASTERY_UNIT_TAG_PLAYER,
			[2] = AURAMASTERY_UNIT_TAG_RETICLEOVER,
--			[3] = AURAMASTERY_UNIT_TAG_PET
		},
		['triggerTypes'] = {
			[1] = AURAMASTERY_TRIGGER_TYPE_BUFF_DEBUFF,
			[2] = AURAMASTERY_TRIGGER_TYPE_FAKE_EFFECT,
			[3] = AURAMASTERY_TRIGGER_TYPE_CUSTOM,
			[4] = AURAMASTERY_TRIGGER_TYPE_COMBAT_EVENT_BASED,
--			[5] = AURAMASTERY_TRIGGER_TYPE_STATUS,
--			[6] = AURAMASTERY_TRIGGER_TYPE_EVENT,
		},
	},
	['changeTypes'] = {
		[1] = "Effect gained",
		[2] = "Effect faded",
		[3] = "Effect refreshed"
	},
	['eventTypes'] = {
		[1] = AURAMASTERY_TRIGGER_TYPE_BUFF_DEBUFF,
		[2] = AURAMASTERY_TRIGGER_TYPE_FAKE_EFFECT,
		[3] = AURAMASTERY_TRIGGER_TYPE_COMBAT_EVENT_BASED
	},
	['eventTypesByIndex'] = {
		[1] = EVENT_EFFECT_CHANGED,
		[2] = EVENT_ACTION_SLOT_ABILITY_USED,
		[3] = EVENT_COMBAT_EVENT,
	},
	['triggerDefaults'] = {
		[1] = {
			['allowed'] = {
				['checkAll'] = true,
				['invert'] = true,
				['operator'] = true,
				['sourceCombatUnitType'] = true,
				['spellId'] = true,
				['triggerType'] = true,
				['unitTag'] = true,
				['value'] = true,
			},
			['required'] = {
				['checkAll'] = false,
				['invert'] = false,
				['operator'] = 2,
				['sourceCombatUnitType'] = false,
				['spellId'] = 0,
				['triggerType'] = 1,
				['unitTag'] = 1,
				['value'] = 0,
			}
		},
		[2] = {
			['allowed'] = {
				['checkAll'] = true,
				['invert'] = true,
				['operator'] = true,
				['spellId'] = true,
				['triggerType'] = true,
				['value'] = true,
				['duration'] = true,
			},
			['required'] = {
				['checkAll'] = false,
				['invert'] = false,
				['operator'] = 2,
				['spellId'] = 0,
				['triggerType'] = 2,
				['value'] = 0,			
			}
		},
		[3] = {
			['allowed'] = {
				['abilityId'] = true,
				['triggerType'] = true,
				['unitTag'] = true,
				['customTriggerData'] = true,
				['customUntriggerData'] = true,
				['invert'] = true,
			},
			['required'] = {
				['triggerType'] = 3,
				['customTriggerData'] = {
					['eventType'] = 1,
					['abilityId'] = 0,
					['changeType'] = 0,
					['unitTag'] = 1
				},
				['customUntriggerData'] = {
					['eventType'] = 1,
					['abilityId'] = 0,
					['changeType'] = 0,
					['unitTag'] = 1				
				},
				['invert'] = false,
			}
		},
		[4] = {
			['allowed'] = {
				['actionResults'] = true,
				['duration'] = true,
				['checkAll'] = true,
				['invert'] = true,
				['operator'] = true,
				['spellId'] = true,
				['triggerType'] = true,
				['value'] = true,
				['combatUnitTag'] = true,
				['casterName'] = true,
				['targetName'] = true,						
			},
			['required'] = {
				['actionResults'] = {2240, 2245},
				['checkAll'] = false,
				['invert'] = false,
				['operator'] = 2,
				['spellId'] = 0,
				['triggerType'] = 4,
				['value'] = 0,
				['casterName'] = "",
				['targetName'] = "",	
			}
		},
	},
	['customTriggerDefaults'] = {
		[1] = {
			['allowed'] = {
				['triggerType'] = true,
				['eventType'] = true,
				['abilityId'] = true,
				['changeType'] = true,
				['unitTag'] = true,
			},
			['required'] = {
				['triggerType'] = 1,
				['eventType'] = 1,
				['abilityId'] = 0,
				['changeType'] = 1,
				['unitTag'] = 1,	
			}
		},
		[2] = {
			['allowed'] = {
				['triggerType'] = true,
				['eventType'] = true,
				['abilityId'] = true,
			},
			['required'] = {
				['triggerType'] = 2,
				['eventType'] = 2,
				['abilityId'] = 0,
			}
		},
		[3] = {
			['allowed'] = {
				['actionResults'] = true,
				['eventType'] = true,
				['abilityId'] = true,
				['sourceName'] = true,
				['targetName'] = true,
			},
			['required'] = {
				['actionResults'] = {2240, 2245},
				['eventType'] = 3,
				['abilityId'] = 0,
				['sourceName'] = "",
				['targetName'] = "",
	
			}
		},
	},
	['customUntriggerDefaults'] = {
		[1] = {
			['allowed'] = {
				['triggerType'] = true,
				['eventType'] = true,
				['abilityId'] = true,
				['changeType'] = true,
				['unitTag'] = true,
			},
			['required'] = {
				['triggerType'] = 1,
				['eventType'] = 1,
				['abilityId'] = 0,
				['changeType'] = 1,
				['unitTag'] = 1,	
			}
		},
		[2] = {
			['allowed'] = {
				['triggerType'] = true,
				['eventType'] = true,
				['abilityId'] = true,
			},
			['required'] = {
				['triggerType'] = 2,
				['eventType'] = 2,
				['abilityId'] = 0,
			}
		},
		[3] = {
			['allowed'] = {
				['actionResults'] = true,
				['eventType'] = true,
				['abilityId'] = true,
				['sourceName'] = true,
				['targetName'] = true,
			},
			['required'] = {
				['actionResults'] = {2240, 2245},
				['eventType'] = 3,
				['abilityId'] = 0,
				['sourceName'] = "",
				['targetName'] = "",
			}
		},
	}
}

AuraMastery.protoDisplay = {
	[1] = {	-- icon
				{	-- aura name
					['poolName'] 	= "auraName",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 30,				
				},
				{	-- group assignment
					['poolName'] 	= "auraGroupAssignment",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 60,
				},	
				{	-- width
					['poolName'] 	= "width",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 90,
				},
				{	-- height
					['poolName'] 	= "height",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 120,
				},
				{	-- posX
					['poolName'] 	= "posX",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 150,
				},
				{	-- posY
					['poolName'] 	= "posY",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 180,
				},
				{	-- alpha
					['poolName'] 	= "alpha",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 210,
				},
				{	-- cooldown font size
					['poolName'] 	= "cooldownFontSize",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 240,
				},
				{	-- cooldown font color
					['poolName'] 	= "cooldownFontColor",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 270,
				},
				{	-- border size
					['poolName'] 	= "borderSize",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 360,
				},
				{	-- border color
					['poolName'] 	= "borderColor",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 390,
				},
				{	-- critical time
					['poolName'] 	= "criticalTime",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 420,
				},
				{	-- text button
					['poolName'] 	= "textButton",
					['parentName']  = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo']  = TOP,
					['offsetX']		= 0,
					['offsetY']		= 450,
				},
				{	-- show cooldown animation
					['poolName'] 	= "auraShowCooldownAnimation",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 480,
				},
				{	-- show cooldown text
					['poolName'] 	= "auraShowCooldownText",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 510,
				},
				{	-- aura trigger actions and animations
					['poolName'] 	= "triggerActions",
					['parentName']	= "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] 	= TOP,
					['offsetX']		= 0,
					['offsetY']		= 540,
				},
				{	-- duration source
					['poolName'] 	= "auraDurationInfo",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 570,
				},
				{	-- icon source
					['poolName'] 	= "auraIconInfo",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 600,
				},
				{	-- icon selector
					['poolName'] = "auraIcon",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']	= TOP,
					['relativeTo'] = TOP,
					['offsetX']	= 0,
					['offsetY']	= 630,
					['spacesReq'] = 2
				},
				{	-- activation button
					['poolName'] 	= "activationState",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 690,
				},	
	},
	[2] = {	-- progression bar
				{	-- aura name
					['poolName'] 	= "auraName",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 30,				
				},
				{	-- group assignment
					['poolName'] 	= "auraGroupAssignment",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 60,
				},
				{	-- width
					['poolName'] 	= "width",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 90,
				},
				{	-- height
					['poolName'] 	= "height",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 120,
				},
				{	-- posX
					['poolName'] 	= "posX",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 150,
				},
				{	-- posY
					['poolName'] 	= "posY",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 180,
				},
				{	-- background color
					['poolName'] 	= "bgColor",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 210,
				},
				{	-- bar color
					['poolName'] 	= "barColor",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 240,
				},				
				{	-- alpha
					['poolName'] 	= "alpha",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 270,
				},
				{	-- cooldown font size
					['poolName'] 	= "cooldownFontSize",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 300,
				},
				{	-- cooldown font color
					['poolName'] 	= "cooldownFontColor",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 330,
				},
				{	-- border size
					['poolName'] 	= "borderSize",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 360,
				},
				{	-- border color
					['poolName'] 	= "borderColor",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 390,
				},
				{	-- critical time
					['poolName'] 	= "criticalTime",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 420,
				},
				{	-- show cooldown text
					['poolName'] 	= "auraShowCooldownText",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 450,
				},
				{	-- aura trigger actions and animations
					['poolName'] 	= "triggerActions",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 480,
				},
				{	-- duration source
					['poolName'] 	= "auraDurationInfo",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 510,
				},
				{	-- icon source
					['poolName'] 	= "auraIconInfo",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 540,
				},
				{	-- icon selector
					['poolName'] 	= "auraIcon",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 570,
				},	
				{	-- activation button
					['poolName'] 	= "activationState",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 630,
				},
	},
	[3] = {	-- texture
				{	-- aura name
					['poolName'] 	= "auraName",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 30,				
				},
	},
	[4] = {	-- text
				{	-- aura name
					['poolName'] 	= "auraName",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 30,				
				},
				{	-- group assignment
					['poolName'] 	= "auraGroupAssignment",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 60,
				},
				{	-- posX
					['poolName'] 	= "posX",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 90,
				},
				{	-- posY
					['poolName'] 	= "posY",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 120,
				},
				{	-- alpha
					['poolName'] 	= "alpha",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 150,
				},
				{	-- critical time
					['poolName'] 	= "criticalTime",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 240,
				},
				{	-- text button
					['poolName'] 	= "textButton",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 270,
				},
				{	-- aura trigger actions and animations
					['poolName'] 	= "triggerActions",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 300,
				},
				{	-- duration source
					['poolName'] 	= "auraDurationInfo",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 330,
				},
				{	-- activation button
					['poolName'] 	= "activationState",
					['parentName'] = "DisplaySettingsDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 390,
				},
	}
}

AuraMastery.protoCustomTriggers = {
	[1] = {	-- EVENT_EFFECT_CHANGED
	--eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType
				{	-- abilityId
					['poolName'] 	= "customTriggerAbilityId",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 65,
				},
				{	-- changeType
					['poolName'] 	= "customTriggerChangeType",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 94,
				},
				{	-- unitTag
					['poolName'] 	= "customTriggerUnitTag",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 123,
				},

				
	},
	[2] = { -- EVENT_ACTION_SLOT_ABILITY_USED
				{	-- abilityId
					['poolName'] 	= "customTriggerAbilityId",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 65,
				},				
	},
	[3] = {	-- EVENT_COMBAT_EVENT
				{	-- ability id
					['poolName'] 	= "customTriggerAbilityId",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 65,
				},
				{	-- action results
					['poolName'] 	= "customTriggerActionResults",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 94,
				},
				{	-- source name
					['poolName'] 	= "customTriggerSourceName",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 123,
				},
				{	-- target name
					['poolName'] 	= "customTriggerTargetName",
					['parentName'] = "AuraMasteryCustomTriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 152,
				},
	},
}

AuraMastery.protoCustomUntriggers = {
	[1] = { -- EVENT_EFFECT_CHANGED
	--eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType
				{	-- abilityId
					['poolName'] 	= "customUntriggerAbilityId",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 65,
				},
				{	-- changeType
					['poolName'] 	= "customUntriggerChangeType",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 94,
				},
				{	-- unitTag
					['poolName'] 	= "customUntriggerUnitTag",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 123,
				},

				
	},
	[2] = { -- EVENT_ACTION_SLOT_ABILITY_USED
				{	-- abilityId
					['poolName'] 	= "customUntriggerAbilityId",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 65,
				},				
	},
	[3] = { -- EVENT_COMBAT_EVENT
				{	-- abilityId
					['poolName'] 	= "customUntriggerAbilityId",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 65,
				},
				{	-- action results
					['poolName'] 	= "customUntriggerActionResults",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 94,
				},
				{	-- source name
					['poolName'] 	= "customUntriggerSourceName",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 123,
				},
				{	-- target name
					['poolName'] 	= "customUntriggerTargetName",
					['parentName'] = "AuraMasteryCustomUntriggerWindowDynamicControls",
					['anchor']		= TOPLEFT,
					['relativeTo'] = TOPLEFT,
					['offsetX']		= 0,
					['offsetY']		= 152,
				},
					-- action results
	},
}

AuraMastery.protoTriggers = {
	[1] = {	-- buff/debuff
				{	-- ability id
					['poolName'] 	= "abilityId",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 29,
				},
				{	-- source [player, target]
					['poolName'] 	= "source",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 58,
				},
				{	-- check all [true, false]
					['poolName'] 	= "checkAll",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 87,
				},
				{	-- invert [true, false]
					['poolName'] 	= "invert",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 116,
				},
				{	-- sourceCombatUnitType
					['poolName'] 	= "sourceCombatUnitType",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 145,
				},
				{	-- operator [<, >, <=, >=, =, ~=]
					['poolName'] 	= "operator",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 174,
				},
				{	-- value
					['poolName'] 	= "value",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 203,
				},
	},
	[2] = {	-- fake effects
				{	-- ability id
					['poolName'] 	= "abilityId",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 29,
				},

				{	-- check all [true, false]
					['poolName'] 	= "checkAll",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 58,
				},
				{	-- invert [true, false]
					['poolName'] 	= "invert",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 87,
				},
				{	-- operator [<, >, <=, >=, =, ~=]
					['poolName'] 	= "operator",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 116,
				},
				{	-- value
					['poolName'] 	= "value",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 145,
				},
				{	-- custom duration
					['poolName'] 	= "duration",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 174,
				},
	},
	[3] = {	-- custom
				{	-- event name
					['poolName'] 	= "LoadCustomTriggerMenuButton",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 29,
				},	
				{	-- untrigger event name
					['poolName'] 	= "LoadCustomUntriggerMenuButton",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 58,
				},					
				{	-- invert [true, false]
					['poolName'] 	= "invert",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 87,
				},
	},
	[4] = {	-- combat event
				{	-- ability id
					['poolName'] 	= "actionResults",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 29,
				},
				{	-- action results
					['poolName'] 	= "abilityId",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 58,
				},
				{	-- unit tag
					['poolName'] 	= "unitTag",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 87,
				},				
				{	-- caster
					['poolName'] 	= "casterName",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 116,
				},
				{	-- target
					['poolName'] 	= "targetName",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 145,
				},
				{	-- check all
					['poolName'] 	= "checkAll",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 174,
				},
				{	-- invert [true, false]
					['poolName'] 	= "invert",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 203,
				},
				{	-- operator
					['poolName'] 	= "operator",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 232,
				},
				{	-- value
					['poolName'] 	= "value",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 261,
				},
				{	-- custom duration
					['poolName'] 	= "duration",
					['parentName'] = "AuraMasteryTriggerSettingsContainerDynamicControls",
					['anchor']		= TOP,
					['relativeTo'] = TOP,
					['offsetX']		= 0,
					['offsetY']		= 290,
				},
	},
	[5] = {	-- unassigned
	},
	[6] = {	-- unassigned
	},
}

AuraMastery.controls.settings = {
	-- Display Settings
	['auraName'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraNameContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Name:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraNameSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {140, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraName)
				AuraMasteryDisplayMenu_AuraNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraName)
			end
		},	
	},
	['auraShowCooldownAnimation'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraShowCooldownAnimationContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Show cooldown animation:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraShowCooldownAnimationSubControl",
			['virtualName'] = "AM_CheckButton",
			['initHandler'] = function()
				ZO_CheckButton_SetToggleFunction(AuraMasteryDisplayMenu_AuraShowCooldownAnimationSubControl, AuraMastery.EditAuraShowCooldownAnimation)
			end
		},
	},
	['auraShowCooldownText'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraShowCooldownTextContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Show cooldown text:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraShowCooldownTextSubControl",
			['virtualName'] = "AM_CheckButton",
			['initHandler'] = function()
				ZO_CheckButton_SetToggleFunction(AuraMasteryDisplayMenu_AuraShowCooldownTextSubControl, AuraMastery.EditAuraShowCooldownText)
			end
		},
	},
	['auraDurationInfo'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraDurationInfoContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Duration Source:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraDurationInfoSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				96, 20
			},
			['tooltipText'] = "Select the trigger to take duration information from.",
		},
	},
	['auraIconInfo'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraIconInfoContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Icon Source:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraIconInfoSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				96, 20
			},
			['tooltipText'] = "Select the trigger to take icon information from.",
		},
	},	
	['auraIcon'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraIcon",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Icon:",
	},
	['cooldownFontSize'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraCooldownFontSizeContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Cooldown Font Size:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraCooldownFontSizeSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {42, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraCooldownFontSizeSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraCooldownFontSize)
				AuraMasteryDisplayMenu_AuraCooldownFontSizeSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraCooldownFontSize)
			end
		},
	},
	['cooldownFontColor'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraCooldownFontColor",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Cooldown Font Color:",
	},
	['bgColor'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraBackgroundColor",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Backdrop Color:",
	},
	['barColor'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraBarColor",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Bar Color:",
	},
	['borderColor'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraBorderColor",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Border Color:",
	},
	['textButton'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraTextButtonContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Text:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraTextButtonSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {80, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraTextButtonSubControl:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMasteryDisplayMenu_AuraTextButtonSubControl:SetText("Edit")
				AuraMasteryDisplayMenu_AuraTextButtonSubControl:SetHandler("OnClicked", AuraMastery.DisplayAuraTextWindow)
			end
		},
	},
	['activationState'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraActivationStateContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Enabled:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraActivationStateSubControl",
			['virtualName'] = "AM_CheckButton",
			['initHandler'] = function()
				ZO_CheckButton_SetToggleFunction(AuraMasteryDisplayMenu_AuraActivationStateSubControl, AuraMastery.EditAuraActivationState)
			end
		},
	},
	['width'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraWidthContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Width:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraWidthSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {42, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraWidthSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraWidth)
				AuraMasteryDisplayMenu_AuraWidthSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraWidth)
			end
		},
	},
	['height'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraHeightContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Height:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraHeightSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {42, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraHeightSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraHeight)
				AuraMasteryDisplayMenu_AuraHeightSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraHeight)
			end
		},
	},
	['posX'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraPosXContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "PosX:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraPosXSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {42, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraPosXSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraPosX)
				AuraMasteryDisplayMenu_AuraPosXSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraPosX)
			end
		},
	},
	['posY'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraPosYContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "PosY:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraPosYSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {42, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraPosYSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraPosY)
				AuraMasteryDisplayMenu_AuraPosYSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraPosY)
			end
		},
	},
	['alpha'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraAlphaContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Transparency [%]:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraAlphaSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {42, 20},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraAlphaSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraAlpha)
				AuraMasteryDisplayMenu_AuraAlphaSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraAlpha)
			end
		},
	},
	['borderSize'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraBorderSizeContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Border Size:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraBorderSizeSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				42, 20
			},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraBorderSizeSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraBorderSize)
				AuraMasteryDisplayMenu_AuraBorderSizeSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraBorderSize)
			end
		},
	},
	['criticalTime'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraCriticalTimeContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Critical Time:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraCriticalTimeSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				42, 20
			},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_AuraCriticalTimeSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditAuraCriticalTime)
				AuraMasteryDisplayMenu_AuraCriticalTimeSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditAuraCriticalTime)
			end
		},
	},
	['triggerActions'] = {
		['controlName'] = "AuraMasteryDisplayMenu_triggerActionsContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Actions/Animations:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_triggerActionsSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function()
				AuraMasteryDisplayMenu_triggerActionsSubControl:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMasteryDisplayMenu_triggerActionsSubControl:SetText("Edit")
				AuraMasteryDisplayMenu_triggerActionsSubControl:SetHandler("OnClicked", AuraMastery.DisplayAuraActionsMenu)		
			end
		},
	},
	['auraGroupAssignment'] = {
		['controlName'] = "AuraMasteryDisplayMenu_AuraGroupAssignmentContainer",
		['virtualName'] = "AM_TriggerControl",
		['dimensions'] = {210, 28},
		['label']		 = "Group:",
		['subControl']  = {
			['controlName'] = "AuraMasteryDisplayMenu_AuraGroupAssignmentSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				140, 20
			},
			['tooltipText'] = "Select a group to assign this aura to it.",
		},
	},
	
	-- Trigger Settings
	['actionResults'] = {
		['controlName'] = "AuraMasteryTriggerMenu_ActionResultsContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Action Results:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_ActionResultsSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function() 
				-- trigger action results button
				local actionResultButton = AuraMasteryTriggerMenu_ActionResultsSubControl
				actionResultButton:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				actionResultButton:SetText("Edit")
				actionResultButton:SetHandler("OnClicked", AuraMastery.DisplayTriggerActionResultsMenu)
			end
		},
	},
	['sourceCombatUnitType'] = {
		['controlName'] = "AuraMasterySourceCombatUnitTypeContainer",
		['virtualName'] = "AM_TriggerControl",
		['label'] 		 = "Cast by:",
		['subControl']  = {
			['controlName'] = "AuraMasterySourceCombatUnitTypeSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				160, 20
			},
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditTriggerSourceCombatUnitType
				local m_comboBox = AuraMasterySourceCombatUnitTypeSubControl.m_comboBox
				local items = {
					[1] = {name = "anyone", callback = selectionCallback, internalValue = false},
					[2] = {name = "me", callback = selectionCallback, internalValue = COMBAT_UNIT_TYPE_PLAYER},
					[3] = {name = "my pet", callback = selectionCallback, internalValue = COMBAT_UNIT_TYPE_PLAYER_PET},
					[4] = {name = "any group member", callback = selectionCallback, internalValue = COMBAT_UNIT_TYPE_GROUP},
					[5] = {name = "any other player", callback = selectionCallback, internalValue = COMBAT_UNIT_TYPE_OTHER},
					[6] = {name = "any NPC", callback = selectionCallback, internalValue = COMBAT_UNIT_TYPE_NONE},
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)	
			end
		},
	},	
	['LoadCustomTriggerMenuButton'] = {
		['controlName'] = "AuraMasteryTriggerMenu_LoadCustomTriggerMenuButtonContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Trigger Settings:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_LoadCustomTriggerMenuButtonSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function() 
				local customTriggerButton = AuraMasteryTriggerMenu_LoadCustomTriggerMenuButtonSubControl
				customTriggerButton:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				customTriggerButton:SetText("Edit")
				customTriggerButton:SetHandler("OnClicked", AuraMastery.DisplayCustomTriggerMenu)
			end
		},
	},
	['LoadCustomUntriggerMenuButton'] = {
		['controlName'] = "AuraMasteryTriggerMenu_LoadCustomUntriggerMenuButtonContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Untrigger Settings:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_LoadCustomUntriggerMenuButtonSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function()
				local customUntriggerButton = AuraMasteryTriggerMenu_LoadCustomUntriggerMenuButtonSubControl
				customUntriggerButton:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				customUntriggerButton:SetText("Edit")
				customUntriggerButton:SetHandler("OnClicked", AuraMastery.DisplayCustomUntriggerMenu)		
			end
		},
	},	
	['abilityId'] = {
		['controlName'] = "AuraMasteryTriggerMenu_AbilityIdContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Ability Id:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_AbilityIdSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryTriggerMenu_AbilityIdSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditTriggerAbilityId)
				AuraMasteryTriggerMenu_AbilityIdSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditTriggerAbilityId)
			end
		},
	},
	['unitTag'] = {
		['controlName'] = "AuraMasteryTriggerMenu_UnitTagContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Unit Tag (optional):",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_UnitTagSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryTriggerMenu_UnitTagSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditTriggerUnitTag)
				AuraMasteryTriggerMenu_UnitTagSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditTriggerUnitTag)
			end
		},	
	},	
	['casterName'] = {
		['controlName'] = "AuraMasteryTriggerMenu_CasterName",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Caster name (optional):",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_CasterNameSubControl",
			['virtualName'] = "AM_TextBox",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function()
				AuraMasteryTriggerMenu_CasterNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditTriggerCasterName)
				AuraMasteryTriggerMenu_CasterNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditTriggerCasterName)
			end
		},
	},
	['targetName'] = {
		['controlName'] = "AuraMasteryTriggerMenu_TargetName",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Target name (optional):",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_TargetNameSubControl",
			['virtualName'] = "AM_TextBox",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function()
				AuraMasteryTriggerMenu_TargetNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditTriggerTargetName)
				AuraMasteryTriggerMenu_TargetNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditTriggerTargetName)
			end
		},
	},
	['source'] = {
		['controlName'] = "AuraMasteryTriggerMenu_SourceContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Source Unit:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_SourceSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				100, 20
			},
			['tooltipText'] = "Select the source unit to check for the specified buff or debuff.",
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditTriggerSourceUnitTag
				local m_comboBox = AuraMasteryTriggerMenu_SourceSubControl.m_comboBox
				local items = {
					[1] = {name = "Me", callback = selectionCallback, internalValue = 1},
					[2] = {name = "My target", callback = selectionCallback, internalValue = 2}
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)			
			end
		},
	},
	['checkAll'] = {
		['controlName'] = "AuraMasteryTriggerMenu_CheckAll",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Check all Ability Ids:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_CheckAllSubControl",
			['virtualName'] = "AM_CheckButton",
			['initHandler'] = function()
				ZO_CheckButton_SetToggleFunction(AuraMasteryTriggerMenu_CheckAllSubControl, AuraMastery.EditTriggerCheckAll)
			end
		},		
	},
	['invert'] = {
		['controlName'] = "AuraMasteryTriggerMenu_Invert",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Invert:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_InvertSubControl",
			['virtualName'] = "AM_CheckButton",
			['initHandler'] = function()
				ZO_CheckButton_SetToggleFunction(AuraMasteryTriggerMenu_InvertSubControl, AuraMastery.EditTriggerInvert)
			end
		},
	},
	['operator'] = {
		['controlName'] = "AuraMasteryTriggerMenu_OperatorContainer",
		['virtualName'] = "AM_TriggerControl",
		['label'] 		 = "Operator:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_OperatorSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditTriggerOperator
				local m_comboBox = AuraMasteryTriggerMenu_OperatorSubControl.m_comboBox
				local items = {
					[1] = {name = "<", callback = selectionCallback, internalValue = 1},
					[2] = {name = ">", callback = selectionCallback, internalValue = 2},
					[3] = {name = "<=", callback = selectionCallback, internalValue = 3},
					[4] = {name = ">=", callback = selectionCallback, internalValue = 4},
					[5] = {name = "==", callback = selectionCallback, internalValue = 5},
					[6] = {name = "~=", callback = selectionCallback, internalValue = 6},
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)	
			end
		},
	},
	['value'] = {
		['controlName'] = "AuraMasteryTriggerMenu_Value",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Value:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_ValueSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				35, 20
			},
			['initHandler'] = function()
				AuraMasteryTriggerMenu_ValueSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditTriggerValue)
				AuraMasteryTriggerMenu_ValueSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditTriggerValue)
			end
		},
	},
	['duration'] = {
		['controlName'] = "AuraMasteryTriggerMenu_AuraDurationContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Duration:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_DurationSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				42, 20
			},
			['initHandler'] = function()
				AuraMasteryTriggerMenu_DurationSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditTriggerDuration)
				AuraMasteryTriggerMenu_DurationSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditTriggerDuration)
			end
		},
	},

	-- Custom Trigger Settings
	['customTriggerAbilityId'] = {
		['controlName'] = "AuraMasteryCustomTriggerAbilityIdContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Ability Id:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomTriggerAbilityIdSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryCustomTriggerAbilityIdSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditCustomTriggerAbilityId)
				AuraMasteryCustomTriggerAbilityIdSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditCustomTriggerAbilityId)
			end
		},
	},
	['customTriggerChangeType'] = {
		['controlName'] = "AuraMasteryCustomTriggerChangeTypeContainer",
		['virtualName'] = "AM_TriggerControl",
		['label'] 		 = "Change Type:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomTriggerChangeTypeSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				160, 20
			},
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditCustomTriggerChangeType
				local m_comboBox = AuraMasteryCustomTriggerChangeTypeSubControl.m_comboBox
				local items = {
					[1] = {name = "Effect gained", callback = selectionCallback, internalValue = 1},
					[2] = {name = "Effect faded", callback = selectionCallback, internalValue = 2},
					[3] = {name = "Effect refreshed", callback = selectionCallback, internalValue = 3},
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)			
			end
		},
	},
	['customTriggerUnitTag'] = {
		['controlName'] = "AuraMasteryCustomTriggerUnitTagContainer",
		['virtualName'] = "AM_TriggerControl",
		['label'] 		 = "Source:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomTriggerUnitTagSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				160, 20
			},
			['tooltipText'] = "Select where to check if the specified effect is active.",
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditCustomTriggerUnitTag
				local m_comboBox = AuraMasteryCustomTriggerUnitTagSubControl.m_comboBox
				local items = {
					[1] = {name = "Me", callback = selectionCallback, internalValue = 1},
					[2] = {name = "My target", callback = selectionCallback, internalValue = 2}
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)			
			end
		},
	},
	['customTriggerSourceName'] = {
		['controlName'] = "AuraMasteryCustomTriggerSourceNameContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Source Name:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomTriggerSourceNameSubControl",
			['virtualName'] = "AM_TextBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryCustomTriggerSourceNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditCustomTriggerSourceName)
				AuraMasteryCustomTriggerSourceNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditCustomTriggerSourceName)
			end
		},
	},
	['customTriggerTargetName'] = {
		['controlName'] = "AuraMasteryCustomTriggerTargetNameContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Target Name:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomTriggerTargetNameSubControl",
			['virtualName'] = "AM_TextBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryCustomTriggerTargetNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditCustomTriggerTargetName)
				AuraMasteryCustomTriggerTargetNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditCustomTriggerTargetName)
			end
		},
	},
	['customTriggerActionResults'] = {
		['controlName'] = "AuraMasteryTriggerMenu_CustomTriggerActionResultsContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Action Results:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_CustomTriggerActionResultsSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function() 
				-- trigger action results button
				local actionResultButton = AuraMasteryTriggerMenu_CustomTriggerActionResultsSubControl
				actionResultButton:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				actionResultButton:SetText("Edit")
				actionResultButton:SetHandler("OnClicked", AuraMastery.DisplayCustomTriggerActionResultsMenu)
			end
		},
	},
	
	-- Custom Untrigger Settings
	['customUntriggerAbilityId'] = {
		['controlName'] = "AuraMasteryCustomUntriggerAbilityIdContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Ability Id:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomUntriggerAbilityIdSubControl",
			['virtualName'] = "AM_EditBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryCustomUntriggerAbilityIdSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditCustomUntriggerAbilityId)
				AuraMasteryCustomUntriggerAbilityIdSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditCustomUntriggerAbilityId)
			end
		},
	},
	['customUntriggerChangeType'] = {
		['controlName'] = "AuraMasteryCustomUntriggerChangeTypeContainer",
		['virtualName'] = "AM_TriggerControl",
		['label'] 		 = "Change Type:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomUntriggerChangeTypeSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				160, 20
			},
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditCustomUntriggerChangeType
				local m_comboBox = AuraMasteryCustomUntriggerChangeTypeSubControl.m_comboBox
				local items = {
					[1] = {name = "Effect gained", callback = selectionCallback, internalValue = 1},
					[2] = {name = "Effect faded", callback = selectionCallback, internalValue = 2},
					[3] = {name = "Effect refreshed", callback = selectionCallback, internalValue = 3},
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)			
			end
		},
	},
	['customUntriggerUnitTag'] = {
		['controlName'] = "AuraMasteryCustomUntriggerUnitTagContainer",
		['virtualName'] = "AM_TriggerControl",
		['label'] 		 = "Source:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomUntriggerUnitTagSubControl",
			['virtualName'] = "AM_ComboBox",
			['dimensions'] = {
				160, 20
			},
			['tooltipText'] = "Select where to check if the specified effect is active.",
			['initHandler'] = function()
				local selectionCallback = AuraMastery.EditCustomUntriggerUnitTag
				local m_comboBox = AuraMasteryCustomUntriggerUnitTagSubControl.m_comboBox
				local items = {
					[1] = {name = "Me", callback = selectionCallback, internalValue = 1},
					[2] = {name = "My target", callback = selectionCallback, internalValue = 2}
				}
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, callback)			
			end
		},
	},
	['customUntriggerSourceName'] = {
		['controlName'] = "AuraMasteryCustomUntriggerSourceNameContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Source Name:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomUntriggerSourceNameSubControl",
			['virtualName'] = "AM_TextBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryCustomUntriggerSourceNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditCustomUntriggerSourceName)
				AuraMasteryCustomUntriggerSourceNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditCustomUntriggerSourceName)
			end
		},
	},
	['customUntriggerTargetName'] = {
		['controlName'] = "AuraMasteryCustomUntriggerTargetNameContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Target Name:",
		['subControl']  = {
			['controlName'] = "AuraMasteryCustomUntriggerTargetNameSubControl",
			['virtualName'] = "AM_TextBox",
			['dimensions'] = {
				52, 20
			},
			['initHandler'] = function()
				AuraMasteryCustomUntriggerTargetNameSubControl_Editbox:SetHandler("OnEnter", AuraMastery.EditCustomUntriggerTargetName)
				AuraMasteryCustomUntriggerTargetNameSubControl_Editbox:SetHandler("OnFocusLost", AuraMastery.EditCustomUntriggerTargetName)
			end
		},
	},
	['customUntriggerActionResults'] = {
		['controlName'] = "AuraMasteryTriggerMenu_CustomUntriggerActionResultsContainer",
		['virtualName'] = "AM_TriggerControl",
		['label']		 = "Action Results:",
		['subControl']  = {
			['controlName'] = "AuraMasteryTriggerMenu_CustomUntriggerActionResultsSubControl",
			['virtualName'] = "ZO_DefaultButton",
			['dimensions'] = {
				80, 20
			},
			['initHandler'] = function() 
				-- trigger action results button
				local actionResultButton = AuraMasteryTriggerMenu_CustomUntriggerActionResultsSubControl
				actionResultButton:SetFont("$(BOLD_FONT)|14|soft-shadow-thin")
				actionResultButton:SetText("Edit")
				actionResultButton:SetHandler("OnClicked", AuraMastery.DisplayCustomUntriggerActionResultsMenu)
			end
		},
	},	
}




AuraMastery.conversion = {
--[[
	['1.9'] = {
		['newFields'] = AuraMastery.AddActionResultFieldsToTriggers,

		['auraData'] = {
			['displaySettings'] = {},
			['triggerSettings'] = {
				['unitTag'] = {		-- table field
					{
						['old'] = "player",
						['new'] = 1,
					},
					{
						['old'] = "target",
						['new'] = 2,
					},
				},
				['operator'] = {
					{
						['old'] = "<",
						['new'] = 1,
					},
					{
						['old'] = ">",
						['new'] = 2,
					},
					{
						['old'] = "<=",
						['new'] = 3,
					},
					{
						['old'] = ">=",
						['new'] = 4,
					},
					{
						['old'] = "=",
						['new'] = 5,
					},
					{
						['old'] = "~=",
						['new'] = 6,
					},
				}
			}
		}

	}
	]]
}

function AuraMastery:AddActionResultFieldsToTriggers()
	for auraName, auraData in pairs(AuraMastery.svars.auraData) do

		local triggers = auraData.triggers

		for i=1,#triggers do
			local updateMsg
			local triggerData = AuraMastery.svars.auraData[auraName].triggers[i]

			if 4 == triggers[i].triggerType and not triggers[i].actionResults then
				AuraMastery.svars.auraData[auraName].triggers[i].actionResults = {}
				local updateMsg = "SVARS UPDATE: Updated combat event based triggers: Added field \"actionResults\" and inserted standard action results for aura \""..auraName.."\" (Trigger Nr. "..i..")" 
				table.insert(AuraMastery.svars.auraData[auraName].triggers[i].actionResults, 2240)
				table.insert(AuraMastery.svars.auraData[auraName].triggers[i].actionResults, 2245)
				table.insert(AuraMastery.svars.auraData[auraName].triggers[i].actionResults, 2250)
				deb(updateMsg, 2000)
			end
		end
	end
end

function AuraMastery:RenameFontFields()
	for auraName, auraData in pairs(AuraMastery.svars.auraData) do
		if 1 == auraData.aType then
			if not auraData.cooldownFontSize then
				AuraMastery.svars.auraData[auraName].cooldownFontSize = auraData['fontSize']
			end
			if not auraData.cooldownFontColor then
				AuraMastery.svars.auraData[auraName].cooldownFontColor = auraData['fontColor']		
			end

			if not auraData.textFontSize then
				AuraMastery.svars.auraData[auraName].textFontSize = auraData['fontSize']
			end
			if not auraData.textFontColor then
				AuraMastery.svars.auraData[auraName].textFontColor = auraData['fontColor']		
			end
			deb("SVARS UPDATE: \"fontSize\" and \"fontColor\" fields have been split into \"cooldownFont\" and \"textFont\" fields for aura \""..auraName.."\".", 2000)
		end

		-- progression bars
		if 2 == auraData.aType then
			if not auraData.cooldownFontSize then
				AuraMastery.svars.auraData[auraName].cooldownFontSize = auraData['fontSize']
			end
			if not auraData.cooldownFontColor then
				AuraMastery.svars.auraData[auraName].cooldownFontColor = auraData['fontColor']		
			end

			if not auraData.textFontSize then
				AuraMastery.svars.auraData[auraName].textFontSize = auraData['fontSize']
			end
			if not auraData.textFontColor then
				AuraMastery.svars.auraData[auraName].textFontColor = auraData['fontColor']		
			end
			deb("SVARS UPDATE: \"fontSize\" and \"fontColor\" fields have been split into \"cooldownFont\" and \"textFont\" fields for aura \""..auraName.."\".", 2000)
		end
		
		if 4 == auraData.aType then
			if not auraData.textFontSize then
				AuraMastery.svars.auraData[auraName].textFontSize = auraData['fontSize']
			end
			if not auraData.textFontColor then
				AuraMastery.svars.auraData[auraName].textFontColor = auraData['fontColor']		
			end
			deb("SVARS UPDATE: \"fontSize\" and \"fontColor\" fields have been split into \"cooldownFont\" and \"textFont\" fields for aura \""..auraName.."\".", 2000)
		end
	end
end
