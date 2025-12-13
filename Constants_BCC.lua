local tbl_sort, select, string_lower = table.sort, select, string.lower

local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

Gladdy.expansion = "BCC"
Gladdy.CLASSES = {"MAGE", "PRIEST", "DRUID", "SHAMAN", "PALADIN", "WARLOCK", "WARRIOR", "HUNTER", "ROGUE"}
tbl_sort(Gladdy.CLASSES)

local specBuffs = {
    -- DRUID
    [GetSpellInfo(45283)] = L["Restoration"], -- Natural Perfection
    [GetSpellInfo(16880)] = L["Restoration"], -- Nature's Grace; Dreamstate spec in TBC equals Restoration
    [GetSpellInfo(24858)] = L["Restoration"], -- Moonkin Form; Dreamstate spec in TBC equals Restoration
    [GetSpellInfo(17007)] = L["Feral"], -- Leader of the Pack
    [GetSpellInfo(16188)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(33891)] = L["Restoration"], -- Tree of Life

    -- HUNTER
    [GetSpellInfo(34471)] = L["Beast Mastery"], -- The Beast Within
    [GetSpellInfo(20895)] = L["Beast Mastery"], -- Spirit Bond
    [GetSpellInfo(34455)] = L["Beast Mastery"], -- Ferocious Inspiration
    [GetSpellInfo(27066)] = L["Marksmanship"], -- Trueshot Aura
    [GetSpellInfo(34501)] = L["Survival"], -- Expose Weakness

    -- MAGE
    [GetSpellInfo(33405)] = L["Frost"], -- Ice Barrier
    [GetSpellInfo(11129)] = L["Fire"], -- Combustion
    [GetSpellInfo(12042)] = L["Arcane"], -- Arcane Power
    [GetSpellInfo(12043)] = L["Arcane"], -- Presence of Mind
    [GetSpellInfo(31589)] = L["Arcane"], -- Slow
    [GetSpellInfo(12472)] = L["Frost"], -- Icy Veins
    [GetSpellInfo(46989)] = L["Arcane"], -- Improved Blink

    -- PALADIN
    [GetSpellInfo(31836)] = L["Holy"], -- Light's Grace
    [GetSpellInfo(31842)] = L["Holy"], -- Divine Illumination
    [GetSpellInfo(20216)] = L["Holy"], -- Divine Favor
    [GetSpellInfo(20375)] = L["Retribution"], -- Seal of Command
    [GetSpellInfo(20049)] = L["Retribution"], -- Vengeance
    [GetSpellInfo(20218)] = L["Retribution"], -- Sanctity Aura
    [GetSpellInfo(26018)] = L["Retribution"], -- Vindication
    [GetSpellInfo(27179)] = L["Protection"], -- Holy Shield

    -- PRIEST
    [GetSpellInfo(15473)] = L["Shadow"], -- Shadowform
    [GetSpellInfo(15286)] = L["Shadow"], -- Vampiric Embrace
    [GetSpellInfo(45234)] = L["Discipline"], -- Focused Will
    [GetSpellInfo(27811)] = L["Discipline"], -- Blessed Recovery
    [GetSpellInfo(33142)] = L["Holy"], -- Blessed Resilience
    [GetSpellInfo(14752)] = L["Discipline"], -- Divine Spirit
    [GetSpellInfo(27681)] = L["Discipline"], -- Prayer of Spirit
    [GetSpellInfo(10060)] = L["Discipline"], -- Power Infusion
    [GetSpellInfo(33206)] = L["Discipline"], -- Pain Suppression
    [GetSpellInfo(14893)] = L["Discipline"], -- Inspiration

    -- ROGUE
    [GetSpellInfo(36554)] = L["Subtlety"], -- Shadowstep
    [GetSpellInfo(44373)] = L["Subtlety"], -- Shadowstep Speed
    [GetSpellInfo(36563)] = L["Subtlety"], -- Shadowstep DMG
    [GetSpellInfo(14278)] = L["Subtlety"], -- Ghostly Strike
    [GetSpellInfo(31233)] = L["Assassination"], -- Find Weakness
    [GetSpellInfo(13877)] = L["Combat"], -- Blade Flurry

    --Shaman
    [GetSpellInfo(30807)] = L["Enhancement"], -- Unleashed Rage
    [GetSpellInfo(16280)] = L["Enhancement"], -- Flurry
    [GetSpellInfo(30823)] = L["Enhancement"], -- Shamanistic Rage
    [GetSpellInfo(16190)] = L["Restoration"], -- Mana Tide Totem
    [GetSpellInfo(32594)] = L["Restoration"], -- Earth Shield
    [GetSpellInfo(29202)] = L["Restoration"], -- Healing Way

    -- WARLOCK
    [GetSpellInfo(19028)] = L["Demonology"], -- Soul Link
    [GetSpellInfo(23759)] = L["Demonology"], -- Master Demonologist
    [GetSpellInfo(35696)] = L["Demonology"], -- Demonic Knowledge
    [GetSpellInfo(30300)] = L["Destruction"], -- Nether Protection
    [GetSpellInfo(34936)] = L["Destruction"], -- Backlash

    -- WARRIOR
    [GetSpellInfo(29838)] = L["Arms"], -- Second Wind
    [GetSpellInfo(12292)] = L["Arms"], -- Death Wish

}
function Gladdy:GetSpecBuffs()
    return specBuffs
end

local specSpells = {
    -- DRUID
    [GetSpellInfo(33831)] = L["Balance"], -- Force of Nature
    [GetSpellInfo(33983)] = L["Feral"], -- Mangle (Cat)
    [GetSpellInfo(33987)] = L["Feral"], -- Mangle (Bear)
    [GetSpellInfo(18562)] = L["Restoration"], -- Swiftmend
    [GetSpellInfo(17116)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(33891)] = L["Restoration"], -- Tree of Life

    -- HUNTER
    [GetSpellInfo(19577)] = L["Beast Mastery"], -- Intimidation
    [GetSpellInfo(34490)] = L["Marksmanship"], -- Silencing Shot
    [GetSpellInfo(27068)] = L["Survival"], -- Wyvern Sting
    [GetSpellInfo(19306)] = L["Survival"], -- Counterattack
    [GetSpellInfo(27066)] = L["Marksmanship"], -- Trueshot Aura

    -- MAGE
    [GetSpellInfo(12042)] = L["Arcane"], -- Arcane Power
    [GetSpellInfo(33043)] = L["Fire"], -- Dragon's Breath
    [GetSpellInfo(33933)] = L["Fire"], -- Blast Wave
    [GetSpellInfo(33405)] = L["Frost"], -- Ice Barrier
    [GetSpellInfo(31687)] = L["Frost"], -- Summon Water Elemental
    [GetSpellInfo(12472)] = L["Frost"], -- Icy Veins
    [GetSpellInfo(11958)] = L["Frost"], -- Cold Snap

    -- PALADIN
    [GetSpellInfo(33072)] = L["Holy"], -- Holy Shock
    [GetSpellInfo(20216)] = L["Holy"], -- Divine Favor
    [GetSpellInfo(31842)] = L["Holy"], -- Divine Illumination
    [GetSpellInfo(32700)] = L["Protection"], -- Avenger's Shield
    [GetSpellInfo(27170)] = L["Retribution"], -- Seal of Command
    [GetSpellInfo(35395)] = L["Retribution"], -- Crusader Strike
    [GetSpellInfo(20066)] = L["Retribution"], -- Repentance
    [GetSpellInfo(20218)] = L["Retribution"], -- Sanctity Aura

    -- PRIEST
    [GetSpellInfo(10060)] = L["Discipline"], -- Power Infusion
    [GetSpellInfo(33206)] = L["Discipline"], -- Pain Suppression
    [GetSpellInfo(14752)] = L["Discipline"], -- Divine Spirit
    [GetSpellInfo(33143)] = L["Holy"], -- Blessed Resilience
    [GetSpellInfo(34861)] = L["Holy"], -- Circle of Healing
    [GetSpellInfo(15473)] = L["Shadow"], -- Shadowform
    [GetSpellInfo(34917)] = L["Shadow"], -- Vampiric Touch
    [GetSpellInfo(15286)] = L["Shadow"], -- Vampiric Embrace

    -- ROGUE
    [GetSpellInfo(34413)] = L["Assassination"], -- Mutilate
    [GetSpellInfo(14177)] = L["Assassination"], -- Cold Blood
    [GetSpellInfo(13750)] = L["Combat"], -- Adrenaline Rush
    [GetSpellInfo(13877)] = L["Combat"], -- Blade Flurry
    [GetSpellInfo(14185)] = L["Subtlety"], -- Preparation
    [GetSpellInfo(16511)] = L["Subtlety"], -- Hemorrhage
    [GetSpellInfo(36554)] = L["Subtlety"], -- Shadowstep
    [GetSpellInfo(14278)] = L["Subtlety"], -- Ghostly Strike
    [GetSpellInfo(14183)] = L["Subtlety"], -- Premeditation

    -- SHAMAN
    [GetSpellInfo(16166)] = L["Elemental"], -- Elemental Mastery
    [GetSpellInfo(30706)] = L["Elemental"], -- Totem of Wrath
    [GetSpellInfo(30823)] = L["Enhancement"], -- Shamanistic Rage
    [GetSpellInfo(17364)] = L["Enhancement"], -- Stormstrike
    [GetSpellInfo(16190)] = L["Restoration"], -- Mana Tide Totem
    [GetSpellInfo(32594)] = L["Restoration"], -- Earth Shield
    [GetSpellInfo(16188)] = L["Restoration"], -- Nature's Swiftness

    -- WARLOCK
    [GetSpellInfo(30405)] = L["Affliction"], -- Unstable Affliction
    [GetSpellInfo(18220)] = L["Affliction"], -- Dark Pact
    --[GetSpellInfo(30911)] = L["Affliction"], -- Siphon Life
    [GetSpellInfo(30414)] = L["Destruction"], -- Shadowfury
    [GetSpellInfo(30912)] = L["Destruction"], -- Conflagrate
    [GetSpellInfo(18708)] = L["Demonology"], -- Fel Domination

    -- WARRIOR
    [GetSpellInfo(30330)] = L["Arms"], -- Mortal Strike
    [GetSpellInfo(12292)] = L["Arms"], -- Death Wish
    [GetSpellInfo(30335)] = L["Fury"], -- Bloodthirst
    [GetSpellInfo(12809)] = L["Protection"], -- Concussion Blow
    [GetSpellInfo(30022)] = L["Protection"], -- Devastation
    [GetSpellInfo(30356)] = L["Protection"], -- Shield Slam
}
function Gladdy:GetSpecSpells()
    return specSpells
end
local importantAuras = {}

local function AddImportantAura(spellID, track, priority, spellIDs, options)
    options = options or {}
    local name, _, texture = GetSpellInfo(spellID)
    if name then
        importantAuras[spellID] = {
            track = track,
            priority = priority,
            spellIDs = spellIDs or { spellID },
            texture = options.texture or texture or GetSpellTexture(spellID),
            textureSpell = options.textureSpell or spellID,
            altName = options.altName,
            duration = options.duration or 0,
            magic = options.magic
        }
    end
end
-- DRUID
AddImportantAura(33786, AURA_TYPE_DEBUFF, 40, { 33786 }, { duration = 6 }) -- Cyclone
AddImportantAura(18658, AURA_TYPE_DEBUFF, 40, { 18658 }, { duration = 10, magic = true }) -- Hibernate
AddImportantAura(26989, AURA_TYPE_DEBUFF, 30, { 26989 }, { duration = 10, magic = true }) -- Entangling Roots
AddImportantAura(27010, AURA_TYPE_DEBUFF, 30, { 27010 }, { duration = 10, altName = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)) }) -- Entangling Roots (Nature's Grasp)
AddImportantAura(16979, AURA_TYPE_DEBUFF, 30, { 16979 }, { duration = 4 }) -- Feral Charge
AddImportantAura(8983, AURA_TYPE_DEBUFF, 30, { 8983 }, { duration = 4 }) -- Bash
AddImportantAura(9005, AURA_TYPE_DEBUFF, 40, { 9005 }, { duration = 3 }) -- Pounce
AddImportantAura(22570, AURA_TYPE_DEBUFF, 40, { 22570 }, { duration = 6 }) -- Maim
AddImportantAura(29166, AURA_TYPE_BUFF, 10, { 29166 }, { duration = 20 }) -- Innervate
AddImportantAura(16922, AURA_TYPE_DEBUFF, 40, { 16922 }, { duration = 3 }) -- Imp Starfire Stun

-- HUNTER
AddImportantAura(14309, AURA_TYPE_DEBUFF, 40, { 14309 }, { duration = 10, magic = true }) -- Freezing Trap Effect
AddImportantAura(19386, AURA_TYPE_DEBUFF, 40, { 19386 }, { duration = 10 }) -- Wyvern Sting
AddImportantAura(19503, AURA_TYPE_DEBUFF, 40, { 19503 }, { duration = 4 }) -- Scatter Shot
AddImportantAura(14327, AURA_TYPE_DEBUFF, 40, { 14327 }, { duration = 8, magic = true }) -- Scare Beast
AddImportantAura(34490, AURA_TYPE_DEBUFF, 15, { 34490 }, { duration = 3, magic = true }) -- Silencing Shot
AddImportantAura(19577, AURA_TYPE_DEBUFF, 40, { 19577 }, { duration = 2 }) -- Intimidation
AddImportantAura(34471, AURA_TYPE_BUFF, 20, { 34471 }, { duration = 18 }) -- The Beast Within

-- MAGE
AddImportantAura(12826, AURA_TYPE_DEBUFF, 40, { 12826 }, { duration = 10, magic = true }) -- Polymorph
AddImportantAura(31661, AURA_TYPE_DEBUFF, 40, { 31661 }, { duration = 3, magic = true }) -- Dragon's Breath
AddImportantAura(27088, AURA_TYPE_DEBUFF, 30, { 27088 }, { duration = 8, magic = true }) -- Frost Nova
AddImportantAura(33395, AURA_TYPE_DEBUFF, 30, { 33395 }, { duration = 8, magic = true }) -- Freeze (Water Elemental)
AddImportantAura(18469, AURA_TYPE_DEBUFF, 15, { 18469 }, { duration = 4, magic = true }) -- Counterspell - Silence
AddImportantAura(45438, AURA_TYPE_BUFF, 20, { 45438 }, { duration = 10 }) -- Ice Block
AddImportantAura(41425, AURA_TYPE_DEBUFF, 8, { 41425 }) -- Hypothermia
AddImportantAura(12355, AURA_TYPE_DEBUFF, 40, { 12355 }, { duration = 2 }) -- Impact

-- PALADIN
AddImportantAura(10308, AURA_TYPE_DEBUFF, 40, { 10308 }, { duration = 6, magic = true }) -- Hammer of Justice
AddImportantAura(20066, AURA_TYPE_DEBUFF, 40, { 20066 }, { duration = 6, magic = true }) -- Repentance
AddImportantAura(10278, AURA_TYPE_BUFF, 10, { 10278 }, { duration = 10 }) -- Blessing of Protection
AddImportantAura(1044, AURA_TYPE_BUFF, 10, { 1044 }, { duration = 14 }) -- Blessing of Freedom
AddImportantAura(6940, AURA_TYPE_BUFF, 12, { 6940 }, { duration = 30 }) -- Blessing of Sacrifice
AddImportantAura(642, AURA_TYPE_BUFF, 20, { 642 }, { duration = 12 }) -- Divine Shield

-- PRIEST
AddImportantAura(8122, AURA_TYPE_DEBUFF, 40, { 8122 }, { duration = 8, magic = true }) -- Psychic Scream
AddImportantAura(44047, AURA_TYPE_DEBUFF, 30, { 44047 }, { duration = 8 }) -- Chastise
AddImportantAura(605, AURA_TYPE_DEBUFF, 40, { 605 }, { duration = 10, magic = true }) -- Mind Control
AddImportantAura(15269, AURA_TYPE_DEBUFF, 40, { 15269 }, { duration = 3 }) -- Blackout Stun
AddImportantAura(15487, AURA_TYPE_DEBUFF, 15, { 15487 }, { duration = 5, magic = true }) -- Silence
AddImportantAura(33206, AURA_TYPE_BUFF, 10, { 33206 }, { duration = 8 }) -- Pain Suppression
AddImportantAura(6346, AURA_TYPE_BUFF, 9, { 6346 }, { duration = 180 }) -- Fear Ward

-- ROGUE
AddImportantAura(6770, AURA_TYPE_DEBUFF, 40, { 6770 }, { duration = 10 }) -- Sap
AddImportantAura(2094, AURA_TYPE_DEBUFF, 40, { 2094 }, { duration = 10 }) -- Blind
AddImportantAura(1833, AURA_TYPE_DEBUFF, 40, { 1833 }, { duration = 4 }) -- Cheap Shot
AddImportantAura(8643, AURA_TYPE_DEBUFF, 40, { 8643 }, { duration = 6 }) -- Kidney Shot
AddImportantAura(1776, AURA_TYPE_DEBUFF, 40, { 1776 }, { duration = 4 }) -- Gouge
AddImportantAura(18425, AURA_TYPE_DEBUFF, 15, { 18425 }, { duration = 2 }) -- Kick - Silence
AddImportantAura(1330, AURA_TYPE_DEBUFF, 15, { 1330 }, { duration = 3 }) -- Garrote - Silence
AddImportantAura(31224, AURA_TYPE_BUFF, 20, { 31224 }, { duration = 5 }) -- Cloak of Shadows
AddImportantAura(26669, AURA_TYPE_BUFF, 10, { 26669 }, { duration = 15 }) -- Evasion
AddImportantAura(14251, AURA_TYPE_DEBUFF, 20, { 14251 }, { duration = 6 }) -- Riposte

-- WARLOCK
AddImportantAura(5782, AURA_TYPE_DEBUFF, 40, { 5782 }, { duration = 10, magic = true }) -- Fear
AddImportantAura(27223, AURA_TYPE_DEBUFF, 40, { 27223 }, { duration = 3 }) -- Death Coil
AddImportantAura(710, AURA_TYPE_DEBUFF, 40, { 710 }, { duration = 10 }) -- Banish
AddImportantAura(30283, AURA_TYPE_DEBUFF, 40, { 30283 }, { duration = 2, magic = true }) -- Shadowfury
AddImportantAura(6358, AURA_TYPE_DEBUFF, 40, { 6358 }, { duration = 10, magic = true }) -- Seduction (Succubus)
AddImportantAura(5484, AURA_TYPE_DEBUFF, 40, { 5484 }, { duration = 8, magic = true }) -- Howl of Terror
AddImportantAura(24259, AURA_TYPE_DEBUFF, 15, { 24259 }, { duration = 3, magic = true }) -- Spell Lock (Felhunter)
AddImportantAura(31117, AURA_TYPE_DEBUFF, 15, { 31117 }, { duration = 5, magic = true, altName = select(1, GetSpellInfo(31117)) .. " Silence" }) -- Unstable Affliction Silence

-- WARRIOR
AddImportantAura(5246, AURA_TYPE_DEBUFF, 15, { 5246 }, { duration = 8 }) -- Intimidating Shout
AddImportantAura(12809, AURA_TYPE_DEBUFF, 40, { 12809 }, { duration = 5 }) -- Concussion Blow
AddImportantAura(25274, AURA_TYPE_DEBUFF, 40, { 25274 }, { duration = 3, texture = select(3, GetSpellInfo(25272)) }) -- Intercept Stun
AddImportantAura(7922, AURA_TYPE_DEBUFF, 40, { 7922 }, { duration = 1, texture = select(3, GetSpellInfo(100)) }) -- Charge Stun
AddImportantAura(23920, AURA_TYPE_BUFF, 50, { 23920 }, { duration = 5 }) -- Spell Reflection
AddImportantAura(18498, AURA_TYPE_DEBUFF, 15, { 18498 }, { duration = 3 }) -- Shield Bash - Silenced
AddImportantAura(12292, AURA_TYPE_BUFF, 15, { 12292 }, { duration = 3 }) -- Death Wish
AddImportantAura(676, AURA_TYPE_DEBUFF, 20, { 676 }, { duration = 10 }) -- Disarm

-- MISC / ITEMS / RACIALS
AddImportantAura(8178, AURA_TYPE_BUFF, 20, { 8178 }, { duration = 0 }) -- Grounding Totem Effect
AddImportantAura(3411, AURA_TYPE_BUFF, 10, { 3411 }, { duration = 10 }) -- Intervene
AddImportantAura(23694, AURA_TYPE_DEBUFF, 40, { 23694 }, { duration = 5 }) -- Improved Hamstring
AddImportantAura(5530, AURA_TYPE_DEBUFF, 40, { 5530 }, { duration = 3, texture = select(3, GetSpellInfo(12284)) }) -- Mace Stun Effect
AddImportantAura(34510, AURA_TYPE_DEBUFF, 40, { 34510 }, { duration = 4 }) -- Storm Herald Stun effect
AddImportantAura(20549, AURA_TYPE_DEBUFF, 40, { 20549 }, { duration = 2 }) -- War Stomp
AddImportantAura(28730, AURA_TYPE_DEBUFF, 15, { 28730 }, { duration = 2, magic = true }) -- Arcane Torrent
AddImportantAura(34709, AURA_TYPE_DEBUFF, 9, { 34709 }, { duration = 15, magic = true }) -- Shadowsight Buff
AddImportantAura(13120, AURA_TYPE_DEBUFF, 30, { 13120 }, { duration = 10 }) -- Net-o-Matic
AddImportantAura(30458, AURA_TYPE_BUFF, 15, { 30458 }, { duration = 8, texture = select(10, GetItemInfo(23825)) }) -- Nigh Invulnerability Shield
AddImportantAura(30457, AURA_TYPE_DEBUFF, 15, { 30457 }, { duration = 8 }) -- Nigh Invulnerability Belt Backfire
AddImportantAura(5024, AURA_TYPE_BUFF, 15, { 5024 }, { duration = 8, altName = (select(1, GetSpellInfo(5024)) or "Flee") .. " - " .. (select(1, GetItemInfo(4984)) or "Skull of Impending Doom") }) -- Skull of Impending Doom
AddImportantAura(7744, AURA_TYPE_BUFF, 15, { 7744 }, { duration = 5 }) -- Will of the Forsaken
function Gladdy:GetImportantAuras()
    return importantAuras
end

local interrupts = {}

local function AddInterrupt(spellID, duration, priority)
    local name, _, texture = GetSpellInfo(spellID)
    if name then
        interrupts[spellID] = {
            duration = duration,
            spellID = spellID,
            track = AURA_TYPE_DEBUFF,
            texture = texture or GetSpellTexture(spellID),
            priority = priority
        }
    end
end

AddInterrupt(19675, 4, 15)   -- Feral Charge Effect (Druid)
AddInterrupt(2139, 8, 15)   -- Counterspell (Mage)
AddInterrupt(1766, 5, 15)   -- Kick (Rogue)
AddInterrupt(6552, 4, 15)   -- Pummel (Warrior)
AddInterrupt(72, 6, 15)   -- Shield Bash (Warrior)
AddInterrupt(8042, 2, 15)   -- Earth Shock (Shaman)
AddInterrupt(19244, 5, 15)   -- Spell Lock (Warlock)
AddInterrupt(32747, 3, 15)   -- Deadly Throw Interrupt

function Gladdy:GetInterrupts()
    return interrupts
end

Gladdy.cooldownBuffs = {
    [GetSpellInfo(6346)] = { cd = function(expTime) -- 180s uptime == cd
        return expTime
    end, spellId = 6346 }, -- Fear Ward
    [GetSpellInfo(11305)] = { cd = function(expTime) -- 15s uptime
        return 60 - (8 - expTime)
    end, spellId = 11305, class = "ROGUE" }, -- Sprint
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

local cooldownList = {}

local function AddCooldownEntry(class, spellId, cooldownInfo)
    if not cooldownList[class] then
        cooldownList[class] = {}
    end
    if spellId then
        cooldownList[class][spellId] = cooldownInfo
    end
end

-- Mage
AddCooldownEntry("MAGE", 1953, { cd = 15 }) -- Blink
AddCooldownEntry("MAGE", 122, { cd = 22 }) -- Frost Nova
AddCooldownEntry("MAGE", 12051, { cd = 480 }) -- Evocation
AddCooldownEntry("MAGE", 2139, { cd = 24 }) -- Counterspell
AddCooldownEntry("MAGE", 45438, { cd = 300, [L["Frost"]] = 240 }) -- Ice Block
AddCooldownEntry("MAGE", 12472, { cd = 180, spec = L["Frost"] }) -- Icy Veins
AddCooldownEntry("MAGE", 31687, { cd = 180, spec = L["Frost"] }) -- Summon Water Elemental
AddCooldownEntry("MAGE", 12043, { cd = 180, spec = L["Arcane"] }) -- Presence of Mind
AddCooldownEntry("MAGE", 11129, { cd = 180, spec = L["Fire"] }) -- Combustion
AddCooldownEntry("MAGE", 120, { cd = 10, sharedCD = { [31661] = true } }) -- Cone of Cold
AddCooldownEntry("MAGE", 31661, { cd = 20, sharedCD = { [120] = true }, spec = L["Fire"] }) -- Dragon's Breath
AddCooldownEntry("MAGE", 12042, { cd = 180, spec = L["Arcane"] }) -- Arcane Power
AddCooldownEntry("MAGE", 11958, { cd = 384, spec = L["Frost"], resetCD = { [12472] = true, [45438] = true, [31687] = true } }) -- Coldsnap

-- Priest
AddCooldownEntry("PRIEST", 10890, { cd = 27, [L["Shadow"]] = 23 }) -- Psychic Scream
AddCooldownEntry("PRIEST", 15487, { cd = 45, spec = L["Shadow"] }) -- Silence
AddCooldownEntry("PRIEST", 10060, { cd = 180, spec = L["Discipline"] }) -- Power Infusion
AddCooldownEntry("PRIEST", 33206, { cd = 120, spec = L["Discipline"] }) -- Pain Suppression
AddCooldownEntry("PRIEST", 34433, { cd = 300 }) -- Shadowfiend
AddCooldownEntry("PRIEST", 32379, { cd = 12 }) -- Shadow Word: Death
AddCooldownEntry("PRIEST", 6346, { cd = 180 }) -- Fear Ward

-- Druid
AddCooldownEntry("DRUID", 22812, { cd = 60 }) -- Barkskin
AddCooldownEntry("DRUID", 29166, { cd = 360 }) -- Innervate
AddCooldownEntry("DRUID", 8983, { cd = 60 }) -- Bash
AddCooldownEntry("DRUID", 16689, { cd = 60 }) -- Natures Grasp
AddCooldownEntry("DRUID", 18562, { cd = 15, spec = L["Restoration"] }) -- Swiftmend
AddCooldownEntry("DRUID", 17116, { cd = 180, spec = L["Restoration"] }) -- Natures Swiftness
AddCooldownEntry("DRUID", 33831, { cd = 180, spec = L["Balance"] }) -- Force of Nature

-- Shaman
AddCooldownEntry("SHAMAN", 8042, { cd = 6, sharedCD = { [8056] = true, [8050] = true } }) -- Earth Shock
AddCooldownEntry("SHAMAN", 30823, { cd = 120, spec = L["Enhancement"] }) -- Shamanistic Rage
AddCooldownEntry("SHAMAN", 16166, { cd = 180, spec = L["Elemental"] }) -- Elemental Mastery
AddCooldownEntry("SHAMAN", 16188, { cd = 180, spec = L["Restoration"] }) -- Natures Swiftness
AddCooldownEntry("SHAMAN", 16190, { cd = 300, spec = L["Restoration"] }) -- Mana Tide Totem
AddCooldownEntry("SHAMAN", 8177, { cd = 15 }) -- Grounding Totem

-- Paladin
AddCooldownEntry("PALADIN", 10278, { cd = 180 }) -- Blessing of Protection
AddCooldownEntry("PALADIN", 1044, { cd = 25 }) -- Blessing of Freedom
AddCooldownEntry("PALADIN", 10308, { cd = 60, [L["Retribution"]] = 40 }) -- Hammer of Justice
AddCooldownEntry("PALADIN", 642, { cd = 300, sharedCD = { cd = 60, [31884] = true } }) -- Divine Shield
AddCooldownEntry("PALADIN", 31884, { cd = 180, spec = L["Retribution"], sharedCD = { cd = 60, [642] = true } }) -- Avenging Wrath
AddCooldownEntry("PALADIN", 20066, { cd = 60, spec = L["Retribution"] }) -- Repentance
AddCooldownEntry("PALADIN", 31842, { cd = 180, spec = L["Holy"] }) -- Divine Illumination
AddCooldownEntry("PALADIN", 31935, { cd = 30, spec = L["Protection"] }) -- Avengers Shield

-- Warlock
AddCooldownEntry("WARLOCK", 17928, { cd = 40 }) -- Howl of Terror
AddCooldownEntry("WARLOCK", 27223, { cd = 120 }) -- Death Coil
AddCooldownEntry("WARLOCK", 19647, { cd = 24 }) -- Spell Lock
AddCooldownEntry("WARLOCK", 27277, { cd = 8 }) -- Devour Magic
AddCooldownEntry("WARLOCK", 30414, { cd = 20, spec = L["Destruction"] }) -- Shadowfury
AddCooldownEntry("WARLOCK", 17877, { cd = 15, spec = L["Destruction"] }) -- Shadowburn
AddCooldownEntry("WARLOCK", 30912, { cd = 10, spec = L["Destruction"] }) -- Conflagrate
AddCooldownEntry("WARLOCK", 18708, { cd = 900, spec = L["Demonology"] }) -- Feldom

-- Warrior
AddCooldownEntry("WARRIOR", 6552, { cd = 10, sharedCD = { [72] = true } }) -- Pummel
AddCooldownEntry("WARRIOR", 72, { cd = 12, sharedCD = { [6552] = true } }) -- Shield Bash
AddCooldownEntry("WARRIOR", 23920, { cd = 10 }) -- Spell Reflection
AddCooldownEntry("WARRIOR", 3411, { cd = 30 }) -- Intervene
AddCooldownEntry("WARRIOR", 676, { cd = 60 }) -- Disarm
AddCooldownEntry("WARRIOR", 5246, { cd = 180 }) -- Intimidating Shout
AddCooldownEntry("WARRIOR", 18499, { cd = 30 }) -- Berserker Rage
AddCooldownEntry("WARRIOR", 2565, { cd = 60 }) -- Shield Block
AddCooldownEntry("WARRIOR", 12292, { cd = 180, spec = L["Arms"] }) -- Death Wish
AddCooldownEntry("WARRIOR", 20252, { cd = 25, [L["Arms"]] = 15 }) -- Intercept
AddCooldownEntry("WARRIOR", 12975, { cd = 180, spec = L["Protection"] }) -- Last Stand
AddCooldownEntry("WARRIOR", 12809, { cd = 30, spec = L["Protection"] }) -- Concussion Blow

-- Hunter
AddCooldownEntry("HUNTER", 19503, { cd = 30 }) -- Scatter Shot
AddCooldownEntry("HUNTER", 14327, { cd = 30 }) -- Scare Beast
AddCooldownEntry("HUNTER", 19263, { cd = 300, spec = { L["Marksmanship"], L["Survival"] } }) -- Deterrence; not on BM but can't do 2 specs
AddCooldownEntry("HUNTER", 13809, { cd = 30, sharedCD = { [14311] = true, [34600] = true }, icon = select(3, GetSpellInfo(14311)) }) -- Frost Trap
AddCooldownEntry("HUNTER", 14311, { cd = 30, sharedCD = { [13809] = true, [34600] = true }, icon = select(3, GetSpellInfo(14311)) }) -- Freezing Trap
AddCooldownEntry("HUNTER", 34600, { cd = 30, sharedCD = { [14311] = true, [13809] = true }, icon = select(3, GetSpellInfo(14311)) }) -- Snake Trap
AddCooldownEntry("HUNTER", 34490, { cd = 20, spec = L["Marksmanship"] }) -- Silencing Shot
AddCooldownEntry("HUNTER", 19386, { cd = 120, spec = L["Survival"] }) -- Wyvern Sting
AddCooldownEntry("HUNTER", 19577, { cd = 60, spec = L["Beast Mastery"] }) -- Intimidation
AddCooldownEntry("HUNTER", 34471, { cd = 120, spec = L["Beast Mastery"] }) -- The Beast Within
AddCooldownEntry("HUNTER", 5384, { cd = 30 }) -- Feign Death
AddCooldownEntry("HUNTER", 3034, { cd = 15 }) -- Viper Sting
AddCooldownEntry("HUNTER", 1543, { cd = 20 }) -- Flare

-- Rogue
AddCooldownEntry("ROGUE", 1766, { cd = 10 }) -- Kick
AddCooldownEntry("ROGUE", 8643, { cd = 20 }) -- Kidney Shot
AddCooldownEntry("ROGUE", 31224, { cd = 60 }) -- Cloak of Shadow
AddCooldownEntry("ROGUE", 26889, { cd = 300, [L["Subtlety"]] = 180 }) -- Vanish
AddCooldownEntry("ROGUE", 2094, { cd = 180, [L["Subtlety"]] = 90 }) -- Blind
AddCooldownEntry("ROGUE", 11305, { cd = 300, [L["Combat"]] = 180 }) -- Sprint
AddCooldownEntry("ROGUE", 26669, { cd = 300, [L["Combat"]] = 180 }) -- Evasion
AddCooldownEntry("ROGUE", 14177, { cd = 180, spec = L["Assassination"] }) -- Cold Blood
AddCooldownEntry("ROGUE", 13750, { cd = 300, spec = L["Combat"] }) -- Adrenaline Rush
AddCooldownEntry("ROGUE", 13877, { cd = 120, spec = L["Combat"] }) -- Blade Flurry
AddCooldownEntry("ROGUE", 36554, { cd = 30, spec = L["Subtlety"] }) -- Shadowstep
AddCooldownEntry("ROGUE", 14185, { cd = 600, spec = L["Subtlety"], resetCD = { [26669] = true, [11305] = true, [26889] = true, [14177] = true, [36554] = true } }) -- Preparation

-- Races
AddCooldownEntry("NightElf", 2651, { cd = 180, spec = L["Discipline"], class = "PRIEST" }) -- Elune's Grace
AddCooldownEntry("NightElf", 10797, { cd = 30, spec = L["Discipline"], class = "PRIEST" }) -- Star Shards
AddCooldownEntry("Draenei", 32548, { cd = 300, spec = L["Discipline"], class = "PRIEST" }) -- Hymn of Hope
AddCooldownEntry("Human", 13908, { cd = 600, spec = L["Discipline"], class = "PRIEST" }) -- Desperate Prayer
AddCooldownEntry("Dwarf", 13908, { cd = 600, spec = L["Discipline"], class = "PRIEST" }) -- Desperate Prayer
AddCooldownEntry("Scourge", nil, nil) -- nil
AddCooldownEntry("BloodElf", nil, nil) -- nil
AddCooldownEntry("Tauren", nil, nil) -- nil
AddCooldownEntry("Orc", nil, nil) -- nil
AddCooldownEntry("Troll", nil, nil) -- nil
AddCooldownEntry("Gnome", nil, nil) -- nil

function Gladdy:GetCooldownList()
    return cooldownList
end

local racials = {
    ["Scourge"] = {
        [7744] = true, -- Will of the Forsaken
        duration = 120,
        spellName = select(1, GetSpellInfo(7744)),
        texture = select(3, GetSpellInfo(7744))
    },
    ["BloodElf"] = {
        [28730] = true, -- Arcane Torrent
        duration = 120,
        spellName = select(1, GetSpellInfo(28730)),
        texture = select(3, GetSpellInfo(28730))
    },
    ["Tauren"] = {
        [20549] = true, -- War Stomp
        duration = 120,
        spellName = select(1, GetSpellInfo(20549)),
        texture = select(3, GetSpellInfo(20549))
    },
    ["Orc"] = {
        [20572] = true,
        [33697] = true,
        [33702] = true,
        duration = 120,
        spellName = select(1, GetSpellInfo(20572)),
        texture = select(3, GetSpellInfo(20572))
    },
    ["Troll"] = {
        [20554] = true,
        [26296] = true,
        [26297] = true,
        duration = 180,
        spellName = select(1, GetSpellInfo(20554)),
        texture = select(3, GetSpellInfo(20554))
    },
    ["NightElf"] = {
        [20580] = true,
        duration = 10,
        spellName = select(1, GetSpellInfo(20580)),
        texture = select(3, GetSpellInfo(20580))
    },
    ["Draenei"] = {
        [28880] = true,
        duration = 180,
        spellName = select(1, GetSpellInfo(28880)),
        texture = select(3, GetSpellInfo(28880))
    },
    ["Human"] = {
        [20600] = true, -- Perception
        duration = 180,
        spellName = select(1, GetSpellInfo(20600)),
        texture = select(3, GetSpellInfo(20600))
    },
    ["Gnome"] = {
        [20589] = true, -- Escape Artist
        duration = 105,
        spellName = select(1, GetSpellInfo(20589)),
        texture = select(3, GetSpellInfo(20589))
    },
    ["Dwarf"] = {
        [20594] = true, -- Stoneform
        duration = 180,
        spellName = select(1, GetSpellInfo(20594)),
        texture = select(3, GetSpellInfo(20594))
    },
}
function Gladdy:Racials()
    return racials
end


---------------------
-- TOTEM STUFF
---------------------

local totemData = {
    -- Fire
    -- Water
    [string_lower("Poison Cleansing Totem")] = {id = 8166,texture = select(3, GetSpellInfo(8166)), color = {r = 0, g = 0, b = 0, a = 1}, pulse = 5},
    [string_lower("Mana Spring Totem")] = {id = 5675,texture = select(3, GetSpellInfo(5675)), color = {r = 0, g = 0, b = 0, a = 1}, pulse = 2},
    -- Earth
    -- Air
    [string_lower("Grace of Air Totem")] = {id = 8835,texture = select(3, GetSpellInfo(8835)), color = {r = 0, g = 0, b = 0, a = 1}},
    [string_lower("Windwall Totem")] = {id = 15107,texture = select(3, GetSpellInfo(15107)), color = {r = 0, g = 0, b = 0, a = 1}},
    [string_lower("Tranquil Air Totem")] = {id = 25908,texture = select(3, GetSpellInfo(25908)), color = {r = 0, g = 0, b = 0, a = 1}},
}

local totemSpellIdToPulse = {
    [GetSpellInfo(totemData[string_lower("Poison Cleansing Totem")].id)] = totemData[string_lower("Poison Cleansing Totem")].pulse,
    [8166] = totemData[string_lower("Poison Cleansing Totem")].pulse,
    [GetSpellInfo(totemData[string_lower("Mana Spring Totem")].id)] = totemData[string_lower("Mana Spring Totem")].pulse,
    [5675] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 1
    [10495] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 2
    [10496] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 3
    [10497] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 4
    [25570] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 5
    [58771] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 6
    [58773] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 7
    [58774] = totemData[string_lower("Mana Spring Totem")].pulse, -- Rank 8
}

local totemNpcIdsToTotemData = {
    --fire
    -- Water
    [5923] = totemData[string_lower("Poison Cleansing Totem")],
    [22487] = totemData[string_lower("Poison Cleansing Totem")],

    -- Earth
    -- Air
    [7486] = totemData[string_lower("Grace of Air Totem")],
    [7487] = totemData[string_lower("Grace of Air Totem")],
    [15463] = totemData[string_lower("Grace of Air Totem")],

    [9687] = totemData[string_lower("Windwall Totem")],
    [9688] = totemData[string_lower("Windwall Totem")],
    [9689] = totemData[string_lower("Windwall Totem")],
    [15492] = totemData[string_lower("Windwall Totem")],

    [15803] = totemData[string_lower("Tranquil Air Totem")],
}

local totemDataShared, totemNpcIdsToTotemDataShared, totemSpellIdToPulseShared = Gladdy:GetSharedTotemData()
Gladdy:AddEntriesToTable(totemData, totemDataShared)
Gladdy:AddEntriesToTable(totemNpcIdsToTotemData, totemNpcIdsToTotemDataShared)
Gladdy:AddEntriesToTable(totemSpellIdToPulse, totemSpellIdToPulseShared)

function Gladdy:GetTotemData()
    return totemData, totemNpcIdsToTotemData, totemSpellIdToPulse
end
