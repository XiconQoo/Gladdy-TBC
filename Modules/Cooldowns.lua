local type, pairs, ceil, tonumber, mod, tostring, upper, select = type, pairs, ceil, tonumber, mod, tostring, string.upper, select
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
                Gladdy:Print("spellid does not exist  " .. spellId)
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
    cooldownCooldownAlpha = 1,
    cooldownCooldowns = getDefaultCooldown()
})

function Cooldowns:Initialize()
    self.cooldownSpellIds = {}
    self.spellTextures = {}
    for _,spellTable in pairs(Gladdy:GetCooldownList()) do
        for spellId,_ in pairs(spellTable) do
            local spellName, _, texture = GetSpellInfo(spellId)
            if spellName then
                self.cooldownSpellIds[spellName] = spellId
                self.spellTextures[spellId] = texture
            else
                Gladdy:Print("spellid does not exist  " .. spellId)
            end
        end
    end
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("SPEC_DETECTED")
    self:RegisterMessage("UNIT_DEATH")
    self:RegisterMessage("UNIT_DESTROYED")
end

function Cooldowns:CreateFrame(unit)
    local button = Gladdy.buttons[unit]
    -- Cooldown frame
    local spellCooldownFrame = CreateFrame("Frame", nil, button)
    spellCooldownFrame:EnableMouse(false)
    for x = 1, 14 do
        local icon = CreateFrame("Frame", nil, spellCooldownFrame)
        icon:EnableMouse(false)
        icon:SetFrameLevel(3)
        icon.texture = icon:CreateTexture(nil, "BACKGROUND")
        icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
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
        icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2  * Gladdy.db.cooldownFontScale, "OUTLINE")
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
        local powerBarHeight = Gladdy.db.powerBarEnabled and (Gladdy.db.powerBarHeight + 1) or 0
        local horizontalMargin = (Gladdy.db.highlightInset and 0 or Gladdy.db.highlightBorderSize)
        if Gladdy.db.cooldownYPos == "TOP" then
            if Gladdy.db.cooldownXPos == "RIGHT" then
                button.spellCooldownFrame:SetPoint("BOTTOMRIGHT", button.healthBar, "TOPRIGHT", Gladdy.db.cooldownXOffset, horizontalMargin + Gladdy.db.cooldownYOffset)
            else
                button.spellCooldownFrame:SetPoint("BOTTOMLEFT", button.healthBar, "TOPLEFT", Gladdy.db.cooldownXOffset, horizontalMargin + Gladdy.db.cooldownYOffset)
            end
        elseif Gladdy.db.cooldownYPos == "BOTTOM" then
            if Gladdy.db.cooldownXPos == "RIGHT" then
                button.spellCooldownFrame:SetPoint("TOPRIGHT", button.healthBar, "BOTTOMRIGHT", Gladdy.db.cooldownXOffset, -horizontalMargin + Gladdy.db.cooldownYOffset - powerBarHeight)
            else
                button.spellCooldownFrame:SetPoint("TOPLEFT", button.healthBar, "BOTTOMLEFT", Gladdy.db.cooldownXOffset, -horizontalMargin + Gladdy.db.cooldownYOffset - powerBarHeight)
            end
        elseif Gladdy.db.cooldownYPos == "LEFT" then
            local anchor = Gladdy:GetAnchor(unit, "LEFT")
            if anchor == Gladdy.buttons[unit].healthBar then
                button.spellCooldownFrame:SetPoint("RIGHT", anchor, "LEFT", -(horizontalMargin + Gladdy.db.padding) + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset)
            else
                button.spellCooldownFrame:SetPoint("RIGHT", anchor, "LEFT", -Gladdy.db.padding + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset)
            end
        elseif Gladdy.db.cooldownYPos == "RIGHT" then
            local anchor = Gladdy:GetAnchor(unit, "RIGHT")
            if anchor == Gladdy.buttons[unit].healthBar then
                button.spellCooldownFrame:SetPoint("LEFT", anchor, "RIGHT", horizontalMargin + Gladdy.db.padding + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset)
            else
                button.spellCooldownFrame:SetPoint("LEFT", anchor, "RIGHT", Gladdy.db.padding + Gladdy.db.cooldownXOffset, Gladdy.db.cooldownYOffset)
            end
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
            icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2 * Gladdy.db.cooldownFontScale, "OUTLINE")
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

            icon.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), (icon:GetWidth()/2 - 1) * Gladdy.db.cooldownFontScale, "OUTLINE")
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
    local button = Gladdy.buttons[unit]
    if Gladdy.db.cooldown then
        button.spellCooldownFrame:Show()
        button.lastCooldownSpell = 1
        self:UpdateTestCooldowns(unit)
    else
        button.spellCooldownFrame:Hide()
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
        for spellId,_ in pairs(Gladdy:GetCooldownList()[button.class]) do
            self:CooldownUsed(unit, button.class, spellId)
        end
        -- use race spells
        for spellId,_ in pairs(Gladdy:GetCooldownList()[button.race]) do
            self:CooldownUsed(unit, button.race, spellId)
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
                    self.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 3.1 * Gladdy.db.cooldownFontScale, "OUTLINE")
                elseif timeLeft < 540 and timeLeft >= 60 then
                    self.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2.15 * Gladdy.db.cooldownFontScale, "OUTLINE")
                elseif timeLeft < 60 and timeLeft > 0 then
                    self.cooldownFont:SetFont(Gladdy:SMFetch("font", "cooldownFont"), Gladdy.db.cooldownSize / 2.15 * Gladdy.db.cooldownFontScale, "OUTLINE")
                end
                Gladdy:FormatTimer(self.cooldownFont, self.timeLeft, self.timeLeft < 0)
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
    if button.class == "PALADIN" and (spec ~= L["Holy"] or spec ~= L["Retribution"]) then
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
        for k, v in pairs(Gladdy:GetCooldownList()[class]) do
            if Gladdy.db.cooldownCooldowns[tostring(k)] then
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
        --end
    end
    ----------------------
    --- RACE FUNCTIONALITY
    ----------------------
    local race = Gladdy.buttons[unit].race
    if Gladdy:GetCooldownList()[race] then
        for k, v in pairs(Gladdy:GetCooldownList()[race]) do
            if Gladdy.db.cooldownCooldowns[tostring(k)] then
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
end

function Cooldowns:ResetUnit(unit)
    Gladdy.buttons[unit].lastCooldownSpell = nil
    Gladdy.buttons[unit].test = nil
end

function Cooldowns:UNIT_DESTROYED(unit)

end

function Cooldowns:UpdateCooldowns(button)
    local class = button.class
    local race = button.race
    if ( not button.lastCooldownSpell) then
        button.lastCooldownSpell = 1
    end

    if (Gladdy.db.cooldown) then
        for k, v in pairs(Gladdy:GetCooldownList()[class]) do
            if Gladdy.db.cooldownCooldowns[tostring(k)] then
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
        end
        ----
        -- RACE FUNCTIONALITY
        ----

        for k, v in pairs(Gladdy:GetCooldownList()[race]) do
            if Gladdy.db.cooldownCooldowns[tostring(k)] then
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
end

function Cooldowns:CooldownUsed(unit, unitClass, spellId)
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
                    self:CooldownStart(button, spellID, sharedCD)
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
                        cooldownMaxIconsPerLine = Gladdy:option({
                            type = "range",
                            name = L["Max Icons per row"],
                            order = 7,
                            min = 3,
                            max = 14,
                            step = 1,
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
                            width = "full",
                        }),
                        cooldownYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 7,
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

function Gladdy:UpdateTestCooldowns(i)
    local unit = "arena" .. i
    local button = Gladdy.buttons[unit]

    if (button.testSpec and button.testSpec == Gladdy.testData[unit].testSpec) then
        button.lastCooldownSpell = 1
        Cooldowns:UpdateCooldowns(button)
        button.spec = nil
        Cooldowns:DetectSpec(unit, button.testSpec)

        -- use class spells
        for spellID,_ in pairs(Gladdy:GetCooldownList()[button.class]) do
            --k is spellId
            Cooldowns:CooldownUsed(unit, button.class, spellID)
        end
        -- use race spells
        for spellID,_ in pairs(Gladdy:GetCooldownList()[button.race]) do
            Cooldowns:CooldownUsed(unit, button.race, spellID)
        end
    end
end