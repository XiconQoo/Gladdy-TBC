local tbl_sort, select, string_lower = table.sort, select, string.lower

local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

Gladdy.expansion = "BCC"
Gladdy.CLASSES = {"MAGE", "PRIEST", "DRUID", "SHAMAN", "PALADIN", "WARLOCK", "WARRIOR", "HUNTER", "ROGUE"}
tbl_sort(Gladdy.CLASSES)

Gladdy.specBuffs = {}
local function AddSpecBuff(spellIDs, spec)
    for _, spellId in ipairs(spellIDs) do
        Gladdy.specBuffs[spellId] = spec
    end
end

-- DRUID
AddSpecBuff({33883, 33881, 33882}, L["Restoration"]) -- Natural Perfection
AddSpecBuff({16880, 16886}, L["Restoration"]) -- Nature's Grace; Dreamstate spec in TBC equals Restoration
AddSpecBuff({24858}, L["Restoration"]) -- Moonkin Form; Dreamstate spec in TBC equals Restoration
AddSpecBuff({17007}, L["Feral"]) -- Leader of the Pack
AddSpecBuff({16188}, L["Restoration"]) -- Nature's Swiftness
AddSpecBuff({33891}, L["Restoration"]) -- Tree of Life

-- HUNTER
AddSpecBuff({34471, 34692}, L["Beast Mastery"]) -- The Beast Within
AddSpecBuff({20895, 19578}, L["Beast Mastery"]) -- Spirit Bond
AddSpecBuff({34460, 34455, 34459}, L["Beast Mastery"]) -- Ferocious Inspiration
AddSpecBuff({27066}, L["Marksmanship"]) -- Trueshot Aura
AddSpecBuff({34502, 34500, 34503, 34501}, L["Survival"]) -- Expose Weakness

-- MAGE
AddSpecBuff({13032, 33405, 13033, 27134, 11426, 13031}, L["Frost"]) -- Ice Barrier
AddSpecBuff({11129}, L["Fire"]) -- Combustion
AddSpecBuff({12042}, L["Arcane"]) -- Arcane Power
AddSpecBuff({12043}, L["Arcane"]) -- Presence of Mind
AddSpecBuff({31589}, L["Arcane"]) -- Slow
AddSpecBuff({12472}, L["Frost"]) -- Icy Veins
AddSpecBuff({31570, 31569}, L["Arcane"]) -- Improved Blink

-- PALADIN
AddSpecBuff({31836, 31834, 31833, 31835}, L["Holy"]) -- Light's Grace
AddSpecBuff({31842}, L["Holy"]) -- Divine Illumination
AddSpecBuff({20216}, L["Holy"]) -- Divine Favor
AddSpecBuff({27170}, L["Retribution"]) -- Seal of Command
AddSpecBuff({20049}, L["Retribution"]) -- Vengeance
AddSpecBuff({20218}, L["Retribution"]) -- Sanctity Aura
AddSpecBuff({26017, 26018, 67, 26016, 9452, 26021}, L["Retribution"]) -- Vindication
AddSpecBuff({27179}, L["Protection"]) -- Holy Shield

-- PRIEST
AddSpecBuff({15473}, L["Shadow"]) -- Shadowform
AddSpecBuff({15286}, L["Shadow"]) -- Vampiric Embrace
AddSpecBuff({45241, 45244, 45237, 45243, 45242, 45234}, L["Discipline"]) -- Focused Will
AddSpecBuff({27811, 27816, 27815, 27813, 27818, 27817}, L["Discipline"]) -- Blessed Recovery
AddSpecBuff({33146, 33143, 33142, 33145}, L["Holy"]) -- Blessed Resilience
AddSpecBuff({14818, 27841, 14819, 25312, 14752}, L["Discipline"]) -- Divine Spirit
AddSpecBuff({32999, 27681}, L["Discipline"]) -- Prayer of Spirit
AddSpecBuff({10060}, L["Discipline"]) -- Power Infusion
AddSpecBuff({33206, 44416}, L["Discipline"]) -- Pain Suppression
AddSpecBuff({14893}, L["Discipline"]) -- Inspiration

-- ROGUE
AddSpecBuff({36554}, L["Subtlety"]) -- Shadowstep
AddSpecBuff({44373}, L["Subtlety"]) -- Shadowstep Speed
AddSpecBuff({36563}, L["Subtlety"]) -- Shadowstep DMG
AddSpecBuff({14278}, L["Subtlety"]) -- Ghostly Strike
AddSpecBuff({31240, 31237, 31238, 31241, 31233, 31236, 31242, 31235, 31239, 31234}, L["Assassination"]) -- Find Weakness
AddSpecBuff({13877}, L["Combat"]) -- Blade Flurry

-- SHAMAN
AddSpecBuff({30809, 30805, 30802, 30808, 30807, 30810, 30804, 30811, 30806, 30803}, L["Enhancement"]) -- Unleashed Rage
AddSpecBuff({16280}, L["Enhancement"]) -- Flurry
AddSpecBuff({30824, 30823}, L["Enhancement"]) -- Shamanistic Rage
AddSpecBuff({16190}, L["Restoration"]) -- Mana Tide Totem
AddSpecBuff({32593, 974, 32594, 379}, L["Restoration"]) -- Earth Shield
AddSpecBuff({29205, 29206, 29202, 29203}, L["Restoration"]) -- Healing Way

-- WARLOCK
AddSpecBuff({19028}, L["Demonology"]) -- Soul Link
AddSpecBuff({23842, 23839, 35706, 23829, 23761, 23826, 23822, 35705, 23835, 23825, 23838, 23841, 23827, 35702, 23828, 35704, 23824, 35703, 23844, 23843, 23840, 23823, 23836, 23785, 23833, 23762, 23760, 23759, 23834, 23837}, L["Demonology"]) -- Master Demonologist
AddSpecBuff({35693, 35691, 35692}, L["Demonology"]) -- Demonic Knowledge
AddSpecBuff({30301, 30302, 30300, 30299}, L["Destruction"]) -- Nether Protection
AddSpecBuff({34936, 34939, 34938, 34935}, L["Destruction"]) -- Backlash

-- WARRIOR
AddSpecBuff({29841, 29834, 29838, 29842}, L["Arms"]) -- Second Wind
AddSpecBuff({12292}, L["Arms"]) -- Death Wish
function Gladdy:GetSpecBuffs()
    return Gladdy.specBuffs
end

Gladdy.specSpells = {}
local function AddSpecSpell(spellIDs, spec)
    for _, spellId in ipairs(spellIDs) do
        Gladdy.specSpells[spellId] = spec
    end
end

-- DRUID
AddSpecSpell({33831}, L["Balance"]) -- Force of Nature
AddSpecSpell({33876, 33983, 33982}, L["Feral"]) -- Mangle (Cat)
AddSpecSpell({33986, 33878, 33987}, L["Feral"]) -- Mangle (Bear)
AddSpecSpell({18562}, L["Restoration"]) -- Swiftmend
AddSpecSpell({17116}, L["Restoration"]) -- Nature's Swiftness
AddSpecSpell({33891}, L["Restoration"]) -- Tree of Life

-- HUNTER
AddSpecSpell({19577}, L["Beast Mastery"]) -- Intimidation
AddSpecSpell({34490}, L["Marksmanship"]) -- Silencing Shot
AddSpecSpell({24134, 24132, 19386, 24135, 27069, 24133, 24131, 27068}, L["Survival"]) -- Wyvern Sting
AddSpecSpell({20909, 19306, 27067, 20910}, L["Survival"]) -- Counterattack
AddSpecSpell({27066}, L["Marksmanship"]) -- Trueshot Aura

-- MAGE
AddSpecSpell({12042}, L["Arcane"]) -- Arcane Power
AddSpecSpell({33042, 33043, 31661, 33041}, L["Fire"]) -- Dragon's Breath
AddSpecSpell({33933, 11113, 13018, 27133, 13019, 13021, 13020}, L["Fire"]) -- Blast Wave
AddSpecSpell({13032, 33405, 13033, 27134, 11426, 13031}, L["Frost"]) -- Ice Barrier
AddSpecSpell({31687}, L["Frost"]) -- Summon Water Elemental
AddSpecSpell({12472}, L["Frost"]) -- Icy Veins
AddSpecSpell({11958}, L["Frost"]) -- Cold Snap

-- PALADIN
AddSpecSpell({33073, 33072, 27175, 25914, 33074, 25903, 20930, 25911, 25902, 25913, 25912, 20473, 27174, 20929, 27176}, L["Holy"]) -- Holy Shock
AddSpecSpell({20216}, L["Holy"]) -- Divine Favor
AddSpecSpell({31842}, L["Holy"]) -- Divine Illumination
AddSpecSpell({32699, 31935, 32700}, L["Protection"]) -- Avenger's Shield
AddSpecSpell({27170}, L["Retribution"]) -- Seal of Command
AddSpecSpell({35395}, L["Retribution"]) -- Crusader Strike
AddSpecSpell({20066}, L["Retribution"]) -- Repentance
AddSpecSpell({20218}, L["Retribution"]) -- Sanctity Aura

-- PRIEST
AddSpecSpell({10060}, L["Discipline"]) -- Power Infusion
AddSpecSpell({33206, 44416}, L["Discipline"]) -- Pain Suppression
AddSpecSpell({14818, 27841, 14819, 25312, 14752}, L["Discipline"]) -- Divine Spirit
AddSpecSpell({33146, 33143, 33142, 33145}, L["Holy"]) -- Blessed Resilience
AddSpecSpell({34865, 34861, 34866, 34863, 34864}, L["Holy"]) -- Circle of Healing
AddSpecSpell({15473}, L["Shadow"]) -- Shadowform
AddSpecSpell({34916, 34917, 34914, 34919}, L["Shadow"]) -- Vampiric Touch
AddSpecSpell({15286}, L["Shadow"]) -- Vampiric Embrace

-- ROGUE
AddSpecSpell({34411, 34413, 34412, 1329}, L["Assassination"]) -- Mutilate
AddSpecSpell({14177}, L["Assassination"]) -- Cold Blood
AddSpecSpell({13750}, L["Combat"]) -- Adrenaline Rush
AddSpecSpell({13877}, L["Combat"]) -- Blade Flurry
AddSpecSpell({14185}, L["Subtlety"]) -- Preparation
AddSpecSpell({26864, 17348, 16511, 17347}, L["Subtlety"]) -- Hemorrhage
AddSpecSpell({36554}, L["Subtlety"]) -- Shadowstep
AddSpecSpell({14278}, L["Subtlety"]) -- Ghostly Strike
AddSpecSpell({14183}, L["Subtlety"]) -- Premeditation

-- SHAMAN
AddSpecSpell({16166}, L["Elemental"]) -- Elemental Mastery
AddSpecSpell({30708, 30706}, L["Elemental"]) -- Totem of Wrath
AddSpecSpell({30824, 30823}, L["Enhancement"]) -- Shamanistic Rage
AddSpecSpell({32176, 17364, 32175}, L["Enhancement"]) -- Stormstrike
AddSpecSpell({16190}, L["Restoration"]) -- Mana Tide Totem
AddSpecSpell({32593, 974, 32594, 379}, L["Restoration"]) -- Earth Shield
AddSpecSpell({16188}, L["Restoration"]) -- Nature's Swiftness

-- WARLOCK
AddSpecSpell({30108, 31117, 30404, 30405}, L["Affliction"]) -- Unstable Affliction
AddSpecSpell({18220, 27265, 18937, 18938}, L["Affliction"]) -- Dark Pact
AddSpecSpell({30413, 30414, 30283}, L["Destruction"]) -- Shadowfury
AddSpecSpell({30912, 17962, 18932, 18931, 27266, 18930}, L["Destruction"]) -- Conflagrate
AddSpecSpell({18708}, L["Demonology"]) -- Fel Domination

-- WARRIOR
AddSpecSpell({21552, 30330, 12294, 21553, 25248, 21551}, L["Arms"]) -- Mortal Strike
AddSpecSpell({12292}, L["Arms"]) -- Death Wish
AddSpecSpell({30335, 23881, 25253, 23885, 23890, 23886, 25252, 23889, 30339, 23893, 23887, 30340, 23894, 23880, 23888, 25251, 23891, 23892}, L["Fury"]) -- Bloodthirst
AddSpecSpell({12809}, L["Protection"]) -- Concussion Blow
AddSpecSpell({20243, 30016, 30022}, L["Protection"]) -- Devastate
AddSpecSpell({23923, 23925, 23924, 30356, 23922, 25258}, L["Protection"]) -- Shield Slam
function Gladdy:GetSpecSpells()
    return Gladdy.specSpells
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
AddImportantAura(18658, AURA_TYPE_DEBUFF, 40, { 2637, 18657, 18658 }, { duration = 10, magic = true }) -- Hibernate
AddImportantAura(26989, AURA_TYPE_DEBUFF, 30, { 339, 1062, 5195, 5196, 9852, 9853, 26989 }, { duration = 10, magic = true }) -- Entangling Roots
AddImportantAura(27010, AURA_TYPE_DEBUFF, 30, { 27010 }, { duration = 10, altName = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689)) }) -- Entangling Roots (Nature's Grasp)
AddImportantAura(16979, AURA_TYPE_DEBUFF, 30, { 16979 }, { duration = 4 }) -- Feral Charge
AddImportantAura(8983, AURA_TYPE_DEBUFF, 30, { 5211, 6798, 8983 }, { duration = 4 }) -- Bash
AddImportantAura(9005, AURA_TYPE_DEBUFF, 40, { 9005, 9823, 9827, 27006 }, { duration = 3 }) -- Pounce
AddImportantAura(22570, AURA_TYPE_DEBUFF, 40, { 22570 }, { duration = 6 }) -- Maim
AddImportantAura(29166, AURA_TYPE_BUFF, 10, { 29166 }, { duration = 20 }) -- Innervate
AddImportantAura(16922, AURA_TYPE_DEBUFF, 40, { 16922 }, { duration = 3 }) -- Imp Starfire Stun

-- HUNTER
AddImportantAura(14309, AURA_TYPE_DEBUFF, 40, { 14309 }, { duration = 10, magic = true }) -- Freezing Trap Effect
AddImportantAura(19386, AURA_TYPE_DEBUFF, 40, { 19386, 24131, 24132, 24133, 24134, 24135, 27068, 27069 }, { duration = 10 }) -- Wyvern Sting
AddImportantAura(19503, AURA_TYPE_DEBUFF, 40, { 19503 }, { duration = 4 }) -- Scatter Shot
AddImportantAura(14327, AURA_TYPE_DEBUFF, 40, { 1513, 14326, 14327 }, { duration = 8, magic = true }) -- Scare Beast
AddImportantAura(34490, AURA_TYPE_DEBUFF, 15, { 34490 }, { duration = 3, magic = true }) -- Silencing Shot
AddImportantAura(19577, AURA_TYPE_DEBUFF, 40, { 19577 }, { duration = 2 }) -- Intimidation
AddImportantAura(34471, AURA_TYPE_BUFF, 20, { 34471, 34692 }, { duration = 18 }) -- The Beast Within

-- MAGE
AddImportantAura(12826, AURA_TYPE_DEBUFF, 40, { 118, 12824, 12825, 12826, 28271, 28272 }, { duration = 10, magic = true }) -- Polymorph
AddImportantAura(31661, AURA_TYPE_DEBUFF, 40, { 31661, 33041, 33042, 33043 }, { duration = 3, magic = true }) -- Dragon's Breath
AddImportantAura(27088, AURA_TYPE_DEBUFF, 30, { 122, 865, 6131, 10230, 27088 }, { duration = 8, magic = true }) -- Frost Nova
AddImportantAura(33395, AURA_TYPE_DEBUFF, 30, { 33395 }, { duration = 8, magic = true }) -- Freeze (Water Elemental)
AddImportantAura(18469, AURA_TYPE_DEBUFF, 15, { 18469 }, { duration = 4, magic = true }) -- Counterspell - Silence
AddImportantAura(45438, AURA_TYPE_BUFF, 20, { 45438 }, { duration = 10 }) -- Ice Block
AddImportantAura(41425, AURA_TYPE_DEBUFF, 8, { 41425 }) -- Hypothermia
AddImportantAura(12355, AURA_TYPE_DEBUFF, 40, { 11103, 12355, 12357, 12358, 12359, 12360 }, { duration = 2 }) -- Impact
AddImportantAura(31642, AURA_TYPE_BUFF, 10, { 31642, 31641, 31643 }, { duration = 8 }) -- Blazing Speed

-- PALADIN
AddImportantAura(10308, AURA_TYPE_DEBUFF, 40, { 853, 5588, 5589, 10308 }, { duration = 6, magic = true }) -- Hammer of Justice
AddImportantAura(20066, AURA_TYPE_DEBUFF, 40, { 20066 }, { duration = 6, magic = true }) -- Repentance
AddImportantAura(10278, AURA_TYPE_BUFF, 10, { 1022, 5599, 10278 }, { duration = 10 }) -- Blessing of Protection
AddImportantAura(1044, AURA_TYPE_BUFF, 10, { 1044 }, { duration = 14 }) -- Blessing of Freedom
AddImportantAura(6940, AURA_TYPE_BUFF, 12, { 6940, 20729, 27147, 27148 }, { duration = 30 }) -- Blessing of Sacrifice
AddImportantAura(642, AURA_TYPE_BUFF, 20, { 642, 1020 }, { duration = 12 }) -- Divine Shield

-- PRIEST
AddImportantAura(8122, AURA_TYPE_DEBUFF, 40, { 8122, 8124, 10888, 10890 }, { duration = 8, magic = true }) -- Psychic Scream
AddImportantAura(44047, AURA_TYPE_DEBUFF, 30, { 44041, 44043, 44044, 44045, 44046, 44047 }, { duration = 8 }) -- Chastise
AddImportantAura(605, AURA_TYPE_DEBUFF, 40, { 605, 10911, 10912 }, { duration = 10, magic = true }) -- Mind Control
AddImportantAura(15269, AURA_TYPE_DEBUFF, 40, { 15269 }, { duration = 3 }) -- Blackout Stun
AddImportantAura(15487, AURA_TYPE_DEBUFF, 15, { 15487 }, { duration = 5, magic = true }) -- Silence
AddImportantAura(33206, AURA_TYPE_BUFF, 10, { 33206, 44416 }, { duration = 8 }) -- Pain Suppression
AddImportantAura(6346, AURA_TYPE_BUFF, 9, { 6346 }, { duration = 180 }) -- Fear Ward

-- ROGUE
AddImportantAura(6770, AURA_TYPE_DEBUFF, 40, { 2070, 6770, 11297 }, { duration = 10 }) -- Sap
AddImportantAura(2094, AURA_TYPE_DEBUFF, 40, { 2094 }, { duration = 10 }) -- Blind
AddImportantAura(1833, AURA_TYPE_DEBUFF, 40, { 1833 }, { duration = 4 }) -- Cheap Shot
AddImportantAura(8643, AURA_TYPE_DEBUFF, 40, { 408, 8643 }, { duration = 6 }) -- Kidney Shot
AddImportantAura(1776, AURA_TYPE_DEBUFF, 40, { 1776, 1777, 8629, 11285, 11286, 38764 }, { duration = 4 }) -- Gouge
AddImportantAura(18425, AURA_TYPE_DEBUFF, 15, { 18425 }, { duration = 2 }) -- Kick - Silence
AddImportantAura(1330, AURA_TYPE_DEBUFF, 15, { 1330 }, { duration = 3 }) -- Garrote - Silence
AddImportantAura(31224, AURA_TYPE_BUFF, 20, { 31224 }, { duration = 5 }) -- Cloak of Shadows
AddImportantAura(26669, AURA_TYPE_BUFF, 10, { 5277, 26669 }, { duration = 15 }) -- Evasion
AddImportantAura(11305, AURA_TYPE_BUFF, 10, { 11305, 8696, 2983 }, { duration = 15 }) -- Sprint
AddImportantAura(14251, AURA_TYPE_DEBUFF, 20, { 14251 }, { duration = 6 }) -- Riposte

--SHAMAN
AddImportantAura(8178, AURA_TYPE_BUFF, 20, { 8178 }, { duration = 0 }) -- Grounding Totem Effect
AddImportantAura(30823, AURA_TYPE_BUFF, 14, { 30823, 30824 }, { duration = 15 }) -- Shamanistic Rage
AddImportantAura(16188, AURA_TYPE_BUFF, 25, { 16188, 17116 }, { duration = 180 }) -- Nature's Swiftness

-- WARLOCK
AddImportantAura(5782, AURA_TYPE_DEBUFF, 40, { 5782, 6213, 6215 }, { duration = 10, magic = true }) -- Fear
AddImportantAura(27223, AURA_TYPE_DEBUFF, 40, { 6789, 17925, 17926, 27223 }, { duration = 3 }) -- Death Coil
AddImportantAura(710, AURA_TYPE_DEBUFF, 40, { 710, 18647 }, { duration = 10 }) -- Banish
AddImportantAura(30283, AURA_TYPE_DEBUFF, 40, { 30283, 30413, 30414 }, { duration = 2, magic = true }) -- Shadowfury
AddImportantAura(6358, AURA_TYPE_DEBUFF, 40, { 6358, 20407, 30850 }, { duration = 10, magic = true }) -- Seduction (Succubus)
AddImportantAura(5484, AURA_TYPE_DEBUFF, 40, { 5484, 17928 }, { duration = 8, magic = true }) -- Howl of Terror
AddImportantAura(24259, AURA_TYPE_DEBUFF, 15, { 19244, 24259 }, { duration = 3, magic = true }) -- Spell Lock (Felhunter)
AddImportantAura(31117, AURA_TYPE_DEBUFF, 15, { 30108, 30404, 30405, 31117 }, { duration = 5, magic = true, altName = select(1, GetSpellInfo(31117)) .. " Silence" }) -- Unstable Affliction Silence

-- WARRIOR
AddImportantAura(5246, AURA_TYPE_DEBUFF, 15, { 5246 }, { duration = 8 }) -- Intimidating Shout
AddImportantAura(12809, AURA_TYPE_DEBUFF, 40, { 12809 }, { duration = 5 }) -- Concussion Blow
AddImportantAura(25274, AURA_TYPE_DEBUFF, 40, { 25274 }, { duration = 3, texture = select(3, GetSpellInfo(25272)) }) -- Intercept Stun
AddImportantAura(7922, AURA_TYPE_DEBUFF, 40, { 7922 }, { duration = 1, texture = select(3, GetSpellInfo(100)) }) -- Charge Stun
AddImportantAura(23920, AURA_TYPE_BUFF, 50, { 23920 }, { duration = 5 }) -- Spell Reflection
AddImportantAura(18498, AURA_TYPE_DEBUFF, 15, { 18498 }, { duration = 3 }) -- Shield Bash - Silenced
AddImportantAura(12292, AURA_TYPE_BUFF, 15, { 12292 }, { duration = 3 }) -- Death Wish
AddImportantAura(676, AURA_TYPE_DEBUFF, 20, { 676 }, { duration = 10 }) -- Disarm
AddImportantAura(3411, AURA_TYPE_BUFF, 10, { 3411 }, { duration = 10 }) -- Intervene
AddImportantAura(23694, AURA_TYPE_DEBUFF, 40, { 23694 }, { duration = 5 }) -- Improved Hamstring

-- MISC / ITEMS / RACIALS
AddImportantAura(5530, AURA_TYPE_DEBUFF, 40, { 5530 }, { duration = 3, texture = select(3, GetSpellInfo(12284)) }) -- Mace Stun Effect
AddImportantAura(34510, AURA_TYPE_DEBUFF, 40, { 34510 }, { duration = 4 }) -- Storm Herald Stun effect
AddImportantAura(20549, AURA_TYPE_DEBUFF, 40, { 20549 }, { duration = 2 }) -- War Stomp
AddImportantAura(28730, AURA_TYPE_DEBUFF, 15, { 28730 }, { duration = 2, magic = true }) -- Arcane Torrent
AddImportantAura(20600, AURA_TYPE_BUFF, 10, { 20600 }, { duration = 20 }) -- Perception
AddImportantAura(20594, AURA_TYPE_BUFF, 10, { 20594 }, { duration = 8 }) -- Stoneform
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

local function AddInterrupt(spellID, duration, priority, spellIDs)
    local name, _, texture = GetSpellInfo(spellID)
    if name then
        interrupts[spellID] = {
            duration = duration,
            spellID = spellID,
            spellIDs = spellIDs,
            track = AURA_TYPE_DEBUFF,
            texture = texture or GetSpellTexture(spellID),
            priority = priority
        }
    end
end

AddInterrupt(19675, 4, 15, { 19675 })   -- Feral Charge Effect (Druid)
AddInterrupt(2139, 8, 15, { 2139 })   -- Counterspell (Mage)
AddInterrupt(1766, 5, 15, { 1766, 1769, 1769, 1768, 1767, 38768 })   -- Kick (Rogue)
AddInterrupt(6552, 4, 15, { 6552, 6554 })   -- Pummel (Warrior) -- 6554
AddInterrupt(72, 6, 15, { 72, 1671, 1672, 29704 })   -- Shield Bash (Warrior)
AddInterrupt(8042, 2, 15, { 8042, 10414, 10412, 25454, 8044, 10413, 8046, 8045 })   -- Earth Shock (Shaman)
AddInterrupt(19244, 5, 15, { 19675, 19647, 19244, 24259 })   -- Spell Lock (Warlock)
AddInterrupt(32747, 3, 15, { 19675 })   -- Deadly Throw Interrupt

function Gladdy:GetInterrupts()
    return interrupts
end

local interruptsToCanonical = {} -- Reverse lookup: spellID -> canonical spellID
function Gladdy:GetInterruptsCanonical()
    if #interruptsToCanonical == 0 then
        for spellId,info in pairs(Gladdy:GetInterrupts()) do
            interruptsToCanonical[spellId] = spellId
            if info.spellIDs then
                for _, rankedSpellID in pairs(info.spellIDs) do
                    interruptsToCanonical[rankedSpellID] = spellId
                end
            end
        end
    end
    return interruptsToCanonical
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
AddCooldownEntry("MAGE", 122,  { cd = 22, spellIDs = { 122, 10230, 6131, 27088, 865 } }) -- Frost Nova
AddCooldownEntry("MAGE", 12051, { cd = 480 }) -- Evocation
AddCooldownEntry("MAGE", 2139, { cd = 24 }) -- Counterspell
AddCooldownEntry("MAGE", 45438, { cd = 300, [L["Frost"]] = 240 }) -- Ice Block
AddCooldownEntry("MAGE", 12472, { cd = 180, spec = L["Frost"] }) -- Icy Veins
AddCooldownEntry("MAGE", 31687, { cd = 180, spec = L["Frost"] }) -- Summon Water Elemental
AddCooldownEntry("MAGE", 12043, { cd = 180, spec = L["Arcane"] }) -- Presence of Mind
AddCooldownEntry("MAGE", 11129, { cd = 180, spec = L["Fire"] }) -- Combustion
AddCooldownEntry("MAGE", 120, { cd = 10, sharedCD = { [31661] = true }, spellIDs = { 120, 10160, 10159, 10161, 8492, 27087 } }) -- Cone of Cold
AddCooldownEntry("MAGE", 31661, { cd = 20, sharedCD = { [120] = true }, spec = L["Fire"], spellIDs = { 31661, 33041, 33043, 33042 } }) -- Dragon's Breath
AddCooldownEntry("MAGE", 12042, { cd = 180, spec = L["Arcane"] }) -- Arcane Power
AddCooldownEntry("MAGE", 11958, { cd = 384, spec = L["Frost"], resetCD = { [12472] = true, [45438] = true, [31687] = true } }) -- Coldsnap

-- Priest
AddCooldownEntry("PRIEST", 10890, { cd = 27, [L["Shadow"]] = 23, spellIDs = { 10890, 8122, 8124, 10888 } }) -- Psychic Scream
AddCooldownEntry("PRIEST", 15487, { cd = 45, spec = L["Shadow"] }) -- Silence
AddCooldownEntry("PRIEST", 10060, { cd = 180, spec = L["Discipline"] }) -- Power Infusion
AddCooldownEntry("PRIEST", 33206, { cd = 120, spec = L["Discipline"] }) -- Pain Suppression
AddCooldownEntry("PRIEST", 34433, { cd = 300 }) -- Shadowfiend
AddCooldownEntry("PRIEST", 32379, { cd = 12, spellIDs = { 32379, 32996 } }) -- Shadow Word: Death
AddCooldownEntry("PRIEST", 6346, { cd = 180 }) -- Fear Ward

-- Druid
AddCooldownEntry("DRUID", 22812, { cd = 60 }) -- Barkskin
AddCooldownEntry("DRUID", 29166, { cd = 360 }) -- Innervate
AddCooldownEntry("DRUID", 8983, { cd = 60, spellIDs = { 8983, 5211, 6798 } }) -- Bash
AddCooldownEntry("DRUID", 16689, { cd = 60, spellIDs = { 16689, 16810, 16813, 16811, 27009, 17329, 16812 } }) -- Natures Grasp
AddCooldownEntry("DRUID", 18562, { cd = 15, spec = L["Restoration"] }) -- Swiftmend
AddCooldownEntry("DRUID", 17116, { cd = 180, spec = L["Restoration"] }) -- Natures Swiftness
AddCooldownEntry("DRUID", 33831, { cd = 180, spec = L["Balance"] }) -- Force of Nature

-- Shaman
AddCooldownEntry("SHAMAN", 8042, { cd = 6, sharedCD = { [8056] = true, [8050] = true }, spellIDs = { 8042, 10414, 10412, 25454, 8044, 10413, 8046, 8045 } }) -- Earth Shock
AddCooldownEntry("SHAMAN", 30823, { cd = 120, spec = L["Enhancement"] }) -- Shamanistic Rage
AddCooldownEntry("SHAMAN", 16166, { cd = 180, spec = L["Elemental"] }) -- Elemental Mastery
AddCooldownEntry("SHAMAN", 16188, { cd = 180, spec = L["Restoration"] }) -- Natures Swiftness
AddCooldownEntry("SHAMAN", 16190, { cd = 300, spec = L["Restoration"] }) -- Mana Tide Totem
AddCooldownEntry("SHAMAN", 8177, { cd = 15 }) -- Grounding Totem

-- Paladin
AddCooldownEntry("PALADIN", 10278, { cd = 180, spellIDs = { 10278, 1022, 5599 } }) -- Blessing of Protection
AddCooldownEntry("PALADIN", 1044, { cd = 25 }) -- Blessing of Freedom
AddCooldownEntry("PALADIN", 10308, { cd = 60, [L["Retribution"]] = 40, spellIDs = { 10308, 5589, 5588, 853 } }) -- Hammer of Justice
AddCooldownEntry("PALADIN", 642, { cd = 300, sharedCD = { cd = 60, [31884] = true }, spellIDs = { 642, 1020 } }) -- Divine Shield
AddCooldownEntry("PALADIN", 31884, { cd = 180, spec = L["Retribution"], sharedCD = { cd = 60, [642] = true } }) -- Avenging Wrath
AddCooldownEntry("PALADIN", 20066, { cd = 60, spec = L["Retribution"] }) -- Repentance
AddCooldownEntry("PALADIN", 31842, { cd = 180, spec = L["Holy"] }) -- Divine Illumination
AddCooldownEntry("PALADIN", 31935, { cd = 30, spec = L["Protection"], spellIDs = { 31935, 32699, 32700 } }) -- Avengers Shield

-- Warlock
AddCooldownEntry("WARLOCK", 17928, { cd = 40, spellIDs = { 17928, 5484 } }) -- Howl of Terror
AddCooldownEntry("WARLOCK", 27223, { cd = 120, spellIDs = { 27223, 17925, 17926, 6789 } }) -- Death Coil
AddCooldownEntry("WARLOCK", 19647, { cd = 24 }) -- Spell Lock
AddCooldownEntry("WARLOCK", 27277, { cd = 8 }) -- Devour Magic
AddCooldownEntry("WARLOCK", 30414, { cd = 20, spec = L["Destruction"], spellIDs = { 30414, 30413, 30283 } }) -- Shadowfury
AddCooldownEntry("WARLOCK", 17877, { cd = 15, spec = L["Destruction"], spellIDs = { 17877, 18869, 18867, 27263, 18870, 18871, 30546, 18868 } }) -- Shadowburn
AddCooldownEntry("WARLOCK", 30912, { cd = 10, spec = L["Destruction"], spellIDs = { 30912, 18930, 27266, 18931, 18932, 17962 } }) -- Conflagrate
AddCooldownEntry("WARLOCK", 18708, { cd = 900, spec = L["Demonology"] }) -- Feldom

-- Warrior
AddCooldownEntry("WARRIOR", 6552, { cd = 10, sharedCD = { [72] = true }, spellIDs = { 6552, 6554 } }) -- Pummel
AddCooldownEntry("WARRIOR", 72, { cd = 12, sharedCD = { [6552] = true }, spellIDs = { 72, 1672, 29704, 1671 } }) -- Shield Bash
AddCooldownEntry("WARRIOR", 23920, { cd = 10 }) -- Spell Reflection
AddCooldownEntry("WARRIOR", 3411, { cd = 30 }) -- Intervene
AddCooldownEntry("WARRIOR", 676, { cd = 60 }) -- Disarm
AddCooldownEntry("WARRIOR", 5246, { cd = 180 }) -- Intimidating Shout
AddCooldownEntry("WARRIOR", 18499, { cd = 30 }) -- Berserker Rage
AddCooldownEntry("WARRIOR", 2565, { cd = 60 }) -- Shield Block
AddCooldownEntry("WARRIOR", 12292, { cd = 180, spec = L["Arms"] }) -- Death Wish
AddCooldownEntry("WARRIOR", 20252, { cd = 25, [L["Arms"]] = 15, spellIDs = { 20252, 20616, 25275, 20617, 25272 } }) -- Intercept
AddCooldownEntry("WARRIOR", 12975, { cd = 180, spec = L["Protection"] }) -- Last Stand
AddCooldownEntry("WARRIOR", 12809, { cd = 30, spec = L["Protection"] }) -- Concussion Blow

-- Hunter
AddCooldownEntry("HUNTER", 19503, { cd = 30 }) -- Scatter Shot
AddCooldownEntry("HUNTER", 14327, { cd = 30, spellIDs = { 14327, 14326, 1513 } }) -- Scare Beast
AddCooldownEntry("HUNTER", 19263, { cd = 300, spec = { L["Marksmanship"], L["Survival"] } }) -- Deterrence; not on BM but can't do 2 specs
AddCooldownEntry("HUNTER", 13809, { cd = 30, sharedCD = { [14311] = true, [34600] = true }, icon = select(3, GetSpellInfo(14311)) }) -- Frost Trap
AddCooldownEntry("HUNTER", 14311, { cd = 30, sharedCD = { [13809] = true, [34600] = true }, icon = select(3, GetSpellInfo(14311)), spellIDs = { 14311, 1499, 14310 } }) -- Freezing Trap
AddCooldownEntry("HUNTER", 34600, { cd = 30, sharedCD = { [14311] = true, [13809] = true }, icon = select(3, GetSpellInfo(14311)) }) -- Snake Trap
AddCooldownEntry("HUNTER", 34490, { cd = 20, spec = L["Marksmanship"] }) -- Silencing Shot
AddCooldownEntry("HUNTER", 19386, { cd = 120, spec = L["Survival"], spellIDs = { 19386, 24132, 24133, 27068 } }) -- Wyvern Sting
AddCooldownEntry("HUNTER", 19577, { cd = 60, spec = L["Beast Mastery"] }) -- Intimidation
AddCooldownEntry("HUNTER", 34471, { cd = 120, spec = L["Beast Mastery"] }) -- The Beast Within
AddCooldownEntry("HUNTER", 5384, { cd = 30 }) -- Feign Death
AddCooldownEntry("HUNTER", 3034, { cd = 15, spellIDs = { 3034, 14280, 27018, 14279 } }) -- Viper Sting
AddCooldownEntry("HUNTER", 1543, { cd = 20 }) -- Flare

-- Rogue
AddCooldownEntry("ROGUE", 1766, { cd = 10, spellIDs = { 1766, 1767, 1769, 1768, 38768 } }) -- Kick
AddCooldownEntry("ROGUE", 8643, { cd = 20, spellIDs = { 8643, 408 } }) -- Kidney Shot
AddCooldownEntry("ROGUE", 31224, { cd = 60 }) -- Cloak of Shadow
AddCooldownEntry("ROGUE", 26889, { cd = 300, [L["Subtlety"]] = 180, spellIDs = { 26889, 1857, 1856 } }) -- Vanish
AddCooldownEntry("ROGUE", 2094, { cd = 180, [L["Subtlety"]] = 90 }) -- Blind
AddCooldownEntry("ROGUE", 11305, { cd = 300, [L["Combat"]] = 180, spellIDs = { 11305, 8696, 2983 } }) -- Sprint
AddCooldownEntry("ROGUE", 26669, { cd = 300, [L["Combat"]] = 180, spellIDs = { 26669, 5277 } }) -- Evasion
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
