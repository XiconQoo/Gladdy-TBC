local Type, Version = "GladdySearchEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local PREDICTOR_ROWS = 20
local predictorBackdrop = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  edgeSize = 26,
  insets = {left = 9, right = 9, top = 9, bottom = 9},
}
local queryResult = {}

-- {{ AceGUI object
local function Fire(self, method, ...)
	local options = self.options
	local func = options[method]
	if func then
		local handler = options.handler or options
		if type(func)=="string" then func = handler[func] end
		return func(handler, ...)
	end
end

local function OnAcquire(self)
	self:SetWidth(200)
	self:SetHeight(26)
	self:SetDisabled(false)
	self:SetLabel()
end

local function OnRelease(self)
	self.frame:ClearAllPoints()
	self.frame:Hide()
	self.predictor:Hide()
	self.spellFilter = nil
	self:SetDisabled(false)
end

local function SetDisabled(self, disabled)
	self.disabled = disabled
	if( disabled ) then
		self.editBox:EnableMouse(false)
		self.editBox:ClearFocus()
		self.editBox:SetTextColor(0.5, 0.5, 0.5)
		self.label:SetTextColor(0.5, 0.5, 0.5)
	else
		self.editBox:EnableMouse(true)
		self.editBox:SetTextColor(1, 1, 1)
		self.label:SetTextColor(1, 0.82, 0)
	end
end

local function ShowButton(self)
	local predictor = self.predictor
	if self.lastText ~= "" then
		predictor.selectedButton = nil
		predictor:Query(self)  -- Dont remove self param, its not a bug
	else
		predictor:Hide()
	end
end

local function HideButton(self)
	self.editBox:SetTextInsets(0, 0, 3, 3)
	self.predictor.selectedButton = nil
	self.predictor:Hide()
end

local function SetText(self, text)
	self.lastText = text or ""
	self.editBox:SetText(self.lastText)
	self.editBox:SetCursorPosition( string.len(self.lastText) )
	HideButton(self)
end

local function SetLabel(self, text)
	if( text and text ~= "" ) then
		self.label:SetText(text)
		self.label:Show()
		self.editBox:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 7, -18)
		self:SetHeight(44)
		self.alignoffset = 30
	else
		self.label:SetText("")
		self.label:Hide()
		self.editBox:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 7, 0)
		self:SetHeight(26)
		self.alignoffset = 12
	end
end

local function ValidateValue(self, text, key)
	if self.options.GetValue then
		local value
		key, value = Fire(self, "GetValue", text, key)
		if key and value then text = value end
	elseif not key then
		key = text
	end
	return key, text
end

local function Initialize(self)
	Fire( self, "Initialize" )
	self.initialized = true
end
-- }}

-- {{ Predictor widget
local function Predictor_OnShow(self)
	-- If the user is using an edit box in a configuration, they will live without arrow keys while the predictor
	-- is opened, this also is the only way of getting up/down arrow for browsing the predictor to work.
	self.obj.editBox:SetAltArrowKeyMode(true)

	local name = self:GetName()
	SetOverrideBindingClick(self, true, "DOWN", name, 1)
	SetOverrideBindingClick(self, true, "UP", name, -1)
	SetOverrideBindingClick(self, true, "LEFT", name, "LEFT")
	SetOverrideBindingClick(self, true, "RIGHT", name, "RIGHT")
end

local function Predictor_OnHide(self)
	if self.obj then
		-- Allow users to use arrows to go back and forth again without the fix
		self.obj.editBox:SetAltArrowKeyMode(false)
		-- Make sure the tooltip isn't kept open if one of the buttons was using it
		for _, button in pairs(self.buttons) do
			if( GameTooltip:IsOwned(button) ) then
				GameTooltip:Hide()
			end
		end
		-- Reset all bindings set on this predictor
		ClearOverrideBindings(self)
	end
end

local function PredictorButton_OnClick(self)
	local value = self.Item.key
	local obj = self.parent.obj
	--local value, text = ValidateValue(obj, obj.editBox:GetText(), self.key )
	if value then
		--SetText(obj, text)
		--self.parent.selectedButton = nil
		obj:Fire("OnEnterPressed", value )
	end
end

local function PredictorButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -16)
	local hyperlink = Fire( self.parent.obj, "GetHyperlink", self.Item.key )
	if hyperlink then
		GameTooltip:SetHyperlink( hyperlink )
	end
end

local function PredictorButton_OnLeave(self)
	local predictor = self.parent
	if not predictor.selectedButton or predictor.buttons[predictor.selectedButton] ~= self then
		GameTooltip:Hide()
	end
end

local function Predictor_Reset(self, object)
	-- reparent the predictor if necessary
	if self.obj~=object then
		self.obj = object
		self:SetPoint("TOPLEFT" , object.editBox, "BOTTOMLEFT", -6, 0)
		self:SetPoint("TOPRIGHT", object.editBox, "BOTTOMRIGHT", 0, 0)
	end
	-- hiding predictor buttons
	for _, button in pairs(self.buttons) do
		button:UnlockHighlight()
		button:Hide()
	end
	-- already done in EditBox FocusGained event, but some times its not fire there (i dont know why)
	if not object.initialized then
		Initialize(object)
	end
	wipe(queryResult)
end

local function Predictor_Query(self, object)
	Predictor_Reset(self,object)
	local activeButtons = 0
	local result = Fire( self.obj, "GetValues", self.obj.editBox:GetText(), queryResult, PREDICTOR_ROWS ) or queryResult

	wipe(self.scrollFrame.items)

	for key,value in pairs(result) do
		activeButtons = activeButtons + 1
		table.insert(self.scrollFrame.items, {
			text = value.text,
			icon = value.icon,
			key = key
		})
		if activeButtons >= PREDICTOR_ROWS then
			activeButtons = PREDICTOR_ROWS
		end
	end
	table.sort(self.scrollFrame.items, function(a, b)
		return a.text < b.text
	end)
	if activeButtons > 0 then
		self:SetHeight(activeButtons >= PREDICTOR_ROWS and activeButtons * 16 or (activeButtons+1) * 16)
		self:Show()
	else
		self:Hide()
	end
	self.scrollFrame.update()
	self.activeButtons = activeButtons
end
-- }}

-- {{ Edit_Box widget
local function EditBox_OnEnter(this)
	this.obj:Fire("OnEnter")
end

local function EditBox_OnLeave(this)
	this.obj:Fire("OnLeave")
end

local function EditBox_OnEnterPressed(this)
	local obj = this.obj
	-- Something is selected in the predictor, use that value instead of whatever is in the input box
	if obj.predictor.selectedButton then
		obj.predictor.buttons[obj.predictor.selectedButton]:Click()
		return
	end
	-- validate
	local value, text = ValidateValue(obj, this:GetText() )
	if value then
		if text ~= obj.lastText then
			SetText(obj, text)
		end
		-- Fire the event
		if not obj:Fire("OnEnterPressed", value) then
			HideButton(obj)
			return
		end
	end
	this:SetFocus()
end

local function EditBox_OnEscapePressed(this)
	this:ClearFocus()
end

local function EditBox_OnReceiveDrag(this)
	local obj = this.obj
	local value = Fire(obj, "OnReceiveDrag")
	if value then
		SetText(value)
		obj:Fire("OnEnterPressed", value)
		ClearCursor()
	end
	HideButton(obj)
	AceGUI:ClearFocus()
end

local function EditBox_OnTextChanged(this)
	local obj = this.obj
	local value = this:GetText()
	if value ~= obj.lastText then
		obj:Fire("OnTextChanged", value)
		obj.lastText = value
		ShowButton(obj)
	end
end

local function EditBox_OnEditFocusLost(self)
	local predictor = self.obj.predictor
	if predictor:IsVisible() then
		local frame = GetMouseFocus()
		if not (frame and frame.parent==predictor) then
			predictor:Hide()
		end
	end
end

local function EditBox_OnEditFocusGained(self)
	local obj = self.obj
	if not obj.initialized then
		Initialize(obj)
	end
	if obj.predictor:IsVisible() then
		Predictor_OnShow(obj.predictor)
	elseif obj.lastText then
		ShowButton(obj)
	end
end
--}}

-- {{ EditBox right button widget
local function Button_OnClick(this)
	EditBox_OnEnterPressed(this.obj.editBox)
end
-- }}
-- This function is only executed once and them removed, because the same predictor frame is used for all widgets
local function CreatePredictorFrame(num)
	local predictor = CreateFrame("Frame", "AceGUI30GladdySearchEditBox" .. num .. "Predictor", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
	predictor:SetBackdrop(predictorBackdrop)
	predictor:SetBackdropColor(0, 0, 0, 0.85)
	predictor:SetFrameStrata("TOOLTIP")
	predictor:SetHeight(300)
	predictor:SetWidth(300)

	predictor.Query = Predictor_Query
	predictor.buttons = {}

	local scrollFrame = CreateFrame("ScrollFrame", nil, predictor, "HybridScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", 8, -8)
	scrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)
	predictor.scrollFrame = scrollFrame

	local function update()
		local items = scrollFrame.items;
		local buttons = HybridScrollFrame_GetButtons(scrollFrame);
		local offset = HybridScrollFrame_GetOffset(scrollFrame);
		predictor.buttons = buttons

		for buttonIndex = 1, #buttons do
			local button = buttons[buttonIndex];
			local itemIndex = buttonIndex + offset;
			button.parent = predictor

			-- Usually the check you'd want to apply here is that if itemIndex
			-- is greater than the size of your model contents, you'll hide the
			-- button. Otherwise, update it visually and show it.
			if itemIndex <= #items then
				local item = items[itemIndex];
				button:SetID(itemIndex);
				button.Icon:SetTexture(item.icon or nil);
				button.Text:SetText(item.text or "");
				button.Item = item
				button:SetScript("OnClick", PredictorButton_OnClick)
				button:SetScript("OnEnter", PredictorButton_OnEnter)

				-- One caveat is buttons are only anchored below one another with
				-- one point, so an explicit width is needed on each row or you
				-- need to add the second point manually.
				local extraWidth = #items > PREDICTOR_ROWS and 0 or 16
				button:SetWidth(predictor.scrollFrame:GetWidth() + extraWidth);
				button:Show();
			else
				button:Hide();
			end
		end

		-- The last step is to ensure the scroll range is updated appropriately.
		-- Calculate the total height of the scrollable region (using the model
		-- size), and the displayed height based on the number of shown buttons.
		local buttonHeight = scrollFrame.buttonHeight;
		local totalHeight = #items * buttonHeight;
		local shownHeight = #buttons * buttonHeight;

		HybridScrollFrame_Update(scrollFrame, totalHeight, shownHeight);
	end
	scrollFrame.update = update

	local scrollBar = CreateFrame("Slider", nil, scrollFrame, "HybridScrollBarTemplate")
	scrollBar:SetPoint("TOPLEFT", scrollFrame,"TOPRIGHT", 1, -16)
	scrollBar:SetPoint("BOTTOMLEFT", scrollFrame,"BOTTOMRIGHT", 1, 12)
	scrollFrame.scrollBar = scrollBar

	scrollFrame.items = {}
	predictor:SetPoint("CENTER", 0, 0)
	--HybridScrollFrame_SetDoNotHideScrollBar(scrollFrame, true)
	HybridScrollFrame_CreateButtons(scrollFrame, "GladdySearchEditBoxItemTemplate")

	--update once to create buttons
	scrollFrame.update()
	predictor:ClearAllPoints()
	-- EditBoxes override the OnKeyUp/OnKeyDown events so that they can function, meaning in order to make up and down
	-- arrow navigation of the menu work, I have to do some trickery with temporary bindings.
	predictor:SetScript("OnHide", Predictor_OnHide)
	-- Replacing with a new function that returns first created predictor
	CreatePredictorFrame = function() return predictor end
	predictor:Hide()
	return predictor
end

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)
	local editBox = CreateFrame("EditBox", "AceGUI30GladdySearchEditBox" .. num, frame, "InputBoxTemplate")
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	local predictor = CreatePredictorFrame(num)
	-- Parent frame for all widgets
	frame:SetSize(200,44)
	-- EditBox Label
	label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)
	-- EditBox
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetScript("OnEnter", EditBox_OnEnter)
	editBox:SetScript("OnLeave", EditBox_OnLeave)
	editBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editBox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editBox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editBox:SetScript("OnReceiveDrag", EditBox_OnReceiveDrag)
	editBox:SetScript("OnMouseDown", EditBox_OnReceiveDrag)
	editBox:SetScript("OnEditFocusGained", EditBox_OnEditFocusGained)
	editBox:SetScript("OnEditFocusLost", EditBox_OnEditFocusLost)
	editBox:SetTextInsets(0, 0, 3, 3)
	editBox:SetMaxLetters(256)
	editBox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 0)
	editBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	editBox:SetHeight(19)
	-- AceGUI object

	local widget = {
		type = Type,
	    num = num,
	    alignoffset = 30,
		frame = frame,
		predictor = predictor,
		editBox = editBox,
		label = label,
		OnRelease = OnRelease,
		OnAcquire = OnAcquire,
		SetDisabled = SetDisabled,
		SetText = SetText,
		SetLabel = SetLabel,
	}
	-- References to the AceGUI object
	frame.obj = widget
	editBox.obj = widget
	-- Registering our new created widget
	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
