local C_NamePlate = C_NamePlate
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local tremove, tinsert = tremove, tinsert
local GetSpellInfo, CreateFrame = GetSpellInfo, CreateFrame
local GetTime, GetPlayerInfoByGUID, UnitIsEnemy, UnitGUID = GetTime, GetPlayerInfoByGUID, UnitIsEnemy, UnitGUID
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local cooldowns = {
    [2484] = 3, --Earthbind
    [8143] = 4, -- Tremor
    [8166] = 4, -- Poison Cleansing
    [8170] = 4, -- Disease Cleansing
    [1535] = { cd = 4, once = true }, -- Fire Nova 1
    [8498] = { cd = 4, once = true }, -- Fire Nova 2
    [8499] = { cd = 4, once = true }, -- Fire Nova 3
    [11314] = { cd = 4, once = true }, -- Fire Nova 4
    [11315] = { cd = 4, once = true }, -- Fire Nova 5
    [25546] = { cd = 4, once = true }, -- Fire Nova 6
    [25547] = { cd = 4, once = true }, -- Fire Nova 7
    [8190] = 2, -- Magma 1
    [10585] = 2, -- Magma 2
    [10586] = 2, -- Magma 3
    [10587] = 2, -- Magma 4
    [25552] = 2, -- Magma 5
    [5394] = 2, -- Healing Stream 1
    [6375] = 2, -- Healing Stream 2
    [6377] = 2, -- Healing Stream 3
    [10462] = 2, -- Healing Stream 4
    [10463] = 2, -- Healing Stream 5
    [25567] = 2, -- Healing Stream 6
    [5675] = 2, -- Mana Spring 1
    [10495] = 2, -- Mana Spring 2
    [10496] = 2, -- Mana Spring 3
    [10497] = 2, -- Mana Spring 4
    [25570] = 2, -- Mana Spring 5
}

local ninetyDegreeInRad = 90 * math.pi / 180

---------------------------------------------------

-- Core

---------------------------------------------------


local TotemPulse = Gladdy:NewModule("Totem Pulse", nil, {
    totemPulseEnabled = true,
    totemPulseEnabledShowFriendly = true,
    totemPulseEnabledShowEnemy = true,
    totemPulseAttachToTotemPlate = true,
    totemPulseStyle = "", -- "COOLDOWN", "COOLDOWNREVERSE", "BARVERTICAL", "BARHORIZONTAL"
    totemPulseTextColor = { r = 1, g = 1, b = 1, a = 0 },
    --bar
    totemPulseBarWidth = 40,
    totemPulseBarHeight = 20,
    totemPulseBarColor =  { r = 1, g = 0, b = 0, a = 1 },
    totemPulseBarBgColor =  { r = 0, g = 1, b = 0, a = 1 },
    totemPulseBarBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    totemPulseBarBorderSize = 5,
    totemPulseBarBorderStyle = "Gladdy Tooltip squared",
    totemPulseBarTexture = "Smooth",
    --cooldown
    totemPulseCooldownAlpha = 1,
})

function TotemPulse.OnEvent(self, event, ...)
    TotemPulse[event](self, ...)
end

function TotemPulse:Initialize()
    self.cooldowns = cooldowns
    self.timeStamps = {}
    self.cooldownCache = {}
    self.barCache = {}
    self.activeFrames = { bars = {}, cooldowns = {} }
    self:SetScript("OnEvent", self.OnEvent)
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("UNIT_NAME_UPDATE")
end

---------------------------------------------------

-- EVENTS

---------------------------------------------------

function TotemPulse:COMBAT_LOG_EVENT_UNFILTERED()
    local _,eventType,_,sourceGUID,_,_,_,destGUID,_,_,_,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool = CombatLogGetCurrentEventInfo()
    print(eventType, spellName, spellID, destGUID)
    if eventType == "SPELL_SUMMON" then
        if cooldowns[spellID] then
            print(eventType, spellName, spellID, GetPlayerInfoByGUID(sourceGUID))
            self.timeStamps[destGUID] = { timeStamp = GetTime(), spellID = spellID }
        end
    elseif eventType == "UNIT_DESTROYED" then
        self.timeStamps[destGUID] = nil
    end
end

function TotemPulse:NAME_PLATE_UNIT_REMOVED(unitId)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitId)
    if nameplate.totemTick then
        print("NAME_PLATE_UNIT_REMOVED", nameplate.totemTick)
        nameplate.totemTick:SetScript("OnUpdate", nil)
        nameplate.totemTick:Hide()
        nameplate.totemTick:SetParent(nil)
        tinsert(nameplate.totemTick.bar and self.barCache or self.cooldownCache, nameplate.totemTick)
        self.activeFrames.bars[nameplate.totemTick] = nil
        self.activeFrames.cooldowns[nameplate.totemTick] = nil
        nameplate.totemTick = nil
    end
end

function TotemPulse:NAME_PLATE_UNIT_ADDED(unitId)
    self:OnUnitAdded(unitId, "NAME_PLATE_UNIT_ADDED")
end

function TotemPulse:UNIT_NAME_UPDATE(unitId)
    self:OnUnitAdded(unitId, "UNIT_NAME_UPDATE")
end

function TotemPulse:OnUnitAdded(unitId, event)
    local isEnemy = UnitIsEnemy("player", unitId)
    local guid = UnitGUID(unitId)

    local nameplate = C_NamePlate.GetNamePlateForUnit(unitId)

    if nameplate then
        print(event, self.timeStamps[guid], nameplate.totemTick)
        if self.timeStamps[guid] then
            self:AddTimerFrame(nameplate, self.timeStamps[guid], Gladdy.db.totemPulseAttachToTotemPlate and nameplate.gladdyTotemFrame)
        else
            if nameplate.totemTick then
                nameplate.totemTick:SetScript("OnUpdate", nil)
                nameplate.totemTick:Hide()
                nameplate.totemTick:SetParent(nil)
                tinsert(nameplate.totemTick.bar and self.barCache or self.cooldownCache, nameplate.totemTick)
                self.activeFrames.bars[nameplate.totemTick] = nil
                self.activeFrames.cooldowns[nameplate.totemTick] = nil
                nameplate.totemTick = nil
            end
        end
    end
end

---------------------------------------------------

-- FRAMES

---------------------------------------------------

function TotemPulse:CreateCooldownFrame(gladdyTotemFrame)
    local totemTick

    if gladdyTotemFrame then
        if #self.cooldownCache > 0 then
            totemTick = tremove(self.cooldownCache, #self.cooldownCache)
        else
            Gladdy:Print("TotemPulse:CreateCooldownFrame()", "CreateCooldown")
            totemTick = CreateFrame("Cooldown", nil, nil, "CooldownFrameTemplate")
            totemTick.noCooldownCount = true
            totemTick:SetFrameStrata("MEDIUM")
            totemTick:SetFrameLevel(4)
            totemTick:SetReverse(true)
            totemTick:SetHideCountdownNumbers(true)
            totemTick:SetAlpha(Gladdy.db.totemPulseCooldownAlpha)

            totemTick.text = totemTick:CreateFontString(nil, "OVERLAY")
            totemTick.text:SetPoint("LEFT", totemTick, "LEFT", 4, 0)
            totemTick.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
            totemTick.text:SetJustifyH("LEFT")
            totemTick.text:SetShadowOffset(1, -1)
            totemTick.text:SetTextColor(Gladdy:SetColor(Gladdy.db.totemPulseTextColor))
        end
    else
        if #self.barCache > 0 then
            Gladdy:Print("TotemPulse:CreateCooldownFrame()", #self.barCache)
            totemTick = tremove(self.barCache, #self.barCache)
        else
            Gladdy:Print("TotemPulse:CreateCooldownFrame()", "CreateBar")
            totemTick = CreateFrame("Frame", nil)

            totemTick:SetWidth(Gladdy.db.totemPulseBarWidth)
            totemTick:SetHeight(Gladdy.db.totemPulseBarHeight)

            totemTick.backdrop = CreateFrame("Frame", nil, totemTick, BackdropTemplateMixin and "BackdropTemplate")
            totemTick.backdrop:SetAllPoints(totemTick)
            totemTick.backdrop:SetBackdrop({ edgeFile = Gladdy:SMFetch("border", "totemPulseBarBorderStyle"),
                                             edgeSize = Gladdy.db.totemPulseBarBorderSize })
            totemTick.backdrop:SetBackdropBorderColor(Gladdy:SetColor(Gladdy.db.totemPulseBarBorderColor))
            totemTick.backdrop:SetFrameLevel(1)
            --totemTick.backdrop:SetFrameStrata(Gladdy.db.castBarFrameStrata)
            --totemTick.backdrop:SetFrameLevel(Gladdy.db.castBarFrameLevel - 1)

            totemTick.bar = CreateFrame("StatusBar", nil, totemTick)
            totemTick.bar:SetStatusBarTexture(Gladdy:SMFetch("statusbar", "totemPulseBarTexture"))
            totemTick.bar:SetStatusBarColor(Gladdy:SetColor(Gladdy.db.totemPulseBarColor))
            totemTick.bar:SetOrientation("Vertical")
            totemTick.bar:SetFrameLevel(0)
            totemTick.bar:SetPoint("TOPLEFT", totemTick, "TOPLEFT", (Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset), -(Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset))
            totemTick.bar:SetPoint("BOTTOMRIGHT", totemTick, "BOTTOMRIGHT", -(Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset), (Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset))

            totemTick.spark = totemTick.bar:CreateTexture(nil, "OVERLAY")
            totemTick.spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            totemTick.spark:SetBlendMode("ADD")
            totemTick.spark:SetWidth(8)
            totemTick.spark:SetHeight(40)
            totemTick.spark.position = 0
            totemTick.spark:SetRotation(ninetyDegreeInRad)

            totemTick.bg = totemTick.bar:CreateTexture(nil, "BACKGROUND")
            totemTick.bg:SetTexture(Gladdy:SMFetch("statusbar", "totemPulseBarTexture"))
            totemTick.bg:SetAllPoints(totemTick.bar)
            totemTick.bg:SetVertexColor(Gladdy:SetColor(Gladdy.db.totemPulseBarBgColor))

            totemTick.text = totemTick.bar:CreateFontString(nil, "OVERLAY")
            totemTick.text:SetPoint("LEFT", totemTick, "LEFT", 4, 0)
            totemTick.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
            totemTick.text:SetJustifyH("LEFT")
            totemTick.text:SetShadowOffset(1, -1)
            totemTick.text:SetTextColor(Gladdy:SetColor(Gladdy.db.totemPulseTextColor))
        end
    end
    return totemTick
end

function TotemPulse:AddTimerFrame(nameplate, timestamp, gladdyTotemFrame)
    if nameplate:IsShown() and cooldowns[timestamp.spellID] then
        if not nameplate.totemTick then
            nameplate.totemTick = TotemPulse:CreateCooldownFrame(gladdyTotemFrame)
        end
        nameplate.totemTick:SetParent(nameplate)
        nameplate.totemTick:ClearAllPoints()
        if gladdyTotemFrame then
            nameplate.totemTick:SetPoint("TOPLEFT", gladdyTotemFrame, "TOPLEFT", Gladdy.db.npTotemPlatesSize/16, -Gladdy.db.npTotemPlatesSize/16)
            nameplate.totemTick:SetPoint("BOTTOMRIGHT", gladdyTotemFrame, "BOTTOMRIGHT", -Gladdy.db.npTotemPlatesSize/16, Gladdy.db.npTotemPlatesSize/16)
        else
            nameplate.totemTick:SetPoint("TOP", nameplate, "BOTTOM")
        end

        local cd = type(cooldowns[timestamp.spellID]) == "table" and cooldowns[timestamp.spellID].cd or cooldowns[timestamp.spellID]
        local once = type(cooldowns[timestamp.spellID]) == "table"
        local cooldown = (timestamp.timeStamp - GetTime()) % cd

        if not gladdyTotemFrame then
            nameplate.totemTick.bar:SetMinMaxValues(0, cd)
            nameplate.totemTick.bar:SetValue(cooldown)
            self.activeFrames.bars[nameplate.totemTick] = nameplate.totemTick
        else
            self.activeFrames.cooldowns[nameplate.totemTick] = nameplate.totemTick
        end

        nameplate.totemTick.timestamp = timestamp.timeStamp
        nameplate.totemTick.maxValue = cd
        nameplate.totemTick.value = cooldown
        nameplate.totemTick.once = once

        print("once", once, " - totemTick.once", nameplate.totemTick.once, " - cd off", math.abs(timestamp.timeStamp - GetTime()) > cd)
        if once and GetTime() - timestamp.timeStamp > cd then
            nameplate.totemTick:SetScript("OnUpdate", nil)
            nameplate.totemTick:Hide()
            print("nameplate.totemTick:Hide()")
        else
            nameplate.totemTick:SetScript("OnUpdate", function(totemTick, elapsed)
                totemTick.now = GetTime()
                totemTick.value = (totemTick.timestamp - totemTick.now) % totemTick.maxValue
                if totemTick.once and totemTick.now - totemTick.timestamp >= totemTick.maxValue then
                    totemTick:SetScript("OnUpdate", nil)
                    print("OnUpdate totemTick:Hide()")
                    totemTick:Hide()
                end
                if not totemTick.bar and not (totemTick.once and totemTick.now - totemTick.timestamp >= totemTick.maxValue) then
                    totemTick:SetCooldown(totemTick.now - totemTick.value, totemTick.maxValue)
                elseif totemTick.bar then
                    totemTick.spark.position = (totemTick.value / totemTick.maxValue) * totemTick.bar:GetHeight()
                    if ( totemTick.spark.position < 0 ) then
                        totemTick.spark.position = 0
                    end
                    totemTick.spark:SetPoint("CENTER", totemTick.bar, "BOTTOM", 0, totemTick.spark.position)
                    totemTick.bar:SetValue(totemTick.value)
                end
                totemTick.text:SetFormattedText("%.1f", totemTick.value)
            end)
            print("nameplate.totemTick:Show()")
            nameplate.totemTick:Show()
        end
    else
        if nameplate.totemTick then
            nameplate.totemTick:SetScript("OnUpdate", nil)
            nameplate.totemTick:Hide()
            nameplate.totemTick:SetParent(nil)
            tinsert(nameplate.totemTick.bar and self.barCache or self.cooldownCache, nameplate.totemTick)
            self.activeFrames.bars[nameplate.totemTick] = nil
            self.activeFrames.cooldowns[nameplate.totemTick] = nil
            nameplate.totemTick = nil
        end
    end
end

function TotemPulse:UpdateBar(bar)
    bar:SetWidth(Gladdy.db.totemPulseBarWidth)
    bar:SetHeight(Gladdy.db.totemPulseBarHeight)

    bar.backdrop:SetBackdrop({ edgeFile = Gladdy:SMFetch("border", "totemPulseBarBorderStyle"),
                               edgeSize = Gladdy.db.totemPulseBarBorderSize })
    bar.backdrop:SetBackdropBorderColor(Gladdy:SetColor(Gladdy.db.totemPulseBarBorderColor))

    bar.bar:SetStatusBarTexture(Gladdy:SMFetch("statusbar", "totemPulseBarTexture"))
    bar.bar:SetStatusBarColor(Gladdy:SetColor(Gladdy.db.totemPulseBarColor))
    bar.bar:SetOrientation("Vertical")
    bar.bar:SetPoint("TOPLEFT", bar, "TOPLEFT", (Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset), -(Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset))
    bar.bar:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -(Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset), (Gladdy.db.totemPulseBarBorderSize/Gladdy.db.statusbarBorderOffset))

    bar.spark:SetWidth(8)
    bar.spark:SetHeight(40)
    bar.spark:SetRotation(ninetyDegreeInRad)

    bar.bg:SetTexture(Gladdy:SMFetch("statusbar", "totemPulseBarTexture"))
    bar.bg:SetVertexColor(Gladdy:SetColor(Gladdy.db.totemPulseBarBgColor))

    bar.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    bar.text:SetTextColor(Gladdy:SetColor(Gladdy.db.totemPulseTextColor))
end

function TotemPulse:UpdateCooldown(cooldown)
    cooldown:SetReverse(true)
    cooldown:SetAlpha(Gladdy.db.totemPulseCooldownAlpha)
    cooldown.text:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    cooldown.text:SetTextColor(Gladdy:SetColor(Gladdy.db.totemPulseTextColor))
end

function TotemPulse:UpdateFrameOnce()
    for _,bar in pairs(self.activeFrames.bars) do
        self:UpdateBar(bar)
    end
    for _,cooldown in pairs(self.activeFrames.cooldowns) do
        self:UpdateCooldown(cooldown)
    end
    for _,bar in pairs(self.barCache) do
        self:UpdateBar(bar)
    end
    for _,cooldown in pairs(self.cooldownCache) do
        self:UpdateCooldown(cooldown)
    end
end

---------------------------------------------------

-- TEST

---------------------------------------------------


---------------------------------------------------

-- OPTIONS

---------------------------------------------------

function TotemPulse:GetOptions()
    return {
        headerClassicon = {
            type = "header",
            name = L["Totem Pulse"],
            order = 2,
        },
        totemPulseEnabled = Gladdy:option({
            type = "toggle",
            name = L["Totem Pulse Enabled"],
            order = 3,
        }),
        totemPulseAttachToTotemPlate = Gladdy:option({
            type = "toggle",
            name = L["Attach to Totem Plates"],
            order = 4,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            args = {
                barFrame = {
                    type = "group",
                    name = L["Bar"],
                    order = 1,
                    args = {
                        headerSize = {
                            type = "header",
                            name = L["Bar Size"],
                            order = 1,
                        },
                        totemPulseBarHeight = Gladdy:option({
                            type = "range",
                            name = L["Bar height"],
                            desc = L["Height of the bar"],
                            order = 3,
                            min = 0.1,
                            max = 200,
                            step = .1,
                            width = "full",
                        }),
                        totemPulseBarWidth = Gladdy:option({
                            type = "range",
                            name = L["Bar width"],
                            desc = L["Width of the bars"],
                            order = 4,
                            min = 0.1,
                            max = 600,
                            step = .1,
                            width = "full",
                        }),
                        headerTexture = {
                            type = "header",
                            name = L["Texture"],
                            order = 5,
                        },
                        totemPulseBarTexture = Gladdy:option({
                            type = "select",
                            name = L["Bar texture"],
                            desc = L["Texture of the bar"],
                            order = 9,
                            dialogControl = "LSM30_Statusbar",
                            values = AceGUIWidgetLSMlists.statusbar,
                        }),
                        totemPulseBarColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Bar color"],
                            desc = L["Color of the cast bar"],
                            order = 10,
                            hasAlpha = true,
                        }),
                        totemPulseBarBgColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Background color"],
                            desc = L["Color of the cast bar background"],
                            order = 11,
                            hasAlpha = true,
                        }),
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 12,
                        },
                        totemPulseBarBorderSize = Gladdy:option({
                            type = "range",
                            name = L["Border size"],
                            order = 13,
                            min = 0.5,
                            max = Gladdy.db.castBarHeight/2,
                            step = 0.5,
                            width = "full",
                        }),
                        totemPulseBarBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Status Bar border"],
                            order = 51,
                            dialogControl = "LSM30_Border",
                            values = AceGUIWidgetLSMlists.border,
                        }),
                        totemPulseBarBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Status Bar border color"],
                            order = 52,
                            hasAlpha = true,
                        }),
                    },
                },
            },
        },
    }
end