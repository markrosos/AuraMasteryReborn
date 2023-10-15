local WM = WINDOW_MANAGER

function AuraMastery:InitializeControls()
	auraMasteryTLW = WM:CreateTopLevelWindow("AuraMasteryTLW")
	auraMasteryControlPoolStorage = WM:CreateControl("AMControlPool", auraMasteryTLW, CT_CONTROL)
	auraMasteryControlPoolStorage:SetHidden(true)
	local fragment = ZO_SimpleSceneFragment:New(auraMasteryTLW)
	HUD_SCENE:AddFragment(fragment)
	HUD_UI_SCENE:AddFragment(fragment)
	
	local overlay = WM:CreateControl("AM_ScreenOverlay", auraMasteryTLW, CT_TEXTURE)
	overlay:SetAnchor(TOPLEFT, auraMasteryTLW, TOPLEFT)
	overlay:SetAnchorFill(GuiRoot)
	overlay:SetAlpha(0)	  
	local animation = ZO_AlphaAnimation:New(overlay)
	
	self.aura = {}
	for k, v in pairs(self.svars.auraData) do
		self:CreateAuraControl(k)
		self:RegisterAbilityIds(k)
		self:AttachEventsToAuras(k)
		self:LoadAura(k)
	end
	self:CreateMenu()
end

function AuraMastery:ReloadAuraControl(auraName)
	self:CreateAuraControl(auraName)
	self:UnloadAura(auraName)
	self:UnregisterAbilityIds(auraName)
	self:DetachEventsFromAuras(auraName)
	self:RegisterAbilityIds(auraName)	
	self:AttachEventsToAuras(auraName)
	self:LoadAura(auraName)
end

function AuraMastery:CreateAuraControl(auraName)
	if 1 == self.svars.auraData[auraName].aType then
		self.aura[auraName] = self.Icon:New(auraName)
	elseif 2 == self.svars.auraData[auraName].aType then
		self.aura[auraName] = self.ProgressBar:New(auraName)
	elseif 4 == self.svars.auraData[auraName].aType then
		self.aura[auraName] = self.Text:New(auraName)
	end
	self.aura[auraName].control:SetAlpha(self.svars.auraData[auraName].alpha)
end

function AuraMastery.AuraOnShow(control)
	if AM_MODE_EDIT == AuraMastery:GetMode() then return; end
	local auraName = control:GetName()
	local auraData = AuraMastery.svars.auraData[auraName]
	local sound = auraData.triggerSound
	local animationData = auraData.animationData and auraData.animationData.trigger
	local delay = animationData and animationData.delay
	
	--
	-- Sounds handling
	--
	if sound then
		if delay then
			zo_callLater(function() PlaySound(sound); end, delay)
		else
			PlaySound(sound)
		end
	end
	
	
	--
	-- Animations handling
	--	
	if animationData then
		local colorData = animationData.colors
		local endAlpha = animationData.endAlpha
		local duration = animationData.duration
		local loopCount = animationData.loopCount
		if animationData then
			if delay then
				zo_callLater(function() AuraMastery:PlayScreenFlash(colorData, endAlpha, duration, loopCount); end, delay)
			else
				AuraMastery:PlayScreenFlash(colorData, endAlpha, duration, loopCount)
			end
		end
	end
end

function AuraMastery.AuraOnHide(control)
	if AM_MODE_EDIT == AuraMastery:GetMode() then return; end
	local auraName = control:GetName()
	local auraData = AuraMastery.svars.auraData[auraName]
	local sound = auraData.untriggerSound
	local animation = auraData.untriggerAnimation
	
	if sound then
		PlaySound(sound)
	end
	
	if animation then
		local colorData = animation.colors
		if 1 == animation then
			AuraMastery:PlayScreenFlash(colorData)
		end
	end
end

function AuraMastery:RemoveAuraControl(auraName)
	local control = self.aura[auraName].control
	local hiddenPool = WM:GetControlByName("AuraMasteryHiddenControls")
	
	-- strip all child elements off the control and move them to the invisible control pool
	local numChildren = control:GetNumChildren()
	for i=1, numChildren do
		local childControl = control:GetChild(i)
		if childControl then	-- neccessary as some controls contain an empty (nil) child, don't know why
			childControl:SetParent(hiddenPool)
		end
	end
	control:SetHidden(true)	
	self.aura[auraName].control = nil
end

function AuraMastery:OnDisplayPosChange(auraName)
	self.svars.auraData[auraName].posX = self.aura[auraName].control:GetLeft()
	self.svars.auraData[auraName].posY = self.aura[auraName].control:GetTop()
end

function AuraMastery:LockBar(bar, isLocked)
	self.aura[bar]:SetMouseEnabled(not isLocked)
	self.aura[bar]:SetMovable(not isLocked)
end

function AuraMastery:AttachEventsToAuras(auraName)
	local activated = AuraMastery.svars.auraData[auraName].loaded
	if activated then	-- only register active auras' ability ids
		local triggers = self.svars.auraData[auraName].triggers
		local aura = self.aura[auraName]
		
		for triggerIndex=1, #triggers	do
			local triggerType = triggers[triggerIndex].triggerType

			if 3 == triggerType then
-- ##################TODO: Implement CheckAll functionality! ########################
-- ##################################################################################	

				--
				-- custom trigger
				--
				local customTriggerType = triggers[triggerIndex].customTriggerData.eventType
				local customTriggerEventCode = self.G.eventTypesByIndex[customTriggerType]
				local customTriggerAbilityId = triggers[triggerIndex].customTriggerData.abilityId				
				aura:AttachEvent(customTriggerEventCode, customTriggerAbilityId, triggerIndex, customTriggerType)
				aura:SetCustomTriggerFlag(customTriggerEventCode, customTriggerAbilityId)
				-- special case for buff/debuff (trigger type = 1):
				if 1 == customTriggerType and 2 == triggers[triggerIndex].unitTag then
					-- tracking on targets additionally needs EVENT_RETICLE_TARGET_CHANGED (id: 131118)!
								   --  ||
								   --  VV
					aura:AttachEvent(131118, abilityId, triggerIndex, customTriggerType)
				end

				--
				-- custom untrigger
				--
				local customUntriggerType = triggers[triggerIndex].customUntriggerData.eventType
				local customUntriggerEventCode = self.G.eventTypesByIndex[customUntriggerType]
				local customUntriggerAbilityId = triggers[triggerIndex].customUntriggerData.abilityId			
				aura:AttachEvent(customUntriggerEventCode, customUntriggerAbilityId, triggerIndex, customUntriggerType)
				aura:SetCustomTriggerFlag(customUntriggerEventCode, customUntriggerAbilityId)
				if 1 == customUntriggerType and 2 == triggers[triggerIndex].unitTag then
					-- tracking on targets additionally needs EVENT_RETICLE_TARGET_CHANGED (id: 131118)!
								   --  ||
								   --  VV
					aura:AttachEvent(131118, abilityId, triggerIndex, customUntriggerType)
				end
				
			else
				local effectiveTriggerType = triggerType
				local eventCode    = self.codes['eventTypesByTriggerTypes'][effectiveTriggerType]
				local abilityId    = triggers[triggerIndex].spellId
				local duration     = triggers[triggerIndex].duration
				--
				-- This checks if there is a custom duration registered for this aura and this abilityId.
				-- If this is the case, the aura must be registered for custom duration handling (eventId: 0)
				-- instead of regular combat event handling
				--
				if duration and (2 == effectiveTriggerType or 4 == effectiveTriggerType) then
					eventCode = 0
				end

				--
				-- This checks whether all ability Ids for the current ability should be registered or just
				-- the one passed by the player.
				--
				local checkAll = triggers[triggerIndex].checkAll
				if false == checkAll then
					aura:AttachEvent(eventCode, abilityId, triggerIndex, effectiveTriggerType)
				else
					local abilityName = GetAbilityName(abilityId)				
					local allAbilityIds = self.abilityIds[abilityName]
					local numAbilityIds = #allAbilityIds
					if 0 < numAbilityIds then
						for triggerIndex=1, numAbilityIds do
							local curAbilityId = allAbilityIds[triggerIndex]
							aura:AttachEvent(eventCode, curAbilityId, triggerIndex, effectiveTriggerType)

						end
					end

				end
				-- special case for buff/debuff (trigger type = 1):
				if 1 == effectiveTriggerType and 2 == triggers[triggerIndex].unitTag then
					-- tracking on targets additionally needs EVENT_RETICLE_TARGET_CHANGED (id: 131118)!
								   --  ||
								   --  VV
					aura:AttachEvent(131118, abilityId, triggerIndex, effectiveTriggerType)
				end
			end
			

		end
	end
end

function AuraMastery:DetachEventsFromAuras(auraName)
	local aura = self.aura[auraName]
	self.aura[auraName].data.attachedEvents = {}
end

function AuraMastery:ControlSetSetState(controlSetParent, enabled)
	controlSetParent.state = enabled
end


--
-- Registration
--
		
function AuraMastery:RegisterAbilityIds(auraName)
	local actionResults, actionResultId
	local customDurationAllowed
	local activated = AuraMastery.svars.auraData[auraName].loaded
	if activated then	-- only register active auras' ability ids
		local triggers = self.svars.auraData[auraName].triggers
	
		for i = 1, #triggers do	
			local triggerType = triggers[i].triggerType
			
			-- regular triggers
			if 3 ~= triggerType then
				local eventType = self.codes.eventTypesByTriggerTypes[triggerType]
				local abilityId = triggers[i].spellId
				local customDuration = triggers[i].duration
				local customDurationAllowed = 4 == triggerType or 2 == triggerType

				if 4 == triggerType then
					actionResults = triggers[i].actionResults
				end	

				local checkAll = self.svars.auraData[auraName].triggers[i].checkAll
				if (checkAll) then	-- add all ability ids, that belong to the ability provided
					local spellName = GetAbilityName(abilityId)				
					local allAbilityIds = self:GetAllAbilityIdsByAbilityName(spellName)
					self.abilityIds[spellName] = allAbilityIds
					local numAbilityIds = #allAbilityIds
					if 0 < numAbilityIds then
						for i=1, #allAbilityIds do
							self:AddAbilityId(allAbilityIds[i], eventType, auraName)
							if actionResults then
								for j=1, #actionResults do
									local actionResultId = actionResults[j]
									self:AddActionResultId(allAbilityIds[i], eventType, actionResultId, auraName)
								end
							end
							if customDuration and customDurationAllowed then
								self:RegisterCustomDuration(allAbilityIds[i], eventType, auraName, customDuration)
							end
						end
					end
				else	-- only add the ability id provided																					
					self:AddAbilityId(abilityId, eventType, auraName)
					if actionResults then
						for i=1, #actionResults do
							local actionResultId = actionResults[i]
							self:AddActionResultId(abilityId, eventType, actionResultId, auraName)
						end
					end
					if customDuration and customDurationAllowed then
						self:RegisterCustomDuration(abilityId, eventType, auraName, customDuration)
					end
				end
				self:ReregisterForEvents(eventType)
			else

				-- trigger type is = 3 (custom trigger + custom untrigger)
				local customTriggerType = triggers[i].customTriggerData.eventType
				local customTriggerEventType = self.G.eventTypesByIndex[customTriggerType]
				local customTriggerAbilityId = triggers[i].customTriggerData.abilityId

				self:AddAbilityId(customTriggerAbilityId, customTriggerEventType, auraName)

				-- if the triggering trigger type is of type _COMBAT_EVENT it needs action results to be registered or it won't call the updating function OnEvent!
				if 3 == customTriggerType then
					local customTriggerActionResults = triggers[i].customTriggerData.actionResults
					if customTriggerActionResults then
						for i=1, #customTriggerActionResults do
							local customTriggerActionResultId = customTriggerActionResults[i]
							self:AddActionResultId(customTriggerAbilityId, customTriggerEventType, customTriggerActionResultId, auraName)
						end				
					end
				end

				local customUntriggerType = triggers[i].customUntriggerData.eventType	
				local customUntriggerEventType = self.G.eventTypesByIndex[customUntriggerType]
				local customUntriggerAbilityId = triggers[i].customUntriggerData.abilityId
			
				self:AddAbilityId(customUntriggerAbilityId, customUntriggerEventType, auraName)
				
				-- if the triggering trigger type is of type _COMBAT_EVENT it needs action results to be registered or it won't call the updating function OnEvent!
				if 3 == customUntriggerType then
					local customUntriggerActionResults = triggers[i].customUntriggerData.actionResults
					if customUntriggerActionResults then
						for i=1, #customUntriggerActionResults do
							local customUntriggerActionResultId = customUntriggerActionResults[i]
							self:AddActionResultId(customUntriggerAbilityId, customUntriggerEventType, customUntriggerActionResultId, auraName)
						end				
					end
				end				

				self:ReregisterForEvents(customTriggerEventType)
				self:ReregisterForEvents(customUntriggerEventType)
			end
			
		end
	end
end

function AuraMastery:UnregisterAbilityIds(auraName)
	local trackedEventsData = self.trackedEvents
	for eventId, _ in pairs(trackedEventsData) do
		-- unregister abilityIds for all events
		local trackedEvents = AuraMastery.trackedEvents[eventId]['abilityIds']

		-- (1) ability Ids
		for abilityId, auraNamesData in pairs(trackedEvents) do
			
			-- (1.1) unregister ability Ids
			for i=1, #auraNamesData do
				if auraName == auraNamesData[i] then
					table.remove(AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId], i)
--d("Removing "..abilityId.." for aura \""..eventAuraName.."\" from event \""..eventId.."\".")
					--self.aura[auraName]:DetachEvent(eventId, abilityId)
					if 0 == #AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] then
						AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] = nil	-- remove the whole abilityId if no aura is listening to it anymore
--d("Entirely removing "..abilityId.." from event \""..eventId.."\".")
					end
				end
			end
			
			-- (1.2) unregister action results for combat events
			if EVENT_COMBAT_EVENT == eventId then
				self:UnregisterTrackedActionResults(auraName)		
			end
		end
		
		-- (2) custom durations
		trackedEvents = self.trackedEvents[eventId]['custom']
		
		-- not all tracked events allow custom durations (e.g. effect events)
		if trackedEvents then
			for abilityId, auraCustomDurationsData in pairs(trackedEvents) do

				if auraCustomDurationsData[auraName] then
					self.trackedEvents[eventId]['custom'][abilityId][auraName] = nil
				end

				if AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] and 0 == #AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] then
					AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] = nil	-- remove the whole abilityId if no aura is listening to it anymore
--d("Entirely removing "..abilityId.." from event \""..eventId.."\".")
				end
			end		
		end
	end
end

function AuraMastery:RegisterCustomDuration(abilityId, eventId, auraName, customDuration)
	if nil == self.trackedEvents[eventId].custom[abilityId] then self.trackedEvents[eventId].custom[abilityId] = {}; end	-- create table for ability if neccessary
	self.trackedEvents[eventId].custom[abilityId][auraName] = customDuration
	if nil == self.activeCustomDurations[eventId][auraName] then self.activeCustomDurations[eventId][auraName] = {}; end
	self.activeCustomDurations[eventId][auraName][abilityId] = {}
end

function AuraMastery:AddAbilityId(abilityId, eventId, auraName)
	local aura = self.aura[auraName]
	if nil == AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] then AuraMastery.trackedEvents[eventId]['abilityIds'][abilityId] = {}; end
	local trackedEventsData = self.trackedEvents[eventId]['abilityIds'][abilityId]
	if not table.contains(trackedEventsData, auraName) then
		table.insert(self.trackedEvents[eventId]['abilityIds'][abilityId], auraName)
	end
end

function AuraMastery:AddActionResultId(abilityId, eventId, actionResultId, auraName)
--deb("Trying to add actionResult "..actionResultId.." for event "..eventId.."("..auraName..":"..abilityId..")")

	if nil == AuraMastery.trackedEvents[eventId]['actionResults'][abilityId] then AuraMastery.trackedEvents[eventId]['actionResults'][abilityId] = {}; end
--deb("Adding abilityId "..abilityId.." for aura "..auraName.." to actionResults.")
	if nil == AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId] then AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId] = {}; end
--deb("Adding actionResultId "..actionResultId.." for "..abilityId.." for aura "..auraName.." to actionResults.")
	if not table.contains(AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId], auraName) then
--deb("Inserting actionResult for aura "..auraName..".")
		table.insert(self.trackedEvents[eventId]['actionResults'][abilityId][actionResultId], auraName)
	end
end

function AuraMastery:UnregisterTrackedActionResults(auraName)
	local eventId = EVENT_COMBAT_EVENT
	local trackedEvents = AuraMastery.trackedEvents[eventId]['actionResults']
	local next = next

	for abilityId, _ in pairs(trackedEvents) do
		for actionResultId, auraNamesData in pairs(trackedEvents[abilityId]) do
			for i=1, #auraNamesData do
				if auraName == auraNamesData[i] then
--deb("Removing aura "..AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId][i].." from actionResults ("..actionResultId..") for abilityId "..abilityId)
					table.remove(AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId], i)
					if 0 == #AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId] then
						AuraMastery.trackedEvents[eventId]['actionResults'][abilityId][actionResultId] = nil		-- remove the whole action result if no aura is listening to it anymore
					end
				end
			end
		end
		if not next(trackedEvents[abilityId]) then
			AuraMastery.trackedEvents[eventId]['actionResults'][abilityId] = nil -- remove the whole ability id if no aura is listening to it anymore
--deb("Entirely removing abilityId "..abilityId.." from actionResults for aura "..auraName)
		end
	end
end

function AuraMastery:GetPlayerCombatState()
	return self.playerCombatState
end

function AuraMastery:CheckLoadingConditions(auraName)
    -- d("[AuraMastery] Checking loading conditions for aura: " .. auraName)

    local loadingConditions = self.svars.auraData[auraName].loadingConditions
    for loadingConditionType, loadingConditionData in pairs(loadingConditions) do
        -- d("[AuraMastery] Checking condition type: " .. loadingConditionType)

        local result = self:CheckLoadingCondition(loadingConditionType, loadingConditionData)
        
        if result then
            -- d("[AuraMastery] Condition " .. loadingConditionType .. " PASSED for aura: " .. auraName)
        else
            -- d("[AuraMastery] Condition " .. loadingConditionType .. " FAILED for aura: " .. auraName)
            return false
        end
    end
    -- d("[AuraMastery] All conditions PASSED for aura: " .. auraName)
    return true
end


function AuraMastery:CheckLoadingCondition(loadingConditionType, loadingConditionData)
	-- in combat
	if "inCombatOnly" == loadingConditionType then
		if false == loadingConditionData then return true; end
		local isPlayerInCombat = self:GetPlayerCombatState()
		if isPlayerInCombat then
			return true
		end
	
	-- aura requires a specific ability to be sloted in one of both action bars
	elseif "abilitiesSloted" == loadingConditionType then
		local numAbilities = #loadingConditionData
		if 0 < numAbilities then
			local abilityId
			for i=1, numAbilities do
				abilityId = loadingConditionData[i]
				if not self:IsAbilitySloted(abilityId) then
					return false
				end
			end
		end
		return true
	end
	return false
end

function AuraMastery:UpdateAuraLoadingState(auraName)
	local loadAura = self:CheckLoadingConditions(auraName)
	if loadAura then
		self:LoadAura(auraName)
	else
		self:UnloadAura(auraName)
	end
end

function AuraMastery:LoadAura(auraName)

	local mode = self:GetMode()
	if 2 == mode then
		self.aura[auraName]:EnterEditMode()
	end
	
	--
	-- If the edit aura menu is loaded, do not load any auras anymore (also see functions.lua, updateHandler() and  UpdateAffectedAuras())
	--	
	if 1 ~= mode then return; end
	
	if self.svars.auraData[auraName].loaded and not(self:GetLoadedAuraByName(auraName)) and (nil == self.svars.auraData[auraName].loadingConditions or self:CheckLoadingConditions(auraName)) then
		table.insert(self.loadedAuras, auraName)
		local aura = self.aura[auraName]
		local conditionsMet = aura:CheckTriggersBaseconditionsMet()
		if conditionsMet then		
			aura:Trigger()
		end
	end

end

function AuraMastery:UnloadAura(auraName)
	local auraIndex = self:GetLoadedAuraByName(auraName)
	if (auraIndex) then
		local aura = self.aura[auraName]
		aura:Untrigger()
		WM:GetControlByName(auraName):SetHidden(true)
		table.remove(self.loadedAuras, auraIndex)
	end
end

function AuraMastery:GetLoadedAuraByName(auraName)
	local numLoadedAuras = #self.loadedAuras
	for index=1, numLoadedAuras do
		if (self.loadedAuras[index] == auraName) then
			local aura = self.loadedAuras[index]
			return index
		end
	end
	return false
end

function AuraMastery:LoadAllAuras()
	local auras = self.aura
	for auraName, _ in pairs(auras) do
		self:LoadAura(auraName)
	end
end

function AuraMastery:UnloadAllAuras()
	local auras = self.aura
	for auraName, _ in pairs(auras) do
		self:UnloadAura(auraName)
	end
end

function AuraMastery:ReloadAllAuraControls()
	local auras = self.aura
	for auraName, _ in pairs(auras) do
		self:ReloadAuraControl(auraName)
	end
end