local type, pairs, ipairs, ceil, tonumber, mod, tostring, upper, select, tinsert, tremove = type, pairs, ipairs, ceil, tonumber, mod, tostring, string.upper, select, tinsert, tremove
local GetTime = GetTime
local CreateFrame = CreateFrame
local RACE_ICON_TCOORDS = {
    ["HUMAN_MALE"]		= {0, 0.125, 0, 0.25},
    ["DWARF_MALE"]		= {0.125, 0.25, 0, 0.25},
    ["GNOME_MALE"]		= {0.25, 0.375, 0, 0.25},
    ["NIGHTELF_MALE"]	= {0.375, 0.5, 0, 0.25},

    ["TAUREN_MALE"]		= {0, 0.125, 0.25, 0.5},
    ["SCOURGE_MALE"]	= {0.125, 0.25, 0.25, 0.5},
    ["TROLL_MALE"]		= {0.25, 0.375, 0.25, 0.5},
    ["ORC_MALE"]		= {0.375, 0.5, 0.25, 0.5},

    ["HUMAN_FEMALE"]	= {0, 0.125, 0.5, 0.75},
    ["DWARF_FEMALE"]	= {0.125, 0.25, 0.5, 0.75},
    ["GNOME_FEMALE"]	= {0.25, 0.375, 0.5, 0.75},
    ["NIGHTELF_FEMALE"]	= {0.375, 0.5, 0.5, 0.75},

    ["TAUREN_FEMALE"]	= {0, 0.125, 0.75, 1.0},
    ["SCOURGE_FEMALE"]	= {0.125, 0.25, 0.75, 1.0},
    ["TROLL_FEMALE"]	= {0.25, 0.375, 0.75, 1.0},
    ["ORC_FEMALE"]		= {0.375, 0.5, 0.75, 1.0},

    ["BLOODELF_MALE"]	= {0.5, 0.625, 0.25, 0.5},
    ["BLOODELF_FEMALE"]	= {0.5, 0.625, 0.75, 1.0},

    ["DRAENEI_MALE"]	= {0.5, 0.625, 0, 0.25},
    ["DRAENEI_FEMALE"]	= {0.5, 0.625, 0.5, 0.75},
}

local GetSpellInfo = GetSpellInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local function getDefaultCooldown()
    local cooldowns = {}
    for _,spellTable in pairs(Gladdy:GetCooldownList()) do
        for spellId,_ in pairs(spellTable) do
            local spellName = GetSpellInfo(spellId)
            if spellName then
                cooldowns[tostring(spellId)] = true
            else
                Gladdy:Debug("ERROR", "spellid does not exist  " .. spellId)
            end
        end
    end
    return cooldowns
end

local Cooldowns = Gladdy:NewModule("Cooldowns", nil, {
    cooldownFont = "DorisPP",
    cooldownFontScale = 1,
    cooldownFontColor = { r = 1, g = 1, b = 0, a = 1 },
    cooldown = true,
    cooldownYGrowDirection = "UP",
    cooldownXGrowDirection = "RIGHT",
    cooldownYOffset = 0,
    cooldownXOffset = 0,
    cooldownSize = 30,
    cooldownWidthFactor = 1,
    cooldownIconPadding = 1,
    cooldownMaxIconsPerLine = 10,
    cooldownBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    cooldownBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    cooldownDisableCircle = false,
    cooldownCooldownAlpha = 1,
    cooldownCooldowns = getDefaultCooldown(),
    cooldownFrameStrata = "MEDIUM",
    cooldownFrameLevel = 3,
})

function Cooldowns:Initialize()
    self.cooldownSpellIds = {}
    self.spellTextures = {}
    self.iconCache = {}
    for _,spellTable in pairs(Gladdy:GetCooldownList()) do
        for spellId,_ in pairs(spellTable) do
            local spellName, _, texture = GetSpellInfo(spellId)
            if spellName then
                self.cooldownSpellIds[spellName] = spellId
                self.spellTextures[spellId] = texture
            else
                Gladdy:Debug("ERROR", "spellid does not exist  " .. spellId)
            end
        end
    end
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("SPEC_DETECTED")
    self:RegisterMessage("UNIT_DEATH")
    self:RegisterMessage("UNIT_DESTROYED")
end

---------------------
-- Frame
---------------------

function Cooldowns:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    -- Cooldown frame
    local spellCooldownFrame = CreateFrame("Frame", nil, button)
    spellCooldownFrame:EnableMouse(false)
    spellCooldownFrame:SetMovable(true)
    spellCooldownFrame:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
    spellCooldownFrame:SetFrameLevel(Gladdy.db.cooldownFrameLevel)
    spellCooldownFrame.icons = {}
    button.spellCooldownFrame = spellCooldownFrame
end

function Cooldowns:CreateIcon() -- returns iconFrame
    local icon
    if (#self.iconCache > 0) then
        icon = tremove(self.iconCache, #self.iconCache)
    else
        icon = CreateFrame("Frame")
        icon:EnableMouse(false)

        icon.texture = icon:CreateTexture(nil, "BACKGROUND")
        icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
        icon.texture:SetAllPoints(icon)

        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true
        icon.cooldown:SetReverse(false)
        icon.cooldown:SetHideCountdownNumbers(true)

        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetAllPoints(icon)

        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY")
        icon.border:SetAllPoints(icon)

        icon.cooldownFont = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.cooldownFont:SetAllPoints(icon)

        self:UpdateIcon(icon)
    end
    return icon
end

function Cooldowns:UpdateIcon(icon)
    icon:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
    icon:SetFrameLevel(Gladdy.db.cooldownFrameLevel)
    icon.cooldown:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
    icon.cooldown:SetFrameLevel(Gladdy.db.cooldownFrameLevel + 1)
    icon.cooldownFrame:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
    icon.cooldownFrame:SetFrameLevel(Gladdy.db.cooldownFrameLevel + 2)

    icon:SetHeight(Gladdy.db.cooldownSize)
    icon:SetWidth(Gladdy.db.cooldownSize * Gladdy.db.cooldownWidthFactor)
    icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2 * Gladdy.db.cooldownFontScale, "OUTLINE")
    icon.cooldownFont:SetTextColor(Gladdy:SetColor(Gladdy.db.cooldownFontColor))

    icon.cooldown:SetWidth(icon:GetWidth() - icon:GetWidth()/16)
    icon.cooldown:SetHeight(icon:GetHeight() - icon:GetHeight()/16)
    icon.cooldown:ClearAllPoints()
    icon.cooldown:SetPoint("CENTER", icon, "CENTER")
    icon.cooldown:SetAlpha(Gladdy.db.cooldownCooldownAlpha)

    icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), (icon:GetWidth()/2 - 1) * Gladdy.db.cooldownFontScale, "OUTLINE")
    icon.cooldownFont:SetTextColor(Gladdy:SetColor(Gladdy.db.cooldownFontColor))

    icon.border:SetTexture(Gladdy.db.cooldownBorderStyle)
    icon.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.cooldownBorderColor))
end

function Cooldowns:IconsSetPoint(button)
    for i,icon in ipairs(button.spellCooldownFrame.icons) do
        icon:SetParent(button.spellCooldownFrame)
        icon:ClearAllPoints()
        if (Gladdy.db.cooldownXGrowDirection == "LEFT") then
            if (i == 1) then
                icon:SetPoint("LEFT", button.spellCooldownFrame, "LEFT", 0, 0)
            elseif (mod(i-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                if (Gladdy.db.cooldownYGrowDirection == "DOWN") then
                    icon:SetPoint("TOP", button.spellCooldownFrame.icons[i-Gladdy.db.cooldownMaxIconsPerLine], "BOTTOM", 0, -Gladdy.db.cooldownIconPadding)
                else
                    icon:SetPoint("BOTTOM", button.spellCooldownFrame.icons[i-Gladdy.db.cooldownMaxIconsPerLine], "TOP", 0, Gladdy.db.cooldownIconPadding)
                end
            else
                icon:SetPoint("RIGHT", button.spellCooldownFrame.icons[i-1], "LEFT", -Gladdy.db.cooldownIconPadding, 0)
            end
        end
        if (Gladdy.db.cooldownXGrowDirection == "RIGHT") then
            if (i == 1) then
                icon:SetPoint("LEFT", button.spellCooldownFrame, "LEFT", 0, 0)
            elseif (mod(i-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                if (Gladdy.db.cooldownYGrowDirection == "DOWN") then
                    icon:SetPoint("TOP", button.spellCooldownFrame.icons[i-Gladdy.db.cooldownMaxIconsPerLine], "BOTTOM", 0, -Gladdy.db.cooldownIconPadding)
                else
                    icon:SetPoint("BOTTOM", button.spellCooldownFrame.icons[i-Gladdy.db.cooldownMaxIconsPerLine], "TOP", 0, Gladdy.db.cooldownIconPadding)
                end
            else
                icon:SetPoint("LEFT", button.spellCooldownFrame.icons[i-1], "RIGHT", Gladdy.db.cooldownIconPadding, 0)
            end
        end
    end
end

function Cooldowns:UpdateFrameOnce()
    for _,icon in ipairs(self.iconCache) do
        Cooldowns:UpdateIcon(icon)
    end
end

function Cooldowns:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    -- Cooldown frame
    if (Gladdy.db.cooldown) then
        button.spellCooldownFrame:SetHeight(Gladdy.db.cooldownSize)
        button.spellCooldownFrame:SetWidth(1)
        button.spellCooldownFrame:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
        button.spellCooldownFrame:SetFrameLevel(Gladdy.db.cooldownFrameLevel)

        Gladdy:SetPosition(button.spellCooldownFrame, unit, "cooldownXOffset", "cooldownYOffset", Cooldowns:LegacySetPosition(button, unit), Cooldowns)

        if (unit == "arena1") then
            Gladdy:CreateMover(button.spellCooldownFrame,"cooldownXOffset", "cooldownYOffset", L["Cooldown"],
                    {"TOPLEFT", "TOPLEFT"},
                    Gladdy.db.cooldownSize * Gladdy.db.cooldownWidthFactor, Gladdy.db.cooldownSize, 0, 0, "cooldown")
        end
        -- Update each cooldown icon
        for _,icon in pairs(button.spellCooldownFrame.icons) do
            self:UpdateIcon(icon)
        end
        self:IconsSetPoint(button)
        button.spellCooldownFrame:Show()
    else
        button.spellCooldownFrame:Hide()
    end
end

function Cooldowns:ResetUnit(unit)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    for i=#button.spellCooldownFrame.icons,1,-1 do
        self:ClearIcon(button, i)
    end
end

function Cooldowns:ClearIcon(button, index, spellId, icon)
    if index then
        icon = tremove(button.spellCooldownFrame.icons, index)
    else
        for i=#button.spellCooldownFrame.icons,1,-1 do
            if icon then
                if button.spellCooldownFrame.icons[i] == icon then
                    icon = tremove(button.spellCooldownFrame.icons, index)
                end
            end
            if not icon and spellId then
                if button.spellCooldownFrame.icons[i].spellId == spellId then
                    icon = tremove(button.spellCooldownFrame.icons, index)
                end
            end
        end
    end
    icon:ClearAllPoints()
    icon:SetParent(nil)
    icon:Hide()
    icon.spellId = nil
    icon.active = false
    icon.cooldown:Hide()
    icon.cooldownFont:SetText("")
    icon:SetScript("OnUpdate", nil)
    tinsert(self.iconCache, icon)
end

---------------------
-- Test
---------------------

function Cooldowns:Test(unit)
    local button = Gladdy.buttons[unit]
    if Gladdy.db.cooldown then
        button.spellCooldownFrame:Show()
        self:UpdateTestCooldowns(unit)
    else
        button.spellCooldownFrame:Hide()
        self:UpdateTestCooldowns(unit)
    end

end

function Cooldowns:UpdateTestCooldowns(unit)
    local button = Gladdy.buttons[unit]

    if (button.testSpec and button.testSpec == Gladdy.testData[unit].testSpec) then
        self:UpdateCooldowns(button)
        button.spec = nil
        self:DetectSpec(unit, button.testSpec)

        -- use class spells
        for spellId,_ in pairs(Gladdy:GetCooldownList()[button.class]) do
            self:CooldownUsed(unit, button.class, spellId)
        end
        -- use race spells
        for spellId,_ in pairs(Gladdy:GetCooldownList()[button.race]) do
            self:CooldownUsed(unit, button.race, spellId)
        end
    end
end

---------------------
-- Events
---------------------

function Cooldowns:ENEMY_SPOTTED(unit)
    self:UpdateCooldowns(Gladdy.buttons[unit])
end

function Cooldowns:SPEC_DETECTED(unit, spec)
    self:DetectSpec(unit, spec)
end

function Cooldowns:UNIT_DESTROYED(unit)

end

---------------------
-- Cooldown Start/Ready
---------------------

function Cooldowns:CooldownStart(button, spellId, duration, start)
    -- starts timer frame
    if not duration or duration == nil or type(duration) ~= "number" then
        return
    end
    for _,icon in pairs(button.spellCooldownFrame.icons) do
        if (icon.spellId == spellId) then
            icon.active = true
            icon.timeLeft = start and start - GetTime() + duration or duration
            if (not Gladdy.db.cooldownDisableCircle) then icon.cooldown:SetCooldown(start or GetTime(), duration) end
            icon:SetScript("OnUpdate", function(self, elapsed)
                self.timeLeft = self.timeLeft - elapsed
                local timeLeft = ceil(self.timeLeft)
                if timeLeft >= 540 then
                    self.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 3.1 * Gladdy.db.cooldownFontScale, "OUTLINE")
                elseif timeLeft < 540 and timeLeft >= 60 then
                    self.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2.15 * Gladdy.db.cooldownFontScale, "OUTLINE")
                elseif timeLeft < 60 and timeLeft > 0 then
                    self.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2.15 * Gladdy.db.cooldownFontScale, "OUTLINE")
                end
                Gladdy:FormatTimer(self.cooldownFont, self.timeLeft, self.timeLeft < 0)
                if (self.timeLeft <= 0) then
                    Cooldowns:CooldownReady(button, spellId, icon)
                end
                if (self.timeLeft <= 0) then
                    Cooldowns:CooldownReady(button, spellId, icon)
                end
            end)
            --C_VoiceChat.SpeakText(2, GetSpellInfo(spellId), 3, 4, 100)
        end
    end
end

function Cooldowns:CooldownReady(button, spellId, frame)
    if (frame == false) then
        for _,icon in pairs(button.spellCooldownFrame.icons) do
            if (icon.spellId == spellId) then
                icon.active = false
                icon.cooldown:Hide()
                icon.cooldownFont:SetText("")
                icon:SetScript("OnUpdate", nil)
            end
        end
    else
        frame.active = false
        frame.cooldown:Hide()
        frame.cooldownFont:SetText("")
        frame:SetScript("OnUpdate", nil)
    end
end

function Cooldowns:CooldownUsed(unit, unitClass, spellId, expirationTimeInSeconds)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    -- if (self.db.cooldownList[spellId] == false) then return end

    local cooldown = Gladdy:GetCooldownList()[unitClass][spellId]
    local cd = cooldown
    if (type(cooldown) == "table") then
        -- return if the spec doesn't have a cooldown for this spell
        --if (arenaSpecs[unit] ~= nil and cooldown.notSpec ~= nil and arenaSpecs[unit] == cooldown.notSpec) then return end
        if (button.spec ~= nil and cooldown.notSpec ~= nil and button.spec == cooldown.notSpec) then
            return
        end

        -- check if we need to reset other cooldowns because of this spell
        if (cooldown.resetCD ~= nil) then
            for spellID,_ in pairs(cooldown.resetCD) do
                self:CooldownReady(button, spellID, false)
            end
        end

        -- check if there is a special cooldown for the units spec
        --if (arenaSpecs[unit] ~= nil and cooldown[arenaSpecs[unit]] ~= nil) then
        if (button.spec ~= nil and cooldown[button.spec] ~= nil) then
            cd = cooldown[button.spec]
        else
            cd = cooldown.cd
        end

        -- check if there is a shared cooldown with an other spell
        if (cooldown.sharedCD ~= nil) then
            local sharedCD = cooldown.sharedCD.cd and cooldown.sharedCD.cd or cd

            for spellID,_ in pairs(cooldown.sharedCD) do
                if (spellID ~= "cd") then
                    local skip = false
                    for _,icon in pairs(button.spellCooldownFrame.icons) do
                        if (icon.spellId == spellID and icon.active and icon.timeLeft > sharedCD) then
                            skip = true
                            break
                        end
                    end
                    if not skip then
                        self:CooldownStart(button, spellID, sharedCD)
                    end
                end
            end
        end
    end

    if (Gladdy.db.cooldown) then
        -- start cooldown
        self:CooldownStart(button, spellId, cd, expirationTimeInSeconds and (GetTime() + expirationTimeInSeconds - cd) or nil)
    end

    --[[ announcement
    if (self.db.cooldownAnnounce or self.db.cooldownAnnounceList[spellId] or self.db.cooldownAnnounceList[unitClass]) then
       self:SendAnnouncement(string.format(L["COOLDOWN USED: %s (%s) used %s - %s sec. cooldown"], UnitName(unit), UnitClass(unit), spellName, cd), RAID_CLASS_COLORS[UnitClass(unit)], self.db.cooldownAnnounceList[spellId] and self.db.cooldownAnnounceList[spellId] or self.db.announceType)
    end]]

    --[[ sound file
    if (db.cooldownSoundList[spellId] ~= nil and db.cooldownSoundList[spellId] ~= "disabled") then
       PlaySoundFile(LSM:Fetch(LSM.MediaType.SOUND, db.cooldownSoundList[spellId]))
    end  ]]
end

---------------------
-- Detect Spec
---------------------

local function notIn(spec, list)
    for _,v in ipairs(list) do
        if spec == v then
            return false
        end
    end
    return true
end

function Cooldowns:DetectSpec(unit, spec)
    local button = Gladdy.buttons[unit]
    if (not button or not spec or button.spec) then
        return
    end
    if button.class == "PALADIN" and notIn(spec, {L["Holy"], L["Retribution"], L["Protection"]})
            or button.class == "SHAMAN" and notIn(spec, {L["Restoration"], L["Enhancement"], L["Elemental"]})
            or button.class == "ROGUE" and notIn(spec, {L["Subtlety"], L["Assassination"], L["Combat"]})
            or button.class == "WARLOCK" and notIn(spec, {L["Demonology"], L["Destruction"], L["Affliction"]})
            or button.class == "PRIEST" and notIn(spec, {L["Shadow"], L["Discipline"], L["Holy"]})
            or button.class == "MAGE" and notIn(spec, {L["Frost"], L["Fire"], L["Arcane"]})
            or button.class == "DRUID" and notIn(spec, {L["Restoration"], L["Feral"], L["Balance"]})
            or button.class == "HUNTER" and notIn(spec, {L["Beast Mastery"], L["Marksmanship"], L["Survival"]})
            or button.class == "WARRIOR" and notIn(spec, {L["Arms"], L["Protection"], L["Fury"]}) then
        return
    end
    if not button.spec then
        button.spec = spec
        Gladdy:SendMessage("UNIT_SPEC", unit, spec)
        Cooldowns:UpdateCooldowns(button)
    end
end

function Cooldowns:AddCooldown(spellID, value, button)
    -- see if we have shared cooldowns without a cooldown defined
    -- e.g. hunter traps have shared cooldowns, so only display one trap instead all of them
    local sharedCD = false
    if (type(value) == "table" and value.sharedCD ~= nil and value.sharedCD.cd == nil) then
        for spellId, _ in pairs(value.sharedCD) do
            for _,icon in pairs(button.spellCooldownFrame.icons) do
                if (icon.spellId == spellId) then
                    sharedCD = true
                end
            end
        end
    end
    for _,icon in pairs(button.spellCooldownFrame.icons) do
        if (icon and icon.spellId == spellID) then
            sharedCD = true
        end
    end
    if (not sharedCD) then
        local icon = self:CreateIcon()
        icon:Show()
        icon.spellId = spellID
        icon.texture:SetTexture(self.spellTextures[spellID])
        tinsert(button.spellCooldownFrame.icons, icon)
        self:IconsSetPoint(button)
        Gladdy:Debug("Cooldowns:AddCooldown", button.unit, GetSpellInfo(spellID))
    end
end

function Cooldowns:UpdateCooldowns(button)
    local class = button.class
    local race = button.race
    local spec = button.spec
    if not class or not race then
        return
    end

    if spec then
        if class == "PALADIN" and notIn(spec, {L["Holy"], L["Retribution"], L["Protection"]})
                or class == "SHAMAN" and notIn(spec, {L["Restoration"], L["Enhancement"], L["Elemental"]})
                or class == "ROGUE" and notIn(spec, {L["Subtlety"], L["Assassination"], L["Combat"]})
                or class == "WARLOCK" and notIn(spec, {L["Demonology"], L["Destruction"], L["Affliction"]})
                or class == "PRIEST" and notIn(spec, {L["Shadow"], L["Discipline"], L["Holy"]})
                or class == "MAGE" and notIn(spec, {L["Frost"], L["Fire"], L["Arcane"]})
                or class == "DRUID" and notIn(spec, {L["Restoration"], L["Feral"], L["Balance"]})
                or class == "HUNTER" and notIn(spec, {L["Beast Mastery"], L["Marksmanship"], L["Survival"]})
                or class == "WARRIOR" and notIn(spec, {L["Arms"], L["Protection"], L["Fury"]}) then
            return
        end
    end

    for k, v in pairs(Gladdy:GetCooldownList()[class]) do
        if Gladdy.db.cooldownCooldowns[tostring(k)] then
            if (type(v) ~= "table" or (type(v) == "table" and v.spec == nil)) then
                Cooldowns:AddCooldown(k, v, button)
            end
            if (type(v) == "table" and v.spec ~= nil and v.spec == spec) then
                Cooldowns:AddCooldown(k, v, button)
            end
        end
    end
    for k, v in pairs(Gladdy:GetCooldownList()[button.race]) do
        if Gladdy.db.cooldownCooldowns[tostring(k)] then
            if (type(v) ~= "table" or (type(v) == "table" and v.spec == nil)) then
                Cooldowns:AddCooldown(k, v, button)
            end
            if (type(v) == "table" and v.spec ~= nil and v.spec == spec) then
                Cooldowns:AddCooldown(k, v, button)
            end
        end
    end
end

---------------------
-- Options
---------------------

function Cooldowns:GetOptions()
    return {
        headerCooldown = {
            type = "header",
            name = L["Cooldown"],
            order = 2,
        },
        cooldown = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enabled cooldown module"],
            order = 2,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 3,
            args = {
                icon = {
                    type = "group",
                    name = L["Icon"],
                    order = 1,
                    args = {
                        headerIcon = {
                            type = "header",
                            name = L["Icon"],
                            order = 2,
                        },
                        cooldownSize = Gladdy:option({
                            type = "range",
                            name = L["Cooldown size"],
                            desc = L["Size of each cd icon"],
                            order = 4,
                            min = 5,
                            max = 50,
                            width = "full",
                        }),
                        cooldownWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon Width Factor"],
                            desc = L["Stretches the icon"],
                            order = 5,
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            width = "full",
                        }),
                        cooldownIconPadding = Gladdy:option({
                            type = "range",
                            name = L["Icon Padding"],
                            desc = L["Space between Icons"],
                            order = 6,
                            min = 0,
                            max = 10,
                            step = 0.1,
                            width = "full",
                        }),
                    },
                },
                cooldown = {
                    type = "group",
                    name = L["Cooldown"],
                    order = 2,
                    args = {
                        header = {
                            type = "header",
                            name = L["Cooldown"],
                            order = 2,
                        },
                        cooldownDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 8,
                            width = "full",
                        }),
                        cooldownCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 9,
                            width = "full",
                        }),
                        cooldownCooldownNumberAlpha = {
                            type = "range",
                            name = L["Cooldown number alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 10,
                            width = "full",
                            set = function(info, value)
                                Gladdy.db.cooldownFontColor.a = value
                                Gladdy:UpdateFrame()
                            end,
                            get = function(info)
                                return Gladdy.db.cooldownFontColor.a
                            end,
                        },
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
                            order = 2,
                        },
                        cooldownFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        cooldownFontScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the font"],
                            order = 12,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
                            width = "full",
                        }),
                        cooldownFontColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Font color"],
                            desc = L["Color of the text"],
                            order = 13,
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
                            order = 2,
                        },
                        cooldownYGrowDirection = Gladdy:option({
                            type = "select",
                            name = L["Vertical Grow Direction"],
                            desc = L["Vertical Grow Direction of the cooldown icons"],
                            order = 3,
                            values = {
                                ["UP"] = L["Up"],
                                ["DOWN"] = L["Down"],
                            },
                        }),
                        cooldownXGrowDirection = Gladdy:option({
                            type = "select",
                            name = L["Horizontal Grow Direction"],
                            desc = L["Horizontal Grow Direction of the cooldown icons"],
                            order = 4,
                            values = {
                                ["LEFT"] = L["Left"],
                                ["RIGHT"] = L["Right"],
                            },
                        }),
                        cooldownMaxIconsPerLine = Gladdy:option({
                            type = "range",
                            name = L["Max Icons per row"],
                            order = 5,
                            min = 3,
                            max = 14,
                            step = 1,
                            width = "full",
                        }),
                        headerOffset = {
                            type = "header",
                            name = L["Offset"],
                            order = 10,
                        },
                        cooldownXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 11,
                            min = -400,
                            max = 400,
                            step = 0.1,
                            width = "full",
                        }),
                        cooldownYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 12,
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
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Border"],
                            order = 2,
                        },
                        cooldownBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 31,
                            values = Gladdy:GetIconStyles()
                        }),
                        cooldownBorderColor = Gladdy:colorOption({
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
                    order = 6,
                    args = {
                        headerAuraLevel = {
                            type = "header",
                            name = L["Frame Strata and Level"],
                            order = 1,
                        },
                        cooldownFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Frame Strata"],
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        cooldownFrameLevel = Gladdy:option({
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
        cooldowns = {
            type = "group",
            childGroups = "tree",
            name = L["Cooldowns"],
            order = 4,
            args = Cooldowns:GetCooldownOptions(),
        },
    }
end

function Cooldowns:GetCooldownOptions()
    local group = {}

    local p = 1
    for i,class in ipairs(Gladdy.CLASSES) do
        group[class] = {
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE[class],
            order = i,
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS[class],
            args = {}
        }
        local o = 1
        for spellId,cooldown in pairs(Gladdy:GetCooldownList()[class]) do
            group[class].args[tostring(spellId)] = {
                type = "toggle",
                name = select(1, GetSpellInfo(spellId)) .. (type(cooldown) == "table" and cooldown.spec and (" - " .. cooldown.spec) or ""),
                order = o,
                width = "full",
                image = select(3, GetSpellInfo(spellId)),
                get = function()
                    return Gladdy.db.cooldownCooldowns[tostring(spellId)]
                end,
                set = function(_, value)
                    Gladdy.db.cooldownCooldowns[tostring(spellId)] = value
                    Gladdy:UpdateFrame()
                end
            }
            o = o + 1
        end
        p = p + i
    end
    for i,race in ipairs(Gladdy.RACES) do
        group[race] = {
            type = "group",
            name = L[race],
            order = i + p,
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Races",
            iconCoords = RACE_ICON_TCOORDS[upper(race) .. "_FEMALE"],
            args = {}
        }
        local o = 1
        for spellId,cooldown in pairs(Gladdy:GetCooldownList()[race]) do
            group[race].args[tostring(spellId)] = {
                type = "toggle",
                name = select(1, GetSpellInfo(spellId)) .. (type(cooldown) == "table" and cooldown.spec and (" - " .. cooldown.spec) or ""),
                order = o,
                width = "full",
                image = select(3, GetSpellInfo(spellId)),
                get = function()
                    return Gladdy.db.cooldownCooldowns[tostring(spellId)]
                end,
                set = function(_, value)
                    Gladdy.db.cooldownCooldowns[tostring(spellId)] = value
                    Gladdy:UpdateFrame()
                end
            }
            o = o + 1
        end
    end
    return group
end

---------------------------

-- LAGACY HANDLER

---------------------------

function Cooldowns:LegacySetPosition(button, unit)
    if Gladdy.db.newLayout then
        return Gladdy.db.newLayout
    end
    button.spellCooldownFrame:ClearAllPoints()
    local powerBarHeight = Gladdy.db.powerBarEnabled and (Gladdy.db.powerBarHeight + 1) or 0
    local horizontalMargin = (Gladdy.db.highlightInset and 0 or Gladdy.db.highlightBorderSize)

    local offset = 0
    if (Gladdy.db.cooldownXPos == "RIGHT") then
        offset = -(Gladdy.db.cooldownSize * Gladdy.db.cooldownWidthFactor)
    end

    if Gladdy.db.cooldownYPos == "TOP" then
        Gladdy.db.cooldownYGrowDirection = "UP"
        if Gladdy.db.cooldownXPos == "RIGHT" then
            Gladdy.db.cooldownXGrowDirection = "LEFT"
            button.spellCooldownFrame:SetPoint("BOTTOMRIGHT", button.healthBar, "TOPRIGHT", Gladdy.db.cooldownXOffset + offset, horizontalMargin + Gladdy.db.cooldownYOffset)
        else
            Gladdy.db.cooldownXGrowDirection = "RIGHT"
            button.spellCooldownFrame:SetPoint("BOTTOMLEFT", button.healthBar, "TOPLEFT", Gladdy.db.cooldownXOffset + offset, horizontalMargin + Gladdy.db.cooldownYOffset)
        end
    elseif Gladdy.db.cooldownYPos == "BOTTOM" then
        Gladdy.db.cooldownYGrowDirection = "DOWN"
        if Gladdy.db.cooldownXPos == "RIGHT" then
            Gladdy.db.cooldownXGrowDirection = "LEFT"
            button.spellCooldownFrame:SetPoint("TOPRIGHT", button.healthBar, "BOTTOMRIGHT", Gladdy.db.cooldownXOffset + offset, -horizontalMargin + Gladdy.db.cooldownYOffset - powerBarHeight)
        else
            Gladdy.db.cooldownXGrowDirection = "RIGHT"
            button.spellCooldownFrame:SetPoint("TOPLEFT", button.healthBar, "BOTTOMLEFT", Gladdy.db.cooldownXOffset + offset, -horizontalMargin + Gladdy.db.cooldownYOffset - powerBarHeight)
        end
    elseif Gladdy.db.cooldownYPos == "LEFT" then
        Gladdy.db.cooldownYGrowDirection = "DOWN"
        local anchor = Gladdy:GetAnchor(unit, "LEFT")
        if anchor == Gladdy.buttons[unit].healthBar then
            Gladdy.db.cooldownXGrowDirection = "LEFT"
            button.spellCooldownFrame:SetPoint("RIGHT", anchor, "LEFT", -(horizontalMargin + Gladdy.db.padding) + Gladdy.db.cooldownXOffset + offset, Gladdy.db.cooldownYOffset)
        else
            Gladdy.db.cooldownXGrowDirection = "LEFT"
            button.spellCooldownFrame:SetPoint("RIGHT", anchor, "LEFT", -Gladdy.db.padding + Gladdy.db.cooldownXOffset + offset, Gladdy.db.cooldownYOffset)
        end
    elseif Gladdy.db.cooldownYPos == "RIGHT" then
        Gladdy.db.cooldownYGrowDirection = "DOWN"
        local anchor = Gladdy:GetAnchor(unit, "RIGHT")
        if anchor == Gladdy.buttons[unit].healthBar then
            Gladdy.db.cooldownXGrowDirection = "RIGHT"
            button.spellCooldownFrame:SetPoint("LEFT", anchor, "RIGHT", horizontalMargin + Gladdy.db.padding + Gladdy.db.cooldownXOffset + offset, Gladdy.db.cooldownYOffset)
        else
            Gladdy.db.cooldownXGrowDirection = "RIGHT"
            button.spellCooldownFrame:SetPoint("LEFT", anchor, "RIGHT", Gladdy.db.padding + Gladdy.db.cooldownXOffset + offset, Gladdy.db.cooldownYOffset)
        end
    end
    LibStub("AceConfigRegistry-3.0"):NotifyChange("Gladdy")

    return Gladdy.db.newLayout
end