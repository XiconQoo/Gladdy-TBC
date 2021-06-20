local select, string_gsub, tostring = select, string.gsub, tostring

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local AURA_TYPE_DEBUFF = AURA_TYPE_DEBUFF
local AURA_TYPE_BUFF = AURA_TYPE_BUFF

local UnitName, UnitAura, UnitRace, UnitClass, UnitGUID, UnitIsUnit = UnitName, UnitAura, UnitRace, UnitClass, UnitGUID, UnitIsUnit
local UnitCastingInfo, UnitChannelInfo = UnitCastingInfo, UnitChannelInfo
local GetSpellInfo = GetSpellInfo
local FindAuraByName = AuraUtil.FindAuraByName

local Gladdy = LibStub("Gladdy")
local Cooldowns = Gladdy.modules["Cooldowns"]
local Diminishings = Gladdy.modules["Diminishings"]

local EventListener = Gladdy:NewModule("EventListener", nil, {
    test = true,
})

function EventListener:Initialize()
    self:RegisterMessage("JOINED_ARENA")
end

function EventListener.OnEvent(self, event, ...)
    EventListener[event](self, ...)
end

function EventListener:JOINED_ARENA()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("ARENA_OPPONENT_UPDATE")
    self:RegisterEvent("UNIT_AURA")
    self:RegisterEvent("UNIT_SPELLCAST_START")
    self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:SetScript("OnEvent", EventListener.OnEvent)
end

function EventListener:Reset()
    self:UnregisterAllEvents()
    self:SetScript("OnEvent", nil)
end

function Gladdy:DetectSpec(unit, specSpell)
    if specSpell then
        self.modules["Cooldowns"]:DetectSpec(unit, specSpell)
    end
end

function Gladdy:SpotEnemy(unit, auraScan)
    local button = self.buttons[unit]
    button.raceLoc = UnitRace(unit)
    button.race = select(2, UnitRace(unit))
    button.classLoc = select(1, UnitClass(unit))
    button.class = select(2, UnitClass(unit))
    button.name = UnitName(unit)
    button.stealthed = false
    Gladdy.guids[UnitGUID(unit)] = unit
    Gladdy:SendMessage("ENEMY_SPOTTED", unit)
    if auraScan and not button.spec then
        for n = 1, 30 do
            local spellName,_,_,_,_,_,unitCaster = UnitAura(unit, n, "HELPFUL")
            if ( not spellName ) then
                break
            end
            if Gladdy.specBuffs[spellName] then
                local unitPet = string_gsub(unit, "%d$", "pet%1")
                if UnitIsUnit(unit, unitCaster) or UnitIsUnit(unitPet, unitCaster) then
                    Gladdy:DetectSpec(unit, Gladdy.specBuffs[spellName])
                end
            end
        end
    end
end

function EventListener:COMBAT_LOG_EVENT_UNFILTERED()
    -- timestamp,eventType,hideCaster,sourceGUID,sourceName,sourceFlags,sourceRaidFlags,destGUID,destName,destFlags,destRaidFlags,spellId,spellName,spellSchool
    local _,eventType,_,sourceGUID,_,_,_,destGUID,_,_,_,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool = CombatLogGetCurrentEventInfo()
    local srcUnit = Gladdy.guids[sourceGUID]
    local destUnit = Gladdy.guids[destGUID]

    if destUnit then
        -- diminish tracker
        if (Gladdy.db.drEnabled and (eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_REFRESH")) then
            Diminishings:AuraFade(destUnit, spellID)
        end
        -- death detection
        if (eventType == "UNIT_DIED" or eventType == "PARTY_KILL" or eventType == "SPELL_INSTAKILL") then
            Gladdy:SendMessage("UNIT_DEATH", destUnit)
        end
        -- spec detection
        if not Gladdy.buttons[destUnit].class then
            Gladdy:SpotEnemy(destUnit, true)
        end
        --interrupt detection
        if eventType == "SPELL_INTERRUPT" then
            Gladdy:SendMessage("SPELL_INTERRUPT", destUnit,spellID,spellName,spellSchool,extraSpellId,extraSpellName,extraSpellSchool)
        end
    end
    if srcUnit then
        if (eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED") then
            local unitRace = Gladdy.buttons[srcUnit].race
            -- cooldown tracker
            if Gladdy.db.cooldown and Cooldowns.cooldownSpellIds[spellName] then
                local unitClass
                local spellId = Cooldowns.cooldownSpellIds[spellName] -- don't use spellId from combatlog, in case of different spellrank
                if Gladdy.db.cooldownCooldowns[tostring(spellId)] then
                    if (Gladdy:GetCooldownList()[Gladdy.buttons[srcUnit].class][spellId]) then
                        unitClass = Gladdy.buttons[srcUnit].class
                    else
                        unitClass = Gladdy.buttons[srcUnit].race
                    end
                    Cooldowns:CooldownUsed(srcUnit, unitClass, spellId, spellName)
                    Gladdy:DetectSpec(srcUnit, Gladdy.specSpells[spellName])
                end
            end

            if Gladdy.db.racialEnabled and Gladdy:Racials()[unitRace].spellName == spellName and Gladdy:Racials()[unitRace][spellID] then
                Gladdy:SendMessage("RACIAL_USED", srcUnit)
            end
        end

        if not Gladdy.buttons[srcUnit].class then
            Gladdy:SpotEnemy(srcUnit, true)
        end
        if not Gladdy.buttons[srcUnit].spec then
            Gladdy:DetectSpec(srcUnit, Gladdy.specSpells[spellName])
        end
    end
end

function EventListener:ARENA_OPPONENT_UPDATE(unit, updateReason)
    --[[ updateReason: seen, unseen, destroyed, cleared ]]

    local button = Gladdy.buttons[unit]
    local pet = Gladdy.modules["Pets"].frames[unit]
    if button or pet then
        if updateReason == "seen" then
            -- ENEMY_SPOTTED
            if button then
                Gladdy:SendMessage("ENEMY_STEALTH", unit, false)
                if not button.class then
                    Gladdy:SpotEnemy(unit, true)
                end
            end
            if pet then
                Gladdy:SendMessage("PET_SPOTTED", unit)
            end
        elseif updateReason == "unseen" then
            -- STEALTH
            if button then
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

local exceptionNames = { -- TODO MOVE ME TO CLASSBUFFS LIB
    [31117] = GetSpellInfo(30405) .. " Silence", -- Unstable Affliction Silence
    [43523] = GetSpellInfo(30405) .. " Silence",
    [24131] = select(1, GetSpellInfo(19386)) .. " Dot", -- Wyvern Sting Dot
    [24134] = select(1, GetSpellInfo(19386)) .. " Dot",
    [24135] = select(1, GetSpellInfo(19386)) .. " Dot",
    [27069] = select(1, GetSpellInfo(19386)) .. " Dot",
    [19975] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)), -- Entangling Roots Nature's Grasp
    [19974] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)),
    [19973] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)),
    [19972] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)),
    [19971] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)),
    [19971] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)),
    [27010] = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)),
}

function EventListener:UNIT_AURA(unit)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    for i = 1, 2 do
        if not Gladdy.buttons[unit].class then
            Gladdy:SpotEnemy(unit, false)
        end
        local filter = (i == 1 and "HELPFUL" or "HARMFUL")
        local auraType = i == 1 and AURA_TYPE_BUFF or AURA_TYPE_DEBUFF
        Gladdy:SendMessage("AURA_FADE", unit, auraType)
        for n = 1, 30 do
            local spellName, texture, count, debuffType, duration, expirationTime, unitCaster, _, shouldConsolidate, spellID = UnitAura(unit, n, filter)
            if ( not spellID ) then
                Gladdy:SendMessage("AURA_GAIN_LIMIT", unit, auraType, n - 1)
                break
            end
            if not button.spec and Gladdy.specBuffs[spellName] then
                local unitPet = string_gsub(unit, "%d$", "pet%1")
                if unitCaster and (UnitIsUnit(unit, unitCaster) or UnitIsUnit(unitPet, unitCaster)) then
                    Gladdy:DetectSpec(unit, Gladdy.specBuffs[spellName])
                end
            end
            if exceptionNames[spellID] then
                spellName = exceptionNames[spellID]
            end
            Gladdy:SendMessage("AURA_GAIN", unit, auraType, spellID, spellName, texture, duration, expirationTime, count, debuffType, i)
            Gladdy:Call("Announcements", "CheckDrink", unit, spellName)
        end
    end
end

function EventListener:UNIT_SPELLCAST_START(unit)
    if Gladdy.buttons[unit] then
        local spellName = UnitCastingInfo(unit)
        if Gladdy.specSpells[spellName] and not Gladdy.buttons[unit].spec then
            Gladdy:DetectSpec(unit, Gladdy.specSpells[spellName])
        end
    end
end

function EventListener:UNIT_SPELLCAST_CHANNEL_START(unit)
    if Gladdy.buttons[unit] then
        local spellName = UnitChannelInfo(unit)
        if Gladdy.specSpells[spellName] and not Gladdy.buttons[unit].spec then
            Gladdy:DetectSpec(unit, Gladdy.specSpells[spellName])
        end
    end
end

function EventListener:UNIT_SPELLCAST_SUCCEEDED(unit)
    if Gladdy.buttons[unit] then
        local spellName = UnitCastingInfo(unit)
        if Gladdy.specSpells[spellName] and not Gladdy.buttons[unit].spec then
            Gladdy:DetectSpec(unit, Gladdy.specSpells[spellName])
        end
    end
end
