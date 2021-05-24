local select = select
local pairs,ipairs,tbl_sort,tinsert,format = pairs,ipairs,table.sort,tinsert,format

local drDuration = 18

local GetSpellInfo = GetSpellInfo
local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local DRData = LibStub("DRData-1.0")
local L = Gladdy.L
local function defaultCategories()
    local categories = {}
    local indexList = {}
    for k,v in pairs(DRData:GetSpells()) do
        tinsert(indexList, {spellID = k, category = v})
    end
    tbl_sort(indexList, function(a, b) return a.spellID < b.spellID end)
    for i,v in ipairs(indexList) do
        if not categories[v.category] then
            categories[v.category] = {
                enabled = true,
                forceIcon = false,
                icon = select(3, GetSpellInfo(v.spellID))
            }
        end
    end
    return categories
end
local Diminishings = Gladdy:NewModule("Diminishings", nil, {
    drFont = "DorisPP",
    drFontColor = { r = 1, g = 1, b = 0, a = 1 },
    drFontScale = 1,
    drCooldownPos = "RIGHT",
    drXOffset = 0,
    drYOffset = 0,
    drIconSize = 36,
    drEnabled = true,
    drBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    drBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    drDisableCircle = false,
    drCooldownAlpha = 1,
    drBorderColorsEnabled = true,
    drIconPadding = 1,
    drHalfColor = {r = 1, g = 1, b = 0, a = 1 },
    drQuarterColor = {r = 1, g = 0.7, b = 0, a = 1 },
    drNullColor = {r = 1, g = 0, b = 0, a = 1 },
    drWidthFactor = 1,
    drCategories = defaultCategories()
})

local function getDiminishColor(dr)
    if dr == 0.5 then
        return Gladdy.db.drHalfColor.r, Gladdy.db.drHalfColor.g, Gladdy.db.drHalfColor.b, Gladdy.db.drHalfColor.a
    elseif dr == 0.25 then
        return Gladdy.db.drQuarterColor.r, Gladdy.db.drQuarterColor.g, Gladdy.db.drQuarterColor.b, Gladdy.db.drQuarterColor.a
    else
        return Gladdy.db.drNullColor.r, Gladdy.db.drNullColor.g, Gladdy.db.drNullColor.b, Gladdy.db.drNullColor.a
    end
end

function Diminishings:Initialize()
    self.frames = {}
    self:RegisterMessage("UNIT_DEATH", "ResetUnit", "AURA_FADE", "UNIT_DESTROYED")
end

function Diminishings:CreateFrame(unit)
    local drFrame = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    drFrame:EnableMouse(false)

    for i = 1, 16 do
        local icon = CreateFrame("Frame", "GladdyDr" .. unit .. "Icon" .. i, drFrame)
        icon:Hide()
        icon:EnableMouse(false)
        icon:SetFrameLevel(3)
        icon.texture = icon:CreateTexture(nil, "BACKGROUND")
        icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
        icon.texture:SetAllPoints(icon)
        icon:SetScript("OnUpdate", function(self, elapsed)
            if (self.active) then
                if (self.timeLeft <= 0) then
                    if (self.factor == drFrame.tracked[self.dr]) then
                        drFrame.tracked[self.dr] = 0
                    end

                    self.active = false
                    self.dr = nil
                    self.diminishing = 1.0
                    self.texture:SetTexture("")
                    self.text:SetText("")
                    self:Hide()
                    Diminishings:Positionate(unit)
                else
                    self.timeLeft = self.timeLeft - elapsed
                    if self.timeLeft >=5 then
                        self.timeText:SetFormattedText("%d", self.timeLeft)
                    else
                        self.timeText:SetFormattedText("%.1f", self.timeLeft >= 0.0 and self.timeLeft or 0.0)
                    end
                end
            end
        end)

        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC
        icon.cooldown:SetHideCountdownNumbers(true)
        icon.cooldown:SetFrameLevel(4)

        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetPoint("TOPLEFT", icon, "TOPLEFT")
        icon.cooldownFrame:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")
        icon.cooldownFrame:SetFrameLevel(5)

        --icon.overlay = CreateFrame("Frame", nil, icon)
        --icon.overlay:SetAllPoints(icon)
        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY")
        icon.border:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")
        icon.border:SetAllPoints(icon)

        icon.text = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.text:SetDrawLayer("OVERLAY")
        icon.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), 10, "OUTLINE")
        icon.text:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.text:SetShadowOffset(1, -1)
        icon.text:SetShadowColor(0, 0, 0, 1)
        icon.text:SetJustifyH("CENTER")
        icon.text:SetPoint("CENTER")

        icon.timeText = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.timeText:SetDrawLayer("OVERLAY")
        icon.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), 10, "OUTLINE")
        icon.timeText:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.timeText:SetShadowOffset(1, -1)
        icon.timeText:SetShadowColor(0, 0, 0, 1)
        icon.timeText:SetJustifyH("CENTER")
        icon.timeText:SetPoint("CENTER", icon, "CENTER", 0, 1)

        icon.diminishing = 1

        drFrame["icon" .. i] = icon
    end

    drFrame.tracked = {}
    Gladdy.buttons[unit].drFrame = drFrame
    self.frames[unit] = drFrame
    self:ResetUnit(unit)
end

function Diminishings:UpdateFrame(unit)
    local drFrame = self.frames[unit]
    if (not drFrame) then
        return
    end

    if (Gladdy.db.drEnabled == false) then
        drFrame:Hide()
        return
    else
        drFrame:Show()
    end

    drFrame:ClearAllPoints()
    local horizontalMargin = (Gladdy.db.highlightInset and 0 or Gladdy.db.highlightBorderSize) + Gladdy.db.padding
    if (Gladdy.db.drCooldownPos == "LEFT") then
        local anchor = Gladdy:GetAnchor(unit, "LEFT")
        if anchor == Gladdy.buttons[unit].healthBar then
            drFrame:SetPoint("RIGHT", anchor, "LEFT", -horizontalMargin + Gladdy.db.drXOffset, Gladdy.db.drYOffset)
        else
            drFrame:SetPoint("RIGHT", anchor, "LEFT", -Gladdy.db.padding + Gladdy.db.drXOffset, Gladdy.db.drYOffset)
        end
    end
    if (Gladdy.db.drCooldownPos == "RIGHT") then
        local anchor = Gladdy:GetAnchor(unit, "RIGHT")
        if anchor == Gladdy.buttons[unit].healthBar then
            drFrame:SetPoint("LEFT", anchor, "RIGHT", horizontalMargin + Gladdy.db.drXOffset, Gladdy.db.drYOffset)
        else
            drFrame:SetPoint("LEFT", anchor, "RIGHT", Gladdy.db.padding + Gladdy.db.drXOffset, Gladdy.db.drYOffset)
        end
    end

    drFrame:SetWidth(Gladdy.db.drIconSize * 16)
    drFrame:SetHeight(Gladdy.db.drIconSize)

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]

        icon:SetWidth(Gladdy.db.drIconSize * Gladdy.db.drWidthFactor)
        icon:SetHeight(Gladdy.db.drIconSize)

        icon.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), (Gladdy.db.drIconSize/2 - 1) * Gladdy.db.drFontScale, "OUTLINE")
        icon.text:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)
        icon.timeText:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.drFont), (Gladdy.db.drIconSize/2 - 1) * Gladdy.db.drFontScale, "OUTLINE")
        icon.timeText:SetTextColor(Gladdy.db.drFontColor.r, Gladdy.db.drFontColor.g, Gladdy.db.drFontColor.b, Gladdy.db.drFontColor.a)

        icon.cooldown:SetWidth(icon:GetWidth() - icon:GetWidth()/16)
        icon.cooldown:SetHeight(icon:GetHeight() - icon:GetHeight()/16)
        icon.cooldown:ClearAllPoints()
        icon.cooldown:SetPoint("CENTER", icon, "CENTER")
        if Gladdy.db.drDisableCircle then
            icon.cooldown:SetAlpha(0)
        else
            icon.cooldown:SetAlpha(Gladdy.db.drCooldownAlpha)
        end

        if Gladdy.db.drBorderColorsEnabled then
            icon.border:SetVertexColor(getDiminishColor(icon.diminishing))
        else
            icon.border:SetVertexColor(Gladdy.db.drBorderColor.r, Gladdy.db.drBorderColor.g, Gladdy.db.drBorderColor.b, Gladdy.db.drBorderColor.a)
        end

        icon:ClearAllPoints()
        if (Gladdy.db.drCooldownPos == "LEFT") then
            if (i == 1) then
                icon:SetPoint("TOPRIGHT")
            else
                icon:SetPoint("RIGHT", drFrame["icon" .. (i - 1)], "LEFT", -Gladdy.db.drIconPadding, 0)
            end
        else
            if (i == 1) then
                icon:SetPoint("TOPLEFT")
            else
                icon:SetPoint("LEFT", drFrame["icon" .. (i - 1)], "RIGHT", Gladdy.db.drIconPadding, 0)
            end
        end

        if Gladdy.db.drBorderStyle == "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss" then
            icon.border:SetTexture("Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp")
        else
            icon.border:SetTexture(Gladdy.db.drBorderStyle)
        end

        --icon.texture:SetTexCoord(.1, .9, .1, .9)
        --icon.texture:SetPoint("TOPLEFT", icon, "TOPLEFT", 2, -2)
        --icon.texture:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -2, 2)
    end
end

function Diminishings:ResetUnit(unit)
    local drFrame = self.frames[unit]
    if (not drFrame) then
        return
    end

    drFrame.tracked = {}

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]
        icon.active = false
        icon.timeLeft = 0
        icon.texture:SetTexture("")
        icon.text:SetText("")
        icon.timeText:SetText("")
        icon:Hide()
    end
end

function Diminishings:UNIT_DESTROYED(unit)
    Diminishings:ResetUnit(unit)
end

function Diminishings:Test(unit)
    if Gladdy.db.drEnabled then
        local spells = { 33786, 118, 8643, 8983 }
        for i = 1, 4 do
            if i == 1 then
                self:AuraFade(unit, spells[i])
            elseif i == 2 then
                self:AuraFade(unit, spells[i])
                self:AuraFade(unit, spells[i])
            else
                self:AuraFade(unit, spells[i])
                self:AuraFade(unit, spells[i])
                self:AuraFade(unit, spells[i])
            end
        end
    end
end

function Diminishings:AuraFade(unit, spellID)
    local drFrame = self.frames[unit]
    local drCat = DRData:GetSpellCategory(spellID)
    if (not drFrame or not drCat) then
        return
    end
    if not Gladdy.db.drCategories[drCat].enabled then
        return
    end

    local lastIcon
    for i = 1, 16 do
        local icon = drFrame["icon" .. i]
        if (icon.active and icon.dr and icon.dr == drCat) then
            lastIcon = icon
            break
        elseif not icon.active and not lastIcon then
            lastIcon = icon
            lastIcon.diminishing = 1.0
        end
    end
    lastIcon.dr = drCat
    lastIcon.timeLeft = drDuration
    lastIcon.diminishing = DRData:NextDR(lastIcon.diminishing)
    if Gladdy.db.drBorderColorsEnabled then
        lastIcon.border:SetVertexColor(getDiminishColor(lastIcon.diminishing))
    else
        lastIcon.border:SetVertexColor(Gladdy.db.drBorderColor.r, Gladdy.db.drBorderColor.g, Gladdy.db.drBorderColor.b, Gladdy.db.drBorderColor.a)
    end
    lastIcon.cooldown:SetCooldown(GetTime(), drDuration)
    if Gladdy.db.drCategories[drCat].forceIcon then
        lastIcon.texture:SetTexture(Gladdy.db.drCategories[drCat].icon)
    else
        lastIcon.texture:SetTexture(select(3, GetSpellInfo(spellID)))
    end
    lastIcon.active = true
    self:Positionate(unit)
    lastIcon:Show()
end

function Diminishings:Positionate(unit)
    local drFrame = self.frames[unit]
    if (not drFrame) then
        return
    end

    local lastIcon

    for i = 1, 16 do
        local icon = drFrame["icon" .. i]

        if (icon.active) then
            icon:ClearAllPoints()
            if (Gladdy.db.drCooldownPos == "LEFT") then
                if (not lastIcon) then
                    icon:SetPoint("TOPRIGHT")
                else
                    icon:SetPoint("RIGHT", lastIcon, "LEFT", -Gladdy.db.drIconPadding, 0)
                end
            else
                if (not lastIcon) then
                    icon:SetPoint("TOPLEFT")
                else
                    icon:SetPoint("LEFT", lastIcon, "RIGHT", Gladdy.db.drIconPadding, 0)
                end
            end

            lastIcon = icon
        end
    end
end

function Diminishings:GetOptions()
    return {
        headerDiminishings = {
            type = "header",
            name = L["Diminishings"],
            order = 2,
        },
        drEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enabled DR module"],
            order = 3,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            args = {
                icon = {
                    type = "group",
                    name = L["Icon"],
                    order = 1,
                    args = {
                        headerDiminishingsFrame = {
                            type = "header",
                            name = L["Icon"],
                            order = 4,
                        },
                        drIconSize = Gladdy:option({
                            type = "range",
                            name = L["Icon Size"],
                            desc = L["Size of the DR Icons"],
                            order = 5,
                            min = 5,
                            max = 50,
                            step = 1,
                        }),
                        drWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon Width Factor"],
                            desc = L["Stretches the icon"],
                            order = 6,
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                        }),
                        drIconPadding = Gladdy:option({
                            type = "range",
                            name = L["Icon Padding"],
                            desc = L["Space between Icons"],
                            order = 7,
                            min = 0,
                            max = 10,
                            step = 0.1,
                        }),
                    },
                },
                cooldown = {
                    type = "group",
                    name = L["Cooldown"],
                    order = 2,
                    args = {
                        headerDiminishingsFrame = {
                            type = "header",
                            name = L["Cooldown"],
                            order = 4,
                        },
                        drDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 8,
                            width = "full",
                        }),
                        drCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 9,
                        }),
                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 3,
                    args = {
                        headerFont = {
                            type = "header",
                            name = L["Font"],
                            order = 10,
                        },
                        drFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        drFontColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Font color"],
                            desc = L["Color of the text"],
                            order = 13,
                            hasAlpha = true,
                        }),
                        drFontScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the text"],
                            order = 12,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
                        }),
                    }
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 4,
                    args = {
                        headerPosition = {
                            type = "header",
                            name = L["Position"],
                            order = 20,
                        },
                        drCooldownPos = Gladdy:option({
                            type = "select",
                            name = L["DR Cooldown position"],
                            desc = L["Position of the cooldown icons"],
                            order = 21,
                            values = {
                                ["LEFT"] = L["Left"],
                                ["RIGHT"] = L["Right"],
                            },
                        }),
                        headerOffset = {
                            type = "header",
                            name = L["Offset"],
                            order = 22,
                        },
                        drXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 23,
                            min = -400,
                            max = 400,
                            step = 0.1,
                        }),
                        drYOffset = Gladdy:option({
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
                    order = 5,
                    args = {
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 30,
                        },
                        drBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 31,
                            values = Gladdy:GetIconStyles()
                        }),
                        drBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 32,
                            hasAlpha = true,
                        }),
                        headerBorderColors = {
                            type = "header",
                            name = L["DR Border Colors"],
                            order = 40,
                        },
                        drBorderColorsEnabled = Gladdy:option({
                            type = "toggle",
                            name = L["Dr Border Colors Enabled"],
                            desc = L["Colors borders of DRs in respective DR-color below"],
                            order = 41,
                            width = "full",
                        }),
                        drHalfColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Half"],
                            desc = L["Color of the border"],
                            order = 42,
                            hasAlpha = true,
                        }),
                        drQuarterColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Quarter"],
                            desc = L["Color of the border"],
                            order = 43,
                            hasAlpha = true,
                        }),
                        drNullColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Immune"],
                            desc = L["Color of the border"],
                            order = 44,
                            hasAlpha = true,
                        }),
                    }
                },
            },
        },
        categories = {
            type = "group",
            name = L["Categories"],
            order = 6,
            args = Diminishings:CategoryOptions(),
        },
    }
end

function Diminishings:CategoryOptions()
    local categories = {}
    local indexList = {}
    for k,v in pairs(DRData:GetCategories()) do
        tinsert(indexList, k)
    end
    tbl_sort(indexList)
    for i, k in ipairs(indexList) do
        categories[k] = {
            type = "group",
            name = DRData:GetCategoryName(k),
            order = i,
            icon = Gladdy.db.drCategories[k].icon,
            args = {
                enabled = {
                    type = "toggle",
                    name = L["Enabled"],
                    order = 1,
                    get = function(info)
                        return Gladdy.db.drCategories[k].enabled
                    end,
                    set = function(info, value)
                        Gladdy.db.drCategories[k].enabled = value
                    end,
                },
                forceIcon = {
                    type = "toggle",
                    name = L["Force Icon"],
                    order = 2,
                    get = function(info)
                        return Gladdy.db.drCategories[k].forceIcon
                    end,
                    set = function(info, value)
                        Gladdy.db.drCategories[k].forceIcon = value
                    end,
                },
                icon = {
                    type = "select",
                    name = L["Icon"],
                    desc = L["Icon of the DR"],
                    order = 4,
                    values = Diminishings:GetDRIcons(k),
                    get = function(info)
                        return Gladdy.db.drCategories[k].icon
                    end,
                    set = function(info, value)
                        Gladdy.db.drCategories[k].icon = value
                        Gladdy.options.args.Diminishings.args.categories.args[k].icon = value
                    end,
                }
            }
        }
    end
    return categories
end

function Diminishings:GetDRIcons(category)
    local icons = {}
    for k,v in pairs(DRData:GetSpells()) do
        if v == category then
            icons[select(3, GetSpellInfo(k))] = format("|T%s:20|t %s", select(3, GetSpellInfo(k)), select(1, GetSpellInfo(k)))
        end
    end
    return icons
end
