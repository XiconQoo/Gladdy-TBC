local select, str_gsub, ceil = select, string.gsub, ceil
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local L = Gladdy.L
local DispelIcon = Gladdy:NewModule("Dispel Icon", 81, {
    dispelIconFont = "DorisPP",
    dispelIconFontScale = 1,
    dispelIconEnabled = true,
    dispelIconSize = 60 + 20 + 1,
    dispelIconWidthFactor = 0.9,
    dispelIconZoomed = false,
    dispelIconBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    dispelIconBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    dispelIconXOffset = 0,
    dispelIconYOffset = 0,
    dispelIconDisableCircle = false,
    dispelIconCooldownAlpha = 1,
    dispelIconCooldownNumberAlpha = 1,
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
        self:RegisterMessage("DISPEL_USED")
    end
end

function DispelIcon:UpdateFrameOnce()
    if Gladdy.db.dispelIconEnabled then
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_DEATH")
        self:RegisterMessage("UNIT_SPEC")
        self:RegisterMessage("UNIT_SPEC_PREPARATION")
        self:RegisterMessage("DISPEL_USED")
    else
        self:UnregisterAllMessages()
    end
end

local function iconTimer(self,elapsed)
    if (self.active) then
        if (self.timeLeft <= 0) then
            self.active = false
            self.cooldown:Clear()
        else
            self.timeLeft = self.timeLeft - elapsed
        end

        if Gladdy.db.dispelIconEnabled and not Gladdy.db.useOmnicc then
            local timeLeft = ceil(self.timeLeft)
            local fontSizeAboveOneMin = (self:GetWidth()/2 - 0.15 * self:GetWidth()) * Gladdy.db.dispelIconFontScale
            local fontSizeBelowOneMin = (self:GetWidth()/2 - 1) * Gladdy.db.dispelIconFontScale
            if timeLeft >= 60 then
                self.cooldownFont:SetTextColor(1, 1, 0, Gladdy.db.dispelIconCooldownNumberAlpha)
                self.cooldownFont:SetFont(Gladdy:SMFetch("font", "dispelIconFont"), fontSizeAboveOneMin > 0 and fontSizeAboveOneMin or 0.01, "OUTLINE")
            elseif timeLeft < 60 and timeLeft >= 30 then
                self.cooldownFont:SetTextColor(1, 1, 0, Gladdy.db.dispelIconCooldownNumberAlpha)
                self.cooldownFont:SetFont(Gladdy:SMFetch("font", "dispelIconFont"), fontSizeBelowOneMin > 0 and fontSizeBelowOneMin or 0.01, "OUTLINE")
            elseif timeLeft < 30 and timeLeft >= 11 then
                self.cooldownFont:SetTextColor(1, 0.7, 0, Gladdy.db.dispelIconCooldownNumberAlpha)
                self.cooldownFont:SetFont(Gladdy:SMFetch("font", "dispelIconFont"), fontSizeBelowOneMin > 0 and fontSizeBelowOneMin or 0.01, "OUTLINE")
            elseif timeLeft < 10 and timeLeft >= 5 then
                self.cooldownFont:SetTextColor(1, 0.7, 0, Gladdy.db.dispelIconCooldownNumberAlpha)
                self.cooldownFont:SetFont(Gladdy:SMFetch("font", "dispelIconFont"), fontSizeBelowOneMin > 0 and fontSizeBelowOneMin or 0.01, "OUTLINE")
            elseif timeLeft < 5 and timeLeft > 0 then
                self.cooldownFont:SetTextColor(1, 0, 0, Gladdy.db.dispelIconCooldownNumberAlpha)
                self.cooldownFont:SetFont(Gladdy:SMFetch("font", "dispelIconFont"), fontSizeBelowOneMin > 0 and fontSizeBelowOneMin or 0.01, "OUTLINE")
            end
            Gladdy:FormatTimer(self.cooldownFont, self.timeLeft, self.timeLeft < 10, true)
        else
            self.cooldownFont:SetText("")
        end
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

    dispelIcon.texture.overlay = dispelIcon:CreateTexture(nil, "OVERLAY", nil, 7)
    dispelIcon.texture.overlay:SetAllPoints(dispelIcon)
    dispelIcon.texture.overlay:SetTexture(Gladdy.db.dispelIconBorderStyle)

    dispelIcon.cooldown = CreateFrame("Cooldown", nil, dispelIcon, "CooldownFrameTemplate")
    dispelIcon.cooldown.noCooldownCount = true --Gladdy.db.dispelIconDisableOmniCC
    dispelIcon.cooldown:SetHideCountdownNumbers(true)
    dispelIcon.cooldown:SetFrameStrata(Gladdy.db.dispelIconFrameStrata)
    dispelIcon.cooldown:SetFrameLevel(Gladdy.db.dispelIconFrameLevel + 1)

    dispelIcon.cooldownFrame = CreateFrame("Frame", nil, dispelIcon)
    dispelIcon.cooldownFrame:ClearAllPoints()
    dispelIcon.cooldownFrame:SetPoint("TOPLEFT", dispelIcon, "TOPLEFT")
    dispelIcon.cooldownFrame:SetPoint("BOTTOMRIGHT", dispelIcon, "BOTTOMRIGHT")
    dispelIcon.cooldownFrame:SetFrameStrata(Gladdy.db.dispelIconFrameStrata)
    dispelIcon.cooldownFrame:SetFrameLevel(Gladdy.db.dispelIconFrameLevel + 2)

    dispelIcon.cooldownFont = dispelIcon.cooldownFrame:CreateFontString(nil, "OVERLAY")
    dispelIcon.cooldownFont:SetFont(Gladdy:SMFetch("font", "dispelIconFont"), 20, "OUTLINE")
    --trinket.cooldownFont:SetAllPoints(trinket.cooldown)
    dispelIcon.cooldownFont:SetJustifyH("CENTER")
    dispelIcon.cooldownFont:SetPoint("CENTER")

    dispelIcon:SetFrameStrata("MEDIUM")
    dispelIcon:SetFrameLevel(2)

    dispelIcon:SetScript("OnUpdate", iconTimer)

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
    local width, height = Gladdy.db.dispelIconSize * Gladdy.db.dispelIconWidthFactor, Gladdy.db.dispelIconSize

    dispelIcon:SetFrameStrata(Gladdy.db.dispelIconFrameStrata)
    dispelIcon:SetFrameLevel(Gladdy.db.dispelIconFrameLevel)
    dispelIcon.cooldown:SetFrameStrata(Gladdy.db.dispelIconFrameStrata)
    dispelIcon.cooldown:SetFrameLevel(Gladdy.db.dispelIconFrameLevel + 1)
    dispelIcon.cooldownFrame:SetFrameStrata(Gladdy.db.dispelIconFrameStrata)
    dispelIcon.cooldownFrame:SetFrameLevel(Gladdy.db.dispelIconFrameLevel + 2)

    dispelIcon:SetWidth(Gladdy.db.dispelIconSize * Gladdy.db.dispelIconWidthFactor)
    dispelIcon:SetHeight(Gladdy.db.dispelIconSize)

    if Gladdy.db.dispelIconZoomed then
        dispelIcon.cooldown:SetWidth(width)
        dispelIcon.cooldown:SetHeight(height)
    else
        dispelIcon.cooldown:SetWidth(width - width/16)
        dispelIcon.cooldown:SetHeight(height - height/16)
    end
    dispelIcon.cooldown:ClearAllPoints()
    dispelIcon.cooldown:SetPoint("CENTER", dispelIcon, "CENTER")
    dispelIcon.cooldown.noCooldownCount = true -- Gladdy.db.dispelIconDisableOmniCC
    dispelIcon.cooldown:SetAlpha(Gladdy.db.dispelIconCooldownAlpha)

    if Gladdy.db.dispelIconDisableCircle then
        dispelIcon.cooldown:SetAlpha(0)
    end

    dispelIcon.cooldown.noCooldownCount = not Gladdy.db.useOmnicc
    if Gladdy.db.useOmnicc then
        dispelIcon.cooldownFont:Hide()
    else
        dispelIcon.cooldownFont:Show()
    end

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

function DispelIcon:DISPEL_USED(unit, spellID)
    local dispelIcon = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not dispelIcon or not button or not Gladdy.dispelIcons[button.class] or not Gladdy.dispelIcons[button.class][button.spec]) then
        return
    end
    if not Gladdy.dispelIcons[button.class]
            or not Gladdy.dispelIcons[button.class][button.spec]
            or not Gladdy.dispelIcons[button.class][button.spec] == spellID then
        return
    end
    local cd = spellID and Gladdy.dispelIcons[spellID] or 8
    dispelIcon.timeLeft = cd
    dispelIcon.cooldown:SetCooldown(GetTime(), cd)
    dispelIcon.active = true
end

function DispelIcon:Test(unit)
    if Gladdy.db.dispelIconEnabled then
        self:ENEMY_SPOTTED(unit)
        self:DISPEL_USED(unit)
    end
end

function DispelIcon:LegacySetPosition(unit, unitId)
    return true
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
                cooldown = {
                    type = "group",
                    name = L["Cooldown"],
                    order = 3,
                    args = {
                        header = {
                            type = "header",
                            name = L["Cooldown"],
                            order = 4,
                        },
                        dispelIconDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 7,
                            width = "full",
                        }),
                        dispelIconCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 8,
                            width = "full",
                        }),
                        dispelIconCooldownNumberAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown number alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 9,
                            width = "full",
                        }),
                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 4,
                    disabled = function()
                        return Gladdy.db.useOmnicc
                    end,
                    args = {
                        header = {
                            type = "header",
                            name = L["Font"],
                            order = 4,
                        },
                        dispelIconFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        dispelIconFontScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the font"],
                            order = 12,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
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
                    name = L["Layer Group and Level"],
                    order = 4,
                    args = {
                        headerAuraLevel = {
                            type = "header",
                            name = L["Layer Group and Level"],
                            order = 1,
                        },
                        dispelIconFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Layer Group"],
                            desc = "General Layer Priority. Controls which layer group the frame belongs to (e.g., Background or Medium). Higher Layer numbers are drawn above lower numbers.",
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        dispelIconFrameLevel = Gladdy:option({
                            type = "range",
                            name = L["Layer Level"],
                            desc = "Fine-tuned Order Within Layer. Controls the order of frames within the same strata. Higher numbers are drawn above lower numbers.",
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