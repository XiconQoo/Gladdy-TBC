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
local function defaultInterrupts()
    local spells = {}
    for k,v in pairs(Gladdy:GetInterrupts()) do
        spells[tostring(v.spellID)] = {}
        spells[tostring(v.spellID)].enabled = true
        spells[tostring(v.spellID)].priority = v.priority
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
    auraListDefault = defaultSpells(),
    auraListInterrupts = defaultInterrupts(),
    auraInterruptColorsEnabled = true,
    auraInterruptColors = Gladdy:GetSpellSchoolColors()
})

function Auras:Initialize()
    self.frames = {}

    self.auras = Gladdy:GetImportantAuras()

    self:RegisterMessage("JOINED_ARENA")
    self:RegisterMessage("UNIT_DEATH")
    self:RegisterMessage("AURA_GAIN")
    self:RegisterMessage("AURA_FADE")
    self:RegisterMessage("SPELL_INTERRUPT")
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
            if (self.interruptFrame.priority and self.priority < self.interruptFrame.priority) then
                self:SetAlpha(0.01)
            else
                self:SetAlpha(1)
            end
            if (self.timeLeft <= 0) then
                Auras:AURA_FADE(self.unit, self.track)
            else
                self.timeLeft = self.timeLeft - elapsed
                Gladdy:FormatTimer(self.text, self.timeLeft, self.timeLeft < 10)
            end
        else
            self:SetAlpha(0.01)
        end
    end)

    Gladdy.buttons[unit].aura = auraFrame
    self.frames[unit] = auraFrame
    self:CreateInterrupt(unit)
    self:ResetUnit(unit)
end

function Auras:CreateInterrupt(unit)
    local interruptFrame = CreateFrame("Frame", nil, Gladdy.modules["Class Icon"].frames[unit])
    interruptFrame:EnableMouse(false)
    interruptFrame:SetFrameStrata("MEDIUM")
    interruptFrame:SetFrameLevel(3)

    interruptFrame.cooldown = CreateFrame("Cooldown", nil, interruptFrame, "CooldownFrameTemplate")
    interruptFrame.cooldown.noCooldownCount = true
    interruptFrame.cooldown:SetFrameStrata("MEDIUM")
    interruptFrame.cooldown:SetFrameLevel(4)
    interruptFrame.cooldown:SetReverse(true)
    interruptFrame.cooldown:SetHideCountdownNumbers(true)

    interruptFrame.cooldownFrame = CreateFrame("Frame", nil, interruptFrame)
    interruptFrame.cooldownFrame:ClearAllPoints()
    interruptFrame.cooldownFrame:SetAllPoints(interruptFrame)
    interruptFrame.cooldownFrame:SetFrameStrata("MEDIUM")
    interruptFrame.cooldownFrame:SetFrameLevel(5)

    interruptFrame.icon = interruptFrame:CreateTexture(nil, "BACKGROUND")
    interruptFrame.icon:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    interruptFrame.icon:SetAllPoints(interruptFrame)

    interruptFrame.icon.overlay = interruptFrame.cooldownFrame:CreateTexture(nil, "OVERLAY")
    interruptFrame.icon.overlay:SetAllPoints(interruptFrame)
    interruptFrame.icon.overlay:SetTexture(Gladdy.db.buttonBorderStyle)

    local classIcon = Gladdy.modules["Class Icon"].frames[unit]
    interruptFrame:ClearAllPoints()
    interruptFrame:SetAllPoints(classIcon)

    interruptFrame.text = interruptFrame.cooldownFrame:CreateFontString(nil, "OVERLAY")
    interruptFrame.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), 10, "OUTLINE")
    interruptFrame.text:SetTextColor(Gladdy.db.auraFontColor.r, Gladdy.db.auraFontColor.g, Gladdy.db.auraFontColor.b, Gladdy.db.auraFontColor.a)
    --auraFrame.text:SetShadowOffset(1, -1)
    --auraFrame.text:SetShadowColor(0, 0, 0, 1)
    interruptFrame.text:SetJustifyH("CENTER")
    interruptFrame.text:SetPoint("CENTER")
    interruptFrame.unit = unit

    interruptFrame:SetScript("OnUpdate", function(self, elapsed)
        if (self.active) then
            if (Auras.frames[self.unit].priority and self.priority <= Auras.frames[self.unit].priority) then
                self:SetAlpha(0.01)
            else
                self:SetAlpha(1)
            end
            if (self.timeLeft <= 0) then
                self.active = false
                self.priority = nil
                self.spellSchool = nil
                self.cooldown:Clear()
                self:SetAlpha(0.01)
            else
                self.timeLeft = self.timeLeft - elapsed
                Gladdy:FormatTimer(self.text, self.timeLeft, self.timeLeft < 10)
            end
        else
            self:SetAlpha(0.01)
        end
    end)

    Gladdy.buttons[unit].interruptFrame = interruptFrame
    self.frames[unit].interruptFrame = interruptFrame
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
    if not auraFrame.active then
        auraFrame.icon.overlay:Hide()
    end
    if Gladdy.db.auraDisableCircle then
        auraFrame.cooldown:SetAlpha(0)
    end
    self:UpdateInterruptFrame(unit)
end

function Auras:UpdateInterruptFrame(unit)
    local interruptFrame = self.frames[unit] and self.frames[unit].interruptFrame
    if (not interruptFrame) then
        return
    end

    local width, height = Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor, Gladdy.db.classIconSize

    interruptFrame:SetWidth(width)
    interruptFrame:SetHeight(height)
    interruptFrame:SetAllPoints(Gladdy.modules["Class Icon"].frames[unit])

    interruptFrame.cooldown:SetWidth(width - width/16)
    interruptFrame.cooldown:SetHeight(height - height/16)
    interruptFrame.cooldown:ClearAllPoints()
    interruptFrame.cooldown:SetPoint("CENTER", interruptFrame, "CENTER")
    interruptFrame.cooldown:SetAlpha(Gladdy.db.auraCooldownAlpha)

    interruptFrame.text:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.auraFont), (width/2 - 1) * Gladdy.db.auraFontSizeScale, "OUTLINE")
    interruptFrame.text:SetTextColor(Gladdy.db.auraFontColor.r, Gladdy.db.auraFontColor.g, Gladdy.db.auraFontColor.b, Gladdy.db.auraFontColor.a)

    interruptFrame.icon.overlay:SetTexture(Gladdy.db.auraBorderStyle)
    if interruptFrame.spellSchool then
        interruptFrame.icon.overlay:SetVertexColor(self:GetInterruptColor(interruptFrame.spellSchool))
    else
        interruptFrame.icon.overlay:SetVertexColor(0, 0, 0, 1)
    end
    if not interruptFrame.active then
        interruptFrame.icon.overlay:Hide()
    end
    if Gladdy.db.auraDisableCircle then
        interruptFrame.cooldown:SetAlpha(0)
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
        spellName, _, icon = GetSpellInfo(7922)
        self:AURA_FADE(unit, AURA_TYPE_BUFF)
        self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
        self:AURA_GAIN(unit,AURA_TYPE_DEBUFF, 7922, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
        self:SPELL_INTERRUPT(unit,19244, select(1, GetSpellInfo(19244)), "physical", 25396, select(1, GetSpellInfo(25396)), 64)
    elseif (unit == "arena2") then
        spellName = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689))
        _, _, icon = GetSpellInfo(27010)
        self:AURA_FADE(unit, AURA_TYPE_BUFF)
        self:AURA_FADE(unit,AURA_TYPE_DEBUFF)
        self:AURA_GAIN(unit,AURA_TYPE_DEBUFF, 27010, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
        self:SPELL_INTERRUPT(unit,19244, select(1, GetSpellInfo(19244)), "physical", 25396, select(1, GetSpellInfo(25396)), 64)
    elseif (unit == "arena3") then
        spellName, _, icon = GetSpellInfo(34709)
        self:AURA_FADE(unit, AURA_TYPE_BUFF)
        self:AURA_GAIN(unit,AURA_TYPE_BUFF, 34709, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
        spellName, _, icon = GetSpellInfo(18425)
        --self:AURA_FADE(unit, AURA_TYPE_DEBUFF)
        --self:AURA_GAIN(unit,AURA_TYPE_DEBUFF, 18425, spellName, icon, self.auras[spellName].duration, GetTime() + self.auras[spellName].duration)
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

    if spellID == 31117 then
        spellName = "Unstable Affliction Silence"
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
    auraFrame.icon:SetTexture(Gladdy:GetImportantAuras()[GetSpellInfo(self.auras[spellName].spellID)] and Gladdy:GetImportantAuras()[GetSpellInfo(self.auras[spellName].spellID)].texture or icon)
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
        auraFrame.cooldown:Clear()
    end
    --auraFrame.cooldown:Hide()
    auraFrame.active = false
    auraFrame.name = nil
    auraFrame.timeLeft = 0
    auraFrame.priority = nil
    auraFrame.startTime = nil
    auraFrame.endTime = nil
    auraFrame.icon:SetTexture("")
    auraFrame.text:SetText("")
    --auraFrame.icon.overlay:Hide()
    --auraFrame.cooldownFrame:Hide()
end

function Auras:GetInterruptColor(extraSpellSchool)
    if not Gladdy.db.auraInterruptColorsEnabled then
        return Gladdy.db.auraDebuffBorderColor.r, Gladdy.db.auraDebuffBorderColor.g, Gladdy.db.auraDebuffBorderColor.b, Gladdy.db.auraDebuffBorderColor.a
    else
        local color = Gladdy.db.auraInterruptColors[extraSpellSchool] or Gladdy.db.auraInterruptColors["unknown"]
        return color.r, color.g, color.b, color.a
    end
end

function Auras:SPELL_INTERRUPT(unit,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool)
    local auraFrame = self.frames[unit]
    local interruptFrame = auraFrame and auraFrame.interruptFrame
    local button = Gladdy.buttons[unit]
    if (not interruptFrame) then
        return
    end
    if not Gladdy.db.auraListInterrupts[tostring(Gladdy:GetInterrupts()[spellName].spellID)] or not Gladdy.db.auraListInterrupts[tostring(Gladdy:GetInterrupts()[spellName].spellID)].enabled then
        return
    end
    if (interruptFrame.priority and interruptFrame.priority > Gladdy.db.auraListInterrupts[tostring(Gladdy:GetInterrupts()[spellName].spellID)].priority) then
        return
    end
    local multiplier = ((button.spec == L["Restoration"] and button.class == "SHAMAN") or (button.spec == L["Holy"] and button.class == "PALADIN")) and 0.7 or 1

    local duration = Gladdy:GetInterrupts()[spellName].duration * multiplier

    interruptFrame.startTime = GetTime()
    interruptFrame.endTime = GetTime() + duration
    interruptFrame.name = spellName
    interruptFrame.timeLeft = duration
    interruptFrame.priority = Gladdy.db.auraListInterrupts[tostring(Gladdy:GetInterrupts()[spellName].spellID)].priority
    interruptFrame.icon:SetTexture(Gladdy:GetInterrupts()[spellName].texture)
    interruptFrame.spellSchool = extraSpellSchool
    interruptFrame.active = true
    interruptFrame.icon.overlay:Show()
    interruptFrame.cooldownFrame:Show()

    interruptFrame.icon.overlay:SetVertexColor(self:GetInterruptColor(extraSpellSchool))

    if not Gladdy.db.auraDisableCircle then
        interruptFrame.cooldown:Show()
        interruptFrame.cooldown:SetCooldown(interruptFrame.startTime, duration)
    end
    --interruptFrame:SetAlpha(1)
end

function Auras:GetOptions()
    local borderArgs = {
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
        headerColors = {
            type = "header",
            name = L["Interrupt Spells School Colors"],
            order = 12,
        },
        auraInterruptColorsEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enable Interrupt Spell School Colors"],
            width = "full",
            desc = L["Will use Debuff Color if disabled"],
            order = 13,
        }),
    }
    local list = {}
    for k,v in pairs(Gladdy:GetSpellSchoolColors()) do
        tinsert(list, { key = k, val = v})
    end
    tbl_sort(list, function(a, b) return a.val.type < b.val.type end)
    for i,v in ipairs(list) do
        borderArgs["auraSpellSchool" .. v.key] = {
            type = "color",
            name = v.val.type,
            order = i + 13,
            hasAlpha = true,
            width = "0.8",
            set = function(info, r, g, b, a)
                Gladdy.db.auraInterruptColors[v.key].r = r
                Gladdy.db.auraInterruptColors[v.key].g = g
                Gladdy.db.auraInterruptColors[v.key].b = b
                Gladdy.db.auraInterruptColors[v.key].a = a
            end,
            get = function()
                local color = Gladdy.db.auraInterruptColors[v.key]
                return color.r, color.g, color.b, color.a
            end
        }
    end

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
                            width = "full",
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
                            width = "full",
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
                    args = borderArgs
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
        },
        interruptList = {
            type = "group",
            childGroups = "tree",
            name = "Interrupts",
            order = 6,
            args = Auras:GetInterruptOptions()
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
    tbl_sort(auras, function(a, b) return GetSpellInfo(a) < GetSpellInfo(b) end)
    for i,k in ipairs(auras) do
        options[tostring(k)] = {
            type = "group",
            name = (Gladdy:GetImportantAuras()["Unstable Affliction Silence"]
                    and Gladdy:GetImportantAuras()["Unstable Affliction Silence"].spellID == k
                    and Gladdy:GetImportantAuras()["Unstable Affliction Silence"].altName)
                    or (Gladdy:GetImportantAuras()[select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689))]
                    and Gladdy:GetImportantAuras()[select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689))].spellID == k
                    and Gladdy:GetImportantAuras()[select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689))].altName)
                    or GetSpellInfo(k),
            order = i+2,
            icon = Gladdy:GetImportantAuras()[GetSpellInfo(k)] and Gladdy:GetImportantAuras()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
            args = {
                enabled = {
                    order = 1,
                    name = L["Enabled"],
                    type = "toggle",
                    image = Gladdy:GetImportantAuras()[GetSpellInfo(k)] and Gladdy:GetImportantAuras()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
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
                    width = "full",
                }
            }
        }
    end
    return options
end

function Auras:GetInterruptOptions()
    local options = {
        ckeckAll = {
            order = 1,
            width = "0.7",
            name = L["Check All"],
            type = "execute",
            func = function(info)
                for k,v in pairs(defaultInterrupts()) do
                    Gladdy.db.auraListInterrupts[k].enabled = true
                end
            end,
        },
        uncheckAll = {
            order = 2,
            width = "0.7",
            name = L["Uncheck All"],
            type = "execute",
            func = function(info)
                for k,v in pairs(defaultInterrupts()) do
                    Gladdy.db.auraListInterrupts[k].enabled = false
                end
            end,
        },
    }
    local auras = {}
    for k,v in pairs(Gladdy:GetInterrupts()) do
        tinsert(auras, v.spellID)
    end
    tbl_sort(auras, function(a, b) return GetSpellInfo(a) < GetSpellInfo(b) end)
    for i,k in ipairs(auras) do
        options[tostring(k)] = {
            type = "group",
            name = Gladdy:GetInterrupts()["Unstable Affliction Silence"]
                    and Gladdy:GetInterrupts()["Unstable Affliction Silence"].spellID == k
                    and Gladdy:GetInterrupts()["Unstable Affliction Silence"].altName
                    or GetSpellInfo(k),
            order = i+2,
            icon = Gladdy:GetInterrupts()[GetSpellInfo(k)] and Gladdy:GetInterrupts()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
            args = {
                enabled = {
                    order = 1,
                    name = L["Enabled"],
                    type = "toggle",
                    image = Gladdy:GetInterrupts()[GetSpellInfo(k)] and Gladdy:GetInterrupts()[GetSpellInfo(k)].texture or select(3, GetSpellInfo(k)),
                    width = "2",
                    set = function(info, value)
                        Gladdy.db.auraListInterrupts[tostring(k)].enabled = value
                    end,
                    get = function(info)
                        return Gladdy.db.auraListInterrupts[tostring(k)].enabled
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
                        return Gladdy.db.auraListInterrupts[tostring(k)].priority
                    end,
                    set = function(info, value)
                        Gladdy.db.auraListInterrupts[tostring(k)].priority = value
                    end,
                    width = "full",
                }
            }
        }
    end
    return options
end