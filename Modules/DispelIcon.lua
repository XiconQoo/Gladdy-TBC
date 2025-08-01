local select, str_gsub = select, string.gsub

local Gladdy = LibStub("Gladdy")
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local L = Gladdy.L
local DispelIcon = Gladdy:NewModule("Dispel Icon", 81, {
    dispelIconEnabled = true,
    dispelIconSize = 60 + 20 + 1,
    dispelIconWidthFactor = 0.9,
    dispelIconZoomed = false,
    dispelIconBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    dispelIconBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    dispelIconXOffset = 0,
    dispelIconYOffset = 0,
    dispelIconFrameStrata = "MEDIUM",
    dispelIconFrameLevel = 5,
    dispelIconGroup = false,
    dispelIconGroupDirection = "DOWN"
})

function DispelIcon:Initialize()
    self.frames = {}

    if Gladdy.db.dispelIconEnabled then
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_DEATH")
        self:RegisterMessage("UNIT_SPEC")
        self:RegisterMessage("UNIT_SPEC_PREPARATION")
    end
end

function DispelIcon:UpdateFrameOnce()
    if Gladdy.db.dispelIconEnabled then
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_DEATH")
        self:RegisterMessage("UNIT_SPEC")
        self:RegisterMessage("UNIT_SPEC_PREPARATION")
    else
        self:UnregisterAllMessages()
    end
end

function DispelIcon:CreateFrame(unit)
    local dispelIcon = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    dispelIcon:EnableMouse(false)
    dispelIcon:SetFrameStrata("MEDIUM")
    dispelIcon:SetFrameLevel(1)
    dispelIcon.texture = dispelIcon:CreateTexture(nil, "BACKGROUND")
    dispelIcon.texture:SetAllPoints(dispelIcon)
    dispelIcon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    dispelIcon.texture.masked = true

    dispelIcon.texture.overlay = dispelIcon:CreateTexture(nil, "BORDER")
    dispelIcon.texture.overlay:SetAllPoints(dispelIcon)
    dispelIcon.texture.overlay:SetTexture(Gladdy.db.dispelIconBorderStyle)

    dispelIcon:SetFrameStrata("MEDIUM")
    dispelIcon:SetFrameLevel(2)

    Gladdy.buttons[unit].dispelIcon = dispelIcon
    self.frames[unit] = dispelIcon
end

function DispelIcon:ResetUnit(unit)
    local dispelIcon = self.frames[unit]
    if (not dispelIcon) then
        return
    end

    dispelIcon.texture:SetTexture("")
end

function DispelIcon:UpdateFrame(unit)
    local dispelIcon = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not dispelIcon) then
        return
    end

    local testAgain = false

    dispelIcon:SetFrameStrata(Gladdy.db.dispelIconFrameStrata)
    dispelIcon:SetFrameLevel(Gladdy.db.dispelIconFrameLevel)

    dispelIcon:SetWidth(Gladdy.db.dispelIconSize * Gladdy.db.dispelIconWidthFactor)
    dispelIcon:SetHeight(Gladdy.db.dispelIconSize)

    if Gladdy.db.dispelIconZoomed then
        if dispelIcon.texture.masked then
            dispelIcon.texture:SetMask("")
            dispelIcon.texture:SetTexCoord(0.1,0.9,0.1,0.9)
            dispelIcon.texture.masked = nil
        end
    else
        if not dispelIcon.texture.masked then
            dispelIcon.texture:SetMask("")
            dispelIcon.texture:SetTexCoord(0,1,0,1)
            dispelIcon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
            dispelIcon.texture.masked = true
            if Gladdy.frame.testing then
                testAgain = true
            end
        end
    end

    Gladdy:SetPosition(dispelIcon, unit, "dispelIconXOffset", "dispelIconYOffset", DispelIcon:LegacySetPosition(dispelIcon, unit), DispelIcon)

    if (Gladdy.db.dispelIconGroup) then
        if (unit ~= "arena1") then
            local previousUnit = "arena" .. str_gsub(unit, "arena", "") - 1
            self.frames[unit]:ClearAllPoints()
            if Gladdy.db.dispelIconGroupDirection == "RIGHT" then
                self.frames[unit]:SetPoint("LEFT", self.frames[previousUnit], "RIGHT", 0, 0)
            elseif Gladdy.db.dispelIconGroupDirection == "LEFT" then
                self.frames[unit]:SetPoint("RIGHT", self.frames[previousUnit], "LEFT", 0, 0)
            elseif Gladdy.db.dispelIconGroupDirection == "UP" then
                self.frames[unit]:SetPoint("BOTTOM", self.frames[previousUnit], "TOP", 0, 0)
            elseif Gladdy.db.dispelIconGroupDirection == "DOWN" then
                self.frames[unit]:SetPoint("TOP", self.frames[previousUnit], "BOTTOM", 0, 0)
            end
        end
    end

    if (unit == "arena1") then
        Gladdy:CreateMover(dispelIcon, "dispelIconXOffset", "dispelIconYOffset", L["Dispel Icon"],
                {"TOPLEFT", "TOPLEFT"},
                Gladdy.db.dispelIconSize * Gladdy.db.dispelIconWidthFactor,
                Gladdy.db.dispelIconSize,
                0,
                0, "dispelIconEnabled")
    end

    dispelIcon.texture:ClearAllPoints()
    dispelIcon.texture:SetAllPoints(dispelIcon)

    dispelIcon.texture.overlay:SetTexture(Gladdy.db.dispelIconBorderStyle)
    dispelIcon.texture.overlay:SetVertexColor(Gladdy:SetColor(Gladdy.db.dispelIconBorderColor))
    if Gladdy.db.dispelIconEnabled then
        if button.spec and button.class and Gladdy.dispelIcons[button.class][button.spec] then
            dispelIcon:Show()
        end
        if testAgain then
            DispelIcon:ResetUnit(unit)
            DispelIcon:ENEMY_SPOTTED(unit)
        end
    else
        dispelIcon:Hide()
    end
end

function DispelIcon:ENEMY_SPOTTED(unit)
    local dispelIcon = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not dispelIcon or not button) then
        return
    end
    if (button.class and button.spec) and Gladdy.dispelIcons[button.class][button.spec] then
        dispelIcon.texture:SetTexture(GetSpellTexture(Gladdy.dispelIcons[button.class][button.spec]))
        dispelIcon.texture:SetAllPoints(dispelIcon)
        dispelIcon:Show()
    else
        dispelIcon:Hide()
    end
end

function DispelIcon:UNIT_SPEC(unit, spec)
    self:ENEMY_SPOTTED(unit)
end

function DispelIcon:UNIT_SPEC_PREPARATION(unit, spec)
    self:ENEMY_SPOTTED(unit)
end

function DispelIcon:LegacySetPosition(unit, unitId)

    return Gladdy.db.newLayout
end

function DispelIcon:GetOptions()
    return {
        headerDispelicon = {
            type = "header",
            name = L["Dispel Icon"],
            order = 2,
        },
        dispelIconEnabled = Gladdy:option({
            type = "toggle",
            name = L["Dispel Icon Enabled"],
            order = 3,
        }),
        dispelIconGroup = Gladdy:option({
            type = "toggle",
            name = L["Group"] .. " " .. L["Dispel Icon"],
            order = 5,
            disabled = function() return not Gladdy.db.dispelIconEnabled end,
        }),
        dispelIconGroupDirection = Gladdy:option({
            type = "select",
            name = L["Group direction"],
            order = 6,
            values = {
                ["RIGHT"] = L["Right"],
                ["LEFT"] = L["Left"],
                ["UP"] = L["Up"],
                ["DOWN"] = L["Down"],
            },
            disabled = function()
                return not Gladdy.db.dispelIconGroup or not Gladdy.db.dispelIconEnabled
            end,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 7,
            disabled = function() return not Gladdy.db.dispelIconEnabled end,
            args = {
                size = {
                    type = "group",
                    name = L["Icon"],
                    order = 1,
                    args = {
                        header = {
                            type = "header",
                            name = L["Icon"],
                            order = 1,
                        },
                        dispelIconZoomed = Gladdy:option({
                            type = "toggle",
                            name = L["Zoomed Icon"],
                            desc = L["Zoomes the icon to remove borders"],
                            order = 2,
                            width = "full",
                        }),
                        dispelIconSize = Gladdy:option({
                            type = "range",
                            name = L["Size"],
                            min = 3,
                            max = 100,
                            step = .1,
                            order = 3,
                            width = "full",
                        }),
                        dispelIconWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
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
                        headerPosition = {
                            type = "header",
                            name = L["Position"],
                            order = 5,
                        },
                        dispelIconXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 11,
                            min = -800,
                            max = 800,
                            step = 0.1,
                            width = "full",
                        }),
                        dispelIconYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 12,
                            min = -800,
                            max = 800,
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
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 10,
                        },
                        dispelIconBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 11,
                            values = Gladdy:GetIconStyles()
                        }),
                        dispelIconBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 12,
                            hasAlpha = true,
                        }),
                    },
                },
                frameStrata = {
                    type = "group",
                    name = L["Frame Strata and Level"],
                    order = 4,
                    args = {
                        headerAuraLevel = {
                            type = "header",
                            name = L["Frame Strata and Level"],
                            order = 1,
                        },
                        dispelIconFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Frame Strata"],
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        dispelIconFrameLevel = Gladdy:option({
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