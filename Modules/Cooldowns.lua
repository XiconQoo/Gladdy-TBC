local type, pairs, ceil, tonumber, mod = type, pairs, ceil, tonumber, mod
local GetTime = GetTime
local CreateFrame = CreateFrame

local GetSpellInfo = GetSpellInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local Cooldowns = Gladdy:NewModule("Cooldowns", nil, {
    cooldownFont = "DorisPP",
    cooldownFontScale = 1,
    cooldownFontColor = { r = 1, g = 1, b = 0, a = 1 },
    cooldown = true,
    cooldownYPos = "TOP",
    cooldownXPos = "LEFT",
    cooldownYOffset = 0,
    cooldownXOffset = 0,
    cooldownSize = 30,
    cooldownWidthFactor = 1,
    cooldownIconPadding = 1,
    cooldownMaxIconsPerLine = 10,
    cooldownBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_Gloss",
    cooldownBorderColor = { r = 1, g = 1, b = 1, a = 1 },
    cooldownDisableCircle = false,
    cooldownCooldownAlpha = 1
})

function Cooldowns:Initialize()
    self.cooldownSpellIds = {}
    self.spellTextures = {}
    for class, t in pairs(self.cooldownSpells) do
        for k, v in pairs(t) do
            local spellName, _, texture = GetSpellInfo(k)
            if spellName then
                self.cooldownSpellIds[spellName] = k
                self.spellTextures[k] = texture
            else
                Gladdy:Print("spellid does not exist  " .. k)
            end
        end
    end
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("SPEC_DETECTED")
    self:RegisterMessage("UNIT_DEATH")
end

function Cooldowns:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    -- Cooldown frame
    local spellCooldownFrame = CreateFrame("Frame", nil, button)
    for x = 1, 14 do
        local icon = CreateFrame("Frame", nil, spellCooldownFrame)
        icon:EnableMouse(false)
        icon:SetFrameLevel(3)
        icon.texture = icon:CreateTexture(nil, "BACKGROUND")
        icon.texture:SetAllPoints(icon)

        icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true

        icon.cooldown:SetFrameLevel(4)
        icon.cooldown:SetReverse(false)
        icon.cooldown:SetHideCountdownNumbers(true)

        icon.cooldownFrame = CreateFrame("Frame", nil, icon)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetAllPoints(icon)
        icon.cooldownFrame:SetFrameLevel(5)

        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY")
        icon.border:SetAllPoints(icon)
        icon.border:SetTexture(Gladdy.db.cooldownBorderStyle)
        icon.border:SetVertexColor(Gladdy.db.cooldownBorderColor.r, Gladdy.db.cooldownBorderColor.g, Gladdy.db.cooldownBorderColor.b, Gladdy.db.cooldownBorderColor.a)

        icon.cooldownFont = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), Gladdy.db.cooldownSize / 2  * Gladdy.db.cooldownFontScale, "OUTLINE")
        icon.cooldownFont:SetTextColor(Gladdy.db.cooldownFontColor.r, Gladdy.db.cooldownFontColor.g, Gladdy.db.cooldownFontColor.b, Gladdy.db.cooldownFontColor.a)
        icon.cooldownFont:SetAllPoints(icon)

        spellCooldownFrame["icon" .. x] = icon
    end
    button.spellCooldownFrame = spellCooldownFrame
end

function Cooldowns:UpdateFrame(unit)
    local button = Gladdy.buttons[unit]
    -- Cooldown frame
    if (Gladdy.db.cooldown) then
        button.spellCooldownFrame:ClearAllPoints()
        local verticalMargin = -(Gladdy.db.powerBarHeight)/2
        if Gladdy.db.cooldownYPos == "TOP" then
            if Gladdy.db.cooldownXPos == "RIGHT" then
                button.spellCooldownFrame:SetPoint("BOTTOMRIGHT", button.healthBar, "TOPRIGHT", Gladdy.db.cooldownXOffset, Gladdy.db.highlightBorderSize + Gladdy.db.cooldownYOffset) -- needs to be properly anchored after trinket
            else
                button.spellCooldownFrame:SetPoint("BOTTOMLEFT", button.healthBar, "TOPLEFT", Gladdy.db.cooldownXOffset, Gladdy.db.highlightBorderSize + Gladdy.db.cooldownYOffset)
            end
        elseif Gladdy.db.cooldownYPos == "BOTTOM" then
            if Gladdy.db.cooldownXPos == "RIGHT" then
                button.spellCooldownFrame:SetPoint("TOPRIGHT", button.powerBar, "BOTTOMRIGHT", Gladdy.db.cooldownXOffset, -Gladdy.db.highlightBorderSize + Gladdy.db.cooldownYOffset) -- needs to be properly anchored after trinket
            else
                button.spellCooldownFrame:SetPoint("TOPLEFT", button.powerBar, "BOTTOMLEFT", Gladdy.db.cooldownXOffset, -Gladdy.db.highlightBorderSize + Gladdy.db.cooldownYOffset)
            end
        elseif Gladdy.db.cooldownYPos == "LEFT" then
            local horizontalMargin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
            if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
                if (Gladdy.db.classIconPos == "LEFT") then
                    horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
                end
            elseif (Gladdy.db.classIconPos == "LEFT") then
                horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
                if (Gladdy.db.trinketPos == "LEFT" and Gladdy.db.trinketEnabled) then
                    horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
                end
            end
            if (Gladdy.db.drCooldownPos == "LEFT" and Gladdy.db.drEnabled) then
                verticalMargin = verticalMargin + Gladdy.db.drIconSize/2 + Gladdy.db.padding/2
            end
            if (Gladdy.db.castBarPos == "LEFT") then
                verticalMargin = verticalMargin -
                        ((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                                or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2
            end
            if (Gladdy.db.buffsCooldownPos == "LEFT" and Gladdy.db.buffsEnabled) then
                verticalMargin = verticalMargin - (Gladdy.db.buffsIconSize/2 + Gladdy.db.padding/2)
            end
            button.spellCooldownFrame:SetPoint("RIGHT", button.healthBar, "LEFT", -horizontalMargin + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset + verticalMargin)
        elseif Gladdy.db.cooldownYPos == "RIGHT" then
            verticalMargin = -(Gladdy.db.powerBarHeight)/2
            local horizontalMargin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
            if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
                horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
                if (Gladdy.db.classIconPos == "RIGHT") then
                    horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
                end
            elseif (Gladdy.db.classIconPos == "RIGHT") then
                horizontalMargin = horizontalMargin + (Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor) + Gladdy.db.padding
                if (Gladdy.db.trinketPos == "RIGHT" and Gladdy.db.trinketEnabled) then
                    horizontalMargin = horizontalMargin + (Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor) + Gladdy.db.padding
                end
            end
            if (Gladdy.db.drCooldownPos == "RIGHT" and Gladdy.db.drEnabled) then
                verticalMargin = verticalMargin + Gladdy.db.drIconSize/2 + Gladdy.db.padding/2
            end
            if (Gladdy.db.castBarPos == "RIGHT") then
                verticalMargin = verticalMargin -
                        ((Gladdy.db.castBarHeight < Gladdy.db.castBarIconSize) and Gladdy.db.castBarIconSize
                                or Gladdy.db.castBarHeight)/2 + Gladdy.db.padding/2
            end
            if (Gladdy.db.buffsCooldownPos == "RIGHT" and Gladdy.db.buffsEnabled) then
                verticalMargin = verticalMargin - (Gladdy.db.buffsIconSize/2 + Gladdy.db.padding/2)
            end
            button.spellCooldownFrame:SetPoint("LEFT", button.healthBar, "RIGHT", horizontalMargin + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset + verticalMargin)
        end
        button.spellCooldownFrame:SetHeight(Gladdy.db.cooldownSize)
        button.spellCooldownFrame:SetWidth(1)
        button.spellCooldownFrame:Show()
        -- Update each cooldown icon
        local o = 1
        for j = 1, 14 do
            local icon = button.spellCooldownFrame["icon" .. j]
            icon:SetHeight(Gladdy.db.cooldownSize)
            icon:SetWidth(Gladdy.db.cooldownSize * Gladdy.db.cooldownWidthFactor)
            icon.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), Gladdy.db.cooldownSize / 2 * Gladdy.db.cooldownFontScale, "OUTLINE")
            icon.cooldownFont:SetTextColor(Gladdy.db.cooldownFontColor.r, Gladdy.db.cooldownFontColor.g, Gladdy.db.cooldownFontColor.b, Gladdy.db.cooldownFontColor.a)
            icon:ClearAllPoints()
            if (Gladdy.db.cooldownXPos == "RIGHT") then
                if (j == 1) then
                    icon:SetPoint("RIGHT", button.spellCooldownFrame, "RIGHT", 0, 0)
                elseif (mod(j-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                    if (Gladdy.db.cooldownYPos == "BOTTOM" or Gladdy.db.cooldownYPos == "LEFT" or Gladdy.db.cooldownYPos == "RIGHT") then
                        icon:SetPoint("TOP", button.spellCooldownFrame["icon" .. o], "BOTTOM", 0, -Gladdy.db.cooldownIconPadding)
                    else
                        icon:SetPoint("BOTTOM", button.spellCooldownFrame["icon" .. o], "TOP", 0, Gladdy.db.cooldownIconPadding)
                    end
                    o = o + tonumber(Gladdy.db.cooldownMaxIconsPerLine)
                else
                    icon:SetPoint("RIGHT", button.spellCooldownFrame["icon" .. j - 1], "LEFT", -Gladdy.db.cooldownIconPadding, 0)
                end
            end
            if (Gladdy.db.cooldownXPos == "LEFT") then
                if (j == 1) then
                    icon:SetPoint("LEFT", button.spellCooldownFrame, "LEFT", 0, 0)
                elseif (mod(j-1,Gladdy.db.cooldownMaxIconsPerLine) == 0) then
                    if (Gladdy.db.cooldownYPos == "BOTTOM" or Gladdy.db.cooldownYPos == "LEFT" or Gladdy.db.cooldownYPos == "RIGHT") then
                        icon:SetPoint("TOP", button.spellCooldownFrame["icon" .. o], "BOTTOM", 0, -Gladdy.db.cooldownIconPadding)
                    else
                        icon:SetPoint("BOTTOM", button.spellCooldownFrame["icon" .. o], "TOP", 0, Gladdy.db.cooldownIconPadding)
                    end
                    o = o + tonumber(Gladdy.db.cooldownMaxIconsPerLine)
                else
                    icon:SetPoint("LEFT", button.spellCooldownFrame["icon" .. j - 1], "RIGHT", Gladdy.db.cooldownIconPadding, 0)
                end
            end

            if (icon.active) then
                icon.active = false
                icon.cooldown:SetCooldown(GetTime(), 0)
                icon.cooldownFont:SetText("")
                icon:SetScript("OnUpdate", nil)
            end
            icon.spellId = nil
            icon:SetAlpha(1)
            icon.texture:SetTexture("Interface\\Icons\\Spell_Holy_PainSupression")

            icon.cooldown:SetWidth(icon:GetWidth() - icon:GetWidth()/16)
            icon.cooldown:SetHeight(icon:GetHeight() - icon:GetHeight()/16)
            icon.cooldown:ClearAllPoints()
            icon.cooldown:SetPoint("CENTER", icon, "CENTER")
            icon.cooldown:SetAlpha(Gladdy.db.cooldownCooldownAlpha)

            icon.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), (icon:GetWidth()/2 - 1) * Gladdy.db.cooldownFontScale, "OUTLINE")
            icon.cooldownFont:SetTextColor(Gladdy.db.cooldownFontColor.r, Gladdy.db.cooldownFontColor.g, Gladdy.db.cooldownFontColor.b, Gladdy.db.cooldownFontColor.a)

            icon.border:SetTexture(Gladdy.db.cooldownBorderStyle)
            icon.border:SetVertexColor(Gladdy.db.cooldownBorderColor.r, Gladdy.db.cooldownBorderColor.g, Gladdy.db.cooldownBorderColor.b, Gladdy.db.cooldownBorderColor.a)
            icon:Hide()
        end
        button.spellCooldownFrame:Show()
    else
        button.spellCooldownFrame:Hide()
    end
    if (Gladdy.frame.testing) then
        self:Test(unit)
    end
end

function Cooldowns:Test(unit)
    if Gladdy.db.cooldown then
        local button = Gladdy.buttons[unit]
        button.spellCooldownFrame:Show()
        button.lastCooldownSpell = 1
        self:UpdateTestCooldowns(unit)
    end
end

function Cooldowns:UpdateTestCooldowns(unit)
    local button = Gladdy.buttons[unit]

    if (button.testSpec and button.testSpec == Gladdy.testData[unit].testSpec) then
        button.lastCooldownSpell = 1
        self:UpdateCooldowns(button)
        button.spec = nil
        self:DetectSpec(unit, button.testSpec)
        button.test = true

        -- use class spells
        for k, v in pairs(self.cooldownSpells[button.class]) do
            --k is spellId
            self:CooldownUsed(unit, button.class, k, nil)
        end
        -- use race spells
        for k, v in pairs(self.cooldownSpells[button.race]) do
            self:CooldownUsed(unit, button.race, k, nil)
        end
    end
end

function Cooldowns:ENEMY_SPOTTED(unit)
    self:UpdateCooldowns(Gladdy.buttons[unit])
end

function Cooldowns:SPEC_DETECTED(unit, spec)
    self:DetectSpec(unit, spec)
end

function Cooldowns:CooldownStart(button, spellId, duration)
    -- starts timer frame
    if not duration or duration == nil or type(duration) ~= "number" then
        return
    end
    for i = 1, button.lastCooldownSpell + 1 do
        if (button.spellCooldownFrame["icon" .. i].spellId == spellId) then
            local frame = button.spellCooldownFrame["icon" .. i]
            frame.active = true
            frame.timeLeft = duration
            if (not Gladdy.db.cooldownDisableCircle) then frame.cooldown:SetCooldown(GetTime(), duration) end
            frame:SetScript("OnUpdate", function(self, elapsed)
                self.timeLeft = self.timeLeft - elapsed
                local timeLeft = ceil(self.timeLeft)
                if timeLeft >= 540 then
                    self.cooldownFont:SetText(ceil(timeLeft / 60) .. "m")
                    self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), Gladdy.db.cooldownSize / 3.1 * Gladdy.db.cooldownFontScale, "OUTLINE")
                elseif timeLeft < 540 and timeLeft >= 60 then
                    -- more than 1 minute
                    self.cooldownFont:SetText(ceil(timeLeft / 60) .. "m")
                    self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), Gladdy.db.cooldownSize / 2.15 * Gladdy.db.cooldownFontScale, "OUTLINE")
                elseif timeLeft < 60 and timeLeft > 0 then
                    -- between 60s and 21s (green)
                    self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.cooldownFont), Gladdy.db.cooldownSize / 2.15 * Gladdy.db.cooldownFontScale, "OUTLINE")
                    self.cooldownFont:SetText(timeLeft)
                else
                    self.cooldownFont:SetText("")
                end
                if (self.timeLeft <= 0) then
                    Cooldowns:CooldownReady(button, spellId, frame)
                end
                if (self.timeLeft <= 0) then
                    Cooldowns:CooldownReady(button, spellId, frame)
                end
            end)
        end
    end
end

function Cooldowns:CooldownReady(button, spellId, frame)
    if (frame == false) then
        for i = 1, button.lastCooldownSpell do
            frame = button.spellCooldownFrame["icon" .. i]

            if (frame.spellId == spellId) then
                frame.active = false
                frame.cooldown:Hide()
                frame.cooldownFont:SetText("")
                frame:SetScript("OnUpdate", nil)
            end
        end
    else
        frame.active = false
        frame.cooldown:Hide()
        frame.cooldownFont:SetText("")
        frame:SetScript("OnUpdate", nil)
    end
end

function Cooldowns:DetectSpec(unit, spec)

    local button = Gladdy.buttons[unit]
    if (not button or not spec or button.spec) then
        return
    end

    button.spec = spec
    if not button.test then
        Gladdy:SendMessage("UNIT_SPEC", unit, spec)
    end


    -- update cooldown tracker
    --[[
        All of this could possibly be handled in a "once they're used, they show up"-manner
        but I PERSONALLY prefer it this way. It also meant less work and makes spec-specific cooldowns easier
    ]]
    if (Gladdy.db.cooldown) then
        local class = Gladdy.buttons[unit].class
        local race = Gladdy.buttons[unit].race
        for k, v in pairs(self.cooldownSpells[class]) do
            --if (self.db.cooldownList[k] ~= false and self.db.cooldownList[class] ~= false) then
            if (type(v) == "table" and ((v.spec ~= nil and v.spec == spec) or (v.notSpec ~= nil and v.notSpec ~= spec))) then
                local sharedCD = false
                if (type(v) == "table" and v.sharedCD ~= nil and v.sharedCD.cd == nil) then
                    for spellId, _ in pairs(v.sharedCD) do
                        for i = 1, button.lastCooldownSpell do
                            local icon = button.spellCooldownFrame["icon" .. i]
                            if (icon.spellId == spellId) then
                                sharedCD = true
                            end
                        end
                    end
                end
                if sharedCD then
                    return
                end

                local icon = button.spellCooldownFrame["icon" .. button.lastCooldownSpell]
                icon:Show()
                icon.texture:SetTexture(self.spellTextures[k])
                icon.spellId = k
                button.spellCooldownFrame["icon" .. button.lastCooldownSpell] = icon
                button.lastCooldownSpell = button.lastCooldownSpell + 1
            end
        end
        --end
    end
    ----------------------
    --- RACE FUNCTIONALITY
    ----------------------
    local race = Gladdy.buttons[unit].race
    if self.cooldownSpells[race] then
        for k, v in pairs(self.cooldownSpells[race]) do
            --if (self.db.cooldownList[k] ~= false and self.db.cooldownList[class] ~= false) then
            if (type(v) == "table" and ((v.spec ~= nil and v.spec == spec) or (v.notSpec ~= nil and v.notSpec ~= spec))) then
                local sharedCD = false
                if (type(v) == "table" and v.sharedCD ~= nil and v.sharedCD.cd == nil) then
                    for spellId, _ in pairs(v.sharedCD) do
                        for i = 1, button.lastCooldownSpell do
                            local icon = button.spellCooldownFrame["icon" .. i]
                            if (icon.spellId == spellId) then
                                sharedCD = true
                            end
                        end
                    end
                end
                if sharedCD then
                    return
                end

                local icon = button.spellCooldownFrame["icon" .. button.lastCooldownSpell]
                icon:Show()
                icon.texture:SetTexture(self.spellTextures[k])
                icon.spellId = k
                button.spellCooldownFrame["icon" .. button.lastCooldownSpell] = icon
                button.lastCooldownSpell = button.lastCooldownSpell + 1
            end
        end
    end
end

function Cooldowns:ResetUnit(unit)
    Gladdy.buttons[unit].lastCooldownSpell = nil
    Gladdy.buttons[unit].test = nil
end

function Cooldowns:UpdateCooldowns(button)
    local class = button.class
    local race = button.race
    if ( not button.lastCooldownSpell) then
        button.lastCooldownSpell = 1
    end

    if (Gladdy.db.cooldown) then
        for k, v in pairs(self.cooldownSpells[class]) do
            if (type(v) ~= "table" or (type(v) == "table" and v.spec == nil and v.notSpec == nil)) then
                -- see if we have shared cooldowns without a cooldown defined
                -- e.g. hunter traps have shared cooldowns, so only display one trap instead all of them
                local sharedCD = false
                if (type(v) == "table" and v.sharedCD ~= nil and v.sharedCD.cd == nil) then
                    for spellId, _ in pairs(v.sharedCD) do
                        for i = 1, button.lastCooldownSpell do
                            local icon = button.spellCooldownFrame["icon" .. i]
                            if (icon.spellId == spellId) then
                                sharedCD = true
                            end
                        end
                    end
                end

                if (not sharedCD) then
                    local icon = button.spellCooldownFrame["icon" .. button.lastCooldownSpell]
                    icon:Show()
                    icon.spellId = k
                    icon.texture:SetTexture(self.spellTextures[k])
                    button.spellCooldownFrame["icon" .. button.lastCooldownSpell] = icon
                    button.lastCooldownSpell = button.lastCooldownSpell + 1
                end
            end
        end
        ----
        -- RACE FUNCTIONALITY
        ----

        for k, v in pairs(self.cooldownSpells[race]) do
            if (type(v) ~= "table" or (type(v) == "table" and v.spec == nil and v.notSpec == nil)) then
                local icon = button.spellCooldownFrame["icon" .. button.lastCooldownSpell]
                icon:Show()
                icon.spellId = k
                icon.texture:SetTexture(self.spellTextures[k])
                button.spellCooldownFrame["icon" .. button.lastCooldownSpell] = icon
                button.lastCooldownSpell = button.lastCooldownSpell + 1
            end
        end
    end
end

function Cooldowns:CooldownUsed(unit, unitClass, spellId, spellName)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    -- if (self.db.cooldownList[spellId] == false) then return end

    local cooldown = self.cooldownSpells[unitClass][spellId]
    local cd = cooldown
    if (type(cooldown) == "table") then
        -- return if the spec doesn't have a cooldown for this spell
        --if (arenaSpecs[unit] ~= nil and cooldown.notSpec ~= nil and arenaSpecs[unit] == cooldown.notSpec) then return end
        if (button.spec ~= nil and cooldown.notSpec ~= nil and button.spec == cooldown.notSpec) then
            return
        end

        -- check if we need to reset other cooldowns because of this spell
        if (cooldown.resetCD ~= nil) then
            for k, v in pairs(cooldown.resetCD) do
                self:CooldownReady(button, k, false)
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

            for k, v in pairs(cooldown.sharedCD) do
                if (k ~= "cd") then
                    self:CooldownStart(button, k, sharedCD)
                end
            end
        end
    end

    if (Gladdy.db.cooldown) then
        -- start cooldown
        self:CooldownStart(button, spellId, cd)
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

local function option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key] = value
            if Gladdy.db.cooldownYPos == "LEFT" then
                Gladdy.db.cooldownXPos = "RIGHT"
            elseif Gladdy.db.cooldownYPos == "RIGHT" then
                Gladdy.db.cooldownXPos = "LEFT"
            end
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Cooldowns:GetOptions()
    return {
        headerCooldown = {
            type = "header",
            name = L["Cooldown"],
            order = 2,
        },
        cooldown = Gladdy:option({
            type = "toggle",
            name = L["Enable"],
            desc = L["Enabled cooldown module"],
            order = 2,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = "Frame",
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
                            max = (Gladdy.db.healthBarHeight + Gladdy.db.castBarHeight + Gladdy.db.powerBarHeight + Gladdy.db.bottomMargin) / 2,
                        }),
                        cooldownWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon Width Factor"],
                            desc = L["Stretches the icon"],
                            order = 5,
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                        }),
                        cooldownIconPadding = Gladdy:option({
                            type = "range",
                            name = L["Icon Padding"],
                            desc = L["Space between Icons"],
                            order = 6,
                            min = 0,
                            max = 10,
                            step = 0.1,
                        }),
                        cooldownMaxIconsPerLine = Gladdy:option({
                            type = "range",
                            name = L["Max Icons per row"],
                            order = 7,
                            min = 3,
                            max = 14,
                            step = 1,
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
                        }),
                        cooldownCooldownAlpha = Gladdy:option({
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
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Position"],
                            order = 2,
                        },
                        cooldownYPos = option({
                            type = "select",
                            name = L["Anchor"],
                            desc = L["Anchor of the cooldown icons"],
                            order = 3,
                            values = {
                                ["TOP"] = L["Top"],
                                ["BOTTOM"] = L["Bottom"],
                                ["LEFT"] = L["Left"],
                                ["RIGHT"] = L["Right"],
                            },
                        }),
                        cooldownXPos = Gladdy:option({
                            type = "select",
                            name = L["Grow Direction"],
                            desc = L["Grow Direction of the cooldown icons"],
                            order = 4,
                            values = {
                                ["LEFT"] = L["Right"],
                                ["RIGHT"] = L["Left"],
                            },
                        }),
                        headerOffset = {
                            type = "header",
                            name = L["Offset"],
                            order = 5,
                        },
                        cooldownXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 6,
                            min = -400,
                            max = 400,
                            step = 0.1,
                        }),
                        cooldownYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 7,
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
            },
        },
    }
end

function Gladdy:UpdateTestCooldowns(i)
    local unit = "arena" .. i
    local button = Gladdy.buttons[unit]

    if (button.testSpec and button.testSpec == Gladdy.testData[unit].testSpec) then
        button.lastCooldownSpell = 1
        Cooldowns:UpdateCooldowns(button)
        button.spec = nil
        Cooldowns:DetectSpec(unit, button.testSpec)

        -- use class spells
        for k, v in pairs(Cooldowns.cooldownSpells[button.class]) do
            --k is spellId
            Cooldowns:CooldownUsed(unit, button.class, k, nil)
        end
        -- use race spells
        for k, v in pairs(Cooldowns.cooldownSpells[button.race]) do
            Cooldowns:CooldownUsed(unit, button.race, k, nil)
        end
    end
end

Cooldowns.cooldownSpells = {
    -- Spell Name			   Cooldown[, Spec]
    -- Mage
    ["MAGE"] = {
        [1953] = 15, -- Blink
        --[122] 	= 22,    -- Frost Nova
        --[12051] = 480, --Evocation
        [2139] = 24, -- Counterspell
        [45438] = { cd = 300, [L["Frost"]] = 240, }, -- Ice Block
        [12472] = { cd = 180, spec = L["Frost"], }, -- Icy Veins
        [31687] = { cd = 180, spec = L["Frost"], }, -- Summon Water Elemental
        [12043] = { cd = 180, spec = L["Arcane"], }, -- Presence of Mind
        [11129] = { cd = 180, spec = L["Fire"] }, -- Combustion
        [120] = { cd = 10,
                  sharedCD = {
                      [31661] = true, -- Cone of Cold
                  }, spec = L["Fire"] }, -- Dragon's Breath
        [31661] = { cd = 20,
                    sharedCD = {
                        [120] = true, -- Cone of Cold
                    }, spec = L["Fire"] }, -- Dragon's Breath
        [12042] = { cd = 180, spec = L["Arcane"], }, -- Arcane Power
        [11958] = { cd = 384, spec = L["Frost"], -- Coldsnap
                    resetCD = {
                        [12472] = true,
                        [45438] = true,
                        [31687] = true,
                    },
        },
    },

    -- Priest
    ["PRIEST"] = {
        [10890] = { cd = 27, [L["Shadow"]] = 23, }, -- Psychic Scream
        [15487] = { cd = 45, spec = L["Shadow"], }, -- Silence
        [10060] = { cd = 180, spec = L["Discipline"], }, -- Power Infusion
        [33206] = { cd = 120, spec = L["Discipline"], }, -- Pain Suppression
        [34433] = 300, -- Shadowfiend
    },

    -- Druid
    ["DRUID"] = {
        [22812] = 60, -- Barkskin
        [29166] = 360, -- Innervate
        [8983] = 60, -- Bash
        [16689] = 60, -- Natures Grasp
        [17116] = { cd = 180, spec = L["Restoration"], }, -- Natures Swiftness
        [33831] = { cd = 180, spec = L["Balance"], }, -- Force of Nature
    },

    -- Shaman
    ["SHAMAN"] = {
        [8042] = { cd = 6, -- Earth Shock
                   sharedCD = {
                       [8056] = true, -- Frost Shock
                       [8050] = true, -- Flame Shock
                   },
        },
        [30823] = { cd = 120, spec = L["Enhancement"], }, -- Shamanistic Rage
        [16166] = { cd = 180, spec = L["Elemental"], }, -- Elemental Mastery
        [16188] = { cd = 180, spec = L["Restoration"], }, -- Natures Swiftness
        [16190] = { cd = 300, spec = L["Restoration"], }, -- Mana Tide Totem
    },

    -- Paladin
    ["PALADIN"] = {
        [10278] = 180, -- Blessing of Protection
        [1044] = 25, -- Blessing of Freedom
        [10308] = { cd = 60, [L["Retribution"]] = 40, }, -- Hammer of Justice
        [642] = { cd = 300, -- Divine Shield
                  sharedCD = {
                      cd = 60, -- no actual shared CD but debuff
                      [31884] = true,
                  },
        },
        [31884] = { cd = 180, spec = L["Retribution"], -- Avenging Wrath
                    sharedCD = {
                        cd = 60,
                        [642] = true,
                    },
        },
        [20066] = { cd = 60, spec = L["Retribution"], }, -- Repentance
        [31842] = { cd = 180, spec = L["Holy"], }, -- Divine Illumination
        [31935] = { cd = 30, spec = L["Protection"], }, -- Avengers Shield

    },

    -- Warlock
    ["WARLOCK"] = {
        [17928] = 40, -- Howl of Terror
        [27223] = 120, -- Death Coil
        --[19647] 	= { cd = 24 },	-- Spell Lock; how will I handle pet spells?
        [30414] = { cd = 20, spec = L["Destruction"], }, -- Shadowfury
        [17877] = { cd = 15, spec = L["Destruction"], }, -- Shadowburn
        [18708] = { cd = 900, spec = L["Demonology"], }, -- Feldom
    },

    -- Warrior
    ["WARRIOR"] = {
        --[[6552] 	= { cd = 10,                              -- Pummel
           sharedCD = {
              [72] = true,
           },
        },
        [72] 	   = { cd = 12,                              -- Shield Bash
           sharedCD = {
              [6552] = true,
           },
        }, ]]
        --[23920] 	= 10,    -- Spell Reflection
        [3411] = 30, -- Intervene
        [676] = 60, -- Disarm
        [5246] = 180, -- Intimidating Shout
        --[2565] 	= 60,    -- Shield Block
        [12292] = { cd = 180, spec = L["Arms"], }, -- Death Wish
        [12975] = { cd = 180, spec = L["Protection"], }, -- Last Stand
        [12809] = { cd = 30, spec = L["Protection"], }, -- Concussion Blow

    },

    -- Hunter
    ["HUNTER"] = {
        [19503] = 30, -- Scatter Shot
        [19263] = 300, -- Deterrence; not on BM but can't do 2 specs
        [14311] = { cd = 30, -- Freezing Trap
                    sharedCD = {
                        [13809] = true, -- Frost Trap
                        [34600] = true, -- Snake Trap
                    },
        },
        [13809] = { cd = 30, -- Frost Trap
                    sharedCD = {
                        [14311] = true, -- Freezing Trap
                        [34600] = true, -- Snake Trap
                    },
        },
        [34600] = { cd = 30, -- Snake Trap
                    sharedCD = {
                        [14311] = true, -- Freezing Trap
                        [13809] = true, -- Frost Trap
                    },
        },
        [34490] = { cd = 20, spec = L["Marksmanship"], }, -- Silencing Shot
        [19386] = { cd = 60, spec = L["Survival"], }, -- Wyvern Sting
        [19577] = { cd = 60, spec = L["Beast Mastery"], }, -- Intimidation
        [38373] = { cd = 120, spec = L["Beast Mastery"], }, -- The Beast Within
    },

    -- Rogue
    ["ROGUE"] = {
        [1766] 	= 10,    -- Kick
        [8643] 	= 20,    -- Kidney Shot
        [31224] = 60, -- Cloak of Shadow
        [26889] = { cd = 300, [L["Subtlety"]] = 180, }, -- Vanish
        [2094] = { cd = 180, [L["Subtlety"]] = 90, }, -- Blind
        [11305] = { cd = 300, [L["Combat"]] = 180, }, -- Sprint
        [26669] = { cd = 300, [L["Combat"]] = 180, }, -- Evasion
        [14177] = { cd = 180, spec = L["Assassination"], }, -- Cold Blood
        [13750] = { cd = 300, spec = L["Combat"], }, -- Adrenaline Rush
        [13877] = { cd = 120, spec = L["Combat"], }, -- Blade Flurry
        [36554] = { cd = 30, spec = L["Subtlety"], }, -- Shadowstep
        [14185] = { cd = 600, spec = L["Subtlety"], -- Preparation
                    resetCD = {
                        [26669] = true,
                        [11305] = true,
                        [26889] = true,
                        [14177] = true,
                        [36554] = true,
                    },
        },
    },
    ["Scourge"] = {
        [7744] = 120, -- Will of the Forsaken
    },
    ["BloodElf"] = {
        [28730] = 120, -- Arcane Torrent
    },
    ["Tauren"] = {
        [20549] = 120, -- War Stomp
    },
    ["Orc"] = {

    },
    ["Troll"] = {

    },
    ["NightElf"] = {
        [2651] = { cd = 180, spec = L["Discipline"], }, -- Elune's Grace
        [10797] = { cd = 30, spec = L["Discipline"], }, -- Star Shards
    },
    ["Draenei"] = {
        [32548] = { cd = 300, spec = L["Discipline"], }, -- Hymn of Hope
    },
    ["Human"] = {
        [13908] = { cd = 600, spec = L["Discipline"], }, -- Desperate Prayer
        [20600] = 180, -- Perception
    },
    ["Gnome"] = {
        [20589] = 105, -- Escape Artist
    },
    ["Dwarf"] = {
        [20594] = 180, -- Stoneform
        [13908] = { cd = 600, spec = L["Discipline"], }, -- Desperate Prayer
    },
}