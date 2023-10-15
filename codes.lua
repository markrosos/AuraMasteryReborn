--######## TODO: merge .lookup and .codes as they are the same from two versions of AM...

--
-- Lookup terminology:
-- 1. a type is an internal identifier that is used by the addon
-- 2. an id is the internal identifier used by the game client
-- 3. a name is the string that gets displayed in the addon's menu (inside combo boxes, etc.)
--
AuraMastery.lookup = {
	['auraTextAnchorPointsByTextPositionId'] = {
		{point=BOTTOMRIGHT, relativePoint=TOPLEFT},
		{point=BOTTOM, relativePoint=TOP},
		{point=BOTTOMLEFT, relativePoint=TOPRIGHT},
		{point=RIGHT, relativePoint=LEFT},
		{point=LEFT, relativePoint=RIGHT},
		{point=TOPRIGHT, relativePoint=BOTTOMLEFT},
		{point=TOP, relativePoint=BOTTOM},
		{point=TOPLEFT, relativePoint=BOTTOMRIGHT}
	},
	['eventNamesByEventTypes'] = {
		[1] = AURAMASTERY_EVENT_NAME_EFFECT_CHANGED,
		[2] = AURAMASTERY_EVENT_NAME_COMBAT_EVENT,   
		[3] = AURAMASTERY_EVENT_NAME_ACTION_SLOT_ABILITY_USED,
	},
	['eventIdsByEventTypes'] = {
		[1] = EVENT_EFFECT_CHANGED,
		[2] = EVENT_COMBAT_EVENT,
		[3] = EVENT_ACTION_SLOT_ABILITY_USED,
	},
	['eventTypesByEventIds'] = {
		[EVENT_EFFECT_CHANGED] = 1,
		[EVENT_COMBAT_EVENT] = 2,
		[EVENT_ACTION_SLOT_ABILITY_USED] = 3,
	},
	['eventHandlersByEventIds'] = {
		[EVENT_EFFECT_CHANGED] = AuraMastery.OnEffectEvent,
		[EVENT_ACTION_SLOT_ABILITY_USED] = AuraMastery.OnActionSlotAbilityUsed,
		[EVENT_COMBAT_EVENT] = AuraMastery.OnCombatEvent,
		[EVENT_RETICLE_TARGET_CHANGED] = AuraMastery.OnReticleTargetChanged
	},
	['untriggerNamesByUntriggerTypes'] = {
		AURAMASTERY_UNTRIGGER_NAME_TIME_BASED,
		AURAMASTERY_UNTRIGGER_NAME_EVENT_BASED
	},
	['combatUnitTypeNamesByCombatUnitTypesInternal'] = {
		[1] = "anyone",
		[2] = "me",
		[3] = "my Pet",
		[4] = "any group member",
		[5] = "any other player",
		[6] = "any NPC"
	},
	['combatUnitTypesByCombatUnitTypesInternal'] = {
		[1] = false,
		[2] = COMBAT_UNIT_TYPE_PLAYER,
		[3] = COMBAT_UNIT_TYPE_PLAYER_PET,
		[4] = COMBAT_UNIT_TYPE_GROUP,
		[5] = COMBAT_UNIT_TYPE_OTHER,
		[6] = COMBAT_UNIT_TYPE_NONE,
	},
	['actionBarNamesByActionBarIds'] = {
		"any",
		"frontbar",
		"backbar"
	},
	['actionSlotNamesByActionSlotTypes'] = {
		"any",
		-- "quick slot", NOTE: Appareantly ACTION_SLOT_ABILITY_USED is not fired by quick slot (potions, etc.)
		"ability in slot 1",
		"ability in slot 2",
		"ability in slot 3",
		"ability in slot 4",
		"ability in slot 5",
		"ultimate",
	},
	['actionSlotIdsByActionSlotTypes'] = {
		[1] = false,
		[2] = 3,
		[3] = 4,
		[4] = 5,
		[5] = 6,
		[6] = 7,
		[7] = 8
	},
	['actionBarNamesByActionBarTypes'] = {
		[1] = "any",
		[2] = "frontbar",
		[3] = "backbar"
	},
	['actionBarIdsByActionBarTypes'] = {
		[1] = false,
		[2] = 1,
		[3] = 2
	},
	['eventParamsByEventIds'] = {
		[EVENT_EFFECT_CHANGED] = {"eventCode","changeType","effectSlot","effectName","unitTag","beginTime","endTime","stackCount","iconName","buffType","effectType","abilityType","statusEffectType","unitName","unitId","abilityId","combatUnitType"},
		[EVENT_COMBAT_EVENT] = {"eventCode","result","isError","abilityName","abilityGraphic","abilityActionSlotType","sourceName","sourceType","targetName","targetType","hitValue","powerType","damageType","combatEventLog","sourceUnitId","targetUnitId","abilityId"},
		[EVENT_ACTION_SLOT_ABILITY_USED] = {"eventCode","slotId"},
	},
	['textReplacersByEventTypes'] = {
		[1] = {	-- effect event
			['{s}'] = "Stacks",
			['{d}'] = "time remaining",
		},
		[2] = {},
		[3] = {
			['-'] = "Custom events are currently not supported, sorry!"
		},
		[4] = {
			['{sn}'] = "source unit's name",
			['{tn}'] = "target unit's name",
			['{d}'] = "time remaining"
		}
	},
	['textReplacerNamesByEventTypes'] = {
		[1] = {	-- effect event
			['{s}'] = "Stacks",
			['{d}'] = "time remaining",
		},
		[2] = {},
		[3] = {
			['-'] = "Custom events are currently not supported, sorry!"		
		},
		[4] = {
			['{sn}'] = "source unit's name",
			['{tn}'] = "target unit's name",
			['{d}'] = "time remaining"
		}
	},
	['triggerCombatUnitNamesByCombatUnitTypes'] = {
		[1] = {
		
		}
	}
}

AuraMastery.codes = {
	['eventTypesByTriggerTypes'] = {
		[1] = EVENT_EFFECT_CHANGED,
		[2] = EVENT_ACTION_SLOT_ABILITY_USED,
		[4] = EVENT_COMBAT_EVENT
	},
	--[[ currently not used
	['eventHandlersByTriggerTypes'] = {
		[1] = AuraMastery.OnEffectEvent,
		[2] = AuraMastery.OnActionSlotAbilityUsed,
		[4] = AuraMastery.OnCombatEvent		
	},
	]]
	['eventHandlersByEventTypes'] = {
		[EVENT_EFFECT_CHANGED] = AuraMastery.OnEffectEvent,
		[EVENT_ACTION_SLOT_ABILITY_USED] = AuraMastery.OnActionSlotAbilityUsed,
		[EVENT_COMBAT_EVENT] = AuraMastery.OnCombatEvent,
		[EVENT_RETICLE_TARGET_CHANGED] = AuraMastery.OnReticleTargetChanged
	},
	['triggerEventsControlNameToEventCode'] = {
		['AuraMasteryAuraMenu_TriggerEventsControl01_SubControl'] = {1, 2, 8, 2120, 2460, 2151, 1073741825, 1073741826}
	},
	['combatEventActionResults'] = {
		[2080] = "ACTION_RESULT_ABILITY_ON_COOLDOWN",	
		[2120] = "ACTION_RESULT_ABSORBED",
		[2040] = "ACTION_RESULT_BAD_TARGET",
		[3210] = "ACTION_RESULT_BATTLE_STANDARDS_DISABLED",
		[3180] = "ACTION_RESULT_BATTLE_STANDARD_ALREADY_EXISTS_FOR_GUILD",
		[3160] = "ACTION_RESULT_BATTLE_STANDARD_LIMIT",
		[3200] = "ACTION_RESULT_BATTLE_STANDARD_NO_PERMISSION",
		[3170] = "ACTION_RESULT_BATTLE_STANDARD_TABARD_MISMATCH",
		[3190] = "ACTION_RESULT_BATTLE_STANDARD_TOO_CLOSE_TO_CAPTURABLE",
		[2200] = "ACTION_RESULT_BEGIN",
		[2210] = "ACTION_RESULT_BEGIN_CHANNEL",
		[2360] = "ACTION_RESULT_BLADETURN",
		[2150] = "ACTION_RESULT_BLOCKED",	
		[2151] = "ACTION_RESULT_BLOCKED_DAMAGE",	
		[2030] = "ACTION_RESULT_BUSY",	
		[2290] = "ACTION_RESULT_CANNOT_USE",
		[2330] = "ACTION_RESULT_CANT_SEE_TARGET",
		[3410] = "ACTION_RESULT_CANT_SWAP_WHILE_CHANGING_GEAR",
		[2060] = "ACTION_RESULT_CASTER_DEAD",	
		   [2] = "ACTION_RESULT_CRITICAL_DAMAGE",	
		  [32] = "ACTION_RESULT_CRITICAL_HEAL",	
		   [1] = "ACTION_RESULT_DAMAGE",
		[2460] = "ACTION_RESULT_DAMAGE_SHIELDED",	
		[2190] = "ACTION_RESULT_DEFENDED",	
		[2260] = "ACTION_RESULT_DIED",	
		[2262] = "ACTION_RESULT_DIED_XP",	
		[2430] = "ACTION_RESULT_DISARMED",	
		[2340] = "ACTION_RESULT_DISORIENTED",	
		[2140] = "ACTION_RESULT_DODGED",	
		[1073741825] = "ACTION_RESULT_DOT_TICK",	
		[1073741826] = "ACTION_RESULT_DOT_TICK_CRITICAL",	
		[2250] = "ACTION_RESULT_EFFECT_FADED",	
		[2240] = "ACTION_RESULT_EFFECT_GAINED",	
		[2245] = "ACTION_RESULT_EFFECT_GAINED_DURATION",	
		[2110] = "ACTION_RESULT_FAILED",	
		[2310] = "ACTION_RESULT_FAILED_REQUIREMENTS",	
		[3100] = "ACTION_RESULT_FAILED_SIEGE_CREATION_REQUIREMENTS",	
		[2500] = "ACTION_RESULT_FALLING",	
		[2420] = "ACTION_RESULT_FALL_DAMAGE",	
		[2320] = "ACTION_RESULT_FEARED",
		[3230] = "ACTION_RESULT_FORWARD_CAMP_ALREADY_EXISTS_FOR_GUILD",
		[3240] = "ACTION_RESULT_FORWARD_CAMP_NO_PERMISSION",	
		[3220] = "ACTION_RESULT_FORWARD_CAMP_TABARD_MISMATCH",	
		[3080] = "ACTION_RESULT_GRAVEYARD_DISALLOWED_IN_INSTANCE",	
		[3030] = "ACTION_RESULT_GRAVEYARD_TOO_CLOSE",	
		  [16] = "ACTION_RESULT_HEAL",	
		[1073741840] = "ACTION_RESULT_HOT_TICK",	
		[1073741856] = "ACTION_RESULT_HOT_TICK_CRITICAL",	
		[2000] = "ACTION_RESULT_IMMUNE",	
		[2090] = "ACTION_RESULT_INSUFFICIENT_RESOURCE",	
		[2410] = "ACTION_RESULT_INTERCEPTED",	
		[2230] = "ACTION_RESULT_INTERRUPT",	
		[2810] = "ACTION_RESULT_INVALID_FIXTURE",	
		[3420] = "ACTION_RESULT_INVALID_JUSTICE_TARGET",	
		[2800] = "ACTION_RESULT_INVALID_TERRAIN",	
		[2510] = "ACTION_RESULT_IN_AIR",	
		[2300] = "ACTION_RESULT_IN_COMBAT",	
		[2610] = "ACTION_RESULT_IN_ENEMY_KEEP",	
		[2613] = "ACTION_RESULT_IN_ENEMY_OUTPOST",	
		[2612] = "ACTION_RESULT_IN_ENEMY_RESOURCE",	
		[2611] = "ACTION_RESULT_IN_ENEMY_TOWN",	
		[3440] = "ACTION_RESULT_IN_HIDEYHOLE",
		[3130] = "ACTION_RESULT_KILLED_BY_SUBZONE",	
		[2265] = "ACTION_RESULT_KILLING_BLOW",	
		[2475] = "ACTION_RESULT_KNOCKBACK",		
		[2400] = "ACTION_RESULT_LEVITATED",		
		[2392] = "ACTION_RESULT_LINKED_CAST",
		[3140] = "ACTION_RESULT_MERCENARY_LIMIT",
		[2180] = "ACTION_RESULT_MISS",		
		[3040] = "ACTION_RESULT_MISSING_EMPTY_SOUL_GEM",		
		[3060] = "ACTION_RESULT_MISSING_FILLED_SOUL_GEM",		
		[3150] = "ACTION_RESULT_MOBILE_GRAVEYARD_LIMIT",		
		[3070] = "ACTION_RESULT_MOUNTED",		
		[2630] = "ACTION_RESULT_MUST_BE_IN_OWN_KEEP",		
		[3430] = "ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE",		
		[3050] = "ACTION_RESULT_NOT_ENOUGH_INVENTORY_SPACE_SOUL_GEM",		
		[3090] = "ACTION_RESULT_NOT_ENOUGH_SPACE_FOR_SIEGE",		
		[2700] = "ACTION_RESULT_NO_LOCATION_FOUND",		
		[2910] = "ACTION_RESULT_NO_RAM_ATTACKABLE_TARGET_WITHIN_RANGE",		
		[3400] = "ACTION_RESULT_NO_WEAPONS_TO_SWAP_TO",		
		[2640] = "ACTION_RESULT_NPC_TOO_CLOSE",		
		[2440] = "ACTION_RESULT_OFFBALANCE",		
		[2390] = "ACTION_RESULT_PACIFIED",		
		[2130] = "ACTION_RESULT_PARRIED",		
		[2170] = "ACTION_RESULT_PARTIAL_RESIST",		
		  [64] = "ACTION_RESULT_POWER_DRAIN",		
		 [128] = "ACTION_RESULT_POWER_ENERGIZE",		
		   [4] = "ACTION_RESULT_PRECISE_DAMAGE",		
		[2350] = "ACTION_RESULT_QUEUED",		
		[3120] = "ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_DESTROYED",		
		[3110] = "ACTION_RESULT_RAM_ATTACKABLE_TARGETS_ALL_OCCUPIED",		
		[2520] = "ACTION_RESULT_RECALLING",		
		[2111] = "ACTION_RESULT_REFLECTED",		
		[3020] = "ACTION_RESULT_REINCARNATING",		
		[2160] = "ACTION_RESULT_RESIST",		
		[2490] = "ACTION_RESULT_RESURRECT",		
		[2480] = "ACTION_RESULT_ROOTED",		
		[2620] = "ACTION_RESULT_SIEGE_LIMIT",		
		[2605] = "ACTION_RESULT_SIEGE_NOT_ALLOWED_IN_ZONE",		
		[2600] = "ACTION_RESULT_SIEGE_TOO_CLOSE",		
		[2010] = "ACTION_RESULT_SILENCED",		
		[2025] = "ACTION_RESULT_SNARED",		
		[3000] = "ACTION_RESULT_SPRINTING",	
		[2470] = "ACTION_RESULT_STAGGERED",		
		[2020] = "ACTION_RESULT_STUNNED",		
		[3010] = "ACTION_RESULT_SWIMMING",		
		[2050] = "ACTION_RESULT_TARGET_DEAD",		
		[2070] = "ACTION_RESULT_TARGET_NOT_IN_VIEW",		
		[2391] = "ACTION_RESULT_TARGET_NOT_PVP_FLAGGED",		
		[2100] = "ACTION_RESULT_TARGET_OUT_OF_RANGE",		
		[2370] = "ACTION_RESULT_TARGET_TOO_CLOSE",		
		[2900] = "ACTION_RESULT_UNEVEN_TERRAIN",		
		[2450] = "ACTION_RESULT_WEAPONSWAP",		
		   [8] = "ACTION_RESULT_WRECKING_DAMAGE",	
		[2380] = "ACTION_RESULT_WRONG_WEAPON"
	}
}