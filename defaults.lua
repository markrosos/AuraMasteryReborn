AuraMastery.triggerAnimationDefaults = {
	['colors'] = {1,1,1,1},
	['endAlpha'] = .5,
	['duration'] = 250,
	['loopCount'] = 3
}

AuraMastery.defaults = {}

-- contains allowed and default values for all auras
AuraMastery.defaults.auraDataShared = {
	['loaded'] = {
		['type'] = "boolean",
		['default'] = true,
	},
	['aType'] = {
		['type'] = "number",
		['allowedValues'] = {
			1, 2, 4
		},
		['default'] = 1,
	},
	['name'] = {
		['type'] = "string",
	},
	['alpha'] = {
		['type'] = "number",
		['allowedValueRange'] = {
			['min'] = 0,
			['max'] = 1
		},
		['default'] = 1,
	},
	['width'] = {
		['type'] = "number",	
		['default'] = 64,
	},
	['height'] = {
		['type'] = "number",
		['default'] = 64,
	},
	['critical'] = {
		['type'] = "number",
		['default'] = 3,
	},
	['posX'] = {
		['type'] = "number",
		['default'] = 0,
	},
	['posY'] = {
		['type'] = "number",
		['default'] = 0,
	},
	['color'] = {
		['type'] = "table",
		['default'] = {['r']=1,['g']=1,['b']=1,['a']=1}
	},
	['triggers'] = {
		['type'] = "table",
		['default'] = {}
	},
	['animationData'] = {
		['type'] = "table",
		['default'] = nil
	},
	loadingConditions = {
		['type'] = "table",
		['default'] = {
			inCombatOnly = false,
			abilitiesSloted = {}
		}
	}	
}

-- contains allowed and default values for the specific aura types
AuraMastery.defaults.auraDataSpecific = {
	[1] = {
		borderSize = {
			['type'] = "number",
			['allowedValueRange'] = {
				['min'] = 0,
				['max'] = 3
			},
			['default'] = 1
		},
		borderColor = {
			['type'] = "table",
			['default'] = {
				r=0,
				g=0,
				b=0,
				a=1,
			}
		},
		bgColor = {
			['type'] = "table",
			['default'] = {
				r=1,
				g=1,
				b=1,
				a=0,
			}
		},
		showCooldownAnimation = {
			['type'] = "boolean",
			['default'] = true
		},
		showCooldownText = {
			['type'] = "boolean",
			['default'] = true
		},
		cooldownFontSize = {
			['type'] = "number",
			['default'] = 20,
		},
		cooldownFontColor = {
			['type'] = "table",
			['default'] = {
				r=.85,
				g=.85,
				b=.55,
				a=1,
			},
		},
		['text'] = {
			['type'] = "string",
			['default'] = ""
		},
		textFontSize = {
			['type'] = "number",
			['default'] = 20,
		},
		textFontColor = {
			['type'] = "table",
			['default'] = {
				r=.85,
				g=.85,
				b=.55,
				a=1,
			},
		},
		iconPath = {
			['type'] = "string",
			['default'] = ""
		},
	},
	[2] = {
		showCooldownText = {
			['type'] = "boolean",
			['default'] = true
		},
		cooldownFontColor = {
			['type'] = "table",
			['default'] = {
				r=.85,
				g=.85,
				b=.55,
				a=1,
			},
		},
		cooldownFontSize = {
			['type'] = "number",
			['default'] = 20,
		},
		borderSize = {
			['type'] = "number",
			['allowedValueRange'] = {
				['min'] = 0,
				['max'] = 3
			},
			['default'] = 1
		},
		borderColor = {
			['type'] = "table",
			['default'] = {
				r=0,
				g=0,
				b=0,
				a=1,
			}
		},
		bgColor = {
			['type'] = "table",
			['default'] = {
				r=1,
				g=1,
				b=1,
				a=.5,
			}
		},
		barColor = {
			['type'] = "table",
			['default'] = {
				r=1,
				g=1,
				b=1,
				a=1,
			}
		},
		iconPath = {
			['type'] = "string",
			['default'] = ""
		},
	},
	[3] = {},
	[4] = {
		text = {
			['type'] = "string",
			['default'] = "[INSERT TEXT HERE]"
		},
		textFontSize = {
			['type'] = "number",
			['default'] = 40,
		},
		textFontColor = {
			['type'] = "table",
			['default'] = {
				r=.85,
				g=.85,
				b=.55,
				a=1,
			},
		},
	}
}

AuraMastery.defaults.auraDataAllowed = {
	[1] = {	-- icon
		['textInfoSource'] = {
			['type'] = "number",
		},
		['durationInfoSource'] = {
			['type'] = "number",
		},
		['iconInfoSource'] = {
			['type'] = "number"
		},
	},
	[2] = { -- progress bar
		['durationInfoSource'] = {
			['type'] = "number",
		},
		['iconInfoSource'] = {
			['type'] = "number"
		},
	},
	[3] = {	-- currently not used (former "texture")
	},
	[4] = {	-- text
		['textInfoSource'] = {
			['type'] = "number",
		},
		['durationInfoSource'] = {
			['type'] = "number",
		},
	},
}

AuraMastery.defaults.triggersData = {
	
	-- buff / debuff
	[1] = {
		['sourceCombatUnitType'] = {
			['type'] = "boolean",
			['default'] = false
		},
		['value'] = {
			['type'] = "number",
			['default'] = 0,
		},
		['operator'] = {
			['type'] = "number",
			['allowedValues'] = {
				1,2,3,4,5,6
			},
			['default'] = 2,
		},
		['invert'] = {
			['type'] = "boolean",
			['default'] = false,
		},
		['checkAll'] = {
			['type'] = "boolean",	
			['default'] = false,
		},
		['triggerType'] = {
			['type'] = "number",
			['default'] = 1,
		},
		['spellId'] = {
			['type'] = "number",
			['default'] = 0,
		},
		['unitTag'] = {
			['type'] = "number",
			['default'] = 1,
		},
	},
	
	-- ability used
	[2] = {
		['value'] = {
			['type'] = "number",
			['default'] = 0,
		},
		['operator'] = {
			['type'] = "number",
			['allowedValues'] = {
				1,2,3,4,5,6
			},
			['default'] = 2,
		},
		['invert'] = {
			['type'] = "boolean",
			['default'] = false,
		},
		['checkAll'] = {
			['type'] = "boolean",	
			['default'] = false,
		},
		['triggerType'] = {
			['type'] = "number",
			['default'] = 2,
		},
		['spellId'] = {
			['type'] = "number",
			['default'] = 0,
		},
	},
	
	-- custom
	[3] = {
		['invert'] = {
			['type'] = "boolean",
			['default'] = false,
		},
		['triggerType'] = {
			['type'] = "number",
			['default'] = 3,
		},
		['customTriggerData'] = {
			['type'] = "table",
			['default'] = {
				['eventType'] = 1,
				['abilityId'] = 0,
				['changeType'] = 0,
				['unitTag'] = 1			
			}
		},
		['customUntriggerData'] = {
			['type'] = "table",
			['default'] = {
				['eventType'] = 1,
				['abilityId'] = 0,
				['changeType'] = 0,
				['unitTag'] = 1				
			},
		},
	},
	
	-- combat event
	[4] = {
		['actionResults'] = {
			['type'] = "table",
			['default'] = {
				[1] = 2240,
				[2] = 2245
			}
		},
		['checkAll'] = {
			['type'] = "boolean",	
			['default'] = false,
		},
		['invert'] = {
			['type'] = "boolean",
			['default'] = false,
		},		
		['spellId'] = {
			['type'] = "number",
			['default'] = 0,
		},
		['operator'] = {
			['type'] = "number",
			['allowedValues'] = {
				1,2,3,4,5,6
			},
			['default'] = 2,
		},
		['triggerType'] = {
			['type'] = "number",
			['default'] = 4,
		},		
		['value'] = {
			['type'] = "number",
			['default'] = 0,
		},
		['casterName'] = {
			['type'] = "string",
			['default'] = "",
		},
		['targetName'] = {
			['type'] = "string",
			['default'] = "",
		},	
	}
	

}

AuraMastery.defaults.loadingConditions = {
	['inCombatOnly'] = {
		['type'] = "boolean",
		['default'] = false,				
	},
	['abilitiesSloted'] = {
		['type'] = "table",
		['default'] = {}
	}
}
