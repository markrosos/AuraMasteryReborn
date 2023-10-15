local WM = WINDOW_MANAGER

AuraMastery.AuraObj = {}
AuraMastery.Icon = {}
AuraMastery.ProgressBar = {}
AuraMastery.Texture	= {}
AuraMastery.Text = {}

AuraObj = AuraMastery.AuraObj
Icon = AuraMastery.Icon
ProgressBar = AuraMastery.ProgressBar
Texture	= AuraMastery.Texture
Text = AuraMastery.Text

-- BASE AURA OBJECT											 (... = eventData)
function AuraObj:CheckCustomTriggerConditionMet(triggerIndex, ...)
	local auraName = self:GetAuraName()
	local conditionMet
	local customTriggerData = AuraMastery.svars.auraData[auraName].triggers[triggerIndex].customTriggerData
	local eventCode = select(1, ...)
	local tEventType = AuraMastery.G['eventTypesByIndex'][customTriggerData.eventType]
	
	if EVENT_EFFECT_CHANGED == eventCode then
		if tEventType ~= eventCode then return; end
		--eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType							

		-- event variables
		local eChangeType = select(2, ...)
		local eEffectSlot = select(3, ...)
		local eEffectName = select(4, ...)
		local eUnitTag = select(5, ...)
		local eBeginTime = select(6, ...)
		local eEndTime = select(7, ...)
		local eStackCount = select(8, ...)
		local eIconName = select(9, ...)
		local eBuffType = select(10, ...)
		local eEffectType = select(11, ...)
		local eAbilityType = select(12, ...)
		local eStatusEffectType = select(13, ...)
		local eUnitName = select(14, ...)
		local eUnitId = select(15, ...)
		local eAbilityId = select(16, ...)
		local eSourceType = select(17, ...)

		-- trigger variables
		local tChangeType = customTriggerData.changeType
		local tEffectSlot = customTriggerData.effectSlot
		local tEffectName = customTriggerData.effectName
		local tUnitTag = 1 == customTriggerData.unitTag and "player" or 2 == customTriggerData.unitTag and "reticleover"
		local tBeginTime = customTriggerData.beginTime
		local tEndTime = customTriggerData.endTime
		local tStackCount = customTriggerData.stackCount
		local tIconName = customTriggerData.iconName
		local tBuffType = customTriggerData.buffType
		local tEffectType = customTriggerData.effectType
		local tAbilityType = customTriggerData.abilityType
		local tStatusEffectType = customTriggerData.statusEffectType
		local tUnitName = customTriggerData.unitName
		local tUnitId = customTriggerData.unitId
		local tAbilityId = customTriggerData.abilityId
		local tSourceType = customTriggerData.sourceType

		if AuraMastery.debug then
			if tChangeType and tChangeType ~= eChangeType then
				deb("Trigger: tChangeType not matching")		
			end
			if tEffectSlot and tEffectSlot ~= eEffectSlot then
				deb("Trigger: tEffectSlot not matching")		
			end
			if tEffectName and tEffectName ~= eEffectName then
				deb("Trigger: tEffectName not matching")		
			end
			if tUnitTag and tUnitTag ~= eUnitTag then
				deb("Trigger: tUnitTag not matching")		
			end
			if tBeginTime and tBeginTime ~= eBeginTime then
				deb("Trigger: tBeginTime not matching")		
			end
			if tEndTime and tEndTime ~= eEndTime then
				deb("Trigger: tEndTime not matching")		
			end
			if tStackCount and tStackCount ~= eStackCount then
				deb("Trigger: tStackCount not matching")		
			end
			if tIconName and tIconName ~= eIconName then
				deb("Trigger: tIconName not matching")		
			end
			if tBuffType and tBuffType then
				deb("Trigger: tBuffType not matching")		
			end
			if tEffectType and tEffectType ~= eEffectType then
				deb("Trigger: tEffectType not matching")		
			end
			if tAbilityType and tAbilityType ~=eAbilityType then
				deb("Trigger: tAbilityType not matching")		
			end
			if tStatusEffectType and tStatusEffectType ~=eStatusEffectType then
				deb("Trigger: tStatusEffectType not matching")		
			end
			if tUnitName and tUnitName ~=eUnitName then
				deb("Trigger: tUnitName not matching")		
			end
			if tUnitId and tUnitId ~= eUnitId then
				deb("Trigger: tUnitId not matching")		
			end
			if tAbilityId and tAbilityId ~= eAbilityId then
				deb("Trigger: tAbilityId not matching")		
			end
			if tSourceType and tSourceType ~= eSourceType then
				deb("Trigger: tSourceType not matching")
			end
		end
		
		if tChangeType and tChangeType ~= eChangeType
		or tEffectSlot and tEffectSlot ~= eEffectSlot
		or tEffectName and tEffectName ~= eEffectName
		or tUnitTag and tUnitTag ~= eUnitTag
		or tBeginTime and tBeginTime ~= eBeginTime
		or tEndTime and tEndTime ~= eEndTime
		or tStackCount and tStackCount ~= eStackCount
		or tIconName and tIconName ~= eIconName
		or tBuffType and tBuffType
		or tEffectType and tEffectType ~= eEffectType
		or tAbilityType and tAbilityType ~=eAbilityType
		or tStatusEffectType and tStatusEffectType ~=eStatusEffectType
		or tUnitName and tUnitName ~=eUnitName
		or tUnitId and tUnitId ~= eUnitId
		or tAbilityId and tAbilityId ~= eAbilityId
		or tSourceType and tSourceType ~= eSourceType then
			return false
		else
			return true
		end
	elseif EVENT_COMBAT_EVENT == eventCode then
		if tEventType ~= eventCode then return; end
		-- eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId

		-- event variables
		local eResult = select(2, ...)
		local eIsError = select(3, ...)
		local eAbilityName = select(4, ...)
		local eAbilityGraphic = select(5, ...)
		local eAbilityActionSlotType = select(6, ...)
		local eSourceName = select(7, ...)
		local eSourceType = select(8, ...)
		local eTargetName = select(9, ...)
		local eTargetType = select(10, ...)
		local eHitValue = select(11, ...)
		local ePowerType = select(12, ...)
		local eDamageType = select(13, ...)
		local eCombatEventLog = select(14, ...)
		local eSourceUnitId = select(15, ...)
		local eTargetUnitId = select(16, ...)
		local eAbilityId = select(17, ...)

		-- trigger variables
		local tResults = customTriggerData.actionResults
		local tIsError = customTriggerData.isError
		local tAbilityName = customTriggerData.abilityName
		local tAbilityGraphic = customTriggerData.abilityGraphic
		local tAbilityActionSlotType = customTriggerData.abilityActionSlotType
		local tSourceName = "" ~= customTriggerData.sourceName and customTriggerData.sourceName or nil
		local tSourceType = customTriggerData.sourceType
		local tTargetName = "" ~= customTriggerData.targetName and customTriggerData.targetName or nil
		local tTargetType = customTriggerData.targetType
		local tHitValue = customTriggerData.hitValue
		local tPowerType = customTriggerData.powerType
		local tDamageType = customTriggerData.damageType
		local tCombatEventLog = customTriggerData.combatEventLog
		local tSourceUnitId = customTriggerData.sourceUnitId
		local tTargetUnitId = customTriggerData.targetUnitId
		local tAbilityId = customTriggerData.abilityId

		if AuraMastery.debug then
			if tResults and not table.contains(tResults, eResult) then
				deb("Untrigger: tResult not matching")		
			end
			if tIsError and tIsError ~= eIsError then
				deb("Trigger: tIsError not matching")		
			end
			if tAbilityName and tAbilityName ~= eAbilityName then
				deb("Untrigger: tAbilityName not matching")		
			end
			if tAbilityGraphic and tAbilityGraphic ~= eAbilityGraphic then
				deb("Untrigger: tAbilityGraphic not matching")		
			end
			if tAbilityActionSlotType and tAbilityActionSlotType ~= eAbilityActionSlotType then
				deb("Untrigger: tAbilityActionSlotType not matching")		
			end
			if tSourceName and tSourceName ~= eSourceName then
				deb("Untrigger: tSourceName not matching")		
			end
			if tSourceType and tSourceType ~= eSourceType then
				deb("Untrigger: tSourceType not matching")		
			end
			if tTargetName and tTargetName ~= eTargetName then
				deb("Untrigger: tTargetName not matching")		
			end
			if tTargetType and tTargetType ~= eTargetType then
				deb("Untrigger: tTargetType not matching")		
			end
			if tHitValue and tHitValue ~= eHitValue then
				deb("Untrigger: tHitValue not matching")		
			end
			if tPowerType and tPowerType ~= ePowerType then
				deb("Untrigger: tPowerType not matching")		
			end
			if tDamageType and tDamageType ~= eDamageType then
				deb("Untrigger: tDamageType not matching")		
			end
			if tCombatEventLog and tCombatEventLog ~= eCombatEventLog then
				deb("Untrigger: tCombatEventLog not matching")		
			end
			if tSourceUnitId and tSourceUnitId ~= eSourceUnitId then
				deb("Untrigger: tSourceUnitId not matching")		
			end
			if tTargetUnitId and tTargetUnitId ~= eTargetUnitId then
				deb("Untrigger: tTargetUnitId not matching")		
			end
			if tAbilityId and tAbilityId ~= eAbilityId then
				deb("Untrigger: tAbilityId not matching")		
			end
		end

		if tResults and not table.contains(tResults, eResult)
		or tIsError and tIsError ~= eIsError
		or tAbilityName and tAbilityName ~= eAbilityName
		or tAbilityGraphic and tAbilityGraphic ~= eAbilityGraphic
		or tAbilityActionSlotType and tAbilityActionSlotType ~= eAbilityActionSlotType
		or tSourceName and tSourceName ~= eSourceName
		or tSourceType and tSourceType ~= eSourceType
		or tTargetName and tTargetName ~= eTargetName
		or tTargetType and tTargetType ~= eTargetType
		or tHitValue and tHitValue ~= eHitValue
		or tPowerType and tPowerType ~=ePowerType
		or tDamageType and tDamageType ~=eDamageType
		or tCombatEventLog and tCombatEventLog ~=eCombatEventLog
		or tSourceUnitId and tSourceUnitId ~= eSourceUnitId
		or tTargetUnitId and tTargetUnitId ~= eTargetUnitId
		or tAbilityId and tAbilityId ~= eAbilityId then
			return false
		else
			return true
		end
		
	elseif EVENT_ACTION_SLOT_ABILITY_USED == eventCode then
		if tEventType ~= eventCode then return; end		
		
		local slotId = select(2, ...)
		local eAbilityId = GetSlotBoundId(slotId)
		local tAbilityId = customTriggerData.abilityId
		
		if tAbilityId and tAbilityId ~= eAbilityId then
			return false
		else
			return true
		end
	end

end

function AuraObj:CheckCustomUntriggerConditionMet(triggerIndex, ...)
	local auraName = self:GetAuraName()
	local conditionMet
	local customUntriggerData = AuraMastery.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData
	local eventCode = select(1, ...)
	local tEventType = AuraMastery.G['eventTypesByIndex'][customUntriggerData.eventType]
	
	if EVENT_EFFECT_CHANGED == eventCode then
		--eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType							
		if tEventType ~= eventCode then return; end

		-- event variables
		local eChangeType = select(2, ...)
		local eEffectSlot = select(3, ...)
		local eEffectName = select(4, ...)
		local eUnitTag = select(5, ...)
		local eBeginTime = select(6, ...)
		local eEndTime = select(7, ...)
		local eStackCount = select(8, ...)
		local eIconName = select(9, ...)
		local eBuffType = select(10, ...)
		local eEffectType = select(11, ...)
		local eAbilityType = select(12, ...)
		local eStatusEffectType = select(13, ...)
		local eUnitName = select(14, ...)
		local eUnitId = select(15, ...)
		local eAbilityId = select(16, ...)
		local eSourceType = select(17, ...)

		-- trigger variables
		local tChangeType = customUntriggerData.changeType
		local tEffectSlot = customUntriggerData.effectSlot
		local tEffectName = customUntriggerData.effectName
		local tUnitTag = 1 == customUntriggerData.unitTag and "player" or 2 == customUntriggerData.unitTag and "reticleover"
		local tBeginTime = customUntriggerData.beginTime
		local tEndTime = customUntriggerData.endTime
		local tStackCount = customUntriggerData.stackCount
		local tIconName = customUntriggerData.iconName
		local tBuffType = customUntriggerData.buffType
		local tEffectType = customUntriggerData.effectType
		local tAbilityType = customUntriggerData.abilityType
		local tStatusEffectType = customUntriggerData.statusEffectType
		local tUnitName = customUntriggerData.unitName
		local tUnitId = customUntriggerData.unitId
		local tAbilityId = customUntriggerData.abilityId
		local tSourceType = customUntriggerData.sourceType

		if AuraMastery.debug then
			if tChangeType and tChangeType ~= eChangeType then
				deb("Untrigger: tChangeType not matching")		
			end
			if tEffectSlot and tEffectSlot ~= eEffectSlot then
				deb("Untrigger: tEffectSlot not matching")		
			end
			if tEffectName and tEffectName ~= eEffectName then
				deb("Untrigger: tEffectName not matching")		
			end
			if tUnitTag and tUnitTag ~= eUnitTag then
				deb("Untrigger: tUnitTag not matching")		
			end
			if tBeginTime and tBeginTime ~= eBeginTime then
				deb("Untrigger: tBeginTime not matching")		
			end
			if tEndTime and tEndTime ~= eEndTime then
				deb("Untrigger: tEndTime not matching")		
			end
			if tStackCount and tStackCount ~= eStackCount then
				deb("Untrigger: tStackCount not matching")		
			end
			if tIconName and tIconName ~= eIconName then
				deb("Untrigger: tIconName not matching")		
			end
			if tBuffType and tBuffType then
				deb("Untrigger: tBuffType not matching")		
			end
			if tEffectType and tEffectType ~= eEffectType then
				deb("Untrigger: tEffectType not matching")		
			end
			if tAbilityType and tAbilityType ~=eAbilityType then
				deb("Untrigger: tAbilityType not matching")		
			end
			if tStatusEffectType and tStatusEffectType ~=eStatusEffectType then
				deb("Untrigger: tStatusEffectType not matching")		
			end
			if tUnitName and tUnitName ~=eUnitName then
				deb("Untrigger: tUnitName not matching")		
			end
			if tUnitId and tUnitId ~= eUnitId then
				deb("Untrigger: tUnitId not matching")		
			end
			if tAbilityId and tAbilityId ~= eAbilityId then
				deb("Untrigger: tAbilityId not matching")		
			end
			if tSourceType and tSourceType ~= eSourceType then
				deb("Untrigger: tSourceType not matching")
			end
		end
		
		if tChangeType and tChangeType ~= eChangeType
		or tEffectSlot and tEffectSlot ~= eEffectSlot
		or tEffectName and tEffectName ~= eEffectName
		or tUnitTag and tUnitTag ~= eUnitTag
		or tBeginTime and tBeginTime ~= eBeginTime
		or tEndTime and tEndTime ~= eEndTime
		or tStackCount and tStackCount ~= eStackCount
		or tIconName and tIconName ~= eIconName
		or tBuffType and tBuffType
		or tEffectType and tEffectType ~= eEffectType
		or tAbilityType and tAbilityType ~=eAbilityType
		or tStatusEffectType and tStatusEffectType ~=eStatusEffectType
		or tUnitName and tUnitName ~=eUnitName
		or tUnitId and tUnitId ~= eUnitId
		or tAbilityId and tAbilityId ~= eAbilityId
		or tSourceType and tSourceType ~= eSourceType then
			return false
		else
			return true
		end
		
	elseif EVENT_COMBAT_EVENT == eventCode then
		if tEventType ~= eventCode then return; end
		-- eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId

		-- event variables
		local eResult = select(2, ...)
		local eIsError = select(3, ...)
		local eAbilityName = select(4, ...)
		local eAbilityGraphic = select(5, ...)
		local eAbilityActionSlotType = select(6, ...)
		local eSourceName = select(7, ...)
		local eSourceType = select(8, ...)
		local eTargetName = select(9, ...)
		local eTargetType = select(10, ...)
		local eHitValue = select(11, ...)
		local ePowerType = select(12, ...)
		local eDamageType = select(13, ...)
		local eCombatEventLog = select(14, ...)
		local eSourceUnitId = select(15, ...)
		local eTargetUnitId = select(16, ...)
		local eAbilityId = select(17, ...)

		-- trigger variables
		local tResults = customUntriggerData.actionResults
		local tIsError = customUntriggerData.isError
		local tAbilityName = customUntriggerData.abilityName
		local tAbilityGraphic = customUntriggerData.abilityGraphic
		local tAbilityActionSlotType = customUntriggerData.abilityActionSlotType
		local tSourceName = "" ~= customUntriggerData.sourceName and customUntriggerData.sourceName or nil
		local tSourceType = customUntriggerData.sourceType
		local tTargetName = "" ~= customUntriggerData.targetName and customUntriggerData.targetName or nil
		local tTargetType = customUntriggerData.targetType
		local tHitValue = customUntriggerData.hitValue
		local tPowerType = customUntriggerData.powerType
		local tDamageType = customUntriggerData.damageType
		local tCombatEventLog = customUntriggerData.combatEventLog
		local tSourceUnitId = customUntriggerData.sourceUnitId
		local tTargetUnitId = customUntriggerData.targetUnitId
		local tAbilityId = customUntriggerData.abilityId

		if AuraMastery.debug then
			if tResults and not table.contains(tResults, eResult) then
				deb("Untrigger: tResult not matching")		
			end
			if tIsError and tIsError ~= eIsError then
				deb("Trigger: tIsError not matching")		
			end
			if tAbilityName and tAbilityName ~= eAbilityName then
				deb("Untrigger: tAbilityName not matching")		
			end
			if tAbilityGraphic and tAbilityGraphic ~= eAbilityGraphic then
				deb("Untrigger: tAbilityGraphic not matching")		
			end
			if tAbilityActionSlotType and tAbilityActionSlotType ~= eAbilityActionSlotType then
				deb("Untrigger: tAbilityActionSlotType not matching")		
			end
			if tSourceName and tSourceName ~= eSourceName then
				deb("Untrigger: tSourceName not matching")		
			end
			if tSourceType and tSourceType ~= eSourceType then
				deb("Untrigger: tSourceType not matching")		
			end
			if tTargetName and tTargetName ~= eTargetName then
				deb("Untrigger: tTargetName not matching")		
			end
			if tTargetType and tTargetType ~= eTargetType then
				deb("Untrigger: tTargetType not matching")		
			end
			if tHitValue and tHitValue ~= eHitValue then
				deb("Untrigger: tHitValue not matching")		
			end
			if tPowerType and tPowerType ~= ePowerType then
				deb("Untrigger: tPowerType not matching")		
			end
			if tDamageType and tDamageType ~= eDamageType then
				deb("Untrigger: tDamageType not matching")		
			end
			if tCombatEventLog and tCombatEventLog ~= eCombatEventLog then
				deb("Untrigger: tCombatEventLog not matching")		
			end
			if tSourceUnitId and tSourceUnitId ~= eSourceUnitId then
				deb("Untrigger: tSourceUnitId not matching")		
			end
			if tTargetUnitId and tTargetUnitId ~= eTargetUnitId then
				deb("Untrigger: tTargetUnitId not matching")		
			end
			if tAbilityId and tAbilityId ~= eAbilityId then
				deb("Untrigger: tAbilityId not matching")		
			end
		end

		if tResults and not table.contains(tResults, eResult)
		or tIsError and tIsError ~= eIsError
		or tAbilityName and tAbilityName ~= eAbilityName
		or tAbilityGraphic and tAbilityGraphic ~= eAbilityGraphic
		or tAbilityActionSlotType and tAbilityActionSlotType ~= eAbilityActionSlotType
		or tSourceName and tSourceName ~= eSourceName
		or tSourceType and tSourceType ~= eSourceType
		or tTargetName and tTargetName ~= eTargetName
		or tTargetType and tTargetType ~= eTargetType
		or tHitValue and tHitValue ~= eHitValue
		or tPowerType and tPowerType ~=ePowerType
		or tDamageType and tDamageType ~=eDamageType
		or tCombatEventLog and tCombatEventLog ~=eCombatEventLog
		or tSourceUnitId and tSourceUnitId ~= eSourceUnitId
		or tTargetUnitId and tTargetUnitId ~= eTargetUnitId
		or tAbilityId and tAbilityId ~= eAbilityId then
			return false
		else
			return true
		end
		
	elseif EVENT_ACTION_SLOT_ABILITY_USED == eventCode then
		-- eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId
		if tEventType ~= eventCode then return; end
--		deb("Untrigger: ACTION_SLOT_EVENT")	

		local slotId = select(2, ...)
		local eAbilityId = GetSlotBoundId(slotId)
		local tAbilityId = customUntriggerData.abilityId
		
		if tAbilityId and tAbilityId ~= eAbilityId then
			return false
		else
			return true
		end
	end
end

function AuraObj:CheckTriggersBaseconditionsMet()
	local auraName = self:GetAuraName()
	local earliestEndTime
	local latestBeginTime
	local conditionMet
	local triggers = AuraMastery.svars.auraData[auraName].triggers
	local useAdvancedDurationTracking = false
	
	for triggerIndex, triggerData in ipairs(triggers) do
		--
		-- durationInfo has been modified by the user (custom startTime, custom endTime)
		-- for at least one (that's why checking false == useAdvancedDurationTracking) trigger condition
		-- ATTENTION: Fake effects (triggerType==2) always need to use ADT as there are no events for fading ground effects
		-- and hence using an update function is the only way to determine if a ground effect is still active
		--
		if not triggerData.invert and 3 ~= triggerData.triggerType and ((0 ~= triggerData.value and false == useAdvancedDurationTracking) or 2 == triggerData.triggerType) then
			useAdvancedDurationTracking = true
		end
		conditionMet, endTime, eventData = self:CheckTriggerConditionMet(triggerData, auraName, triggerIndex)
--deb("baseConditionMet for: "..auraName..": "..tostring(conditionMet))
		if false == conditionMet then
			self:UnregisterAuraForUpdate()
			self:DeleteEventInfo(triggerIndex)
			return false
		end
	
		if useAdvancedDurationTracking then	
			if nil ~= endTime then		
				-- this calculates the real endTime, which takes timing conditions (e.g. 'display only until buffDuration > 5 seconds') into consideration 
				local realEndTime = self:CalcTriggerEndTime(endTime, triggerData)	
				if (nil == earliestEndTime or realEndTime < earliestEndTime) then
					earliestEndTime = realEndTime
				end
				local realBeginTime = self:CalcTriggerBeginTime(endTime, triggerData)				
				if (nil == latestBeginTime or realBeginTime > latestBeginTime) then
					latestBeginTime = realBeginTime
				end		
			end
		else
			if nil ~= endTime then
				if (nil == earliestEndTime or endTime < earliestEndTime) then
					earliestEndTime = endTime
				end				
			end
		end
		
		-- save effect data to aura object (for eventual text parsing)
		self:SaveEventInfo(triggerIndex, eventData)
	end
	
	if nil ~= earliestEndTime then
		self.data.durationInfo['endTime'] = earliestEndTime
	end
	
	--
	-- This is the aura flicker protection: When using a smaller than condition to prevent an aura from displaying OnEvent,
	-- this functionality ensures, that 
	--
	if useAdvancedDurationTracking then
		self:RegisterAuraForUpdate(auraName, latestBeginTime, earliestEndTime)
		local curTime = AuraMastery.curTime
		local updateSpeed = AuraMastery.savedVariables.updateSpeed
		-- this makes sure that the system only applies, if the user specified a real smaller than duration and that it does not trigger by function execution time
		if latestBeginTime-curTime >  updateSpeed/1000 then
			-- this is neccessary to prevent the aura from being triggered for a fraction of a second and then being untriggered by the update-handler when using a "smaller than" condition
			if curTime < latestBeginTime then
				return false;
			end
		end
		
	end
	return true
end

function AuraObj:GetTriggerState(triggerIndex)
	return self.data.triggerStates[triggerIndex]
end

function AuraObj:SetCustomTriggerState(triggerIndex, triggerState)
	--if not self.data.triggerStates then self.data.triggerStates = {}; end	
	self.data.triggerStates[triggerIndex] = triggerState
--	deb("Activation state for trigger number "..tostring(triggerIndex).." is now "..tostring(triggerState))
end

function AuraObj:CheckTriggerConditionMet(triggerData, auraName, triggerIndex)
	if nil == triggerData then d("FATAL ERROR: No trigger data!"); return; end

	local auraDataSource, effectData
	local effectId = triggerData.spellId
	local checkAll = triggerData.checkAll
	local triggerTimeLeft = 0	-- 0 = nothing active, -1 = always active (e. g. status triggers), >0 = active
	local effectIndex
	local eventData
	local selfCast = triggerData['selfCast']
	local conditionMet = false	-- bool is this trigger's condition met?
	local endTime
	local invertedCheck = triggerData.invert
--deb(triggerData.triggerType)
	--======================================
	-- buff/debuff -------------------------
	--======================================
	if (1 == triggerData.triggerType) then
--deb("checking... buff/debuff")
		-- depending on a trigger's unitTag, the addon will check the activeEffects-table (effects on the player)
		-- or the reticleactiveeffects-table (effects on reticleover, only if valid target!)
		auraDataSource = (1 == triggerData['unitTag'] and AuraMastery.activeEffects) or (2 == triggerData['unitTag'] and AuraMastery.ROActiveEffects)
		-- check all ability IDs for the ability's name, that has been specified by the provided 
		-- ability ID (WARNING: does not work if ZOS has not properly localized the ability name!)
		if checkAll then
			effectId, effectIndex, endTime = AuraMastery:CheckAll(effectId, auraDataSource, selfCast)	-- if checkAll is active, check for other ranks and instances of the ability
		elseif nil ~= auraDataSource[effectId] then
			effectIndex, endTime = AuraMastery:GetLongestDurationData(effectId, auraDataSource, selfCast)
		end
		effectData = auraDataSource[effectId]
		
		if nil ~= effectData and nil ~= effectData[effectIndex] then
			eventData = effectData[effectIndex]
			conditionMet = true
		end
	end

	--======================================
	-- fake effect -------------------------
	--======================================
	if (2 == triggerData.triggerType) then
--deb("checking... fake effect")
		if AuraMastery.trackedEvents[EVENT_ACTION_SLOT_ABILITY_USED]['custom'][effectId] and AuraMastery.trackedEvents[EVENT_ACTION_SLOT_ABILITY_USED]['custom'][effectId][auraName] then
			auraDataSource = AuraMastery.activeCustomDurations[EVENT_ACTION_SLOT_ABILITY_USED][auraName]
		else
			auraDataSource = AuraMastery.activeFakeEffects
		end																						-- v as there is only one fake effect active at the same time (fake effects cannot be triggered by other players), 
		effectData = auraDataSource[effectId]	
		-- 										   no need to dynamically pass an effectIndex, as it will always be the first entry - 
		--										   there can only be one fake effect of a given ability id active at the same time, as only the player himself can trigger it
		--										   V
		if nil ~= effectData and nil ~= effectData[1] then
			endTime = effectData[1]['endTime']
			eventData = effectData[1]
			conditionMet = true
		end				
	end

	--=====================================
	-- custom trigger ---------------------
	--=====================================
	if (3 == triggerData.triggerType) then
--deb("checking... custom")
--deb(triggerIndex)
		conditionMet = self:GetTriggerState(triggerIndex)
--deb(conditionMet)

	end

	--======================================
	-- combat event ------------------------
	--======================================
	if (4 == triggerData.triggerType) then
--deb("checking... combat")
		local triggerCasterName = triggerData['casterName']
		local triggerTargetName = triggerData['targetName']
		local triggerUnitTag    = triggerData['combatUnitTag']
		
		-- If the player has specified a duration, use it instead of the ability duration
		if AuraMastery.trackedEvents[EVENT_COMBAT_EVENT]['custom'][effectId] and AuraMastery.trackedEvents[EVENT_COMBAT_EVENT]['custom'][effectId][auraName] then
			auraDataSource = AuraMastery.activeCustomDurations[EVENT_COMBAT_EVENT][auraName]
		else
			auraDataSource = AuraMastery.activeCombatEffects
		end
	
		-- check for all ability ids
		if checkAll then
			effectId, effectIndex, endTime = AuraMastery:CheckAll(effectId, auraDataSource, false, triggerCasterName, triggerTargetName)
		elseif nil ~= auraDataSource[effectId] then
			effectIndex, endTime = AuraMastery:GetLongestDurationData(effectId, auraDataSource, false, triggerCasterName, triggerTargetName)
		end

		-- Important: CheckAll() must be run before this point

		effectData = auraDataSource[effectId]

		if nil ~= effectData and nil ~= effectData[effectIndex] then
			eventData = effectData[effectIndex]
			conditionMet = true
		end
	end
	if (true == triggerData['invert']) then conditionMet = not(conditionMet); end

	return conditionMet, endTime, eventData
end

function AuraObj:SaveEventInfo(triggerIndex, eventData)
	--local triggerEventInfo = self.data.eventInfo[triggerIndex]
	--if not triggerEventInfo then		not really sure what this was good for, problem is it prevents stack counts being reset if an ability like assassins will is fired and stacks are reset to 0
	self.data.eventInfo[triggerIndex] = eventData
	--end
end

function AuraObj:DeleteEventInfo(triggerIndex)
	self.data.eventInfo[triggerIndex] = nil
end

--
-- This function registers an aura to be checked onUpdate: Neccessary to check for trigger conditions that use modified trigger/untrigger times, like "buff < 5s" or "buff > 3s"
--
function AuraObj:RegisterAuraForUpdate(auraName, triggerTime, untriggerTime)
	local auraDurationData = AuraMastery.auraDurations[auraName]
	if nil == auraDurationData then
		AuraMastery.auraDurations[auraName] = {}
	end
	if nil ~= untriggerTime then
		AuraMastery.auraDurations[auraName]['endTime'] = untriggerTime
	end
	if nil ~= triggerTime then
		AuraMastery.auraDurations[auraName]['beginTime'] = triggerTime
	end
end

function AuraObj:UnregisterAuraForUpdate()
	local auraName = self:GetAuraName()
	AuraMastery.auraDurations[auraName] = nil
end

function AuraObj:CalcTriggerBeginTime(endTime, triggerData)
	local operator = triggerData.operator
	local cTime = GetGameTimeMilliSeconds()
	local value = triggerData.value
	local realBeginTime
	-- #################################################################################################
	-- ## operator > value bedeutet, dass die Laufzeit um 'value' sekunden früher beendet werden muss  #
	-- ## operator < value bedeutet, dass die Laufzeit um 'value' sekunden später begonnen werden muss #
	-- #################################################################################################
	-- hier wird die Endzeit berechnet, also ist nur der '>'- bzw. der '>='-Operator von Bedeutung
	if 1 == operator then		-- '<'
		realBeginTime = endTime-value
	elseif 3 == operator then	-- '<='
		realBeginTime = endTime-value-1
	else
		realBeginTime = cTime
	end
	
	return realBeginTime	
end

function AuraObj:CalcTriggerEndTime(endTime, triggerData)
	local operator = triggerData.operator
	local value    = triggerData.value
	local realEndTime

	-- #################################################################################################
	-- ## operator > value bedeutet, dass die Laufzeit um 'value' sekunden früher beendet werden muss  #
	-- ## operator < value bedeutet, dass die Laufzeit um 'value' sekunden später begonnen werden muss #
	-- #################################################################################################
	-- hier wird die Endzeit berechnet, also ist nur der '>'- bzw. der '>='-Operator von Bedeutung
	if 2 == operator then		-- '>'
		realEndTime = endTime-value
	elseif 4 == operator then	-- '>='
		realEndTime = endTime-value-1
	else
		realEndTime = endTime
	end
	
	return realEndTime
end

function AuraObj:GetEffectLongestDuration(abilityId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)
	local effectIndex
	local endTime = -1
	local n = #dataSource[abilityId]
	for i=1, n do
		local selfCastCondition = true
		local sourceCondition = true
		local targetCondition = true

		local data = dataSource[abilityId][i]

		if triggerCasterName and data['sourceName'] ~= triggerCasterName then
			sourceCondition = false
		end
		if triggerTargetName and data['targetName'] ~= triggerTargetName then
			targetCondition = false
		end
		if selfCastOnly then	
			if COMBAT_UNIT_TYPE_PLAYER ~= data['source'] then	-- Attention: `selfCastOnly` is only applied for buff/debuff auras => `data` will contain 'source' field; 'sourceName' is only for combat events
				selfCastCondition = false
			end
		end

		if selfCastCondition and sourceCondition and targetCondition and data['endTime'] > endTime then
			effectIndex 	  = i
			endTime     	  = data['endTime']
		end
	end
	return effectIndex, endTime
end

function AuraObj:CheckAll(abilityId, auraDataSource, selfCastOnly, sourceName, targetName)
	local matchingEffectId, effectIndex
	local endTime = -1
	local abilityName = GetAbilityName(abilityId)
	local abilityIds = self.abilityIds[abilityName]

	for i=1,#abilityIds do
		local abilityId = abilityIds[i]
		if (auraDataSource[abilityId]) then
			local n = #auraDataSource[abilityId]
			for i=1, n do
				local selfCastCondition = true
				local sourceCondition = true
				local targetCondition = true

				local data = auraDataSource[abilityId][i]

				if sourceName and data['sourceName'] ~= sourceName then
					sourceCondition = false
				end
				if targetName and data['targetName'] ~= targetName then
					targetCondition = false
				end
				if selfCastOnly then	
					if COMBAT_UNIT_TYPE_PLAYER ~= data['source'] then	-- Attention: `selfCastOnly` is only applied for buff/debuff auras => `data` will contain 'source' field; 'sourceName' is only for combat events
						selfCastCondition = false
					end
				end
				if selfCastCondition and sourceCondition and targetCondition and data['endTime'] > endTime then
					matchingEffectId = abilityId
					effectIndex 	  = i
					endTime     	  = data['endTime']
				end				
			end
		end
	end
	return matchingEffectId, effectIndex, endTime
end

function AuraObj:GetAuraName()
	return self.auraName
end

function AuraObj:GetData()
	local auraName = self:GetAuraName()
	return AuraMastery.svars.auraData[auraName]
end

function AuraObj:GetControl()
	return self.control
end

function AuraObj:SetAuraName(auraName)
	self.auraName = auraName
end

function AuraObj:SetAuraState(state)
	self.triggerState = state
end

function AuraObj:GetAuraState()
	return self.triggerState
end

function AuraObj:SetDurationText()
	local curTime = AuraMastery.curTime
	local endTime = self.data.durationInfo.cdEndTime

	if nil ~= endTime then
		local auraName = self:GetAuraName()
		
		-- text auras have different labels for cooldown display
		if 4 ~= AuraMastery.svars.auraData[auraName].aType then
			local remaining = endTime-curTime
			local cooldownFontColor = AuraMastery.svars.auraData[auraName].cooldownFontColor	
			local criticalTime = AuraMastery.svars.auraData[auraName].critical
			if (remaining <= criticalTime) then 		
				self.control.label:SetColor(1,0,0,1);
			else
				self.control.label:SetColor(cooldownFontColor.r, cooldownFontColor.g, cooldownFontColor.b);
			end
			local text = (0 < remaining) and AuraMastery.FormatTime(remaining, criticalTime) or ""
			self.control.label:SetText(text)
		else
			-- text aura
			
		end
	end
end

function AuraObj:AttachEvent(eventCode, abilityId, triggerIndex, triggerType)
--deb(eventCode.." - "..abilityId.." - "..triggerIndex.." - "..triggerType, 500)

	local attachedEvents = self.data.attachedEvents[eventCode]
	if not attachedEvents then	-- no event of that type is registered
		self.data.attachedEvents[eventCode] = {}
		attachedEvents = self.data.attachedEvents[eventCode]
	end
	if not attachedEvents[abilityId] then -- there is an event of that type registered, but it doesn't contain the ability id
		self.data.attachedEvents[eventCode][abilityId] = {
			['triggerType'] = triggerType,
			['triggerIndex'] = triggerIndex
		}
	end
end

function AuraObj:SetCustomTriggerFlag(eventCode, abilityId)
	self.data.attachedEvents[eventCode][abilityId]['isCustomTrigger'] = true
end

function AuraObj:DetachEvent(eventCode, abilityId)
	local attachedEvents = self.data.attachedEvents[eventCode]
	if attachedEvents and attachedEvents[abilityId] then
		self.data.attachedEvents[eventCode][abilityId] = nil
		
		--[[local abilityIdNumTriggers = attachedEvents[abilityId]
		self.data.attachedEvents[eventCode][abilityId] = abilityIdNumTriggers-1
		if 0 == self.data.attachedEvents[eventCode][abilityId] then
			self.data.attachedEvents[eventCode][abilityId] = nil
			if 0 == #self.data.attachedEvents[eventCode] then
				self.data.attachedEvents[eventCode] = nil
			end
		end
		]]
	end
end

function AuraObj:Untrigger()
--deb("Untriggered..."..self:GetAuraName())
	local control = self.control
	local cooldown = self.control.cd
	control:SetHidden(true)
	self:SetAuraState(0)
	self.data.preParsedAuraText = nil
	if cooldown then cooldown:SetHidden(true); end
end

function AuraObj:EnterEditMode()

	local auraControl = self:GetControl()
	local auraData = self:GetData()
	--
	-- If the aura is configured to show a cooldown, display it with a placeholder
	--
	if auraData.showCooldownText then
		local cdLabel = auraControl:GetNamedChild("_CooldownLabel")
		if cdLabel then
			cdLabel:SetText("??")
		end
	end
	
	--
	-- If the aura has text, display it
	--
	local auraText = auraData.text
	if auraText then
		self.control:GetNamedChild("_TextLabel"):SetText(auraText)
	end
	
	--
	-- Set the aura to it's configured visibility
	--
	local alpha = auraData.alpha
	local coordsX = auraControl:GetLeft()
	local coordsY = auraControl:GetTop()
	auraControl:SetAlpha(alpha)

	--
	-- Configure the draging anchor control and make it visible
	--
	local function OnDragingControl()
		local control = WM:GetControlByName("AM_GenericAnchor")
		local controlX = control:GetLeft()
		local controlY = control:GetTop()
		local labelCoords = control:GetNamedChild("_LabelCoords")
		labelCoords:SetText(controlX..","..controlY)
	end	
	local genericAnchorControl = WM:GetControlByName("AM_GenericAnchor")
	genericAnchorControl:ClearAnchors()
	genericAnchorControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, coordsX, coordsY)
	genericAnchorControl:SetMouseEnabled(true)
	genericAnchorControl:SetMovable(true)
	genericAnchorControl:SetHidden(false)
	EVENT_MANAGER:RegisterForUpdate("DragUpdater", 100, OnDragingControl)	-- coordinates updater

	--
	-- Attach the draging anchor control to the selected aura
	--		
	auraControl:SetAnchor(TOPLEFT, genericAnchorControl, TOPLEFT)
	
	--
	-- If the aura is not set to be hidden during the menu scene, show it
	--
	local isHidden = auraControl:IsHidden()
	if not isHidden then
		auraControl:SetHidden(false)
	end
end

function AuraObj:LeaveEditMode()
	local auraControl = self:GetControl()
	local auraData = self:GetData()
	local genericAnchorControl = WM:GetControlByName("AM_GenericAnchor")
	local offsetX = auraControl:GetLeft()
	local offsetY = auraControl:GetTop()
	local alpha = auraData.alpha

	--
	-- If the aura is configured to show a cooldown, display it by a placeholder
	--
	if auraData['showCooldownText'] then
		local cdLabel = auraControl:GetNamedChild("_CooldownLabel")
		if cdLabel then
			cdLabel:SetText("")
		end
	end
	
	--
	-- Detach the draging anchor control from the aura control
	--
	genericAnchorControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT)
	genericAnchorControl:SetMouseEnabled(false)
	genericAnchorControl:SetMovable(false)
	genericAnchorControl:SetHidden(true)
	
	--
	-- Hide the aura control and reapply it's configured alpha
	--
	auraControl:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, offsetX, offsetY)
	auraControl:SetAlpha(0.25)	-- LeaveEditMode() is only called when the edit aura menu is open. As soon as it's opened, all auras are set to alpha = 0.35.
end

function AuraObj:ParseAuraText()
	local auraName = self:GetAuraName()
	local auraText = AuraMastery.svars.auraData[auraName].text
	local textInfoTriggerIndex = AuraMastery.svars.auraData[auraName].textInfoSource

	if auraText and textInfoTriggerIndex then
		local eventInfo = self.data.eventInfo[textInfoTriggerIndex]
		if eventInfo then
			local eventType = AuraMastery.svars.auraData[auraName].triggers[textInfoTriggerIndex].triggerType

			-- EVENT_EFFECT_CHANGED
			if 1 == eventType then
				local stacks = eventInfo['stacks']
				auraText = string.gsub(auraText, "{s}", stacks)
				
			-- EVENT_COMBAT_EVENT
			elseif 4 == eventType then
				local sourceName = eventInfo['sourceName']
				local targetName = eventInfo['targetName']		
				auraText = string.gsub(auraText, "{sn}", sourceName)
				auraText = string.gsub(auraText, "{tn}", targetName)
			end	
			
			--
			-- self.data.preParsedAuraText is always browsed onUpdate - if the updater finds anything, it will parse and set it
			--
			if string.find(auraText, "{d}") then
				self.data.preParsedAuraText = {preParsedString = auraText, endTime = eventInfo['endTime']}
			end
		end
	end
	if not auraText then auraText = ""; end
	self:SetAuraText(auraText)	
end

function AuraObj:ParseAuraTextTimeData()
	local auraText = self.data.preParsedAuraText.preParsedString
	local endTime = self.data.preParsedAuraText.endTime
	local remain = endTime-GetGameTimeSeconds()
	remain = (0 < remain) and AuraMastery.FormatTime(remain, 3) or ""
	auraText = string.gsub(auraText, "{d}", remain)
	self:SetAuraText(auraText)
end

function AuraObj:SetAuraText(auraText)
	local textLabel = self.control.textLabel
	textLabel:SetText(auraText)
end

function AuraObj:IsAuraTextRegisteredForUpdate()
	return self.data.preParsedAuraText
end

-- ICON inherits BASE AURA OBJECT
function Icon:New(auraName)
	local icon = ZO_Object:MultiSubclass(AuraObj, Icon)
	local triggers = AuraMastery.svars.auraData[auraName].triggers	
	
	-- Base Control
	local baseControl = WM:GetControlByName(auraName)
	icon.control = baseControl or WM:CreateControlFromVirtual(auraName, auraMasteryTLW, "AM_IconAuraControl")
	local iconAnchor = icon.control
	icon.control:SetHandler("OnMoveStop", function() AuraMastery:OnDisplayPosChange(auraName) end)
	icon.control:SetClampedToScreen(true);
	icon.control:SetDimensions(AuraMastery.svars.auraData[auraName]['width'], AuraMastery.svars.auraData[auraName]['height'])
	icon.control:ClearAnchors()
	icon.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AuraMastery.svars.auraData[auraName]['posX'], AuraMastery.svars.auraData[auraName]['posY'])
	icon.control:SetMovable(false)
	icon.control:SetMouseEnabled(false)
	icon.control:SetHidden(true)
	
	-- Background and border
	local backdropControl = WM:GetControlByName(auraName.."_Backdrop")
	if backdropControl then
		backdropControl:SetParent(iconAnchor)
	else
		backdropControl = WM:CreateControl("$(parent)_Backdrop", iconAnchor, CT_BACKDROP)
	end
	icon.control.bg = backdropControl
	icon.control.bg:ClearAnchors()
	icon.control.bg:SetAnchorFill()
	icon.control.bg:SetCenterColor(AuraMastery.svars.auraData[auraName].bgColor['r'], AuraMastery.svars.auraData[auraName].bgColor['g'], AuraMastery.svars.auraData[auraName].bgColor['b'], AuraMastery.svars.auraData[auraName].bgColor['a']);
	icon.control.bg:SetEdgeTexture(nil, 1, 1, AuraMastery.svars.auraData[auraName].borderSize, 0);
	icon.control.bg:SetEdgeColor(AuraMastery.svars.auraData[auraName].borderColor['r'], AuraMastery.svars.auraData[auraName].borderColor['g'], AuraMastery.svars.auraData[auraName].borderColor['b'], AuraMastery.svars.auraData[auraName].borderColor['a']);	
	icon.control.bg:SetDrawLevel(2)

	-- Cooldown
	local cooldownControl = WM:GetControlByName(auraName.."_Cooldown")
	if cooldownControl then
		cooldownControl:SetParent(iconAnchor)
	else
		cooldownControl = WM:CreateControl("$(parent)_Cooldown", iconAnchor, CT_COOLDOWN)
	end
	icon.control.cd = cooldownControl
	icon.control.cd:ClearAnchors()
	icon.control.cd:SetAnchor(TOPLEFT, bgAnchor, TOPLEFT)
	icon.control.cd:SetAnchor(BOTTOMRIGHT, bgAnchor, BOTTOMRIGHT)
	icon.control.cd:SetFillColor(0,0,0,.75)

	-- Label (Cooldown)
	local r,g,b,a = AuraMastery.svars.auraData[auraName].cooldownFontColor.r, AuraMastery.svars.auraData[auraName].cooldownFontColor.g, AuraMastery.svars.auraData[auraName].cooldownFontColor.b, AuraMastery.svars.auraData[auraName].cooldownFontColor.a
	local labelControl = WM:GetControlByName(auraName.."_CooldownLabel")
	if labelControl then
		labelControl:SetParent(iconAnchor)
	else
		labelControl = WM:CreateControl("$(parent)_CooldownLabel", iconAnchor, CT_LABEL)
	end
	icon.control.label = labelControl
	icon.control.label:ClearAnchors()
	icon.control.label:SetAnchor(TOPLEFT, iconAnchor, TOPLEFT, 2,2)
	icon.control.label:SetAnchor(BOTTOMRIGHT, iconAnchor, BOTTOMRIGHT, -2,-2)
	icon.control.label:SetVerticalAlignment(1)
	icon.control.label:SetHorizontalAlignment(1)
	icon.control.label:SetColor(r,g,b,a)
	icon.control.label:SetFont("$(BOLD_FONT)|"..tostring(AuraMastery.svars.auraData[auraName].cooldownFontSize).."|outline")
	icon.control.label:SetText("")
	
	-- Label (Text)
	local r,g,b,a = AuraMastery.svars.auraData[auraName].textFontColor.r, AuraMastery.svars.auraData[auraName].textFontColor.g, AuraMastery.svars.auraData[auraName].textFontColor.b, AuraMastery.svars.auraData[auraName].textFontColor.a
	local textLabelControl = WM:GetControlByName(auraName.."_TextLabel")

	-- use bottom text position as default
	local auraTextPositionId = AuraMastery.svars.auraData[auraName].auraTextPositionId or 7
	local point = AuraMastery.lookup.auraTextAnchorPointsByTextPositionId[auraTextPositionId]['point']
	local relativePoint = AuraMastery.lookup.auraTextAnchorPointsByTextPositionId[auraTextPositionId]['relativePoint']
	
	if textLabelControl then
		textLabelControl:SetParent(iconAnchor)
	else
		textLabelControl = WM:CreateControl("$(parent)_TextLabel", iconAnchor, CT_LABEL)
	end
	icon.control.textLabel = textLabelControl
	icon.control.textLabel:ClearAnchors()
	icon.control.textLabel:SetAnchor(point, iconAnchor, relativePoint, 2,2)
	icon.control.textLabel:SetVerticalAlignment(1)
	icon.control.textLabel:SetHorizontalAlignment(1)
	icon.control.textLabel:SetColor(r,g,b,a)
	icon.control.textLabel:SetFont("$(BOLD_FONT)|"..tostring(AuraMastery.svars.auraData[auraName].textFontSize).."|outline")
	local text = AuraMastery.svars.auraData[auraName].text or ""
	icon.control.textLabel:SetText(labelText)
	
	-- Icon
	local iconControl = WM:GetControlByName(auraName.."_Icon")
	if iconControl then
		iconControl:SetParent(iconAnchor)
	else
		iconControl = WM:CreateControl("$(parent)_Icon", iconAnchor, CT_TEXTURE)
	end
	icon.control.icon = iconControl
	icon.control.icon:ClearAnchors()
	icon.control.icon:SetAnchor(TOPLEFT, iconAnchor, TOPLEFT)
	icon.control.icon:SetAnchor(BOTTOMRIGHT, iconAnchor, BOTTOMRIGHT)
	local texture = AuraMastery.svars.auraData[auraName].iconPath

	if "" == texture then
		if (nil ~= triggers[1]) then
			firstAbilityId =  triggers[1].spellId
			if nil ~= firstAbilityId then
				texture =  GetAbilityIcon(firstAbilityId)
			end
		end
	end
	icon.control.icon:SetTexture(texture)

	icon.auraName		 = auraName
	icon.triggerState	 = 0
	icon.data = {
		['attachedEvents'] = {},
		['durationInfo'] = {},
		['triggerStates'] = {},
		['eventInfo'] = {}
	}
	
	for i=1, #triggers do
		icon.data['triggerStates'][i] = false
	end
	
	-- Handlers
	icon.control:SetHandler("OnShow", AuraMastery.AuraOnShow)
	icon.control:SetHandler("OnHide", AuraMastery.AuraOnHide)

	return icon
end

function Icon:Trigger()

	--
	-- Aura text must be parsed before the aura state check, because inverted text triggers would not display onPlayerActivated otherwise
	--
	self:ParseAuraText()	
	self.control:SetHidden(false)
	
	--
	-- We must first check for the aura state before setting it to 1 (active) because retriggering an aura(cooldown) in case of an effect being refreshed would not be possible otherwise
	--
	if 1 == self:GetAuraState() or nil == self.data.durationInfo['endTime'] then return; end	-- only trigger this if it hasn't been triggered already!
	self:SetAuraState(1)

	local auraName = self.auraName
	local durationInfoSource = AuraMastery.svars.auraData[auraName].durationInfoSource
	local showCooldownAnimation = AuraMastery.svars.auraData[auraName].showCooldownAnimation
	local fillAlpha = 0.75*AuraMastery.svars.auraData[auraName].alpha
	local cTime = AuraMastery.curTime or GetGameTimeMilliSeconds() -- neccessary to circumvent a problem after loading screens (AuraMastery.curTime is not set when called by EVENT_PLAYER_ACTIVATED
	local endTime = self.data.durationInfo['endTime']
	local absolute, remaining
	local text = AuraMastery.svars.auraData[auraName].text
	local dataSource
	local stacks, tName, sName

	--
	-- endTime is always either > 0 or -1 for auras that are infinetely displayed. The value is set by GetLongestDurationData() or CheckAll()
	-- which are both called in CheckTriggerConditionMet().
	--
	if 0 <= endTime then

		if nil ~= durationInfoSource then -- user has specified a trigger (= an ability) to take duration information from
			local triggerData = AuraMastery.svars.auraData[auraName].triggers[durationInfoSource]
			local selfCastOnly = triggerData.selfCast
			local checkAll = triggerData.checkAll
			local triggerCasterName = triggerData.sourceName 
			local triggerTargetName = triggerData.targetName
			local effectIndex
			if 1 == triggerData.triggerType then -- effect duration
				if 1 == triggerData.unitTag then -- effect on player
					dataSource = AuraMastery.activeEffects	
				elseif 2 == triggerData.unitTag then -- effect on reticleover
					dataSource = AuraMastery.ROActiveEffects
				end
			elseif 2 == triggerData.triggerType then -- fake effect
				if	nil ~= triggerData.duration then -- a custom duration has been specified by the user
					dataSource = AuraMastery.activeCustomDurations[EVENT_ACTION_SLOT_ABILITY_USED][auraName] 	 	
				else								
					dataSource = AuraMastery.activeFakeEffects -- no custom duration
				end	
			elseif 4 == triggerData.triggerType then -- combat event
				if	nil ~= triggerData.duration then -- a custom duration has been specified by the user
					dataSource = AuraMastery.activeCustomDurations[EVENT_COMBAT_EVENT][auraName] 	 
				else			
					dataSource = AuraMastery.activeCombatEffects -- no custom duration
				end				
			end
			
			if checkAll then
				abilityId, effectIndex, endTime = AuraMastery:CheckAll(triggerData.spellId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)	-- if checkAll is active, check for other ranks and instances of the ability
			else
				abilityId = triggerData.spellId
				if nil == dataSource[abilityId] then
					return false
				else
					effectIndex, endTime = AuraMastery:GetLongestDurationData(abilityId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)
				end
			end
			if nil ~= dataSource[abilityId] then
				endTime = dataSource[abilityId][effectIndex].endTime
				absolute = nil == triggerData.duration and GetAbilityDuration(abilityId) or triggerData.duration*1000 -- use custom duration if set (e.g. fake effects), otherwise use ability duration
				remaining = (endTime-cTime)*1000
			end
			

			stacks = dataSource[abilityId][effectIndex]['stacks'] or "***"
			tName = "" ~= dataSource[abilityId][effectIndex]['targetName'] and dataSource[abilityId][effectIndex]['targetName'] or "***"
			sName = "" ~= dataSource[abilityId][effectIndex]['sourceName'] and dataSource[abilityId][effectIndex]['sourceName'] or "***"
		else -- user has not specified any duration info => take duration info from remaining aura display time
			absolute = (endTime-cTime)*1000
			remaining = (endTime-cTime)*1000
		end

		self.data.durationInfo.cdEndTime = endTime	-- cdEndTime contains the duration that will be displayed as text on the icon
		-- start cooldown
		if showCooldownAnimation then
			self.control.cd:StartCooldown(remaining, absolute, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
			self.control.cd:SetHidden(false)
		end
	end
end

-- PROGRESSIONBAR inherits BASE AURA OBJECT
function ProgressBar:New(auraName)

-- COPIED CODE --###############################
	local BAR_HEIGHT = 24
	local BAR_HEIGHT_SHRINK = 0
	local FADE_OUT_TIME = 250
	local REFRESHER_LAST_USED = GetAbilityDuration(61500) + 2 * FADE_OUT_TIME
	local USE_FADE = true
-- /COPIED CODE --##############################

	local bar = ZO_Object:MultiSubclass(AuraObj, ProgressBar)
	local triggers = AuraMastery.svars.auraData[auraName].triggers	

	local baseControl = WM:GetControlByName(auraName)
	--bar.control = baseControl or WM:CreateControl(auraName, auraMasteryTLW, CT_CONTROL)
	bar.control = baseControl or WM:CreateControlFromVirtual(auraName, auraMasteryTLW, "AM_ProgressBarAuraControl")
	local control = bar.control
	local colors,r,g,b,a,gr,gg,gb

	bar.timer = ZO_TimerBar:New(bar.control)

-- COPIED CODE --##############################
	bar.timer:SetDirection(TIMER_BAR_COUNTS_DOWN)
	bar.timer:SetFades(USE_FADE, FADE_OUT_TIME)
	bar.frame = frame
	bar.lastTimeUsed = 0
	--bar.control:SetHeight(BAR_HEIGHT_SHRINK)
-- /COPIED CODE --#############################
	
	bar.control:SetDimensions(AuraMastery.svars.auraData[auraName]['width'], AuraMastery.svars.auraData[auraName]['height'])
	bar.control:GetNamedChild("Status"):SetDimensions(AuraMastery.svars.auraData[auraName]['width'], AuraMastery.svars.auraData[auraName]['height'])
	bar.control:ClearAnchors()
	bar.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AuraMastery.svars.auraData[auraName]['posX'], AuraMastery.svars.auraData[auraName]['posY']);
	bar.control:SetMovable(false)
	bar.control:SetMouseEnabled(false)
	bar.control:SetHidden(true)
	bar.control:SetAlpha(AuraMastery.svars.auraData[auraName]['alpha'])
	
	bar.control:SetHandler("OnMoveStop", function() AuraMastery:OnDisplayPosChange(auraName) end);
	bar.control:SetClampedToScreen(true)
	
	-- Background and border
	local backdropControl = WM:GetControlByName(auraName.."_Backdrop")
	if backdropControl then
		backdropControl:SetParent(control)
	else
		backdropControl = WM:CreateControl("$(parent)_Backdrop", control, CT_BACKDROP)
	end
	bar.control.bg = backdropControl
	bar.control.bg:ClearAnchors()
	bar.control.bg:SetAnchorFill()
	colors = AuraMastery.svars.auraData[auraName].bgColor
	r,g,b,a = colors.r,colors.g,colors.b,colors.a
	bar.control.bg:SetCenterColor(r,g,b,a)	-- rgba
	bar.control.bg:SetEdgeTexture(nil, 1, 1, AuraMastery.svars.auraData[auraName].borderSize, 0);
	bar.control.bg:SetEdgeColor(AuraMastery.svars.auraData[auraName].borderColor['r'], AuraMastery.svars.auraData[auraName].borderColor['g'], AuraMastery.svars.auraData[auraName].borderColor['b'], AuraMastery.svars.auraData[auraName].borderColor['a']);	
	bar.control.bg:SetDrawLevel(0)
		
	-- Progression bar
	local barControl = WM:GetControlByName(auraName.."Status")
	bar.control.bar = barControl
	local barOffset = AuraMastery.svars.auraData[auraName]['borderSize']
	
	bar.control.bar:ClearAnchors()
	bar.control.bar:SetAnchor(TOPLEFT, control, TOPLEFT, AuraMastery.svars.auraData[auraName]['height']-2*AuraMastery.svars.auraData[auraName]['borderSize']+barOffset, barOffset)
	bar.control.bar:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, -barOffset, -barOffset)
	colors = AuraMastery.svars.auraData[auraName].barColor
	r,g,b,a = colors.r, colors.g, colors.b, colors.a
	gr,gg,gb = r*0.2, g*0.2, b*0,2
	bar.control.bar:SetColor(r,g,b,a)

	-- Label
	local labelControl = WM:GetControlByName(auraName.."_CooldownLabel")
	if labelControl then
		labelControl:SetParent(control)
	else
		labelControl = WM:CreateControl("$(parent)_CooldownLabel", control, CT_LABEL)
	end
	bar.control.label = labelControl
	local offsetX = (AuraMastery.svars.auraData[auraName]['height']-AuraMastery.svars.auraData[auraName]['cooldownFontSize'])/2
	bar.control.label:ClearAnchors()
	bar.control.label:SetAnchor(RIGHT, control, RIGHT, -offsetX, 0)
	bar.control.label:SetVerticalAlignment(1)
	bar.control.label:SetHorizontalAlignment(1)
	colors = AuraMastery.svars.auraData[auraName].cooldownFontColor
	r,g,b,a = colors.r,colors.g,colors.b,colors.a
	bar.control.label:SetColor(r,g,b,a)
	bar.control.label:SetFont("$(BOLD_FONT)|"..tostring(AuraMastery.svars.auraData[auraName].cooldownFontSize).."|outline")
	bar.control.label:SetText("")
	
	-- Icon
	local iconControl = WM:GetControlByName(auraName.."_Icon")
	if iconControl then
		iconControl:SetParent(control)
	else
		iconControl = WM:CreateControl("$(parent)_Icon", control, CT_TEXTURE)
	end
	bar.control.icon = iconControl
	bar.control.icon:ClearAnchors()
	bar.control.icon:SetAnchor(LEFT, control, LEFT, AuraMastery.svars.auraData[auraName]['borderSize'],0)
	bar.control.icon:SetDimensions(AuraMastery.svars.auraData[auraName]['height']-2*AuraMastery.svars.auraData[auraName]['borderSize'], AuraMastery.svars.auraData[auraName]['height']-2*AuraMastery.svars.auraData[auraName]['borderSize']);
	bar.control.icon:SetTexture(AuraMastery.svars.auraData[auraName].iconPath)
	local texture = AuraMastery.svars.auraData[auraName].iconPath
	if "" == texture then
		if (nil ~= triggers[1]) then
			firstAbilityId =  triggers[1].spellId
			if nil ~= firstAbilityId then
				texture =  GetAbilityIcon(firstAbilityId)
			end
		end
	end
	bar.control.icon:SetTexture(texture)
	bar.control.icon:SetDrawLevel(2)

	-- Data
	bar.auraName		 = auraName
	bar.triggerState	 = 0
	bar.data = {
		['attachedEvents'] = {},
		['durationInfo'] = {},
		['triggerStates'] = {},
		['eventInfo'] = {}
	}
	
	for i=1, #triggers do
		bar.data['triggerStates'][i] = false
	end

	-- Handlers
	bar.control:SetHandler("OnShow", AuraMastery.AuraOnShow)
	bar.control:SetHandler("OnHide", AuraMastery.AuraOnHide)
	
	return bar
end

function ProgressBar:Trigger()
	--
	-- Aura text must be parsed before the aura state check, because inverted text triggers would not display onPlayerActivated otherwise
	--
	self.control:SetHidden(false)
	
	--
	-- We must first check for the aura state before setting it to 1 (active) because retriggering an aura(cooldown) in case of an effect being refreshed would not be possible otherwise
	--
	if 1 == self:GetAuraState() or nil == self.data.durationInfo['endTime'] then return; end	-- only trigger this if it hasn't been triggered already!
	self:SetAuraState(1)

	local control = self.control
	local auraName = self.auraName
	local bar = control.bar
	local alpha = AuraMastery.svars.auraData[auraName].alpha
	local cTime = AuraMastery.curTime
	local height = AuraMastery.svars.auraData[auraName].height-2
	local startWidth = AuraMastery.svars.auraData[auraName].width-height-2
	local durationInfoSource = AuraMastery.svars.auraData[auraName].durationInfoSource
	local endTime = self.data.durationInfo['endTime']
	local timeLeft, triggerData


	--
	-- endTime is always either > 0 or -1 for auras that are infinetely displayed. The value is set by GetLongestDurationData() or CheckAll()
	-- which are both called in CheckTriggerConditionMet().
	--
	if 0 <= endTime then
		if nil ~= durationInfoSource then -- user has specified a trigger (= an ability) to take duration information from
			triggerData = AuraMastery.svars.auraData[auraName].triggers[durationInfoSource]
			local selfCastOnly = triggerData.selfCast
			local checkAll = triggerData.checkAll
			local triggerCasterName = triggerData.sourceName 
			local triggerTargetName = triggerData.targetName
			local dataSource
			
			if 1 == triggerData.triggerType then -- effect duration
				if 1 == triggerData.unitTag then -- effect on player
					dataSource = AuraMastery.activeEffects	
				elseif 2 == triggerData.unitTag then -- effect on reticleover
					dataSource = AuraMastery.ROActiveEffects
				end
			elseif 2 == triggerData.triggerType then -- fake effect
				if	nil ~= triggerData.duration then -- a custom duration has been specified by the user
					dataSource = AuraMastery.activeCustomDurations[EVENT_ACTION_SLOT_ABILITY_USED][auraName] 	 
				else																		
					dataSource = AuraMastery.activeFakeEffects -- no custom duration
				end	
			elseif 4 == triggerData.triggerType then -- combat effect
				if	nil ~= triggerData.duration then -- a custom duration has been specified by the user
					dataSource = AuraMastery.activeCustomDurations[EVENT_COMBAT_EVENT][auraName] 	 
				else																		
					dataSource = AuraMastery.activeCombatEffects -- no custom duration
				end				
			end
			
			if checkAll then
				abilityId, effectIndex, endTime = AuraMastery:CheckAll(triggerData.spellId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)	-- if checkAll is active, check for other ranks and instances of the ability
			else
				abilityId = triggerData.spellId
				if nil == dataSource[abilityId] then
					return false
				else
					effectIndex, endTime = AuraMastery:GetLongestDurationData(abilityId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)
				end
			end

			if nil ~= dataSource[abilityId] then
				endTime = dataSource[abilityId][effectIndex].endTime
			end
		else -- user has not specified any duration info => take duration info from remaining aura display time
			endTime = self.data.durationInfo.endTime
		end
		timeLeft = (endTime-cTime)*1000
		self.data.durationInfo.cdEndTime = endTime	-- cdEndTime contains the duration that will be displayed as text on the icon
	end	
	
	local abilityDuration
	if	triggerData and triggerData.duration then	-- user has specified a custom duration
		abilityDuration = triggerData.duration
	else
		abilityDuration = GetAbilityDuration(abilityId)/1000	
	end
	local timer = self.timer
	--local beginTime = endTime - abilityDuration
	local beginTime = GetGameTimeSeconds()
	if beginTime > 0 then	-- without this ZOS's code will hide controls that display without having a display duration (e. g. 'effect missing' auras)
		timer:Stop()
		timer:Start(beginTime, endTime)
	end

	control:SetAlpha(alpha)	-- this is neccessary as ZO_TimerBar:Stop() will set alpha to 1 after fading out, which will always trigger when the bar has finished playing it's animation 
end

-- TEXT inherits BASE AURA OBJECT
function Text:New(auraName)
	local text = ZO_Object:MultiSubclass(AuraObj, Text)
	local triggers = AuraMastery.svars.auraData[auraName].triggers	
	
	-- Base Control
	local baseControl = WM:GetControlByName(auraName)
	text.control = baseControl or WM:CreateControlFromVirtual(auraName, auraMasteryTLW, "AM_TextAuraControl")
	local textAnchor = text.control

	text.control:SetClampedToScreen(true)
	text.control:ClearAnchors()
	text.control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, AuraMastery.svars.auraData[auraName]['posX'], AuraMastery.svars.auraData[auraName]['posY'])
	text.control:SetAlpha(AuraMastery.svars.auraData[auraName]['alpha']);
	text.control:SetResizeToFitDescendents(true)
	text.control:SetHidden(true)
	
	-- Dynamic Text
	local r,g,b,a = AuraMastery.svars.auraData[auraName].textFontColor.r, AuraMastery.svars.auraData[auraName].textFontColor.g, AuraMastery.svars.auraData[auraName].textFontColor.b, AuraMastery.svars.auraData[auraName].textFontColor.a
	local labelControl = WM:GetControlByName(auraName.."_TextLabel")
	text.control.textLabel = labelControl or WM:CreateControl("$(parent)_TextLabel", textAnchor, CT_LABEL)

	text.control.textLabel:ClearAnchors()
	text.control.textLabel:SetAnchor(TOPLEFT, textAnchor, TOPLEFT, 2,2)
	text.control.textLabel:SetAnchor(BOTTOMRIGHT, textAnchor, BOTTOMRIGHT, -2,-2)


	text.control.textLabel:SetVerticalAlignment(1)
	text.control.textLabel:SetHorizontalAlignment(1)
	text.control.textLabel:SetColor(r,g,b,a)
	text.control.textLabel:SetFont("$(BOLD_FONT)|"..tostring(AuraMastery.svars.auraData[auraName].textFontSize).."|outline")
--	text.control.textLabel:SetText(AuraMastery.svars.auraData[auraName]['text'])
	
	-- Data
	text.auraName		 = auraName
	text.triggerState	 = 0
	text.data = {
		['attachedEvents'] = {},
		['durationInfo'] = {},
		['triggerStates'] = {},
		['eventInfo'] = {}
	}
	
	for i=1, #triggers do
		text.data['triggerStates'][i] = false
	end
	
	-- Handlers
	text.control:SetHandler("OnShow", AuraMastery.AuraOnShow)
	text.control:SetHandler("OnHide", AuraMastery.AuraOnHide)

	return text
end

function Text:Trigger()
	--
	-- Aura text must be parsed before the aura state check, because inverted text triggers would not display onPlayerActivated otherwise
	--
	self:ParseAuraText()	
	self.control:SetHidden(false)
	
	--
	-- We must first check for the aura state before setting it to 1 (active) because retriggering an aura(cooldown) in case of an effect being refreshed would not be possible otherwise
	--
	if 1 == self:GetAuraState() or nil == self.data.durationInfo['endTime'] then return; end	-- only trigger this if it hasn't been triggered already!
	self:SetAuraState(1)
	
	if AuraMastery.debug then deb("Triggered..."..self:GetAuraName()); end
	local auraName = self.auraName
	local durationInfoSource = AuraMastery.svars.auraData[auraName].durationInfoSource
	local cTime = AuraMastery.curTime or GetGameTimeMilliSeconds() -- neccessary to circumvent a problem after loading screens (AuraMastery.curTime is not set when called by EVENT_PLAYER_ACTIVATED
	local endTime = self.data.durationInfo['endTime']
	local absolute, remaining
	local stacks, tName, sName
	
	--
	-- endTime is always either > 0 or -1 for auras that are infinetely displayed. The value is set by GetLongestDurationData() or CheckAll()
	-- which are both called in CheckTriggerConditionMet().
	--
	if 0 <= endTime then
		if nil ~= durationInfoSource then -- user has specified a trigger (= an ability) to take duration information from
			local triggerData = AuraMastery.svars.auraData[auraName].triggers[durationInfoSource]
			local selfCastOnly = triggerData.selfCast
			local checkAll = triggerData.checkAll
			local triggerCasterName = triggerData.sourceName 
			local triggerTargetName = triggerData.targetName
			local dataSource
			
			if 1 == triggerData.triggerType then -- effect duration
				if 1 == triggerData.unitTag then -- effect on player
					dataSource = AuraMastery.activeEffects	
				elseif 2 == triggerData.unitTag then -- effect on reticleover
					dataSource = AuraMastery.ROActiveEffects
				end
			elseif 2 == triggerData.triggerType then -- fake effect
				if	nil ~= triggerData.duration then -- a custom duration has been specified by the user
					dataSource = AuraMastery.activeCustomDurations[EVENT_ACTION_SLOT_ABILITY_USED][auraName] 	 
				else																		
					dataSource = AuraMastery.activeFakeEffects -- no custom duration
				end	
			elseif 4 == triggerData.triggerType then
				if	nil ~= triggerData.duration then -- a custom duration has been specified by the user
					dataSource = AuraMastery.activeCustomDurations[EVENT_COMBAT_EVENT][auraName] 	 
				else																		
					dataSource = AuraMastery.activeCombatEffects -- no custom duration
				end				
			end
			
			if checkAll then
				abilityId, effectIndex, endTime = AuraMastery:CheckAll(triggerData.spellId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)	-- if checkAll is active, check for other ranks and instances of the ability
			else
				abilityId = triggerData.spellId
				if nil == dataSource[abilityId] then
					return false
				else
					effectIndex, endTime = AuraMastery:GetLongestDurationData(abilityId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)
				end
			end

			if nil ~= dataSource[abilityId] then
				endTime = dataSource[abilityId][effectIndex].endTime
				absolute = nil == triggerData.duration and GetAbilityDuration(abilityId) or triggerData.duration*1000 -- use custom duration if set (e.g. fake effects), otherwise use ability duration
				remaining = (endTime-cTime)*1000
			end

			stacks = dataSource[abilityId][effectIndex]['stacks'] or "***"
			tName = "" ~= dataSource[abilityId][effectIndex]['targetName'] and dataSource[abilityId][effectIndex]['targetName'] or "***"
			sName = "" ~= dataSource[abilityId][effectIndex]['sourceName'] and dataSource[abilityId][effectIndex]['sourceName'] or "***"					
		else -- user has not specified any duration info => take duration info from remaining aura display time
			absolute = (endTime-cTime)*1000
			remaining = (endTime-cTime)*1000
		end
		self.data.durationInfo.cdEndTime = endTime	-- cdEndTime contains the duration that will be displayed as text on the icon	
	end
end

-- MultiIcon

-- MultiBar