local WM = WINDOW_MANAGER

local SER = LibStub:GetLibrary("AceSerializer-3.0")
local LAM = LibStub("LibAddonMenu-2.0")

local C_PASS = {0,.75,0}
local C_ERR  = {1,0,0}

AM_CONTROL_STATE_ENABLED = 1
AM_CONTROL_STATE_DISABLED = 2

function AuraMastery:Edit_SetActiveAura(auraName)
	self.activeAura = auraName
end

function AuraMastery:Edit_GetActiveAura()
	return self.activeAura
end

function AuraMastery:Edit_GetActiveTrigger()
	return self.activeTrigger
end

-- Aura menu
function AuraMastery:CreateMenu()
	self:CreateAurasList()

	local parent = WM:GetControlByName("AuraMasteryMenuContainer");
	local button = WM:CreateControl("AuraMasteryMenuCloseButton", parent, CT_BUTTON);
	button:SetDimensions(24,24);
	button:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -5, 5);
	button:SetClickSound('Click')
	button:SetNormalTexture("/esoui/art/buttons/decline_up.dds")
	button:SetMouseOverTexture("/esoui/art/buttons/decline_over.dds")
	button:SetPressedTexture("/esoui/art/buttons/decline_down.dds")
	button:SetHandler("OnClicked", AuraMastery.UnloadMainMenu)
	self:CreateMenuControls()
	AuraMasteryDisplayMenu_AuraNameSubControl_Editbox:SetMaxInputChars(20)
end

function AuraMastery:CreateMenuControls()
	for k,v in pairs(AuraMastery.controls.settings) do
		local control = WM:CreateControlFromVirtual(v['controlName'], auraMasteryControlPoolStorage, v['virtualName'])
		if nil ~= v['dimensions'] then
			control:SetDimensions(v['dimensions'][1], v['dimensions'][2])
		end
		control:GetNamedChild("_Label"):SetText(v['label'])

		-- init subcontrol
		if v['subControl'] then
			local subControl = WM:CreateControlFromVirtual(v['subControl']['controlName'], control, v['subControl']['virtualName'])
			if v['subControl']['dimensions'] then
				subControl:SetDimensions(v['subControl']['dimensions'][1], v['subControl']['dimensions'][2])
			end
			subControl:ClearAnchors()
			subControl:SetAnchor(RIGHT, control, RIGHT, -4)

			-- setup a tooltip for the subcontrol
			if v['subControl']['tooltipText'] then

				-- tooltip text
				subControl.data = { tooltipText = v['subControl']['tooltipText']}

				-- tooltip handlers
				subControl:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
				subControl:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)
			end
				
			-- subcontrol is a comboBox
--[[			if (subControl.m_comboBox) then
				local m_comboBox = subControl.m_comboBox
				local itemSelectCallback = v['subControl']['callback']
				local passedItems = v['subControl']['items']
				local itemIndex = 1
				local items = {}
				for itemInternalValue, itemName in pairs(passedItems) do
					items[itemIndex] = {name = itemName, callback = itemSelectCallback, internalValue = itemInternalValue}
					itemIndex = itemIndex+1
				end
				m_comboBox:SetSortsItems(false)
				m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
				AuraMastery:PopulateComboBoxCustom(m_comboBox, items, itemSelectCallback)
			end]]

			-- subcontrol is a checkButton
			--if "AM_CheckButton" == v['subControl']['virtualName'] then
				--local callbackFunc = v['subControl']['callback']
				--ZO_CheckButton_SetToggleFunction(subControl, callbackFunc)
			--end
			
			--subcontrol is an editbox or a textBox
			--if "AM_EditBox" == v['subControl']['virtualName'] or "AM_TextBox" == v['subControl']['virtualName'] then
				--local callback = v['subControl']['callback']
				--local editbox = subControl:GetNamedChild("_Editbox")
				--editbox:SetHandler("OnEnter", function() v['subControl']['callback'](editbox) end)
			--end
			
			-- subcontrol is a switch
			--if "AM_Switch" == v['subControl']['virtualName'] then
				--local callback = v['subControl']['callback']
				--subControl:SetHandler("OnClicked", callback)
			--end
			
			if v['subControl']['initHandler'] then
				v['subControl']['initHandler']()
			end

			control.subControl = subControl
		end
		self.controls.pool[k] = control
	end

	self:CreateActionResultsList()
	self:InitCustomTriggerActionResultsScrollList()
	self:InitCustomUntriggerActionResultsScrollList()
	self:CreateIconSelect()
	self:CreateAuraGroupAssignment()
	self:CreateCooldownFontColorSelect()
	self:CreateTextFontColorSelect()
	self:CreateBorderColorSelect()
	self:CreateBackgroundColorSelect()
	self:CreateBarColorSelect()
	self:CreateAnimationColorColorSelect()
end

function AuraMastery:PopulateComboBox(m_comboBox, itemData, callback)
	m_comboBox:ClearItems()
 
	--===============================================================--
	--====== Population Code  ============--
	--===============================================================--

	for k,name in ipairs(itemData) do
		local itemEntry = m_comboBox:CreateItemEntry(name, callback)
		
		-- suppress update until were done adding items
		m_comboBox:AddItem(itemEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	--===============================================================--

	-- Update & select first item
	m_comboBox:UpdateItems()
	--m_comboBox:SelectFirstItem(true) -- ignore callback on first load = true
	--m_comboBox:SelectItemByIndex(preSelectionIndex, true)
 end

function AuraMastery:PopulateComboBoxCustom(m_comboBox, itemData, callback)
	m_comboBox:ClearItems()
	for k,itemData in ipairs(itemData) do
		-- suppress update until were done adding items
		m_comboBox:AddItem(itemData, ZO_COMBOBOX_SUPRESS_UPDATE)
	end
	m_comboBox:UpdateItems()
	--m_comboBox:SelectFirstItem(true) -- ignore callback on first load = true
	--m_comboBox:SelectItemByIndex(preSelectionIndex, true)
 end

function AuraMastery:CreateAurasList()
	self:InitAurasScrollList()
	self:UpdateAurasScrollList()
	self:InitAurasGroupSelect()
	self:UpdateAurasGroupSelect()
end

function AuraMastery:CreateActionResultsList()
	self:InitActionResultsScrollList()
end

-- Aura list scrolllist
function AuraMastery:InitAurasScrollList()
	local function setupDataRow(rowControl, rowData, scrollList)
		local auraName = rowData['auraName']
		local icon = self.svars.auraData[auraName].iconPath
		
		local nameLabel = rowControl:GetNamedChild("_Label")
		local thumbnail = rowControl:GetNamedChild("_Thumbnail")
		local deleteButton = rowControl:GetNamedChild("_DeleteButton")
		local visibilityButton = rowControl:GetNamedChild("_VisibilityButton")
	
		local auraControl = WM:GetControlByName(auraName)
		if auraControl then
			local isAuraHidden = auraControl:IsHidden()

			if isAuraHidden then
				-- set button control to hidden symbol
				visibilityButton:SetNormalTexture("/esoui/art/tutorial/stealth-hidden.dds")
				visibilityButton:SetMouseOverTexture("/esoui/art/buttons/stealth-hidden.dds")
				visibilityButton:SetPressedTexture("/esoui/art/buttons/stealth-hidden.dds")		
			else
				-- set button control to not hidden symbol
				visibilityButton:SetNormalTexture("/esoui/art/tutorial/stealth-seen.dds")
				visibilityButton:SetMouseOverTexture("/esoui/art/buttons/stealth-seen.dds")
				visibilityButton:SetPressedTexture("/esoui/art/buttons/stealth-seen.dds")
			end
		end
		nameLabel:SetText(rowData['auraName'])
		thumbnail:SetTexture(icon)
		visibilityButton:SetHandler("OnClicked", function() AuraMastery:AM_Menu_SwitchVisibility(auraName, visibilityButton) end)
		deleteButton:SetHandler("OnClicked", function() AuraMastery:DeleteAura(auraName) end)
	end
	
	local parent = WM:GetControlByName("AuraMasteryMenuAuraListContainer")

	local height = parent:GetHeight()-140
	local control = WM:CreateControlFromVirtual("AM_ScrollList", parent, "ZO_ScrollList")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 140)
	control:SetDimensions(292, height)

	backdrop = WM:CreateControl("$(parent)_Backdrop", control, CT_BACKDROP)
	backdrop:SetAnchorFill()
	backdrop:SetCenterColor(0,0,0,0)
	backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
	backdrop:SetEdgeColor(0,0,0)
	
	ZO_ScrollList_AddDataType(control, 1, "AM_ScrollListRowElement", 30, setupDataRow)
	ZO_ScrollList_SetTypeSelectable(control, 1, true)
	
	ZO_ScrollList_SetDeselectOnReselect(control, false)
	ZO_ScrollList_EnableSelection(control, "ZO_ThinListHighlight", AuraMastery.OnAurasScrollListSelectionChanged)
	ZO_ScrollList_EnableHighlight(control, "ZO_ThinListHighlight")
end

function AuraMastery.OnAurasScrollListSelectionChanged(previouslySelectedData, selectedData, selectingDuringRebuild)
	-- selectedData will be nil if the control is already selected...
	if selectedData then
		local auraName = selectedData.auraName
		AuraMastery:LoadAuraMenu(auraName)	
	end
end

-- Action results scrolllist
function AuraMastery:InitActionResultsScrollList()

	local function setupDataRow(rowControl, rowData, scrollList)
		local nameLabel = rowControl:GetNamedChild("_Label")
		local actionResultName = rowData['actionResultName']
		local actionResultCode = rowData['actionResultCode']
		local actionResultState = tostring(rowData['actionResultState'])

		local control = rowControl
		nameLabel:SetText(actionResultName)
				
		local button = rowControl:GetNamedChild("_Switch")
		button:SetHandler("OnClicked", AuraMastery.EditTriggerEventDamage)
		
		local textColor = "On" == actionResultState and {0,1,0} or {1,0,0}
		
		local buttonLabel = button:GetNamedChild("_Label")
		buttonLabel:SetText(actionResultState)
		buttonLabel:SetColor(textColor[1], textColor[2], textColor[3])
		
		control.actionResultCode = actionResultCode
	end
	
	local parent = WM:GetControlByName("AuraMasteryTriggerEventsWindow")
	local width = parent:GetWidth()
	local height = parent:GetHeight()-36
	local control = WM:CreateControlFromVirtual("AM_ActionResultsScrollList", parent, "ZO_ScrollList")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 36)
	control:SetDimensions(width, height)
	ZO_ScrollList_AddDataType(control, 1, "AM_ActionResultsListRowElement", 30, setupDataRow)
end

-- Action results scrolllist
function AuraMastery:InitCustomTriggerActionResultsScrollList()

	local function setupDataRow(rowControl, rowData, scrollList)
		local nameLabel = rowControl:GetNamedChild("_Label")
		local actionResultName = rowData['actionResultName']
		local actionResultCode = rowData['actionResultCode']
		local actionResultState = tostring(rowData['actionResultState'])

		local control = rowControl
		nameLabel:SetText(actionResultName)
				
		local button = rowControl:GetNamedChild("_Switch")
		button:SetHandler("OnClicked", AuraMastery.EditCustomTriggerActionResult)
		
		local textColor = "On" == actionResultState and {0,1,0} or {1,0,0}
		
		local buttonLabel = button:GetNamedChild("_Label")
		buttonLabel:SetText(actionResultState)
		buttonLabel:SetColor(textColor[1], textColor[2], textColor[3])
		
		control.actionResultCode = actionResultCode
	end
	
	local parent = WM:GetControlByName("AuraMasteryCustomTriggerActionResultsWindow")
	local width = parent:GetWidth()
	local height = parent:GetHeight()-36
	local control = WM:CreateControlFromVirtual("AM_CustomTriggerActionResultsScrollList", parent, "ZO_ScrollList")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 36)
	control:SetDimensions(width, height)
	ZO_ScrollList_AddDataType(control, 1, "AM_ActionResultsListRowElement", 30, setupDataRow)
end

function AuraMastery:InitCustomUntriggerActionResultsScrollList()

	local function setupDataRow(rowControl, rowData, scrollList)
		local nameLabel = rowControl:GetNamedChild("_Label")
		local actionResultName = rowData['actionResultName']
		local actionResultCode = rowData['actionResultCode']
		local actionResultState = tostring(rowData['actionResultState'])

		local control = rowControl
		nameLabel:SetText(actionResultName)
				
		local button = rowControl:GetNamedChild("_Switch")
		button:SetHandler("OnClicked", AuraMastery.EditCustomUntriggerActionResult)
		
		local textColor = "On" == actionResultState and {0,1,0} or {1,0,0}
		
		local buttonLabel = button:GetNamedChild("_Label")
		buttonLabel:SetText(actionResultState)
		buttonLabel:SetColor(textColor[1], textColor[2], textColor[3])
		
		control.actionResultCode = actionResultCode
	end
	
	local parent = WM:GetControlByName("AuraMasteryCustomUntriggerActionResultsWindow")
	local width = parent:GetWidth()
	local height = parent:GetHeight()-36
	local control = WM:CreateControlFromVirtual("AM_CustomUntriggerActionResultsScrollList", parent, "ZO_ScrollList")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 36)
	control:SetDimensions(width, height)
	ZO_ScrollList_AddDataType(control, 1, "AM_ActionResultsListRowElement", 30, setupDataRow)
end

-- Trigger actions
function AuraMastery:InitTriggerSoundsComboBox()
	-- local control = WM:GetControlByName("AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_TriggerActions_ScrollableComboBox")
	local control = WM:GetControlByName("AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_TriggerActions_ComboBox")
	local m_comboBox = control.m_comboBox
	local itemSelectCallback = AuraMastery.TriggerSoundSelectCallback
	local index = 1
	local items = {}
	table.insert(items, {name = "AA_NONE", callback = itemSelectCallback, internalValue = index})
	for _, soundName in pairs(SOUNDS) do
		index = index+1
		items[index] = {name = soundName, callback = itemSelectCallback, internalValue = index}
	end
	control.items = items
	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	
	--AuraMastery.UpdateTriggerSoundSelect()
end

function AuraMastery:InitUntriggerSoundsComboBox()
	-- local control = WM:GetControlByName("AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_UntriggerActions_ScrollableComboBox")
	local control = WM:GetControlByName("AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_UntriggerActions_ComboBox")
	local m_comboBox = control.m_comboBox
	local itemSelectCallback = AuraMastery.UntriggerSoundSelectCallback
	local index = 1
	local items = {}
	table.insert(items, {name = "AA_NONE", callback = itemSelectCallback, internalValue = index})
	for _, soundName in pairs(SOUNDS) do
		index = index+1
		items[index] = {name = soundName, callback = itemSelectCallback, internalValue = index}
	end
	control.items = items
	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	
	--AuraMastery.UpdateUntriggerSoundSelect()
end

function AuraMastery:SetAuraButtonState(control, state)
	if not control then return; end
	local scrollList = WM:GetControlByName("AM_ScrollList") -- remember: every #userData control is registered in ESO's globals!
	local scrollListRows = scrollList.data

	if 1 == state then
		-- browse through all scroll list rows and set them to inactive
		for i=1, #scrollListRows do
			local rowControl = scrollListRows[i].control
			rowControl:SetState(0)
		end
	end
	
	-- set the clicked row entry's button to active
	control:SetState(state)
end

function AuraMastery:LoadNewAuraMenu()
	WM:GetControlByName("AuraMasteryMenu_EditAura"):SetHidden(true)
	WM:GetControlByName("AuraMasteryImportWindow"):SetHidden(true)
	WM:GetControlByName("AuraMasteryTriggerSettingsContainer"):SetHidden(true)
	WM:GetControlByName("NotificationDisplay"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_EditAuraGroups"):SetHidden(true)
	
	WM:GetControlByName("AuraMasteryMenu_NewAura"):SetHidden(false)
	self:CloseAllSubmenuPanels()
end

function AuraMastery:LoadImportAuraMenu()
	WM:GetControlByName("AuraMasteryMenu_EditAura"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_NewAura"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_EditAuraGroups"):SetHidden(true)
	
	WM:GetControlByName("AuraMasteryImportWindow"):SetHidden(false)
end

function AuraMastery:LoadAuraGroupsMenu()
	WM:GetControlByName("AuraMasteryMenu_EditAura"):SetHidden(true)
	WM:GetControlByName("AuraMasteryImportWindow"):SetHidden(true)
	WM:GetControlByName("AuraMasteryTriggerSettingsContainer"):SetHidden(true)
	WM:GetControlByName("NotificationDisplay"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_NewAura"):SetHidden(true)
	
	WM:GetControlByName("AuraMasteryMenu_EditAuraGroups"):SetHidden(false)
	self:CloseAllSubmenuPanels()
	AuraMastery:UpdateAuraGroupsScrollList()
end

function AuraMastery:LoadMainMenu()
	AuraMastery:SetMode(AM_MODE_EDIT)
	self:UnloadAllAuras()
	
	--
	-- This is neccessary for auras not to activate after closing the menu
	-- (retriggering after closing the menu currently works fine with auras that have no custom duration,
	--  but custom duration auras are too complicated to retrigger after closing the menu)
	--
	self:ClearAllCombatData()
	
	--
	-- Leave edit mode for all other auras
	-- and set all auras alpha to 25%
	--
	for auraName, auraObj in pairs(self.aura) do
		auraObj.control:SetAlpha(0.25)
		auraObj.control:SetHidden(false)
	end
	self:UpdateAurasScrollList()
	SetGameCameraUIMode(true)
	local AMMainMenu = WM:GetControlByName("AuraMasteryMenuContainer")
	AMMainMenu:SetHidden(false)
end

function AuraMastery.UnloadMainMenu()
	AuraMastery:SetMode(AM_MODE_NORMAL)
	local AMMainMenu = WM:GetControlByName("AuraMasteryMenuContainer")
	AMMainMenu:SetHidden(true)
	for auraName, auraObj in pairs(AuraMastery.aura) do
		auraObj:LeaveEditMode()
	end
	AuraMastery:ReloadAllAuraControls()
end

function AuraMastery:ClearAllCombatData()
	-- buffs / debuffs
	AuraMastery.activeEffects	 	 	= {}

	-- ground effects
	AuraMastery.activeFakeEffects  		= {}

	-- effects on current target
	AuraMastery.ROActiveEffects 	 	= {}

	-- combat effects
	AuraMastery.activeCombatEffects 	= {}

	-- all effects that have user specified durations
	AuraMastery.activeCustomDurations 	= {
		[EVENT_COMBAT_EVENT] = {},
		[EVENT_ACTION_SLOT_ABILITY_USED] = {}
	}
end

function AuraMastery:LoadEditAuraMenu()
	WM:GetControlByName("AuraMasteryMenu_NewAura"):SetHidden(true)
	WM:GetControlByName("AuraMasteryImportWindow"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_EditAura"):SetHidden(false)
	WM:GetControlByName("AuraMasteryTriggerEventsWindow"):SetHidden(true)
	WM:GetControlByName("AuraMasteryAuraActionsWindow"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_EditAuraGroups"):SetHidden(true)
	WM:GetControlByName("AuraMasteryAuraTextWindow"):SetHidden(true)
end

function AuraMastery:LoadAuraMenu(auraName)
	AuraMasteryMenu_NewAura:SetHidden(true)
	AuraMasteryMenu_EditAura:SetHidden(false)
	AuraMasteryMenu_EditAuraGroups:SetHidden(true)
	AuraMasteryTriggerSettingsContainer:SetHidden(true)
	NotificationDisplay:SetHidden(true)
	self:CloseAllSubmenuPanels()
	
	if not auraName then d("Critical Error: No aura data passed."); return; end
	
	
	local activeAura = self:Edit_GetActiveAura()
	local activeAuraObj
	
	if activeAura then
		activeAuraObj = self.aura[activeAura]
		activeAuraObj:LeaveEditMode()
	end
	
	self:Edit_SetActiveAura(auraName)
	self.activeAuraType = self.svars.auraData[auraName].aType
	activeAuraObj = self.aura[auraName]
	
	self:UpdateDisplaySettingsMenu()
	self:UpdateAuraGroupAssignment()
	self:UpdateTriggerSelect()
	self:UpdateDurationInfoSelect()
	self:UpdateIconInfoSelect()
	self:UpdateTriggerSoundSelect()
	self:UpdateUntriggerSoundSelect()
	
	self:UpdateTriggerAnimationSettingsMenu()
	
	self:UpdateLoadingConditionsSettingsMenu()
	activeAuraObj:EnterEditMode()
end

function AuraMastery:NewIcon(data)

	local default = {
		name = "New Icon",
		aType = 1,
		critical = 3,
		width 	= 64,
		height	= 64,
		alpha		= 1,
		color		= {
			r=0,
			g=0,
			b=0
		},
		borderSize = 1,
		borderColor = {
			r=0,
			g=0,
			b=0,
			a=1,
		},
		bgColor = {
			r=1,
			g=1,
			b=1,
			a=0,
		},
		posX = 0,
		posY = 0,
		cooldownFontSize = 20,
		cooldownFontColor = {
			r=.85,
			g=.85,
			b=.55,
			a=1,
		},
		textFontSize = 20,
		textFontColor = {
			r=.85,
			g=.85,
			b=.55,
			a=1,
		},
		iconPath = "",
		showCooldownAnimation = true,
		showCooldownText = true,
		loaded = true,
		triggers = {
		},
		loadingConditions = {
			inCombatOnly = false,
			abilitiesSloted = {}
		}
	}

	if not data then data = default; end
 
	self.activeAura = nil;


	self.counter	= 0
	self.ATN		= data.name and data.name or "New Icon"
	self.finalName = nil
	self:CheckNewName()
	local auraName = self.finalName
	
	local parent = WM:GetControlByName("AuraMasteryMenuAuraListContainer");
	local i = self:GetNumElements(self.svars.auraData);

	self:CreateNewAura(auraName, data)
	self.activeAura = auraName
	self:UpdateAurasScrollList()
	
	local auraListElementControl = self:GetAuraListControlByAuraName(auraName)
end

function AuraMastery:GetAuraListControlByAuraName(auraName)
	local dataList = ZO_ScrollList_GetDataList(AM_ScrollList)
	for i=1, #dataList do
		local dataListAuraName = dataList[i].data.auraName
		if auraName == dataListAuraName then
			return dataList[i].control
		end
	end
end

function AuraMastery:NewProgressBar(data)
	local default = {
		name = "New Progress Bar",
		aType = 2,
		critical = 3,
		width 	= 128,
		height	= 28,
		alpha		= 1,
		color		= {
			r=0,
			g=0,
			b=0
		},
		cooldownFontColor = {
			r=.85,
			g=.85,
			b=.55,
			a=1
		},
		borderSize = 1,
		borderColor = {
			r=0,
			g=0,
			b=0,
			a=1
		},
		bgColor = {
			r=0,
			g=0,
			b=0,
			a=.5
		},
		barColor = {
			r=1,
			g=1,
			b=1,
			a=1
		},
		posX = 0,
		posY = 0,
		cooldownFontSize = 20,
		iconPath = "",
		loaded = true,
		triggers = {
		},
		loadingConditions = {
			inCombatOnly = false,
			abilitiesSloted = {}
		}
	}

	if nil == data then data = default; end
 
	self.activeAura = nil


	self.counter	= 0
	self.ATN			= data.name and data.name or "New Progress Bar"
	self.finalName = nil
	self:CheckNewName()
	local auraName = self.finalName
	
	local parent = WM:GetControlByName("AuraMasteryMenuAuraListContainer")
	local i = self:GetNumElements(self.svars.auraData)
	self:CreateNewAura(auraName, data)
	self.activeAura = auraName
	self:UpdateAurasScrollList()
end

function AuraMastery:NewTexture(data)

end

function AuraMastery:NewText(data)

	local default = {
		name = "New Text",
		aType = 4,
		critical = 3,
		width 	= 64,
		height	= 64,
		alpha		= 1,
		color		= {
			r=0,
			g=0,
			b=0
		},
		textFontColor = {
			r=.85,
			g=.85,
			b=.55,
			a=1,
		},
		posX = 0,
		posY = 0,
		textFontSize = 40,
		text = "Text...",
		loaded = true,
		triggers = {
		},
		loadingConditions = {
			inCombatOnly = false,
			abilitiesSloted = {}
		}
	}

	if nil == data then data = default; end

	self.activeAura = nil

	self.counter	= 0
	self.ATN			= data.name and data.name or "New Text"
	self.finalName = nil
	self:CheckNewName()
	local auraName = self.finalName
	
	local parent = WM:GetControlByName("AuraMasteryMenuAuraListContainer")
	local i = self:GetNumElements(self.svars.auraData)

	self:CreateNewAura(auraName, data)
	self.activeAura = auraName
	self:UpdateAurasScrollList()
end

function AuraMastery:CheckNewName()
	local free = true
	local testname = (0 == AuraMastery.counter and AuraMastery.ATN) or self.ATN.." ("..self.counter..")"
	for k, v in pairs(self.svars.auraData) do
		if (k == testname) then
			self.counter = self.counter+1
			free = false
			self:CheckNewName()
			break
		end
	end
	if free then self.finalName = testname; end -- DEBUGGING: self.counter = 0 setzen? (wird eigentlich schon in NewIcon() gemacht)
end

function AuraMastery:CreateNewAura(auraName, data)
	self.svars.auraData[auraName] = data
	self:CreateAuraControl(auraName)
	self:LoadAura(auraName)
end

function AuraMastery:AM_Menu_SwitchVisibility(auraName, buttonControl)
	local aura = WM:GetControlByName(auraName)
	local isHidden = aura:IsHidden()
	
	if isHidden then
		-- hide aura
		aura:SetHidden(false)

		-- set button control to not hidden symbol
		buttonControl:SetNormalTexture("/esoui/art/tutorial/stealth-seen.dds")
		buttonControl:SetMouseOverTexture("/esoui/art/buttons/stealth-seen.dds")
		buttonControl:SetPressedTexture("/esoui/art/buttons/stealth-seen.dds")
	else
		-- show
		aura:SetHidden(true)
		
		-- set button control to hidden symbol
		buttonControl:SetNormalTexture("/esoui/art/tutorial/stealth-hidden.dds")
		buttonControl:SetMouseOverTexture("/esoui/art/buttons/stealth-hidden.dds")
		buttonControl:SetPressedTexture("/esoui/art/buttons/stealth-hidden.dds")
	end

end

function AuraMastery:DeleteAura(auraName)
	self:UnloadAura(auraName)
	self:RemoveAuraFromAuraGroups(auraName)
	self:RemoveAuraControl(auraName)
	self:RemoveAuraData(auraName)
	self.activeAura = nil
	WM:GetControlByName("AuraMasteryMenu_NewAura"):SetHidden(true)
	WM:GetControlByName("AuraMasteryMenu_EditAura"):SetHidden(true)
	self:UpdateAurasScrollList()
	
	-- hide Anchor
	local genericAnchorControl = WM:GetControlByName("AM_GenericAnchor")
	genericAnchorControl:SetHidden(true)
	genericAnchorControl:SetMouseEnabled(false)
	genericAnchorControl:SetMovable(false)
end

function AuraMastery:CreateDurationInfoSelect()

end

function AuraMastery:CreateNewTrigger()
	local auraName = self.activeAura
	local defaults = {
		['triggerType'] 	= 1,		-- buff/debuff
		['unitTag']			= 1,		-- player
		['invert']			= false,
		['checkAll']      = false,
		['spellId']       = 0,
		['operator']		= 2,		-- greater than
		['value']			= 0,
		['selfCast']		= false
	}
	table.insert(self.svars.auraData[auraName].triggers, defaults)
end

function AuraMastery:DeleteTrigger(auraName, triggerIndex)
	local auraName = (auraName and auraName) or self.activeAura
	local triggerIndex = (triggerIndex and triggerIndex) or self.activeTrigger

	table.remove(self.svars.auraData[auraName].triggers, triggerIndex);
	self.activeTrigger = nil
	WM:GetControlByName("AuraMasteryTriggerSettingsContainer"):SetHidden(true);
	self:UpdateTriggerSelect()
	self:ReloadAuraControl(auraName)
	self:UpdateIconInfoSelect()
	self:UpdateDurationInfoSelect()
end

function AuraMastery.IconInfoSelectCallback(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end	-- don't do anything if nothing changes
	local control = WM:GetControlByName("AuraMasteryDisplayMenu_IconSelect")
	local auraName = AuraMastery.activeAura
	local selectionIndex = item.internalValue

	if selectionIndex then
		-- set icon manually => activate icon selector
		local abilityId = AuraMastery.svars.auraData[auraName].triggers[selectionIndex].spellId
		local texturePath = GetAbilityIcon(abilityId)
		AuraMastery.EditAuraIcon(texturePath)
		AuraMastery.svars.auraData[auraName].iconInfoSource = selectionIndex
		WM:GetControlByName("AuraMasteryDisplayMenu_AuraIcon"):SetHidden(true)
	else
		AuraMastery.svars.auraData[auraName].iconInfoSource = nil
		WM:GetControlByName("AuraMasteryDisplayMenu_AuraIcon"):SetHidden(false)
	end
	AuraMastery:UpdateIconInfoSelect()
end

function AuraMastery.DurationInfoSelectCallback(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end	-- don't do anything if nothing changes
	local auraName = AuraMastery.activeAura
	local selectionIndex = item.internalValue
	if selectionIndex then
		AuraMastery.svars.auraData[auraName].durationInfoSource = selectionIndex
	else
		AuraMastery.svars.auraData[auraName].durationInfoSource = nil
	end
end

function AuraMastery.TriggerSoundSelectCallback(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end	-- don't do anything if nothing changes
	local auraName = AuraMastery.activeAura
	--local selectionIndex = item.internalValue
	if "AA_NONE" == itemText then
		AuraMastery.svars.auraData[auraName].triggerSound = nil
	else
		AuraMastery.svars.auraData[auraName].triggerSound = itemText
		PlaySound(itemText)
	end
end

function AuraMastery.UntriggerSoundSelectCallback(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end	-- don't do anything if nothing changes
	local auraName = AuraMastery.activeAura
	--local selectionIndex = item.internalValue
	if "AA_NONE" == itemText then
		AuraMastery.svars.auraData[auraName].untriggerSound = nil
	else
		AuraMastery.svars.auraData[auraName].untriggerSound = itemText
		PlaySound(itemText)
	end
end




--=====================================
-- Control Updates --------------------
--=====================================

--
-- Whole Menues
--
function AuraMastery:CloseAllSubmenuPanels()
	AuraMasteryExportWindow:SetHidden(true)
	AuraMasteryImportWindow:SetHidden(true)
	AuraMasteryTriggerEventsWindow:SetHidden(true)
	AuraMasteryAuraTextWindow:SetHidden(true)
	AuraMasteryCustomTriggerActionResultsWindow:SetHidden(true)
	AuraMasteryCustomUntriggerActionResultsWindow:SetHidden(true)
	AuraMasteryCustomTriggerWindow:SetHidden(true)
	AuraMasteryCustomUntriggerWindow:SetHidden(true)
	AuraMasteryAuraActionsWindow:SetHidden(true)
end

function AuraMastery:UpdateDisplaySettingsMenu()
	--
	-- Hide all other input controls
	--
	local control = DisplaySettingsDynamicControls -- container that contains all input controls for the trigger type that is currently active
	local children = {}
	for i = 1, control:GetNumChildren() do
		children[i] = control:GetChild(i)
	end
	for i=1, #children do
		children[i]:SetParent(AuraMasteryHiddenControls)
	end	

	local auraName 	= AuraMastery.activeAura
	local auraType 	= AuraMastery.activeAuraType
	local protoFields = AuraMastery.protoDisplay[auraType]
	
	local spaceHeight = 30
	local offset = 0
	for i=1, #protoFields do
		local poolName = protoFields[i]['poolName']
		local parentName = protoFields[i]['parentName']
		local anchor =	protoFields[i]['anchor']
		local relativeTo = protoFields[i]['relativeTo']
		local offsetX = protoFields[i]['offsetX']		
		local offsetY = i*spaceHeight+offset -- protoFields[i]['offsetY']
		local control = AuraMastery.controls.pool[poolName]
		local parent = WM:GetControlByName(parentName)
		control:SetParent(parent)
		control:SetAnchor(anchor, parent, relativeTo, offsetX, offsetY)
		if protoFields[i].spacesReq then
			offset = offset+(protoFields[i].spacesReq-1)*spaceHeight
		end
	end

	local auraName = self.activeAura
	local auraSettings = self.svars.auraData[auraName]
	
	-- aura state
	local enabled = auraSettings.loaded
	local CBEnabled = AuraMasteryDisplayMenu_AuraActivationStateSubControl
	if enabled then
		ZO_CheckButton_SetChecked(CBEnabled)
	else
		ZO_CheckButton_SetUnchecked(CBEnabled)
	end

	-- aura name
	local EBName = WM:GetControlByName("AuraMasteryDisplayMenu_AuraNameSubControl_Editbox")
	EBName:SetText(auraName)

	-- aura width
	local EBWidth = WM:GetControlByName("AuraMasteryDisplayMenu_AuraWidthSubControl_Editbox")
	EBWidth:SetText(auraSettings.width)

	-- aura height
	local EBHeight = WM:GetControlByName("AuraMasteryDisplayMenu_AuraHeightSubControl_Editbox")
	EBHeight:SetText(auraSettings.height)
	
	-- aura offsetX
	local EBPosX = WM:GetControlByName("AuraMasteryDisplayMenu_AuraPosXSubControl_Editbox");
	EBPosX:SetText(auraSettings.posX);

	-- aura offsetX
	local EBPosY = WM:GetControlByName("AuraMasteryDisplayMenu_AuraPosYSubControl_Editbox");
	EBPosY:SetText(auraSettings.posY);

	-- aura transparency
	local EBAlpha = WM:GetControlByName("AuraMasteryDisplayMenu_AuraAlphaSubControl_Editbox");
	EBAlpha:SetText(auraSettings.alpha*100);

	-- aura critical time
	local EBCritical = WM:GetControlByName("AuraMasteryDisplayMenu_AuraCriticalTimeSubControl_Editbox")
	EBCritical:SetText(auraSettings.critical)
	
	if 1 == auraType then	-- icon

		-- border size
		local EBBorderSize = WM:GetControlByName("AuraMasteryDisplayMenu_AuraBorderSizeSubControl_Editbox");
		EBBorderSize:SetText(self.svars.auraData[auraName].borderSize);

		-- border color
		local borderColorSelect = WM:GetControlByName("AuraMasteryDisplayMenu_BorderColorSelect")
		preSelection = self.svars.auraData[auraName].borderColor
		borderColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)

		-- backdrop color
		local backgroundColorSelect = WM:GetControlByName("AuraMasteryDisplayMenu_BackgroundColorSelect")
		preSelection = self.svars.auraData[auraName].bgColor
		backgroundColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)
		if nil ~= self.svars.auraData[auraName].barColor then
			local barColorSelect = WM:GetControlByName("AuraMasteryDisplayMenu_BarColorSelect")
			preSelection = self.svars.auraData[auraName].barColor
			barColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)
		end	
		
		-- cooldown animation
		local showCooldownAnimation = auraSettings.showCooldownAnimation
		local CBShowCooldownAnimation = AuraMasteryDisplayMenu_AuraShowCooldownAnimationSubControl
		if showCooldownAnimation then
			ZO_CheckButton_SetChecked(CBShowCooldownAnimation)
		else
			ZO_CheckButton_SetUnchecked(CBShowCooldownAnimation)
		end

		-- cooldown text
		local showCooldownText = auraSettings.showCooldownText
		local CBShowCooldownText = AuraMasteryDisplayMenu_AuraShowCooldownTextSubControl
		if showCooldownText then
			ZO_CheckButton_SetChecked(CBShowCooldownText)
		else
			ZO_CheckButton_SetUnchecked(CBShowCooldownText)
		end
		
		-- cooldown font size
		local EBCooldownFontSize = WM:GetControlByName("AuraMasteryDisplayMenu_AuraCooldownFontSizeSubControl_Editbox");
		EBCooldownFontSize:SetText(self.svars.auraData[auraName].cooldownFontSize)	
		
		-- cooldown font color
		local cooldownFontColorSelect = WM:GetControlByName("AuraMasteryDisplayMenu_CooldownFontColorSelect")
		preSelection = self.svars.auraData[auraName].cooldownFontColor
		cooldownFontColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)

		-- icon
		local iconSelect = WM:GetControlByName("AuraMasteryDisplayMenu_IconSelect")
		local preSelection = self.svars.auraData[auraName].iconPath
		iconSelect.icon:SetTexture(preSelection)

	elseif 2 == auraType then	-- progression bar
	
		-- backdrop color
		local backgroundColorSelect = AuraMasteryDisplayMenu_BackgroundColorSelect
		preSelection = self.svars.auraData[auraName].bgColor
		backgroundColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)

		-- border size
		local EBBorderSize = AuraMasteryDisplayMenu_AuraBorderSizeSubControl_Editbox
		EBBorderSize:SetText(self.svars.auraData[auraName].borderSize);
		
		-- border color
		local borderColorSelect = AuraMasteryDisplayMenu_BorderColorSelect
		preSelection = self.svars.auraData[auraName].borderColor
		borderColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)
			
		-- bar color
		local barColorSelect = AuraMasteryDisplayMenu_BarColorSelect
		preSelection = self.svars.auraData[auraName].barColor
		barColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)
		
		-- cooldown font size
		local EBCooldownFontSize = AuraMasteryDisplayMenu_AuraCooldownFontSizeSubControl_Editbox
		EBCooldownFontSize:SetText(self.svars.auraData[auraName].cooldownFontSize)		
		
		-- cooldown font color
		local cooldownFontColorSelect = AuraMasteryDisplayMenu_CooldownFontColorSelect
		preSelection = self.svars.auraData[auraName].cooldownFontColor
		cooldownFontColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)

		-- icon
		local iconSelect = AuraMasteryDisplayMenu_IconSelect
		local preSelection = self.svars.auraData[auraName].iconPath
		iconSelect.icon:SetTexture(preSelection)

	elseif 4 == auraType then	-- text
		-- nothing to update here
	end
end

function AuraMastery:UpdateTriggerMenu()
	local auraName = AuraMastery.activeAura
	local activeTrigger = self.activeTrigger
	local triggerType = AuraMastery.svars.auraData[auraName].triggers[activeTrigger].triggerType
	local protoTriggers = AuraMastery.protoTriggers[triggerType]

	--
	-- Hide all other input controls
	--
	local control = AuraMasteryTriggerSettingsContainerDynamicControls -- container that contains all input controls for the trigger type that is currently active
	local children = {}
	for i = 1, control:GetNumChildren() do
		children[i] = control:GetChild(i)
	end
	for i=1, #children do
		children[i]:SetParent(AuraMasteryHiddenControls)
	end	
	
	--
	-- Display required input controls
	--
	local spaceHeight = 30
	local offset = 0
	for i=1, #protoTriggers do
		local poolName = protoTriggers[i]['poolName']
		local parentName = protoTriggers[i]['parentName']
		local anchor =	protoTriggers[i]['anchor']
		local relativeTo = protoTriggers[i]['relativeTo']
		local offsetX = protoTriggers[i]['offsetX']
		local offsetY = i*spaceHeight+offset -- protoTriggers[i]['offsetY']
		local control = AuraMastery.controls.pool[poolName]
		local parent = WM:GetControlByName(parentName)
		control:SetParent(parent)
		control:SetAnchor(anchor, parent, relativeTo, offsetX, offsetY)
		if protoTriggers[i].spacesReq then
			offset = offset+(protoTriggers[i].spacesReq-1)*spaceHeight
		end
	end

	
	-- ================================================
	-- fill controls with preselected values from svars
	-- ================================================	
	
	local triggerData = AuraMastery.svars.auraData[auraName].triggers[activeTrigger]	

	--
	-- invert (must be preselected first as some of the following controls depend on this
	--
	local invert = triggerData.invert
	local CBInvert = AuraMasteryTriggerMenu_InvertSubControl
	if invert then
		ZO_CheckButton_SetChecked(CBInvert)
	else
		ZO_CheckButton_SetUnchecked(CBInvert)
	end
	
	-- trigger type
	local triggerTypeId = triggerData.triggerType
	if triggerTypeId then
		local CBTriggerTypeData = WM:GetControlByName("AuraMasteryTriggerMenu_TriggerTypeSubControl").m_comboBox
		CBTriggerTypeData:SelectItemByIndex(triggerTypeId, true)
	end
	
	-- ability id
	local abilityId = triggerData.spellId
	--if abilityId then
		local EBAbilityId = WM:GetControlByName("AuraMasteryTriggerMenu_AbilityIdSubControl_Editbox");
		EBAbilityId:SetText(triggerData.spellId);
	--end
	
	-- source unit tag
	local sourceUnitTag = triggerData.unitTag
	if sourceUnitTag then
		AuraMasteryTriggerMenu_SourceSubControl.m_comboBox:SelectItemByIndex(sourceUnitTag, true)
	end
	
	-- source combat unit type
	local sourceCombatUnitType = triggerData.sourceCombatUnitType
	if sourceCombatUnitType then
		self:AM_ComboBox_SelectItemByInternalValue(AuraMasterySourceCombatUnitTypeSubControl.m_comboBox, sourceCombatUnitType, true)
	else
		AuraMasterySourceCombatUnitTypeSubControl.m_comboBox:SelectItemByIndex(1, true)
	end
	
	-- check all
	local checkAll = triggerData.checkAll
	local CBCheckAll = AuraMasteryTriggerMenu_CheckAllSubControl
	if checkAll then
		ZO_CheckButton_SetChecked(CBCheckAll)
	else
		ZO_CheckButton_SetUnchecked(CBCheckAll)
	end
	
	-- operator
	local operatorId = triggerData.operator
	if operatorId then
		local CBOperatorData = WM:GetControlByName("AuraMasteryTriggerMenu_OperatorSubControl").m_comboBox
		CBOperatorData:SelectItemByIndex(operatorId, true)
	end

	-- value
	local value = triggerData.value
	if value then
		local EBValue = WM:GetControlByName("AuraMasteryTriggerMenu_ValueSubControl_Editbox")
		EBValue:SetText(AuraMastery.svars.auraData[auraName].triggers[activeTrigger].value)
	end
	
	-- custom duration
	local customDuration = triggerData.duration
	if customDuration then
		local EBDurationText = customDuration and customDuration or nil
		local EBDuration = WM:GetControlByName("AuraMasteryTriggerMenu_DurationSubControl_Editbox")
		EBDuration:SetText(EBDurationText)
	end
	
	-- caster name
	local casterName = triggerData.casterName
	if casterName then
		local EBCasterNameText = casterName and casterName or nil
		local EBCasterName = WM:GetControlByName("AuraMasteryTriggerMenu_CasterNameSubControl_Editbox")
		EBCasterName:SetText(EBCasterNameText)
	end
	
	-- target name
	local targetName = triggerData.targetName
	if targetName then
		local EBTargetNameText = targetName and targetName or nil
		local EBTargetName = WM:GetControlByName("AuraMasteryTriggerMenu_TargetNameSubControl_Editbox")
		EBTargetName:SetText(EBTargetNameText)
	end

end

function AuraMastery:UpdateCustomTriggerMenu()
	local auraName = AuraMastery.activeAura
	local activeTrigger = self.activeTrigger
	local activeTriggerType = self.activeTriggerType
	local customTriggerData = self.svars.auraData[auraName].triggers[activeTrigger].customTriggerData	

	local eventTypeId = customTriggerData.eventType

	local protoCustomTriggers = AuraMastery.protoCustomTriggers[eventTypeId]
	--
	-- Hide all other input controls
	--
	local control = AuraMasteryCustomTriggerWindowDynamicControls -- container that contains all input controls for the trigger type that is currently active
	local children = {}
	for i = 1, control:GetNumChildren() do
		children[i] = control:GetChild(i)
	end
	for i=1, #children do
		children[i]:SetParent(AuraMasteryHiddenControls)
	end	
	
	--
	-- Display required input controls
	--
	for i=1, #protoCustomTriggers do
		local poolName = protoCustomTriggers[i]['poolName']
		local parentName = protoCustomTriggers[i]['parentName']
		local anchor =	protoCustomTriggers[i]['anchor']
		local relativeTo = protoCustomTriggers[i]['relativeTo']
		local offsetX = protoCustomTriggers[i]['offsetX']
		local offsetY = protoCustomTriggers[i]['offsetY']
		local control = AuraMastery.controls.pool[poolName]
		local parent = WM:GetControlByName(parentName)
		control:SetParent(parent)
		control:SetAnchor(anchor, parent, relativeTo, offsetX, offsetY)
	end

	
	-- ================================================
	-- fill controls with preselected values from svars
	-- ================================================

	
	-- event type	
	local eventType = AuraMastery.svars.auraData[auraName].triggers[activeTrigger].customTriggerData.eventType
	local CBEventType = WM:GetControlByName("AuraMasteryCustomTriggerWindowTriggerTypeSelectSubControl").m_comboBox
	CBEventType:SelectItemByIndex(eventType, true)
	
	local abilityId = customTriggerData.abilityId
	if abilityId then
		local EBAbilityId = WM:GetControlByName("AuraMasteryCustomTriggerAbilityIdSubControl_Editbox")
		EBAbilityId:SetText(abilityId)
	end
	
	-- change type (EVENT_EFFECT_CHANGED)
	local changeType = customTriggerData.changeType
	if changeType then
		local CBChangeType = WM:GetControlByName("AuraMasteryCustomTriggerChangeTypeSubControl").m_comboBox
		CBChangeType:SelectItemByIndex(changeType, true)
	end
	
	-- source unit tag (EVENT_EFFECT_CHANGED)
	local sourceUnitTag = customTriggerData.unitTag
	if sourceUnitTag then
		local CBSourceData = WM:GetControlByName("AuraMasteryCustomTriggerUnitTagSubControl").m_comboBox
		CBSourceData:SelectItemByIndex(sourceUnitTag, true)
	end
	
	-- source name (EVENT_COMBAT_EVENT)
	local sourceName = customTriggerData.sourceName
	if sourceName then
		local EBSourceName = WM:GetControlByName("AuraMasteryCustomTriggerSourceNameSubControl_Editbox")
		EBSourceName:SetText(sourceName)
	end

	-- target name (EVENT_COMBAT_EVENT)
	local targetName = customTriggerData.targetName
	if targetName then
		local EBTargetName = WM:GetControlByName("AuraMasteryCustomTriggerTargetNameSubControl_Editbox")
		EBTargetName:SetText(targetName)
	end
	
end

function AuraMastery:UpdateCustomUntriggerMenu()
	local auraName = AuraMastery.activeAura
	local activeTrigger = self.activeTrigger
	local activeTriggerType = self.activeTriggerType
	local customUntriggerData = self.svars.auraData[auraName].triggers[activeTrigger].customUntriggerData	
	local eventTypeId = customUntriggerData.eventType
	local protoCustomUntriggers = AuraMastery.protoCustomUntriggers[eventTypeId]
	
	--
	-- Hide all other input controls
	--
	local control = AuraMasteryCustomUntriggerWindowDynamicControls -- container that contains all input controls for the trigger type that is currently active
	local children = {}
	for i = 1, control:GetNumChildren() do
		children[i] = control:GetChild(i)
	end
	for i=1, #children do
		children[i]:SetParent(AuraMasteryHiddenControls)
	end	
	
	--
	-- Display required input controls
	--
	for i=1, #protoCustomUntriggers do
		local poolName = protoCustomUntriggers[i]['poolName']
		local parentName = protoCustomUntriggers[i]['parentName']
		local anchor =	protoCustomUntriggers[i]['anchor']
		local relativeTo = protoCustomUntriggers[i]['relativeTo']
		local offsetX = protoCustomUntriggers[i]['offsetX']
		local offsetY = protoCustomUntriggers[i]['offsetY']
		local control = AuraMastery.controls.pool[poolName]
		local parent = WM:GetControlByName(parentName)
		control:SetParent(parent)
		control:SetAnchor(anchor, parent, relativeTo, offsetX, offsetY)
	end

	
	-- ================================================
	-- fill controls with preselected values from svars
	-- ================================================

	-- event type	
	local eventType = AuraMastery.svars.auraData[auraName].triggers[activeTrigger].customUntriggerData.eventType
	local CBEventType = WM:GetControlByName("AuraMasteryCustomUntriggerWindowUntriggerTypeSelectSubControl").m_comboBox

	CBEventType:SelectItemByIndex(eventType, true)
	
	local abilityId = customUntriggerData.abilityId
	if abilityId then
		local EBAbilityId = WM:GetControlByName("AuraMasteryCustomUntriggerAbilityIdSubControl_Editbox")
		EBAbilityId:SetText(customUntriggerData.abilityId)
	end
	
	-- change type (EVENT_EFFECT_CHANGED)
	local changeType = customUntriggerData.changeType
	if changeType then
		local CBChangeType = WM:GetControlByName("AuraMasteryCustomUntriggerChangeTypeSubControl").m_comboBox
		CBChangeType:SelectItemByIndex(changeType, true)
	end
	
	-- source unit tag (EVENT_EFFECT_CHANGED)
	local sourceUnitTag = customUntriggerData.unitTag
	if sourceUnitTag then
		local CBSourceData = WM:GetControlByName("AuraMasteryCustomUntriggerUnitTagSubControl").m_comboBox
		CBSourceData:SelectItemByIndex(sourceUnitTag, true)
	end
	
	-- source name (EVENT_COMBAT_EVENT)
	local sourceName = customUntriggerData.sourceName
	if sourceName then
		local EBSourceName = WM:GetControlByName("AuraMasteryCustomUntriggerSourceNameSubControl_Editbox")
		EBSourceName:SetText(sourceName)
	end

	-- target name (EVENT_COMBAT_EVENT)
	local targetName = customUntriggerData.targetName
	if targetName then
		local EBTargetName = WM:GetControlByName("AuraMasteryCustomUntriggerTargetNameSubControl_Editbox")
		EBTargetName:SetText(targetName)
	end	
end

function AuraMastery:UpdateAuraTextMenu()
	local activeAura = AuraMastery.activeAura

	-- setup replacer legend
	local textInfoTriggerIndex = AuraMastery.svars.auraData[activeAura].textInfoSource
	local textInfoSource = AuraMastery.svars.auraData[activeAura].triggers[textInfoTriggerIndex]
	local legendText = ""
	local label = AuraMasteryAuraTextWindowLegendLabel	
	if textInfoSource then
		-- inverted triggers do not contain event info (as they are displaying when nothing happened)
		if AuraMastery.svars.auraData[activeAura].triggers[textInfoTriggerIndex].invert then
			legendText = "\nNote: Replacement functionality\nis not available for inverted triggers!"
		else
			local eventType = textInfoSource.triggerType
			local replacers = AuraMastery.lookup.textReplacerNamesByEventTypes[eventType]		
			for replacer, replacement in pairs(replacers) do
				legendText = legendText.."\n"..replacer.." = ".. replacement
			end
		end
	else
		legendText = "\nNote: You must\nselect an\nevent-info-trigger\nto use replacers!"
	end
	label:SetText(legendText)

	-- aura text
	local auraText = AuraMastery.svars.auraData[activeAura].text
	AuraMasteryAuraText_TextBox:SetText(auraText)

	-- aura text font size
	local textFontSize = self.svars.auraData[activeAura].textFontSize
	AuraTextFontSizeSubControl_Editbox:SetText(textFontSize)

	-- aura text font color
	local preSelection = AuraMastery.svars.auraData[activeAura].textFontColor
	AuraMasteryDisplayMenu_TextFontColorSelect.thumb:SetColor(preSelection.r, preSelection.g, preSelection.b)
	
	-- aura text position
	local auraTextPositionId = self.svars.auraData[activeAura].auraTextPositionId or 7
	AuraTextPositionSubControl.m_comboBox:SelectItemByIndex(auraTextPositionId, true)
	
	self:UpdateTextInfoSourceSelect()
end

function AuraMastery:UpdateTriggerAnimationSettingsMenu()
	local controlSet = AuraMasteryAuraActionsWindow_DisplayContainer_Animations
	local activeAura = AuraMastery.activeAura
	local auraData = AuraMastery.svars.auraData[activeAura]

	--
	-- checkButton preselection
	--
	local enabled = auraData.animationData and true or false
	if enabled then
		ZO_CheckButton_SetChecked(AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEnabled_Checkbox)
	else
		ZO_CheckButton_SetUnchecked(AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEnabled_Checkbox)
	end
	--
	-- enable/disable controls
	--
	local textColor = enabled and {0.77255, 0.76078, 0.61961, 1} or {ZO_DISABLED_TEXT.r, ZO_DISABLED_TEXT.g, ZO_DISABLED_TEXT.b, ZO_DISABLED_TEXT.a}
	
	local colorSettings = controlSet:GetNamedChild("_TriggerAnimationColor")
	colorSettings:GetNamedChild("_Label"):SetColor(unpack(textColor))
	local triggerAnimationColorSelect = AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationColorColorSelect
	triggerAnimationColorSelect:UpdateDisabled()

	local endAlphaSettings = controlSet:GetNamedChild("_TriggerAnimationEndAlpha")
	endAlphaSettings:GetNamedChild("_Label"):SetColor(unpack(textColor))
	AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEndAlpha_Editbox_Editbox:SetEditEnabled(enabled)
	AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEndAlpha_Editbox_Editbox:SetMouseEnabled(enabled)
	
	local durationSettings = controlSet:GetNamedChild("_TriggerAnimationDuration")
	durationSettings:GetNamedChild("_Label"):SetColor(unpack(textColor))
	AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationDuration_Editbox_Editbox:SetEditEnabled(enabled)
	AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationDuration_Editbox_Editbox:SetMouseEnabled(enabled)
	
	local loopCountSettings = controlSet:GetNamedChild("_TriggerAnimationLoopCount")
	loopCountSettings:GetNamedChild("_Label"):SetColor(unpack(textColor))
	AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationLoopCount_Editbox_Editbox:SetEditEnabled(enabled)
	AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationLoopCount_Editbox_Editbox:SetMouseEnabled(enabled)
	
	--
	-- preselections
	--
	if enabled then -- only apply preselections if the control set is enabled	
		local preSelection
		r,g,b,a = unpack(auraData.animationData.trigger.colors)
		triggerAnimationColorSelect.thumb:SetColor(r,g,b,a)
		
		preSelection = auraData.animationData.trigger.endAlpha*100	-- convert 0-1 to 0-100
		AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEndAlpha_Editbox_Editbox:SetText(preSelection)
		
		preSelection = auraData.animationData.trigger.duration
		AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationDuration_Editbox_Editbox:SetText(preSelection)
		local ceil = math.ceil
		preSelection = ceil(auraData.animationData.trigger.loopCount/2)
		AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationLoopCount_Editbox_Editbox:SetText(preSelection)
	else
		triggerAnimationColorSelect.thumb:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
		AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEndAlpha_Editbox_Editbox:SetText("")
		AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationDuration_Editbox_Editbox:SetText("")
		AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationLoopCount_Editbox_Editbox:SetText("")
	end
end

function AuraMastery:UpdateLoadingConditionsSettingsMenu()
	local auraName 	= AuraMastery.activeAura
	local loadingConditionsData = self.svars.auraData[auraName].loadingConditions
	
	-- in combat only
	local control = WM:GetControlByName("AuraMasteryLoadingConditionsMenu_InCombatOnlyButton_Label")
	control:SetText(tostring(self.svars.auraData[auraName].loadingConditions['inCombatOnly']))
	
	-- abilities sloted
	local parent = WM:GetControlByName("AuraMasteryLoadingConditionsAbilitiesSlotedContainer")
	
	local numAbilities = loadingConditionsData.abilitiesSloted
	for i=1, #numAbilities do
		local controlName = "AuraMasteryLoadingConditionsAbilitiesSlotedAbilityRow"..i
		local abilityId = loadingConditionsData.abilitiesSloted[i]
		control = WM:GetControlByName(controlName)
		if not control then
			control = WM:CreateControlFromVirtual(controlName, parent, "AM_AbilityRow")
		end
		control:SetHidden(false)
		control:SetAnchor(TOPLEFT, parent, TOPLEFT, 9, i*20)
		control:GetNamedChild("_Label"):SetText(abilityId)
		control:GetNamedChild("_DeleteButton"):SetHandler("OnClicked", function() AuraMastery:RemoveAbilityFromLoadingConditions(auraName, abilityId) end)
	end
	
	-- hide any other unused row controls
	local rowNum = #numAbilities+1
	control = WM:GetControlByName("AuraMasteryLoadingConditionsAbilitiesSlotedAbilityRow"..rowNum)
	while control do
		control:SetHidden(true)
		rowNum = rowNum+1
		control = WM:GetControlByName("AuraMasteryLoadingConditionsAbilitiesSlotedAbilityRow"..rowNum)
	end
end


--
-- Specific Controls
--
function AuraMastery:UpdateAurasScrollList()
	local activeAura = self.activeAura
    local activeAuraGroup = self.activeAuragroup
	local scrollList = WM:GetControlByName("AM_ScrollList")
    local dataList = ZO_ScrollList_GetDataList(scrollList)

    ZO_ScrollList_Clear(scrollList)

	local auraData = self.svars.auraData
	
	for auraName, auraData in self:pairsByKeys(auraData) do
		local rowData
		local containingAuraGroupId = self:GetAssignedAuraGroup(auraName)

		if (not containingAuraGroupId and not activeAuraGroup) or (containingAuraGroupId == activeAuraGroup) then
			rowData = {
				['auraName'] = auraName
			}
			dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(1, rowData, 1)
		end
	end
    ZO_ScrollList_Commit(scrollList)
	self:AM_ScrollList_SelectItemByName(AM_ScrollList, activeAura, true) -- true = animateInstantly so we don't get a flicker when updating the auras list
end

function AuraMastery:UpdateActionResultsScrollList()
    local scrollList = WM:GetControlByName("AM_ActionResultsScrollList") 
    local dataList = ZO_ScrollList_GetDataList(scrollList)
    ZO_ScrollList_Clear(scrollList)
	
	local actionResults = self.codes.combatEventActionResults
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	for actionResultCode, actionResultName in self:pairsByKeys(actionResults) do
		local triggerActionResults = self.svars.auraData[activeAura].triggers[activeTrigger].actionResults
		local index = table.contains(triggerActionResults, actionResultCode)
		local actionResultState = index and "On" or "Off"

		local rowData = {
			['actionResultCode'] = actionResultCode,
			['actionResultName'] = actionResultName,
			['actionResultState'] = actionResultState
		}
		dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(1, rowData, 1)
	end
    ZO_ScrollList_Commit(scrollList)
end

function AuraMastery:UpdateCustomTriggerActionResultsScrollList()
    local scrollList = WM:GetControlByName("AM_CustomTriggerActionResultsScrollList") 
    local dataList = ZO_ScrollList_GetDataList(scrollList)
    ZO_ScrollList_Clear(scrollList)
	
	local actionResults = self.codes.combatEventActionResults
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	for actionResultCode, actionResultName in self:pairsByKeys(actionResults) do
		local triggerActionResults = self.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults
		local index = table.contains(triggerActionResults, actionResultCode)
		local actionResultState = index and "On" or "Off"

		local rowData = {
			['actionResultCode'] = actionResultCode,
			['actionResultName'] = actionResultName,
			['actionResultState'] = actionResultState
		}
		dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(1, rowData, 1)
	end
    ZO_ScrollList_Commit(scrollList)
end

function AuraMastery:UpdateCustomUntriggerActionResultsScrollList()
    local scrollList = WM:GetControlByName("AM_CustomUntriggerActionResultsScrollList") 
    local dataList = ZO_ScrollList_GetDataList(scrollList)
    ZO_ScrollList_Clear(scrollList)
	
	local actionResults = self.codes.combatEventActionResults
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	for actionResultCode, actionResultName in self:pairsByKeys(actionResults) do
		local triggerActionResults = self.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults
		local index = table.contains(triggerActionResults, actionResultCode)
		local actionResultState = index and "On" or "Off"

		local rowData = {
			['actionResultCode'] = actionResultCode,
			['actionResultName'] = actionResultName,
			['actionResultState'] = actionResultState
		}
		dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(1, rowData, 1)
	end
    ZO_ScrollList_Commit(scrollList)
end

function AuraMastery:UpdateDurationInfoSelect()
	local auraName = self.activeAura
	local control = WM:GetControlByName("AuraMasteryDisplayMenu_AuraDurationInfoSubControl")
	local m_comboBox = control.m_comboBox

	local itemSelectCallback = AuraMastery.DurationInfoSelectCallback

	-- assign dropdown items to control object
	local items = {}
	local triggers = self.svars.auraData[self.activeAura].triggers
	local preSelection = "Aura"
	local disable = true
	local durationInfoSource = self.svars.auraData[auraName].durationInfoSource

	if 0 < #triggers then
		for i=1,#triggers do
			local spellId = triggers[i].spellId
			if 5 ~= triggers[i].triggerType and nil ~= spellId then	-- status triggers have no ability id and hence don't provide any icon info
				items[i] = {name = "Trigger "..i, callback = itemSelectCallback, internalValue = i}
				disable = false	-- at least one valid trigger has been found
			end
			if i == #triggers then
				items[i+1] = {name = "Aura", callback = itemSelectCallback, internalValue = false}
			end
			if durationInfoSource == i then
				preSelection = "Trigger "..i
			end
		end
	end

	if disable then
		if durationInfoSource then self.svars.auraData[auraName].durationInfoSource = nil; end
		ZO_ComboBox_Disable(control)
	else
		ZO_ComboBox_Enable(control)
	end

	control.items = items

	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	control.m_comboBox:SetSelectedItemText(preSelection)
end

function AuraMastery:UpdateIconInfoSelect()
	local auraName = self.activeAura
	local control = WM:GetControlByName("AuraMasteryDisplayMenu_AuraIconInfoSubControl")
	local m_comboBox = control.m_comboBox

	local itemSelectCallback = AuraMastery.IconInfoSelectCallback


	-- assign dropdown items to control object
	local items = {}
	local triggers = self.svars.auraData[self.activeAura].triggers
	local preSelection = "Manual"
	local disable = true
	local iconInfoSource = self.svars.auraData[auraName].iconInfoSource
	WM:GetControlByName("AuraMasteryDisplayMenu_AuraIcon"):SetHidden(false)

	if 0 < #triggers then
		for i=1,#triggers do

			local spellId = triggers[i].spellId
			if 5 ~= triggers[i].triggerType and nil ~= spellId then	-- status triggers have no ability id and hence don't provide any icon info
				items[i] = {name = "Trigger "..i, callback = itemSelectCallback, internalValue = i}
				disable = false	-- at least one valid trigger has been found
			end
			if i == #triggers then
				items[i+1] = {name = "Manual", callback = itemSelectCallback, internalValue = false}
			end

			if iconInfoSource == i then
				preSelection = "Trigger "..i
				local abilityId = AuraMastery.svars.auraData[auraName].triggers[i].spellId
				local texturePath = GetAbilityIcon(abilityId)
				WM:GetControlByName("AuraMasteryDisplayMenu_AuraIcon"):SetHidden(true)
			end

		end
	end

	if disable then
		if iconInfoSource then self.svars.auraData[auraName].iconInfoSource = nil; end
		ZO_ComboBox_Disable(control)
	else
		ZO_ComboBox_Enable(control)
	end

	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	control.m_comboBox:SetSelectedItemText(preSelection)
end

function AuraMastery.UpdateTriggerSoundSelect()
	local auraName = AuraMastery.activeAura
	-- local control = AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_TriggerActions_ScrollableComboBox
	local control = AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_TriggerActions_ComboBox
	local m_comboBox = control.m_comboBox
	local preSelectionItemText = AuraMastery.svars.auraData[auraName].triggerSound or "AA_NONE"
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	control.m_comboBox:SetSelectedItemText(preSelectionItemText)
end

function AuraMastery.UpdateUntriggerSoundSelect()
	local auraName = AuraMastery.activeAura
	-- local control = WM:GetControlByName("AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_UntriggerActions_ScrollableComboBox")
	local control = WM:GetControlByName("AuraMasteryAuraActionsWindow_DisplayContainer_Sounds_UntriggerActions_ComboBox")
	local m_comboBox = control.m_comboBox
	local preSelectionItemText = AuraMastery.svars.auraData[auraName].untriggerSound or "AA_NONE"
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	control.m_comboBox:SetSelectedItemText(preSelectionItemText)
end

function AuraMastery:UpdateTextInfoSourceSelect()
	local activeAura = self.activeAura
	local control = AuraTextInfoSourceSubControl
	local m_comboBox = control.m_comboBox
	local itemSelectCallback = AuraMastery.EditAuraTextInfoSource
	
	local triggers = self.svars.auraData[activeAura].triggers
	local preSelection = "-- NONE --"
	local disable = true
	local textInfoSource = self.svars.auraData[activeAura].textInfoSource
	
	local items = {}
	if 0 < #triggers then
		for i=1,#triggers do
			items[i] = {name = "Trigger "..i, callback = itemSelectCallback, internalValue = i}
			if textInfoSource == i then
				preSelection = "Trigger "..i
			end
		end
		ZO_ComboBox_Enable(control)
	else
		self.svars.auraData[activeAura].textInfoSource = nil
		ZO_ComboBox_Disable(control)
	end
	AuraMastery:PopulateComboBoxCustom(m_comboBox, items, itemSelectCallback)
	control.m_comboBox:SetSelectedItemText(preSelection)
end

function AuraMastery:UpdateAuraGroupAssignment()
	local control = WM:GetControlByName("AuraMasteryDisplayMenu_AuraGroupAssignmentSubControl")

	local m_comboBox = control.m_comboBox
	m_comboBox:SetSortsItems(false)  
	local itemSelectCallback = AuraMastery.EditAuraGroupAssignment


	-- assign dropdown items to control object
	local items = {}
	local auraGroups = self.svars.groupsData
	items[1] = {name = "None", callback = itemSelectCallback, internalValue = 0}
	if auraGroups and 0 < #auraGroups then
		for i = 1, #auraGroups do
			local groupName = auraGroups[i].groupName
			items[i+1] = {name = groupName, callback = itemSelectCallback, internalValue = i}
		end
	end

	control.items = items
	AuraMastery:PopulateComboBoxCustom(m_comboBox, control.items, callback)
	m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	
	local activeAura = self.activeAura
	local groupIndex = self:GetAssignedAuraGroup(activeAura)
	groupIndex = groupIndex or 0
	self:AM_ComboBox_SelectItemByInternalValue(m_comboBox, groupIndex, true)
end

function AuraMastery.UpdateTriggerAnimationCheckbox()
	local activeAura = AuraMastery.activeAura
	local auraData = AuraMastery.svars.auraData[activeAura]
	
	-- set the checkbox to checked based on svars animationData
	local checkButton = AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEnabled_Checkbox
	local enabled = auraData.animationData and ZO_CheckButton_SetChecked(checkButton) or ZO_CheckButton_SetUnchecked(checkButton)
	--AuraMastery:UpdateTriggerAnimationSettingsMenu()
	--AuraMastery:EditAuraTriggerAnimation()
end




--==========================================
-- 1.0 Display Settings --------------------
--==========================================


--
-- 1.1 Edit
--
function AuraMastery.EditAuraActivationState()
	local activeAura = AuraMastery.activeAura
	local checkButtonControl = AuraMasteryDisplayMenu_AuraActivationStateSubControl
	AuraMastery:SaveAuraEnabled(activeAura, ZO_CheckButton_IsChecked(checkButtonControl))
	AuraMastery:ReloadAuraControl(activeAura)
end

function AuraMastery.EditAuraName()
	local activeAura = AuraMastery.activeAura
	if not activeAura then return; end -- workaround for editauraname editbox calling this method two times: OnEnter AND OnFocusLost!
	local inputAuraName = zo_strtrim(AuraMasteryDisplayMenu_AuraNameSubControl_Editbox:GetText())
	local isValid,msg,color	= AuraMastery:IsValidAuraName(inputAuraName)
	if (isValid) then
		AuraMastery:SaveAuraName(inputAuraName)
		activeAura = inputAuraName				-- set new aura to active state
		AuraMastery:ReloadAuraControl(activeAura)	-- reload aura display
		AuraMastery:UpdateAurasScrollList()			-- reload aura list in menu
	else
		local oldName = AuraMastery.svars.auraData[activeAura].name
		AuraMasteryDisplayMenu_AuraNameSubControl_Editbox:SetText(oldName)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraGroupAssignment(comboBox, itemText, item, selectionChanged)
	if not selectionChanged then return; end
	local selectionValue = item.internalValue
	local auraName = AuraMastery.activeAura
	AuraMastery:RemoveAuraFromAuraGroups(auraName)
	if 0 < selectionValue then
		AuraMastery:AddAuraToAuraGroup(auraName, selectionValue)
	end
	
	-- update aura list
	AuraMastery:UpdateAurasScrollList()
		
	WM:GetControlByName("AuraMasteryMenu_EditAura"):SetHidden(true)
	AuraMastery:Edit_SetActiveAura(nil)
end

function AuraMastery.EditAuraWidth()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraWidthSubControl_Editbox
	local inputAuraWidth = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraWidth(inputAuraWidth)

	if (isValid) then
		AuraMastery:SaveAuraWidth(activeAura, inputAuraWidth)
		WM:GetControlByName(activeAura):SetWidth(inputAuraWidth)
		AuraMastery:ReloadAuraControl(activeAura)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['width'])
	end

	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraHeight()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraHeightSubControl_Editbox
	local inputAuraHeight = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraHeight(inputAuraHeight)
	if (isValid) then
		AuraMastery:SaveAuraHeight(activeAura, inputAuraHeight)
		WM:GetControlByName(activeAura):SetHeight(inputAuraHeight)
		AuraMastery:ReloadAuraControl(activeAura)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['height'])
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end 

function AuraMastery.EditAuraPosX()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraPosXSubControl_Editbox
	local inputAuraPosX = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraPosX(inputAuraPosX)

	if (isValid) then
		AuraMastery:SaveAuraPosX(activeAura, inputAuraPosX)
		local control = WM:GetControlByName("AM_GenericAnchor")
		local auraPosY = control:GetTop()
		local genericAnchorControl = control:GetParent()
		control:ClearAnchors()
		control:SetAnchor(TOPLEFT, genericAnchorControl, TOPLEFT, inputAuraPosX, auraPosY)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['posX'])
	end

	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraPosY()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraPosYSubControl_Editbox
	local inputAuraPosY = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraPosY(inputAuraPosY)
	if (isValid) then
		AuraMastery:SaveAuraPosY(activeAura, inputAuraPosY)
		local control = WM:GetControlByName("AM_GenericAnchor")
		local auraPosX = control:GetLeft()
		control:ClearAnchors()
		control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, auraPosX, inputAuraPosY)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['posY'])
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraAlpha()
	local activeAura = AuraMastery.activeAura;
	local editBoxControl = AuraMasteryDisplayMenu_AuraAlphaSubControl_Editbox
	local inputAuraAlpha 	= tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraAlpha(inputAuraAlpha)
	if (isValid) then
		AuraMastery:SaveAuraAlpha(activeAura, inputAuraAlpha)
		local alpha = inputAuraAlpha/100
		WM:GetControlByName(activeAura):SetAlpha(alpha)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['alpha']*100)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraCooldownFontSize()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraCooldownFontSizeSubControl_Editbox
	local inputAuraCooldownFontSize	= tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraCooldownFontSize(inputAuraCooldownFontSize)
	if (isValid) then
		AuraMastery:SaveAuraCooldownFontSize(activeAura, inputAuraCooldownFontSize)
		WM:GetControlByName(activeAura.."_CooldownLabel"):SetFont("$(BOLD_FONT)|"..inputAuraCooldownFontSize.."|outline")
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['cooldownFontSize'])
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery:EditAuraBorderSize()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraBorderSizeSubControl_Editbox
	local inputAuraBorderSize = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color = AuraMastery:IsValidAuraBorderSize(inputAuraBorderSize)
	if (isValid) then
		AuraMastery:SaveAuraBorderSize(activeAura, inputAuraBorderSize)
		WM:GetControlByName(activeAura.."_Backdrop"):SetEdgeTexture(nil, 1, 1, inputAuraBorderSize, 0)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['borderSize'])
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery:EditAuraCriticalTime()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryDisplayMenu_AuraCriticalTimeSubControl_Editbox
	local inputAuraCritical	= tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraCritical(inputAuraCritical)
	if (isValid) then
		AuraMastery:SaveAuraCritical(activeAura, inputAuraCritical)
		AuraMastery:ReloadAuraControl(activeAura)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['critical'])
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraIcon(texturePath)
	local activeAura = AuraMastery.activeAura
	AuraMastery.svars.auraData[activeAura].iconPath = texturePath
	AuraMastery:UpdateAurasScrollList()
	local auraControl = WM:GetControlByName(activeAura)
	auraControl.icon:SetTexture(texturePath)
end

function AuraMastery.EditAuraCooldownFontColor(r,g,b,a)
	local activeAura = AuraMastery.activeAura
	AuraMastery.svars.auraData[activeAura].cooldownFontColor.r = r
	AuraMastery.svars.auraData[activeAura].cooldownFontColor.g = g
	AuraMastery.svars.auraData[activeAura].cooldownFontColor.b = b
	AuraMastery.svars.auraData[activeAura].cooldownFontColor.a = a
end

function AuraMastery.EditAuraBorderColor(r,g,b,a)
	local activeAura = AuraMastery.activeAura
	AuraMastery.svars.auraData[activeAura].borderColor.r = r
	AuraMastery.svars.auraData[activeAura].borderColor.g = g
	AuraMastery.svars.auraData[activeAura].borderColor.b = b
	AuraMastery.svars.auraData[activeAura].borderColor.a = a
	local control = WM:GetControlByName(activeAura.."_Backdrop")
	control:SetEdgeColor(r,g,b)
end

function AuraMastery.EditAuraBackgroundColor(r,g,b,a)
	local activeAura = AuraMastery.activeAura
	AuraMastery.svars.auraData[activeAura].bgColor.r = r
	AuraMastery.svars.auraData[activeAura].bgColor.g = g
	AuraMastery.svars.auraData[activeAura].bgColor.b = b
	AuraMastery.svars.auraData[activeAura].bgColor.a = a
	local control = WM:GetControlByName(activeAura.."_Backdrop")
	control:SetCenterColor(r,g,b,a)
end

function AuraMastery.EditAuraBarColor(r,g,b,a)
	local activeAura = AuraMastery.activeAura
	if nil == AuraMastery.svars.auraData[activeAura].barColor then AuraMastery.svars.auraData[activeAura].barColor = {}; end
	AuraMastery.svars.auraData[activeAura].barColor.r = r
	AuraMastery.svars.auraData[activeAura].barColor.g = g
	AuraMastery.svars.auraData[activeAura].barColor.b = b
	AuraMastery.svars.auraData[activeAura].barColor.a = a
	local control = WM:GetControlByName(activeAura.."Status")
	local gr = r*0.2
	local gg = g*0.2
	local gb = b*0.2
	control:SetColor(r,g,b,a,gr,gg,gb,a)
end

function AuraMastery.EditAuraShowCooldownAnimation()
	local activeAura = AuraMastery.activeAura
	local checkButtonControl = AuraMasteryDisplayMenu_AuraShowCooldownAnimationSubControl
	AuraMastery:SaveAuraShowCooldownAnimation(activeAura, ZO_CheckButton_IsChecked(checkButtonControl))
	AuraMastery:ReloadAuraControl(activeAura)
end

function AuraMastery.EditAuraShowCooldownText()
	local activeAura = AuraMastery.activeAura
	local checkButtonControl = AuraMasteryDisplayMenu_AuraShowCooldownTextSubControl
	AuraMastery:SaveAuraShowCooldownText(activeAura, ZO_CheckButton_IsChecked(checkButtonControl))
	AuraMastery:ReloadAuraControl(activeAura)
end

function AuraMastery.EditAuraDurationInfo(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputAuraDurationInfo = item.internalValue
	local isValid, msg, color = AuraMastery:IsValidAuraDurationInfo(inputAuraDurationInfo)
	if (isValid) then
		AuraMastery:SaveAuraDurationInfo(activeAura, inputAuraDurationInfo)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraIconInfo(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputAuraIconInfo = item.internalValue
	local isValid, msg, color = AuraMastery:IsValidAuraIconInfo(inputAuraIconInfo)
	if (isValid) then
		AuraMastery:SaveAuraIconInfo(activeAura, inputAuraIconInfo)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditAuraText()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraMasteryAuraText_TextBox
	local inputAuraText	= zo_strtrim(editBoxControl:GetText())	
	local msg, color = "Aura text for aura "..activeAura.." has been saved.", C_PASS
	AuraMastery:SaveAuraText(activeAura, inputAuraText)
	editBoxControl:LoseFocus()
	AuraMastery:SetNotification(msg, color, AuraMasteryAuraTextWindow_NotificationLabel)
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:ReloadAuraControl(activeAura)
end

function AuraMastery.EditAuraTextFontSize()
	local activeAura = AuraMastery.activeAura
	local editBoxControl = AuraTextFontSizeSubControl_Editbox
	local inputAuraTextFontSize	= tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraTextFontSize(inputAuraTextFontSize)
	if (isValid) then
		AuraMastery:SaveAuraTextFontSize(activeAura, inputAuraTextFontSize)
		WM:GetControlByName(activeAura.."_TextLabel"):SetFont("$(BOLD_FONT)|"..inputAuraTextFontSize.."|outline")
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura]['textFontSize'])
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color, AuraMasteryAuraTextWindow_NotificationLabel)
end

function AuraMastery.EditAuraTextPosition(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputAuraTextPosition = item.internalValue
	local isValid, msg, color = AuraMastery:IsValidAuraTextPosition(inputAuraTextPosition)
	if (isValid) then
		AuraMastery:SaveAuraTextPosition(activeAura, inputAuraTextPosition)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color, AuraMasteryAuraTextWindow_NotificationLabel)
end

function AuraMastery.EditAuraTextFontColor(r,g,b,a)
	local activeAura = AuraMastery.activeAura
	AuraMastery.svars.auraData[activeAura].textFontColor.r = r
	AuraMastery.svars.auraData[activeAura].textFontColor.g = g
	AuraMastery.svars.auraData[activeAura].textFontColor.b = b
	AuraMastery.svars.auraData[activeAura].textFontColor.a = a
end

function AuraMastery.EditAuraTextInfoSource(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end
	local auraName = AuraMastery.activeAura
	local selectionIndex = item.internalValue
	if selectionIndex then
		AuraMastery.svars.auraData[auraName].textInfoSource = selectionIndex
	else
		AuraMastery.svars.auraData[auraName].textInfoSource = nil
	end
	AuraMastery:UpdateAuraTextMenu()
end


--
-- 1.2 Validate
--
function AuraMastery:IsValidAuraName(inputAuraName)
	local activeAura = self.activeAura
	local msg,rv,color
	if "" == inputAuraName then
		rv,msg,color = false, "Please enter a name.", C_ERR
	elseif self.svars.auraData[inputAuraName] then
		rv,msg,color = false, "This name is already taken by another aura.", C_ERR
	else
		rv,msg,color = true, "\""..activeAura.."\"'s Name has been set to "..inputAuraName..".", C_PASS
	end
	return rv,msg,color
end

function AuraMastery:IsValidTriggerDuration(inputAuraDuration)
	local activeAura = self.activeAura or "Aura"
	if "" ~= inputAuraDuration then
		inputAuraDuration = tonumber(inputAuraDuration) 
	end
	local msg,rv,color;
	if nil == inputAuraDuration then
		rv,msg,color = false, "Only numeric values or blank input are allowed in this field.", C_ERR;
	elseif "" == inputAuraDuration then
		rv,msg,color = true, "\""..activeAura.."\"'s duration will be calculated base on ability duration.", C_PASS;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s duration has been set to "..inputAuraDuration..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraType(inputAuraType)			-- only called by import function
	if 1 == inputAuraType or 2 == inputAuraType or 4 == inputAuraType then return true; else return false; end
end

function AuraMastery:IsValidAuraWidth(inputAuraWidth)

	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;
	if nil == inputAuraWidth or 0 ~= inputAuraWidth%1 or 8 > inputAuraWidth or 512 < inputAuraWidth then
		rv,msg,color = false, "Only integer values between 8 and 512 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s width has been set to "..inputAuraWidth..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraHeight(inputAuraHeight)
	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;
	if nil == inputAuraHeight or 0 ~= inputAuraHeight%1 or 8 > inputAuraHeight or 512 < inputAuraHeight then
		rv,msg,color = false, "Only integer values between 8 and 512 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s height has been set to "..inputAuraHeight..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraPosX(inputAuraPosX)					-- todo: add max values check (dynamical screen size)
	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;
	if nil == inputAuraPosX or 0 > inputAuraPosX or 0 ~= inputAuraPosX%1  then
		rv,msg,color = false, "Only integer values greater or equal to zero are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s horizontal anchor point coordinate has been set to "..inputAuraPosX..".", C_PASS;
	end

	return rv,msg,color;
end

function AuraMastery:IsValidAuraPosY(inputAuraPosY)					-- todo: add max values check
	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;
	if nil == inputAuraPosY or 0 > inputAuraPosY or 0 ~= inputAuraPosY%1  then
		rv,msg,color = false, "Only integer values greater or equal to zero are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s vertical anchor point coordinate has been set to "..inputAuraPosY..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraAlpha(inputAuraAlpha)
	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;

	-- quick and dirty fix: internal saving is 0.01-1, formula input is 1-100%...
	if 1 > inputAuraAlpha then inputAuraAlpha = inputAuraAlpha*100; end

	if nil == inputAuraAlpha or 0 ~= inputAuraAlpha%1 or 1 > inputAuraAlpha or 100 < inputAuraAlpha  then
		rv,msg,color = false, "Only integer values between 1 and 100 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s visibility has been set to "..inputAuraAlpha.."%.", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraShowCooldownAnimation(inputAuraShowCooldownAnimation)
	--deb("Called: IsValidAuraShowCooldownAnimation!")
end

function AuraMastery:IsValidAuraShowCooldownAnimation(inputAuraShowCooldownText)
	--deb("Called: IsValidAuraShowCooldownText!")
end

function AuraMastery:IsValidAuraCooldownFontSize(inputAuraCooldownFontSize)
	local activeAura = self.activeAura or "Aura"
	local msg,rv,color
	if nil == inputAuraCooldownFontSize or 0 ~= inputAuraCooldownFontSize%1 or 0 >= inputAuraCooldownFontSize or 72 < inputAuraCooldownFontSize  then
		rv,msg,color = false, "Only integer values between 1 and 72 are allowed in this field.", C_ERR
	else
		rv,msg,color = true, "\""..activeAura.."\"'s cooldown font size has been set to "..inputAuraCooldownFontSize..".", C_PASS
	end
	return rv,msg,color
end

function AuraMastery:IsValidAuraFontColor(inputAuraFontColor)	-- only called by import function
	if
		nil ~= inputAuraFontColor['r'] and 0 <= inputAuraFontColor['r'] and 1 >= inputAuraFontColor['r'] and
		nil ~= inputAuraFontColor['g'] and 0 <= inputAuraFontColor['g'] and 1 >= inputAuraFontColor['g'] and
		nil ~= inputAuraFontColor['b'] and 0 <= inputAuraFontColor['b'] and 1 >= inputAuraFontColor['b']
	then
		return true;
	end
	return false;
end

function AuraMastery:IsValidAuraBackgroundColor(inputAuraBackgroundColor)	-- only called by import function
	if
		nil ~= inputAuraBackgroundColor['r'] and 0 <= inputAuraBackgroundColor['r'] and 1 >= inputAuraBackgroundColor['r'] and
		nil ~= inputAuraBackgroundColor['g'] and 0 <= inputAuraBackgroundColor['g'] and 1 >= inputAuraBackgroundColor['g'] and
		nil ~= inputAuraBackgroundColor['b'] and 0 <= inputAuraBackgroundColor['b'] and 1 >= inputAuraBackgroundColor['b'] and
		nil ~= inputAuraBackgroundColor['a'] and 0 <= inputAuraBackgroundColor['a'] and 1 >= inputAuraBackgroundColor['a']
	then
		return true;
	end
	return false;
end

function AuraMastery:IsValidAuraIconPath(inputAuraIconPath)						-- only called by import function
	if "string" == type(inputAuraIconPath) then return true; else return false; end
end

function AuraMastery:IsValidAuraBorderSize(inputAuraBorderSize)
	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;
	if nil == inputAuraBorderSize or 0 ~= inputAuraBorderSize%1 or 0 > inputAuraBorderSize or 3 < inputAuraBorderSize  then
		rv,msg,color = false, "Only integer values between 0 and 3 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s border size has been set to "..inputAuraBorderSize..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraBorderColor(inputAuraBorderColor)				-- only called by import function
	if
		nil ~= inputAuraBorderColor['r'] and 0 <= inputAuraBorderColor['r'] and 1 >= inputAuraBorderColor['r'] and
		nil ~= inputAuraBorderColor['g'] and 0 <= inputAuraBorderColor['g'] and 1 >= inputAuraBorderColor['g'] and
		nil ~= inputAuraBorderColor['b'] and 0 <= inputAuraBorderColor['b'] and 1 >= inputAuraBorderColor['b'] and
		nil ~= inputAuraBorderColor['a'] and 0 <= inputAuraBorderColor['a'] and 1 >= inputAuraBorderColor['a']
	then
		return true;
	end
	return false;
end

function AuraMastery:IsValidAuraCritical(inputAuraCritical)
	local activeAura = self.activeAura or "Aura";
	local msg,rv,color;
	if nil == inputAuraCritical or 0 > inputAuraCritical  then
		rv,msg,color = false, "Only positive numeric values are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s critical time for decimal font cooldown display has been set to "..inputAuraCritical..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidAuraActivationState(inputAuraActivationState)	-- only called by import function
	if "boolean" == type(inputAuraActivationState) then return true; else return false; end
end

function AuraMastery:IsValidAuraLoadingConditionInCombatOnly(input)	-- only called by import function
	if "boolean" == type(input) then return true; else return false; end
end

function AuraMastery:IsValidAuraTextPosition(inputAuraTextPosition)
	local activeAura = self.activeAura or "Aura"
	local msg,rv,color

	if inputAuraTextPosition then
		rv,msg,color = true, "\""..activeAura.."\"'s text's position has been set to "..inputAuraTextPosition..".", C_PASS

	else
		rv,msg,color = false, "Error: Invalid aura text position id.", C_ERR
	end
	return rv,msg,color
end

function AuraMastery:IsValidAuraTextFontSize(inputAuraTextFontSize)
	local activeAura = self.activeAura or "Aura"
	local msg,rv,color
	if nil == inputAuraTextFontSize or 0 ~= inputAuraTextFontSize%1 or 0 >= inputAuraTextFontSize or 72 < inputAuraTextFontSize  then
		rv,msg,color = false, "Only integer values between 1 and 72 are allowed in this field.", C_ERR
	else
		rv,msg,color = true, "\""..activeAura.."\"'s text font size has been set to "..inputAuraTextFontSize..".", C_PASS
	end
	return rv,msg,color
end

function AuraMastery:IsValidAuraEnabled(inputAuraEnabled)
	--deb("Called: IsValidAuraEnabled!")
end


--
-- 1.3 Save to SVars
--
-- Note: Aura must be fully reloaded, because controls can't be renamed!
function AuraMastery:SaveAuraName(newAuraName)
	local oldAuraName = self.activeAura
	-- Einträge mit neuem Namen erstellen:
	-- 1. Controlreferenz
	self.aura[newAuraName] = self.aura[oldAuraName]
	-- 2. SVars
	self.svars.auraData[newAuraName] = self.svars.auraData[oldAuraName]
	self.svars.auraData[newAuraName]['name'] = newAuraName
	-- 3. LoadedAuras
	self:LoadAura(newAuraName)
	-- 4. Auramenu:List
	local number = self:GetNumElements(self.svars.auraData)

	local assignedAuraGroup = self:GetAssignedAuraGroup(oldAuraName)
	if assignedAuraGroup then
		self:AddAuraToAuraGroup(newAuraName, assignedAuraGroup)
	end
	self:DeleteAura(oldAuraName)
	self:Edit_SetActiveAura(newAuraName)
end

function AuraMastery:SaveAuraWidth(auraName, auraWidth)
	self.svars.auraData[auraName]['width'] = auraWidth
end

function AuraMastery:SaveAuraHeight(auraName, auraHeight)
	self.svars.auraData[auraName]['height'] = auraHeight
end

function AuraMastery:SaveAuraPosX(auraName, auraPosX)
	self.svars.auraData[auraName]['posX'] = auraPosX
end

function AuraMastery:SaveAuraPosY(auraName, auraPosY)
	self.svars.auraData[auraName]['posY'] = auraPosY
end

function AuraMastery:SaveAuraAlpha(auraName, auraAlpha)
	self.svars.auraData[auraName]['alpha'] = auraAlpha/100
end

function AuraMastery:SaveAuraShowCooldownAnimation(auraName, auraShowCooldownAnimation)
	self.svars.auraData[auraName].showCooldownAnimation = auraShowCooldownAnimation
end

function AuraMastery:SaveAuraShowCooldownText(auraName, auraShowCooldownText)
	self.svars.auraData[auraName].showCooldownText = auraShowCooldownText
end

function AuraMastery:SaveAuraCooldownFontSize(auraName, auraCooldownFontSize)
	self.svars.auraData[auraName]['cooldownFontSize'] = auraCooldownFontSize
end

function AuraMastery:SaveAuraBorderSize(auraName, auraBorderSize)
	self.svars.auraData[auraName]['borderSize'] = auraBorderSize
end

function AuraMastery:SaveAuraCritical(auraName, auraCritical)
	self.svars.auraData[auraName]['critical'] = auraCritical;
end

function AuraMastery:SaveAuraTextFontSize(auraName, auraTextFontSize)
	self.svars.auraData[auraName]['textFontSize'] = auraTextFontSize
end

function AuraMastery:SaveAuraText(auraName, auraText)
	self.svars.auraData[auraName]['text'] = auraText
end

function AuraMastery:SaveAuraTextPosition(auraName, auraTextPositionId)
	self.svars.auraData[auraName].auraTextPositionId = auraTextPositionId
end

function AuraMastery:SaveAuraEnabled(auraName, auraEnabled)
	self.svars.auraData[auraName].loaded = auraEnabled
end




--==========================================
-- 2.0 Trigger Settings --------------------
--==========================================



--
-- 2.1 Edit
--
function AuraMastery.EditTriggerAbilityId()
	local activeAura = AuraMastery.activeAura
	local activeTrigger = AuraMastery.activeTrigger
	local editBoxControl = AuraMasteryTriggerMenu_AbilityIdSubControl_Editbox
	local inputTriggerAbilityId = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidTriggerAbilityId(inputTriggerAbilityId)
	if (isValid) then
		AuraMastery:SaveTriggerAbilityId(activeAura, activeTrigger, inputTriggerAbilityId)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].spellId)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerSourceUnitTag(comboBox, itemText, item, selectionChanged)
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputTriggerSourceUnitTag = item.internalValue
	local isValid,msg,color	= AuraMastery:IsValidTriggerSourceUnitTag(inputTriggerSourceUnitTag)
	if (isValid) then
		AuraMastery:SaveTriggerSourceUnitTag(activeAura, activeTrigger, inputTriggerSourceUnitTag)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery:EditTriggerUnitTag()
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local editBoxControl = AuraMasteryTriggerMenu_UnitTagSubControl_Editbox
	local inputTriggerUnitTag = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color	= AuraMastery:IsValidTriggerUnitTag(inputTriggerUnitTag)
	if (isValid) then
		AuraMastery:SaveTriggerUnitTag(activeAura, activeTrigger, inputTriggerUnitTag)
		AuraMastery:ReloadAuraControl(activeAura)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].combatUnitTag)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerTargetName()			
	local editBoxControl = AuraMasteryTriggerMenu_TargetNameSubControl_Editbox
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputTriggerTargetName = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color = AuraMastery:IsValidTriggerTargetName(inputTriggerTargetName)
	if (isValid) then
		AuraMastery:SaveTriggerTargetName(activeAura, activeTrigger, inputTriggerTargetName)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].targetName)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerCasterName()
	local editBoxControl = WM:GetControlByName("AuraMasteryTriggerMenu_CasterNameSubControl_Editbox")
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputTriggerCasterName = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color	= AuraMastery:IsValidTriggerTargetName(inputTriggerCasterName)
	if (isValid) then
		AuraMastery:SaveTriggerCasterName(activeAura, activeTrigger, inputTriggerCasterName)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].casterName)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerDurationInfo(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local unitTag 				= AuraMastery:GetTableKey(AuraMastery.G.triggers.unitTags, itemText)
	local activeAura 			= AuraMastery.activeAura
	local activeTrigger			= AuraMastery.activeTrigger
	local isValid, msg, color	= AuraMastery:IsValidTriggerTarget(unitTag)

	if (isValid) then
		AuraMastery:SaveTriggerTarget(activeAura, activeTrigger, unitTag)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerSourceCombatUnitType(comboBox, itemText, item, selectionChanged)
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputTriggerSourceCombatUnitType = item.internalValue
	local isValid,msg,color	= AuraMastery:IsValidTriggerSourceCombatUnitType(inputTriggerSourceCombatUnitType)
	if (isValid) then
		AuraMastery:SaveTriggerSourceCombatUnitType(activeAura, activeTrigger, inputTriggerSourceCombatUnitType)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerIconInfo(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local unitTag 				= AuraMastery:GetTableKey(AuraMastery.G.triggers.unitTags, itemText)
	local activeAura 			= AuraMastery.activeAura
	local activeTrigger			= AuraMastery.activeTrigger
	local isValid, msg, color	= AuraMastery:IsValidTriggerTarget(unitTag)

	if (isValid) then
		AuraMastery:SaveTriggerTarget(activeAura, activeTrigger, unitTag)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerType(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local triggerTypeId = item.internalValue
	local isValid, msg, color	= AuraMastery:IsValidTriggerType(triggerTypeId)

	if (isValid) then
		local activeAura 				= AuraMastery.activeAura;
		local activeTrigger			= AuraMastery.activeTrigger;
		AuraMastery:SaveTriggerType(activeAura, activeTrigger, triggerTypeId)
		AuraMastery:RemoveInvalidTriggerTypeDataFromSVars()
		AuraMastery:AddRequiredTriggerTypeDataToSVars()
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateTriggerMenu()
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	end
	AuraMastery:SetNotification(msg, color);
end

function AuraMastery.EditTriggerOperator(comboBox, itemText, item, selectionChanged)		-- predefined form input
	if not(selectionChanged) then return; end

	local operator 				= AuraMastery:GetTableKey(AuraMastery.G.triggers.operators, itemText)
	local activeAura 			= AuraMastery.activeAura;
	local activeTrigger			= AuraMastery.activeTrigger;
	local isValid, msg, color	= AuraMastery:IsValidTriggerOperator(operator);

	if (isValid) then
		AuraMastery:SaveTriggerOperator(activeAura, activeTrigger, operator);
		AuraMastery:ReloadAuraControl(activeAura);
	end
	AuraMastery:SetNotification(msg, color);
end

function AuraMastery.EditTriggerValue()
	local activeAura = AuraMastery.activeAura;
	local activeTrigger	= AuraMastery.activeTrigger;
	local editBoxControl = AuraMasteryTriggerMenu_ValueSubControl_Editbox
	local inputTriggerValue = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidTriggerValue(inputTriggerValue)
	if (isValid) then
		AuraMastery:SaveTriggerValue(activeAura, activeTrigger, inputTriggerValue)
		AuraMastery:ReloadAuraControl(activeAura)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].value)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditTriggerCheckAll()
	local activeAura 		 = AuraMastery.activeAura
	local activeTrigger		 = AuraMastery.activeTrigger
	local checkButtonControl = AuraMasteryTriggerMenu_CheckAllSubControl
	if ZO_CheckButton_IsChecked(checkButtonControl) then
		AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].checkAll = true
	else
		AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].checkAll = false
	end
	AuraMastery:ReloadAuraControl(activeAura)
end

function AuraMastery.EditTriggerInvert()
	local activeAura 		 = AuraMastery.activeAura
	local activeTrigger		 = AuraMastery.activeTrigger
	local checkButtonControl = AuraMasteryTriggerMenu_InvertSubControl
	if ZO_CheckButton_IsChecked(checkButtonControl) then
		AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].invert = true
	else
		AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].invert = false
	end
	AuraMastery:ReloadAuraControl(activeAura)
	AuraMastery:UpdateTriggerMenu()	-- neccessary as elements are modified based on if this is checked or not
	AuraMastery:UpdateAuraTextMenu() -- neccessary as inverted trigger do not contain any event info which is written as a note into the text info menu
end

function AuraMastery.EditTriggerDuration()
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local editBoxControl = AuraMasteryTriggerMenu_DurationSubControl_Editbox 
	local inputTriggerDuration = zo_strtrim(editBoxControl:GetText())
	if "" ~= inputTriggerDuration then inputTriggerDuration = tonumber(inputTriggerDuration); end
	local isValid,msg,color	= AuraMastery:IsValidTriggerDuration(inputTriggerDuration)
	
	if (isValid) then
		AuraMastery:SaveTriggerDuration(activeAura, activeTrigger, inputTriggerDuration)
		AuraMastery:ReloadAuraControl(activeAura)
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].duration)
	end

	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end



--
-- 2.2 Validate
--
function AuraMastery:IsValidTriggerType(inputTriggerType)
	local activeAura = self.activeAura or "Aura"
	local activeTrigger = self.activeTrigger or "Trigger"
	local msg,rv,color
	if self.G.triggers.triggerTypes[inputTriggerType] then
		rv,msg,color = true, "\""..activeAura.."\"'s type for trigger "..activeTrigger.." has been set to \""..self.G.triggers.triggerTypes[inputTriggerType].."\".", C_PASS
	else
		rv,msg,color = false, "Please enter a valid trigger type \"Buff/Debuff\" or \"Fake effect\" or \"Combat event\" or \"Custom\".", C_ERR
	end
	return rv,msg,color
end

function AuraMastery:IsValidTriggerAbilityId(inputTriggerAbilityId)
	local activeAura = self.activeAura or "Aura";
	local activeTrigger = self.activeTrigger or "";
	local msg,rv,color;
	if nil == inputTriggerAbilityId or 0 ~= inputTriggerAbilityId%1 or 0 >= inputTriggerAbilityId then
		rv,msg,color = false, "Please enter a valid ability id.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s ability id for trigger "..activeTrigger.." has been set to "..inputTriggerAbilityId..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidTriggerSourceUnitTag(inputTriggerSourceUnitTag)
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	local msg,rv,color
	rv,msg,color = true, "\""..activeAura.."\"'s unit tag for trigger "..activeTrigger.." has been set to "..inputTriggerSourceUnitTag..".", C_PASS;
	return rv,msg,color
end

function AuraMastery:IsValidTriggerSourceCombatUnitType(inputTriggerSourceCombatUnitType)
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	if not inputTriggerSourceCombatUnitType then inputTriggerSourceCombatUnitType = "anyone" end
	local msg,rv,color
	rv,msg,color = true, "\""..activeAura.."\"'s source combat unit tag for trigger "..activeTrigger.." has been set to "..inputTriggerSourceCombatUnitType..".", C_PASS
	return rv,msg,color
end

function AuraMastery:IsValidTriggerUnitTag(inputTriggerUnitTag)
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	local msg,rv,color
	rv,msg,color = true, "\""..activeAura.."\"'s unit tag for trigger "..activeTrigger.." has been set to "..inputTriggerUnitTag..".", C_PASS
	return rv,msg,color
end

function AuraMastery:IsValidTriggerTarget(inputTriggerTarget)
	local activeAura = self.activeAura or "Aura";
	local activeTrigger = self.activeTrigger or "Trigger";
	local msg,rv,color;
	if self.G.triggers.unitTags[inputTriggerTarget] then
		rv,msg,color = true, "\""..activeAura.."\"'s target for trigger "..activeTrigger.." has been set to \""..self.G.triggers.unitTags[inputTriggerTarget].."\".", C_PASS;
	else
		rv,msg,color = false, "Please enter a valid target (\"Player\" or \"Target\").", C_ERR;	
	end
	return rv,msg,color;
end

function AuraMastery:IsValidTriggerTargetName(inputTriggerTargetName)
	local activeAura = self.activeAura or "Aura"
	local activeTrigger = self.activeTrigger or "Trigger"
	local msg,rv,color;
	return true, "Caster or Target Name has been set to "..inputTriggerTargetName.." for "..activeTrigger..".", C_PASS --return rv,msg,color;
end

function AuraMastery:IsValidTriggerOperator(inputTriggerOperator)
	local activeAura = self.activeAura or "Aura";
	local activeTrigger = self.activeTrigger or "Trigger";
	local msg,rv,color;
	if self.G.triggers.operators[inputTriggerOperator] then
		rv,msg,color = true, "\""..activeAura.."\"'s operator for trigger "..activeTrigger.." has been set to \""..self.G.triggers.operators[inputTriggerOperator].."\".", C_PASS;
	else
		rv,msg,color = false, "Please select a valid operator.", C_ERR;	
	end
	return rv,msg,color;
end

function AuraMastery:IsValidTriggerValue(inputTriggerValue)
	local activeAura = self.activeAura or "Aura";
	local activeTrigger = self.activeTrigger or "Trigger";
	local msg,rv,color;
	if nil == inputTriggerValue or 0 > inputTriggerValue  then
		rv,msg,color = false, "Only values greater than or equal to 0 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s value for trigger "..activeTrigger.." has been set to "..inputTriggerValue..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:IsValidTriggerCheckAll(inputTriggerCheckAll)
	local activeAura = self.activeAura or "Aura";
	if "boolean" == type(inputTriggerCheckAll) then return true; else return false; end
end

function AuraMastery:IsValidTriggerInvertLogic(inputTriggerInvertLogic)
	local activeAura = self.activeAura or "Aura";
	if "boolean" == type(inputTriggerInvertLogic) then return true; else return false; end
end



--
-- 2.3 Save to SVars
--
function AuraMastery:AddRequiredTriggerTypeDataToSVars()
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	local triggerData = self.svars.auraData[activeAura].triggers[activeTrigger]
	local triggerDefaults = AuraMastery.G.triggerDefaults[triggerData.triggerType]
	
	for field, defaultValue in pairs(triggerDefaults.required) do
		if not triggerData[field] then
--deb("Field "..field.." is required for trigger type "..triggerData.triggerType..". Adding.")
			self.svars.auraData[activeAura].triggers[activeTrigger][field] = defaultValue
		end
	end
end

function AuraMastery:RemoveInvalidTriggerTypeDataFromSVars()
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	local triggerData = self.svars.auraData[activeAura].triggers[activeTrigger]
	local triggerDefaults = AuraMastery.G.triggerDefaults[triggerData.triggerType]
	
	for field, _ in pairs(triggerData) do
		if not triggerDefaults.allowed[field] then
--deb("Field "..field.." is not allowed for trigger type "..triggerData.triggerType..". Removing.")
			self.svars.auraData[activeAura].triggers[activeTrigger][field] = nil
		end
	end
end

function AuraMastery:SaveTriggerAbilityId(auraName, triggerIndex, triggerAbilityId)
	self.svars.auraData[auraName].triggers[triggerIndex].spellId = triggerAbilityId
end

-- special case for buff/debuff triggers as currently only the unit tags "player" and "target" (= "reticleover") are supported
function AuraMastery:SaveTriggerSourceUnitTag(auraName, triggerIndex, triggerSourceUnitTag)
	self.svars.auraData[auraName].triggers[triggerIndex].unitTag = triggerSourceUnitTag
end

function AuraMastery:SaveTriggerUnitTag(auraName, triggerIndex, triggerUnitTag)
	self.svars.auraData[auraName].triggers[triggerIndex].combatUnitTag = triggerUnitTag
end

function AuraMastery:SaveTriggerSourceCombatUnitType(auraName, triggerIndex, sourceCombatUnitType)
	self.svars.auraData[auraName].triggers[triggerIndex].sourceCombatUnitType = sourceCombatUnitType or nil -- if "anyone" is selected to be the combatUnitType, delete it from svars
end

function AuraMastery:SaveTriggerTarget(auraName, triggerIndex, triggerTarget)
	self.svars.auraData[auraName].triggers[triggerIndex].unitTag = triggerTarget
end

function AuraMastery:SaveTriggerCasterName(auraName, triggerIndex, triggerCasterName)
	self.svars.auraData[auraName].triggers[triggerIndex].casterName = triggerCasterName
end

function AuraMastery:SaveTriggerTargetName(auraName, triggerIndex, triggerTargetName)
	self.svars.auraData[auraName].triggers[triggerIndex].targetName = triggerTargetName
end

function AuraMastery:SaveTriggerType(auraName, triggerIndex, triggerType)
	self.svars.auraData[auraName].triggers[triggerIndex].triggerType = triggerType
end

function AuraMastery:SaveTriggerOperator(auraName, triggerIndex, triggerOperator)
	self.svars.auraData[auraName].triggers[triggerIndex].operator = triggerOperator;
end

function AuraMastery:SaveTriggerValue(auraName, triggerIndex, triggerValue)
	self.svars.auraData[auraName].triggers[triggerIndex].value = triggerValue;
end

function AuraMastery:SaveTriggerDuration(auraName, triggerIndex, triggerDuration)
	if "" == triggerDuration then
		self.svars.auraData[auraName].triggers[triggerIndex].duration = nil;
	else
		self.svars.auraData[auraName].triggers[triggerIndex].duration = triggerDuration
	end
end




--=================================================
-- 3.0 Custom Trigger Settings --------------------
--=================================================



--
-- 3.1 Edit
--
function AuraMastery.EditCustomTriggerEvent(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end
	local eventCode = item.internalValue	
	local isValid, msg, color = AuraMastery:IsValidCustomTriggerEvent(eventCode)

	if (isValid) then
		local activeAura 			= AuraMastery.activeAura
		local activeTrigger			= AuraMastery.activeTrigger
		AuraMastery:SaveCustomTriggerEvent(activeAura, activeTrigger, eventCode)
		AuraMastery:RemoveInvalidCustomTriggerTypeDataFromSVars()
		AuraMastery:AddRequiredCustomTriggerTypeDataToSVars()
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateCustomTriggerMenu()
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomTriggerAbilityId()
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local editBoxControl = AuraMasteryCustomTriggerAbilityIdSubControl_Editbox
	local inputCustomTriggerAbilityId = tonumber(zo_strtrim(editBoxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidTriggerAbilityId(inputCustomTriggerAbilityId)
	if (isValid) then
		AuraMastery:SaveCustomTriggerAbilityId(activeAura, activeTrigger, inputCustomTriggerAbilityId)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.abilityId)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomTriggerChangeType(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local changeType 			= AuraMastery:GetTableKey(AuraMastery.G.changeTypes, itemText)
	local activeAura 			= AuraMastery.activeAura
	local activeTrigger			= AuraMastery.activeTrigger
	local isValid, msg, color	= AuraMastery:IsValidCustomTriggerChangeType(changeType)

	if (isValid) then
		AuraMastery:SaveCustomTriggerChangeType(activeAura, activeTrigger, changeType)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomTriggerUnitTag(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local unitTag 				= AuraMastery:GetTableKey(AuraMastery.G.triggers.unitTags, itemText)
	local activeAura 			= AuraMastery.activeAura
	local activeTrigger			= AuraMastery.activeTrigger
	local isValid, msg, color	= AuraMastery:IsValidTriggerTarget(unitTag)

	if (isValid) then
		AuraMastery:SaveCustomTriggerUnitTag(activeAura, activeTrigger, unitTag)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomTriggerSourceName()
	local editBoxControl = AuraMasteryCustomTriggerSourceNameSubControl_Editbox
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputCustomTriggerSourceName = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color	= AuraMastery:IsValidTriggerTargetName(inputCustomTriggerSourceName)
	if (isValid) then
		AuraMastery:SaveCustomTriggerSourceName(activeAura, activeTrigger, inputCustomTriggerSourceName)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.sourceName)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomTriggerTargetName()			
	local editBoxControl = AuraMasteryCustomTriggerTargetNameSubControl_Editbox
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputCustomTriggerTargetName = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color	= AuraMastery:IsValidTriggerTargetName(inputCustomTriggerTargetName)
	if (isValid) then
		AuraMastery:SaveCustomTriggerTargetName(activeAura, activeTrigger, inputCustomTriggerTargetName)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.targetName)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomTriggerActionResult(control)
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local triggerType = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].triggerType

	if 3 ~= triggerType then return; end	

	local controlName 				= control:GetName()
	local actionResultActivated 	= "On" == control:GetNamedChild("_Label"):GetText()
	local actionResults = AuraMastery.codes.combatEventActionResults
	local triggerActionResults = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults
	local label = control:GetNamedChild("_Label")
	local parent = control:GetParent()
	local actionResultCode = parent.actionResultCode
	
	if actionResultActivated then
		if triggerActionResults then
			local index = table.contains(triggerActionResults, actionResultCode)
			if index then
				table.remove(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults, index)
--[[
d("REMOVE:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
d("Index "..index)
]]
			end			
		end
		
		label:SetText("Off")
		label:SetColor(1,0,0)
	else
		if not triggerActionResults then
			AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults = {}
			triggerActionResults = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults	-- reassign local table from updated svar table
			table.insert(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults, actionResultCode)
--[[
d("INSERT:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
]]
		else
			local index = table.contains(triggerActionResults, actionResultCode)
			if not index then
				table.insert(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData.actionResults, actionResultCode)
--[[
d("INSERT:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
]]
			end
		end	
		label:SetText("On")
		label:SetColor(0,1,0)
	end
	--AuraMastery:UpdateCustomTriggerActionResultsScrollList()
	AuraMastery:ReloadAuraControl(activeAura)
end



--
-- 3.2 Validate
--
function AuraMastery:IsValidCustomTriggerEvent(inputEventCode)
	local activeAura = self.activeAura or "Aura"
	local activeTrigger = self.activeTrigger or "Trigger"
	local msg,rv,color
	if self.G.eventTypes[inputEventCode] then
		rv,msg,color = true, "\""..activeAura.."\"'s event for custom trigger "..activeTrigger.." has been set to \""..self.G.eventTypes[inputEventCode].."\".", C_PASS
	else
		rv,msg,color = false, "Please enter a valid custom trigger event type \"Buff/Debuff\" or \"Fake effect\" or \"Combat event\".", C_ERR	
	end
	return rv,msg,color
end

function AuraMastery:IsValidCustomTriggerChangeType(inputCustomTriggerChangeType)
	local activeAura = self.activeAura or "Aura"
	local activeTrigger = self.activeTrigger or "Trigger"
	local msg,rv,color
	if 1 == inputCustomTriggerChangeType or 2 == inputCustomTriggerChangeType or 3 == inputCustomTriggerChangeType then
		rv,msg,color = true, "\""..activeAura.."\"'s target for trigger "..activeTrigger.." has been set to \""..inputCustomTriggerChangeType.."\".", C_PASS;
	else
		rv,msg,color = false, "Please enter a valid change type (\"1\" or \"2\") or \"3\".", C_ERR;	
	end
	return rv,msg,color;
end



--
-- 3.3 Save to SVars
--
function AuraMastery:AddRequiredCustomTriggerTypeDataToSVars()
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	local customTriggerData = self.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData
	local customTriggerDefaults = AuraMastery.G.customTriggerDefaults[customTriggerData.eventType]

	for field, defaultValue in pairs(customTriggerDefaults.required) do
		if not customTriggerData[field] then
--deb("Field "..field.." is required for custom trigger type "..customTriggerData.eventType..". Adding.")
			self.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData[field] = defaultValue
		end
	end
end

function AuraMastery:RemoveInvalidCustomTriggerTypeDataFromSVars()
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	local customTriggerData = self.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData
	local customTriggerDefaults = AuraMastery.G.customTriggerDefaults[customTriggerData.eventType]
	
	for field, _ in pairs(customTriggerData) do
		if not customTriggerDefaults.allowed[field] then
--deb("Field "..field.." is not allowed for custom trigger type "..customTriggerData.eventType..". Removing.")
			self.svars.auraData[activeAura].triggers[activeTrigger].customTriggerData[field] = nil
		end
	end
end

function AuraMastery:SaveCustomTriggerEvent(auraName, triggerIndex, eventCode)
	self.svars.auraData[auraName].triggers[triggerIndex].customTriggerData.eventType = eventCode
end

function AuraMastery:SaveCustomTriggerAbilityId(auraName, triggerIndex, customTriggerAbilityId)
	self.svars.auraData[auraName].triggers[triggerIndex].customTriggerData.abilityId = customTriggerAbilityId
end

function AuraMastery:SaveCustomTriggerChangeType(auraName, triggerIndex, customTriggerChangeType)
	self.svars.auraData[auraName].triggers[triggerIndex].customTriggerData.changeType = customTriggerChangeType
end

function AuraMastery:SaveCustomTriggerUnitTag(auraName, triggerIndex, customTriggerUnitTag)
	self.svars.auraData[auraName].triggers[triggerIndex].customTriggerData.unitTag = customTriggerUnitTag
end

function AuraMastery:SaveCustomTriggerSourceName(auraName, triggerIndex, customTriggerSourceName)
	self.svars.auraData[auraName].triggers[triggerIndex].customTriggerData.sourceName = customTriggerSourceName
end

function AuraMastery:SaveCustomTriggerTargetName(auraName, triggerIndex, customTriggerTargetName)
	self.svars.auraData[auraName].triggers[triggerIndex].customTriggerData.targetName = customTriggerTargetName
end




--===================================================
-- 4.0 Custom Untrigger Settings --------------------
--===================================================



--
-- 4.1 Edit
--
function AuraMastery.EditCustomUntriggerEvent(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end
	local eventCode = item.internalValue	
	local isValid, msg, color = AuraMastery:IsValidCustomTriggerEvent(eventCode)

	if (isValid) then
		local activeAura 			= AuraMastery.activeAura
		local activeTrigger			= AuraMastery.activeTrigger
		AuraMastery:SaveCustomUntriggerEvent(activeAura, activeTrigger, eventCode)
		AuraMastery:RemoveInvalidCustomUntriggerTypeDataFromSVars()
		AuraMastery:AddRequiredCustomUntriggerTypeDataToSVars()
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateCustomUntriggerMenu()
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomUntriggerAbilityId()
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local editBoxcontrol = AuraMasteryCustomUntriggerAbilityIdSubControl_Editbox
	local inputCustomUntriggerAbilityId 	= tonumber(zo_strtrim(editBoxcontrol:GetText()))
	local isValid,msg,color			= AuraMastery:IsValidTriggerAbilityId(inputCustomUntriggerAbilityId)
	if (isValid) then
		AuraMastery:SaveCustomUntriggerAbilityId(activeAura, activeTrigger, inputCustomUntriggerAbilityId)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxcontrol:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.abilityId)
	end
	editBoxcontrol:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomUntriggerChangeType(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local changeType 			= AuraMastery:GetTableKey(AuraMastery.G.changeTypes, itemText)
	local activeAura 			= AuraMastery.activeAura
	local activeTrigger			= AuraMastery.activeTrigger
	local isValid, msg, color	= AuraMastery:IsValidCustomTriggerChangeType(changeType)

	if (isValid) then
		AuraMastery:SaveCustomUntriggerChangeType(activeAura, activeTrigger, changeType)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomUntriggerUnitTag(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end

	local unitTag 				= AuraMastery:GetTableKey(AuraMastery.G.triggers.unitTags, itemText)
	local activeAura 			= AuraMastery.activeAura
	local activeTrigger			= AuraMastery.activeTrigger
	local isValid, msg, color	= AuraMastery:IsValidTriggerTarget(unitTag)

	if (isValid) then
		AuraMastery:SaveCustomUntriggerUnitTag(activeAura, activeTrigger, unitTag)
		AuraMastery:ReloadAuraControl(activeAura)
	end
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomUntriggerSourceName()
	local editBoxControl = AuraMasteryCustomUntriggerSourceNameSubControl_Editbox
	local activeAura = AuraMastery.activeAura
	local activeTrigger = AuraMastery.activeTrigger
	local inputCustomUntriggerSourceName = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color = AuraMastery:IsValidTriggerTargetName(inputCustomUntriggerSourceName)
	if (isValid) then
		AuraMastery:SaveCustomUntriggerSourceName(activeAura, activeTrigger, inputCustomUntriggerSourceName)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.sourceName)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomUntriggerTargetName()
	local editBoxControl = AuraMasteryCustomUntriggerTargetNameSubControl_Editbox
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local inputCustomUntriggerTargetName = zo_strtrim(editBoxControl:GetText())
	local isValid,msg,color			= AuraMastery:IsValidTriggerTargetName(inputCustomUntriggerTargetName)
	if (isValid) then
		AuraMastery:SaveCustomUntriggerTargetName(activeAura, activeTrigger, inputCustomUntriggerTargetName)
		AuraMastery:ReloadAuraControl(activeAura)
		AuraMastery:UpdateIconInfoSelect()
		AuraMastery:UpdateDurationInfoSelect()
	else
		editBoxControl:SetText(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.targetName)
	end
	editBoxControl:LoseFocus()
	AuraMastery:EditBoxOnMouseExit(editBoxControl)
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery.EditCustomUntriggerActionResult(control)
	local activeAura = AuraMastery.activeAura
	local activeTrigger	= AuraMastery.activeTrigger
	local triggerType = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].triggerType

	if 3 ~= triggerType then return; end	

	local controlName 				= control:GetName()
	local actionResultActivated 	= "On" == control:GetNamedChild("_Label"):GetText()
	local actionResults = AuraMastery.codes.combatEventActionResults
	local untriggerActionResults = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults
	local label = control:GetNamedChild("_Label")
	local parent = control:GetParent()
	local actionResultCode = parent.actionResultCode
	
	if actionResultActivated then
		if untriggerActionResults then
			local index = table.contains(untriggerActionResults, actionResultCode)
			if index then
				table.remove(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults, index)
--[[
d("REMOVE:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
d("Index "..index)
]]
			end			
		end
		
		label:SetText("Off")
		label:SetColor(1,0,0)
	else
		if not untriggerActionResults then
			AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults = {}
			untriggerActionResults = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults	-- reassign local table from updated svar table
			table.insert(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults, actionResultCode)
--[[
d("INSERT:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
]]
		else
			local index = table.contains(untriggerActionResults, actionResultCode)
			if not index then
				table.insert(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData.actionResults, actionResultCode)
--[[
d("INSERT:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
]]
			end
		end	
		label:SetText("On")
		label:SetColor(0,1,0)
	end
	--AuraMastery:UpdateCustomUntriggerActionResultsScrollList()
	AuraMastery:ReloadAuraControl(activeAura)
end



--
-- 4.2 Validate
--



--
-- 4.3 Save to Svars
--
function AuraMastery:AddRequiredCustomUntriggerTypeDataToSVars()
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	local customUntriggerData = self.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData
	local customTriggerDefaults = AuraMastery.G.customTriggerDefaults[customUntriggerData.eventType]

	for field, defaultValue in pairs(customTriggerDefaults.required) do
		if not customUntriggerData[field] then
--deb("Field "..field.." is required for custom trigger type "..customUntriggerData.eventType..". Adding.")
			self.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData[field] = defaultValue
		end
	end
end

function AuraMastery:RemoveInvalidCustomUntriggerTypeDataFromSVars()
	local activeAura = self.activeAura
	local activeTrigger = self.activeTrigger
	
	local customUntriggerData = self.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData
	local customTriggerDefaults = AuraMastery.G.customTriggerDefaults[customUntriggerData.eventType]
	
	for field, _ in pairs(customUntriggerData) do
		if not customTriggerDefaults.allowed[field] then
--deb("Field "..field.." is not allowed for custom trigger type "..customUntriggerData.eventType..". Removing.")
			self.svars.auraData[activeAura].triggers[activeTrigger].customUntriggerData[field] = nil
		end
	end
end

function AuraMastery:SaveCustomUntriggerEvent(auraName, triggerIndex, eventCode)
	self.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData.eventType = eventCode
end

function AuraMastery:SaveCustomUntriggerAbilityId(auraName, triggerIndex, customUntriggerAbilityId)
	self.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData.abilityId = customUntriggerAbilityId
end

function AuraMastery:SaveCustomUntriggerChangeType(auraName, triggerIndex, customUntriggerChangeType)
	self.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData.changeType = customUntriggerChangeType
end

function AuraMastery:SaveCustomUntriggerUnitTag(auraName, triggerIndex, customUntriggerUnitTag)
	self.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData.unitTag = customUntriggerUnitTag
end

function AuraMastery:SaveCustomUntriggerSourceName(auraName, triggerIndex, customUntriggerSourceName)
	self.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData.sourceName = customUntriggerSourceName
end

function AuraMastery:SaveCustomUntriggerTargetName(auraName, triggerIndex, customUntriggerTargetName)
	self.svars.auraData[auraName].triggers[triggerIndex].customUntriggerData.targetName = customUntriggerTargetName
end




-- Create and initialize
function AuraMastery:CreateAuraGroupAssignment()
	local control = WM:GetControlByName("AuraMasteryDisplayMenu_AuraGroupAssignmentContainer")
	control.data = {tooltipText = "Select a group to assign this aura to it."}

	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	AuraMastery.controls.pool['auraGroupAssignment'] = control
end

function AuraMastery:CreateIconInfoSelect()
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraIcon")

	parent.data = {}
	parent:SetHeight(58)

	local icons = AuraMastery.rawIconsData
--[[
	type = "iconpicker", -- the widget type of this control
   name = "My Iconpicker", -- the text to display for the icon picker
   tooltip = "Iconpicker's tooltip text.", -- (optional) the tooltip to display for the texture
   choices = {}, -- a table containing all icon pathes for the icons to display in the icon picker menu
   choicesTooltips = {"Icon1's tooltip text.", "Icon2's tooltip text.", "Icon3's tooltip text.", "Icon4's tooltip text."}, -- (optional) a table containing tooltips for each icon in the choices table
   getFunc = function() end, -- the function to call that provides the value (string) of this setting
   setFunc = function() end, -- the function that will be called when the value is changed - passes through one returns value (string)
   --maxColumns = 2, --(optional) number of icons in one row
   -- visibleRows = 6, -- (optional) number of visible rows
   --iconSize = number -- (optional) size of the icons
   --width = "half", -- (optional) "full" or "half" width in the panel
   --beforeShow = function() end, -- (optional) callback that is called before the icon selection menu is shown, gets passed the widget control and iconPicker control, returns preventShow boolean
   --disabled = function or boolean -- (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
   --warning = "string" -- (optional) will enable a warning icon for this control with this text as its tooltip
   --default = "string" -- (optional) the default texture path for this setting (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
   --reference = "string" -- (optional) unique global reference to this control
   },]]

	local	iconSelect = LAMCreateControl.iconpicker(parent, {
		type = "iconpicker",
		name = "",
		tooltip = "Select an Icon.",
		choices = icons,
		choicesTooltips = icons,
		--sort = "name-up", --or "name-down", "numeric-up", "numeric-down" (optional) - if not provided, list will not be sorted
		getFunc = function() end,
		setFunc = AuraMastery.EditAuraIcon,
		maxColumns = 20,
		visibleRows = 10,
		iconSize = 40,
		reference = "AuraMasteryDisplayMenu_IconSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(TOPRIGHT, parent, TOPRIGHT, 6, 7)
	iconSelect:SetDrawTier(2)
end

function AuraMastery:CreateIconSelect()
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraIcon")

	parent.data = {}
	parent:SetHeight(58)

	local icons = AuraMastery.rawIconsData
--[[
	type = "iconpicker", -- the widget type of this control
   name = "My Iconpicker", -- the text to display for the icon picker
   tooltip = "Iconpicker's tooltip text.", -- (optional) the tooltip to display for the texture
   choices = {}, -- a table containing all icon pathes for the icons to display in the icon picker menu
   choicesTooltips = {"Icon1's tooltip text.", "Icon2's tooltip text.", "Icon3's tooltip text.", "Icon4's tooltip text."}, -- (optional) a table containing tooltips for each icon in the choices table
   getFunc = function() end, -- the function to call that provides the value (string) of this setting
   setFunc = function() end, -- the function that will be called when the value is changed - passes through one returns value (string)
   --maxColumns = 2, --(optional) number of icons in one row
   -- visibleRows = 6, -- (optional) number of visible rows
   --iconSize = number -- (optional) size of the icons
   --width = "half", -- (optional) "full" or "half" width in the panel
   --beforeShow = function() end, -- (optional) callback that is called before the icon selection menu is shown, gets passed the widget control and iconPicker control, returns preventShow boolean
   --disabled = function or boolean -- (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
   --warning = "string" -- (optional) will enable a warning icon for this control with this text as its tooltip
   --default = "string" -- (optional) the default texture path for this setting (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
   --reference = "string" -- (optional) unique global reference to this control
   },]]

	local	iconSelect = LAMCreateControl.iconpicker(parent, {
		type = "iconpicker",
		name = "",
		tooltip = "Select an Icon.",
		choices = icons,
		choicesTooltips = icons,
		--sort = "name-up", --or "name-down", "numeric-up", "numeric-down" (optional) - if not provided, list will not be sorted
		getFunc = function() end,
		setFunc = AuraMastery.EditAuraIcon,
		maxColumns = 20,
		visibleRows = 10,
		iconSize = 40,
		reference = "AuraMasteryDisplayMenu_IconSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -14, 7)
	iconSelect:SetDrawTier(2)
end

function AuraMastery:CreateCooldownFontColorSelect()
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraCooldownFontColor")

	parent.data = {}

--[[
    type = "colorpicker" - the widget type of this control
    name = "string" - the text to display for this setting
    tooltip = "string" - the text to display in the tooltip
    getFunc = function - the function to call that provides the r, g, b[, a] numerical values this control should display (alpha is optional)
    setFunc = function - the function that will be called when this setting is changed - passes through four returns r, g, b, a (numbers)
    width = "string" - (optional) "full" or "half" width in the panel
    disabled = function or boolean - (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
    warning = "string" - (optional) will enable a warning icon for this control with this text as its tooltip
    default = table - (optional) the default values for this setting, stored in a table with r, g, b[, a] as its keys (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
    reference = "string" - (optional) unique global reference to this control
   },
]]

	local	iconSelect = LAMCreateControl.colorpicker(parent, {
		type = "colorpicker",
		name = "",
		tooltip = "Select font color.",
		getFunc = AuraMastery.GetAuraCooldownFontColor,
		setFunc = AuraMastery.EditAuraCooldownFontColor,
		reference = "AuraMasteryDisplayMenu_CooldownFontColorSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(RIGHT, parent, RIGHT, 5)
	iconSelect:SetDrawTier(2)
end

function AuraMastery:CreateTextFontColorSelect()
--[[
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraTextFontColor")

	parent.data = {}


    type = "colorpicker" - the widget type of this control
    name = "string" - the text to display for this setting
    tooltip = "string" - the text to display in the tooltip
    getFunc = function - the function to call that provides the r, g, b[, a] numerical values this control should display (alpha is optional)
    setFunc = function - the function that will be called when this setting is changed - passes through four returns r, g, b, a (numbers)
    width = "string" - (optional) "full" or "half" width in the panel
    disabled = function or boolean - (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
    warning = "string" - (optional) will enable a warning icon for this control with this text as its tooltip
    default = table - (optional) the default values for this setting, stored in a table with r, g, b[, a] as its keys (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
    reference = "string" - (optional) unique global reference to this control
   },


	local	iconSelect = LAMCreateControl.colorpicker(parent, {
		type = "colorpicker",
		name = "",
		tooltip = "Select font color.",
		getFunc = AuraMastery.GetAuraTextFontColor,
		setFunc = AuraMastery.EditAuraTextFontColor,
		reference = "AuraMasteryDisplayMenu_TextFontColorSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(RIGHT, parent, RIGHT, 5)
	iconSelect:SetDrawTier(2)
	]]
end

function AuraMastery:CreateAnimationColorColorSelect()
	local parent = AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationColor
	parent.data = {}

--[[
    type = "colorpicker" - the widget type of this control
    name = "string" - the text to display for this setting
    tooltip = "string" - the text to display in the tooltip
    getFunc = function - the function to call that provides the r, g, b[, a] numerical values this control should display (alpha is optional)
    setFunc = function - the function that will be called when this setting is changed - passes through four returns r, g, b, a (numbers)
    width = "string" - (optional) "full" or "half" width in the panel
    disabled = function or boolean - (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
    warning = "string" - (optional) will enable a warning icon for this control with this text as its tooltip
    default = table - (optional) the default values for this setting, stored in a table with r, g, b[, a] as its keys (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
    reference = "string" - (optional) unique global reference to this control
   },
]]

	local	iconSelect = LAMCreateControl.colorpicker(parent, {
		type = "colorpicker",
		name = "",
		disabled = function()
			return not ZO_CheckButton_IsChecked(AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEnabled_Checkbox)
		end,
		tooltip = "Select animation color.",
		getFunc = AuraMastery.GetAuraTriggerAnimationColors,
		setFunc = AuraMastery.EditAuraTriggerAnimationColor,
		reference = parent:GetName().."ColorSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(RIGHT, parent, RIGHT)
	iconSelect:SetDrawTier(2)
end

function AuraMastery:CreateBorderColorSelect()
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraBorderColor")

	parent.data = {}

--[[
    type = "colorpicker" - the widget type of this control
    name = "string" - the text to display for this setting
    tooltip = "string" - the text to display in the tooltip
    getFunc = function - the function to call that provides the r, g, b[, a] numerical values this control should display (alpha is optional)
    setFunc = function - the function that will be called when this setting is changed - passes through four returns r, g, b, a (numbers)
    width = "string" - (optional) "full" or "half" width in the panel
    disabled = function or boolean - (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
    warning = "string" - (optional) will enable a warning icon for this control with this text as its tooltip
    default = table - (optional) the default values for this setting, stored in a table with r, g, b[, a] as its keys (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
    reference = "string" - (optional) unique global reference to this control
   },
]]

	local	iconSelect = LAMCreateControl.colorpicker(parent, {
		type = "colorpicker",
		name = "",
		tooltip = "Select border color.",
		getFunc = AuraMastery.GetAuraBorderColor,
		setFunc = AuraMastery.EditAuraBorderColor,
		reference = "AuraMasteryDisplayMenu_BorderColorSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(RIGHT, parent, RIGHT, 5)
	iconSelect:SetDrawTier(2)
end

function AuraMastery:CreateBackgroundColorSelect()
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraBackgroundColor")

	parent.data = {}

--[[
    type = "colorpicker" - the widget type of this control
    name = "string" - the text to display for this setting
    tooltip = "string" - the text to display in the tooltip
    getFunc = function - the function to call that provides the r, g, b[, a] numerical values this control should display (alpha is optional)
    setFunc = function - the function that will be called when this setting is changed - passes through four returns r, g, b, a (numbers)
    width = "string" - (optional) "full" or "half" width in the panel
    disabled = function or boolean - (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
    warning = "string" - (optional) will enable a warning icon for this control with this text as its tooltip
    default = table - (optional) the default values for this setting, stored in a table with r, g, b[, a] as its keys (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
    reference = "string" - (optional) unique global reference to this control
   },
]]

	local	iconSelect = LAMCreateControl.colorpicker(parent, {
		type = "colorpicker",
		name = "",
		tooltip = "Select background color.",
		getFunc = AuraMastery.GetAuraBackgroundColor,
		setFunc = AuraMastery.EditAuraBackgroundColor,
		reference = "AuraMasteryDisplayMenu_BackgroundColorSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(RIGHT, parent, RIGHT, 5)
	iconSelect:SetDrawTier(2)
end

function AuraMastery:CreateBarColorSelect()
	local parent = WM:GetControlByName("AuraMasteryDisplayMenu_AuraBarColor")

	parent.data = {}

--[[
    type = "colorpicker" - the widget type of this control
    name = "string" - the text to display for this setting
    tooltip = "string" - the text to display in the tooltip
    getFunc = function - the function to call that provides the r, g, b[, a] numerical values this control should display (alpha is optional)
    setFunc = function - the function that will be called when this setting is changed - passes through four returns r, g, b, a (numbers)
    width = "string" - (optional) "full" or "half" width in the panel
    disabled = function or boolean - (optional) this control will be disabled if this field evaluates to true (your panel must have registerForRefresh set to true)
    warning = "string" - (optional) will enable a warning icon for this control with this text as its tooltip
    default = table - (optional) the default values for this setting, stored in a table with r, g, b[, a] as its keys (your panel must have registerForRefresh set to true to have access to the "Reset To Defaults" button in your panel)
    reference = "string" - (optional) unique global reference to this control
   },
]]

	local	iconSelect = LAMCreateControl.colorpicker(parent, {
		type = "colorpicker",
		name = "",
		tooltip = "Select bar color.",
		getFunc = AuraMastery.GetAuraBarColor,
		setFunc = AuraMastery.EditAuraBarColor,
		reference = "AuraMasteryDisplayMenu_BarColorSelect"
	})
	iconSelect:ClearAnchors()
	iconSelect:SetAnchor(RIGHT, parent, RIGHT, 5)
	iconSelect:SetDrawTier(2)
end

-- Get functions
function AuraMastery.GetAuraCooldownFontColor()
	local activeAura = AuraMastery.activeAura
	
	if nil ~= activeAura then
		local colors = AuraMastery.svars.auraData[activeAura].cooldownFontColor
		return colors.r, colors.g, colors.b, colors.a
	end
end

function AuraMastery.GetAuraTextFontColor()
	local activeAura = AuraMastery.activeAura
	
	if nil ~= activeAura then
		local colors = AuraMastery.svars.auraData[activeAura].textFontColor
		return colors.r, colors.g, colors.b, colors.a
	end
end

function AuraMastery.GetAuraBorderColor()
	local activeAura = AuraMastery.activeAura
	if nil ~= activeAura then
		local colors = AuraMastery.svars.auraData[activeAura].borderColor
		return colors.r, colors.g, colors.b, colors.a
	end
end

function AuraMastery.GetAuraBackgroundColor()
	local activeAura = AuraMastery.activeAura
	if nil ~= activeAura then
		local colors = AuraMastery.svars.auraData[activeAura].bgColor
		return colors.r, colors.g, colors.b, colors.a
	end
end

function AuraMastery.GetAuraBarColor()
	local activeAura = AuraMastery.activeAura
	if nil ~= activeAura then
		local colors = AuraMastery.svars.auraData[activeAura].barColor
		if nil ~= colors then
			return colors.r, colors.g, colors.b, colors.a
		end
	end
end

function AuraMastery.GetAuraTriggerAnimationColors()
	local activeAura = AuraMastery.activeAura
	--[[
	local animationData = AuraMastery.svars.auraData[activeAura].animationData
	
	if nil ~= activeAura then
		local animationColorsData = animationData and animationData.trigger and animationData.trigger.colors
		if animationColorsData then
			return unpack(animationColorsData)
		else
			return 1,1,1,1
		end
		
	end
	]]
end




--======================================
-- Aura Group Settings -----------------
--======================================

--
-- This is the group selection comboBox on the left side above the auras list
--
function AuraMastery:InitAurasGroupSelect()
	local control = WM:GetControlByName("AuraMasteryAuraMenu_GroupNumber")
	control.data = {tooltipText = "Click to select a Group."}
	
	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	AuraMastery.controls.pool['aurasGroupNumber'] = control
end

function AuraMastery:UpdateAurasGroupSelect()
	local control = WM:GetControlByName("AuraMasteryAuraMenu_GroupNumber")

	local m_comboBox = control.m_comboBox
	m_comboBox:SetSortsItems(false)  
	local itemSelectCallback = AuraMastery.LoadAuraGroup


	-- assign dropdown items to control object
	local items = {}
	local auraGroups = self.svars.groupsData
	items[1] = {name = "Ungrouped Auras", callback = itemSelectCallback, internalValue = 0}
	if auraGroups and 0 < #auraGroups then
		for i = 1, #auraGroups do
			local groupName = auraGroups[i].groupName
			items[i+1] = {name = groupName, callback = itemSelectCallback, internalValue = i}
		end
	end

	control.items = items
	AuraMastery:PopulateComboBoxCustom(m_comboBox, control.items, callback)
	m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	m_comboBox:SelectFirstItem(true) -- ignore callback on first load = true
end

function AuraMastery:InitAuraGroupsScrollList()
	local function setupDataRow(rowControl, rowData, scrollList)
		local nameLabel = rowControl:GetNamedChild("_Label")
		local groupId = rowData['groupId']
		local groupName = rowData['groupName']
		local control = rowControl
		control:GetNamedChild("_Label"):SetText(groupName)
		local exportButton = control:GetNamedChild("_ExportButton")
		exportButton:SetHandler("OnClicked", function() AuraMastery:DisplayExportAuraGroupWindow(groupId) end)
		local deleteButton = control:GetNamedChild("_DeleteButton")
		deleteButton:SetHandler("OnClicked", function() AuraMastery:DeleteAuraGroup(groupId) end)	
	end
	
	local parent = WM:GetControlByName("AuraMasteryMenu_EditAuraGroups")	
	local control = WM:CreateControlFromVirtual("AM_AuraGroupsScrollList", parent, "ZO_ScrollList")
	control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 140)
	control:SetDimensions(292, 640)

	backdrop = WM:CreateControl("$(parent)_Backdrop", control, CT_BACKDROP)
	backdrop:SetAnchorFill()
	backdrop:SetCenterColor(0,0,0,0)
	backdrop:SetEdgeTexture(nil, 1, 1, 1, 0)
	backdrop:SetEdgeColor(0,0,0)
	
	ZO_ScrollList_AddDataType(control, 1, "AM_AuraGroupsScrollListRowElement", 30, setupDataRow)
end

function AuraMastery:UpdateAuraGroupsScrollList()
    local activeAuragroup = self.activeAuragroup
	local scrollList = WM:GetControlByName("AM_AuraGroupsScrollList") 
    local dataList = ZO_ScrollList_GetDataList(scrollList)
    ZO_ScrollList_Clear(scrollList)
	
	local auraGroups = self.svars.groupsData
	
	for i=1, #auraGroups do
		local groupName = auraGroups[i].groupName
		local rowData = {
			['groupId'] = i,
			['groupName'] = groupName
		}
		dataList[#dataList+1] = ZO_ScrollList_CreateDataEntry(1, rowData, 1)	
	end
    ZO_ScrollList_Commit(scrollList)
end

function AuraMastery.LoadAuraGroup(comboBox, itemText, item, selectionChanged)
	if not selectionChanged then return; end
	local selectionValue = item.internalValue
	AuraMastery.activeAuragroup = 0 ~= selectionValue and item.internalValue or nil
	AuraMastery:UpdateAurasScrollList()
end

function AuraMastery:NewAuragroup(name, data)
	local name = zo_strtrim(name)
	local success = false
	if "" == name then 
		self:SetNotification("Error: Please enter a valid aura group name.", C_ERR)
		return success
	end
	local nameAvailable = self:CheckNewGroupName(name)
	
	if nameAvailable then
		success = true
		local groupData = data and data or {['groupName'] = name, ['elements'] = {}}
		table.insert(self.svars.groupsData, groupData)
		
		self:UpdateAurasGroupSelect()
		self:UpdateAuraGroupsScrollList()
		if data then
			AuraMastery:AM_ComboBox_SelectItemByName(AuraMasteryAuraMenu_GroupNumber.m_comboBox, name)
		end
	else
		self:SetNotification("Error: A group named "..name.." already exists.", C_ERR)
	end
	return success
end

function AuraMastery:CheckNewGroupName(testName)
	local free = true
	local auraGroups = self.svars.groupsData
	for i=1, #auraGroups do
		if (auraGroups[i]['groupName'] == testName) then
			return false
		end
	end
	return true
end

function AuraMastery:DeleteAuraGroup(groupId)
	local auraGroupName = self.svars.groupsData[groupId].groupName
	
	-- remove passed aura group from svars and set active aura group to nil (ungrouped)
	table.remove(self.svars.groupsData, groupId)
	self.activeAuragroup = nil
	
	-- update all affected display sections
	self:UpdateAuraGroupsScrollList()
	self:UpdateAurasGroupSelect()
	self:UpdateAurasScrollList()
	self:SetNotification("Aura Group \""..auraGroupName.."\" has been deleted and all affected auras have been ungrouped.", C_PASS)
end

function AuraMastery:GetAssignedAuraGroup(auraName)
	local auraGroups = self.svars.groupsData
	for i=1, #auraGroups do
		local groupElements = auraGroups[i]['elements']
		if table.contains(groupElements, auraName) then
			return i
		end
	end
	return false
end

function AuraMastery:AddAuraToAuraGroup(auraName, auraGroupId)
	table.insert(self.svars.groupsData[auraGroupId].elements, auraName)
end

function AuraMastery:RemoveAuraFromAuraGroups(auraName)
	local auraGroups = self.svars.groupsData
	for i=1, #auraGroups do
		local groupElements = auraGroups[i]['elements']
		for j=1, #groupElements do
			if auraName == groupElements[j]  then
				table.remove(self.svars.groupsData[i]['elements'], j)
			end
		end
	end
end




-- Untriggers
function AuraMastery:IsValidUntriggerType(inputUntriggerType)						-- only called by import function
	local activeAura = self.activeAura or "Aura";
	local activeUntrigger = 1 --self.activeTrigger or "Trigger";
	local msg,rv,color;
	if self.G.untriggers.untriggerTypes[inputUntriggerType] then
		rv,msg,color = true, "\""..activeAura.."\"'s type for untrigger "..activeUntrigger.." has been set to \""..self.G.untriggers.untriggerTypes[inputUntriggerType].."\".", C_PASS;
	else
		rv,msg,color = false, "Please enter a valid trigger type \"time-based\".", C_ERR;	
	end
	return rv,msg,color;
end


-- loading conditions

-- trigger event action results
function AuraMastery.EditTriggerEventDamage(control)
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local controlName 				= control:GetName()
	local actionResultActivated 	= "On" == control:GetNamedChild("_Label"):GetText()
	local actionResults = AuraMastery.codes.combatEventActionResults
	local triggerActionResults = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].actionResults
	local label = control:GetNamedChild("_Label")
	local parent = control:GetParent()
	local actionResultCode = parent.actionResultCode
	
	if actionResultActivated then
		if triggerActionResults then
			local index = table.contains(triggerActionResults, actionResultCode)
			if index then
				table.remove(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].actionResults, index)
--[[
d("REMOVE:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
d("Index "..index)
]]
			end			
		end
		
		label:SetText("Off")
		label:SetColor(1,0,0)
	else
		if not triggerActionResults then
			AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].actionResults = {}
			triggerActionResults = AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].actionResults	-- reassign local table from updated svar table
			table.insert(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].actionResults, actionResultCode)
--[[
d("INSERT:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
]]
		else
			local index = table.contains(triggerActionResults, actionResultCode)
			if not index then
				table.insert(AuraMastery.svars.auraData[activeAura].triggers[activeTrigger].actionResults, actionResultCode)
--[[
d("INSERT:")
d("AuraName: "..activeAura)
d("TriggerId: "..activeTrigger)
d("ActionResult: "..actionResultCode)
]]
			end
		end	
		label:SetText("On")
		label:SetColor(0,1,0)
	end
	AuraMastery:UpdateActionResultsScrollList()
	AuraMastery:ReloadAuraControl(activeAura)
end

function AuraMastery.DisplayTriggerActionResultsMenu()
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local control 					= WM:GetControlByName("AuraMasteryTriggerEventsWindow")
	AuraMastery:UpdateActionResultsScrollList()
	control:SetHidden(false)
end

function AuraMastery.DisplayCustomTriggerActionResultsMenu()
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local control 					= WM:GetControlByName("AuraMasteryCustomTriggerActionResultsWindow")
	AuraMastery:UpdateCustomTriggerActionResultsScrollList()
	control:SetHidden(false)
end

function AuraMastery.DisplayCustomUntriggerActionResultsMenu()
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local control 					= WM:GetControlByName("AuraMasteryCustomUntriggerActionResultsWindow")
	AuraMastery:UpdateCustomUntriggerActionResultsScrollList()
	control:SetHidden(false)
end

function AuraMastery.DisplayAuraActionsMenu()
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local control 					= WM:GetControlByName("AuraMasteryAuraActionsWindow")
	control:SetHidden(false)
end

function AuraMastery.DisplayCustomTriggerMenu()
	AuraMastery.activeTriggerType   = 3
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local activeTriggerType			= AuraMastery.activeTriggerType
	local control 					= WM:GetControlByName("AuraMasteryCustomTriggerWindow")
	AuraMastery:UpdateCustomTriggerMenu()
	control:SetHidden(false)
end

function AuraMastery.DisplayCustomUntriggerMenu()
	AuraMastery.activeTriggerType   = 3
	local activeAura 				= AuraMastery.activeAura
	local activeTrigger				= AuraMastery.activeTrigger
	local activeTriggerType			= AuraMastery.activeTriggerType
	local control 					= WM:GetControlByName("AuraMasteryCustomUntriggerWindow")
	AuraMastery:UpdateCustomUntriggerMenu()
	control:SetHidden(false)
end

function AuraMastery.DisplayAuraTextWindow()
	AuraMastery:UpdateAuraTextMenu()
	AuraMasteryAuraTextWindow:SetHidden(false)
end




-- Loading conditions
function AuraMastery.EditLoadingConditionInCombatOnly()
	local activeAura = AuraMastery.activeAura
	local control = WM:GetControlByName("AuraMasteryLoadingConditionsMenu_InCombatOnlyButton_Label")

	local inputState = AuraMastery:toboolean(zo_strtrim(control:GetText()))

	if true == inputState then
		AuraMastery.svars.auraData[activeAura].loadingConditions['inCombatOnly'] = false
		control:SetText("false")
	else
		AuraMastery.svars.auraData[activeAura].loadingConditions['inCombatOnly'] = true
		control:SetText("true")
	end
	AuraMastery:ReloadAuraControl(activeAura)
end



-- Triggers settings menu
function AuraMastery:InitTriggerSelect()
	local parent = WM:GetControlByName("TriggerSettings")
	local control = WM:GetControlByName("AuraMasteryAuraMenu_TriggerNumber")
	control.data = {tooltipText = "Click to select a trigger."}

	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	AuraMastery.controls.pool['triggerNumber'] = control
end

function AuraMastery:InitTriggerTypeSelect()
	local parent = WM:GetControlByName("TriggerSettings")
	local control = WM:GetControlByName("AuraMasteryTriggerMenu_TriggerTypeSubControl")
	control.data = {tooltipText = "Click to select the trigger condition type."}
	control.m_comboBox:SetSortsItems(false)   
	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	local itemSelectCallback = AuraMastery.EditTriggerType


	-- assign dropdown items to control object
	local items = {}
	local triggerTypes = AuraMastery.G.triggers.triggerTypes
	for i=1,#triggerTypes do
		items[i] = {name = triggerTypes[i], callback = itemSelectCallback, internalValue = i}
	end
	control.items = items
	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	AuraMastery.controls.pool['triggerTypeSelect'] = control
end

function AuraMastery:InitCustomTriggerTypeSelect()
	local control = WM:GetControlByName("AuraMasteryCustomTriggerWindowTriggerTypeSelectSubControl")
	control.data = {tooltipText = "Click to select the trigger condition type."}
	control.m_comboBox:SetSortsItems(false)   
	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	local itemSelectCallback = AuraMastery.EditCustomTriggerEvent


	-- assign dropdown items to control object
	local items = {}
	local eventTypes = AuraMastery.G.eventTypes
	for i=1,#eventTypes do
		items[i] = {name = eventTypes[i], callback = itemSelectCallback, internalValue = i}
	end
	control.items = items
	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	AuraMastery.controls.pool['customTriggerTypeSelect'] = control
end

function AuraMastery:InitCustomUntriggerTypeSelect()
	local control = WM:GetControlByName("AuraMasteryCustomUntriggerWindowUntriggerTypeSelectSubControl")
	control.data = {tooltipText = "Click to select the untrigger condition type."}
	control.m_comboBox:SetSortsItems(false)   
	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	local itemSelectCallback = AuraMastery.EditCustomUntriggerEvent


	-- assign dropdown items to control object
	local items = {}
	local eventTypes = AuraMastery.G.eventTypes
	for i=1,#eventTypes do
		items[i] = {name = eventTypes[i], callback = itemSelectCallback, internalValue = i}
	end
	control.items = items
	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	AuraMastery.controls.pool['customUntriggerTypeSelect'] = control
end

function AuraMastery:InitEventSelect()
	local control = WM:GetControlByName("AuraMasteryUntriggerMenu_eventNameSubControl")
	control.data = {tooltipText = "Click to select an event."}
	control.m_comboBox:SetSortsItems(false)   
	-- tooltip handlers
	control:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
	control:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

	local itemSelectCallback = AuraMastery.SelectUntriggerEvent


	-- assign dropdown items to control object
	-- trigger type elements are defined in prototriggers.lua, search for "AuraMastery.G"
	local items = {}
	local triggerTypes = AuraMastery.G.triggers.triggerTypes
	for i=1,#triggerTypes do
		items[i] = {name = triggerTypes[i], callback = itemSelectCallback, internalValue = i}
	end
	control.items = items
	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	AuraMastery.controls.pool['triggerTypeSelect'] = control
end

function AuraMastery:UpdateTriggerSelect()
	local control = WM:GetControlByName("AuraMasteryAuraMenu_TriggerNumber")
	local m_comboBox = control.m_comboBox

	local itemSelectCallback = AuraMastery.LoadTriggerMenu


	-- assign dropdown items to control object
	local items = {}
	local triggers = self.svars.auraData[self.activeAura].triggers

	if 0 < #triggers then
		for i=1,#triggers do
			items[i] = {name = "Trigger "..i, callback = itemSelectCallback, internalValue = i}
		end
		ZO_ComboBox_Enable(control)
	else
		ZO_ComboBox_Disable(control)
	end


	control.items = items

	AuraMastery:PopulateComboBoxCustom(control.m_comboBox, control.items, callback)
	control.m_comboBox:SetSelectedItemFont("$(BOLD_FONT)|14|soft-shadow-thin")
	control.m_comboBox:SetSelectedItemText("select trigger...")
end

function AuraMastery:NewTrigger()
	self.activeTrigger = nil;
	WM:GetControlByName("AuraMasteryTriggerSettingsContainer"):SetHidden(false);	-- show trigger settings
	local numTriggers = #self.svars.auraData[self.activeAura].triggers
	
	self:CreateNewTrigger()
	self.activeTrigger = numTriggers+1
	self:UpdateTriggerSelect()

	local comboBox = WM:GetControlByName("AuraMasteryAuraMenu_TriggerNumber").m_comboBox
	local lastItem = comboBox:GetNumItems() -- new trigger will be the last entry (no sorting) =>	get last entry
	comboBox:SelectItemByIndex(lastItem)	-- auto select last entry
	
	self:UpdateDurationInfoSelect()
	self:UpdateIconInfoSelect()
end

function AuraMastery.LoadTriggerMenu(comboBox, itemText, item, selectionChanged)
	if not(selectionChanged) then return; end	-- don't do anything if nothing changes
	local triggerNumber = item.internalValue

	WM:GetControlByName("AuraMasteryTriggerSettingsContainer"):SetHidden(false) 	-- show trigger settings
	WM:GetControlByName("NotificationDisplay"):SetHidden(true)

	local auraName = AuraMastery.activeAura;
	local triggerType = AuraMastery.svars.auraData[auraName].triggers[triggerNumber].triggerType
	local protoTriggers = AuraMastery.protoTriggers[triggerType]

	AuraMastery.activeTrigger = triggerNumber

	AuraMastery:UpdateTriggerMenu()	-- careful: only update after AuraMastery.activeTrigger and AuraMastery.activeAura have been set!
end




--=====================================================
-- Trigger Actions (Sounds, Animations, etc.) ---------
--=====================================================

function AuraMastery.EditAuraTriggerAnimation()
--deb("called: EditAuraTriggerAnimation()", 500)
	local buttonControl = AuraMasteryAuraActionsWindow_DisplayContainer_Animations_TriggerAnimationEnabled_Checkbox
	local newState = buttonControl:GetState()
	local activeAura = AuraMastery.activeAura
	local animationData = AuraMastery.svars.auraData[activeAura].animationData
	if 1 == newState then
		--if not animationData then
			AuraMastery.svars.auraData[activeAura].animationData = {}
		--end
		local triggerAnimationDefaults = AuraMastery.triggerAnimationDefaults
		AuraMastery.svars.auraData[activeAura].animationData.trigger = triggerAnimationDefaults	
	elseif 0 == newState then
	
		-- delete all animation data from the aura's svars
		--if animationData then
			AuraMastery.svars.auraData[activeAura].animationData = nil
		--end
--[[		
		-- but keep the settings in case the user rechecks the checkBox
		if 0 == AuraMastery:GetNumElements(AuraMastery.svars.auraData[activeAura].animationData) then
			AuraMastery.svars.auraData[activeAura].animationData = nil
		end]]
	end
	
	local controlSet = buttonControl:GetParent():GetParent()
	AuraMastery:UpdateTriggerAnimationSettingsMenu(controlSet)
end


--
-- trigger animation end alpha
--
function AuraMastery:EditAuraTriggerAnimationEndAlpha(editboxControl)
	local activeAura 		= self.activeAura
	local inputAuraTriggerAnimationEndAlpha 	= tonumber(zo_strtrim(editboxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraTriggerAnimationEndAlpha(inputAuraTriggerAnimationEndAlpha)
	if (isValid) then
		self:SaveAuraTriggerAnimationEndAlpha(activeAura, inputAuraTriggerAnimationEndAlpha)
	else
		local oldValue = AuraMastery.svars.auraData[activeAura].animationData.trigger.endAlpha
		editboxControl:SetText(oldValue)
	end
	
	editboxControl:LoseFocus()
	self:SetNotification(msg, color)
end

function AuraMastery:IsValidAuraTriggerAnimationEndAlpha(inputAuraTriggerAnimationEndAlpha)
	local activeAura = self.activeAura
	local msg,rv,color;
	if nil == inputAuraTriggerAnimationEndAlpha or 0 ~= inputAuraTriggerAnimationEndAlpha%1 or 0 > inputAuraTriggerAnimationEndAlpha or 100 < inputAuraTriggerAnimationEndAlpha then
		rv,msg,color = false, "Only integer values between 0 and 100 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s animation end alpha value has been set to "..inputAuraTriggerAnimationEndAlpha..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:SaveAuraTriggerAnimationEndAlpha(auraName, auraTriggerAnimationEndAlpha)
	self.svars.auraData[auraName].animationData.trigger.endAlpha = auraTriggerAnimationEndAlpha/100
end


--
-- trigger animation duration
--
function AuraMastery:EditAuraTriggerAnimationDuration(editboxControl)
	local activeAura 		= self.activeAura
	local inputAuraTriggerAnimationDuration 	= tonumber(zo_strtrim(editboxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraTriggerAnimationDuration(inputAuraTriggerAnimationDuration)
	if (isValid) then
		self:SaveAuraTriggerAnimationDuration(activeAura, inputAuraTriggerAnimationDuration)
	else
		local oldValue = AuraMastery.svars.auraData[activeAura].animationData.trigger.duration
		editboxControl:SetText(oldValue)
	end
	
	editboxControl:LoseFocus()
	self:SetNotification(msg, color)
end

function AuraMastery:IsValidAuraTriggerAnimationDuration(inputAuraTriggerAnimationDuration)
	local activeAura = self.activeAura
	local msg,rv,color;
	if nil == inputAuraTriggerAnimationDuration or 0 ~= inputAuraTriggerAnimationDuration%1 or 100 > inputAuraTriggerAnimationDuration then
		rv,msg,color = false, "Only positive integer values above 100 are allowed in this field.", C_ERR;
	else
		rv,msg,color = true, "\""..activeAura.."\"'s animation duration has been set to "..inputAuraTriggerAnimationDuration..".", C_PASS;
	end
	return rv,msg,color;
end

function AuraMastery:SaveAuraTriggerAnimationDuration(auraName, auraTriggerAnimationDuration)
	self.svars.auraData[auraName].animationData.trigger.duration = auraTriggerAnimationDuration
end


--
-- trigger animation loop count
--
function AuraMastery:EditAuraTriggerAnimationLoopCount(editboxControl)
	local activeAura 		= self.activeAura
	local inputAuraTriggerAnimationLoopCount 	= tonumber(zo_strtrim(editboxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraTriggerAnimationLoopCount(inputAuraTriggerAnimationLoopCount)
	if (isValid) then
		self:SaveAuraTriggerAnimationLoopCount(activeAura, inputAuraTriggerAnimationLoopCount)
	else
		local oldValue = AuraMastery.svars.auraData[activeAura].animationData.trigger.loopCount
		editboxControl:SetText(oldValue)
	end
	editboxControl:LoseFocus()
	self:SetNotification(msg, color)
end

function AuraMastery:IsValidAuraTriggerAnimationLoopCount(inputAuraTriggerAnimationLoopCount)
	local activeAura = self.activeAura
	local msg,rv,color
	if nil == inputAuraTriggerAnimationLoopCount or 0 ~= inputAuraTriggerAnimationLoopCount%1 or 1 > inputAuraTriggerAnimationLoopCount or 10 < inputAuraTriggerAnimationLoopCount then
		rv,msg,color = false, "Only integer values between 1 and 10 are allowed in this field.", C_ERR
	else
		rv,msg,color = true, "\""..activeAura.."\"'s animation loop count has been set to "..inputAuraTriggerAnimationLoopCount..".", C_PASS
	end
	return rv,msg,color;
end

function AuraMastery:SaveAuraTriggerAnimationLoopCount(auraName, auraTriggerAnimationLoopCount)
	local loopCount = auraTriggerAnimationLoopCount*2-1
	self.svars.auraData[auraName].animationData.trigger.loopCount = loopCount
end


--
-- trigger animation color
--
function AuraMastery.EditAuraTriggerAnimationColor(r,g,b,a)
	AuraMastery:SaveAuraTriggerAnimationColor({r,g,b,a})
end

function AuraMastery:IsValidAuraTriggerAnimationColor(inputAuraTriggerAnimationColorData)
	local r,g,b,a = unpack(inputAuraTriggerAnimationColorData)
	if
		nil ~= r and 0 <= r and 1 >= r and
		nil ~= g and 0 <= g and 1 >= g and
		nil ~= b and 0 <= b and 1 >= b and
		nil ~= a and 0 <= a and 1 >= a
	then
		return true
	end
	return false
end

function AuraMastery:SaveAuraTriggerAnimationColor(colorData)
	local activeAura = AuraMastery.activeAura
	AuraMastery.svars.auraData[activeAura].animationData.trigger.colors = colorData
end


--
-- trigger animation delay
--
function AuraMastery:EditAuraTriggerAnimationDelay(editboxControl)
	local activeAura = self.activeAura
	local inputAuraTriggerAnimationDelay = tonumber(zo_strtrim(editboxControl:GetText()))
	local isValid,msg,color	= AuraMastery:IsValidAuraTriggerAnimationDelay(inputAuraTriggerAnimationDelay)
	if (isValid) then
		self:SaveAuraTriggerAnimationDelay(activeAura, inputAuraTriggerAnimationDelay)
	else
		local oldValue = AuraMastery.svars.auraData[activeAura].animationData.trigger.delay
		editboxControl:SetText(oldValue)
	end
	
	editboxControl:LoseFocus()
	self:SetNotification(msg, color)
end

function AuraMastery:IsValidAuraTriggerAnimationDelay(inputAuraTriggerAnimationDelay)
	local activeAura = self.activeAura
	local msg,rv,color;
	if nil == inputAuraTriggerAnimationDelay or 0 ~= inputAuraTriggerAnimationDelay%1 or 100 > inputAuraTriggerAnimationDelay then
		rv,msg,color = false, "Only positive integer values above 100 are allowed in this field.", C_ERR
	else
		rv,msg,color = true, "\""..activeAura.."\"'s animation delay has been set to "..inputAuraTriggerAnimationDelay..".", C_PASS
	end
	return rv,msg,color;
end

function AuraMastery:SaveAuraTriggerAnimationDelay(auraName, inputAuraTriggerAnimationDelay)
	self.svars.auraData[auraName].animationData.trigger.delay = inputAuraTriggerAnimationDelay
end






--======================================
-- Loading Conditions Settings ---------
--======================================

function AuraMastery:AddAbilityToLoadingConditions()
	local auraName = AuraMastery.activeAura
	local control = WM:GetControlByName("AuraMasteryLoadingConditionsAbilitiesSlotedContainer_Editbox_Editbox")
	local abilityId = tonumber(zo_strtrim(control:GetText()))
	
	local isValid,msg,color	= AuraMastery:IsValidTriggerAbilityId(abilityId)
	if (isValid) then
		local list = self.svars.auraData[auraName].loadingConditions.abilitiesSloted
		
		-- only add a valid ability id if it's not yet on the list
		for i=1, #list do
			if list[i] == abilityId then
				return
			end
		end
		table.insert(list, abilityId)
		self:UpdateLoadingConditionsSettingsMenu()
		self:UpdateAuraLoadingState(auraName)
	end
	control:LoseFocus()
	AuraMastery:SetNotification(msg, color)
end

function AuraMastery:RemoveAbilityFromLoadingConditions(auraName, abilityId)
	local list = self.svars.auraData[auraName].loadingConditions.abilitiesSloted
	for i=1, #list do
		if list[i] == abilityId then
			table.remove(self.svars.auraData[auraName].loadingConditions.abilitiesSloted, i)
			WM:GetControlByName("AuraMasteryLoadingConditionsAbilitiesSlotedAbilityRow"..i):SetHidden(true)
			self:UpdateLoadingConditionsSettingsMenu()
		end
	end
	self:UpdateAuraLoadingState(auraName)
end


--======================================
-- Handler Functions -------------------
--======================================

-- Editbox handlers
function AuraMastery:EditBoxOnMouseDown(control)
	control:SelectAll()
	control:TakeFocus()
end

function AuraMastery:EditBoxOnMouseEnter(control)
	local parent = control:GetParent() -- get backdrop
	parent:SetEdgeColor(0.9,.87,0.68,1);
end

function AuraMastery:EditBoxOnMouseExit(editBoxControl)
	if not(editBoxControl:HasFocus()) then 	
			local parent = editBoxControl:GetParent() -- get backdrop
			parent:SetEdgeColor(1,1,1,.12)
	end
end

function AuraMastery:EditBoxOnEnter(control)
	control:LoseFocus()
end

function AuraMastery:EditBoxOnEscape(control)
	control:LoseFocus()
end

function AuraMastery:EditBoxOnFocusLost(control)
	self:EditBoxOnMouseExit(control)
end

function AuraMastery:SetNotification(errMsg, color)
	local parent = WM:GetControlByName("NotificationDisplay")
	parent:SetHidden(false)
	local label = parent:GetNamedChild("_Label")
	label:SetColor(color[1],color[2],color[3])
	label:SetText(errMsg)
end

function AuraMastery:FindAbilityIds()
	local textBox = WM:GetControlByName("FindIdsByNameContainer_Editbox_Editbox");
	local text = textBox:GetText();
	local parsedName = zo_strformat("<<z:1>>", text);
	textBox:SetText("");
	textBox:LoseFocus();
	local output = "";
	local lang = GetCVar("language.2");
	if (self.abilityData[lang][parsedName]) then
		output = output.."The following ability IDs have been found for \""..text.."\"\n";
		output = output..self.abilityData[lang][parsedName].rank1.. " (Rank 1)\n";
		output = output..self.abilityData[lang][parsedName].rank2.. " (Rank 2)\n";
		output = output..self.abilityData[lang][parsedName].rank3.. " (Rank 3)\n";
		output = output..self.abilityData[lang][parsedName].rank4.. " (Rank 4)\n";
	elseif (self.effectData[parsedName]) then
		output = output.."The following ID has been found for \""..text.."\"\n";
		output = output..self.effectData[parsedName][1];
		output = output.."\n\nPlease note that you have entered an ability-ID that belongs to an\nability that has no ranks!\n\"Check all\" MUST be set to 'true' to make it work!!!" ;
	else
		output = "There is no ability named "..text..". Please check for typos.";
	end

	local resultsDisplay = WM:GetControlByName("FindIdsByNameContainer_Results_Label");
	resultsDisplay:SetText(output);
end

-- Switch handlers
function AuraMastery:SwitchOnMouseEnter(control)
	local backdrop = control:GetNamedChild("_Backdrop")
	backdrop:SetEdgeColor(.9,.87,.68,1)
end

function AuraMastery:SwitchOnMouseExit(control)
	local backdrop = control:GetNamedChild("_Backdrop")
	backdrop:SetEdgeColor(1,1,1,.12)
end

function AuraMastery:SwitchOnClicked(control)
	local controlName = control:GetName()
	if AuraMastery.handlers['OnClicked'][controlName] then
		local func = AuraMastery.handlers['OnClicked'][controlName]['func']
		func(self, control)
	end
end






-- Import/Export functions
function AuraMastery:DisplayExportAuraWindow()
	local auraName = self.activeAura
	local exportWindow = WM:GetControlByName("AuraMasteryExportWindow")
	exportWindow:GetNamedChild("_Label"):SetText("Export aura: "..auraName)
	local EBExportAura = WM:GetControlByName("ExportEditbox")
	
	local data = self:GetAuraDataForSerialization(auraName)
	local serialized = SER:Serialize(data)
	
	EBExportAura:Clear()
	EBExportAura:InsertText(serialized)
	exportWindow:SetHidden(false)
end

function AuraMastery:DisplayExportAuraGroupWindow(groupId)
	local exportWindow = WM:GetControlByName("AuraMasteryExportWindow")
	exportWindow:GetNamedChild("_Label"):SetText("Export aura group: "..groupId)
	local EBExportAura = WM:GetControlByName("ExportEditbox")
	
	local data = self:GetAuraGroupDataForSerialization(groupId)
	local serialized = SER:Serialize(data)

	EBExportAura:Clear()
	EBExportAura:InsertText(serialized)
	exportWindow:SetHidden(false)
end

function AuraMastery:GetAuraGroupDataForSerialization(groupId)
	local serializedData = {
		['importDataType'] = AM_IMPORT_TYPE_AURA_GROUP,
		['groupData'] = {},
		['aurasData'] = {}
	}
	local aurasData = self.svars.auraData
	local groupData = self.svars.groupsData[groupId]

	serializedData['groupData'] = groupData

	local groupedAuras = groupData.elements
	for i=1,#groupedAuras do
		local auraName = groupedAuras[i]
		local auraData = aurasData[auraName]
		serializedData['aurasData'][i] = auraData
	end	
	
	return serializedData
end

function AuraMastery:GetAuraDataForSerialization(auraName)
	local serializedData = {
		['importDataType'] = AM_IMPORT_TYPE_AURA,
		['auraData'] = self.svars.auraData[auraName]
	}
	
	return serializedData
end

function AuraMastery:ImportAura()

	local control = WM:GetControlByName("ImportEditbox")
	local importString = zo_strtrim(control:GetText())
	local msg, color
	control:Clear()
	local success, deserializedData = SER:Deserialize(importString)
	if success then
		if AM_IMPORT_TYPE_AURA_GROUP == deserializedData['importDataType'] then
			local auraGroupData = deserializedData['groupData']
			local aurasData = deserializedData['aurasData']
			local auraGroupSuccess = self:NewAuragroup(auraGroupData['groupName'], auraGroupData)

			
			
			AuraMastery.dump = deserializedData	

			if auraGroupSuccess then
				for i=1,#aurasData do
					local auraData = aurasData[i]		
					if AuraMastery:CheckImportedData(auraData) then
						if (1 == auraData['aType']) then
							self:NewIcon(auraData)
						elseif (2 == auraData['aType']) then
							self:NewProgressBar(auraData)
						elseif (4 == auraData['aType']) then
							self:NewText(auraData)
						end
						WM:GetControlByName("AuraMasteryImportWindow"):SetHidden(true)
						msg = ""
						color = C_PASS
					else
						msg = "Error: The provided aura import string contains invalid information."
						color = C_ERR
					end			
				end
			else
				msg = "Error: An aura group named "..auraGroupData['groupName'].." already exists. Aborted the import operation..."
				color = C_ERR
			end
		elseif AM_IMPORT_TYPE_AURA == deserializedData['importDataType'] then
			local auraData = deserializedData['auraData']
			if AuraMastery:CheckImportedData(auraData) then
				if (1 == auraData['aType']) then
					self:NewIcon(auraData)
				elseif (2 == auraData['aType']) then
					self:NewProgressBar(auraData)
				elseif (4 == auraData['aType']) then
					self:NewText(auraData)
				end
				WM:GetControlByName("AuraMasteryImportWindow"):SetHidden(true)
				msg = ""
				color = C_PASS
			else
				msg = "Error: The provided aura import string contains invalid information."
				color = C_ERR
			end
		else
			msg = "Error: No import aura type provided! Aborting..."
			color = C_ERR
		end
	else 
		msg = "Error: The provided aura import string is corrupt."
		color = C_ERR
	end

	local notificationText = WM:GetControlByName("AuraMasteryImportWindow_NotificationLabel")
	notificationText:SetColor(color[1],color[2],color[3])
	notificationText:SetText(msg)
	control:SetText("")
end

function AuraMastery:CheckImportedData(data)
--[[
	local validTriggers = true
	if nil ~= data['triggers'] and 0 < #data['triggers'] then
		validTriggers = AuraMastery:ValidateTriggers(data['triggers'])
	end
]]


	if nil == data['aType'] or not(AuraMastery:IsValidAuraType(data['aType'])) then
		d("Invalid aura Type: "..assert(data['aType'])); return false
	end
	-- aura type specific fields
	if 1 == data['aType'] then
		if nil == data['textFontSize'] or not(AuraMastery:IsValidAuraTextFontSize(data['textFontSize'])) then
			d("Invalid aura text font size: "..assert(data['textFontSize'])); return false
		end
		if nil == data['cooldownFontSize'] or not(AuraMastery:IsValidAuraCooldownFontSize(data['cooldownFontSize'])) then
			d("Invalid aura cooldown font size: "..assert(data['cooldownFontSize'])); return false
		end
		if nil == data['borderSize'] or not(AuraMastery:IsValidAuraBorderSize(data['borderSize'])) then
			d("Invalid aura border size: "..assert(data['borderSize'])); return false
		end
		if nil == data['borderColor'] or not(AuraMastery:IsValidAuraBorderColor(data['borderColor'])) then
			d("Invalid aura border color: "..assert(data['borderColor'])); return false
		end
		if nil == data['bgColor'] or not(AuraMastery:IsValidAuraBackgroundColor(data['bgColor'])) then
			d("Invalid aura background color: "..assert(data['bgColor'])); return false
		end
		if nil == data['iconPath'] or not(AuraMastery:IsValidAuraIconPath(data['iconPath'])) then
			d("Invalid aura icon path: "..assert(data['iconPath'])); return false
		end
	elseif 2 == data['aType'] then
		if nil == data['bgColor'] then
			d("Invalid aura background color: "..assert(data['bgColor'])); return false
		end
		if nil == data['cooldownFontSize'] or not(AuraMastery:IsValidAuraCooldownFontSize(data['cooldownFontSize'])) then
			d("Invalid aura cooldown font size: "..assert(data['cooldownFontSize'])); return false
		end	
		if nil == data['barColor'] then
			d("Invalid aura bar color: "..assert(data['barColor'])); return false
		end
		if nil == data['borderSize'] or not(AuraMastery:IsValidAuraBorderSize(data['borderSize'])) then
			d("Invalid aura border size: "..assert(data['borderSize'])); return false
		end
		if nil == data['borderColor'] or not(AuraMastery:IsValidAuraBorderColor(data['borderColor'])) then
			d("Invalid aura border color: "..assert(data['borderColor'])); return false
		end
		if nil == data['bgColor'] or not(AuraMastery:IsValidAuraBackgroundColor(data['bgColor'])) then
			d("Invalid aura background color: "..assert(data['bgColor'])); return false
		end
		if nil == data['iconPath'] or not(AuraMastery:IsValidAuraIconPath(data['iconPath'])) then
			d("Invalid aura icon path: "..assert(data['iconPath'])); return false
		end

	elseif 4 == data['aType'] then	
		if nil == data['textFontSize'] or not(AuraMastery:IsValidAuraTextFontSize(data['textFontSize'])) then
			d("Invalid aura text font size: "..assert(data['textFontSize'])); return false
		end
	end
	if nil == data['width'] or not(AuraMastery:IsValidAuraWidth(data['width'])) then
		d("Invalid aura width: "..assert(data['width'])); return false
	end
	if nil == data['height'] or not(AuraMastery:IsValidAuraHeight(data['height'])) then
		d("Invalid aura height: "..assert(data['height'])); return false
	end
	if nil == data['posX'] or not(AuraMastery:IsValidAuraPosX(data['posX'])) then
		d("Invalid aura x-coordinate: "..assert(data['posX'])); return false
	end
	if nil == data['posY'] or not(AuraMastery:IsValidAuraPosY(data['posY'])) then
		d("Invalid aura y-coordinate: "..assert(data['posY'])); return false
	end
	if nil == data['alpha'] or not(AuraMastery:IsValidAuraAlpha(data['alpha'])) then
		d("Invalid aura alpha: "..assert(data['alpha'])); return false
	end
	if nil == data['critical'] or not(AuraMastery:IsValidAuraCritical(data['critical'])) then
		d("Invalid aura critical time: "..assert(data['critical'])); return false
	end

	return true
end

function AuraMastery:ValidateTriggers(triggerData)
	local isValidTriggerData
	local n = #triggerData
	for i=1, n do
		if
			nil ~= triggerData[i]['triggerType']	and AuraMastery:IsValidTriggerType(triggerData[i]['triggerType'])		and
			nil ~= triggerData[i]['unitTag'] 		and AuraMastery:IsValidTriggerTarget(triggerData[i]['unitTag']) 		and
			nil ~= triggerData[i]['invert']			and AuraMastery:IsValidTriggerInvertLogic( triggerData[i]['invert']) and
			nil ~= triggerData[i]['checkAll']		and AuraMastery:IsValidTriggerCheckAll(triggerData[i]['checkAll']) 	and
			nil ~= triggerData[i]['spellId']			and AuraMastery:IsValidTriggerAbilityId(triggerData[i]['spellId']) 	and
			nil ~= triggerData[i]['operator']		and AuraMastery:IsValidTriggerOperator(triggerData[i]['operator']) 	and
			nil ~= triggerData[i]['value']			and AuraMastery:IsValidTriggerValue(triggerData[i]['value'])
		then
			isValidTriggerData = true
		else
			isValidTriggerData = false
			d("Trigger Problem!")
			break
		end
	end
	return isValidTriggerData
end