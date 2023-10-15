local formatCritical = '%.1f';
local formatSeconds  = '%d';
local formatMinutes  = '%dm';
local formatHours	 = '%dh';
local formatDays	 = '%dd';


--++++++++--
-- EVENTS --
--++++++++--
function AuraMastery.OnEffectEvent(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType)
	if (("player" ~= unitTag and "reticleover" ~= unitTag) or "Offline" == unitName) then return; end -- unitTag = source

	-- ability is being tracked
	if (AuraMastery.trackedEvents[EVENT_EFFECT_CHANGED].abilityIds[abilityId]) then

		AuraMastery:UpdateCustomTriggerStates(abilityId, eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, combatUnitType)
		
	
		-- effect gained
		if (1 == changeType) then
			if AuraMastery.debug then deb("Gained: "..effectName.."("..abilityId..") on "..unitName.." ("..unitId..") from "..combatUnitType); end
			AuraMastery:EffectGained(abilityId, endTime, effectSlot, unitTag, unitId, stackCount, combatUnitType)

		-- effect faded
		elseif (2 == changeType) then
			if AuraMastery.debug then deb("Faded: "..abilityId.." - "..unitName.." ("..unitId..")"); end
			AuraMastery:EffectRemoved(abilityId, effectSlot, unitTag, unitId)

		-- effect refreshed
		elseif (3 == changeType) then
			if AuraMastery.debug then deb("Refreshed: "..abilityId.." - "..unitName.." ("..unitId..")"); end
			AuraMastery:EffectRefreshed(abilityId, endTime, effectSlot, unitTag, unitId, stackCount, combatUnitType)
		end
	end
end

function AuraMastery.OnReticleTargetChanged(eventCode)
	if AuraMastery.debug then deb("reticleTargetChanged"); end
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
end

function AuraMastery.OnActionSlotAbilityUsed(eventCode, slotId)
	if 1 == slotId or 2 == slotId then return; end	-- ignore light and heavy attacks (yes, they have a slot ID and trigger this event...)
	local abilityId = GetSlotBoundId(slotId)
	local auraDuration
	local endTime
	local abilityFakeEffects = AuraMastery.trackedEvents[EVENT_ACTION_SLOT_ABILITY_USED]['abilityIds']

	if abilityFakeEffects[abilityId] then

		AuraMastery:UpdateCustomTriggerStates(abilityId, eventCode, slotId)
				
		-- 1. standard fake effects
		for i=1,#abilityFakeEffects[abilityId] do	
			if (abilityFakeEffects[abilityId][i]) then
				local auraName = abilityFakeEffects[abilityId][i]
				for j=1, #AuraMastery.svars.auraData[auraName].triggers do
					local triggerData = AuraMastery.svars.auraData[auraName].triggers[j]
					auraDuration = GetAbilityDuration(abilityId)/1000
				end
				endTime = GetGameTimeMilliSeconds()+auraDuration
			end
		end

		AuraMastery:FakeEffectGained(abilityId, endTime)
		

		
		-- 2. fake effects that have a custom duration specified by the user
		local abilityCustomDuration = AuraMastery.trackedEvents[EVENT_ACTION_SLOT_ABILITY_USED].custom[abilityId]
		if abilityCustomDuration then
--deb("custom duration specified - following auras are affected:")
			local curTime = AuraMastery.curTime
			for auraName, duration in pairs(abilityCustomDuration) do
				local endTime = curTime+duration	-- calculate custom duration and use it as new endTime
--deb(curTime)
--deb(auraName.."("..duration..">endTime="..endTime..")")				
				--
				-- custom duration aura names and ability ids have already been registered at startup (see AuraMastery:RegisterCustomDuration in controls.lua)		
			    -- index will always be = 1 because there can only be one custom duration active for a given abilityId on a given aura at the same time
				-- index must be used though, because trigger checking conditions use a uniformed format for every trigger type and effects/combat events use index values
				-- endTime index must be used for the same reason: GetLongestDurationData() expects it
				AuraMastery.activeCustomDurations[eventCode][auraName][abilityId] = {[1] = {['endTime'] = endTime}}
				AuraMastery:UpdateAffectedAuras(AURAMASTERY_EVENT_CUSTOM_DURATION_CHANGED, abilityId, false, true)
			end
		end
	end
end

function AuraMastery.OnCombatEvent(eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)
	--
	-- Note: `Faded` action results (2250) are used by AuraMastery as TRIGGERING action results, just like `gained` and `duration gained` action results (2240 and 2245). Fading combat events are therefor handled by
	-- a registered updater-function that compares the event effects endTimes against the current game time (see AuraMastery:UpdateCombatEffects() in functions.lua)
	--
	local curTime 	 = GetGameTimeMilliSeconds()
	local sourceName = zo_strformat("<<1>>", sourceName)
	local targetName = zo_strformat("<<1>>", targetName)
	local endTime 	 = curTime+(GetAbilityDuration(abilityId)/1000)

	-- ability is being tracked
	if AuraMastery:IsTrackedEvent(eventCode, result, abilityId) then
	
		-- 
		-- In some cases when a 2040/45 and 2050 are registered for the same abilityId, an insert on2050 is made before onUpdate (does not update in real time, that is the problem) 
		-- deletes the old on2040/45 combat effect. This function call prevents that.
		--
		if 2250 == result then
			AuraMastery:UpdateCombatEffects(GetGameTimeMilliSeconds())
		end
		AuraMastery:UpdateCustomTriggerStates(abilityId, eventCode,result,isError,abilityName,abilityGraphic,abilityActionSlotType,sourceName,sourceType,targetName,targetType,hitValue,powerType,damageType,combatEventLog,sourceUnitId,targetUnitId,abilityId)	
		local updateIndex
		local activeCombatEffects = AuraMastery.activeCombatEffects

		-- 1. regular durations
		if nil == AuraMastery.activeCombatEffects[abilityId] then
			AuraMastery.activeCombatEffects[abilityId] = {}		
		end

		for i=1, #activeCombatEffects[abilityId] do
			if sourceName == activeCombatEffects[abilityId][i]['sourceName'] and targetName == activeCombatEffects[abilityId][i]['targetName'] and sourceUnitId == activeCombatEffects[abilityId][i]['sourceUnitId'] and targetUnitId == activeCombatEffects[abilityId][i]['targetUnitId'] then
				updateIndex = i
			end
		end

		if not updateIndex then
			-- add effect to table
			AuraMastery:CEEffectGained(abilityId, sourceName, sourceUnitId, targetName, targetUnitId, endTime, result)
		else	

			-- Refresh effect (combat events do not return refresh results, only gained and faded)
			AuraMastery:CEEffectRefreshed(abilityId, updateIndex, sourceName, sourceUnitId, targetName, targetUnitId, endTime, result)
		end

		-- 2. custom durations
		local abilityCustomDuration = AuraMastery.trackedEvents[EVENT_COMBAT_EVENT].custom[abilityId]
		if abilityCustomDuration then

			for auraName, duration in pairs(abilityCustomDuration) do
				local activeCustomDurations = AuraMastery.activeCustomDurations[eventCode][auraName][abilityId] -- index will always be = 1 because there can only be one custom duration active for a given abilityId on a given aura at the same time
				local endTime = curTime+duration	-- calculate custom duration and use it as new endTime	
				updateIndex = 0
				
				for i=1, #activeCustomDurations do
					if sourceName == activeCustomDurations[i]['sourceName'] and targetName == activeCustomDurations[i]['targetName'] and sourceUnitId == activeCustomDurations[i]['sourceUnitId'] and targetUnitId == activeCustomDurations[i]['targetUnitId'] then
						updateIndex = i
					end
				end
			
				if 0 == updateIndex then
					-- add effect to table 
					AuraMastery:CustomDurationGained(eventCode, auraName, abilityId, sourceName, sourceUnitId, targetName, targetUnitId, endTime, result)
				else	
					-- Refresh effect (combat events do not return refresh results, only gained and faded)		    
					AuraMastery:CustomDurationRefreshed(eventCode, auraName, abilityId, updateIndex, sourceName, sourceUnitId, targetName, targetUnitId, endTime, result)
				end

			end
		end
	end

end


--++++++++++++++++++--
-- EVENT PROCESSING --
--++++++++++++++++++--


-- EVENT_EFFECT_CHANGED
function AuraMastery:EffectGained(abilityId, endTime, effectSlot, unitTag, unitId, stackCount, source)
	if ("reticleover" == unitTag) then
		if nil == AuraMastery.ROActiveEffects[abilityId] then AuraMastery.ROActiveEffects[abilityId] = {}; end
		table.insert(AuraMastery.ROActiveEffects[abilityId], {['endTime'] = endTime, ['effectSlot'] = effectSlot, ['stacks'] = stackCount, ['unitTag'] = unitTag, ['unitId'] = unitId, ['source'] = source})
	elseif ("player" == unitTag) then
		local effects = AuraMastery.activeEffects[abilityId]
		if nil == AuraMastery.activeEffects[abilityId] then AuraMastery.activeEffects[abilityId] = {}; end
		table.insert(AuraMastery.activeEffects[abilityId], {['endTime'] = endTime, ['effectSlot'] = effectSlot, ['stacks'] = stackCount, ['unitTag'] = unitTag, ['unitId'] = unitId, ['source'] = source})
	end
	self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId)
end

function AuraMastery:EffectRemoved(abilityId, effectSlot, unitTag, unitId)
	--
	-- no need to check for other unitTags than "player" and "reticleover", 
	-- as effects on reticleover get automatically deleted when moving the 
	-- reticle away from the target
	--
	if ("player" == unitTag) then
		local effects = AuraMastery.activeEffects[abilityId]
		if (nil == effects) then return; end -- <-- temporärer workaround bis aktive buffs/debuffs auf dem spieler beim login/reload ausgelesen und in activeEffects gespeichert werden	
		for i=#effects, 1, -1 do
			if effects[i]['effectSlot'] == effectSlot then
				table.remove(effects, i)
			end									
		end
		if 0 == #effects then AuraMastery.activeEffects[abilityId] = nil; --[[return;]] end
	elseif ("reticleover" == unitTag) then
		local effects = AuraMastery.ROActiveEffects[abilityId]
		if nil ~= effects then
			for i=#effects, 1, -1 do
				if effects[i]['effectSlot'] == effectSlot then
					table.remove(effects, i)
				end
			end
			if 0 == #effects then AuraMastery.ROActiveEffects[abilityId] = nil; --[[return;]] end
		end
	end
	self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId)
end

function AuraMastery:EffectRefreshed(abilityId, endTime, effectSlot, unitTag, unitId, stackCount, source)
	-- workaround to emulate a fade event for the refreshed effect to retrigger the cooldown display
	self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId, false, true)

	if ("player" == unitTag) then
		if nil ~= AuraMastery.activeEffects[abilityId] then
			for i=1, #AuraMastery.activeEffects[abilityId] do
				if AuraMastery.activeEffects[abilityId][i]['effectSlot'] == effectSlot then
					AuraMastery.activeEffects[abilityId][i]['stacks'] = stackCount
					AuraMastery.activeEffects[abilityId][i]['endTime'] = endTime
					AuraMastery.activeEffects[abilityId][i]['source'] = source
					self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId, false, true)
				end
			end
		else
			AuraMastery:EffectGained(abilityId, endTime, effectSlot, unitTag, unitId, stackCount, source)
		end
	elseif ("reticleover" == unitTag) then
		if nil ~= AuraMastery.ROActiveEffects[abilityId] then
			for i=1, #AuraMastery.ROActiveEffects[abilityId] do
				if AuraMastery.ROActiveEffects[abilityId][i]['effectSlot'] == effectSlot then
					AuraMastery.ROActiveEffects[abilityId][i]['stacks'] = stackCount
					AuraMastery.ROActiveEffects[abilityId][i]['endTime'] = endTime
					AuraMastery.ROActiveEffects[abilityId][i]['source'] = source
					self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId, false, true)
				end
			end
		else
			AuraMastery:EffectGained(abilityId, endTime, effectSlot, unitTag, unitId, stackCount, source)
		end
	end
end

function AuraMastery:ROEffectGained(abilityId, endTime, effectSlot, stackCount, source)
	table.insert(AuraMastery.ROActiveEffects[abilityId], {['endTime'] = endTime, ['effectSlot'] = effectSlot, ['stacks'] = stackCount, ['source'] = source})
	self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId)
end

function AuraMastery:ROEffectRemoved(abilityId, endTime, effectSlot, castByPlayer)
	if AuraMastery.debug then
		if not abilityId then abilityId = "noAbilityId" end
		if not endTime then endTime = "noEndTime" end
		if not effectSlot then effectSlot = "noEffectSlot" end
		if not castByPlayer then castByPlayer = "noCastByPlayer" end
		
-- deb("Called: ROEffectRemoved("..abilityId..", "..endTime..", "..effectSlot..", "..castByPlayer..")");
	end
	self.ROActiveEffects[abilityId] = nil
	self:UpdateAffectedAuras(EVENT_EFFECT_CHANGED, abilityId)
end

function AuraMastery:ClearROAuras()
	local ROActiveEffects = self.ROActiveEffects
	for abilityId, data in pairs(ROActiveEffects) do
		for i=1, #data do
			local endTime = data[i]['endTime']
			local effectSlot = data[i]['effectSlot']
			local castByPlayer = data[i]['source']
			self:ROEffectRemoved(abilityId)
		end
	end
end


-- EVENT_ACTION_SLOT_ABILITY_USED
function AuraMastery:FakeEffectGained(abilityId, endTime)
	if nil == self.activeFakeEffects[abilityId] then self.activeFakeEffects[abilityId] = {[1]={}}; end
	self.activeFakeEffects[abilityId][1]['endTime'] = endTime
	AuraMastery:UpdateAffectedAuras(EVENT_ACTION_SLOT_ABILITY_USED, abilityId, false, true)
end

function AuraMastery:FakeEffectRemoved(abilityId)
	self.activeFakeEffects[abilityId] = nil
	AuraMastery:UpdateAffectedAuras(EVENT_ACTION_SLOT_ABILITY_USED, abilityId)
end

function AuraMastery:FakeEffectRefreshed(abilityId)
	self.activeCombatEffects[abilityId][updateIndex]['sourceName'] = sourceName	
	self.activeCombatEffects[abilityId][updateIndex]['targetName'] = targetName
	self.activeCombatEffects[abilityId][updateIndex]['targetUnitId'] = targetUnitId				
	self.activeCombatEffects[abilityId][updateIndex]['endTime'] = endTime
	self:UpdateAffectedAuras(EVENT_COMBAT_EVENT, abilityId, false, true)
end


-- EVENT_COMBAT_EVENT
function AuraMastery:CEEffectGained(abilityId, sourceName, sourceUnitId, targetName, targetUnitId, endTime, actionResultId)
	table.insert(AuraMastery.activeCombatEffects[abilityId], {['sourceName'] = sourceName, ['sourceUnitId'] = sourceUnitId, ['targetName'] = targetName, ['targetUnitId'] = targetUnitId, ['endTime'] = endTime})
	AuraMastery:UpdateAffectedAuras(EVENT_COMBAT_EVENT, abilityId, actionResultId)
end

function AuraMastery:CEEffectRemoved(abilityId, effectIndex)
	local effect = self.activeCombatEffects[abilityId]
	table.remove(effect, effectIndex)
	if 0 == #effect then
		self.activeCombatEffects[abilityId] = nil
	end
	self:UpdateAffectedAuras(EVENT_COMBAT_EVENT, abilityId)
end

function AuraMastery:CEEffectRefreshed(abilityId, updateIndex, sourceName, sourceUnitId, targetName, targetUnitId, endTime, actionResultId)
	self.activeCombatEffects[abilityId][updateIndex]['sourceName'] = sourceName
	self.activeCombatEffects[abilityId][updateIndex]['sourceUnitId'] = sourceUnitId
	self.activeCombatEffects[abilityId][updateIndex]['targetName'] = targetName
	self.activeCombatEffects[abilityId][updateIndex]['targetUnitId'] = targetUnitId				
	self.activeCombatEffects[abilityId][updateIndex]['endTime'] = endTime
	self:UpdateAffectedAuras(EVENT_COMBAT_EVENT, abilityId, actionResultId, true)
end


-- MISC_EVENTS
function AuraMastery:CustomDurationGained(eventId, auraName, abilityId, sourceName, sourceUnitId, targetName, targetUnitId, endTime, actionResultId)

--deb(GetGameTimeMilliSeconds()..": Gained: "..abilityId)

	table.insert(AuraMastery.activeCustomDurations[eventId][auraName][abilityId], {['sourceName'] = sourceName, ['sourceUnitId'] = sourceUnitId, ['targetName'] = targetName, ['targetUnitId'] = targetUnitId, ['endTime'] = endTime})
	AuraMastery:UpdateAffectedAuras(AURAMASTERY_EVENT_CUSTOM_DURATION_CHANGED, abilityId, actionResultId)
end

function AuraMastery:CustomDurationRemoved(eventId, auraName, abilityId, effectIndex)
	local effect = self.activeCustomDurations[eventId][auraName][abilityId]
	table.remove(effect, effectIndex)
--deb(GetGameTimeMilliSeconds()..": Removed: "..abilityId)

	--self.activeCustomDurations[auraName][abilityId][effectIndex] = nil -- index will always be = 1 as there can never be more than one custom duration for a given abilityId of a given aura registered!
	AuraMastery:UpdateAffectedAuras(AURAMASTERY_EVENT_CUSTOM_DURATION_CHANGED, abilityId)
end
											 
function AuraMastery:CustomDurationRefreshed(eventId, auraName, abilityId, updateIndex, sourceName, sourceUnitId, targetName, targetUnitId, endTime, actionResultId)

--deb(GetGameTimeMilliSeconds()..": Refreshed: "..abilityId)

	self.activeCustomDurations[eventId][auraName][abilityId][updateIndex]['sourceName'] = sourceName
	self.activeCustomDurations[eventId][auraName][abilityId][updateIndex]['sourceUnitId'] = sourceUnitId
	self.activeCustomDurations[eventId][auraName][abilityId][updateIndex]['targetName'] = targetName
	self.activeCustomDurations[eventId][auraName][abilityId][updateIndex]['targetUnitId'] = targetUnitId	
	self.activeCustomDurations[eventId][auraName][abilityId][updateIndex]['endTime'] 	= endTime
	self:UpdateAffectedAuras(AURAMASTERY_EVENT_CUSTOM_DURATION_CHANGED, abilityId, actionResultId, true)
end


--+++++++++++++++++--
-- ADDON FUNCTIONS --
--+++++++++++++++++--
function AuraMastery.updateHandler()

	--
	-- If the edit aura menu is loaded, do not update any auras anymore
	--
	local mode = AuraMastery:GetMode()
	if 1 ~= mode then return; end
	AuraMastery.curTime = GetGameTimeMilliSeconds()
	local curTime = AuraMastery.curTime
	--
	-- It's important that the three functions get called first as combat event based auras that use action result 2040 (effect gained) and result 2050 (effect faded)
	-- can get in conflict with each other by injecting new aura durations on2050 before the old aura has been untriggered
	--
	AuraMastery:UpdateFakeEffects(curTime)
	AuraMastery:UpdateCombatEffects(curTime)
	AuraMastery:UpdateCustomDurations(curTime)
	
	local auraDurations = AuraMastery.auraDurations		
	for auraName, durationData in pairs(auraDurations) do
		local beginTime = durationData['beginTime']
		local endTime = durationData['endTime']
		if nil ~= beginTime and nil ~= endTime then
			if curTime >= beginTime and curTime <= endTime then
				AuraMastery.aura[auraName]:Trigger()
			else	
				AuraMastery.aura[auraName]:Untrigger()
			end
		end
	end

	local auras = AuraMastery.aura
	for auraName, auraObj in pairs(auras) do
		local showCooldownText = AuraMastery.svars.auraData[auraName].showCooldownText
		if  showCooldownText then
			auraObj:SetDurationText()
		end
		if auraObj:IsAuraTextRegisteredForUpdate() then
			auraObj:ParseAuraTextTimeData()
		end
	end
end

function AuraMastery:UpdateCustomTriggerStates(abilityId, ...)
	local eventCode = select(1, ...)
	local n = #self.loadedAuras
	for i=1, n do
		local auraName = self.loadedAuras[i]
		local aura = self.aura[auraName]
		local attachedEvents = aura.data.attachedEvents[eventCode]


			
		-- todo: Lookup-table einrichten, damit nicht über alle attached events iteriert werden muss (es interessiert ja nur trigger type 3)
		if attachedEvents then
			local n = #attachedEvents
			for relevantAbilityId, triggerData in pairs(attachedEvents) do
				if relevantAbilityId == abilityId then
					local isCustomTrigger = triggerData.isCustomTrigger
					if isCustomTrigger then	
--deb("checkingConditions for ability "..abilityId.."...")					
						local triggerIndex = triggerData.triggerIndex
						if aura:CheckCustomTriggerConditionMet(triggerIndex, ...) then
--deb("setting custom triggerState to active")
							aura:SetCustomTriggerState(triggerIndex, true)
						end
						if aura:CheckCustomUntriggerConditionMet(triggerIndex, ...) then
--deb("setting custom triggerState to inactive")
							aura:SetCustomTriggerState(triggerIndex, false)
						end
					end		
				end
			end	
		end
	end				
end

--
-- This method connects the event layer with the trigger layer. It's called by an event's appropriate event handler.
--
function AuraMastery:UpdateAffectedAuras(eventCode, abilityId, actionResultId, prepareForRetrigger)
	--
	-- If the edit aura menu is loaded, do not update any auras anymore
	--
	local mode = self:GetMode()
	if 1 ~= mode then return; end

	--
	-- Event Code for EVENT_RETICLE_TARGET_CHANGED must be overridden by EVENT_EFFECT_CHANGED
	--
	
	if AuraMastery.debug then
		if not eventCode then debEventCode = "[empty: eventCode]"; else debEventCode = eventCode; end
		if not abilityId then debAbilityId = "[empty: abilityId]"; else debAbilityId = abilityId; end
		if not actionResultId then debActionResultId = "[empty: actionResultId]"; else debActionResultId = actionResultId; end
		if not prepareForRetrigger then debPrepareForRetrigger = "[empty: prepareForRetrigger]"; else debPrepareForRetrigger = prepareForRetrigger; end
		deb("Called: UpdateAffectedAuras("..debEventCode..", "..debAbilityId..", "..debActionResultId..", "..debPrepareForRetrigger..")")
		
	end
	
	local n = #self.loadedAuras
	for i=1, n do
		local auraName = self.loadedAuras[i]
		local aura = self.aura[auraName]
		local attachedEvents = aura.data.attachedEvents[eventCode]

		--
		-- ATTENTION: Don't mix this up with AuraMastery.trackedEvents! registered events is part of the aura
		-- object and is registered seperately; this is needed for handling custom durations as events (eventCode: 0)
		--
		if attachedEvents then
			local n = #attachedEvents
			for relevantAbilityId, attachedEventsData in pairs(attachedEvents) do
				if relevantAbilityId == abilityId then
					local conditionsMet = aura:CheckTriggersBaseconditionsMet()
					local isNotAffectedByActionResult = self:IsNotAffectedByActionResult(abilityId, actionResultId, auraName)
					if prepareForRetrigger and not isNotAffectedByActionResult then
						--[[
						if nil ~= self.auraDurations[auraName] then
							--
							-- this is normally called by an aura's triggers' base conditions check - since we are only untriggering here,
							-- a condition check is not called and we have to manually unregister the aura
							-- (see AuraObj:CheckTriggersBaseconditionsMet() in prototypes.lua)
							--
							--aura:UnregisterAuraForUpdate()
						end
						]]					
						-- set aura state to 'untriggered' to allow it to be triggered again (triggered auras will be ignored by aura:Trigger() as long as triggerState=1)
						aura:SetAuraState(0)
					end
					if false == conditionsMet then
--deb(GetGameTimeMilliSeconds())
						aura:Untrigger()
					elseif true == conditionsMet and not isNotAffectedByActionResult then
						aura:Trigger()
					end
				end
			end
		end
	end
end

--
-- Determines if a combat event based aura has been affected by a fired combat event by doing a check on the fired combat events action result
--
function AuraMastery:IsNotAffectedByActionResult(abilityId, actionResultId, auraName)
	if actionResultId then
		local registeredActionResults = self.trackedEvents[EVENT_COMBAT_EVENT]['actionResults'][abilityId]
		for registeredActionResultsId, registeredActionResultsData in pairs(registeredActionResults) do	
			if registeredActionResultsId == actionResultId then	-- only browse through passed action result id
				if not table.contains(registeredActionResultsData, auraName) then
					return true
				end
			end
		end
	end
	return false
end

function AuraMastery:IsTrackedEvent(eventId, actionResultId, abilityId)
	if AuraMastery.trackedEvents[eventId].abilityIds[abilityId] then
		local trackedActionResults = AuraMastery.trackedEvents[eventId]['actionResults'][abilityId]
		if trackedActionResults and trackedActionResults[actionResultId] then
			return true
		end
	end
	return false
end

function AuraMastery:CheckAll(abilityId, auraDataSource, selfCastOnly, sourceName, targetName)
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
				if sourceName and "" ~= zo_strtrim(sourceName) and data['sourceName'] ~= sourceName then
					sourceCondition = false
				end
				if targetName and "" ~= zo_strtrim(targetName) and data['targetName'] ~= targetName then
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

function AuraMastery:GetLongestDurationData(abilityId, dataSource, selfCastOnly, triggerCasterName, triggerTargetName)
	local effectIndex
	local endTime = -1
	local n = #dataSource[abilityId]

	for i=1, n do
		local selfCastCondition = true
		local sourceCondition = true
		local targetCondition = true

		local data = dataSource[abilityId][i]

		if triggerCasterName and "" ~= zo_strtrim(triggerCasterName) and data['sourceName'] ~= triggerCasterName then
			sourceCondition = false
		end
		if triggerTargetName and "" ~= zo_strtrim(triggerTargetName) and data['targetName'] ~= triggerTargetName then
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

function AuraMastery:RemoveAuraData(auraName)
	self.svars.auraData[auraName] = nil

	-- delete aura data from tracked events
	for abilityId, auras in pairs(self.trackedEvents[EVENT_ACTION_SLOT_ABILITY_USED]['abilityIds']) do
		for i=1, #auras do
			if auraName == auras[i] then table.remove(auras, i); end
		end
	end
	
	for abilityId, auras in pairs(self.trackedEvents[EVENT_ACTION_SLOT_ABILITY_USED]['custom']) do
		for i=1, #auras do
			if auraName == auras[i] then table.remove(auras, i); end
		end
	end
	
	for abilityId, auras in pairs(self.trackedEvents[EVENT_COMBAT_EVENT]['abilityIds']) do
		for i=1, #auras do
			if auraName == auras[i] then table.remove(auras, i); end
		end
	end
	for abilityId, auras in pairs(self.trackedEvents[EVENT_COMBAT_EVENT]['custom']) do
		for i=1, #auras do
			if auraName == auras[i] then table.remove(auras, i); end
		end
	end

	-- delete aura from custom duration updater lookup table
	AuraMastery.auraDurations[auraName] = nil
	
	
	-- unset currently active custom durations
	local activeCustomDurations = self.activeCustomDurations
	for eventId, data in pairs(activeCustomDurations) do
		for auraName, _ in pairs(data) do
			self.activeCustomDurations[eventId][auraName] = nil
		end
	end
	
	-- note: EVENT_EFFECT_CHANGED has no custom durations!
	for abilityId, auras in pairs(self.trackedEvents[EVENT_EFFECT_CHANGED]['abilityIds']) do
		for i=1, #auras do
			if auraName == auras[i] then table.remove(auras, i); end
		end
	end
	
	self.aura[auraName] = nil
end

function AuraMastery:UpdateFakeEffects(curTime)
	local activeFakeEffects = AuraMastery.activeFakeEffects
	for abilityId, data in pairs(activeFakeEffects) do
		for i=1,#data do
			local endTime = data[i]['endTime']
			if curTime > endTime then
				self:FakeEffectRemoved(abilityId)
			end
		end
	end
end

function AuraMastery:UpdateCustomDurations(curTime)
	local activeCustomDurations = AuraMastery.activeCustomDurations

	-- combat event custom durations
	for auraName, auraData in pairs(activeCustomDurations[EVENT_COMBAT_EVENT]) do
		for abilityId, customDurationData in pairs(auraData) do
			for i = #customDurationData, 1, -1 do
				local endTime = customDurationData[i]['endTime']
				if curTime > endTime then
					self:CustomDurationRemoved(EVENT_COMBAT_EVENT, auraName, abilityId, i)
				end
			end
		end
	end
	
	-- fake effect custom durations
	for auraName, auraData in pairs(activeCustomDurations[EVENT_ACTION_SLOT_ABILITY_USED]) do
		for abilityId, customDurationData in pairs(auraData) do	
			for i = #customDurationData, 1, -1 do
				local endTime = customDurationData[i]['endTime']
				if curTime > endTime then
					self:CustomDurationRemoved(EVENT_ACTION_SLOT_ABILITY_USED, auraName, abilityId, i)
				end
			end
		end
	end
end

function AuraMastery:UpdateCombatEffects(curTime)
	local activeCombatEffects = AuraMastery.activeCombatEffects
	for abilityId, effects in pairs(activeCombatEffects) do
		for i=#effects,1,-1 do
			local endTime = effects[i]['endTime']
			if curTime > endTime then
--deb(curTime..">"..endTime)
				self:CEEffectRemoved(abilityId, i)
			end
		end
	end
end

function AuraMastery:GetAllAbilityIdsByAbilityName(abilityName)
	local abilityIds = {}
	for i=1, AURAMASTERY_ABILITY_IDS_MAX_VALUE do
		if (DoesAbilityExist(i) and abilityName == GetAbilityName(i)) then
			table.insert(abilityIds, i)
		end
	end
	return abilityIds
end

function AuraMastery:RegisterForEvents(eventId)
	local abilityIds = self.trackedEvents[eventId]['abilityIds']
	for abilityId, data in pairs (abilityIds) do
		local eventNamespace = "AM_"..eventId..abilityId
		local eventHandler = AuraMastery.codes['eventHandlersByEventTypes'][eventId]
		
		--
		-- Contrary to filters, events can only be registered once. Avoids registering the same filter multiple times.
		--
		if EVENT_MANAGER:RegisterForEvent(eventNamespace, eventId, eventHandler) then
			EVENT_MANAGER:AddFilterForEvent(eventNamespace, eventId, REGISTER_FILTER_ABILITY_ID, abilityId)
		end
	end
end

function AuraMastery:UnregisterForEvents(eventId)
	local abilityIds = self.trackedEvents[eventId]['abilityIds']
	for abilityId, _ in ipairs (abilityIds) do
		local eventNamespace = "AM_"..eventId..abilityId
		EVENT_MANAGER:UnregisterForEvent(eventNamespace, eventId)
	end
end

function AuraMastery:ReregisterForEvents(eventId)
	self:UnregisterForEvents(eventId)
	self:RegisterForEvents(eventId)
end

function AuraMastery:PlayScreenFlash(colorData, endAlpha, duration, loopCount)
	local overlay = AM_ScreenOverlay
	local animation = ZO_AlphaAnimation_GetAnimation(overlay)
	overlay:SetColor(unpack(colorData))	
	animation:PingPong(0, endAlpha, duration, loopCount)	
end

--++++++++++++++++++--
-- HELPER FUNCTIONS --
--++++++++++++++++++--
function AuraMastery.FormatTime(remaining, critical)
	if (remaining < critical) then
		return string.format(formatCritical, remaining)
	elseif (remaining < 60) then
		return string.format(formatSeconds, remaining)
	elseif (remaining < 3600) then
		return string.format(formatMinutes, math.floor(remaining / 60))
	elseif (remaining > 172800) then
		return string.format(formatDays, math.floor(remaining / 86400))
	else
		return string.format(formatHours, math.floor(remaining / 3600))
	end
end

function GetGameTimeMilliSeconds()
	local ms = GetGameTimeMilliseconds();
	return ms/1000;
end

function deb(s, callLater)
	if callLater then
		zo_callLater(function() d(s) end, 2500)
	else
		d(s)
	end
end

function table.contains(table, element)
	if not table then return false; end
	for key, value in pairs(table) do
		if value == element then
		return key
		end
	end
	return false
end

function AuraMastery:GetNumElements(t)
	if not t then return; end
	local count = 0
	for _ in pairs(t) do
		count = count + 1;
	end
	return count
end

function AuraMastery:pairsByKeys (t, f)
	local a = {};
	for n in pairs(t) do
		table.insert(a, n);
	end
	table.sort(a, f)
	local i = 0 ;						-- iterator variable
	local iterator = function ()	-- iterator function
		i = i + 1;
		if (a[i] == nil) then
			return nil;
		else
			return a[i], t[a[i]];
		end
	end
	return iterator
end

function AuraMastery:toboolean(val)
	if "string" == type(val) then
		if "true" == val then return true; else return false; end	
	end
end

function AuraMastery:GetTableKey(t, value)
	for k,v in pairs(t) do
		if v==value then return k; end
	end
	return
end

function AuraMastery:GetUnlocalized()
	local counter = 0
	for i = 1, 20000 do
		if (DoesAbilityExist(i)) then
			local abilityName = GetAbilityName(i)
			if (nil == abilityName:find("%^")) then
				counter = counter+1
				d(abilityName)
			end
		end
	end
	d("Total: "..tostring(counter))
end

function AuraMastery:GetAbilityInfo(abilityId)
	d("<------#Results for abilityId "..abilityId.."#------>")
	d("01) Name: "..tostring(GetAbilityName(abilityId)))
	d("02) Description: "..tostring(GetAbilityDescription(abilityId)))
	d("03) EffectDescription: "..tostring(GetAbilityEffectDescription(abilityId)))
	d("04) Cost: "..tostring(GetAbilityCost(abilityId)))
	d("05) Duration: "..tostring(GetAbilityDuration(abilityId)))
	d("06) Icon: "..tostring(GetAbilityIcon(abilityId)))
	d("07) Radius: "..tostring(GetAbilityRadius(abilityId)))
	d("08) Range: "..tostring(GetAbilityRange(abilityId)))
	d("09) TargetDescription: "..tostring(GetAbilityTargetDescription(abilityId)))
	d("<--------------------------------------------------->")
end

function AuraMastery:GetAbilityIdsMaxValue()
	local maxValue = 0
	for i=1, 1000000 do
		if (DoesAbilityExist(i)) then
			maxValue = i
		end
	end
	return maxValue
end

function AuraMastery:GetPlayerEffects()
	local numAuras = GetNumBuffs("player")
	for i=1, numAuras do
		local auraName, startTime, endTime, effectSlot, _, _, _, _, _, _, abilityId, castByPlayer = GetUnitBuffInfo('player', i);
		d("<------#Results for abilityId "..abilityId.."#------>")
		d("01) Name: "..tostring(GetAbilityName(abilityId)))
		d("02) Description: "..tostring(GetAbilityDescription(abilityId)))
		d("03) EffectDescription: "..tostring(GetAbilityEffectDescription(abilityId)))
		d("04) Cost: "..tostring(GetAbilityCost(abilityId)))
		d("05) Duration: "..tostring(GetAbilityDuration(abilityId)))
		d("06) Icon: "..tostring(GetAbilityIcon(abilityId)))
		d("07) Radius: "..tostring(GetAbilityRadius(abilityId)))
		d("08) Range: "..tostring(GetAbilityRange(abilityId)))
		d("09) TargetDescription: "..tostring(GetAbilityTargetDescription(abilityId)))
		d("<--------------------------------------------------->")
	end
end

function AuraMastery:SearchEffect(str)
	local numAuras = GetNumBuffs("player")
	for i=1, numAuras do
		local auraName, startTime, endTime, effectSlot, _, _, _, _, _, _, abilityId, castByPlayer = GetUnitBuffInfo('player', i);
		d("<------#Results for abilityId "..abilityId.."#------>")
		d("01) Name: "..tostring(GetAbilityName(abilityId)))
		d("02) Description: "..tostring(GetAbilityDescription(abilityId)))
		d("03) EffectDescription: "..tostring(GetAbilityEffectDescription(abilityId)))
		d("04) Cost: "..tostring(GetAbilityCost(abilityId)))
		d("05) Duration: "..tostring(GetAbilityDuration(abilityId)))
		d("06) Icon: "..tostring(GetAbilityIcon(abilityId)))
		d("07) Radius: "..tostring(GetAbilityRadius(abilityId)))
		d("08) Range: "..tostring(GetAbilityRange(abilityId)))
		d("09) TargetDescription: "..tostring(GetAbilityTargetDescription(abilityId)))
		d("<--------------------------------------------------->")
	end
end


--==========================================
-- ScrollList Functions --------------------
--==========================================
function AuraMastery:AM_ComboBox_SelectItemByName(m_comboBox, itemName)
	local items = m_comboBox.m_sortedItems
	for i=1, #items do
		if items[i].name == itemName then
			m_comboBox:SelectItemByIndex(i)	-- comboBoxes seem to use the index stored in m_comboBox.m_sortedItems for SelectItemByIndex(), NOT the internal value!
		end
	end
end

function AuraMastery:AM_ComboBox_SelectItemByInternalValue(m_comboBox, internalValue, ignoreCallback)
	local items = m_comboBox.m_sortedItems
	for i=1, #items do
		local itemsInternalValue = items[i].internalValue
		if items[i].internalValue == internalValue then
			m_comboBox:SelectItemByIndex(i, ignoreCallback)	-- scroll lists use the index stored in m_comboBox.m_sortedItems for SelectItemByIndex(), NOT the internal value!
		end
	end		
end

function AuraMastery:AM_ScrollList_SelectItemByName(scrollListControl, itemName, animateInstantly)
	local dataList = ZO_ScrollList_GetDataList(scrollListControl)
	for i=1, #dataList do
		local dataAssignedControl = dataList[i].control
		local data = dataList[i].data
		for dataKey, dataName in pairs(data) do
			if itemName == dataName then
				ZO_ScrollList_SelectData(scrollListControl, data, dataAssignedControl, false, animateInstantly)
			end
		end
	end
end

--[[
function AuraMastery:CheckForActiveEffects() -- currently not used!
	local numAuras = GetNumBuffs("player")
	for i=1, numAuras do
		local auraName, startTime, endTime, effectSlot, _, _, _, _, _, _, abilityId, castByPlayer = GetUnitBuffInfo('player', i);
		if (AuraMastery.trackedEvents[EVENT_EFFECT_CHANGED].abilityIds[abilityId]) then
			AuraMastery:EffectGained(abilityId, endTime, effectSlot, "player", 0) -- TODO: 0 ist ein Platzhalter für die UnitId. Weg finden, die UnitId des unitTags "player" herauszufinden und hier zu übergeben
			AuraMastery:UpdateAuras(abilityId)
		end
	end
end

function AuraMastery:UpdateAuras(abilityId)	-- currently not used!
	for i=1, #AuraMastery.trackedEvents[EVENT_EFFECT_CHANGED]['abilityIds'][abilityId] do -- todo: evtl. erst prüfen ob numerischer wert existiert!
		local auraName = AuraMastery.trackedEvents'EVENT_EFFECT_CHANGED]['abilityIds'][abilityId][i]
		AuraMastery:UpdateAura(auraName)
	end
end

function AuraMastery:GetSlotAbility(abilityId)
	for i = 3, 8 do
		local slotedAbilityId = GetSlotBoundId(i);
		--d(i..": "..slotedAbilityId);
		if abilityId == slotedAbilityId then return true; else return false; end
	end
end

function AuraMastery:GetToggled()
	-- returns all abilityIDs that match the names used as toggledAuras
	-- used to grab ALL the nessecary abilityIDs for the table after a patch changes things
	local data, names, saved = {}, {}, {}

	for k, v in pairs(toggledAuras) do
		names[GetAbilityName(k)] = true
	end

	for x = 1, 100000 do
		if (DoesAbilityExist(x) and names[GetAbilityName(x)] and GetAbilityDuration(x) == 0 and GetAbilityDescription(x) ~= '') then
			table.insert(data, {(GetAbilityName(x)), x, GetAbilityDescription(x)})
		end
	end

	table.sort(data, function(a, b)	return a[1] > b[1] end)

	for k, v in ipairs(data) do
		d(v[2] .. ' ' .. v[1] .. '      ' .. string.sub(v[3], 1, 30))
		table.insert(saved, v[2] .. '|' .. v[1]..'||' ..string.sub(v[3],1,30))
	end

	--SrendarrDB.toggled = saved
end



	-- set custom trigger status
	local triggerAuras = AuraMastery.trackedEvents[EVENT_COMBAT_EVENT]['trigger'][abilityId]

	if triggerAuras then
		for auraName,data in pairs(triggerAuras) do
			if changeType == data.condition then
--d(auraName)
				AuraMastery.triggerData[auraName][data.triggerId] = true
			end
		end
	end

	-- set custom untrigger status
	local untriggerAuras = AuraMastery.trackedEvents[EVENT_COMBAT_EVENT]['untrigger'][abilityId]

	if untriggerAuras then
		for auraName,data in pairs(untriggerAuras) do
d("if "..changeType.." == "..data.condition.." then.......")
			if changeType == data.condition then
d(auraName)
				AuraMastery.triggerData[auraName][data.triggerId] = false
			end
		end
	end
			if (nil == AuraMastery.activeCombatEffects[abilityId]) then return; end -- <-- temporärer workaround bis aktive buffs/debuffs auf dem spieler beim login/reload ausgelesen und in activeCombatEffects gespeichert werden
			for i=1, #AuraMastery.activeCombatEffects[abilityId] do
				AuraMastery.activeCombatEffects[abilityId][i] = nil;
			end
			if 0 == #AuraMastery.activeCombatEffects[abilityId] then AuraMastery.activeCombatEffects[abilityId] = nil; return; end

		end
]]