local select, string_gsub, tostring, pairs, ipairs = select, string.gsub, tostring, pairs, ipairs
local wipe = wipe
local unpack = unpack

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local AURA_TYPE_DEBUFF = AURA_TYPE_DEBUFF
local AURA_TYPE_BUFF = AURA_TYPE_BUFF

local UnitName, UnitAura, UnitRace, UnitClass, UnitGUID, UnitIsUnit, UnitExists = UnitName, UnitAura, UnitRace, UnitClass, UnitGUID, UnitIsUnit, UnitExists
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local GetSpellInfo = GetSpellInfo
local FindAuraByName = AuraUtil.FindAuraByName
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Cooldowns = Gladdy.modules["Cooldowns"]
local Diminishings = Gladdy.modules["Diminishings"]

local EventListener = Gladdy:NewModule("EventListener", 101, {
    test = true,
})

function EventListener:Initialize()
    self.friendlyUnits = {}
    self:RegisterMessage("JOINED_ARENA")
end

function EventListener.OnEvent(self, event, ...)
    EventListener[event](self, ...)
end

function EventListener:JOINED_ARENA()
    self.friendlyUnits = {["player"] = true}
    for i=2, Gladdy.curBracket do
        self.friendlyUnits["party" .. i-1] = true
    end
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("ARENA_OPPONENT_UPDATE")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    -- in case arena has started already we check for units
    for i=1,Gladdy.curBracket do
        if Gladdy.buttons["arena"..i].lastAuras then
            wipe(Gladdy.buttons["arena"..i].lastAuras)
        end
        if Gladdy.buttons["arena"..i].lastCastSpell then
            wipe(Gladdy.buttons["arena"..i].lastCastSpell)
        end
        if UnitExists("arena" .. i) then
            Gladdy:SpotEnemy("arena" .. i, true, true)
        end
        if UnitExists("arenapet" .. i) then
            Gladdy:SendMessage("PET_SPOTTED", "arenapet" .. i)
        end
    end
    Gladdy.bombExpireTime = {}
    self:SetScript("OnEvent", EventListener.OnEvent)
end

function EventListener:Reset()
    self:UnregisterAllEvents()
    self:SetScript("OnEvent", nil)
    self.friendlyUnits = {}
    Gladdy.bombExpireTime = {}
end

function Gladdy:SpotEnemy(unit, auraScan, report)
    local button = self.buttons[unit]
    if not unit or not button then
        return
    end
    if UnitExists(unit) then
        button.raceLoc = UnitRace(unit)
        button.race = select(2, UnitRace(unit))
        button.classLoc = select(1, UnitClass(unit))
        button.class = select(2, UnitClass(unit))
        button.name = UnitName(unit)
        Gladdy.guids[UnitGUID(unit)] = unit
    end
    if button.class and button.race and report then
        Gladdy:SendMessage("ENEMY_SPOTTED", unit)
    end
    if auraScan and not button.spec then
        EventListener:ScanAuras(unit)
    end
end

function EventListener:CooldownCheck(eventType, srcUnit, spellName, spellID)
    if not Gladdy.buttons[srcUnit] or not spellName or not spellID then
        return
    end
    if Gladdy.db.cooldown and Cooldowns.cooldownSpells[spellName] then
        local unitClass
        local spellId = Cooldowns.cooldownSpells[spellName] -- don't use spellId from combatlog, in case of different spellrank
        if spellID == 16188 or spellID == 17116 then -- Nature's Swiftness (same name for druid and shaman)
            spellId = spellID
        end
        if Gladdy.db.cooldownCooldowns[tostring(spellId)] then
            if (Gladdy:GetCooldownList()[Gladdy.buttons[srcUnit].class][spellId]) then
                unitClass = Gladdy.buttons[srcUnit].class
            else
                unitClass = Gladdy.buttons[srcUnit].race
            end
            --TODO find a better solution
            if spellID ~= 16188 and spellID ~= 17116 and spellID ~= 16166 and spellID ~= 12043 and spellID ~= 5384 or spellID == 14751 or spellID == 89485 then -- Nature's Swiftness CD starts when buff fades
                Gladdy:Debug("INFO", eventType, "- CooldownUsed", srcUnit, "spellID:", spellID)
                Cooldowns:CooldownUsed(srcUnit, unitClass, spellId)
            end
        end
    end
end

function EventListener:COMBAT_LOG_EVENT_UNFILTERED()
    -- timestamp,eventType,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellId,spellName,spellSchool
    local _,eventType,_,sourceGUID,_,_,_,destGUID,_,_,_,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool = CombatLogGetCurrentEventInfo()
    local srcUnit = Gladdy.guids[sourceGUID] -- can be a PET
    local destUnit = Gladdy.guids[destGUID] -- can be a PET
    if (Gladdy.db.shadowsightTimerEnabled and eventType == "SPELL_AURA_APPLIED" and spellID == 34709) then
        Gladdy.modules["Shadowsight Timer"]:AURA_GAIN(nil, nil, 34709)
    end

    if Gladdy.exceptionNames[spellID] then
        spellName = Gladdy.exceptionNames[spellID]
    end
    -- smoke bomb
    if (eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED") and spellID == 76577 then
        local now = GetTime()
        if (Gladdy.bombExpireTime[sourceGUID] and now >= Gladdy.bombExpireTime[sourceGUID]) or eventType == "SPELL_CAST_SUCCESS" then
            Gladdy.bombExpireTime[sourceGUID] = now + 6
        elseif not Gladdy.bombExpireTime[sourceGUID] then
            Gladdy.bombExpireTime[sourceGUID] = now + 6
        end
    end
    if destUnit then
        -- diminish tracker
        if Gladdy.buttons[destUnit] and Gladdy.db.drEnabled and extraSpellId == AURA_TYPE_DEBUFF then
            if (eventType == "SPELL_AURA_REMOVED") then
                Diminishings:AuraFade(destUnit, spellID)
            end
            if (eventType == "SPELL_AURA_REFRESH") then
                if not Gladdy.db.drShowIconOnAuraApplied then
                    Diminishings:AuraFade(destUnit, spellID)
                end
                Diminishings:AuraGain(destUnit, spellID)
            end
            if (eventType == "SPELL_AURA_APPLIED") then
                Diminishings:AuraGain(destUnit, spellID)
            end
        end
        -- death detection
        if (eventType == "UNIT_DIED" or eventType == "PARTY_KILL" or eventType == "SPELL_INSTAKILL") then
            if not Gladdy:isFeignDeath(destUnit) then
                Gladdy:SendMessage("UNIT_DEATH", destUnit)
            end
        end
        -- spec detection
        if Gladdy.buttons[destUnit] and (not Gladdy.buttons[destUnit].class or not Gladdy.buttons[destUnit].race) then
            Gladdy:SpotEnemy(destUnit, true, true)
        end
        --interrupt detection
        if Gladdy.buttons[destUnit] then
            if eventType == "SPELL_INTERRUPT" then
                Gladdy:SendMessage("SPELL_INTERRUPT", destUnit,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool)
            elseif (eventType == "SPELL_CAST_SUCCESS" and Gladdy:GetInterrupts()[spellName]) then
                local spellNameChanneled, _, _, _, _, _, interruptable, spellIdChanneled = UnitChannelInfo(destUnit)
                if interruptable == false and spellNameChanneled then
                    if Gladdy.buttons[destUnit].lastCastSpell and Gladdy.buttons[destUnit].lastCastSpell.spellName == spellNameChanneled then
                        extraSpellSchool = Gladdy.buttons[destUnit].lastCastSpell.spellSchool
                    end
                    Gladdy:SendMessage("SPELL_INTERRUPT", destUnit,spellID,spellName,spellSchool,spellIdChanneled,spellNameChanneled,extraSpellSchool)
                end
            end
        end
    end
    if srcUnit then
        srcUnit = string_gsub(srcUnit, "pet", "")
        if (not UnitExists(srcUnit)) then
            return
        end
        if not Gladdy.buttons[srcUnit].class or not Gladdy.buttons[srcUnit].race then
            Gladdy:SpotEnemy(srcUnit, true, true)
        end
        if not Gladdy.buttons[srcUnit].spec then
            self:DetectSpec(srcUnit, Gladdy.specSpells[spellName])
        end
        if (eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_MISSED" or eventType == "SPELL_DODGED") then
            -- caching last cast spell
            if not Gladdy.buttons[srcUnit].lastCastSpell then
                Gladdy.buttons[srcUnit].lastCastSpell = {}
            end
            Gladdy.buttons[srcUnit].lastCastSpell.spellName = spellName
            Gladdy.buttons[srcUnit].lastCastSpell.spellSchool = spellSchool
            -- cooldown tracker
            EventListener:CooldownCheck(eventType, srcUnit, spellName, spellID)
        end
        if (eventType == "SPELL_AURA_APPLIED") then
            EventListener:CooldownCheck(eventType, srcUnit, spellName, spellID)
        end
        --TODO find a better solution
        if (eventType == "SPELL_AURA_REMOVED" and (spellID == 16188 or spellID == 17116 or spellID == 16166 or spellID == 12043 or spellID == 14751 or spellID == 89485) and Gladdy.buttons[srcUnit].class) then
            Gladdy:Debug("INFO", "SPELL_AURA_REMOVED - CooldownUsed", srcUnit, "spellID:", spellID)
            Cooldowns:CooldownUsed(srcUnit, Gladdy.buttons[srcUnit].class, spellID)
        end
        if (eventType == "SPELL_AURA_REMOVED" and Gladdy.db.cooldown and Cooldowns.cooldownSpells[spellName]) then
            local unit = Gladdy:GetArenaUnit(srcUnit, true)
            local spellId = Cooldowns.cooldownSpells[spellName] -- don't use spellId from combatlog, in case of different spellrank
            if spellID == 16188 or spellID == 17116 then -- Nature's Swiftness (same name for druid and shaman)
                spellId = spellID
            end
            if unit then
                --Gladdy:Debug("INFO", "EL:CL:SPELL_AURA_REMOVED (srcUnit)", "Cooldowns:AURA_FADE", unit, spellId)
                Cooldowns:AURA_FADE(unit, spellId, spellName)
            end
        end
    end
end

function EventListener:ARENA_OPPONENT_UPDATE(unit, updateReason)
    --[[ updateReason: seen, unseen, destroyed, cleared ]]

    unit = Gladdy:GetArenaUnit(unit)
    local button = Gladdy.buttons[unit]
    local pet = Gladdy.modules["Pets"].frames[unit]
    Gladdy:Debug("INFO", "ARENA_OPPONENT_UPDATE", unit, updateReason)
    if button or pet then
        if updateReason == "seen" then
            -- ENEMY_SPOTTED
            if button then
                button.stealthed = false
                Gladdy:SendMessage("ENEMY_STEALTH", unit, false)
                if not button.class or not button.race then
                    Gladdy:SpotEnemy(unit, true, true)
                end
            end
            if pet then
                Gladdy:SendMessage("PET_SPOTTED", unit)
            end
        elseif updateReason == "unseen" then
            -- STEALTH
            if button then
                button.stealthed = true
                Gladdy:SendMessage("ENEMY_STEALTH", unit, true)
            end
            if pet then
                Gladdy:SendMessage("PET_STEALTH", unit)
            end
        elseif updateReason == "destroyed" then
            -- LEAVE
            if button then
                Gladdy:SendMessage("UNIT_DESTROYED", unit)
            end
            if pet then
                Gladdy:SendMessage("PET_DESTROYED", unit)
            end
        elseif updateReason == "cleared" then
            --Gladdy:Print("ARENA_OPPONENT_UPDATE", updateReason, unit)
        end
    end
end

Gladdy.cooldownBuffs = {
    [GetSpellInfo(6346)] = { cd = function(expTime) -- 180s uptime == cd
        return expTime
    end, spellId = 6346 }, -- Fear Ward
    [GetSpellInfo(2983)] = { cd = function(expTime) -- 15s uptime
        return 60 - (8 - expTime)
    end, spellId = 2983, class = "ROGUE" }, -- Sprint
    [36554] = { cd = function(expTime) -- 3s uptime
        return 30 - (3 - expTime)
    end, spellId = 36554, class = "ROGUE" }, -- Shadowstep speed buff
    [36563] = { cd = function(expTime) -- 10s uptime
        return 30 - (10 - expTime)
    end, spellId = 36554 }, -- Shadowstep dmg buff
    [GetSpellInfo(1856)] = { cd = function(expTime) -- 3s uptime
        return 180 - (3 - expTime)
    end, spellId = 1856, class = "ROGUE" }, -- Vanish
    racials = {
        --[[[GetSpellInfo(20600)] = { cd = function(expTime) -- 20s uptime
            return GetTime() - (20 - expTime)
        end, spellId = 20600 }, -- Perception]]
    },
    [GetSpellInfo(31224)] = { cd = function(expTime) -- 180s uptime == cd
        return 60 - (5 - expTime)
    end, spellId = 31224, class = "ROGUE" }, -- Cloak of Shadows
    [GetSpellInfo(2094)] = { cd = function(expTime) -- 180s uptime == cd
        return 120 - (10 - expTime)
    end, spellId = 2094, class = "ROGUE" }, -- Blind
}
--[[
/run local f,sn,dt for i=1,2 do f=(i==1 and "HELPFUL"or"HARMFUL")for n=1,30 do sn,_,_,dt=UnitAura("player",n,f) if(not sn)then break end print(sn,dt,dt and dt:len())end end
--]]
function EventListener:UNIT_AURA(unit, isFullUpdate, updatedAuras)
    local button = Gladdy.buttons[unit]
    if not button then
        local skip = true
        for i=1, Gladdy.curBracket do
            if not Gladdy.buttons["arena" .. i].class then
                skip = false
                break
            end
        end
        if not skip then
            if self.friendlyUnits[unit] then -- this is mainly for Blind detection when the unit was not seen before
                for n = 1, 30 do
                    local spellName, texture, count, dispelType, duration, expirationTime, unitCaster, _, shouldConsolidate, spellID = UnitAura(unit, n, "HARMFUL")
                    if spellName and (Gladdy.cooldownBuffs[spellName] or Gladdy.cooldownBuffs[spellID]) and unitCaster then
                        local cooldownBuff = Gladdy.cooldownBuffs[spellID] or Gladdy.cooldownBuffs[spellName]
                        for arenaUnit,v in pairs(Gladdy.buttons) do
                            if (UnitIsUnit(arenaUnit, unitCaster)) then
                                if not v.class then
                                    Gladdy:SpotEnemy(arenaUnit, false, true)
                                end
                                if not v.class and Gladdy.expansion == "Wrath" then
                                    Gladdy.buttons[arenaUnit].class = Gladdy.cooldownBuffs[spellName].class
                                    Cooldowns:UpdateCooldowns(Gladdy.buttons[arenaUnit])
                                end
                                Cooldowns:CooldownUsed(arenaUnit, Gladdy.buttons[arenaUnit].class, cooldownBuff.spellId, cooldownBuff.cd(expirationTime - GetTime()))
                            end
                        end
                    else
                        break
                    end
                end
            end
        end
        return
    end
    EventListener:ScanAuras(unit)
end

function EventListener:ScanAuras(unit)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end

    if not button.auras then
        button.auras = {}
    end
    wipe(button.auras)
    if not button.lastAuras then
        button.lastAuras = {}
    end

    local unitPet = string_gsub(unit, "%d$", "pet%1")

    Gladdy:SendMessage("AURA_FADE", unit, AURA_TYPE_BUFF)
    Gladdy:SendMessage("AURA_FADE", unit, AURA_TYPE_DEBUFF)
    for i = 1, 2 do
        if not Gladdy.buttons[unit].class or not Gladdy.buttons[unit].race then
            Gladdy:SpotEnemy(unit, false, true)
        end
        local filter = (i == 1 and "HELPFUL" or "HARMFUL")
        local auraType = i == 1 and AURA_TYPE_BUFF or AURA_TYPE_DEBUFF
        for n = 1, 30 do
            local auraTypeTemp = auraType
            local spellName, texture, count, dispelType, duration, expirationTime, unitCaster, _, shouldConsolidate, spellID = UnitAura(unit, n, filter)
            if ( not spellID ) then
                Gladdy:SendMessage("AURA_GAIN_LIMIT", unit, auraType, n - 1)
                break
            end

            if Gladdy.exceptionNames[spellID] then
                spellName = Gladdy.exceptionNames[spellID]
            end
            button.auras[spellID] = { auraType, spellID, spellName, texture, duration, expirationTime, count, dispelType }
            if not button.spec and Gladdy.specSpells[spellName] and unitCaster then
                if unitCaster and (UnitIsUnit(unit, unitCaster) or UnitIsUnit(unitPet, unitCaster)) then
                    self:DetectSpec(unit, Gladdy.specSpells[spellName])
                end
            end
            if (Gladdy.cooldownBuffs[spellName] or Gladdy.cooldownBuffs[spellID]) and unitCaster then -- Check for auras that hint used CDs (like Fear Ward)
                local cooldownBuff = Gladdy.cooldownBuffs[spellID] or Gladdy.cooldownBuffs[spellName]
                for arenaUnit,v in pairs(Gladdy.buttons) do
                    if (UnitIsUnit(arenaUnit, unitCaster)) then
                        Cooldowns:CooldownUsed(arenaUnit, v.class, cooldownBuff.spellId, cooldownBuff.cd(expirationTime - GetTime()))
                    end
                end
            end
            if Gladdy.cooldownBuffs.racials[spellName] then
                Gladdy:SendMessage("RACIAL_USED", unit, spellName, Gladdy.cooldownBuffs.racials[spellName].cd(expirationTime - GetTime()), spellName)
            end
            local sourceGUID = unitCaster and UnitGUID(unitCaster)
            if spellID == 88611 and Gladdy.bombExpireTime[sourceGUID] then
                duration = 6
                expirationTime = Gladdy.bombExpireTime[sourceGUID]
            end
            Gladdy:SendMessage("AURA_GAIN", unit, auraType, spellID, spellName, texture, duration, expirationTime, count, dispelType, i, unitCaster)
        end
    end
    -- check lastAuras for Cooldown detection of spells that trigger cd if buff fades
    for spellID,v in pairs(button.lastAuras) do
        if not button.auras[spellID] then
            local spellName = v[3]
            if Gladdy.db.cooldown and Cooldowns.cooldownSpells[spellName] then
                local spellId = Cooldowns.cooldownSpells[spellName] -- don't use spellId from combatlog, in case of different spellrank
                if spellID == 16188 or spellID == 17116 then -- Nature's Swiftness (same name for druid and shaman)
                    spellId = spellID
                end
                --Gladdy:Debug("INFO", "EL:UNIT_AURA Cooldowns:AURA_FADE", unit, spellId)
                Cooldowns:AURA_FADE(unit, spellId, spellName)
                if spellID == 5384 then -- Feign Death CD Detection needs this
                    Cooldowns:CooldownUsed(unit, Gladdy.buttons[unit].class, 5384)
                end
            end
        end
    end
    wipe(button.lastAuras)
    button.lastAuras = Gladdy:DeepCopy(button.auras)
end

function EventListener:UpdateAuras(unit)
    local button = Gladdy.buttons[unit]
    if not button or button.lastAuras then
        return
    end
    for i=1, #button.lastAuras do
        Gladdy.modules["Auras"]:AURA_GAIN(unit, unpack(button.lastAuras[i]))
    end
end

function EventListener:UNIT_SPELLCAST_START(unit)
    if Gladdy.buttons[unit] then
        local spellName = UnitCastingInfo(unit)
        if Gladdy.specSpells[spellName] and not Gladdy.buttons[unit].spec then
            self:DetectSpec(unit, Gladdy.specSpells[spellName])
        end
    end
end

function EventListener:UNIT_SPELLCAST_CHANNEL_START(unit)
    if Gladdy.buttons[unit] then
        local spellName = UnitChannelInfo(unit)
        if Gladdy.specSpells[spellName] and not Gladdy.buttons[unit].spec then
            self:DetectSpec(unit, Gladdy.specSpells[spellName])
        end
    end
end

function EventListener:UNIT_SPELLCAST_SUCCEEDED(...)
    local unit, castGUID, spellID = ...
    unit = Gladdy:GetArenaUnit(unit, true)
    local button = Gladdy.buttons[unit]
    if button then
        if not button.class or not button.race then
            Gladdy:SpotEnemy(unit, false, true)
        end
        local spellName = GetSpellInfo(spellID)
        local unitRace = button.race
        local unitClass = button.class

        if Gladdy.exceptionNames[spellID] then
            spellName = Gladdy.exceptionNames[spellID]
        end

        -- spec detection
        if spellName and Gladdy.specSpells[spellName] and not button.spec then
            self:DetectSpec(unit, Gladdy.specSpells[spellName])
        end

        -- trinket
        if spellID == 42292 or spellID == 59752 then
            Gladdy:Debug("INFO", "UNIT_SPELLCAST_SUCCEEDED - TRINKET_USED", unit, spellID)
            Gladdy:SendMessage("TRINKET_USED", unit)
        end

        -- racial
        if unitRace and  Gladdy:Racials()[unitRace].spellName == spellName and Gladdy:Racials()[unitRace][spellID] then
            Gladdy:Debug("INFO", "UNIT_SPELLCAST_SUCCEEDED - RACIAL_USED", unit, spellID)
            Gladdy:SendMessage("RACIAL_USED", unit)
        end

        -- cooldown tracker
        EventListener:CooldownCheck("UNIT_SPELLCAST_SUCCEEDED", unit, spellName, spellID)
    end
end

local specCheck = {
    ["PALADIN"] = function(spec) return Gladdy:contains(spec, {L["Holy"], L["Retribution"], L["Protection"]}) end,
    ["SHAMAN"] = function(spec) return Gladdy:contains(spec, {L["Restoration"], L["Enhancement"], L["Elemental"]}) end,
    ["ROGUE"] = function(spec) return Gladdy:contains(spec, {L["Subtlety"], L["Assassination"], L["Combat"]}) end,
    ["WARLOCK"] = function(spec) return Gladdy:contains(spec, {L["Demonology"], L["Destruction"], L["Affliction"]}) end,
    ["PRIEST"] = function(spec) return Gladdy:contains(spec, {L["Shadow"], L["Discipline"], L["Holy"]}) end,
    ["MAGE"] = function(spec) return Gladdy:contains(spec, {L["Frost"], L["Fire"], L["Arcane"]}) end,
    ["DRUID"] = function(spec) return Gladdy:contains(spec, {L["Restoration"], L["Feral"], L["Balance"]}) end,
    ["HUNTER"] = function(spec) return Gladdy:contains(spec, {L["Beast Mastery"], L["Marksmanship"], L["Survival"]}) end,
    ["WARRIOR"] = function(spec) return Gladdy:contains(spec, {L["Arms"], L["Protection"], L["Fury"]}) end,
    ["DEATHKNIGHT"] = function(spec) return Gladdy:contains(spec, {L["Unholy"], L["Blood"], L["Frost"]}) end,
}

function EventListener:DetectSpec(unit, spec)
    local button = Gladdy.buttons[unit]
    if (not button or not spec or button.spec or button.class and not specCheck[button.class](spec)) then
        return
    end
    if not button.spec then
        button.spec = spec
        Gladdy:SendMessage("UNIT_SPEC", unit, spec)
    end
end

function EventListener:Test(unit)
    local button = Gladdy.buttons[unit]
    if (button and Gladdy.testData[unit].testSpec) then
        button.spec = nil
        Gladdy:SpotEnemy(unit, false, true)
        self:DetectSpec(unit, button.testSpec)
    end
end
