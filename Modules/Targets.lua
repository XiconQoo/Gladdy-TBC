local string_gsub, floor, pairs = string.gsub, math.floor, pairs
local select = select
local CreateFrame, SetPortraitTexture = CreateFrame, SetPortraitTexture
local UnitHealthMax, UnitHealth, UnitName, UnitClass, UnitGUID, UnitIsConnected = UnitHealthMax, UnitHealth, UnitName, UnitClass, UnitGUID, UnitIsConnected
local UnitIsPlayer, UnitIsDead, UnitIsGhost, UnitExists = UnitIsPlayer, UnitIsDead, UnitIsGhost, UnitExists

local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Targets = Gladdy:NewModule("Targets", nil, {
    targetEnabled = true,
    targetWidth = 90,
    targetHeight = 30,
    targetBarEnabled = true,
    targetPortraitEnabled = true,
    targetPortraitClass = true,
    targetPortraitBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    targetHealthBarFont = "DorisPP",
    targetHealthBarHeight = 60,
    targetHealthBarTexture = "Smooth",
    targetHealthBarBorderStyle = "Gladdy Tooltip round",
    targetHealthBarBorderSize = 9,
    targetHealthBarBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    targetHealthBarColor = { r = 0, g = 1, b = 0, a = 1 },
    targetHealthBarBgColor = { r = 0, g = 0, b = 0, a = 0.4 },
    targetHealthBarFontColor = { r = 1, g = 1, b = 1, a = 1 },
    targetHealthBarFontSize = 12,
    targetHealthUnitName = true,
    targetHealthPercentage = true,
    targetHealthBarClassColored = true,
    targetXOffset = 286,
    targetYOffset = 0,
    targetGroup = false,
    targetMargin = 1,
    targetFrameStrata = "MEDIUM",
    targetFrameLevel = 5,
})

Targets.targetUnits = {
    "arena1target", "arena2target", "arena3target", "arena4target", "arena5target"
}

function Targets:Initialize()
    self.frames = {}
    if Gladdy.db.targetEnabled then
        self:RegisterMessage("JOINED_ARENA")
    end
end

function Targets:UpdateFrameOnce()
    if Gladdy.db.targetEnabled then
        self:RegisterMessage("JOINED_ARENA")
    else
        self:UnregisterAllMessages()
    end
end

function Targets:JOINED_ARENA()
    for _,v in pairs(self.frames) do
        v:SetAlpha(0)
    end

    if Gladdy.db.targetEnabled then
        self:RegisterEvent("UNIT_HEALTH_FREQUENT")
        self:RegisterEvent("UNIT_MAXHEALTH")
        self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
        self:RegisterEvent("UNIT_NAME_UPDATE")
        self:RegisterEvent("UNIT_TARGET")
        self:SetScript("OnEvent", Targets.OnEvent)
    end
end

function Targets:OnEvent(event)
    for i=1, Gladdy.curBracket do
        local unit = self.targetUnits[i]
        local button = self.frames[unit]
        local healthBar = self.frames[unit].healthBar
        local unitGUID = UnitGUID(unit)
        if UnitGUID(unit) then
            Gladdy:Debug("INFO", unit, "show", event)
            local health = UnitHealth(unit)
            local healthMax = UnitHealthMax(unit)
            local checkedHealth
            if event == "UNIT_TARGET" and button.unitGUID ~= unitGUID then
                --changed target
                button.unitGUID = unitGUID
                self:UpdateHealthBarColor(unit)
                self:UpdatePortrait(unit)
                healthBar.hp:SetMinMaxValues(0, healthMax)
                healthBar.hp:SetValue(health)
                self:HealthCheck(unit)
                self:SetHealthText(healthBar, health, healthMax)
                self:SetText(unit)
                checkedHealth = true
            end
            if (event == "UNIT_MAXHEALTH" and not checkedHealth) then
                healthBar.hp:SetMinMaxValues(0, healthMax)
                healthBar.hp:SetValue(health)
                self:HealthCheck(unit)
                self:SetHealthText(healthBar, health, healthMax)
            end
            if (event == "UNIT_HEALTH_FREQUENT" and not checkedHealth) then
                healthBar.hp:SetValue(health)
                self:HealthCheck(unit)
                self:SetHealthText(healthBar, health, healthMax)
            end
            button:SetAlpha(1)
        else
            Gladdy:Debug("INFO", unit, "hide", event)
            button.unitGUID = nil
            button:SetAlpha(0)
        end
    end
end

function Targets:Reset()
    self:UnregisterAllEvents()
    for _,v in pairs(self.frames) do
        v:SetAlpha(0)
    end
end

function Targets:UNIT_DESTROYED(unitId)
    local unit = string_gsub(unitId, "%d$", "%1target")
    local healthBar = self.frames[unit].healthBar
    local button = self.frames[unit]
    if (not healthBar) then
        return
    end

    button:SetAlpha(0)
    button.portrait:SetTexture(nil)
end


function Targets:ENEMY_SPOTTED(unit)
    if Gladdy.db.targetEnabled then
        self:CheckUnitTarget(unit)
    end
end

function Targets:Test(unitId)
    if Gladdy.db.targetEnabled then
        local unit = string_gsub(unitId, "%d$", "%1target")
        local button = self.frames[unit]
        if (not button) then
            return
        end

        button:SetAlpha(1)
        button.healthBar.hp:SetMinMaxValues(0, 12000)
        button.healthBar.hp:SetValue(7000)
        Targets:SetHealthText(button.healthBar, 7000, 12000)
        Targets:UpdatePortrait(unit)
        Targets:SetText(unit)
        Targets:SetHealthStatusBarColor(unit)
    end
end

function Targets:CreateFrame(unitId)
    local unit = string_gsub(unitId, "%d$", "%1target")
    if self.frames[unit] then
        return
    end
    local button = CreateFrame("Frame", "GladdyButtonFrameTarget" .. unit, Gladdy.frame)
    button:SetMovable(true)
    button:SetPoint("LEFT", Gladdy.buttons[unitId].healthBar, "RIGHT", Gladdy.db.targetXOffset, Gladdy.db.targetYOffset)
    button:SetAlpha(0)

    --[[local secure = CreateFrame("Button", "GladdyButton" .. unit, button, "SecureActionButtonTemplate, SecureHandlerEnterLeaveTemplate")
    secure:RegisterForClicks("AnyUp")
    secure:RegisterForClicks("AnyDown")
    secure:SetAttribute("*type1", "target")
    secure:SetAttribute("*type2", "focus")
    secure:SetAttribute("unit", unit)
    secure:SetAllPoints(button)--]]

    button.unit = unit
    button.unitSource = unitId
    --button.secure = secure

    local healthBar = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
    healthBar:SetBackdrop({ edgeFile = Gladdy:SMFetch("border", "targetHealthBarBorderStyle"),
                            edgeSize = Gladdy.db.targetHealthBarBorderSize })
    healthBar:SetBackdropBorderColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBorderColor))
    healthBar:SetFrameStrata(Gladdy.db.targetFrameStrata)
    healthBar:SetFrameLevel(Gladdy.db.targetFrameLevel)
    healthBar:SetAllPoints(button)

    button.portrait = button:CreateTexture(nil, "BACKGROUND")
    button.portrait:SetPoint("LEFT", healthBar, "RIGHT")
    --button.portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.portrait.border = button:CreateTexture(nil, "OVERLAY")
    button.portrait.border:SetAllPoints(button.portrait)
    button.portrait.border:SetTexture(Gladdy.db.classIconBorderStyle)
    button.portrait.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBorderColor))


    healthBar.hp = CreateFrame("StatusBar", nil, healthBar)
    healthBar.hp:SetStatusBarTexture(Gladdy:SMFetch("statusbar", "targetHealthBarTexture"))
    healthBar.hp:SetStatusBarColor(Gladdy:SetColor(Gladdy.db.targetHealthBarColor))
    healthBar.hp:SetMinMaxValues(0, 100)
    healthBar.hp:SetFrameStrata(Gladdy.db.targetFrameStrata)
    healthBar.hp:SetFrameLevel(Gladdy.db.targetFrameLevel - 1)
    healthBar.hp:SetAllPoints(healthBar)

    healthBar.bg = healthBar.hp:CreateTexture(nil, "BACKGROUND")
    healthBar.bg:SetTexture(Gladdy:SMFetch("statusbar", "targetHealthBarTexture"))
    healthBar.bg:ClearAllPoints()
    healthBar.bg:SetAllPoints(healthBar.hp)
    healthBar.bg:SetAlpha(1)
    healthBar.bg:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBgColor))

    healthBar.nameText = healthBar:CreateFontString(nil, "LOW", "GameFontNormalSmall")
    if (Gladdy.db.targetHealthBarFontSize < 1) then
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.nameText:Hide()
    else
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthBarFontSize)
        healthBar.nameText:Show()
    end
    healthBar.nameText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.nameText:SetShadowOffset(1, -1)
    healthBar.nameText:SetShadowColor(0, 0, 0, 1)
    healthBar.nameText:SetJustifyH("CENTER")
    healthBar.nameText:SetPoint("LEFT", 5, 0)

    healthBar.healthText = healthBar:CreateFontString(nil, "LOW")
    if (Gladdy.db.targetHealthBarFontSize < 1) then
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.healthText:Hide()
    else
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthBarFontSize)
        healthBar.healthText:Hide()
    end
    healthBar.healthText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.healthText:SetShadowOffset(1, -1)
    healthBar.healthText:SetShadowColor(0, 0, 0, 1)
    healthBar.healthText:SetJustifyH("CENTER")
    healthBar.healthText:SetPoint("RIGHT", -5, 0)

    healthBar.unit = unit
    healthBar.unitSource = unitId
    button.healthBar = healthBar

    button:SetWidth(Gladdy.db.targetWidth)
    button:SetHeight(Gladdy.db.targetHeight)

    self.frames[unit] = button
end

function Targets:UpdateHealthBarColor(unit)
    local button = self.frames[unit]
    if not button or not Gladdy.db.targetBarEnabled then
        return
    end
    -- player or not
    if UnitIsPlayer(unit) then
        local class = select(2, UnitClass(unit))
        button.healthBar.hp:SetStatusBarColor(
                RAID_CLASS_COLORS[class].r,
                RAID_CLASS_COLORS[class].g,
                RAID_CLASS_COLORS[class].b, 1)
    else
        button.healthBar.hp:SetStatusBarColor(Gladdy:SetColor(Gladdy.db.targetHealthBarColor))
    end
end

function Targets:UpdatePortrait(unit)
    local button = self.frames[unit]
    if not button then
        return
    end
    if Gladdy.frame.testing then
        unit = "player"
    end
    if Gladdy.db.targetPortraitClass then
        button.portrait:SetTexture(Gladdy.classIcons[select(2, UnitClass(unit))])
    else
        SetPortraitTexture(button.portrait, unit)
    end
end

function Targets:HealthCheck(unit)
    local button = self.frames[unit]
    if not button or not Gladdy.db.targetBarEnabled then
        return
    end
    if UnitIsPlayer(unit) then
        local unitHPMin, unitHPMax, unitCurrHP
        unitHPMin, unitHPMax = button.healthBar.hp:GetMinMaxValues()
        unitCurrHP = button.healthBar.hp:GetValue()
        button.unitHPPercent = unitCurrHP / unitHPMax
        if UnitIsDead(unit) and not Gladdy:isFeignDeath(unit) then
            button.portrait:SetVertexColor(0.35, 0.35, 0.35, 1.0)
        elseif UnitIsGhost(unit) then
            button.portrait:SetVertexColor(0.2, 0.2, 0.75, 1.0)
        elseif (button.unitHPPercent > 0) and (button.unitHPPercent <= 0.2) then
            button.portrait:SetVertexColor(1.0, 0.0, 0.0)
        else
            button.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        end
    else
        button.portrait:SetVertexColor(1.0, 1.0, 1.0, 1.0)
    end
end

function Targets:UpdateFrame(unitId)
    local unit = string_gsub(unitId, "%d$", "%1target")
    local healthBar = self.frames[unit].healthBar
    local button = self.frames[unit]

    if (not healthBar) then
        return
    end

    healthBar:SetFrameStrata(Gladdy.db.targetFrameStrata)
    healthBar:SetFrameLevel(Gladdy.db.targetFrameLevel)
    healthBar.hp:SetFrameStrata(Gladdy.db.targetFrameStrata)
    healthBar.hp:SetFrameLevel(Gladdy.db.targetFrameLevel - 1)

    if not Gladdy.db.targetEnabled then
        self.frames[unit]:Hide()
    else
        self.frames[unit]:Show()
    end

    self.frames[unit]:SetWidth(Gladdy.db.targetWidth)
    self.frames[unit]:SetHeight(Gladdy.db.targetHeight)

    Gladdy:SetPosition(self.frames[unit], unitId, "targetXOffset", "targetYOffset", Targets:LegacySetPosition(unit, unitId), Targets)

    if (Gladdy.db.targetGroup) then
        if (unit == "arena1target") then
            self.frames[unit]:ClearAllPoints()
            self.frames[unit]:SetPoint("TOPLEFT", Gladdy.buttons[unitId].healthBar, "TOPLEFT", Gladdy.db.targetXOffset, Gladdy.db.targetYOffset)
        else
            local previousTarget = "arena" .. string_gsub(string_gsub(unit, "arena", ""), "target", "") - 1 .. "target"
            self.frames[unit]:ClearAllPoints()
            self.frames[unit]:SetPoint("TOPLEFT", self.frames[previousTarget], "BOTTOMLEFT", 0, - Gladdy.db.targetMargin)
        end
    else
        self.frames[unit]:ClearAllPoints()
        self.frames[unit]:SetPoint("TOPLEFT", Gladdy.buttons[unitId].healthBar, "TOPLEFT", Gladdy.db.targetXOffset, Gladdy.db.targetYOffset)
    end

    button.portrait:SetHeight(Gladdy.db.targetHeight)
    button.portrait:SetWidth(Gladdy.db.targetHeight)
    if not Gladdy.db.targetPortraitEnabled then
        button.portrait:Hide()
        button.portrait.border:Hide()
    else
        button.portrait:Show()
        button.portrait.border:Show()
    end
    button.portrait.border:SetTexture(Gladdy.db.targetPortraitBorderStyle)
    button.portrait.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBorderColor))

    healthBar.bg:SetTexture(Gladdy:SMFetch("statusbar",  "targetHealthBarTexture"))
    healthBar.bg:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBgColor))

    healthBar:SetBackdrop({ edgeFile = Gladdy:SMFetch("border", "targetHealthBarBorderStyle"),
                            edgeSize = Gladdy.db.targetHealthBarBorderSize })
    healthBar:SetBackdropBorderColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBorderColor))

    healthBar.hp:SetStatusBarTexture(Gladdy:SMFetch("statusbar", "targetHealthBarTexture"))
    healthBar.hp:SetStatusBarColor(Gladdy:SetColor(Gladdy.db.targetHealthBarColor))
    healthBar.hp:ClearAllPoints()
    healthBar.hp:SetPoint("TOPLEFT", healthBar, "TOPLEFT", (Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset), -(Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset))
    healthBar.hp:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", -(Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset), (Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset))

    if (Gladdy.db.targetHealthBarFontSize < 1) then
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.nameText:Hide()
        healthBar.healthText:Hide()
    else
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthBarFontSize)
        healthBar.nameText:Show()
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthBarFontSize)
        healthBar.healthText:Show()
    end
    healthBar.nameText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.healthText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))

    if Gladdy.db.targetBarEnabled then
        healthBar:Show()
    else
        healthBar:Hide()
    end

    if (unit == "arena1target") then
        Gladdy:CreateMover(self.frames[unit], "targetXOffset", "targetYOffset", L["Targets"], {"TOPLEFT", "TOPLEFT"})
    end
end

function Targets:SetHealthStatusBarColor(unit)
    local targetsFrame = self.frames[unit]
    if not targetsFrame then
        return
    end
    if Gladdy.frame.testing then
        unit = "player"
    end

    local class = select(2, UnitClass(unit))
    if not class then
        return
    end

    local healthBar = targetsFrame.healthBar
    if not healthBar.hp.oorFactor then
        healthBar.hp.oorFactor = 1
    end

    healthBar.bg:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBgColor))

    if Gladdy.db.targetHealthBarClassColored then
        healthBar.hp:SetStatusBarColor(
                RAID_CLASS_COLORS[class].r / healthBar.hp.oorFactor,
                RAID_CLASS_COLORS[class].g / healthBar.hp.oorFactor,
                RAID_CLASS_COLORS[class].b / healthBar.hp.oorFactor, 1)
    end
end

function Targets:SetHealthText(healthBar, health, healthMax)
    local healthText = ""
    if healthMax ~= 0 then
        local healthPercentage = floor(health * 100 / healthMax)

        if (Gladdy.db.targetHealthPercentage) then
            healthText = ("%d%%"):format(healthPercentage)
        end
    else
        healthText = ""
    end

    healthBar.healthText:SetText(healthText)
end

function Targets:SetText(unit)
    local targetsFrame = self.frames[unit]
    if not targetsFrame then
        return
    end
    if Gladdy.frame.testing then
        unit = "player"
    end

    local nameText = ""
    local unitName = UnitName(unit)
    if unitName and Gladdy.db.targetHealthUnitName then
        nameText = unitName
    else
        nameText = ""
    end
    
    targetsFrame.healthBar.nameText:SetText(nameText)
end

local function option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key] = value
            Gladdy.options.args.Targets.args.group.args.border.args.targetHealthBarBorderSize.max = Gladdy.db.targetHeight/2
            if Gladdy.db.targetHealthBarBorderSize > Gladdy.db.targetHeight/2 then
                Gladdy.db.targetHealthBarBorderSize = Gladdy.db.targetHeight/2
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Targets:GetOptions()
    return {
        header = {
            type = "header",
            name = L["Targets"],
            order = 2,
        },
        targetEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enables Targets module"],
            order = 3,
        }),
        targetGroup = option({
            type = "toggle",
            name = L["Group Targets"],
            order = 4,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 3,
            disabled = function() return not Gladdy.db.targetEnabled end,
            args = {
                general = {
                    type = "group",
                    name = L["Bar"],
                    order = 1,
                    args = {
                        headerAuras = {
                            type = "header",
                            name = L["General"],
                            order = 1,
                        },
                        targetBarEnabled = option({
                            order = 2,
                            type = "toggle",
                            name = L["Enabled"],
                        }),
                        targetHeight = option({
                            type = "range",
                            name = L["Bar height"],
                            desc = L["Height of the bar"],
                            order = 3,
                            min = 10,
                            max = 100,
                            step = 1,
                            width = "full",
                        }),
                        targetWidth = option({
                            type = "range",
                            name = L["Bar width"],
                            desc = L["Width of the bar"],
                            order = 4,
                            min = 10,
                            max = 300,
                            step = 1,
                            width = "full",
                        }),
                        targetMargin = option({
                            type = "range",
                            name = L["Margin"],
                            desc = L["Height of the bar"],
                            order = 6,
                            disabled = function()
                                return not Gladdy.db.targetGroup
                            end,
                            min = 0,
                            max = 50,
                            step = .1,
                        }),
                        targetHealthBarTexture = option({
                            type = "select",
                            name = L["Bar texture"],
                            desc = L["Texture of the bar"],
                            order = 7,
                            dialogControl = "LSM30_Statusbar",
                            values = AceGUIWidgetLSMlists.statusbar,
                        }),
                        targetHealthBarClassColored = Gladdy:option({
                            type = "toggle",
                            name = L["Class Colored Bars"],
                            order = 8,
                        }),
                        targetHealthBarColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Health color"],
                            desc = L["Color of the status bar"],
                            order = 9,
                            hasAlpha = true,
                        }),
                        targetHealthBarBgColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Background color"],
                            desc = L["Color of the status bar background"],
                            order = 10,
                            hasAlpha = true,
                        }),
                    },
                },
                portrait = {
                    type = "group",
                    name = L["Portrait"],
                    order = 2,
                    args = {
                        headerAuras = {
                            type = "header",
                            name = L["Portrait"],
                            order = 1,
                        },
                        targetPortraitEnabled = Gladdy:option({
                            type = "toggle",
                            name = L["Enabled"],
                            order = 2,
                        }),
                        targetPortraitClass = Gladdy:option({
                            type = "toggle",
                            name = L["Class Icon"],
                            order = 3,
                        }),
                        targetPortraitBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 4,
                            values = Gladdy:GetIconStyles()
                        }),

                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 3,
                    args = {
                        header = {
                            type = "header",
                            name = L["Font"],
                            order = 1,
                        },
                        targetHealthBarFont = option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the bar"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        targetHealthBarFontColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Font color"],
                            desc = L["Color of the text"],
                            order = 12,
                            hasAlpha = true,
                        }),
                        targetHealthBarFontSize = option({
                            type = "range",
                            name = L["Font size"],
                            desc = L["Size of the text"],
                            order = 13,
                            min = 0,
                            max = 50,
                            width = "full",
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
                            order = 1,
                        },
                        targetHealthBarBorderStyle = option({
                            type = "select",
                            name = L["Border style"],
                            order = 21,
                            dialogControl = "LSM30_Border",
                            values = AceGUIWidgetLSMlists.border,
                        }),
                        targetHealthBarBorderSize = option({
                            type = "range",
                            name = L["Border size"],
                            desc = L["Size of the border"],
                            order = 22,
                            min = 0.5,
                            max = Gladdy.db.targetHeight/2,
                            step = 0.5,
                            width = "full",
                        }),
                        targetHealthBarBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 23,
                            hasAlpha = true,
                        }),
                    },
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 5,
                    args = {
                        header = {
                            type = "header",
                            name = L["Position"],
                            order = 1,
                        },
                        targetXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 22,
                            min = -600,
                            max = 600,
                            step = 0.1,
                            width = "full",
                        }),
                        targetYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 23,
                            min = -600,
                            max = 600,
                            step = 0.1,
                            width = "full",
                        }),
                    }
                },
                frameStrata = {
                    type = "group",
                    name = L["Frame Strata and Level"],
                    order = 6,
                    args = {
                        headerAuraLevel = {
                            type = "header",
                            name = L["Frame Strata and Level"],
                            order = 1,
                        },
                        targetFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Frame Strata"],
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        targetFrameLevel = Gladdy:option({
                            type = "range",
                            name = L["Frame Level"],
                            min = 1,
                            max = 500,
                            step = 1,
                            order = 3,
                            width = "full",
                        }),
                    },
                },
                healthValues = {
                    type = "group",
                    name = L["Health Bar Text"],
                    order = 7,
                    args = {
                        header = {
                            type = "header",
                            name = L["Health Bar Text"],
                            order = 1,
                        },
                        targetHealthUnitName = option({
                            type = "toggle",
                            name = L["Show name text"],
                            desc = L["Show the units name"],
                            order = 2,
                            width = "full",
                        }),
                        targetHealthPercentage = option({
                            type = "toggle",
                            name = L["Show health percentage"],
                            desc = L["Show health percentage on the health bar"],
                            order = 33,
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

function Targets:LegacySetPosition(unit, unitId)

    return Gladdy.db.newLayout
end