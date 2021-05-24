local select = select
local UnitExists, UnitAffectingCombat, GetSpellInfo = UnitExists, UnitAffectingCombat, GetSpellInfo
local CreateFrame = CreateFrame
local ANCHORS = { ["LEFT"] = "RIGHT", ["RIGHT"] = "LEFT", ["BOTTOM"] = "TOP", ["TOP"] = "BOTTOM"}

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local CombatIndicator = Gladdy:NewModule("Combat Indicator", nil, {
    ciEnabled = true,
    ciSize = 20,
    ciAlpha = 1,
    ciWidthFactor = 1,
    ciAnchor = "healthBar",
    ciPos = "TOP",
    ciXOffset = 0,
    ciYOffset = -31,
    ciBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    ciBorderColor = { r = 0, g = 0, b = 0, a = 1 },
})

function CombatIndicator:Initialize()
    self.frames = {}
    self:RegisterMessage("JOINED_ARENA")
    self.updateInterval = 0.05
    self.combatIndicatorIcon = select(3, GetSpellInfo(674))
end

function CombatIndicator:JOINED_ARENA()
    self:SetScript("OnUpdate", CombatIndicator.OnEvent)
    self.lastTimeUpdated = 0
end

function CombatIndicator:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    local ciFrame = CreateFrame("Frame", "GladdyCombatindicator" .. unit, button)
    ciFrame:EnableMouse(false)
    ciFrame:SetFrameStrata("HIGH")
    ciFrame:SetHeight(Gladdy.db.ciSize)
    ciFrame:SetWidth(Gladdy.db.ciSize * Gladdy.db.ciWidthFactor)

    ciFrame.texture = ciFrame:CreateTexture(nil, "OVERLAY")
    ciFrame.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    ciFrame.texture:SetTexture(self.combatIndicatorIcon)
    ciFrame.texture:SetAllPoints(ciFrame)

    ciFrame.border = ciFrame:CreateTexture(nil, "OVERLAY")
    ciFrame.border:SetAllPoints(ciFrame)
    ciFrame.border:SetTexture(Gladdy.db.ciBorderStyle)
    ciFrame.border:SetVertexColor(Gladdy.db.ciBorderColor.r, Gladdy.db.ciBorderColor.g, Gladdy.db.ciBorderColor.b, Gladdy.db.ciBorderColor.a)

    self.frames[unit] = ciFrame
    button.ciFrame = ciFrame
end

function CombatIndicator:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    local ciFrame = self.frames[unit]
    if (not button or not ciFrame) then
        return
    end
    ciFrame:SetHeight(Gladdy.db.ciSize)
    ciFrame:SetWidth(Gladdy.db.ciSize * Gladdy.db.ciWidthFactor)
    ciFrame.border:SetTexture(Gladdy.db.ciBorderStyle)
    ciFrame.border:SetVertexColor(Gladdy.db.ciBorderColor.r, Gladdy.db.ciBorderColor.g, Gladdy.db.ciBorderColor.b, Gladdy.db.ciBorderColor.a)

    ciFrame:ClearAllPoints()
    ciFrame:SetPoint(ANCHORS[Gladdy.db.ciPos], Gladdy.buttons[unit][Gladdy.db.ciAnchor], Gladdy.db.ciPos, Gladdy.db.ciXOffset, Gladdy.db.ciYOffset)

    ciFrame:SetAlpha(Gladdy.db.ciAlpha)

    if (Gladdy.db.ciEnabled == false) then
        ciFrame:Hide()
    else
        ciFrame:Show()
    end
end

function CombatIndicator:Test()
    self.test = true
    self:JOINED_ARENA()
end

function CombatIndicator:Reset()
    self:SetScript("OnUpdate", nil)
    self.test = false
end

function CombatIndicator.OnEvent(self, elapsed)
    self.lastTimeUpdated = self.lastTimeUpdated + elapsed

    if (self.lastTimeUpdated > self.updateInterval) then
        for i=1,Gladdy.curBracket do
            local unit = "arena" .. i
            if CombatIndicator.test or (UnitExists(unit) and UnitAffectingCombat(unit)) then
                CombatIndicator.frames[unit]:Show()
            else
                CombatIndicator.frames[unit]:Hide()
            end
        end
        self.lastTimeUpdated = 0
    end
end

function CombatIndicator:GetOptions()
    return {
        header = {
            type = "header",
            name = L["Combat Indicator"],
            order = 2,
        },
        ciEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enable Combat Indicator icon"],
            order = 3,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            args = {
                general = {
                    type = "group",
                    name = L["Frame"],
                    order = 1,
                    args = {
                        header = {
                            type = "header",
                            name = L["Frame"],
                            order = 1,
                        },
                        ciSize = Gladdy:option({
                            type = "range",
                            name = L["Icon size"],
                            min = 5,
                            max = 100,
                            step = 1,
                            order = 2,
                        }),
                        ciWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            order = 3,
                        }),
                        ciAlpha = Gladdy:option({
                            type = "range",
                            name = L["Alpha"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                            order = 4,
                        }),
                    },
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Position"],
                            order = 4,
                        },
                        ciAnchor = Gladdy:option({
                            type = "select",
                            name = L["Anchor"],
                            desc = L["This changes the anchor of the ci icon"],
                            order = 20,
                            values = {
                                ["trinket"] = L["Trinket"],
                                ["classIcon"] = L["Class Icon"],
                                ["healthBar"] = L["Health Bar"],
                                ["powerBar"] = L["Power Bar"],
                            },
                        }),
                        ciPos = Gladdy:option({
                            type = "select",
                            name = L["Position"],
                            desc = L["This changes position relative to its anchor of the ci icon"],
                            order = 21,
                            values = {
                                ["LEFT"] = L["Left"],
                                ["RIGHT"] = L["Right"],
                                ["TOP"] = L["Top"],
                                ["BOTTOM"] = L["Bottom"],
                            },
                        }),
                        ciXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 23,
                            min = -400,
                            max = 400,
                            step = 0.1,
                        }),
                        ciYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 24,
                            min = -400,
                            max = 400,
                            step = 0.1,
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Border"],
                            order = 4,
                        },
                        ciBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 31,
                            values = Gladdy:GetIconStyles()
                        }),
                        ciBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 32,
                            hasAlpha = true,
                        }),
                    },
                },
            },
        },
    }
end