AuraMastery 				= {}
AuraMastery.name 			= "AuraMastery"
AuraMastery.version 		= "1.20"-- ATTENTION!!! Don't forget to update version data in prototriggers.lua (AuraMastery.conversion) and AuraMastery.txt
AuraMastery.author			= "Letho"
AuraMastery.mode 			= AM_MODE_NORMAL

AM_ERRORS = {}
local WM = WINDOW_MANAGER

local profileDefaults 		 = {
	updateSpeed				= 100,
	activeProfile			= 1,
	version					= AuraMastery.version,
	profiles					= {
		["profileNames"] 	= {
			[1] 				= "default",
		},
		["profileData"] 	= {
			[1] = {
				['auraData'] = {},
				['groupsData'] = {}
			},
		}
	}	
}

-- Current Mode AM is running in (normal = 1, edit = 2, debug = 3)
AuraMastery.mode = 1

-- lookup table that contains all ability ids for a specific ability name
AuraMastery.abilityIds 				= {}

-- buffs / debuffs
AuraMastery.activeEffects	 	 	= {}

-- ground effects
AuraMastery.activeFakeEffects  		= {}

-- effects on current target
AuraMastery.ROActiveEffects 	 	= {}

-- combat effects
AuraMastery.activeCombatEffects 	= {}

--[[ custom triggers
Structure:
AuraMastery.customTriggers = {
	[EVENTID] = {
		['trigger'] = {
			['AURANAME'] = {
		
			}
		},
		['untrigger'] = {
			
		}
	}
}
]]
AuraMastery.customTriggers 			= {}

--[[ Contains all time values for currently active auras that have user specified display durations
Structure:
AuraMastery.activeCustomDurations = {
	[EVENT_ID] = {
		[AURANAME] = {
			[ABILITYID] = {
				[NUM_TABLE_INDEX] = {
					['endTime'] = TIMESTAMP
				}
			},
			[...],
		}
	}
}
]]
AuraMastery.activeCustomDurations 	= {
	[EVENT_COMBAT_EVENT] = {},
	[EVENT_ACTION_SLOT_ABILITY_USED] = {}
}

--[[ Lookup table for events and their relevant abilities and custom durations
Structure:
AuraMastery.trackedEvents = {
	[EVENT_EFFECT_CHANGED] = {		
		['abilityIds'] = {
			[ABILITYID] = {
				[NUM_TABLE_INDEX] = "AURANAME"
			},
			[...],
		},
	},
	[EVENT_COMBAT_EVENT] = {
		['abilityIds'] = {
			[ABILITYID] = {
				[NUM_TABLE_INDEX] = "AURANAME"
			},
			[...],
		},
		['actionResults'] = {
			[ABILITYID] = {
				[ACTION_RESULT_ID] = {
					[NUM_TABLE_INDEX] = "AURANAME"
				}
			},
			[...],		
		},
		['custom'] = {
			[ABILITYID] = {
				['AURANAME'] = DISPLAY_DURATION (seconds)
			},
			[...],	
		},
	},
	[EVENT_ACTION_SLOT_ABILITY_USED] = {
		['abilityIds'] = {
			[ABILITYID] = {
				[NUM_TABLE_INDEX] = "AURANAME"
			},
			[...],		
		},
		['custom'] = {
			[ABILITYID] = {
				['AURANAME'] = DISPLAY_DURATION (seconds)
			},
			[...],	
		},
	}
}
]]

function RefreshActionBarData()
    local frontBarSlots = ACTION_BAR_ASSIGNMENT_MANAGER['hotbars'][0]['slots']
    local backBarSlots = ACTION_BAR_ASSIGNMENT_MANAGER['hotbars'][1]['slots']

    AuraMastery.actionBarData = {
        [1] = {
            [1] = 0,
            [2] = 0,
            [3] = frontBarSlots[3]:IsUsable() and frontBarSlots[3]:GetEffectiveAbilityId() or 0,
            [4] = frontBarSlots[4]:IsUsable() and frontBarSlots[4]:GetEffectiveAbilityId() or 0,
            [5] = frontBarSlots[5]:IsUsable() and frontBarSlots[5]:GetEffectiveAbilityId() or 0,
            [6] = frontBarSlots[6]:IsUsable() and frontBarSlots[6]:GetEffectiveAbilityId() or 0,
            [7] = frontBarSlots[7]:IsUsable() and frontBarSlots[7]:GetEffectiveAbilityId() or 0,
            [8] = frontBarSlots[8]:IsUsable() and frontBarSlots[8]:GetEffectiveAbilityId() or 0,
            [9] = 0,
            [10] = 0,
        },
        [2] = {
            [1] = 0,
            [2] = 0,
            [3] = backBarSlots[3]:IsUsable() and backBarSlots[3]:GetEffectiveAbilityId() or 0,
            [4] = backBarSlots[4]:IsUsable() and backBarSlots[4]:GetEffectiveAbilityId() or 0,
            [5] = backBarSlots[5]:IsUsable() and backBarSlots[5]:GetEffectiveAbilityId() or 0,
            [6] = backBarSlots[6]:IsUsable() and backBarSlots[6]:GetEffectiveAbilityId() or 0,
            [7] = backBarSlots[7]:IsUsable() and backBarSlots[7]:GetEffectiveAbilityId() or 0,
            [8] = backBarSlots[8]:IsUsable() and backBarSlots[8]:GetEffectiveAbilityId() or 0,
            [9] = 0,
            [10] = 0,
        }
    }
end

AuraMastery.trackedEvents = {
	[EVENT_EFFECT_CHANGED] = {		
		['abilityIds'] = {},
		-- buffs and debuffs have no custom duration option
	},
	[EVENT_COMBAT_EVENT] = {
		['abilityIds'] = {},
		['actionResults'] = {},
		['custom'] = {},
	},
	[EVENT_ACTION_SLOT_ABILITY_USED] = {
		['abilityIds'] = {},
		['custom'] = {},
	}
}

-- lookup table for aura display durations
AuraMastery.auraDurations = {}

-- all currently loaded auras
AuraMastery.loadedAuras = {}

-- contains all ability ids of abilities that are currenty equiped

local frontBarSlots = ACTION_BAR_ASSIGNMENT_MANAGER['hotbars'][0]['slots']
local backBarSlots = ACTION_BAR_ASSIGNMENT_MANAGER['hotbars'][1]['slots']
AuraMastery.actionBarData = {
								[1] = {
									[1] = 0,
									[2] = 0,
									[3] = frontBarSlots[3]:IsUsable() and frontBarSlots[3]:GetEffectiveAbilityId() or 0,
									[4] = frontBarSlots[4]:IsUsable() and frontBarSlots[4]:GetEffectiveAbilityId() or 0,
									[5] = frontBarSlots[5]:IsUsable() and frontBarSlots[5]:GetEffectiveAbilityId() or 0,
									[6] = frontBarSlots[6]:IsUsable() and frontBarSlots[6]:GetEffectiveAbilityId() or 0,
									[7] = frontBarSlots[7]:IsUsable() and frontBarSlots[7]:GetEffectiveAbilityId() or 0,
									[8] = frontBarSlots[8]:IsUsable() and frontBarSlots[8]:GetEffectiveAbilityId() or 0,
									[9] = 0,
									[10] = 0,									
								},
								[2] = {
									[1] = 0,
									[2] = 0,
									[3] = backBarSlots[3]:IsUsable() and backBarSlots[3]:GetEffectiveAbilityId() or 0,
									[4] = backBarSlots[4]:IsUsable() and backBarSlots[4]:GetEffectiveAbilityId() or 0,
									[5] = backBarSlots[5]:IsUsable() and backBarSlots[5]:GetEffectiveAbilityId() or 0,
									[6] = backBarSlots[6]:IsUsable() and backBarSlots[6]:GetEffectiveAbilityId() or 0,
									[7] = backBarSlots[7]:IsUsable() and backBarSlots[7]:GetEffectiveAbilityId() or 0,
									[8] = backBarSlots[8]:IsUsable() and backBarSlots[8]:GetEffectiveAbilityId() or 0,
									[9] = 0,
									[10] = 0,
								}
							}

-- contains all menu elements and the pool object
AuraMastery.controls = {
	pool 	 = {},
	settings = {}
}

function AuraMastery.OnAddOnLoaded(event, addonName)
	if addonName ~= AuraMastery.name then return end	
	EVENT_MANAGER:UnregisterForEvent(AuraMastery.name, EVENT_ADD_ON_LOADED)
	AuraMastery:Initialize()
end

function AuraMastery:Initialize()
	self:LoadProfileData()
	if AuraMastery.svars.version ~= AuraMastery.version then
		zo_callLater(function() d("UPDATING...") end, 3000)
		self:Update()
	end
	for auraName, auraData in pairs(self.svars.auraData) do
		-- validate data first and insert missing fields (use defaults)
		self:ValidateAuraData(auraData)
	end
	self:InitializeControls()
	
	-- register the addon's central update handler
	EVENT_MANAGER:RegisterForUpdate(AuraMastery.name, AuraMastery.savedVariables.updateSpeed, AuraMastery.updateHandler)
	EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_RETICLE_TARGET_CHANGED, AuraMastery.OnReticleTargetChanged)
	--EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, AuraMastery.OnActiveWeaponPairChanged)
	EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_ACTION_SLOT_UPDATED, AuraMastery.OnActionSlotUpdated)
	EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_PLAYER_COMBAT_STATE, AuraMastery.OnPlayerCombatState)
	EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_PLAYER_ACTIVATED, AuraMastery.OnPlayerActivated)
	EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_PLAYER_DEACTIVATED, AuraMastery.OnPlayerDeactivated) 
end


function AuraMastery.OnActionSlotUpdated(eventCode, slotId)
    -- refresh action bar data every time an action slot is updated
    RefreshActionBarData()

    -- d("Action slot " .. slotId .. " was updated.")
    local activeBar = GetActiveWeaponPairInfo()
    
    if (1 == slotId or 2 == slotId or not AuraMastery.actionBarData[activeBar]) then return; end  -- 1 = light attack, 2 = heavy attack
    
    local oldAbilityId = AuraMastery.actionBarData[activeBar][slotId]
    local newAbilityId = GetSlotBoundId(slotId)
    
    -- d("Action slot " .. slotId .. " was updated. Old ID: " .. (oldAbilityId or "nil") .. " New ID: " .. (newAbilityId or "nil"))
    
    AuraMastery:UpdateActionBarSetup(slotId, newAbilityId)
    for auraName, auraData in pairs(AuraMastery.svars.auraData) do
        if auraData.loaded then 
            local shouldLoad = AuraMastery:CheckLoadingCondition(loadingConditionType, loadingConditionData)  
            AuraMastery:UpdateAuraLoadingState(auraName, shouldLoad)  -- modified this function to accept a second argument that forces an aura's state if provided
            -- AuraMastery:UpdateAuraLoadingState(auraName) -- old function
        end
    end
end

function AuraMastery.OnPlayerCombatState(_, inCombat)
	AuraMastery.playerCombatState = inCombat
	for auraName, auraData in pairs(AuraMastery.svars.auraData) do
		if auraData.loaded then 
			AuraMastery:UpdateAuraLoadingState(auraName)
		end
	end
end

function AuraMastery.OnPlayerActivated()
	-- prevents some problems if abilities run out during loading screens
	AuraMastery.activeEffects = {}
	local loadedAuras = AuraMastery.loadedAuras
	local numLoadedAuras = #loadedAuras
	for i=1, numLoadedAuras do
		local auraName = loadedAuras[i]
		local auraObj = AuraMastery.aura[auraName]
		local conditionsMet = auraObj:CheckTriggersBaseconditionsMet()
		if conditionsMet then
			auraObj:Trigger()
		end
	end
	
end

function AuraMastery.OnPlayerDeactivated()
	for auraName, _ in pairs(AuraMastery.aura) do
		AuraMastery.aura[auraName]:Untrigger()
	end
end

function AuraMastery:SetMode(mode)
	self.mode = mode
end

function AuraMastery:GetMode()
	return self.mode
end

function AuraMastery:UpdateActionBarSetup(slotId, abilityId)
	local activeActionBar = GetActiveWeaponPairInfo()
	AuraMastery.actionBarData[activeActionBar][slotId] = abilityId
end

function AuraMastery:IsAbilitySloted(abilityId)
	-- d("[AuraMastery] Checking if ability ID " .. abilityId .. " is slotted.")
	for actionBar = 1, 2 do
		for actionBarSlot = 3, 8 do
			if abilityId == self.actionBarData[actionBar][actionBarSlot] then return true end
			-- d("[AuraMastery] Found ability ID " .. abilityId .. " slotted in action bar " .. actionBar .. " slot " .. actionBarSlot)
		end
	end
	return false
end

function AuraMastery:LoadProfileData()
	self.savedVariables = ZO_SavedVars:New("AuraMasterySavedVariables", 1, nil, profileDefaults)
	self.svars = self.savedVariables.profiles.profileData[self.savedVariables.activeProfile]
end

function AuraMastery:Update()
	local addonVersion = self.version
	local svarsVersion = self.svars.version

	self:UpdateVersion()
	--[[
		self:AddActionResultFieldsToTriggers()
	self:RenameFontFields()
]]	
--	for auraName, auraData in pairs(self.svars.auraData) do
-- validate data first and insert missing fields (use defaults)
--		self:ValidateAuraData(auraData)
--[[		
	-- display settings
		if self.conversion[addonVersion] then
			for fieldName, fieldData in pairs(auraData) do
				local fieldChanges = self.conversion[addonVersion]['auraData']['displaySettings'][fieldName]
				-- convert display settings for each aura
				if fieldChanges then
					for i=1,#fieldChanges do
						if self.conversion[addonVersion]['auraData']['displaySettings'][fieldName][i]['old'] == svars.auraData[auraName][fieldName] then
							self.svars.auraData[auraName][fieldName] = self.conversion[addonVersion]['auraData']['displaySettings'][fieldName][i]['new']
							--d("Setting "..self.svars.auraData[auraName][fieldName].." to "..self.conversion[addonVersion]['auraData']['displaySettings'][fieldName][i]['new']..".")
						end
					end
				end
			end

			-- trigger settings	
			for i=1, #auraData.triggers do
				for fieldName, fieldValue in pairs(auraData.triggers[i]) do
					local fieldChanges = self.conversion[addonVersion]['auraData']['triggerSettings'][fieldName]
					-- convert trigger settings for each trigger
					if fieldChanges then
						for j=1,#fieldChanges do
							if fieldChanges[j]['old'] == fieldValue then
								self.svars.auraData[auraName].triggers[i][fieldName] = self.conversion[addonVersion]['auraData']['triggerSettings'][fieldName][j]['new']
								--d("Setting "..self.svars.auraData[auraName].triggers[i][fieldName].." to "..self.conversion[addonVersion]['auraData']['triggerSettings'][fieldName][j]['new'].." for aura \""..auraName.."\", trigger"..i..".")
							end
						end

					end
				end
			end
			
			-- loading conditions settings	
			for fieldName, fieldValue in pairs(auraData.loadingConditions) do
				local fieldChanges = self.conversion[addonVersion]['auraData']['loadingConditions'][fieldName]
				-- convert trigger settings for each trigger
				if fieldChanges then
					for j=1,#fieldChanges do
						if fieldChanges[j]['old'] == fieldValue then
							self.svars.auraData[auraName].loadingConditions[fieldName] = self.conversion[addonVersion]['auraData']['loadingConditions'][fieldName][j]['new']
							--d("Setting "..self.svars.auraData[auraName].triggers[i][fieldName].." to "..self.conversion[addonVersion]['auraData']['triggerSettings'][fieldName][j]['new'].." for aura \""..auraName.."\", trigger"..i..".")
						end
					end

				end
			end		
		end]]
--	end
end

function AuraMastery:UpdateVersion()
	self.svars.version = self.version
	zo_callLater(function() d("AuraMastery: Saved variables have been updated to version "..self.svars.version.." for this character."); end,3000)
end

function AuraMastery:ValidateAuraData(auraData)
	local auraName
	if nil == auraData['name'] then
		zo_callLater(function() d("Fatal error: Unnamed aura detected, factory reset needed. Please log out and delete the file AuraMastery.lua from your ESO's SavedVariables folder."); end, 3000)
		return
	else
		auraName = auraData['name']
	end
	local defaultsShared = AuraMastery.defaults.auraDataShared
	local errMsg
	AM_ERRORS[auraName] = {}
	
	-- add missing shared fields
	for fieldName, fieldDefaults in pairs(defaultsShared) do
		local defaultValue = fieldDefaults['default']
		
		-- check for all required fields
		if nil == auraData[fieldName] then
			errMsg = "Missing field: \""..fieldName.."\" for aura \""..auraName.."\"."
			table.insert(AM_ERRORS[auraName], errMsg)
			self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)
		else

			-- check for proper type
			local fieldType = type(auraData[fieldName])
			if fieldType ~= fieldDefaults['type'] then
				errMsg = "Wrong data type for field "..fieldName.."\": "..tostring(fieldDefaults['type']).."\" expected, got \""..tostring(fieldType).."\" for aura \""..auraName.."\"."
				table.insert(AM_ERRORS[auraName], errMsg)
				self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)	
			else

				-- check for allowed values
				if fieldDefaults['allowedValues'] then
					local allowed = false
					for i=1,#fieldDefaults['allowedValues'] do
						if (auraData[fieldName] == fieldDefaults['allowedValues'][i]) then
							allowed = true
							break
						end
					end
					if not(allowed) then
						errMsg = "Invalid field value detected: \""..fieldName.." = "..auraData[fieldName].."\" for aura \""..auraName.."\"."
						table.insert(AM_ERRORS[auraName], errMsg)
						self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)	
					end
				end
				
				-- check for allowed value range
				if (fieldDefaults['allowedValueRange']) then
					local minVal = fieldDefaults['allowedValueRange']['min']
					local maxVal = fieldDefaults['allowedValueRange']['max']
					if "number" == fieldType and (auraData[fieldName] < minVal or auraData[fieldName] > maxVal) then
						errMsg = "Field value ("..fieldDefaults..") out of allowed value range: "..minVal.." to "..maxVal.." for aura \""..auraName.."\"."
						table.insert(AM_ERRORS[auraName], errMsg)
						self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)
					end
				end

			end
		end
	end
	
	-- add aura type specific fields
	local auraTypeId = auraData.aType
	local defaultsSpecific = AuraMastery.defaults.auraDataSpecific[auraTypeId]
	for fieldName, fieldDefaults in pairs(defaultsSpecific) do
		local defaultValue = fieldDefaults['default']
		
		-- check for all required fields
		if nil == auraData[fieldName] then
			errMsg = "Missing field: \""..fieldName.."\" for aura \""..auraName.."\"."
			table.insert(AM_ERRORS[auraName], errMsg)
deb(errMsg, 500)
self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)
		else
			
			-- check for proper type
			local fieldType = type(auraData[fieldName])
			if fieldType ~= fieldDefaults['type'] then
				errMsg = "Wrong data type for field "..fieldName.."\": "..tostring(fieldDefaults['type']).."\" expected, got \""..tostring(fieldType).."\" for aura \""..auraName.."\"."
				table.insert(AM_ERRORS[auraName], errMsg)
				deb(errMsg, 500)
				self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)	
			else
				
				-- check for allowed values
				if fieldDefaults['allowedValues'] then
					local allowed = false
					for i=1,#fieldDefaults['allowedValues'] do
						if (auraData[fieldName] == fieldDefaults['allowedValues'][i]) then
							allowed = true
							break
						end
					end
					if not(allowed) then
						errMsg = "Invalid field value detected: \""..fieldName.." = "..auraData[fieldName].."\" for aura \""..auraName.."\"."
						table.insert(AM_ERRORS[auraName], errMsg)
deb(errMsg, 500)
						self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)	
					end
				end

				-- check for allowed value range
				if (fieldDefaults['allowedValueRange']) then
					local minVal = fieldDefaults['allowedValueRange']['min']
					local maxVal = fieldDefaults['allowedValueRange']['max']
					if "number" == fieldType and (auraData[fieldName] < minVal or auraData[fieldName] > maxVal) then
						errMsg = "Field value ("..fieldDefaults..") out of allowed value range: "..minVal.." to "..maxVal.." for aura \""..auraName.."\"."
						table.insert(AM_ERRORS[auraName], errMsg)
deb(errMsg, 500)
						self:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)
					end
				end

			end
		end
	end	
	
	-- remove illegal fields
	local allowed = AuraMastery.defaults.auraDataAllowed[auraTypeId]
	for fieldName, _ in pairs(auraData) do
		if not defaultsShared[fieldName] and not defaultsSpecific[fieldName] and not allowed[fieldName] then
			errMsg = "Illegal field: \""..fieldName.."\" for aura \""..auraName.."\"."
			table.insert(AM_ERRORS[auraName], errMsg)
deb(errMsg, 500)
			self:RemoveIllegalFieldFromAuraSVar(auraName, fieldName)		
		end
	end
	
	-- check triggers
	self:ValidateAuraTriggersData(auraName)
	
	-- check loading conditions
	self:ValidateAuraLoadingConditionsData(auraName)
end

function AuraMastery:ValidateAuraTriggersData(auraName)
	AM_ERRORS[auraName]['triggers'] = {}
	local triggers = AuraMastery.svars.auraData[auraName].triggers
	for i=1,#triggers do
		AM_ERRORS[auraName]['triggers'][i] = {}
		local errMsg
		local triggerData = AuraMastery.svars.auraData[auraName].triggers[i]
		local triggerType = triggers[i].triggerType
		
		if nil == triggerType then
			errMsg = "Missing field: \"triggerType\" for aura \""..auraName.."\"."
			table.insert(AM_ERRORS[auraName], errMsg)
			self:SetDefaultValueForAuraTriggerSVar(auraName, i, "triggerType", 1)		
		end
		
		local defaults = AuraMastery.defaults.triggersData[triggerType]
		
		-- check trigger data
		for fieldName, fieldDefaults in pairs(defaults) do
			local defaultValue = fieldDefaults['default']
		
			-- check for all required fields
			if nil == triggerData[fieldName] then
				errMsg = "Missing field: \""..fieldName.."\" for aura \""..auraName.."\"."
				table.insert(AM_ERRORS[auraName]['triggers'][i], errMsg)
				self:SetDefaultValueForAuraTriggerSVar(auraName, i, fieldName, defaultValue)
			else
				
				-- check for proper types
				local fieldType = type(triggerData[fieldName])
				if fieldType ~= fieldDefaults['type'] then
					errMsg = "Wrong data type for field "..fieldName.."\": "..tostring(fieldDefaults['type']).."\" expected, got \""..tostring(fieldType).."\" ("..auraName..")."
					table.insert(AM_ERRORS[auraName]['triggers'][i], errMsg)
					self:SetDefaultValueForAuraTriggerSVar(auraName, i, fieldName, defaultValue)	
				else
					
					-- check for allowed values
					if fieldDefaults['allowedValues'] then
						local allowed = false
						for i=1,#fieldDefaults['allowedValues'] do
							if (triggerData[fieldName] == fieldDefaults['allowedValues'][i]) then
								allowed = true
								break
							end
						end
						if not(allowed) then
							errMsg = "Invalid field value detected: \""..fieldName.." = "..triggerData[fieldName].."\" for aura \""..auraName.."\"."
							table.insert(AM_ERRORS[auraName]['triggers'][i], errMsg)
							self:SetDefaultValueForAuraTriggerSVar(auraName, i, fieldName, defaultValue)	
						end
					end

					-- check for allowed value range
					if (fieldDefaults['allowedValueRange']) then
						local minVal = fieldDefaults['allowedValueRange']['min']
						local maxVal = fieldDefaults['allowedValueRange']['max']
						if "number" == fieldType and (triggerData[fieldName] < minVal or triggerData[fieldName] > maxVal) then
							errMsg = "Field value ("..fieldDefaults..") out of allowed value range: "..minVal.." to "..maxVal.." for aura \""..auraName.."\"."
							table.insert(AM_ERRORS[auraName]['triggers'][i], errMsg)
							self:SetDefaultValueForAuraTriggerSVar(auraName, i, fieldName, defaultValue)
						end
					end
				end
			end
		end		
	end
end

function AuraMastery:ValidateAuraLoadingConditionsData(auraName)
	AM_ERRORS[auraName]['loadingConditions'] = {}

	local defaults = AuraMastery.defaults.loadingConditions
	if not AuraMastery.svars.auraData[auraName].loadingConditions then
		AuraMastery.svars.auraData[auraName].loadingConditions = {}	
	end
	
	local auraData = AuraMastery.svars.auraData[auraName].loadingConditions
	
	for fieldName, fieldDefaults in pairs(defaults) do
		-- check for all required fields
		if nil == auraData[fieldName] then
			errMsg = "Missing field: \""..fieldName.."\" for aura \""..auraName.."\"."
			table.insert(AM_ERRORS[auraName]['loadingConditions'], errMsg)
			self:SetDefaultValueForAuraLoadingConditionSVar(auraName, fieldName)
		else

			-- check for proper types
			local fieldType = type(auraData[fieldName])
			if fieldType ~= fieldDefaults['type'] then
				errMsg = "Wrong data type for field "..fieldName.."\": "..tostring(fieldDefaults['type']).."\" expected, got \""..tostring(fieldType).."\" for aura \""..auraName.."\"."
				table.insert(AM_ERRORS[auraName]['loadingConditions'], errMsg)
				self:SetDefaultValueForAuraLoadingConditionSVar(auraName, fieldName)	
			else

				-- check for allowed values
				if fieldDefaults['allowedValues'] then
					local allowed = false
					for i=1,#fieldDefaults['allowedValues'] do
						if (auraData[fieldName] == fieldDefaults['allowedValues'][i]) then
							allowed = true
							break
						end
					end
					if not(allowed) then
						errMsg = "Invalid field value detected: \""..fieldName.." = "..auraData[fieldName].."\" for aura \""..auraName.."\"."
						table.insert(AM_ERRORS[auraName], errMsg)
						self:SetDefaultValueForAuraLoadingConditionSVar(auraName, fieldName)	
					end
				end

				-- check for allowed value range
				if (fieldDefaults['allowedValueRange']) then
					local minVal = fieldDefaults['allowedValueRange']['min']
					local maxVal = fieldDefaults['allowedValueRange']['max']
					if "number" == fieldType and (auraData[fieldName] < minVal or auraData[fieldName] > maxVal) then
						errMsg = "Field value ("..fieldDefaults..") out of allowed value range: "..minVal.." to "..maxVal.." for aura \""..auraName.."\"."
						table.insert(AM_ERRORS[auraName], errMsg)
						self:SetDefaultValueForAuraLoadingConditionSVar(auraName, fieldName)
					end
				end

			end
		end
	end
end

function AuraMastery:SetDefaultValueForAuraSVar(auraName, fieldName, defaultValue)
	AuraMastery.svars.auraData[auraName][fieldName] = defaultValue
end

function AuraMastery:RemoveIllegalFieldFromAuraSVar(auraName, fieldName)
	AuraMastery.svars.auraData[auraName][fieldName] = nil
end

function AuraMastery:SetDefaultValueForAuraTriggerSVar(auraName, triggerIndex, fieldName, defaultValue)
	AuraMastery.svars.auraData[auraName].triggers[triggerIndex][fieldName] = defaultValue
end

function AuraMastery:SetDefaultValueForAuraLoadingConditionSVar(auraName, fieldName)
	AuraMastery.svars.auraData[auraName].loadingConditions[fieldName] = AuraMastery.defaults.loadingConditions[fieldName]['default']
end

local function slashHandler(userInput)
	local parsedUserInput = {string.match(userInput,"^(%S*)%s*(.-)$")}
	local command = {}
	local n = #parsedUserInput
	for i=1, n do
		if (parsedUserInput[i] ~= nil and parsedUserInput[i] ~= "") then
			command[i] = string.lower(parsedUserInput[i])
		end
	end

	if ("unlock" == command[1]) then
		for k, v in pairs(AuraMastery.aura) do
			--local label = v.control:GetNamedChild("_Label")
			--if label then label:SetText("") end
			local icon = v.control:GetNamedChild("_Icon")
			if icon then icon:SetColor(0,1,0,.5); end
			AuraMastery:UnloadAura(k)
			v.control:SetHidden(false)
			v.control:SetMouseEnabled(true)
			v.control:SetMovable(true)
		end
		d("Auras unlocked.")
		return
	end
	
	if ("lock" == command[1]) then
		for k, v in pairs(AuraMastery.aura) do
			local icon = v.control:GetNamedChild("_Icon")
			if icon then icon:SetColor(1,1,1); end
			AuraMastery:LoadAura(k)
			v.control:SetHidden(true)
			v.control:SetMouseEnabled(false)
			v.control:SetMovable(false)
		end
		d("Auras locked.")
		return
	end

	if "track" == command[1] then
		if 0 == AM_Debugger.state then
			AM_Debugger:Enable()
		else
			AM_Debugger:Disable()
		end
		return
	end
	
	if "abilities" == command[1] then
		if 0 == AM_Debugger.state then d("AuraMastery: Please enable the tracker module first by typing '/am track' into the chat."); return end
		if not AM_Debugger.abilityTrace then
			AM_Debugger.abilityTrace = true
			d("AuraMastery: Information on abilities used by the player will now be displayed in the chat window.")
		else
			AM_Debugger.abilityTrace = false
			d("AuraMastery: Information on abilities used by the player will not be displayed in the chat window anymore.")
		end
		return
	end
	
	if "combat" == command[1] then
		if 0 == AM_Debugger.state then d("AuraMastery: Please enable the tracker module first by typing '/am track' into the chat."); return end
		if not AM_Debugger.combatTrace then
			AM_Debugger.combatTrace = true
			d("AuraMastery: Combat event information will now be displayed in the chat window.")
		else
			AM_Debugger.combatTrace = false
			d("AuraMastery: Combat event information will not be displayed in the chat window anymore.")
		end
		return	
	end
	
	if "effects" == command[1] then
		if 0 == AM_Debugger.state then d("AuraMastery: Please enable the tracker module first by typing '/am track' into the chat."); return end
		if not AM_Debugger.effectTrace then
			AM_Debugger.effectTrace = true
			d("AuraMastery: Effects information will now be displayed in the chat window.")
		else
			AM_Debugger.effectTrace = false
			d("AuraMastery: Effects information will not be displayed in the chat window anymore.")
		end
		return	
	end
	
	-- no parameters passed -> load main menu
	AuraMastery:LoadMainMenu()
end
SLASH_COMMANDS["/am"] = slashHandler
EVENT_MANAGER:RegisterForEvent(AuraMastery.name, EVENT_ADD_ON_LOADED, AuraMastery.OnAddOnLoaded)

SLASH_COMMANDS["/printabilities"] = function()
    for i = 3, 8 do  -- Iterate through action slots
        local abilityId = GetSlotBoundId(i)
        local abilityName = GetSlotName(i)
        d("Slot " .. i .. ": " .. abilityName .. " - ID: " .. abilityId)
    end
	end

	-- function AuraMastery.OnActionSlotUpdated(eventCode, slotId)
	-- 	d("Action slot " .. slotId .. " was updated.")
	-- 	local activeBar = GetActiveWeaponPairInfo()
	-- 	if (1 == slotId or 2 == slotId or not AuraMastery.actionBarData[activeBar]) then return; end	-- 1 = light attack, 2 = heavy attack
	-- 	local oldAbilityId = AuraMastery.actionBarData[activeBar][slotId]
	-- 	local newAbilityId = GetSlotBoundId(slotId)
	-- 	d("Action slot " .. slotId .. " was updated. Old ID: " .. (oldAbilityId or "nil") .. " New ID: " .. (newAbilityId or "nil"))
	-- 	AuraMastery:UpdateActionBarSetup(slotId, newAbilityId)
	-- 	for auraName, auraData in pairs(AuraMastery.svars.auraData) do
	-- 		if auraData.loaded then 
	-- 			local shouldLoad = AuraMastery:CheckLoadingCondition(loadingConditionType, loadingConditionData)  
	--       AuraMastery:UpdateAuraLoadingState(auraName, shouldLoad)
	-- 			-- AuraMastery:UpdateAuraLoadingState(auraName)
	-- 		end
	-- 	end
	-- end
	
	-- function AuraMastery.OnActionSlotUpdated(eventCode, slotId)
	--     d("Action slot " .. slotId .. " was updated.")
	
	--     local activeBar = GetActiveWeaponPairInfo()
	
	--     if (1 == slotId or 2 == slotId or not AuraMastery.actionBarData[activeBar]) then return; end
	
	--     local oldAbilityId = AuraMastery.actionBarData[activeBar][slotId]
			
	--     -- Reset the ability ID for the slot being updated
	--     AuraMastery.actionBarData[activeBar][slotId] = nil
	
	--     local newAbilityId = GetSlotBoundId(slotId)
			
	--     -- Assign the new ability ID to the slot
	--     AuraMastery.actionBarData[activeBar][slotId] = newAbilityId
	
	--     d("Action slot " .. slotId .. " was updated. Old ID: " .. (oldAbilityId or "nil") .. " New ID: " .. (newAbilityId or "nil"))
	
	--     AuraMastery:UpdateActionBarSetup(slotId, newAbilityId)
	--     for auraName, auraData in pairs(AuraMastery.svars.auraData) do
	--         if auraData.loaded then 
	--             local shouldLoad = AuraMastery:CheckLoadingCondition(loadingConditionType, loadingConditionData)
	--             AuraMastery:UpdateAuraLoadingState(auraName, shouldLoad)
	--         end
	--     end
	-- end