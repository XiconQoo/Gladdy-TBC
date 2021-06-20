local CreateFrame = CreateFrame
local UIParent = UIParent
local InCombatLockdown = InCombatLockdown

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

Gladdy.BUTTON_DEFAULTS = {
    name = "",
    guid = "",
    raceLoc = "",
    classLoc = "",
    class = "",
    health = "",
    healthMax = 0,
    power = 0,
    powerMax = 0,
    powerType = 0,
    spec = "",
    testSpec = "",
    spells = {},
    ns = false,
    nf = false,
    pom = false,
    fd = false,
    damaged = 0,
    click = false,
    stealthed = false,
    classColors = {},
    lastState = 0,
}

function Gladdy:CreateFrame()
    self.frame = CreateFrame("Frame", "GladdyFrame", UIParent)
    --self.frame.texture = self.frame:CreateTexture(nil, "OVERLAY")
    --self.frame.texture:SetAllPoints(self.frame)
    --self.frame.texture:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")

    self.frame:SetClampedToScreen(true)
    self.frame:EnableMouse(false)
    self.frame:SetMovable(true)
    self.frame:RegisterForDrag("LeftButton")

    self.frame:SetScript("OnDragStart", function(f)
        if (not InCombatLockdown() and not self.db.locked) then
            f:StartMoving()
        end
    end)
    self.frame:SetScript("OnDragStop", function(f)
        if (not InCombatLockdown()) then
            f:StopMovingOrSizing()

            local scale = f:GetEffectiveScale()
            self.db.x = f:GetLeft() * scale
            self.db.y = (self.db.growUp and f:GetBottom() or f:GetTop()) * scale
        end
    end)

    self.anchor = CreateFrame("Button", "GladdyAnchor", self.frame, BackdropTemplateMixin and "BackdropTemplate")
    self.anchor:SetHeight(20)
    self.anchor:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16 })
    self.anchor:SetBackdropColor(0, 0, 0, 1)
    self.anchor:SetClampedToScreen(true)
    self.anchor:EnableMouse(true)
    self.anchor:SetMovable(true)
    self.anchor:RegisterForDrag("LeftButton")
    self.anchor:RegisterForClicks("RightButtonUp")
    self.anchor:SetScript("OnDragStart", function()
        if (not InCombatLockdown() and not self.db.locked) then
            self.frame:StartMoving()
        end
    end)
    self.anchor:SetScript("OnDragStop", function()
        if (not InCombatLockdown()) then
            self.frame:StopMovingOrSizing()

            local scale = self.frame:GetEffectiveScale()
            self.db.x = self.frame:GetLeft() * scale
            self.db.y = (self.db.growUp and self.frame:GetBottom() or self.frame:GetTop()) * scale
        end
    end)
    self.anchor:SetScript("OnClick", function()
        if (not InCombatLockdown()) then
            self:ShowOptions()
        end
    end)

    self.anchor.text = self.anchor:CreateFontString("GladdyAnchorText", "ARTWORK", "GameFontHighlightSmall")
    self.anchor.text:SetText(L["Gladdy - drag to move"])
    self.anchor.text:SetPoint("CENTER")

    self.anchor.button = CreateFrame("Button", "GladdyAnchorButton", self.anchor, "UIPanelCloseButton")
    self.anchor.button:SetWidth(20)
    self.anchor.button:SetHeight(20)
    self.anchor.button:SetPoint("RIGHT", self.anchor, "RIGHT", 2, 0)
    self.anchor.button:SetScript("OnClick", function(_, _, down)
        if (not down) then
            self.db.locked = true
            self:UpdateFrame()
        end
    end)

    if (self.db.locked) then
        self.anchor:Hide()
    end

    self.frame:Hide()
end

function Gladdy:UpdateFrame()

    if (InCombatLockdown()) then
        return
    end

    if (not self.frame) then
        self:CreateFrame()
    end
    local teamSize = self.curBracket or 0

    local highlightBorderSize = (self.db.highlightInset and 0 or self.db.highlightBorderSize * 2)
    local powerBarHeight = self.db.powerBarEnabled and (self.db.powerBarHeight + 1) or 0
    local leftSize = 0
    local rightSize = 0
    --Trinket + Racial
    if self.db.trinketEnabled and self.db.trinketPos == "LEFT" then
        leftSize = leftSize + self.db.trinketSize * self.db.trinketWidthFactor + self.db.padding
        if self.db.racialEnabled and self.db.racialAnchor == "trinket" and self.db.racialPos == "LEFT" then
            leftSize = leftSize + self.db.racialSize * self.db.racialWidthFactor + self.db.padding
        end
    end
    if self.db.trinketEnabled and self.db.trinketPos == "RIGHT" then
        rightSize = rightSize + self.db.trinketSize * self.db.trinketWidthFactor + self.db.padding
        if self.db.racialEnabled and self.db.racialAnchor == "trinket" and self.db.racialPos == "RIGHT" then
            rightSize = rightSize + self.db.racialSize * self.db.racialWidthFactor + self.db.padding
        end
    end
    --ClassIcon
    if self.db.classIconPos == "LEFT" then
        leftSize = leftSize + self.db.classIconSize * self.db.classIconWidthFactor + self.db.padding
    else
        rightSize = rightSize + self.db.classIconSize * self.db.classIconWidthFactor + self.db.padding
    end
    --Highlight
    if not self.db.highlightInset then
        leftSize = leftSize + self.db.highlightBorderSize
        rightSize = rightSize + self.db.highlightBorderSize
    end

    local margin = powerBarHeight
    local width = self.db.barWidth + leftSize + rightSize
    local height = (self.db.healthBarHeight + powerBarHeight) * teamSize
            + (self.db.highlightInset and 0 or self.db.highlightBorderSize * 2 * teamSize)
            + self.db.bottomMargin * (teamSize - 1)

    -- Highlight
    margin = margin + highlightBorderSize

    if (self.db.cooldownYPos == "TOP" or self.db.cooldownYPos == "BOTTOM") and self.db.cooldown then
        margin = margin + self.db.cooldownSize
        height = height + self.db.cooldownSize * (teamSize - 1)
    end
    if (self.db.buffsCooldownPos == "TOP" or self.db.buffsCooldownPos == "BOTTOM") and self.db.buffsEnabled then
        margin = margin + self.db.buffsIconSize
        height = height + self.db.buffsIconSize * (teamSize - 1)
    end
    if (self.db.buffsBuffsCooldownPos == "TOP" or self.db.buffsBuffsCooldownPos == "BOTTOM") and self.db.buffsEnabled then
        margin = margin + self.db.buffsBuffsIconSize
        height = height + self.db.buffsBuffsIconSize * (teamSize - 1)
    end
    if self.db.buffsCooldownPos == "TOP" and self.db.cooldownYPos == "TOP" and self.db.cooldown and self.db.buffsEnabled then
        margin = margin + 1
        height = height + (teamSize - 1)
    end
    if self.db.buffsCooldownPos == "BOTTOM" and self.db.cooldownYPos == "BOTTOM" and self.db.cooldown and self.db.buffsEnabled then
        margin = margin + 1
        height = height + (teamSize - 1)
    end

    -- GrowDirection
    if (self.db.growDirection == "LEFT" or self.db.growDirection == "RIGHT") then
        width = self.db.barWidth * teamSize + (leftSize + rightSize) * teamSize + self.db.bottomMargin * (teamSize - 1)
        height = self.db.healthBarHeight + powerBarHeight
    end

    self.frame:SetScale(self.db.frameScale)
    self.frame:SetWidth(width)
    self.frame:SetHeight(height)
    --self.frame:SetBackdropColor(self.db.frameColor.r, self.db.frameColor.g, self.db.frameColor.b, self.db.frameColor.a)
    self.frame:ClearAllPoints()
    if (self.db.x == 0 and self.db.y == 0) then
        self.frame:SetPoint("CENTER")
    else
        local scale = self.frame:GetEffectiveScale()
        if (self.db.growDirection == "TOP") then
            self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.x / scale, self.db.y / scale)
        else
            self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.x / scale, self.db.y / scale)
        end
    end

    --Anchor
    self.anchor:SetWidth(width)
    self.anchor:ClearAllPoints()
    if (self.db.growDirection == "TOP") then
        self.anchor:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
    elseif self.growDirection == "BOTTOM" or self.growDirection == "RIGHT" then
        self.anchor:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT")
    else
        self.anchor:SetPoint("BOTTOMRIGHT", self.frame, "TOPRIGHT")
    end

    if (self.db.locked) then
        self.anchor:Hide()
    else
        self.anchor:Show()
    end

    for i = 1, teamSize do
        local button = self.buttons["arena" .. i]
        button:SetWidth(self.db.barWidth)
        button:SetHeight(self.db.healthBarHeight)
        button.secure:SetWidth(self.db.barWidth)
        button.secure:SetHeight(self.db.healthBarHeight + powerBarHeight)

        button:ClearAllPoints()
        button.secure:ClearAllPoints()
        if (self.db.growDirection == "TOP") then
            if (i == 1) then
                button:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", leftSize, powerBarHeight)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            else
                button:SetPoint("BOTTOMLEFT", self.buttons["arena" .. (i - 1)], "TOPLEFT", 0, margin + self.db.bottomMargin)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            end
        elseif (self.db.growDirection == "BOTTOM") then
            if (i == 1) then
                button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", leftSize, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            else
                button:SetPoint("TOPLEFT", self.buttons["arena" .. (i - 1)], "BOTTOMLEFT", 0, -margin - self.db.bottomMargin)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            end
        elseif (self.db.growDirection == "LEFT") then
            if (i == 1) then
                button:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -rightSize, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            else
                button:SetPoint("TOPRIGHT", self.buttons["arena" .. (i - 1)], "TOPLEFT", -rightSize - leftSize - self.db.bottomMargin, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            end
        elseif (self.db.growDirection == "RIGHT") then
            if (i == 1) then
                button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", leftSize, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            else
                button:SetPoint("TOPLEFT", self.buttons["arena" .. (i - 1)], "TOPRIGHT", leftSize + rightSize + self.db.bottomMargin, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            end
        end


        for _, v in self:IterModules() do
            self:Call(v, "UpdateFrame", "arena" .. i)
        end
    end
    for _, v in self:IterModules() do
        self:Call(v, "UpdateFrameOnce")
    end
end

function Gladdy:HideFrame()
    if (self.frame) then
        self.frame:Hide()
        self.frame.testing = nil
    end
end

function Gladdy:ToggleFrame(i)
    self:Reset()
    if (self.frame and self.frame:IsShown() and i == self.curBracket) then
        self:HideFrame()
    else
        self.curBracket = i

        if (not self.frame) then
            self:CreateFrame()
        end

        for o = 1, self.curBracket do
            local unit = "arena" .. o
            if (not self.buttons[unit]) then
                self:CreateButton(o)
            end
        end
        self:Reset()
        self.curBracket = i
        self:UpdateFrame()
        self:Test()
        self.frame:Show()
    end
end

function Gladdy:CreateButton(i)
    if (not self.frame) then
        self:CreateFrame()
    end

    local button = CreateFrame("Frame", "GladdyButtonFrame" .. i, self.frame)
    button:EnableMouse(false)
    --button:SetAlpha(0)
    --button.texture = button:CreateTexture(nil, "OVERLAY")
    --button.texture:SetAllPoints(button)
    --button.texture:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")

    local secure = CreateFrame("Button", "GladdyButton" .. i, button, "SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate")
    secure:RegisterForClicks("AnyUp")
    secure:RegisterForClicks("AnyDown")

    secure:SetAttribute("target", "arena" .. i)
    secure:SetAttribute("focus", "arena" .. i)
    secure:SetAttribute("unit", "arena" .. i)

    --[[
    secure:SetAttribute("target", i == 1 and "player" or "focus")
    secure:SetAttribute("focus", i == 1 and "player" or "focus")
    secure:SetAttribute("unit", i == 1 and "player" or "focus")
    --]]

    --secure.texture = secure:CreateTexture(nil, "OVERLAY")
    --secure.texture:SetAllPoints(secure)
    --secure.texture:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")

    button.id = i
    --button.unit = i == 1 and "player" or "focus"
    button.unit = "arena" .. i
    button.secure = secure


    self:ResetButton("arena" .. i)

    self.buttons["arena" .. i] = button

    for _, v in self:IterModules() do
        self:Call(v, "CreateFrame", "arena" .. i)
    end
    self:ResetButton("arena" .. i)
end

function Gladdy:GetAnchor(unit, position)
    local anchor = "healthBar"
    if Gladdy.db.classIconPos == position then
        anchor = "classIcon"
    end
    if Gladdy.db.trinketPos == position then
        anchor = "trinket"
    end
    if anchor == Gladdy.db.racialAnchor and Gladdy.db.racialPos == position then
        anchor = "racial"
    end
    return Gladdy.buttons[unit][anchor]
end