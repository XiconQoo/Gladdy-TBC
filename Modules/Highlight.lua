local CreateFrame, UnitIsUnit = CreateFrame, UnitIsUnit

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Highlight = Gladdy:NewModule("Highlight", nil, {
    highlightBorderSize = 2,
    targetBorderColor = { r = 1, g = 0.8, b = 0, a = 1 },
    focusBorderColor = { r = 1, g = 0, b = 0, a = 1 },
    leaderBorderColor = { r = 0, g = 1, b = 0, a = 1 },
    highlight = true,
    targetBorder = true,
    focusBorder = true,
    leaderBorder = true,
})

function Highlight:Initialize()
    self:RegisterMessage("JOINED_ARENA")
end

function Highlight:JOINED_ARENA()
    self:RegisterEvent("PLAYER_FOCUS_CHANGED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end

function Highlight:Reset()
    self:UnregisterAllEvents()
    self:SetScript("OnEvent", nil)
end

function Highlight:PLAYER_TARGET_CHANGED()
    for i=1, Gladdy.curBracket do
        self:Toggle("arena" .. i, "target", UnitIsUnit("target", "arena" .. i))
    end
end

function Highlight:PLAYER_FOCUS_CHANGED()
    for i=1, Gladdy.curBracket do
        self:Toggle("arena" .. i, "focus", UnitIsUnit("focus", "arena" .. i))
    end
end

function Highlight:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    local healthBar = Gladdy.modules.Healthbar.frames[unit]

    local targetBorder = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
    targetBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = Gladdy.db.highlightBorderSize })
    targetBorder:SetFrameStrata("HIGH")
    targetBorder:Hide()

    local focusBorder = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
    focusBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = Gladdy.db.highlightBorderSize })
    focusBorder:SetFrameStrata("LOW")
    focusBorder:Hide()

    local leaderBorder = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
    leaderBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = Gladdy.db.highlightBorderSize })
    leaderBorder:SetFrameStrata("MEDIUM")
    leaderBorder:Hide()

    local highlight = healthBar:CreateTexture(nil, "OVERLAY")
    highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
    highlight:SetBlendMode("ADD")
    highlight:SetAlpha(0.5)
    highlight:ClearAllPoints()
    highlight:SetAllPoints(healthBar)
    highlight:Hide()

    button.targetBorder = targetBorder
    button.focusBorder = focusBorder
    button.leaderBorder = leaderBorder
    button.highlight = highlight
end

function Highlight:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    local borderSize = Gladdy.db.highlightBorderSize
    local iconSize = Gladdy.db.healthBarHeight + Gladdy.db.powerBarHeight + 1
    local width = Gladdy.db.barWidth + borderSize * 2
    local height = iconSize + borderSize * 2

    button.targetBorder:SetWidth(width)
    button.targetBorder:SetHeight(height)
    button.targetBorder:ClearAllPoints()
    button.targetBorder:SetPoint("TOP", button.healthBar, "TOP", 0, borderSize)
    button.targetBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = borderSize })
    button.targetBorder:SetBackdropBorderColor(Gladdy.db.targetBorderColor.r, Gladdy.db.targetBorderColor.g, Gladdy.db.targetBorderColor.b, Gladdy.db.targetBorderColor.a)

    button.focusBorder:SetWidth(width)
    button.focusBorder:SetHeight(height)
    button.focusBorder:ClearAllPoints()
    button.focusBorder:SetPoint("TOP", button.healthBar, "TOP", 0, borderSize)
    button.focusBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = borderSize })
    button.focusBorder:SetBackdropBorderColor(Gladdy.db.focusBorderColor.r, Gladdy.db.focusBorderColor.g, Gladdy.db.focusBorderColor.b, Gladdy.db.focusBorderColor.a)

    button.leaderBorder:SetWidth(width)
    button.leaderBorder:SetHeight(height)
    button.leaderBorder:ClearAllPoints()
    button.leaderBorder:SetPoint("TOP", button.healthBar, "TOP", 0, borderSize)
    button.leaderBorder:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = borderSize })
    button.leaderBorder:SetBackdropBorderColor(Gladdy.db.leaderBorderColor.r, Gladdy.db.leaderBorderColor.g, Gladdy.db.leaderBorderColor.b, Gladdy.db.leaderBorderColor.a)
    if Gladdy.frame.testing then
        Highlight:Test(unit)
    end
end

function Highlight:ResetUnit(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    button.targetBorder:Hide()
    button.focusBorder:Hide()
    button.leaderBorder:Hide()
    button.highlight:Hide()
end

function Highlight:Test(unit)
    if (unit == "arena1") then
        self:Toggle(unit, "focus", true)
    elseif (unit == "arena2") then
        self:Toggle(unit, "target", true)
    elseif (unit == "arena3") then
        self:Toggle(unit, "leader", true)
    end
end

function Highlight:Toggle(unit, frame, show)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    if (frame == "target") then
        if (Gladdy.db.targetBorder and show) then
            button.targetBorder:Show()
        else
            button.targetBorder:Hide()
        end

        if (Gladdy.db.highlight and show) then
            button.highlight:Show()
        else
            button.highlight:Hide()
        end
    elseif (frame == "focus") then
        if (Gladdy.db.focusBorder and show) then
            button.focusBorder:Show()
        else
            button.focusBorder:Hide()
        end
    elseif (frame == "leader") then
        if (Gladdy.db.leaderBorder and show) then
            button.leaderBorder:Show()
        else
            button.leaderBorder:Hide()
        end
    end
end

function Highlight:GetOptions()
    return {
        headerHighlight = {
            type = "header",
            name = L["Highlight"],
            order = 2,
        },
        highlightBorderSize = {
            type = "range",
            name = L["Border size"],
            desc = L["Border size"],
            order = 3,
            min = 1,
            max = 10,
            step = 1,
        },
        targetBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Target border color"],
            desc = L["Color of the selected targets border"],
            order = 4,
            hasAlpha = true,
        }),
        focusBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Focus border color"],
            desc = L["Color of the focus border"],
            order = 5,
            hasAlpha = true,
        }),
        leaderBorderColor = Gladdy:colorOption({
            type = "color",
            name = L["Raid leader border color"],
            desc = L["Color of the raid leader border"],
            order = 6,
            hasAlpha = true,
        }),
        headerEnable = {
            type = "header",
            name = L["Enable/Disable"],
            order = 10,
        },
        highlight = Gladdy:option({
            type = "toggle",
            name = L["Highlight target"],
            desc = L["Toggle if the selected target should be highlighted"],
            order = 11,
        }),
        targetBorder = Gladdy:option({
            type = "toggle",
            name = L["Show border around target"],
            desc = L["Toggle if a border should be shown around the selected target"],
            order = 12,
        }),
        focusBorder = Gladdy:option({
            type = "toggle",
            name = L["Show border around focus"],
            desc = L["Toggle of a border should be shown around the current focus"],
            order = 13,
        }),
        leaderBorder = Gladdy:option({
            type = "toggle",
            name = L["Show border around raid leader"],
            desc = L["Toggle if a border should be shown around the raid leader"],
            order = 14,
        }),
    }
end