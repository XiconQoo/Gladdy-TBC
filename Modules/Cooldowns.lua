local type, pairs, ipairs, ceil, tonumber, mod, tostring, upper, select, tinsert, tremove = type, pairs, ipairs, ceil, tonumber, mod, tostring, string.upper, select, tinsert, tremove
local tbl_sort = table.sort
local C_Timer = C_Timer
local GetTime = GetTime
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local AURA_TYPE_BUFF = "BUFF"
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local Gladdy = LibStub("Gladdy")
local LCG = LibStub("LibCustomGlow-1.0")
local L = Gladdy.L

local function tableLength(tbl)
    local getN = 0
    for n in pairs(tbl) do
        getN = getN + 1
    end
    return getN
end

local function getDefaultCooldown()
    local cooldowns = {}
    local cooldownsOrder = {}
    for class,spellTable in pairs(Gladdy:GetCooldownList()) do
        if not spellTable.class and not cooldownsOrder[class] then
            cooldownsOrder[class] = {}
        end
        for spellId,val in pairs(spellTable) do
            local spellName = GetSpellInfo(spellId)
            if spellName then
                cooldowns[tostring(spellId)] = (val.enabled == nil and true) or val.enabled
                if type(val) == "table" and val.class then
                    if val.class and not cooldownsOrder[val.class] then
                        cooldownsOrder[val.class] = {}
                    end
                    if not cooldownsOrder[val.class][tostring(spellId)] then
                        cooldownsOrder[val.class][tostring(spellId)] = tableLength(cooldownsOrder[val.class]) + 1
                    end
                else
                    if not cooldownsOrder[class][tostring(spellId)] then
                        cooldownsOrder[class][tostring(spellId)] = tableLength(cooldownsOrder[class]) + 1
                    end
                end
            else
                Gladdy:Debug("ERROR", "spellid does not exist  " .. spellId)
            end
        end
    end
    return cooldowns, cooldownsOrder
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
    cooldownIconGlow = true,
    cooldownIconAnimationActivation = true,
    cooldownIconAnimationReady = true,
    cooldownIconGlowColor = {r = 0.95, g = 0.95, b = 0.32, a = 1},
    cooldownIconZoomed = false,
    cooldownIconDesaturateOnCooldown = false,
    cooldownIconAlphaOnCooldown = 1,
    cooldownWidthFactor = 1,
    cooldownIconPadding = 1,
    cooldownMaxIconsPerLine = 10,
    cooldownBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    cooldownBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    cooldownDisableCircle = false,
    cooldownCooldownAlpha = 1,
    cooldownCooldowns = getDefaultCooldown(),
    cooldownCooldownsOrder = select(2, getDefaultCooldown()),
    cooldownFrameStrata = "MEDIUM",
    cooldownFrameLevel = 3,
    cooldownGroup = false,
    cooldownGroupDirection = "DOWN",
    cooldownGroupMode = "ARENA", -- ARENA or ORDER
})

function Cooldowns:Initialize()
    self.frames = {}
    self.spellTextures = {}
    self.spellIdToCanonical = {} -- Reverse lookup: spellID -> canonical spellID
    self.iconCache = {}
    for _,spellTable in pairs(Gladdy:GetCooldownList()) do
        for spellId,val in pairs(spellTable) do
            local spellName, _, texture = GetSpellInfo(spellId)
            if type(val) == "table" then
                if val.icon then
                    texture = val.icon
                end
                if val.altName then
                    spellName = val.altName
                end
                -- Build reverse lookup: map all spellIDs to canonical spellId
                if val.spellIDs then
                    for _,altSpellId in ipairs(val.spellIDs) do
                        self.spellIdToCanonical[altSpellId] = spellId
                    end
                end
            end
            if spellName then
                self.spellTextures[spellId] = texture
                self.spellIdToCanonical[spellId] = spellId
            else
                Gladdy:Debug("ERROR", "spellid does not exist  " .. spellId)
            end
        end
    end
    self:LoadModule()
end

function Cooldowns:LoadModule()
    if Gladdy.db.cooldown then
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_SPEC")
        self:RegisterMessage("UNIT_SPEC_PREPARATION")
        self:RegisterMessage("UNIT_DEATH")
        self:RegisterMessage("UNIT_DESTROYED")
        self:RegisterMessage("AURA_GAIN")
        self:RegisterMessage("DISPEL_USED")
    else
        self:UnregisterAllMessages()
    end
end

---------------------
-- Frame
---------------------

function Cooldowns:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    local spellCooldownFrame = CreateFrame("Frame", nil, button)
    spellCooldownFrame:EnableMouse(false)
    spellCooldownFrame:SetMovable(true)
    spellCooldownFrame:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
    spellCooldownFrame:SetFrameLevel(Gladdy.db.cooldownFrameLevel)
    spellCooldownFrame.icons = {}
    button.spellCooldownFrame = spellCooldownFrame
    self.frames[unit] = spellCooldownFrame
end

function Cooldowns:CreateIcon()
    local icon
    if (#self.iconCache > 0) then
        icon = tremove(self.iconCache, #self.iconCache)
    else
        icon = CreateFrame("Frame")
        icon:EnableMouse(false)

        icon.texture = icon:CreateTexture(nil, "BACKGROUND")
        icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
        icon.texture.masked = true
        icon.texture:SetAllPoints(icon)

        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true
        icon.cooldown:SetReverse(false)
        icon.cooldown:SetHideCountdownNumbers(true)

        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetAllPoints(icon)

        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        icon.border:SetAllPoints(icon)

        icon.cooldownFont = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.cooldownFont:SetAllPoints(icon)

        icon.charges = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.charges:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 2)

        icon.glow = CreateFrame("Frame", nil, icon)
        icon.glow:SetAllPoints(icon)


        --- Activation and Flash textures (hidden by default)
        icon.activationTexture = icon:CreateTexture(nil, "OVERLAY")
        icon.activationTexture:SetAllPoints(icon)
        if icon.activationTexture.SetAtlas then
            icon.activationTexture:SetAtlas("bags-innerglow", false)
        else
            icon.activationTexture:SetTexture("Interface\\Buttons\\CheckButtonHilight")
        end
        icon.activationTexture:SetBlendMode("ADD")
        icon.activationTexture:SetAlpha(0)
        icon.activationTexture:Hide()

        icon.flash = icon:CreateTexture(nil, "OVERLAY")
        icon.flash:SetAllPoints(icon)
        if icon.flash.SetAtlas then
            icon.flash:SetAtlas("bags-glow-flash", false)
        else
            icon.flash:SetTexture("Interface\\Buttons\\WHITE8x8")
        end
        icon.flash:SetBlendMode("ADD")
        icon.flash:SetAlpha(0)
        icon.flash:Hide()

        --- Activation animation group (Alpha)
        icon.ActivationAnimation = icon:CreateAnimationGroup()
        icon.ActivationAnimation:SetToFinalAlpha(true)
        icon.ActivationAnimation:SetScript("OnPlay", function(self)
            local i = self:GetParent()
            i.activationTexture:SetAlpha(1)
            i.activationTexture:Show()
        end)
        icon.ActivationAnimation:SetScript("OnFinished", function(self)
            local i = self:GetParent()
            i.activationTexture:Hide()
            i.activationTexture:SetAlpha(0)
        end)
        do
            local a1 = icon.ActivationAnimation:CreateAnimation("Alpha")
            a1:SetTarget(icon.activationTexture)
            a1:SetSmoothing("NONE")
            a1:SetOrder(1)
            a1:SetFromAlpha(0.8)
            a1:SetToAlpha(1)
            a1:SetDuration(0.2)

            local a2 = icon.ActivationAnimation:CreateAnimation("Alpha")
            a2:SetTarget(icon.activationTexture)
            a2:SetSmoothing("NONE")
            a2:SetOrder(2)
            a2:SetFromAlpha(1)
            a2:SetToAlpha(1)
            a2:SetDuration(0.4)

            local a3 = icon.ActivationAnimation:CreateAnimation("Alpha")
            a3:SetTarget(icon.activationTexture)
            a3:SetSmoothing("NONE")
            a3:SetOrder(3)
            a3:SetFromAlpha(1)
            a3:SetToAlpha(0)
            a3:SetDuration(0.6)
        end

        --- Flash animation group (quick flash fade out)
        icon.FlashAnimation = icon:CreateAnimationGroup()
        icon.FlashAnimation:SetToFinalAlpha(true)
        icon.FlashAnimation:SetScript("OnPlay", function(self)
            local i = self:GetParent()
            i.flash:SetAlpha(1)
            i.flash:Show()
        end)
        icon.FlashAnimation:SetScript("OnFinished", function(self)
            local i = self:GetParent()
            i.flash:Hide()
            i.flash:SetAlpha(0)
        end)
        do
            local a1 = icon.FlashAnimation:CreateAnimation("Alpha")
            a1:SetTarget(icon.flash)
            a1:SetSmoothing("NONE")
            a1:SetOrder(1)
            a1:SetFromAlpha(0.8)
            a1:SetToAlpha(1)
            a1:SetDuration(0.2)

            local a2 = icon.FlashAnimation:CreateAnimation("Alpha")
            a2:SetTarget(icon.flash)
            a2:SetSmoothing("NONE")
            a2:SetOrder(2)
            a2:SetFromAlpha(1)
            a2:SetToAlpha(1)
            a2:SetDuration(0.4)

            local a3 = icon.FlashAnimation:CreateAnimation("Alpha")
            a3:SetTarget(icon.flash)
            a3:SetSmoothing("NONE")
            a3:SetOrder(3)
            a3:SetFromAlpha(1)
            a3:SetToAlpha(0)
            a3:SetDuration(0.6)
        end

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
    icon.glow:SetFrameStrata(Gladdy.db.cooldownFrameStrata)
    icon.glow:SetFrameLevel(Gladdy.db.cooldownFrameLevel + 3)

    icon:SetHeight(Gladdy.db.cooldownSize)
    icon:SetWidth(Gladdy.db.cooldownSize * Gladdy.db.cooldownWidthFactor)
    icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2 * Gladdy.db.cooldownFontScale, "OUTLINE")
    icon.cooldownFont:SetTextColor(Gladdy:SetColor(Gladdy.db.cooldownFontColor))

    if Gladdy.db.cooldownIconZoomed then
        icon.cooldown:SetWidth(icon:GetWidth())
        icon.cooldown:SetHeight(icon:GetHeight())
    else
        icon.cooldown:SetWidth(icon:GetWidth() - icon:GetWidth()/16)
        icon.cooldown:SetHeight(icon:GetHeight() - icon:GetHeight()/16)
    end
    icon.cooldown:ClearAllPoints()
    icon.cooldown:SetPoint("CENTER", icon, "CENTER")
    icon.cooldown:SetAlpha(Gladdy.db.cooldownCooldownAlpha)

    if (Gladdy.db.cooldownDisableCircle) then icon.cooldown:SetAlpha(0) end

    icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), (icon:GetWidth()/2 - 1) * Gladdy.db.cooldownFontScale, "OUTLINE")
    icon.cooldownFont:SetTextColor(Gladdy:SetColor(Gladdy.db.cooldownFontColor))

    icon.charges:SetFont(Gladdy:SMFetch("font", "cooldownFont"), (icon:GetWidth()/2 - 1) * Gladdy.db.cooldownFontScale, "OUTLINE")
    icon.charges:SetTextColor(Gladdy:SetColor(Gladdy.db.cooldownFontColor))

    icon.border:SetTexture(Gladdy.db.cooldownBorderStyle)
    icon.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.cooldownBorderColor))

    if Gladdy.db.cooldownIconZoomed then
        if icon.texture.masked then
            icon.texture:SetMask("")
            icon.texture:SetTexCoord(0.1,0.9,0.1,0.9)
            icon.texture.masked = nil
        end
    else
        if not icon.texture.masked then
            icon.texture:SetMask("")
            icon.texture:SetTexCoord(0,1,0,1)
            icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
            icon.texture.masked = true
        end
    end
    if Gladdy.db.cooldownIconDesaturateOnCooldown and icon.active then
        icon.texture:SetDesaturated(true)
    else
        icon.texture:SetDesaturated(false)
    end
    if Gladdy.db.cooldownIconAlphaOnCooldown < 1 and icon.active then
        icon.texture:SetAlpha(Gladdy.db.cooldownIconAlphaOnCooldown)
    else
        icon.texture:SetAlpha(1)
    end
    if icon.timer and not icon.timer:IsCancelled() then
        LCG.PixelGlow_Start(icon.glow, Gladdy:ColorAsArray(Gladdy.db.cooldownIconGlowColor), 12, 0.15, nil, 2)
    end

    icon.cooldown.noCooldownCount = not Gladdy.db.useOmnicc
    if Gladdy.db.useOmnicc then
        icon.cooldownFont:Hide()
    else
        icon.cooldownFont:Show()
    end
end

function Cooldowns:IconsSetPoint(button)
    if Gladdy.db.cooldownGroup then
        self:LayoutGroupedIcons()
        return
    end
    local orderedIcons = {}
    for _,icon in pairs(button.spellCooldownFrame.icons) do
        tinsert(orderedIcons, icon)
    end
    tbl_sort(orderedIcons, function(a, b)
        return Gladdy.db.cooldownCooldownsOrder[button.class][tostring(a.spellId)] < Gladdy.db.cooldownCooldownsOrder[button.class][tostring(b.spellId)]
    end)

    for i,icon in ipairs(orderedIcons) do
        icon:SetParent(button.spellCooldownFrame)
        icon:ClearAllPoints()
        if (Gladdy.db.cooldownXGrowDirection == "LEFT") then
            if (i == 1) then
                icon:SetPoint("LEFT", button.spellCooldownFrame, "LEFT", 0, 0)
            elseif (mod(i-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                if (Gladdy.db.cooldownYGrowDirection == "DOWN") then
                    icon:SetPoint("TOP", orderedIcons[i-Gladdy.db.cooldownMaxIconsPerLine], "BOTTOM", 0, -Gladdy.db.cooldownIconPadding)
                else
                    icon:SetPoint("BOTTOM", orderedIcons[i-Gladdy.db.cooldownMaxIconsPerLine], "TOP", 0, Gladdy.db.cooldownIconPadding)
                end
            else
                icon:SetPoint("RIGHT", orderedIcons[i-1], "LEFT", -Gladdy.db.cooldownIconPadding, 0)
            end
        end
        if (Gladdy.db.cooldownXGrowDirection == "RIGHT") then
            if (i == 1) then
                icon:SetPoint("LEFT", button.spellCooldownFrame, "LEFT", 0, 0)
            elseif (mod(i-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                if (Gladdy.db.cooldownYGrowDirection == "DOWN") then
                    icon:SetPoint("TOP", orderedIcons[i-Gladdy.db.cooldownMaxIconsPerLine], "BOTTOM", 0, -Gladdy.db.cooldownIconPadding)
                else
                    icon:SetPoint("BOTTOM", orderedIcons[i-Gladdy.db.cooldownMaxIconsPerLine], "TOP", 0, Gladdy.db.cooldownIconPadding)
                end
            else
                icon:SetPoint("LEFT", orderedIcons[i-1], "RIGHT", Gladdy.db.cooldownIconPadding, 0)
            end
        end
    end
end

function Cooldowns:LayoutGroupedIcons()
    local anchorButton = Gladdy.buttons["arena1"]
    if not anchorButton then return end
    local anchorFrame = anchorButton.spellCooldownFrame

    local allIcons = {}
    -- ensure all unit frames are visible and icons are attached for layout source
    for i=1, Gladdy.curBracket do
        local unit = "arena" .. i
        local b = Gladdy.buttons[unit]
        if b and b.spellCooldownFrame then
            b.spellCooldownFrame:Show()
        end
    end
    local units = {}
    for i=1, Gladdy.curBracket do
        local unit = "arena" .. i
        if Gladdy.buttons[unit] and Gladdy.buttons[unit].spellCooldownFrame then
            tinsert(units, unit)
        end
    end

    if Gladdy.db.cooldownGroupMode == "ORDER" then
        -- Interleave by order index across all arenas
        local perUnits = {}
        local maxLen = 0
        for _,unit in ipairs(units) do
            local b = Gladdy.buttons[unit]
            local perUnit = {}
            if b and b.spellCooldownFrame and b.spellCooldownFrame.icons then
                for _,icon in pairs(b.spellCooldownFrame.icons) do
                    tinsert(perUnit, icon)
                end
                tbl_sort(perUnit, function(a, other)
                    local orderTbl = Gladdy.db.cooldownCooldownsOrder[b.class]
                    local ao = orderTbl and orderTbl[tostring(a.spellId)] or 9999
                    local bo = orderTbl and orderTbl[tostring(other.spellId)] or 9999
                    return ao < bo
                end)
            end
            perUnits[unit] = perUnit
            if #perUnit > maxLen then maxLen = #perUnit end
        end
        for idx=1, maxLen do
            for _,unit in ipairs(units) do
                local icon = perUnits[unit][idx]
                if icon then
                    tinsert(allIcons, icon)
                end
            end
        end
    else
        -- ARENA mode: concatenate all icons by arena sequentially
        for _,unit in ipairs(units) do
            local b = Gladdy.buttons[unit]
            if b and b.spellCooldownFrame and b.spellCooldownFrame.icons then
                local perUnit = {}
                for _,icon in pairs(b.spellCooldownFrame.icons) do
                    tinsert(perUnit, icon)
                end
                tbl_sort(perUnit, function(a, other)
                    local orderTbl = Gladdy.db.cooldownCooldownsOrder[b.class]
                    local ao = orderTbl and orderTbl[tostring(a.spellId)] or 9999
                    local bo = orderTbl and orderTbl[tostring(other.spellId)] or 9999
                    return ao < bo
                end)
                for _,icon in ipairs(perUnit) do
                    tinsert(allIcons, icon)
                end
            end
        end
    end

    local cols = Gladdy.db.cooldownMaxIconsPerLine
    local xPad = Gladdy.db.cooldownIconPadding
    local yPad = Gladdy.db.cooldownIconPadding

    for idx,icon in ipairs(allIcons) do
        -- reparent once to anchor cluster
        if icon:GetParent() ~= anchorFrame then
            icon:SetParent(anchorFrame)
        end
        icon:ClearAllPoints()
        local row = math.floor((idx-1) / cols)
        local col = (idx-1) % cols
        if Gladdy.db.cooldownXGrowDirection == "LEFT" then
            if col == 0 then
                if row == 0 then
                    icon:SetPoint("LEFT", anchorFrame, "LEFT", 0, 0)
                else
                    icon:SetPoint(Gladdy.db.cooldownYGrowDirection == "DOWN" and "TOP" or "BOTTOM", allIcons[idx - cols], Gladdy.db.cooldownYGrowDirection == "DOWN" and "BOTTOM" or "TOP", 0, Gladdy.db.cooldownYGrowDirection == "DOWN" and -yPad or yPad)
                end
            else
                icon:SetPoint("RIGHT", allIcons[idx-1], "LEFT", -xPad, 0)
            end
        else
            if col == 0 then
                if row == 0 then
                    icon:SetPoint("LEFT", anchorFrame, "LEFT", 0, 0)
                else
                    icon:SetPoint(Gladdy.db.cooldownYGrowDirection == "DOWN" and "TOP" or "BOTTOM", allIcons[idx - cols], Gladdy.db.cooldownYGrowDirection == "DOWN" and "BOTTOM" or "TOP", 0, Gladdy.db.cooldownYGrowDirection == "DOWN" and -yPad or yPad)
                end
            else
                icon:SetPoint("LEFT", allIcons[idx-1], "RIGHT", xPad, 0)
            end
        end
    end
end

function Cooldowns:UpdateFrameOnce()
    for _,icon in ipairs(self.iconCache) do
        self:UpdateIcon(icon)
    end
    self:UpdateCooldownOptions()
end

function Cooldowns:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    local testAgain = false
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
            testAgain = icon.texture.masked
            self:UpdateIcon(icon)
            if icon.texture.masked ~= testAgain then
                testAgain = true
            else
                testAgain = false
            end
        end
        self:IconsSetPoint(button)
        button.spellCooldownFrame:Show()
    else
        button.spellCooldownFrame:Hide()
    end
    if testAgain and Gladdy.frame.testing then
        Cooldowns:ResetUnit(unit)
        Cooldowns:ENEMY_SPOTTED(unit)
        Cooldowns:UNIT_SPEC(unit)
        Cooldowns:Test(unit, true)
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
                    break
                end
            end
            if not icon and spellId then
                if button.spellCooldownFrame.icons[i].spellId == spellId then
                    icon = tremove(button.spellCooldownFrame.icons, index)
                    break
                end
            end
        end
    end
    if not icon then
        return
    end
    icon:Show()
    LCG.PixelGlow_Stop(icon.glow)
    if icon.timer then
        icon.timer:Cancel()
    end
    icon:ClearAllPoints()
    icon:SetParent(nil)
    icon:Hide()
    icon.spellId = nil
    icon.active = false
    icon.cooldown:Hide()
    icon.cooldownFont:SetText("")
    icon.charges:SetText("")
    icon.rechargeEndTimes = nil
    icon:SetScript("OnUpdate", nil)
    tinsert(self.iconCache, icon)
end

---------------------
-- Test
---------------------

-- /run for k,v in pairs(LibStub("Gladdy").buttons["arena2"].spellCooldownFrame.icons) do print(v.spellId) end

-- /run LibStub("Gladdy").modules["Cooldowns"]:AURA_GAIN(_, AURA_TYPE_BUFF, 22812, "Barkskin", _, 20, _, _, _, _, "arena1", true)
-- /run LibStub("Gladdy").modules["Cooldowns"]:AURA_FADE("arena1", 22812)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 1953)

-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 45438)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 120)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 10160)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 31661)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 122)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 11958)

-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 116011)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena2", "MAGE", 102051)
-- /run LibStub("Gladdy").modules["Cooldowns"]:CooldownUsed("arena1", "DRUID", 33831)
-- /run local G=LibStub("Gladdy") G.buttons["arena2"].spellCooldownFrame.icons modules["Cooldowns"]:UpdateTestCooldowns("arena2")
function Cooldowns:Test(unit, showTalents)
    if Gladdy.frame.testing and Gladdy.buttons[unit] then
        self:ResetUnit(unit)
        self:UpdateCooldowns(Gladdy.buttons[unit])
        self:UpdateTestCooldowns(unit, showTalents == nil or showTalents)
    end
    Cooldowns:AURA_GAIN(_, AURA_TYPE_BUFF, 22812, "Barkskin", _, 20, _, _, _, _, unit, true)
end

function Cooldowns:UpdateTestCooldowns(unit, showTalents)
    local button = Gladdy.buttons[unit]
    if not button or not button.class then
        return
    end
    local orderedIcons = {}

    for _,icon in pairs(button.spellCooldownFrame.icons) do
        tinsert(orderedIcons, icon)
    end
    tbl_sort(orderedIcons, function(a, b)
        return Gladdy.db.cooldownCooldownsOrder[button.class][tostring(a.spellId)] < Gladdy.db.cooldownCooldownsOrder[button.class][tostring(b.spellId)]
    end)

    for _,icon in ipairs(orderedIcons) do
        if icon.timer then
            icon.timer:Cancel()
        end
    end
    local talents = {}
    for spellID,cooldown in pairs(Gladdy:GetCooldownList()[button.class]) do
        if Gladdy.db.cooldownCooldowns[tostring(spellID)] then
            if cooldown.talent then
                if not talents[cooldown.talent] and showTalents then
                    self:CooldownUsed(unit, button.class, spellID)
                    talents[cooldown.talent] = true
                end
            else
                self:CooldownUsed(unit, button.class, spellID)
            end
        end
    end
end

---------------------
-- Events
---------------------

function Cooldowns:ENEMY_SPOTTED(unit)
    if (not Gladdy.buttons[unit]) then
        return
    end
    self:UpdateCooldowns(Gladdy.buttons[unit])
end

function Cooldowns:UNIT_SPEC(unit)
    if (not Gladdy.buttons[unit]) then
        return
    end
    self:UpdateCooldowns(Gladdy.buttons[unit])
end

function Cooldowns:UNIT_SPEC_PREPARATION(unit, spec)
    self:UNIT_SPEC(unit)
end

function Cooldowns:DISPEL_USED(unit, spellId)
    local button = Gladdy.buttons[unit]
    if not button or not button.class then
        return
    end
    if Gladdy.db.cooldownCooldowns[tostring(spellId)] then
        self:CooldownUsed(unit, button.class, spellId, nil)
    end
end

function Cooldowns:UNIT_DESTROYED(unit)
    self:ResetUnit(unit)
end

function Cooldowns:AURA_GAIN(_, auraType, spellID, spellName, _, duration, _, _, _, _, unitCaster, test)
    local arenaUnit = test and unitCaster or Gladdy:GetArenaUnit(unitCaster, true)
    if not Gladdy.db.cooldownIconGlow or not arenaUnit or not Gladdy.buttons[arenaUnit] or auraType ~= AURA_TYPE_BUFF or spellID == 26889 then
        return
    end
    local cooldownFrame = Gladdy.buttons[arenaUnit].spellCooldownFrame

    -- Use canonical spellID for consistency
    local spellId = Cooldowns:GetCanonicalSpellID(spellID)

    for _,icon in pairs(cooldownFrame.icons) do
        if (icon.spellId == spellId) then
            Gladdy:Debug("INFO", "Cooldowns:AURA_GAIN", "PixelGlow_Start", spellID)
            LCG.PixelGlow_Start(icon.glow, Gladdy:ColorAsArray(Gladdy.db.cooldownIconGlowColor), 12, 0.15, nil, 2)
            if icon.timer then
                icon.timer:Cancel()
            end
            icon.timer = C_Timer.NewTimer(duration, function()
                LCG.PixelGlow_Stop(icon.glow)
                icon.timer:Cancel()
            end)
        end
    end
end

function Cooldowns:AURA_FADE(unit, spellID, spellName)
    if not Gladdy.buttons[unit] or Gladdy.buttons[unit].stealthed then
        return
    end
    -- Use canonical spellID for consistency
    local spellId = Cooldowns:GetCanonicalSpellID(spellID)
    local cooldownFrame = Gladdy.buttons[unit].spellCooldownFrame
    for _,icon in pairs(cooldownFrame.icons) do
        if (icon.spellId == spellId) then
            Gladdy:Debug("INFO", "Cooldowns:AURA_FADE", "LCG.ButtonGlow_Stop")
            if icon.timer then
                icon.timer:Cancel()
            end
            LCG.PixelGlow_Stop(icon.glow)
        end
    end
end

---------------------
-- Helper Functions
---------------------

function Cooldowns:GetCanonicalSpellID(spellID)
    return self.spellIdToCanonical[spellID] or spellID
end

---------------------
-- Cooldown Start/Ready
---------------------

function Cooldowns:CooldownStart(button, spellId, duration, start)
    if not duration or duration == nil or type(duration) ~= "number" then
        return
    end
    local cooldown = Gladdy:GetCooldownList()[button.class][spellId]
    if type(cooldown) == "table" then
        if (button.spec ~= nil and cooldown[button.spec] ~= nil) then
            cooldown = cooldown[button.spec]
        else
            cooldown = cooldown.cd
        end
    end
    for _,icon in pairs(button.spellCooldownFrame.icons) do
        if (icon.spellId == spellId) then
            -- brief activation on cooldown start
            if icon.ActivationAnimation and Gladdy.db.cooldownIconAnimationActivation then
                if icon.ActivationAnimation:IsPlaying() then icon.ActivationAnimation:Stop() end
                icon.ActivationAnimation:Play()
            end
            -- Charge-style cooldown handling
            if icon.maxCharges then
                -- dynamic chargeMod: if we detect a second use while on cooldown and a modifier exists, raise max charges
                local cdEntry = Gladdy:GetCooldownList()[button.class][spellId]
                if type(cdEntry) == "table" and cdEntry.chargeMod and (icon.active or (icon.rechargeEndTimes and #icon.rechargeEndTimes > 0)) and (not icon.maxCharges or icon.maxCharges < cdEntry.chargeMod) then
                    icon.maxCharges = cdEntry.chargeMod
                end

                icon.rechargeEndTimes = icon.rechargeEndTimes or {}
                local now = GetTime()
                local endTime = (start and start or now) + duration
                tinsert(icon.rechargeEndTimes, endTime)
                tbl_sort(icon.rechargeEndTimes, function(a, b) return a < b end)

                icon.active = #icon.rechargeEndTimes > 0
                local chargesAvailable = (icon.maxCharges or 0) - #icon.rechargeEndTimes
                if chargesAvailable < 0 then chargesAvailable = 0 end
                icon.charges:SetText((icon.maxCharges and icon.maxCharges > 1) and tostring(chargesAvailable) or "")

                if (not Gladdy.db.cooldownDisableCircle) then
                    local nextReady = icon.rechargeEndTimes[1]
                    icon.cooldown:SetCooldown(now, nextReady - now)
                end
                if Gladdy.db.cooldownIconDesaturateOnCooldown then
                    icon.texture:SetDesaturated(true)
                end
                if Gladdy.db.cooldownIconAlphaOnCooldown < 1 then
                    icon.texture:SetAlpha(Gladdy.db.cooldownIconAlphaOnCooldown)
                end

                icon:SetScript("OnUpdate", function(self, elapsed)
                    local current = GetTime()
                    if self.rechargeEndTimes then
                        local changed = false
                        -- remove finished recharges
                        while #self.rechargeEndTimes > 0 and self.rechargeEndTimes[1] <= current do
                            tremove(self.rechargeEndTimes, 1)
                            changed = true
                        end
                        local remaining = #self.rechargeEndTimes
                        local available = (self.maxCharges or 0) - remaining
                        if available < 0 then available = 0 end
                        self.charges:SetText((self.maxCharges and self.maxCharges > 1) and tostring(available) or "")

                        if remaining <= 0 then
                            Cooldowns:CooldownReady(button, spellId, self)
                            return
                        end

                        if changed and (not Gladdy.db.cooldownDisableCircle) then
                            local nextReady = self.rechargeEndTimes[1]
                            self.cooldown:SetCooldown(current, nextReady - current)
                        end

                        if not Gladdy.db.useOmnicc then
                            Gladdy:FormatTimer(self.cooldownFont, self.rechargeEndTimes[1] - current, (self.rechargeEndTimes[1] - current) < 0)
                        else
                            self.cooldownFont:SetText("")
                        end
                    end
                end)
            else
                -- Single-charge (normal) cooldown handling
                if not start and icon.active and icon.timeLeft > cooldown/2 then
                    return
                end
                icon.active = true
                icon.timeLeft = (start and start - GetTime() + duration) or duration
                if (not Gladdy.db.cooldownDisableCircle) then icon.cooldown:SetCooldown(start or GetTime(), duration) end
                if Gladdy.db.cooldownIconDesaturateOnCooldown then
                    icon.texture:SetDesaturated(true)
                end
                if Gladdy.db.cooldownIconAlphaOnCooldown < 1 then
                    icon.texture:SetAlpha(Gladdy.db.cooldownIconAlphaOnCooldown)
                end
                icon:SetScript("OnUpdate", function(self, elapsed)
                    self.timeLeft = self.timeLeft - elapsed
                    if not Gladdy.db.useOmnicc then
                        Gladdy:FormatTimer(self.cooldownFont, self.timeLeft, self.timeLeft < 0)
                    else
                        self.cooldownFont:SetText("")
                    end
                    if (self.timeLeft <= 0) then
                        Cooldowns:CooldownReady(button, spellId, icon)
                    end
                end)
            end
            break
            --C_VoiceChat.SpeakText(2, GetSpellInfo(spellId), 3, 4, 100)
        end
    end
end

local function resetIcon(icon)
    if Gladdy.db.cooldownIconDesaturateOnCooldown then
        icon.texture:SetDesaturated(false)
    end
    if Gladdy.db.cooldownIconAlphaOnCooldown < 1 then
        icon.texture:SetAlpha(1)
    end
    icon.active = false
    icon.cooldown:Hide()
    icon.cooldownFont:SetText("")
    if icon.rechargeEndTimes then
        icon.rechargeEndTimes = {}
    end
    if icon.maxCharges then
        icon.charges:SetText((icon.maxCharges and icon.maxCharges > 1) and tostring(icon.maxCharges) or "")
    end
    --if icon.FlashAnimation and icon.FlashAnimation:IsPlaying() then icon.FlashAnimation:Stop() end
    --if icon.ActivationAnimation and icon.ActivationAnimation:IsPlaying() then icon.ActivationAnimation:Stop() end
    --if icon.activationTexture then icon.activationTexture:SetAlpha(0); icon.activationTexture:Hide() end
    --if icon.flash then icon.flash:SetAlpha(0); icon.flash:Hide() end
    icon:SetScript("OnUpdate", nil)
    if icon.timer then
        icon.timer:Cancel()
    end
    LCG.PixelGlow_Stop(icon.glow)
end

function Cooldowns:CooldownReady(button, spellId, frame)
    if (frame == false) then
        for _,icon in pairs(button.spellCooldownFrame.icons) do
            if (icon.spellId == spellId) then
                if icon.FlashAnimation and Gladdy.db.cooldownIconAnimationReady then
                    if icon.FlashAnimation:IsPlaying() then icon.FlashAnimation:Stop() end
                    icon.FlashAnimation:Play()
                end
                resetIcon(icon)
            end
        end
    else
        if frame and frame.FlashAnimation and Gladdy.db.cooldownIconAnimationReady then
            if frame.FlashAnimation:IsPlaying() then frame.FlashAnimation:Stop() end
            frame.FlashAnimation:Play()
        end
        resetIcon(frame)
    end
end

function Cooldowns:CooldownUsed(unit, unitClass, spellID, expirationTimeInSeconds)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end

    -- Always react to used spells (even if disabled in options) so replacements and talents work on use
    -- Use canonical spellID for consistency
    local spellId = Cooldowns:GetCanonicalSpellID(spellID)

    local cooldown = Gladdy:GetCooldownList()[unitClass][spellId]
    local cd = cooldown
    if (type(cooldown) == "table") then
        -- check if enabled
        -- check for cooldown.spec and compare with button.spec
        -- check if we need to reset other cooldowns because of this spell
        -- check if there is a special cooldown for the units spec
        -- check if there is a shared cooldown with an other spell
        -- check if talent row
        -- check if there is charges
        -- start cooldown

        --[[
                {
                    cd = 60,
                    resetCD = {[1499] = true, [9] = true},
                    sharedCD = {[1499] = true, [9] = true},
                    spec = L["Affliction"],
                    talent = 1,
                    charges = 2,
                    replaces = 12354,
                    L["Affliction"] = 45,
                    chargeMod = 3,
                    enabled = nil
                 }
                - cd = number
                - sharedCD = table of ids or nil
                - resetCD = table of ids or nil
                - spec = table or str or nil
                - notSpec = str
                - talent = number or nil -- represents row .. all talents in one row can only appear once
                - charges = number or nil -- need to show charges and track cd of x charges
                - replaces = spellid or nil -- replaces the spellid cd
                - e.g L["Affliction"] =  number or nil -- is cd of a specific spec
                - enabled = boolean or nil -- should the spell be enabled by default, when nil it implies it is enabled
                - chargeMod = number or nil -- a cd with possible charges. Will initially show with 1 stack, updated to 2 stacks if used when cd has not elapsed
        ]]

        if (cooldown.spec and button.spec) then
            if type(cooldown.spec) == "table" then
                local found
                for _,spec in ipairs(cooldown.spec) do
                    if button.spec == spec then
                        found = true
                    end
                end
                if not found then
                    return
                end
            else
                if cooldown.spec ~= button.spec then
                    return
                end
            end
        end


        -- return if the spec doesn't have a cooldown for this spell
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
        if (button.spec ~= nil and cooldown[button.spec] ~= nil) then
            cd = cooldown[button.spec]
        else
            cd = cooldown.cd
        end

        -- ensure icon exists for this spell (talents may not be pre-populated)
        local hasIcon = false
        for _,icon in pairs(button.spellCooldownFrame.icons) do
            if (icon.spellId == spellId) then
                hasIcon = true
                break
            end
        end
        if not hasIcon then
            -- if this spell replaces another, remove the replaced icon first to avoid ordering glitches
            if cooldown.replaces then
                self:ClearIcon(button, nil, cooldown.replaces)
            end
            if Gladdy.db.cooldownCooldowns[tostring(spellId)] then
                self:AddCooldown(spellId, cooldown, button)
            end
            self:IconsSetPoint(button)
        end

        -- enforce talent row exclusivity dynamically: remove any other talent from the same row
        if cooldown.talent then
            for i = #button.spellCooldownFrame.icons, 1, -1 do
                local icon = button.spellCooldownFrame.icons[i]
                if icon.spellId ~= spellId then
                    local other = Gladdy:GetCooldownList()[unitClass][icon.spellId]
                    if type(other) == "table" and other.talent and other.talent == cooldown.talent then
                        self:ClearIcon(button, nil, nil, icon)
                    end
                end
            end
            self:IconsSetPoint(button)
        end

        -- handle replacements: remove the base spell icon if this spell replaces another
        if cooldown.replaces then
            self:ClearIcon(button, nil, cooldown.replaces)
            self:IconsSetPoint(button)
        end

        -- check if there is a shared cooldown with another spell
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
                        -- ensure shared cooldown icon exists as well
                        local sharedHasIcon = false
                        for _,icon in pairs(button.spellCooldownFrame.icons) do
                            if (icon.spellId == spellID) then
                                sharedHasIcon = true
                                break
                            end
                        end
                        if not sharedHasIcon then
                            local value = Gladdy:GetCooldownList()[unitClass][spellID]
                            if value and Gladdy.db.cooldownCooldowns[tostring(spellID)] then
                                self:AddCooldown(spellID, value, button)
                            end
                        end
                        self:CooldownStart(button, spellID, sharedCD)
                    end
                end
            end
        end

        -- check if there is charges
        if (cooldown.charges) then

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
-- Update Cooldowns
---------------------

function Cooldowns:AddCooldown(spellID, value, button)
    -- see if we have shared cooldowns without a cooldown defined
    -- e.g. hunter traps have shared cooldowns, so only display one trap instead all of them
    local sharedCD = false
    if (type(value) == "table" and value.sharedCD ~= nil and value.sharedCD.cd == nil) then
        for spellId, _ in pairs(value.sharedCD) do
            for _,icon in pairs(button.spellCooldownFrame.icons) do
                if (icon.spellId == spellId) then
                    sharedCD = true
                    break
                end
            end
        end
    end
    for _,icon in pairs(button.spellCooldownFrame.icons) do
        if (icon and icon.spellId == spellID) then
            sharedCD = true
            break
        end
    end
    if (not sharedCD) then
        local icon = self:CreateIcon()
        icon:Show()
        icon.spellId = spellID
        icon.texture:SetTexture(self.spellTextures[spellID])
        if button.class then
            icon.activationTexture:SetVertexColor(
                    RAID_CLASS_COLORS[button.class].r,
                    RAID_CLASS_COLORS[button.class].g,
                    RAID_CLASS_COLORS[button.class].b, 1)
            icon.flash:SetVertexColor(
                    RAID_CLASS_COLORS[button.class].r,
                    RAID_CLASS_COLORS[button.class].g,
                    RAID_CLASS_COLORS[button.class].b, 1)
        else
            icon.activationTexture:SetVertexColor(1,1,1,1)
            icon.flash:SetVertexColor(1,1,1,1)
        end

        if (type(value) == "table") then
            if value.charges then
                icon.maxCharges = value.charges
            elseif value.chargeMod then
                icon.maxCharges = 1 -- discover additional charges dynamically on use
            else
                icon.maxCharges = nil
            end
        else
            icon.maxCharges = nil
        end
        icon.rechargeEndTimes = nil
        icon.charges:SetText((icon.maxCharges and icon.maxCharges > 1) and tostring(icon.maxCharges) or "")
        tinsert(button.spellCooldownFrame.icons, icon)
        self:IconsSetPoint(button)
    end
end

function Cooldowns:UpdateCooldowns(button)
    if not button then
        return
    end
    local class = button.class
    local race = button.race
    local spec = button.spec
    if not class or (not race and Gladdy.expansion ~= "Wrath") then
        return
    end

    -- Precompute replaced spells and enforce talent row exclusivity
    local replaced = {}
    local talentRowShown = {}
    for spellId, data in pairs(Gladdy:GetCooldownList()[class]) do
        if type(data) == "table" and data.replaces then
            replaced[data.replaces] = true
        end
    end
    for spellID, cooldownInfo in pairs(Gladdy:GetCooldownList()[class]) do
        if Gladdy.db.cooldownCooldowns[tostring(spellID)] then
            if replaced[spellID] then
                -- Skip base spell when there is a replacement
            else
                local add = false
                if type(cooldownInfo) ~= "table" then
                    add = true
                else
                    -- spec gating
                    if cooldownInfo.notSpec and spec == cooldownInfo.notSpec then
                        add = false
                    elseif not cooldownInfo.spec then
                        add = true
                    elseif type(cooldownInfo.spec) == "table" then
                        for _,specialization in pairs(cooldownInfo.spec) do
                            if spec == specialization then
                                add = true
                                break
                            end
                        end
                    else
                        add = (cooldownInfo.spec == spec)
                    end
                    -- hide talent rows until used (they will be added dynamically on first use)
                    if add and cooldownInfo.talent then
                        add = false
                    end
                end
                if add then
                    Cooldowns:AddCooldown(spellID, cooldownInfo, button)
                end
            end
        end
    end
    if race then
        for k, v in pairs(Gladdy:GetCooldownList()[race]) do
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
end

---------------------
-- Options
---------------------

local function FormatClassHeaderName(class)
    local icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
    local coords = CLASS_ICON_TCOORDS[class] -- {left, right, top, bottom}
    -- Usage: CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, xOffset, yOffset)
    return CreateTextureMarkup(icon, 512, 512, 22, 22, coords[1], coords[2], coords[3], coords[4], 0, -2) .. " " .. LOCALIZED_CLASS_NAMES_MALE[class]
end

function Cooldowns:GetOptions()
    local options = {
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
        }, function()
            Cooldowns:LoadModule()
        end),
        cooldownGroup = Gladdy:option({
            type = "toggle",
            name = L["Group"] .. " " .. L["Cooldown"],
            order = 3,
            disabled = function() return not Gladdy.db.cooldown end,
        }),
        cooldownGroupMode = Gladdy:option({
            type = "select",
            name = L["Group Mode"],
            order = 4,
            values = {
                ["ARENA"] = L["By Arena"],
                ["ORDER"] = L["By Order"],
            },
            disabled = function() return not Gladdy.db.cooldown or not Gladdy.db.cooldownGroup end,
        }),
        testSpec = {
            type = "execute",
            order = 4,
            width = "0.7",
            name = L["Test Without Talents"],
            func = function()
                for unit in pairs(Gladdy.buttons) do
                    Cooldowns:ResetUnit(unit)
                    Cooldowns:UpdateCooldowns(Gladdy.buttons[unit])
                    Cooldowns:Test(unit, false)
                end
            end,
            disabled = function() return not Gladdy.db.cooldown end,
        },
        testTalents = {
            type = "execute",
            order = 4,
            width = "0.7",
            name = L["Test With Talents"],
            func = function()
                for unit in pairs(Gladdy.buttons) do
                    Cooldowns:ResetUnit(unit)
                    Cooldowns:UpdateCooldowns(Gladdy.buttons[unit])
                    Cooldowns:Test(unit, true)
                end
            end,
            disabled = function() return not Gladdy.db.cooldown end,
        },
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            width = 2.0,
            order = 5,
            disabled = function() return not Gladdy.db.cooldown end,
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
                        cooldownIconZoomed = Gladdy:option({
                            type = "toggle",
                            name = L["Zoomed Icon"],
                            desc = L["Zoomes the icon to remove borders"],
                            order = 4,
                            width = "full",
                        }),
                        cooldownSize = Gladdy:option({
                            type = "range",
                            name = L["Cooldown size"],
                            desc = L["Size of each cd icon"],
                            order = 5,
                            min = 5,
                            max = 50,
                            width = "full",
                        }),
                        cooldownWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon Width Factor"],
                            desc = L["Stretches the icon"],
                            order = 6,
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            width = "full",
                        }),
                        cooldownIconPadding = Gladdy:option({
                            type = "range",
                            name = L["Icon Padding"],
                            desc = L["Space between Icons"],
                            order = 7,
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
                        cooldownIconDesaturateOnCooldown = Gladdy:option({
                            type = "toggle",
                            name = L["Desaturate Icon"],
                            order = 5,
                            width = "full",
                        }),
                        cooldownIconAlphaOnCooldown = Gladdy:option({
                            type = "range",
                            name = L["Cooldown alpha on CD"],
                            desc = L["Alpha of the icon when cooldown active"],
                            desc = L["changes "],
                            order = 6,
                            min = 0,
                            max = 1,
                            step = 0.1,
                            width = "full",
                        }),
                        headerCircle = {
                            type = "header",
                            name = L["Cooldowncircle"],
                            order = 10,
                        },
                        cooldownDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 11,
                            width = "full",
                        }),
                        cooldownCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 12,
                            width = "full",
                        }),
                        cooldownCooldownNumberAlpha = {
                            type = "range",
                            name = L["Cooldown number alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 13,
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
                glow = {
                    type = "group",
                    name = L["Glow"],
                    order = 3,
                    args = {
                        header = {
                            type = "header",
                            name = L["Glow"],
                            order = 1,
                        },
                        cooldownIconGlow = Gladdy:option({
                            type = "toggle",
                            name = L["Glow Icon"],
                            desc = L["Glow the icon when cooldown active"],
                            order = 2,
                            width = "full",
                        }),
                        cooldownIconGlowColor = Gladdy:colorOption({
                            disabled = function() return not Gladdy.db.cooldownIconGlow end,
                            type = "color",
                            hasAlpha = true,
                            name = L["Glow color"],
                            desc = L["Color of the glow"],
                            order = 3,
                            width = "full",
                        }),
                        resetGlow = {
                            type = "execute",
                            name = L["Reset Glow"],
                            desc = L["Reset Glow Color"],
                            func = function()
                                Gladdy.db.cooldownIconGlowColor = {r = 0.95, g = 0.95, b = 0.32, a = 1}
                                Gladdy:UpdateFrame()
                            end,
                            order = 3,
                        }
                    },
                },
                animation = {
                    type = "group",
                    name = L["Animation"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Animation"],
                            order = 1,
                        },
                        cooldownIconAnimationActivation = Gladdy:option({
                            type = "toggle",
                            name = L["Animation when used"],
                            desc = L["Flash the icon when cooldown is used"],
                            order = 3,
                            width = "full",
                        }),
                        cooldownIconAnimationReady = Gladdy:option({
                            type = "toggle",
                            name = L["Animation when ready"],
                            desc = L["Flash the icon when cooldown becomes usable"],
                            order = 4,
                            width = "full",
                        }),
                    }
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 5,
                    disabled = function()
                        return Gladdy.db.useOmnicc
                    end,
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
                    order = 6,
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
                    order = 5,
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
                    order = 7,
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
        --cooldowns = {
        --    type = "group",
        --    childGroups = "tab",
        --    name = L["Cooldowns"],
        --    order = 4,
        --    disabled = function() return not Gladdy.db.cooldown end,
        --    args = Cooldowns:GetCooldownOptions(),
        --},
    }
    local cdOptions = Cooldowns:GetCooldownOptions()
    for i,class in ipairs(Gladdy.CLASSES) do
        options[class] = cdOptions[class]
        --{
        --    type = "group",
        --    childGroups = "tree",
        --    name = FormatClassHeaderName(class),
        --    order = 5+i,
        --    disabled = function() return not Gladdy.db.cooldown end,
        --    args = {
        --        ["1231"] = {
        --            name = FormatClassHeaderName(class),
        --            type = "group",
        --            inline = true,
        --            args = {}
        --        }
        --    },
        --}
    end
    return options
end

local function getName(spellID, cooldown, class, onlyspec)
    local spec = ""
    if type(cooldown) == "table" and cooldown.spec then
        if type(cooldown.spec) == "table" then
            spec = " - ("
            for _,specialization in ipairs(cooldown.spec) do
                local coloredSpec = Gladdy:GetSpecColors()[class][specialization].color:WrapTextInColorCode(specialization)
                spec = spec .. CreateTextureMarkup(Gladdy:GetSpecIcons()[class][specialization], 64, 64, 16, 16, 0, 1, 0, 1) .. " " .. coloredSpec .. ", "
            end
            spec = spec:sub(1, -3) .. ")"
        else
            local coloredSpec = Gladdy:GetSpecColors()[class][cooldown.spec].color:WrapTextInColorCode(cooldown.spec)
            spec = " - " .. CreateTextureMarkup(Gladdy:GetSpecIcons()[class][cooldown.spec], 64, 64, 16, 16, 0, 1, 0, 1) .. " " .. coloredSpec
        end
    end
    if type(cooldown) == "table" and cooldown.talent then
        spec = spec .. " - " .. WrapTextInColorCode("Talent " .. (cooldown.talent + 1), "FF8e9e9e")--9c5b00
    end
    return (onlyspec and spec) or (CreateTextureMarkup(GetSpellTexture(spellID), 64, 64, 24, 24, 0, 1, 0, 1) .. " " .. select(1, GetSpellInfo(spellID)) .. spec)
end

local function UpdateSpellOrder(class, spellId, newOrder)
    local spellOrders = Gladdy.db.cooldownCooldownsOrder[class]
    if not spellOrders then return end

    local spellIdStr = tostring(spellId)
    local oldOrder = spellOrders[spellIdStr]
    if not oldOrder then return end
    if oldOrder == newOrder then return end

    -- Build reverse lookup: order -> spellId
    local orderToSpell = {}
    for id, order in pairs(spellOrders) do
        orderToSpell[order] = id
    end

    -- Moving down the list
    if newOrder > oldOrder then
        for i = oldOrder + 1, newOrder do
            local otherSpellId = orderToSpell[i]
            if otherSpellId then
                spellOrders[otherSpellId] = i - 1
                Gladdy.options.args["Cooldowns"].args[class].args[tostring(otherSpellId)].order = spellOrders[otherSpellId]
            end
        end
        -- Moving up the list
    elseif newOrder < oldOrder then
        for i = oldOrder - 1, newOrder, -1 do
            local otherSpellId = orderToSpell[i]
            if otherSpellId then
                spellOrders[otherSpellId] = i + 1
                Gladdy.options.args["Cooldowns"].args[class].args[tostring(otherSpellId)].order = spellOrders[otherSpellId]
            end
        end
    end
    -- Finally assign the new order
    spellOrders[spellIdStr] = newOrder
    Gladdy.options.args["Cooldowns"].args[class].args[spellIdStr].order = newOrder
end


function Cooldowns:UpdateCooldownOptions()
    local options = self:GetCooldownOptions()
    for _,class in ipairs(Gladdy.CLASSES) do
        Gladdy.options.args["Cooldowns"].args[class] = options[class]
    end
end

function Cooldowns:GetCooldownOptions()
    local group = {}

    local p = 1
    for i,class in ipairs(Gladdy.CLASSES) do
        group[class] = {
            type = "group",
            name = FormatClassHeaderName(class),
            order = i+4,
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS[class],
            disabled = function() return not Gladdy.db.cooldown end,
            args = {}
            --base, spec, talent
        }
        for spellId,cooldown in pairs(Gladdy:GetCooldownList()[class]) do
            group[class].args[tostring(spellId)] = {
                name = "",
                type = "group",
                inline = true,
                order = Gladdy.db.cooldownCooldownsOrder[class][tostring(spellId)],
                args = {
                    order = {
                        type = "input",
                        name = "",
                        width = 0.2,
                        order = 1,
                        get = function()
                            return tostring(Gladdy.db.cooldownCooldownsOrder[class][tostring(spellId)])
                        end,
                        dialogControl = "NumericInputBox",
                        set = function(_, value)
                            local num = tonumber(value)
                            if not num or num < 1 then return end
                            UpdateSpellOrder(class, spellId,  tonumber(value))
                            for unit in pairs(Gladdy.buttons) do
                                Cooldowns:ResetUnit(unit)
                                Cooldowns:UpdateCooldowns(Gladdy.buttons[unit])
                                Cooldowns:Test(unit, true)
                            end
                        end,
                    },
                    toggle = {
                        type = "toggle",
                        name = getName(spellId, cooldown, class),
                        desc = Gladdy:GetSpellDescription(spellId, cooldown),
                        order = 2,
                        width = 2,
                        --image = select(3, GetSpellInfo(spellId)),
                        get = function()
                            return Gladdy.db.cooldownCooldowns[tostring(spellId)]
                        end,
                        set = function(_, value)
                            Gladdy.db.cooldownCooldowns[tostring(spellId)] = value
                            for unit in pairs(Gladdy.buttons) do
                                Cooldowns:ResetUnit(unit)
                                Cooldowns:UpdateCooldowns(Gladdy.buttons[unit])
                                Cooldowns:Test(unit, true)
                            end
                        end
                    },
                }
            }
        end
        p = p + i
    end
    for i,race in ipairs(Gladdy.RACES) do
        for spellId,cooldown in pairs(Gladdy:GetCooldownList()[race]) do
            local tblLength = tableLength(Gladdy.db.cooldownCooldownsOrder[cooldown.class])
            local class = cooldown.class
            group[class].args[tostring(spellId)] = {
                name = "",
                type = "group",
                inline = true,
                order = Gladdy.db.cooldownCooldownsOrder[class][tostring(spellId)],
                args = {
                    order = {
                        type = "input",
                        name = "",
                        width = 0.2,
                        order = 1,
                        get = function()
                            return tostring(Gladdy.db.cooldownCooldownsOrder[class][tostring(spellId)])
                        end,
                        dialogControl = "NumericInputBox",
                        set = function(_, value)
                            local num = tonumber(value)
                            if not num or num < 1 then return end
                            UpdateSpellOrder(class, spellId,  tonumber(value))
                            for unit in pairs(Gladdy.buttons) do
                                Cooldowns:ResetUnit(unit)
                                Cooldowns:UpdateCooldowns(Gladdy.buttons[unit])
                                Cooldowns:Test(unit, true)
                            end
                        end,
                    },
                    toggle = {
                        type = "toggle",
                        name = getName(spellId, cooldown, class),
                        desc = Gladdy:GetSpellDescription(spellId, cooldown),
                        order = 2,
                        width = 2,
                        --image = select(3, GetSpellInfo(spellId)),
                        get = function()
                            return Gladdy.db.cooldownCooldowns[tostring(spellId)]
                        end,
                        set = function(_, value)
                            Gladdy.db.cooldownCooldowns[tostring(spellId)] = value
                            for unit in pairs(Gladdy.buttons) do
                                Cooldowns:ResetUnit(unit)
                                Cooldowns:UpdateCooldowns(Gladdy.buttons[unit])
                                Cooldowns:Test(unit, true)
                            end
                        end
                    },
                }
            }
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