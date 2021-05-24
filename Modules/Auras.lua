local pairs, ipairs, select, tinsert, tbl_sort, tostring = pairs, ipairs, select, tinsert, table.sort, tostring

local GetSpellInfo = GetSpellInfo
local CreateFrame, GetTime = CreateFrame, GetTime
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local function defaultSpells(auraType)
    local spells = {}
    for k,v in pairs(Gladdy:GetImportantAuras()) do
        if not auraType or auraType == v.track then
            spells[tostring(v.spellID)] = {}
            spells[tostring(v.spellID)].enabled = true
            spells[tostring(v.spellID)].priority = v.priority
            spells[tostring(v.spellID)].track = v.track
        end
    end
    return spells
end
local Auras = Gladdy:NewModule("Auras", nil, {
    auraFont = "DorisPP",
    auraFontSizeScale = 1,
    auraFontColor = { r = 1, g = 1, b = 0, a = 1 },
    auraBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    auraBuffBorderColor = { r = 1, g = 0, b = 0, a = 1 },
    auraDebuffBorderColor = { r = 0, g = 1, b = 0, a = 1 },
    auraDisableCircle = false,
    auraCooldownAlpha = 1,
    auraListDefault = defaultSpells()
})

function Auras:Initialize()
    self.frames = {}

    self.auras = Gladdy:GetImportantAuras()

    self:RegisterMessage("JOINED_ARENA")
    self:RegisterMessage("UNIT_DEATH")
    self:RegisterMessage("AURA_GAIN")
    self:RegisterMessage("AURA_FADE")
end

function Auras:CreateFrame(unit)
    local auraFrame = CreateFrame("Frame", nil, Gladdy.modules["Class Icon"].frames[unit])
    auraFrame:EnableMouse(false)
    auraFrame:SetFrameStrata("MEDIUM")
    auraFrame:SetFrameLevel(3)

    auraFrame.cooldown = CreateFrame("Cooldown", nil, auraFrame, "CooldownFrameTemplate")
    auraFrame.cooldown.noCooldownCount = true
    auraFrame.cooldown:SetFrameStrata("MEDIUM")
    auraFrame.cooldown:SetFrameLevel(4)
    auraFrame.cooldown:SetReverse(true)
    auraFrame.cooldown:SetHideCountdownNumbers(true)

    auraFrame.cooldownFrame = CreateFrame("Frame", nil, auraFrame)
    auraFrame.cooldownFrame:ClearAllPoints()
    auraFrame.cooldownFrame:SetAllPoints(auraFrame)
    auraFrame.cooldownFrame:SetFrameStrata("MEDIUM")
    auraFrame.cooldownFrame:SetFrameLevel(5)

    auraFrame.icon = auraFrame:CreateTexture(nil, "BACKGROUND")
    auraFrame.icon:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    auraFrame.icon:SetAllPoints(auraFrame)

    auraFrame.icon.overlay = auraFrame.cooldownFrame:CreateTexture(nil, "OVERLAY")
    auraFrame.icon.overlay:SetAllPoints(auraFrame)
    auraFrame.icon.overlay:SetTexture(Gladdy.db.buttonBorderStyle)

    local classIcon = Gladdy.modules["Class Icon"].frames[unit]
    auraFrame:ClearAllPoints()
    auraFrame:SetAllPoints(classIcon)

    auraFrame.text = auraFrame.cooldownFrame:CreateFontString(nil, "OVERLAY")
    auraFrame.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), 10, "OUTLINE")
    auraFrame.text:SetTextColor(Gladdy.db.auraFontColor.r, Gladdy.db.auraFontColor.g, Gladdy.db.auraFontColor.b, Gladdy.db.auraFontColor.a)
    --auraFrame.text:SetShadowOffset(1, -1)
    --auraFrame.text:SetShadowColor(0, 0, 0, 1)
    auraFrame.text:SetJustifyH("CENTER")
    auraFrame.text:SetPoint("CENTER")
    auraFrame.unit = unit

    auraFrame:SetScript("OnUpdate", function(self, elapsed)
        if (self.active) then
            if (self.timeLeft <= 0) then
                Auras:AURA_FADE(self.unit, self.track)
            else
                self.timeLeft = self.timeLeft - elapsed
                self.text:SetFormattedText("%.1f", self.timeLeft >= 0.0 and self.timeLeft or 0.0)
            end
        end
    end)

    self.frames[unit] = auraFrame
    self:ResetUnit(unit)
end

function Auras:UpdateFrame(unit)
    local auraFrame = self.frames[unit]
    if (not auraFrame) then
        return
    end

    local width, height = Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor, Gladdy.db.classIconSize

    auraFrame:SetWidth(width)
    auraFrame:SetHeight(height)
    auraFrame:SetAllPoints(Gladdy.modules["Class Icon"].frames[unit])

    auraFrame.cooldown:SetWidth(width - width/16)
    auraFrame.cooldown:SetHeight(height - height/16)
    auraFrame.cooldown:ClearAllPoints()
    auraFrame.cooldown:SetPoint("CENTER", auraFrame, "CENTER")
    auraFrame.cooldown:SetAlpha(Gladdy.db.auraCooldownAlpha)

    auraFrame.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), (width/2 - 1) * Gladdy.db.auraFontSizeScale, "OUTLINE")
    auraFrame.text:SetTextColor(Gladdy.db.auraFontColor.r, Gladdy.db.auraFontColor.g, Gladdy.db.auraFontColor.b, Gladdy.db.auraFontColor.a)

    auraFrame.icon.overlay:SetTexture(Gladdy.db.auraBorderStyle)
    if auraFrame.track and auraFrame.track == AURA_TYPE_DEBUFF then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraDebuffBorderColor.r, Gladdy.db.auraDebuffBorderColor.g, Gladdy.db.auraDebuffBorderColor.b, Gladdy.db.auraDebuffBorderColor.a)
    elseif auraFrame.track and auraFrame.track == AURA_TYPE_BUFF then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraBuffBorderColor.r, Gladdy.db.auraBuffBorderColor.g, Gladdy.db.auraBuffBorderColor.b, Gladdy.db.auraBuffBorderColor.a)
    else
        auraFrame.icon.overlay:SetVertexColor(0, 0, 0, 1)
    end
    auraFrame.icon.overlay:Hide()
    if Gladdy.db.auraDisableCircle then
        auraFrame.cooldown:SetAlpha(0)
    end
end

function Auras:ResetUnit(unit)
    self.frames[unit]:UnregisterAllEvents()
    self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
    self:AURA_FADE(unit, AURA_TYPE_BUFF)
end

function Auras:Test(unit)
    local spellName, _, icon

    if (unit == "arena1") then
        spellName, _, icon = GetSpellInfo(12826)
        self:AURA_FADE(unit, AURA_TYPE_BUFF)
        self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
        self:AURA_GAIN(unit,AURA_TYPE_DEBUFF, 12826, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
    elseif (unit == "arena2") then
        spellName, _, icon = GetSpellInfo(6770)
        self:AURA_FADE(unit, AURA_TYPE_BUFF)
        self:AURA_FADE(unit,AURA_TYPE_DEBUFF)
        self:AURA_GAIN(unit,AURA_TYPE_DEBUFF, 6770, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
    elseif (unit == "arena3") then
        spellName, _, icon = GetSpellInfo(31224)
        self:AURA_FADE(unit, AURA_TYPE_BUFF)
        self:AURA_GAIN(unit,AURA_TYPE_BUFF, 31224, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
        spellName, _, icon = GetSpellInfo(18425)
        self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
        self:AURA_GAIN(unit,AURA_TYPE_DEBUFF, 18425, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
    end
end

function Auras:JOINED_ARENA()
    for i=1, Gladdy.curBracket do
        --self.frames["arena" .. i]:RegisterUnitEvent("UNIT_AURA", "arena" .. i)
        --self.frames["arena" .. i]:SetScript("OnEvent", Auras.OnEvent)
    end
end

function Auras:AURA_GAIN(unit, auraType, spellID, spellName, icon, duration, expirationTime, count, debuffType)
    local auraFrame = self.frames[unit]
    if (not auraFrame) then
        return
    end

    if not self.auras[spellName] then
        return
    end
    -- don't use spellId from combatlog, in case of different spellrank
    if not Gladdy.db.auraListDefault[tostring(self.auras[spellName].spellID)] or not Gladdy.db.auraListDefault[tostring(self.auras[spellName].spellID)].enabled then
        return
    end

    if (auraFrame.priority and auraFrame.priority > Gladdy.db.auraListDefault[tostring(self.auras[spellName].spellID)].priority) then
        return
    end
    auraFrame.startTime = expirationTime - duration
    auraFrame.endTime = expirationTime
    auraFrame.name = spellName
    auraFrame.timeLeft = expirationTime - GetTime()
    auraFrame.priority = Gladdy.db.auraListDefault[tostring(self.auras[spellName].spellID)].priority
    auraFrame.icon:SetTexture(icon)
    auraFrame.track = auraType
    auraFrame.active = true
    auraFrame.icon.overlay:Show()
    auraFrame.cooldownFrame:Show()
    if auraType == AURA_TYPE_DEBUFF then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraDebuffBorderColor.r, Gladdy.db.auraDebuffBorderColor.g, Gladdy.db.auraDebuffBorderColor.b, Gladdy.db.auraDebuffBorderColor.a)
    elseif auraType == AURA_TYPE_BUFF then
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.auraBuffBorderColor.r, Gladdy.db.auraBuffBorderColor.g, Gladdy.db.auraBuffBorderColor.b, Gladdy.db.auraBuffBorderColor.a)
    else
        auraFrame.icon.overlay:SetVertexColor(Gladdy.db.frameBorderColor.r, Gladdy.db.frameBorderColor.g, Gladdy.db.frameBorderColor.b, Gladdy.db.frameBorderColor.a)
    end
    if not Gladdy.db.auraDisableCircle then
        auraFrame.cooldown:Show()
        auraFrame.cooldown:SetCooldown(auraFrame.startTime, duration)
    end
end

function Auras:AURA_FADE(unit, auraType)
    local auraFrame = self.frames[unit]
    if (not auraFrame or auraFrame.track ~= auraType) then
        return
    end
    if auraFrame.active then
        auraFrame.cooldown:SetCooldown(GetTime(), 0)
    end
    auraFrame.cooldown:Hide()
    auraFrame.active = false
    auraFrame.name = nil
    auraFrame.timeLeft = 0
    auraFrame.priority = nil
    auraFrame.startTime = nil
    auraFrame.endTime = nil
    auraFrame.icon:SetTexture("")
    auraFrame.text:SetText("")
    auraFrame.icon.overlay:Hide()
    auraFrame.cooldownFrame:Hide()
end

function Auras:GetOptions()
    return {
        header = {
            type = "header",
            name = L["Auras"],
            order = 2,
        },
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 3,
            args = {
                cooldown = {
                    type = "group",
                    name = L["Cooldown"],
                    order = 1,
                    args = {
                        headerAuras = {
                            type = "header",
                            name = L["Cooldown"],
                            order = 2,
                        },
                        auraDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 3,
                            width = "full"
                        }),
                        auraCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 4,
                        }),
                    }
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 2,
                    args = {
                        headerAuras = {
                            type = "header",
                            name = L["Font"],
                            order = 1,
                        },
                        auraFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 5,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        auraFontSizeScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the text"],
                            order = 6,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
                        }),
                        auraFontColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Font color"],
                            desc = L["Color of the text"],
                            order = 7,
                            hasAlpha = true,
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 3,
                    args = {
                        headerAuras = {
                            type = "header",
                            name = L["Border"],
                            order = 2,
                        },
                        auraBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 9,
                            values = Gladdy:GetIconStyles(),
                        }),
                        auraBuffBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Buff color"],
                            desc = L["Color of the text"],
                            order = 10,
                            hasAlpha = true,
                            width = "0.8",
                        }),
                        auraDebuffBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Debuff color"],
                            desc = L["Color of the text"],
                            order = 11,
                            hasAlpha = true,
                            width = "0.8",
                        }),
                    }
                }
            }
        },
        debuffList = {
            type = "group",
            childGroups = "tree",
            name = "Debuffs",
            order = 4,
            args = Auras:GetAuraOptions(AURA_TYPE_DEBUFF)
        },
        buffList = {
            type = "group",
            childGroups = "tree",
            name = "Buffs",
            order = 5,
            args = Auras:GetAuraOptions(AURA_TYPE_BUFF)
        }
    }
end

function Auras:GetAuraOptions(auraType)
    local options = {
        ckeckAll = {
            order = 1,
            width = "0.7",
            name = L["Check All"],
            type = "execute",
            func = function(info)
                for k,v in pairs(defaultSpells(auraType)) do
                    Gladdy.db.auraListDefault[k].enabled = true
                end
            end,
        },
        uncheckAll = {
            order = 2,
            width = "0.7",
            name = L["Uncheck All"],
            type = "execute",
            func = function(info)
                for k,v in pairs(defaultSpells(auraType)) do
                    Gladdy.db.auraListDefault[k].enabled = false
                end
            end,
        },
    }
    local auras = {}
    for k,v in pairs(Gladdy:GetImportantAuras()) do
        if v.track == auraType then
            tinsert(auras, v.spellID)
        end
    end
    tbl_sort(auras)
    for i,k in ipairs(auras) do
        options[tostring(k)] = {
            type = "group",
            name = GetSpellInfo(k),
            order = i+2,
            icon = select(3, GetSpellInfo(k)),
            args = {
                enabled = {
                    order = 1,
                    name = L["Enabled"],
                    type = "toggle",
                    image = select(3, GetSpellInfo(k)),
                    width = "2",
                    set = function(info, value)
                        Gladdy.db.auraListDefault[tostring(k)].enabled = value
                    end,
                    get = function(info)
                        return Gladdy.db.auraListDefault[tostring(k)].enabled
                    end
                },
                priority = {
                    order = 2,
                    name = L["Priority"],
                    type = "range",
                    min = 0,
                    max = 50,
                    width = "2",
                    step = 1,
                    get = function(info)
                        return Gladdy.db.auraListDefault[tostring(k)].priority
                    end,
                    set = function(info, value)
                        Gladdy.db.auraListDefault[tostring(k)].priority = value
                    end,
                }
            }
        }
    end
    return options
end