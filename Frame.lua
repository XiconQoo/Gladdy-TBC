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
}

function Gladdy:CreateFrame()
    self.frame = CreateFrame("Frame", "GladdyFrame", UIParent)

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

    if (not self.frame) then
        self:CreateFrame()
    end
    local teamSize = self.curBracket or 0

    local iconSize = self.db.healthBarHeight
    local margin = 0
    local width = self.db.barWidth + self.db.padding * 2 + 5
    local height = self.db.healthBarHeight * teamSize + margin * (teamSize - 1) + self.db.padding * 2 + 5
    local extraBarWidth = 0
    local extraBarHeight = 0

    -- Powerbar
    iconSize = iconSize + self.db.powerBarHeight
    margin = margin + self.db.powerBarHeight
    height = height + self.db.powerBarHeight * teamSize
    extraBarHeight = extraBarHeight + self.db.powerBarHeight

    -- Cooldown
    margin = margin + 1 + self.db.highlightBorderSize * 2 + 1 -- + 1 space between health and power bar
    height = height + self.db.highlightBorderSize * teamSize

    if (self.db.cooldownYPos == "TOP" or self.db.cooldownYPos == "BOTTOM") and self.db.cooldown then
        margin = margin + self.db.cooldownSize
        height = height + self.db.cooldownSize * teamSize
    end
    if (self.db.buffsCooldownPos == "TOP" or self.db.buffsCooldownPos == "BOTTOM") and self.db.buffsEnabled then
        margin = margin + self.db.buffsIconSize
        height = height + self.db.buffsIconSize * teamSize
    end
    if (self.db.buffsBuffsCooldownPos == "TOP" or self.db.buffsBuffsCooldownPos == "BOTTOM") and self.db.buffsEnabled then
        margin = margin + self.db.buffsBuffsIconSize
        height = height + self.db.buffsBuffsIconSize * teamSize
    end
    if self.db.buffsCooldownPos == "TOP" and self.db.cooldownYPos == "TOP" and self.db.cooldown and self.db.buffsEnabled then
        margin = margin + 1
    end
    if self.db.buffsCooldownPos == "BOTTOM" and self.db.cooldownYPos == "BOTTOM" and self.db.cooldown and self.db.buffsEnabled then
        margin = margin + 1
    end

    -- Classicon
    width = width + iconSize
    extraBarWidth = extraBarWidth + iconSize

    -- Trinket
    width = width + iconSize

    self.frame:SetScale(self.db.frameScale)
    self.frame:SetWidth(width)
    self.frame:SetHeight(height)
    --self.frame:SetBackdropColor(self.db.frameColor.r, self.db.frameColor.g, self.db.frameColor.b, self.db.frameColor.a)
    self.frame:ClearAllPoints()
    if (self.db.x == 0 and self.db.y == 0) then
        self.frame:SetPoint("CENTER")
    else
        local scale = self.frame:GetEffectiveScale()
        if (self.db.growUp) then
            self.frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.db.x / scale, self.db.y / scale)
        else
            self.frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", self.db.x / scale, self.db.y / scale)
        end
    end

    self.anchor:SetWidth(width)
    self.anchor:ClearAllPoints()
    if (self.db.growUp) then
        self.anchor:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
    else
        self.anchor:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT")
    end

    if (self.db.locked) then
        self.anchor:Hide()
        self.anchor:Hide()
    else
        self.anchor:Show()
    end

    for i = 1, teamSize do
        local button = self.buttons["arena" .. i]
        button:SetWidth(self.db.barWidth + extraBarWidth)
        button:SetHeight(self.db.healthBarHeight)
        button.secure:SetWidth(self.db.barWidth)
        button.secure:SetHeight(self.db.healthBarHeight + extraBarHeight)

        button:ClearAllPoints()
        button.secure:ClearAllPoints()
        if (self.db.growUp) then
            if (i == 1) then
                button:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", self.db.padding + 2, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            else
                button:SetPoint("BOTTOMLEFT", self.buttons["arena" .. (i - 1)], "TOPLEFT", 0, margin + self.db.bottomMargin)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            end
        else
            if (i == 1) then
                button:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.db.padding + 2, 0)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            else
                button:SetPoint("TOPLEFT", self.buttons["arena" .. (i - 1)], "BOTTOMLEFT", 0, -margin - self.db.bottomMargin)
                button.secure:SetPoint("TOPLEFT", button.healthBar, "TOPLEFT")
            end
        end


        for k, v in self:IterModules() do
            self:Call(v, "UpdateFrame", button.unit)
        end
    end
    for k, v in self:IterModules() do
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
    button:SetAlpha(0)

    local secure = CreateFrame("Button", "GladdyButton" .. i, button, "SecureActionButtonTemplate")
    secure:RegisterForClicks("AnyUp")
    secure:RegisterForClicks("AnyUp")
    secure:SetAttribute("*type1", "target")
    secure:SetAttribute("*type2", "focus")
    secure:SetAttribute("unit", "arena" .. i)
    --secure.texture = secure:CreateTexture(nil, "OVERLAY")
    --secure.texture:SetAllPoints(secure)
    --secure.texture:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")

    button.id = i
    button.unit = "arena" .. i
    button.secure = secure


    self:ResetButton(button.unit)

    self.buttons[button.unit] = button

    for k, v in self:IterModules() do
        self:Call(v, "CreateFrame", button.unit)
    end
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