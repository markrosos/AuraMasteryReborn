AM_Debugger = {}
AM_Debugger.state = 0
AM_Debugger.effectTrace = false
AM_Debugger.combatTrace = false
AM_Debugger.abilityTrace = false
AM_Debugger.dump = {
	[EVENT_EFFECT_CHANGED] = {},
	[EVENT_COMBAT_EVENT] = {},
	[EVENT_ACTION_SLOT_ABILITY_USED] = {},
}

function AM_Debugger:Enable()
	EVENT_MANAGER:RegisterForEvent("AM_Debugger_"..EVENT_EFFECT_CHANGED, EVENT_EFFECT_CHANGED, AM_Debugger.OnEffectEvent)
	EVENT_MANAGER:RegisterForEvent("AM_Debugger_"..EVENT_ACTION_SLOT_ABILITY_USED, EVENT_ACTION_SLOT_ABILITY_USED, AM_Debugger.OnActionSlotAbilityUsed)
	EVENT_MANAGER:RegisterForEvent("AM_Debugger_"..EVENT_COMBAT_EVENT, EVENT_COMBAT_EVENT, AM_Debugger.OnCombatEvent)
	--EVENT_MANAGER:AddFilterForEvent("AM_Debugger_"..EVENT_COMBAT_EVENT, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_NONE)
	--EVENT_MANAGER:AddFilterForEvent("AM_Debugger_"..EVENT_COMBAT_EVENT, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
	AM_Debugger.state = 1
	d("AuraMastery: Tracking Module enabled.")
end

function AM_Debugger:Disable()
	AM_Debugger.state = 0
	AM_Debugger.effectTrace = false
	AM_Debugger.combatTrace = false
	AM_Debugger.abilityTrace = false
	EVENT_MANAGER:UnregisterForEvent("AM_Debugger_"..EVENT_EFFECT_CHANGED, EVENT_EFFECT_CHANGED)
	EVENT_MANAGER:UnregisterForEvent("AM_Debugger_"..EVENT_ACTION_SLOT_ABILITY_USED)
	EVENT_MANAGER:UnregisterForEvent("AM_Debugger_"..EVENT_COMBAT_EVENT, EVENT_COMBAT_EVENT)
	d("AuraMastery: Tracking Module disabled.")
end

function AM_Debugger.OnEffectEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType)	
	if AM_Debugger.effectTrace then
		local abilityIdToName=GetAbilityName(abilityId)
		local curTime = GetGameTimeMilliSeconds()

		d("<------#"..GetGameTimeMilliSeconds().."#------>")
		d("01) eventCode: "..eventCode)
		d("02) changeType: "..changeType)
		d("03) effectSlot: "..effectSlot)
		d("04) effectName: "..effectName)
		d("05) unitTag: "..unitTag)	-- taget unit tag, not source unit tag
		d("06) beginTime: "..beginTime)
		d("07) endTime: "..endTime)
		d("08) stackCount: "..stackCount)
		d("09) iconName: "..iconName)
		d("10) buffType: "..buffType)
		d("11) effectType: "..effectType)
		d("12) abilityType: "..abilityType)
		d("13) statusEffectType: "..statusEffectType)
		d("14) unitName: "..unitName)	-- target name, not source name
		d("15) unitId: "..unitId)
		d("16) abilityId: "..abilityId)
		d("17) combatUnitType: "..combatUnitType)	-- only source information available, for further specifications EVENT_COMBAT_EVENT must be used
		d("<----------------------------->")

		local sourceIndexName = "Unknown"
		local eventDump = AM_Debugger.dump[eventCode]
		if not eventDump[sourceIndexName] then AM_Debugger.dump[eventCode][sourceIndexName] = {}; end
		if not eventDump[sourceIndexName][abilityIdToName] then AM_Debugger.dump[eventCode][sourceIndexName][abilityIdToName] = {}; end
		if not eventDump[sourceIndexName][abilityIdToName][changeType] then AM_Debugger.dump[eventCode][sourceIndexName][abilityIdToName][changeType] = {}; end
		local eventData = {
			['time'] = curTime,
			['effectSlot'] = effectSlot,
			['effectName'] = effectName,
			['unitTag']    = unitTag,
			['beginTime']  = beginTime,
			['endTime']  = endTime,
			['stackCount']  = stackCount,
			['buffType']  = buffType,
			['effectType']  = effectType,
			['abilityType']  = abilityType,
			['statusEffectType']  = statusEffectType,
			['unitName']  = unitName,
			['unitId']  = unitId,
			['abilityId']  = abilityId,
			['combatUnitType']  = combatUnitType,
		}
		table.insert(AM_Debugger.dump[eventCode][sourceIndexName][abilityIdToName][changeType], eventData)
	end
end

function AM_Debugger.OnReticleTargetChanged(eventCode)
--[[
	AuraMastery:ClearROAuras()
	if not(DoesUnitExist("reticleover")) or IsUnitDead("reticleover") then return; end
	local numEffects = GetNumBuffs("reticleover")
	for i=1, numEffects do
		local source
		local auraName, startTime, endTime, effectSlot, _, _, _, _, _, _, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo('reticleover', i)
		if nil == AuraMastery.ROActiveEffects[abilityId] then AuraMastery.ROActiveEffects[abilityId] = {}; end
		if castByPlayer then source = 1; end	
		AuraMastery:ROEffectGained(abilityId, endTime, effectSlot, stackCount, source)
	end
]]
end

function AM_Debugger.OnActionSlotAbilityUsed(eventCode, slotId)
	if AM_Debugger.abilityTrace then
		local abilityId = GetSlotBoundId(slotId)
		local curTime = GetGameTimeMilliSeconds()
		local abilityName = GetAbilityName(abilityId)
		d("<------#"..curTime.."#------>")
		d("01) eventCode: "..eventCode)
		d("02) slotId: "..slotId)
		d("03) abilityId: "..abilityId)
		d("04) abilityName: "..abilityName)
		d("<----------------------------->")
		local eventDump = AM_Debugger.dump[eventCode]
		if not eventDump[abilityName] then AM_Debugger.dump[eventCode][abilityName] = {}; end
		local eventData = {
			['timestamp'] = curTime,
			['slotId'] = slotId,
			['abilityId'] = abilityId,
		}
		table.insert(AM_Debugger.dump[eventCode][abilityName], eventData)
	end
	if AM_Debugger.gcdTrace then
		local abilityId = GetSlotBoundId(slotId)
		local cooldown = GetSlotCooldownInfo(slotId)
		d(cooldown)
	end
end

function AM_Debugger.OnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
	if AM_Debugger.combatTrace then
		local abilityIdToName=GetAbilityName(abilityId)
		local curTime = GetGameTimeMilliSeconds()
		local sourceNameIndex

		d("<------#"..curTime.."#------>")
		d("01) eventCode: "..eventCode)
		d("02) result: "..result)
		d("03) isError: "..tostring(isError))
		d("04) abilityName: "..abilityName)
		d("05) abilityGraphic: "..abilityGraphic)
		d("06) abilityActionSlotType: "..abilityActionSlotType)
		d("07) sourceName: "..sourceName)
		d("08) sourceType: "..sourceType)
		d("09) targetName: "..targetName)
		d("10) targetType: "..targetType)
		d("11) hitValue: "..hitValue)
		d("12) powerType: "..powerType)
		d("13) damageType: "..damageType)
		d("14) combatEventLog: "..tostring(combatEventLog))
		d("15) sourceUnitId: "..sourceUnitId)	-- unreliable, since being ported to another maparea because of specific fight mechanics might reset unitIds
		d("16) targetUnitId: "..targetUnitId)	-- ^same here
		d("17) abilityId: "..abilityId.."("..abilityIdToName..")")
		d("<----------------------------->")

		local eventDump = AM_Debugger.dump[eventCode]
		if not sourceName or "" == sourceName then sourceIndexName = "Unknown" else sourceIndexName = sourceName; end
		if not eventDump[sourceIndexName] then AM_Debugger.dump[eventCode][sourceIndexName] = {}; end
		if not eventDump[sourceIndexName][abilityIdToName] then AM_Debugger.dump[eventCode][sourceIndexName][abilityIdToName] = {}; end
		if not eventDump[sourceIndexName][abilityIdToName][result] then AM_Debugger.dump[eventCode][sourceIndexName][abilityIdToName][result] = {}; end
		local eventData = {
			['time'] = curTime,
			['isError'] = isError,
			['abilityId'] = abilityId,
			['abilityName'] = abilityName,
			['abilityGraphic'] = abilityGraphic,
			['actionSlotType'] = abilityActionSlotType,
			['sourceName'] = sourceName,
			['sourceType'] = sourceType,
			['targetName'] = targetName,
			['targetType'] = targetType,
			['hitValue'] = hitValue,
			['powerType'] = powerType,
			['damageType'] = damageType,
			['combatEventLog'] = combatEventLog,
			['sourceUnitId'] = sourceUnitId,
			['targetUnitId'] = targetUnitId
		}
		table.insert(AM_Debugger.dump[eventCode][sourceIndexName][abilityIdToName][result], eventData)
	end
end

function AM_Debugger.DumpSkills()
    AM_Debugger.skillsDump = {}
    for skillType = 1, GetNumSkillTypes() do
        for line = 1, GetNumSkillLines(skillType) do
            local linename = GetSkillLineInfo(skillType, line)
            d(" ")
            df("=[ %s ]=", linename)
            for skill = 1, GetNumSkillAbilities(skillType, line) do
                local name, _, _, passive, ultimate, _, progressionIndex, rankIndex = GetSkillAbilityInfo(skillType, line, skill)
                atype = (ultimate and " (u)") or ""
                if not passive then 
                    for morph = 0, 2 do
                        local id = GetSpecificSkillAbilityInfo(skillType, line, skill, morph)
                        df("(%d) %s%s - %s - %s", id, GetAbilityName(id), atype, tostring(progressionIndex), tostring(rankIndex))
                        table.insert(AM_Debugger.skillsDump, {linename,id,GetAbilityName(id)})
                    end
                end
            end
        end    
    end
end
-- /script AM_Debugger:Enable()
-- /zgoo AM_Debugger.dump
-- /script AM_Debugger.DumpSkills()
-- /zgoo AM_Debugger.skillsDump