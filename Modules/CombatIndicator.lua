local select, str_match = select, string.match
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists, UnitAffectingCombat, GetSpellInfo = UnitExists, UnitAffectingCombat, GetSpellInfo
local CreateFrame = CreateFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local CombatIndicator = Gladdy:NewModule("Combat Indicator", nil, {
    ciEnabled = true,
    ciSize = 20,
    ciAlpha = 1,
    ciWidthFactor = 1,
    ciXOffset = 0,
    ciYOffset = -31,
    ciBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    ciBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    ciFrameStrata = "HIGH",
    ciFrameLevel = 5,
})

local petClasses = {["MAGE"] = 1, ["PRIEST"] = 1, ["SHAMAN"] = 1, ["WARLOCK"] = 1, ["HUNTER"] = 1, ["DEATHKNIGHT"] = 1}
local function InCombat(unit)
    if not Gladdy.buttons[unit] then
        return
    end
    local class = Gladdy.buttons[unit].class

    if UnitExists(unit) and UnitAffectingCombat(unit) then
        return true
    elseif (petClasses[class]) then
        local arenaNumber = str_match(unit, "%d")
        if UnitExists("arenapet" .. arenaNumber .. "target")
                or UnitDetailedThreatSituation("player", "arenapet" .. arenaNumber)
                or UnitDetailedThreatSituation("playerpet", "arenapet" .. arenaNumber) then
            return true
        end
        for i = 1, Gladdy.curBracket - 1 do
            if UnitDetailedThreatSituation("party"..i, "arenapet" .. arenaNumber)
                    or UnitDetailedThreatSituation("party"..i .. "pet", "arenapet" .. arenaNumber) then
                return true
            end
        end
    end
    return false
end

function CombatIndicator:Initialize()
    self.frames = {}
    if Gladdy.db.ciEnabled then
        self:RegisterMessage("JOINED_ARENA")
    end
    self.updateInterval = 0.05
    self.combatIndicatorIcon = select(3, GetSpellInfo(674))
end

function CombatIndicator:JOINED_ARENA()
    for i=1, Gladdy.curBracket do
        CombatIndicator.frames["arena" .. i]:Hide()
    end
    self:RegisterEvent("UNIT_FLAGS")
    self:SetScript("OnEvent", CombatIndicator.OnEvent)
    self.lastTimeUpdated = 0
end

function CombatIndicator.OnEvent(self, event, ...)
    CombatIndicator[event](self, ...)
end

function CombatIndicator:UNIT_FLAGS(unit)
    if CombatIndicator.frames[unit] then
        if Gladdy.db.ciEnabled and (CombatIndicator.test or InCombat(unit)) then
            CombatIndicator.frames[unit]:Show()
        else
            CombatIndicator.frames[unit]:Hide()
        end
    end
end

function CombatIndicator:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    local ciFrame = CreateFrame("Frame", "GladdyCombatindicator" .. unit, button)
    ciFrame:EnableMouse(false)
    ciFrame:SetMovable(true)
    ciFrame:SetFrameStrata(Gladdy.db.ciFrameStrata)
    ciFrame:SetFrameLevel(Gladdy.db.ciFrameLevel)
    ciFrame:SetHeight(Gladdy.db.ciSize)
    ciFrame:SetWidth(Gladdy.db.ciSize * Gladdy.db.ciWidthFactor)

    ciFrame.texture = ciFrame:CreateTexture(nil, "BACKGROUND")
    ciFrame.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    ciFrame.texture:SetTexture(self.combatIndicatorIcon)
    ciFrame.texture:SetAllPoints(ciFrame)

    ciFrame.border = ciFrame:CreateTexture(nil, "OVERLAY")
    ciFrame.border:SetAllPoints(ciFrame)
    ciFrame.border:SetTexture(Gladdy.db.ciBorderStyle)
    ciFrame.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.ciBorderColor))

    self.frames[unit] = ciFrame
    button.ciFrame = ciFrame
end

function CombatIndicator:UpdateFrameOnce()
    if Gladdy.db.ciEnabled then
        self:RegisterMessage("JOINED_ARENA")
    else
        self:UnregisterAllMessages()
    end
end

function CombatIndicator:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    local ciFrame = self.frames[unit]
    if (not button or not ciFrame) then
        return
    end

    ciFrame:SetFrameStrata(Gladdy.db.ciFrameStrata)
    ciFrame:SetFrameLevel(Gladdy.db.ciFrameLevel)

    ciFrame:SetHeight(Gladdy.db.ciSize)
    ciFrame:SetWidth(Gladdy.db.ciSize * Gladdy.db.ciWidthFactor)
    ciFrame.border:SetTexture(Gladdy.db.ciBorderStyle)
    ciFrame.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.ciBorderColor))

    Gladdy:SetPosition(ciFrame, unit, "ciXOffset", "ciYOffset", CombatIndicator:LegacySetPosition(ciFrame, unit), CombatIndicator)

    ciFrame:SetAlpha(Gladdy.db.ciAlpha)

    if (Gladdy.db.ciEnabled == false) then
        ciFrame:Hide()
    else
        ciFrame:Show()
    end
    if (unit == "arena1") then
        Gladdy:CreateMover(ciFrame, "ciXOffset", "ciYOffset", L["Combat Indicator"],
                {"TOPLEFT", "TOPLEFT"},
                Gladdy.db.ciSize * Gladdy.db.ciWidthFactor, Gladdy.db.ciSize,
                0, 0, "ciEnabled")
    end
end

function CombatIndicator:Test()
    self.test = true
    self:JOINED_ARENA()
    for i=1,Gladdy.curBracket do
        local unit = "arena" .. i
        self:UNIT_FLAGS(unit)
    end
end

function CombatIndicator:Reset()
    self:SetScript("OnEvent", nil)
    self:UnregisterAllEvents()
    self.test = false
end

--[[function CombatIndicator.OnEvent(self, elapsed)
    self.lastTimeUpdated = self.lastTimeUpdated + elapsed

    if (self.lastTimeUpdated > self.updateInterval) then
        for i=1,Gladdy.curBracket do
            local unit = "arena" .. i
            if Gladdy.db.ciEnabled and (CombatIndicator.test or (UnitExists(unit) and UnitAffectingCombat(unit))) then
                CombatIndicator.frames[unit]:Show()
            else
                CombatIndicator.frames[unit]:Hide()
            end
        end
        self.lastTimeUpdated = 0
    end
end--]]

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
            disabled = function() return not Gladdy.db.ciEnabled end,
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
                            width = "full",
                        }),
                        ciWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            order = 3,
                            width = "full",
                        }),
                        ciAlpha = Gladdy:option({
                            type = "range",
                            name = L["Alpha"],
                            min = 0,
                            max = 1,
                            step = 0.05,
                            order = 4,
                            width = "full",
                        }),
                    },
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 3,
                    args = {
                        header = {
                            type = "header",
                            name = L["Position"],
                            order = 4,
                        },
                        ciXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 23,
                            min = -400,
                            max = 400,
                            step = 0.1,
                            width = "full",
                        }),
                        ciYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 24,
                            min = -400,
                            max = 400,
                            step = 0.1,
                            width = "full",
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 2,
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
                frameStrata = {
                    type = "group",
                    name = L["Frame Strata and Level"],
                    order = 5,
                    args = {
                        headerAuraLevel = {
                            type = "header",
                            name = L["Frame Strata and Level"],
                            order = 1,
                        },
                        ciFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Frame Strata"],
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        ciFrameLevel = Gladdy:option({
                            type = "range",
                            name = L["Frame Level"],
                            min = 0,
                            max = 500,
                            step = 1,
                            order = 3,
                            width = "full",
                        }),
                    },
                },
            },
        },
    }
end

---------------------------

-- LAGACY HANDLER

---------------------------

function CombatIndicator:LegacySetPosition(ciFrame, unit)
    if Gladdy.db.newLayout then
        return Gladdy.db.newLayout
    end
    -- LEGACY options
    local ANCHORS = { ["LEFT"] = "RIGHT", ["RIGHT"] = "LEFT", ["BOTTOM"] = "TOP", ["TOP"] = "BOTTOM"}
    local ciAnchor = Gladdy.db.ciAnchor or Gladdy.legacy.ciAnchor
    local ciPos = Gladdy.db.ciPos

    ciFrame:ClearAllPoints()
    ciFrame:SetPoint(ANCHORS[ciPos], Gladdy.buttons[unit][ciAnchor], ciPos, Gladdy.db.ciXOffset, Gladdy.db.ciYOffset)
    return Gladdy.db.newLayout
end