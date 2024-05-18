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
    targetBarVertical = false,
    targetPortraitEnabled = true,
    targetPortraitClass = true,
    targetPortraitBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    targetPortraitBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    targetPortraitPosition = "RIGHT",
    targetPortraitMargin = 1,
    targetPortraitSize = 30,
    targetPortraitWidthFactor = 1,
    targetHealthBarFont = "DorisPP",
    targetHealthBarTexture = "Smooth",
    targetHealthBarBorderStyle = "Gladdy Tooltip round",
    targetHealthBarBorderSize = 9,
    targetHealthBarBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    targetHealthBarColor = { r = 0, g = 1, b = 0, a = 1 },
    targetHealthBarBgColor = { r = 0, g = 0, b = 0, a = 0.4 },
    targetHealthBarFontColor = { r = 1, g = 1, b = 1, a = 1 },
    targetHealthBarFontSize = 12,
    targetHealthTextLeftFontSize = 12,
    targetHealthTextRightFontSize = 12,
    targetHealthTextLeftOutline = false,
    targetHealthTextRightOutline = false,
    targetHealthTextLeftVOffset = 0,
    targetHealthTextLeftHOffset = 5,
    targetHealthTextRightVOffset = 0,
    targetHealthTextRightHOffset = -5,
    targetHealthUnitName = true,
    targetHealthPercentage = true,
    targetHealthBarClassColored = true,
    targetXOffset = 286,
    targetYOffset = 0,
    targetGroup = false,
    targetMargin = 1,
    targetFrameStrata = "MEDIUM",
    targetFrameLevel = 8,
})

Targets.targetUnits = {
    "arena1target", "arena2target", "arena3target", "arena4target", "arena5target"
}

function Targets:Initialize()
    self.frames = {}
    if Gladdy.db.targetEnabled then
        self:RegisterMessage("JOINED_ARENA")
        self:RegisterMessage("ENEMY_SPOTTED")
    end
end

function Targets:UpdateFrameOnce()
    if Gladdy.db.targetEnabled then
        self:RegisterMessage("JOINED_ARENA")
        self:RegisterMessage("ENEMY_SPOTTED")
    else
        self:UnregisterAllMessages()
    end
end

function Targets:JOINED_ARENA()
    if Gladdy.db.targetEnabled then
        self:RegisterEvent("UNIT_HEALTH_FREQUENT")
        self:RegisterEvent("UNIT_MAXHEALTH")
        self:RegisterEvent("UNIT_TARGET")
        self:SetScript("OnEvent", Targets.OnEvent)
    end

    for i=1, Gladdy.curBracket do
        self:ENEMY_SPOTTED("arena" .. i)
    end
end

--[[local function checkTargets(unitTarget, checkUnits)
    local unit = unitTarget:gsub("target", "")
    for _,checkUnit in pairs(checkUnits) do
        if UnitIsUnit(unit, checkUnit) and not UnitIsUnit(unitTarget, checkUnit .. "target") then
            Gladdy:Debug("WARN", unitTarget, "is currupted", "checked", checkUnit)
            return false
        end
    end
    return true
end]]

function Targets:ENEMY_SPOTTED(unit)
    unit = unit .. "target"
    Gladdy:Debug("ENEMY_SPOTTED", unit)
    local unitGUID = UnitExists(unit) and UnitGUID(unit)
    local button = self.frames[unit]
    if button then
        if unitGUID then
            local health = UnitHealth(unit)
            local healthMax = UnitHealthMax(unit)

            button.unitGUID = unitGUID
            self:UpdateHealthBarColor(unit)
            self:UpdatePortrait(unit)
            button.healthBar.hp:SetMinMaxValues(0, healthMax)
            button.healthBar.hp:SetValue(health)
            self:HealthCheck(unit)
            self:SetHealthText(button.healthBar, health, healthMax)
            self:SetText(unit)
            button:SetAlpha(1)
        else
            button.unitGUID = nil
            button:SetAlpha(0)
        end
    end
end

function Targets:OnEvent(event)
    for i=1, Gladdy.curBracket do
        local unit = self.targetUnits[i]
        local button = self.frames[unit]
        local unitGUID = UnitExists(unit) and UnitGUID(unit)
        if unitGUID then
            Gladdy:Debug("INFO", unit, "show", event, unitGUID)
            local health = UnitHealth(unit)
            local healthMax = UnitHealthMax(unit)
            local checkedHealth
            if event == "UNIT_TARGET" and button.unitGUID ~= unitGUID then
                --changed target
                button.unitGUID = unitGUID
                self:UpdateHealthBarColor(unit)
                self:UpdatePortrait(unit)
                button.healthBar.hp:SetMinMaxValues(0, healthMax)
                button.healthBar.hp:SetValue(health)
                self:HealthCheck(unit)
                self:SetHealthText(button.healthBar, health, healthMax)
                self:SetText(unit)
                checkedHealth = true
            end
            if (event == "UNIT_MAXHEALTH" and not checkedHealth) then
                button.healthBar.hp:SetMinMaxValues(0, healthMax)
                button.healthBar.hp:SetValue(health)
                self:HealthCheck(unit)
                self:SetHealthText(button.healthBar, health, healthMax)
            end
            if (event == "UNIT_HEALTH_FREQUENT" and not checkedHealth) then
                button.healthBar.hp:SetValue(health)
                self:HealthCheck(unit)
                self:SetHealthText(button.healthBar, health, healthMax)
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
    button:SetFrameStrata(Gladdy.db.targetFrameStrata)
    button:SetFrameLevel(Gladdy.db.targetFrameLevel)

    button.unit = unit
    button.unitSource = unitId

    local healthBar = CreateFrame("Frame", nil, button, BackdropTemplateMixin and "BackdropTemplate")
    healthBar:SetBackdrop({ edgeFile = Gladdy:SMFetch("border", "targetHealthBarBorderStyle"),
                            edgeSize = Gladdy.db.targetHealthBarBorderSize })
    healthBar:SetBackdropBorderColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBorderColor))
    healthBar:SetFrameStrata(Gladdy.db.targetFrameStrata)
    healthBar:SetFrameLevel(Gladdy.db.targetFrameLevel)
    healthBar:SetAllPoints(button)

    button.portrait = button:CreateTexture(nil, "BACKGROUND")
    button.portrait:SetPoint("LEFT", healthBar, "RIGHT")
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

    healthBar.nameText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    if (Gladdy.db.targetHealthTextLeftFontSize < 1) then
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.nameText:Hide()
    else
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthTextLeftFontSize, Gladdy.db.targetHealthTextLeftOutline and "OUTLINE")
        healthBar.nameText:Show()
    end
    healthBar.nameText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.nameText:SetShadowOffset(1, -1)
    healthBar.nameText:SetShadowColor(0, 0, 0, 1)
    healthBar.nameText:SetJustifyH("CENTER")
    healthBar.nameText:SetPoint("LEFT", 5, 0)
    healthBar.nameText:SetPoint("LEFT", Gladdy.db.targetHealthTextLeftHOffset, Gladdy.db.targetHealthTextLeftVOffset)

    healthBar.healthText = button:CreateFontString(nil, "OVERLAY")
    if (Gladdy.db.targetHealthTextRightFontSize < 1) then
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.healthText:Hide()
    else
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthTextRightFontSize, Gladdy.db.targetHealthTextRightOutline and "OUTLINE")
        healthBar.healthText:Show()
    end
    healthBar.healthText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.healthText:SetShadowOffset(1, -1)
    healthBar.healthText:SetShadowColor(0, 0, 0, 1)
    healthBar.healthText:SetJustifyH("CENTER")
    healthBar.healthText:SetPoint("RIGHT", Gladdy.db.targetHealthTextRightHOffset, Gladdy.db.targetHealthTextRightVOffset)

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
    if Gladdy.db.targetPortraitClass and UnitIsPlayer(unit) then
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
            button.portrait.border:SetVertexColor(0.35, 0.35, 0.35, 1.0)
        elseif UnitIsGhost(unit) then
            button.portrait.border:SetVertexColor(0.2, 0.2, 0.75, 1.0)
        elseif (button.unitHPPercent > 0) and (button.unitHPPercent <= 0.2) then
            button.portrait.border:SetVertexColor(1.0, 0.0, 0.0)
        else
            button.portrait.border:SetVertexColor(1.0, 1.0, 1.0, 1.0)
        end
    else
        button.portrait.border:SetVertexColor(1.0, 1.0, 1.0, 1.0)
    end
end

function Targets:UpdateFrame(unitId)
    local unit = string_gsub(unitId, "%d$", "%1target")
    local healthBar = self.frames[unit].healthBar
    local button = self.frames[unit]

    if (not healthBar) then
        return
    end

    button:SetFrameStrata(Gladdy.db.targetFrameStrata)
    button:SetFrameLevel(Gladdy.db.targetFrameLevel)
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

    button.portrait:SetWidth(Gladdy.db.targetPortraitSize * Gladdy.db.targetPortraitWidthFactor)
    button.portrait:SetHeight(Gladdy.db.targetPortraitSize)
    button.portrait:ClearAllPoints()
    if Gladdy.db.targetPortraitPosition == "RIGHT" then
        button.portrait:SetPoint("LEFT", healthBar, "RIGHT", Gladdy.db.targetPortraitMargin, 0)
    elseif Gladdy.db.targetPortraitPosition == "LEFT" then
        button.portrait:SetPoint("RIGHT", healthBar, "LEFT", -Gladdy.db.targetPortraitMargin, 0)
    elseif Gladdy.db.targetPortraitPosition == "TOP" then
        button.portrait:SetPoint("BOTTOM", healthBar, "TOP", 0, Gladdy.db.targetPortraitMargin)
    elseif Gladdy.db.targetPortraitPosition == "BOTTOM" then
        button.portrait:SetPoint("TOP", healthBar, "BOTTOM", 0, -Gladdy.db.targetPortraitMargin)
    end


    if not Gladdy.db.targetPortraitEnabled then
        button.portrait:Hide()
        button.portrait.border:Hide()
    else
        button.portrait:Show()
        button.portrait.border:Show()
    end
    button.portrait.border:SetTexture(Gladdy.db.targetPortraitBorderStyle)
    button.portrait.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetPortraitBorderColor))

    healthBar.bg:SetTexture(Gladdy:SMFetch("statusbar",  "targetHealthBarTexture"))
    healthBar.bg:SetVertexColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBgColor))

    healthBar:SetBackdrop({ edgeFile = Gladdy:SMFetch("border", "targetHealthBarBorderStyle"),
                            edgeSize = Gladdy.db.targetHealthBarBorderSize })
    healthBar:SetBackdropBorderColor(Gladdy:SetColor(Gladdy.db.targetHealthBarBorderColor))

    healthBar.hp:SetStatusBarTexture(Gladdy:SMFetch("statusbar", "targetHealthBarTexture"))
    if Gladdy.testing then
        healthBar.hp:SetStatusBarColor(Gladdy:SetColor(Gladdy.db.targetHealthBarColor))
    else
        self:UpdateHealthBarColor(unit)
    end

    healthBar.hp:ClearAllPoints()
    healthBar.hp:SetPoint("TOPLEFT", healthBar, "TOPLEFT", (Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset), -(Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset))
    healthBar.hp:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", -(Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset), (Gladdy.db.targetHealthBarBorderSize/Gladdy.db.statusbarBorderOffset))

    if Gladdy.db.targetBarVertical then
        healthBar.hp:SetOrientation("VERTICAL")
    else
        healthBar.hp:SetOrientation("HORIZONTAL")
    end

    if (Gladdy.db.targetHealthTextLeftFontSize < 1) then
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.nameText:Hide()
    else
        healthBar.nameText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthTextLeftFontSize, Gladdy.db.targetHealthTextLeftOutline and "OUTLINE")
        healthBar.nameText:Show()
    end
    if (Gladdy.db.targetHealthTextRightFontSize < 1) then
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), 1)
        healthBar.healthText:Hide()
    else
        healthBar.healthText:SetFont(Gladdy:SMFetch("font", "targetHealthBarFont"), Gladdy.db.targetHealthTextRightFontSize, Gladdy.db.targetHealthTextRightOutline and "OUTLINE")
        healthBar.healthText:Show()
    end

    healthBar.nameText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.healthText:SetTextColor(Gladdy:SetColor(Gladdy.db.targetHealthBarFontColor))
    healthBar.nameText:SetPoint("LEFT", Gladdy.db.targetHealthTextLeftHOffset, Gladdy.db.targetHealthTextLeftVOffset)
    healthBar.healthText:SetPoint("RIGHT", Gladdy.db.targetHealthTextRightHOffset, Gladdy.db.targetHealthTextRightVOffset)

    if Gladdy.db.targetBarEnabled then
        healthBar:Show()
    else
        healthBar:Hide()
    end

    if Gladdy.db.targetPortraitClass then
        button.portrait:SetTexCoord(0,1,0,1)
    else
        button.portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
    if Gladdy.frame.testing then
        self:Test(unitId)
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
                bar = {
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
                        targetBarVertical = option({
                            type = "toggle",
                            order = 3,
                            name = L["Vertical Bar"],
                        }),
                        targetHeight = option({
                            type = "range",
                            name = L["Bar height"],
                            desc = L["Height of the bar"],
                            order = 4,
                            min = 10,
                            max = 600,
                            step = 0.05,
                            width = "full",
                        }),
                        targetWidth = option({
                            type = "range",
                            name = L["Bar width"],
                            desc = L["Width of the bar"],
                            order = 5,
                            min = 10,
                            max = 600,
                            step = 0.05,
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
                        targetPortraitSize = Gladdy:option({
                            type = "range",
                            name = L["Size"],
                            min = 3,
                            max = 100,
                            step = .1,
                            order = 4,
                            width = "full",
                        }),
                        targetPortraitWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            order = 5,
                            width = "full",
                        }),
                        headerPosition = {
                            type = "header",
                            name = L["Position"],
                            order = 10,
                        },
                        targetPortraitPosition = Gladdy:option({
                            type = "select",
                            name = L["Anchor"],
                            order = 11,
                            values = Gladdy.positions,
                            width = "full",
                        }),
                        targetPortraitMargin = Gladdy:option({
                            type = "range",
                            name = L["Margin"],
                            order = 12,
                            min = -100,
                            max = 100,
                            step = 0.05,
                            order = 12,
                            width = "full",
                        }),
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 20,
                        },
                        targetPortraitBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 21,
                            values = Gladdy:GetIconStyles()
                        }),
                        targetPortraitBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 22,
                            hasAlpha = true,
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
                        targetHealthTextLeftOutline = option({
                            type = "toggle",
                            name = L["Left Font Outline"],
                            order = 13,
                            width = "full",
                        }),
                        targetHealthTextRightOutline = option({
                            type = "toggle",
                            name = L["Right Font Outline"],
                            order = 14,
                            width = "full",
                        }),
                        headerSize = {
                            type = "header",
                            name = L["Size"],
                            order = 20,
                        },
                        targetHealthTextLeftFontSize = option({
                            type = "range",
                            name = L["Font size left text"],
                            desc = L["Size of the left text"],
                            order = 21,
                            min = 0,
                            max = 50,
                            step = 0.05,
                            width = "full",
                        }),
                        targetHealthTextRightFontSize = option({
                            type = "range",
                            name = L["Font size right text"],
                            desc = L["Size of the right text"],
                            order = 22,
                            min = 0,
                            max = 50,
                            step = 0.05,
                            width = "full",
                        }),
                        headerOffsets = {
                            type = "header",
                            name = L["Offsets"],
                            order = 30,
                        },
                        targetHealthTextLeftVOffset = option({
                            type = "range",
                            name = L["Left Text Vertical Offset"],
                            order = 31,
                            step = 0.1,
                            min = -200,
                            max = 200,
                            width = "full",
                        }),
                        targetHealthTextLeftHOffset = option({
                            type = "range",
                            name = L["Left Text Horizontal Offset"],
                            order = 32,
                            step = 0.1,
                            min = -200,
                            max = 200,
                            width = "full",
                        }),
                        targetHealthTextRightVOffset = option({
                            type = "range",
                            name = L["Right Text Vertical Offset"],
                            order = 33,
                            step = 0.1,
                            min = -200,
                            max = 200,
                            width = "full",
                        }),
                        targetHealthTextRightHOffset = option({
                            type = "range",
                            name = L["Right Text Horizontal Offset"],
                            order = 34,
                            step = 0.1,
                            min = -200,
                            max = 200,
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