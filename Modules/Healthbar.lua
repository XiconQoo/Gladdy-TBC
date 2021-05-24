local pairs = pairs
local floor = math.floor
local UnitHealth, UnitHealthMax, UnitName, UnitExists = UnitHealth, UnitHealthMax, UnitName, UnitExists

local CreateFrame = CreateFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AceGUIWidgetLSMlists = AceGUIWidgetLSMlists
local Healthbar = Gladdy:NewModule("Health Bar", 100, {
    healthBarFont = "DorisPP",
    healthBarHeight = 60,
    healthBarTexture = "Smooth",
    healthBarBorderStyle = "Gladdy Tooltip round",
    healthBarBorderSize = 9,
    healthBarBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    healthBarBgColor = { r = 0, g = 0, b = 0, a = 0.4 },
    healthBarFontColor = { r = 1, g = 1, b = 1, a = 1 },
    healthBarNameFontSize = 12,
    healthBarHealthFontSize = 12,
    healthNameToArenaId = false,
    healthName = true,
    healthActual = false,
    healthMax = true,
    healthPercentage = true,
})

function Healthbar:Initialize()
    self.frames = {}
    self:RegisterMessage("JOINED_ARENA")
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_DESTROYED")
    self:RegisterMessage("UNIT_DEATH")
end

function Healthbar:CreateFrame(unit)
    local button = Gladdy.buttons[unit]

    local healthBar = CreateFrame("Frame", nil, Gladdy.buttons[unit], BackdropTemplateMixin and "BackdropTemplate")
    healthBar:EnableMouse(false)
    healthBar:SetBackdrop({ edgeFile = Gladdy.LSM:Fetch("border", Gladdy.db.healthBarBorderStyle),
                                   edgeSize = Gladdy.db.healthBarBorderSize })
    healthBar:SetBackdropBorderColor(Gladdy.db.healthBarBorderColor.r, Gladdy.db.healthBarBorderColor.g, Gladdy.db.healthBarBorderColor.b, Gladdy.db.healthBarBorderColor.a)
    healthBar:SetFrameLevel(1)

    healthBar.hp = CreateFrame("StatusBar", nil, healthBar)
    healthBar.hp:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar.hp:SetMinMaxValues(0, 100)
    healthBar.hp:SetFrameLevel(0)

    healthBar.bg = healthBar.hp:CreateTexture(nil, "BACKGROUND")
    healthBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar.bg:ClearAllPoints()
    healthBar.bg:SetAllPoints(healthBar.hp)
    healthBar.bg:SetAlpha(1)
    healthBar.bg:SetVertexColor(Gladdy.db.healthBarBgColor.r, Gladdy.db.healthBarBgColor.g, Gladdy.db.healthBarBgColor.b, Gladdy.db.healthBarBgColor.a)

    healthBar.nameText = healthBar:CreateFontString(nil, "LOW", "GameFontNormalSmall")
    if (Gladdy.db.healthBarNameFontSize < 1) then
        healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarNameFont), 1)
        healthBar.nameText:Hide()
    else
        healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarFont), Gladdy.db.healthBarNameFontSize)
        healthBar.nameText:Show()
    end
    healthBar.nameText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
    healthBar.nameText:SetShadowOffset(1, -1)
    healthBar.nameText:SetShadowColor(0, 0, 0, 1)
    healthBar.nameText:SetJustifyH("CENTER")
    healthBar.nameText:SetPoint("LEFT", 5, 0)

    healthBar.healthText = healthBar:CreateFontString(nil, "LOW")
    if (Gladdy.db.healthBarHealthFontSize < 1) then
        healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarFont), 1)
        healthBar.healthText:Hide()
    else
        healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarFont), Gladdy.db.healthBarHealthFontSize)
        healthBar.healthText:Hide()
    end
    healthBar.healthText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
    healthBar.healthText:SetShadowOffset(1, -1)
    healthBar.healthText:SetShadowColor(0, 0, 0, 1)
    healthBar.healthText:SetJustifyH("CENTER")
    healthBar.healthText:SetPoint("RIGHT", -5, 0)

    healthBar.unit = unit
    self.frames[unit] = healthBar
    button.healthBar = healthBar
    self:ResetUnit(unit)
    healthBar:RegisterUnitEvent("UNIT_HEALTH", unit)
    healthBar:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
    healthBar:RegisterUnitEvent("UNIT_NAME_UPDATE", unit)
    healthBar:SetScript("OnEvent", Healthbar.OnEvent)
end

function Healthbar.OnEvent(self, event, unit)
    if event == "UNIT_HEALTH" then
        local health = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        self.hp:SetMinMaxValues(0, healthMax)
        self.hp:SetValue(UnitHealth(unit))
        Healthbar:SetHealthText(self, health, healthMax)
    elseif event == "UNIT_MAXHEALTH" then
        local health = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        self.hp:SetMinMaxValues(0, healthMax)
        self.hp:SetValue(health)
        Healthbar:SetHealthText(self, health, healthMax)
    elseif event == "UNIT_NAME_UPDATE" then
        local name = UnitName(unit)
        Gladdy.buttons[unit].name = name
        if Gladdy.db.healthName and not Gladdy.db.healthNameToArenaId then
            self.nameText:SetText(name)
        end
    end
    if not Gladdy.buttons[unit].class then
        Gladdy:SpotEnemy(unit, true)
    end
end

function Healthbar:SetHealthText(healthBar, health, healthMax)
    local healthText
    local healthPercentage = floor(health * 100 / healthMax)

    if health == 0 then
        self:UNIT_DEATH(healthBar.unit)
        return
    end

    if (Gladdy.db.healthActual) then
        healthText = healthMax > 999 and ("%.1fk"):format(health / 1000) or health
    end

    if (Gladdy.db.healthMax) then
        local text = healthMax > 999 and ("%.1fk"):format(healthMax / 1000) or healthMax
        if (healthText) then
            healthText = ("%s/%s"):format(healthText, text)
        else
            healthText = text
        end
    end

    if (Gladdy.db.healthPercentage) then
        if (healthText) then
            healthText = ("%s (%d%%)"):format(healthText, healthPercentage)
        else
            healthText = ("%d%%"):format(healthPercentage)
        end
    end

    healthBar.healthText:SetText(healthText)
end

function Healthbar:UpdateFrame(unit)
    local healthBar = self.frames[unit]
    if (not healthBar) then
        return
    end

    local iconSize = Gladdy.db.healthBarHeight + Gladdy.db.powerBarHeight

    healthBar.bg:SetTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar.bg:SetVertexColor(Gladdy.db.healthBarBgColor.r, Gladdy.db.healthBarBgColor.g, Gladdy.db.healthBarBgColor.b, Gladdy.db.healthBarBgColor.a)

    healthBar:SetBackdrop({ edgeFile = Gladdy.LSM:Fetch("border", Gladdy.db.healthBarBorderStyle),
                            edgeSize = Gladdy.db.healthBarBorderSize })
    healthBar:SetBackdropBorderColor(Gladdy.db.healthBarBorderColor.r, Gladdy.db.healthBarBorderColor.g, Gladdy.db.healthBarBorderColor.b, Gladdy.db.healthBarBorderColor.a)
    healthBar:ClearAllPoints()
    healthBar:SetPoint("TOPLEFT", Gladdy.buttons[unit], "TOPLEFT", 0, 0)
    healthBar:SetPoint("BOTTOMRIGHT", Gladdy.buttons[unit], "BOTTOMRIGHT")

    healthBar.hp:SetStatusBarTexture(Gladdy.LSM:Fetch("statusbar", Gladdy.db.healthBarTexture))
    healthBar.hp:ClearAllPoints()
    healthBar.hp:SetPoint("TOPLEFT", healthBar, "TOPLEFT", (Gladdy.db.healthBarBorderSize/Gladdy.db.statusbarBorderOffset), -(Gladdy.db.healthBarBorderSize/Gladdy.db.statusbarBorderOffset))
    healthBar.hp:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", -(Gladdy.db.healthBarBorderSize/Gladdy.db.statusbarBorderOffset), (Gladdy.db.healthBarBorderSize/Gladdy.db.statusbarBorderOffset))

    if (Gladdy.db.healthBarHealthFontSize < 1) then
        healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarFont), 1)
        healthBar.healthText:Hide()
    else
        healthBar.healthText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarFont), Gladdy.db.healthBarHealthFontSize)
        healthBar.healthText:Show()
    end
    if (Gladdy.db.healthBarNameFontSize < 1) then
        healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarNameFont), 1)
        healthBar.nameText:Hide()
    else
        healthBar.nameText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.healthBarFont), Gladdy.db.healthBarNameFontSize)
        if Gladdy.db.healthName then
            healthBar.nameText:Show()
        else
            healthBar.nameText:Hide()
        end
    end
    healthBar.nameText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
    healthBar.healthText:SetTextColor(Gladdy.db.healthBarFontColor.r, Gladdy.db.healthBarFontColor.g, Gladdy.db.healthBarFontColor.b, Gladdy.db.healthBarFontColor.a)
end

function Healthbar:ResetUnit(unit)
    local healthBar = self.frames[unit]
    if (not healthBar) then
        return
    end

    healthBar.hp:SetStatusBarColor(1, 1, 1, 1)
    healthBar.nameText:SetText("")
    healthBar.healthText:SetText("")
    healthBar.hp:SetValue(0)
end

function Healthbar:Test(unit)
    local healthBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not healthBar or not button) then
        return
    end

    self:JOINED_ARENA()
    self:ENEMY_SPOTTED(unit)
    self:UNIT_HEALTH(unit, button.health, button.healthMax)
end

function Healthbar:JOINED_ARENA()
    if Gladdy.db.healthNameToArenaId and Gladdy.db.healthName then
        for i=1,Gladdy.curBracket do
            local healthBar = self.frames["arena" .. i]
            healthBar.nameText:SetText("Arena" .. i)
        end
    end
end

function Healthbar:ENEMY_SPOTTED(unit)
    local healthBar = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not healthBar or not button) then
        return
    end

    if UnitExists(unit) then
        local health = UnitHealth(unit)
        local healthMax = UnitHealthMax(unit)
        healthBar.hp:SetMinMaxValues(0, healthMax)
        healthBar.hp:SetValue(health)
        Healthbar:SetHealthText(healthBar, health, healthMax)
    end
    if Gladdy.db.healthName and not Gladdy.db.healthNameToArenaId then
        healthBar.nameText:SetText(button.name)
    end

    healthBar.hp:SetStatusBarColor(RAID_CLASS_COLORS[button.class].r, RAID_CLASS_COLORS[button.class].g, RAID_CLASS_COLORS[button.class].b, 1)
end

function Healthbar:UNIT_HEALTH(unit, health, healthMax)
    local healthBar = self.frames[unit]
    if (not healthBar) then
        return
    end
    if not Gladdy.buttons[unit].class then
        Gladdy:SpotEnemy(unit, true)
    end
    Gladdy:SendMessage("UNIT_HEALTH", unit, health, healthMax)

    local healthPercentage = floor(health * 100 / healthMax)
    local healthText

    if (Gladdy.db.healthActual) then
        healthText = healthMax > 999 and ("%.1fk"):format(health / 1000) or health
    end

    if (Gladdy.db.healthMax) then
        local text = healthMax > 999 and ("%.1fk"):format(healthMax / 1000) or healthMax
        if (healthText) then
            healthText = ("%s/%s"):format(healthText, text)
        else
            healthText = text
        end
    end

    if (Gladdy.db.healthPercentage) then
        if (healthText) then
            healthText = ("%s (%d%%)"):format(healthText, healthPercentage)
        else
            healthText = ("%d%%"):format(healthPercentage)
        end
    end

    healthBar.healthText:SetText(healthText)
    healthBar.hp:SetValue(healthPercentage)
end

function Healthbar:UNIT_DEATH(unit)
    local healthBar = self.frames[unit]
    if (not healthBar) then
        return
    end

    healthBar.hp:SetValue(0)
    healthBar.healthText:SetText(L["DEAD"])
end

function Healthbar:UNIT_DESTROYED(unit)
    local healthBar = self.frames[unit]
    if (not healthBar) then
        return
    end

    healthBar.hp:SetValue(0)
    healthBar.healthText:SetText(L["LEAVE"])
    healthBar.nameText:SetText("")
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
            Gladdy.options.args["Health Bar"].args.group.args.border.args.healthBarBorderSize.max = Gladdy.db.healthBarHeight/2
            if Gladdy.db.healthBarBorderSize > Gladdy.db.healthBarHeight/2 then
                Gladdy.db.healthBarBorderSize = Gladdy.db.healthBarHeight/2
            end
            for i=1,Gladdy.curBracket do
                Healthbar:Test("arena" .. i)
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Healthbar:GetOptions()
    return {
        headerHealthbar = {
            type = "header",
            name = L["Health Bar"],
            order = 2,
        },
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 3,
            args = {
                general = {
                    type = "group",
                    name = L["General"],
                    order = 1,
                    args = {
                        headerAuras = {
                            type = "header",
                            name = L["General"],
                            order = 1,
                        },
                        healthBarHeight = option({
                            type = "range",
                            name = L["Bar height"],
                            desc = L["Height of the bar"],
                            order = 3,
                            min = 10,
                            max = 100,
                            step = 1,
                        }),
                        healthBarTexture = option({
                            type = "select",
                            name = L["Bar texture"],
                            desc = L["Texture of the bar"],
                            order = 4,
                            dialogControl = "LSM30_Statusbar",
                            values = AceGUIWidgetLSMlists.statusbar,
                        }),
                        healthBarBgColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Background color"],
                            desc = L["Color of the status bar background"],
                            order = 5,
                            hasAlpha = true,
                        }),
                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 2,
                    args = {
                        header = {
                            type = "header",
                            name = L["Font"],
                            order = 1,
                        },
                        healthBarFont = option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the bar"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        healthBarFontColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Font color"],
                            desc = L["Color of the text"],
                            order = 12,
                            hasAlpha = true,
                        }),
                        healthBarNameFontSize = option({
                            type = "range",
                            name = L["Name font size"],
                            desc = L["Size of the name text"],
                            order = 13,
                            step = 0.1,
                            min = 0,
                            max = 20,
                        }),
                        healthBarHealthFontSize = option({
                            type = "range",
                            name = L["Health font size"],
                            desc = L["Size of the health text"],
                            order = 14,
                            step = 0.1,
                            min = 0,
                            max = 20,
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 3,
                    args = {
                        header = {
                            type = "header",
                            name = L["Border"],
                            order = 1,
                        },
                        healthBarBorderStyle = option({
                            type = "select",
                            name = L["Border style"],
                            order = 21,
                            dialogControl = "LSM30_Border",
                            values = AceGUIWidgetLSMlists.border,
                        }),
                        healthBarBorderSize = option({
                            type = "range",
                            name = L["Border size"],
                            desc = L["Size of the border"],
                            order = 22,
                            min = 0.5,
                            max = Gladdy.db.healthBarHeight/2,
                            step = 0.5,
                        }),
                        healthBarBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 23,
                            hasAlpha = true,
                        }),
                    },
                },
                healthValues = {
                    type = "group",
                    name = L["Health Bar Text"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Health Bar Text"],
                            order = 1,
                        },
                        healthName = option({
                            type = "toggle",
                            name = L["Show name text"],
                            desc = L["Show the units name"],
                            order = 2,
                            width = "full",
                        }),
                        healthNameToArenaId = option({
                            type = "toggle",
                            name = L["Show ArenaX"],
                            desc = L["Show Arena1-5 as name instead"],
                            order = 3,
                            width = "full",
                            disabled = function() return not Gladdy.db.healthName end
                        }),
                        healthActual = option({
                            type = "toggle",
                            name = L["Show the actual health"],
                            desc = L["Show the actual health on the health bar"],
                            order = 4,
                            width = "full",
                        }),
                        healthMax = option({
                            type = "toggle",
                            name = L["Show max health"],
                            desc = L["Show max health on the health bar"],
                            order = 5,
                            width = "full",
                        }),
                        healthPercentage = option({
                            type = "toggle",
                            name = L["Show health percentage"],
                            desc = L["Show health percentage on the health bar"],
                            order = 6,
                            width = "full",
                        }),
                    },
                },
            },
        },
    }
end