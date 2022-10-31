local tbl_sort, select, string_lower = table.sort, select, string.lower

local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

Gladdy.expansion = "Wrath"
Gladdy.CLASSES = { "MAGE", "PRIEST", "DRUID", "SHAMAN", "PALADIN", "WARLOCK", "WARRIOR", "HUNTER", "ROGUE", "DEATHKNIGHT" }
tbl_sort(Gladdy.CLASSES)

local specBuffs = {
    -- WARRIOR
    [GetSpellInfo(56638)] = L["Arms"], -- Taste for Blood
    [GetSpellInfo(64976)] = L["Arms"], -- Juggernaut
    [GetSpellInfo(57522)] = L["Arms"], -- Enrage
    [GetSpellInfo(52437)] = L["Arms"], -- Sudden Death
    [GetSpellInfo(46857)] = L["Arms"], -- Trauma
    [GetSpellInfo(56112)] = L["Fury"], -- Furious Attacks
    [GetSpellInfo(29801)] = L["Fury"], -- Rampage
    [GetSpellInfo(46916)] = L["Fury"], -- Slam!
    [GetSpellInfo(50227)] = L["Protection"], -- Sword and Board
    [GetSpellInfo(50720)] = L["Protection"], -- Vigilance
    [GetSpellInfo(74347)] = L["Protection"], -- Silenced - Gag Order
    -- PALADIN
    [GetSpellInfo(20375)] = L["Retribution"], -- Seal of Command
    [GetSpellInfo(59578)] = L["Retribution"], -- The Art of War
    [GetSpellInfo(31836)] = L["Holy"], -- Light's Grace
    [GetSpellInfo(53563)] = L["Holy"], -- Beacon of Light
    [GetSpellInfo(54149)] = L["Holy"], -- Infusion of Light
    [GetSpellInfo(63529)] = L["Protection"], -- Silenced - Shield of the Templar
    -- ROGUE
    [GetSpellInfo(36554)] = L["Subtlety"], -- Shadowstep
    [GetSpellInfo(44373)] = L["Subtlety"], -- Shadowstep Speed
    [GetSpellInfo(36563)] = L["Subtlety"], -- Shadowstep DMG
    [GetSpellInfo(51713)] = L["Subtlety"], -- Shadow Dance
    [GetSpellInfo(31665)] = L["Subtlety"], -- Master of Subtlety
    [GetSpellInfo(14278)] = L["Subtlety"], -- Ghostly Strike
    [GetSpellInfo(51690)] = L["Combat"], -- Killing Spree
    [GetSpellInfo(13877)] = L["Combat"], -- Blade Flurry
    [GetSpellInfo(13750)] = L["Combat"], -- Adrenaline Rush
    [GetSpellInfo(14177)] = L["Assassination"], -- Cold Blood
    -- PRIEST
    [GetSpellInfo(47788)] = L["Holy"], -- Guardian Spirit
    [GetSpellInfo(52800)] = L["Discipline"], -- Borrowed Time
    [GetSpellInfo(63944)] = L["Discipline"], -- Renewed Hope
    [GetSpellInfo(15473)] = L["Shadow"], -- Shadowform
    [GetSpellInfo(15286)] = L["Shadow"], -- Vampiric Embrace
    -- DEATHKNIGHT
    [GetSpellInfo(49222)] = L["Unholy"], -- Bone Shield
    [GetSpellInfo(49016)] = L["Blood"], -- Hysteria
    [GetSpellInfo(53138)] = L["Blood"], -- Abomination's Might
    [GetSpellInfo(55610)] = L["Frost"], -- Imp. Icy Talons
    -- MAGE
    [GetSpellInfo(43039)] = L["Frost"], -- Ice Barrier
    [GetSpellInfo(74396)] = L["Frost"], -- Fingers of Frost
    [GetSpellInfo(57761)] = L["Frost"], -- Fireball!
    [GetSpellInfo(11129)] = L["Fire"], -- Combustion
    [GetSpellInfo(64346)] = L["Fire"], -- Fiery Payback
    [GetSpellInfo(48108)] = L["Fire"], -- Hot Streak
    [GetSpellInfo(54741)] = L["Fire"], -- Firestarter
    [GetSpellInfo(55360)] = L["Fire"], -- Living Bomb
    [GetSpellInfo(31583)] = L["Arcane"], -- Arcane Empowerment
    [GetSpellInfo(44413)] = L["Arcane"], -- Incanter's Absorption
    -- WARLOCK
    [GetSpellInfo(30302)] = L["Destruction"], -- Nether Protection
    [GetSpellInfo(63244)] = L["Destruction"], -- Pyroclasm
    [GetSpellInfo(54277)] = L["Destruction"], -- Backdraft
    [GetSpellInfo(47283)] = L["Destruction"], -- Empowered Imp
    [GetSpellInfo(34936)] = L["Destruction"], -- Backlash
    [GetSpellInfo(47193)] = L["Demonology"], -- Demonic Empowerment
    [GetSpellInfo(64371)] = L["Affliction"], -- Eradication
    -- SHAMAN
    [GetSpellInfo(57663)] = L["Elemental"], -- Totem of Wrath
    [GetSpellInfo(65264)] = L["Elemental"], -- Lava Flows
    [GetSpellInfo(51470)] = L["Elemental"], -- Elemental Oath
    [GetSpellInfo(52179)] = L["Elemental"], -- Astral Shift
    [GetSpellInfo(49284)] = L["Restoration"], -- Earth Shield
    [GetSpellInfo(53390)] = L["Restoration"], -- Tidal Waves
    [GetSpellInfo(30809)] = L["Enhancement"], -- Unleashed Rage
    [GetSpellInfo(53817)] = L["Enhancement"], -- Maelstrom Weapon
    [GetSpellInfo(63685)] = L["Enhancement"], -- Freeze (Frozen Power)
    -- HUNTER
    [GetSpellInfo(20895)] = L["Beast Mastery"], -- Spirit Bond
    [GetSpellInfo(34471)] = L["Beast Mastery"], -- The Beast Within
    [GetSpellInfo(75447)] = L["Beast Mastery"], -- Ferocious Inspiration
    [GetSpellInfo(19506)] = L["Marksmanship"], -- Trueshot Aura
    [GetSpellInfo(64420)] = L["Survival"], -- Sniper Training
    -- DRUID
    [GetSpellInfo(24932)] = L["Feral"], -- Leader of the Pack
    [GetSpellInfo(16975)] = L["Feral"], -- Predatory Strikes
    [GetSpellInfo(50334) .. " Feral"] = L["Feral"], -- Berserk
    [GetSpellInfo(24907)] = L["Balance"], -- Moonkin Aura
    [GetSpellInfo(24858)] = L["Balance"], -- Moonkin Form
    [GetSpellInfo(48504)] = L["Restoration"], -- Living Seed
    [GetSpellInfo(45283)] = L["Restoration"], -- Natural Perfection
    [GetSpellInfo(53251)] = L["Restoration"], -- Wild Growth
    [GetSpellInfo(16188)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(33891)] = L["Restoration"], -- Tree of Life
}
function Gladdy:GetSpecBuffs()
    return specBuffs
end

local specSpells = {
    -- WARRIOR
    [GetSpellInfo(47486)] = L["Arms"], -- Mortal Strike
    [GetSpellInfo(46924)] = L["Arms"], -- Bladestorm
    [GetSpellInfo(23881)] = L["Fury"], -- Bloodthirst
    [GetSpellInfo(12809)] = L["Protection"], -- Concussion Blow
    [GetSpellInfo(47498)] = L["Protection"], -- Devastate
    [GetSpellInfo(46968)] = L["Protection"], -- Shockwave
    [GetSpellInfo(50720)] = L["Protection"], -- Vigilance
    -- PALADIN
    [GetSpellInfo(48827)] = L["Protection"], -- Avenger's Shield
    [GetSpellInfo(48825)] = L["Holy"], -- Holy Shock
    [GetSpellInfo(53563)] = L["Holy"], -- Beacon of Light
    [GetSpellInfo(35395)] = L["Retribution"], -- Crusader Strike
    [GetSpellInfo(66006)] = L["Retribution"], -- Divine Storm
    [GetSpellInfo(20066)] = L["Retribution"], -- Repentance
    -- ROGUE
    [GetSpellInfo(48666)] = L["Assassination"], -- Mutilate
    [GetSpellInfo(14177)] = L["Assassination"], -- Cold Blood
    [GetSpellInfo(51690)] = L["Combat"], -- Killing Spree
    [GetSpellInfo(13877)] = L["Combat"], -- Blade Flurry
    [GetSpellInfo(13750)] = L["Combat"], -- Adrenaline Rush
    [GetSpellInfo(36554)] = L["Subtlety"], -- Shadowstep
    [GetSpellInfo(48660)] = L["Subtlety"], -- Hemorrhage
    [GetSpellInfo(51713)] = L["Subtlety"], -- Shadow Dance
    -- PRIEST
    [GetSpellInfo(53007)] = L["Discipline"], -- Penance
    [GetSpellInfo(10060)] = L["Discipline"], -- Power Infusion
    [GetSpellInfo(33206)] = L["Discipline"], -- Pain Suppression
    [GetSpellInfo(34861)] = L["Holy"], -- Circle of Healing
    [GetSpellInfo(15487)] = L["Shadow"], -- Silence
    [GetSpellInfo(48160)] = L["Shadow"], -- Vampiric Touch
    -- DEATHKNIGHT
    [GetSpellInfo(55262)] = L["Blood"], -- Heart Strike
    [GetSpellInfo(49203)] = L["Frost"], -- Hungering Cold
    [GetSpellInfo(55268)] = L["Frost"], -- Frost Strike
    [GetSpellInfo(51411)] = L["Frost"], -- Howling Blast
    [GetSpellInfo(55271)] = L["Unholy"], -- Scourge Strike
    -- MAGE
    [GetSpellInfo(44781)] = L["Arcane"], -- Arcane Barrage
    [GetSpellInfo(55360)] = L["Fire"], -- Living Bomb
    [GetSpellInfo(42950)] = L["Fire"], -- Dragon's Breath
    [GetSpellInfo(42945)] = L["Fire"], -- Blast Wave
    [GetSpellInfo(44572)] = L["Frost"], -- Deep Freeze
    -- WARLOCK
    [GetSpellInfo(59164)] = L["Affliction"], -- Haunt
    [GetSpellInfo(47843)] = L["Affliction"], -- Unstable Affliction
    [GetSpellInfo(47241)] = L["Demonology"], -- Metamorphosis
    [GetSpellInfo(47193)] = L["Demonology"], -- Demonic Empowerment
    [GetSpellInfo(47996) .. " Felguard"] = L["Demonology"], -- Intercept Felguard
    [GetSpellInfo(59172)] = L["Destruction"], -- Chaos Bolt
    [GetSpellInfo(47847)] = L["Destruction"], -- Shadowfury
    -- SHAMAN
    [GetSpellInfo(59159)] = L["Elemental"], -- Thunderstorm
    [GetSpellInfo(16166)] = L["Elemental"], -- Elemental Mastery
    [GetSpellInfo(51533)] = L["Enhancement"], -- Feral Spirit
    [GetSpellInfo(30823)] = L["Enhancement"], -- Shamanistic Rage
    [GetSpellInfo(17364)] = L["Enhancement"], -- Stormstrike
    [GetSpellInfo(61301)] = L["Restoration"], -- Riptide
    [GetSpellInfo(51886)] = L["Restoration"], -- Cleanse Spirit
    -- HUNTER
    [GetSpellInfo(19577)] = L["Beast Mastery"], -- Intimidation
    [GetSpellInfo(34490)] = L["Marksmanship"], -- Silencing Shot
    [GetSpellInfo(53209)] = L["Marksmanship"], -- Chimera Shot
    [GetSpellInfo(60053)] = L["Survival"], -- Explosive Shot
    [GetSpellInfo(49012)] = L["Survival"], -- Wyvern Sting
    -- DRUID
    [GetSpellInfo(53201)] = L["Balance"], -- Starfall
    [GetSpellInfo(61384)] = L["Balance"], -- Typhoon
    [GetSpellInfo(24858)] = L["Balance"], -- Moonkin Form
    [GetSpellInfo(48566)] = L["Feral"], -- Mangle (Cat)
    [GetSpellInfo(48564)] = L["Feral"], -- Mangle (Bear)
    [GetSpellInfo(50334) .. " Feral"] = L["Feral"], -- Berserk
    [GetSpellInfo(61336)] = L["Feral"], -- Survival Instincts
    [GetSpellInfo(18562)] = L["Restoration"], -- Swiftmend
    [GetSpellInfo(17116)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(33891)] = L["Restoration"], -- Tree of Life
    [GetSpellInfo(53251)] = L["Restoration"], -- Wild Growth
}
function Gladdy:GetSpecSpells()
    return specSpells
end

local importantAuras = {
    --- Crowd control
    [33786] = {  -- Cyclone
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 33786 },
    },
    [18658] = { -- Hibernate
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 2637, 18657, 18658 },
    },
    [14309] = { -- Freezing Trap Effect
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 3355, 14308, 14309 },
    },
    [60210] = { -- Freezing arrow effect
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 60210 },
    },
    [6770] = {  -- Sap
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 2070, 6770, 11297, 51724 },
    },
    [2094] = { -- Blind
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 2094 },
    },
    [10326] = { -- Turn Evil
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 10326 },
    },
    [5782] = { -- Fear
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5782, 6213, 6215 },
    },
    [47860] = { -- Death Coil Warlock
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 6789, 17925, 17926, 27223, 47859, 47860 },
    },
    [6358] = { -- Seduction
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 6358 },
    },
    [5484] = { -- Howl of Terror
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5484, 17928, 50577 },
    },
    [5246] = { -- Intimidating Shout
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5246 },
    },
    [8122] = { -- Psychic Scream
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 8122, 8124, 10888, 10890 },
    },
    [64044] = { -- Psychic Horror
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 64044 },
    },
    [9484] = { -- Shackle Undead
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 9484, 9485, 10955 },
    },
    [12826] = { -- Polymorph
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 118, 12824, 12825, 12826, 28271, 28272, 61305, 61721, 61780 },
        texture = select(3, GetSpellInfo(12826)),
        textureSpell = 12826,
    },
    [51514] = { -- Hex
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 51514 },
    },
    [18647] = { -- Banish
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 710, 18647 },
    },
    [605] = { -- Mind Control
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 605 },
    },
    [14327] = { -- Scare Beast
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 1513, 14326, 14327 },
    },

    --- Roots
    [339] = { -- Entangling Roots
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = {
            339, 1062, 5195, 5196, 9852, 9853, 26989, 53308, -- Entangling Roots
            19975, 19974, 19973, 19972, 19971, 19970, 27010, 53313 -- Nature's Grasp
        },
    },
    [42917] = { -- Frost Nova
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 122, 865, 6131, 10230, 27088, 42917 },
    },
    [33395] = { -- Freeze (Water Elemental)
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 33395, 62469 },
    },
    [12494] = { -- Frost Bite
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 12494 },
    },
    [55080] = { -- Shattered Barrier
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 55080 },
    },
    [16979] = { -- Feral Charge
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 16979 },
    },
    [23694] = { -- Improved Hamstring
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 23694 },
    },
    [4167] = { -- Web (Hunter Pet)
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 4167 },
    },
    [19185] = { -- Entrapment
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 19185, 64803, 64804 },
    },
    [50245] = { -- Pin (Hunter Pet)
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 50245, 53544, 53545, 53546, 53547, 53548 },
    },
    [25999] = { -- Boar Charge
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 25999 },
    },
    [19306] = { -- Counterattack
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 19306, 20909, 20910, 27067, 48998, 48999 },
    },

    --- Stuns and incapacitates
    [5211] = { -- Bash
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5211, 6798, 8983 },
    },
    [1833] = { -- Cheap Shot
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 1833 },
    },
    [408] = { -- Kidney Shot
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 408, 8643 },
    },
    [1776] = { -- Gouge
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 1776 },
    },
    [44572] = { -- Deep Freeze
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 44572 },
    },
    [19386] = { -- Wyvern Sting
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 19386, 24132, 24133, 27068, 49011, 49012 },
    },
    [19503] = { -- Scatter Shot
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 19503 },
    },
    [9005] = { -- Pounce
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 9005, 9823, 9827, 27006, 49803 },
    },
    [22570] = { -- Maim
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 22570, 49802 },
    },
    [853] = { -- Hammer of Justice
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 853, 5588, 5589, 10308 },
    },
    [2812] = { -- Holy Wrath
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 2812, 10318, 27139, 48816, 48817 },
    },
    [20066] = { -- Repentance
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 20066 },
    },
    [46968] = { -- Shockwave
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 46968 },
    },
    [49203] = { -- Hungering Cold
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 49203 },
    },
    [47481] = { -- Gnaw (dk pet stun)
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 47481 },
    },
    [30283] = { -- Shadowfury Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 30283, 30413, 30414, 47846, 47847 },
    },
    [19482] = { -- War Stomp
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 19482, 20549 },
    },
    [7922] = { -- Charge Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 7922, 65929 },
        texture = select(3, GetSpellInfo(100)),
        textureSpell = 100
    },
    [20253] = { -- Intercept Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = {
            20253, 20614, 67573, 25273, 25274, --Warrior
            30153, 30195, 30197, 47995, --Felguard
        },
        texture = select(3, GetSpellInfo(25272)),
        textureSpell = 25272,
    },
    [60995] = { -- Demon Charge
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 60995 },
        texture = select(3, GetSpellInfo(54785)),
        textureSpell = 54785
    },
    [12809] = { -- Concussion Blow
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 12809 },
    },
    [64343] = { -- Impact
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 64343, 12355 },
    },
    [19577] = {-- Intimidation
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 19577 },
    },
    [50518] = { -- Ravage Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 50518, 53558, 53559, 53560, 53561, 53562 },
    },
    [31661] = { -- Dragon's Breath
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 31661, 33041, 33042, 33043, 42949, 42950 },
    },

    --- Stun procs
    [39796] = { -- Stoneclaw Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 39796 },
    },
    [20170] = { -- Seal of Justice Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 20170 },
    },
    [23454] = { -- Brutal Earthstorm Diamond
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 39796 },
    },


    --- Silences
    [18469] = { -- Improved Counterspell
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 18469, 55021 },
    },
    [15487] = { -- Silence
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 15487 },
    },
    [34490] = { -- Silencing Shot
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 34490 },
    },
    [18425] = { -- Improved Kick
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 18425 },
    },
    [47476] = { -- Strangulate
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 47476, 49913, 49914, 49915, 49916 },
    },
    [74347] = { -- Silenced - Gag Order
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 74347 },
    },
    [63529] = { -- Silenced - Shield of the Templar
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 63529 },
    },
    [31117] = { -- Unstable Affliction Silence (GetSpellInfo returns "Unstable Affliction")
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 31117, 43523, 65813 },
    },
    [24259] = { -- Spell Lock (Felhunter)
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 19244, 67519, 24259 },
    },
    [28730] = { -- Arcane Torrent
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 28730, 25046, 50613 },
    },
    [1330] = { -- Garrote - Silence
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 1330 },
    },

    --- Disarms
    [676] = { -- Disarm
        track = AURA_TYPE_DEBUFF,
        priority = 21,
        spellIDs = { 676 },
    },
    [51722] = { -- Dismantle
        track = AURA_TYPE_DEBUFF,
        priority = 21,
        spellIDs = { 51722 },
    },
    [53359] = { -- Chimera Shot - Scorpid
        track = AURA_TYPE_DEBUFF,
        priority = 21,
        spellIDs = { 53359 },
    },
    [64058] = { -- Psychic Horror Disarm
        track = AURA_TYPE_DEBUFF,
        priority = 21,
        spellIDs = { 64058 },
    },

    --- Buffs
    [1022] = { -- Hand of Protection
        track = AURA_TYPE_BUFF,
        priority = 22,
        spellIDs = { 1022, 5599, 10278 },
    },
    [1044] = { -- Hand of Freedom
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 1044 },
    },
    [6940] = { -- Hand of Sacrifice
        track = AURA_TYPE_BUFF,
        priority = 22,
        spellIDs = { 6940 },
    },
    [64205] = { -- Divine Sacrifice
        track = AURA_TYPE_BUFF,
        priority = 22,
        spellIDs = { 64205 },
    },
    [53659] = { -- Sacred Cleansing
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 53659 },
    },
    [54428] = { -- Divine Plea
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 54428 },
    },
    [31821] = { -- Aura mastery
        track = AURA_TYPE_BUFF,
        priority = 21,
        spellIDs = { 31821 },
    },
    [53271] = { -- Master's Call (Hunter Pet Hand of Freedom)
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 53271 },
    },
    [2825] = { -- Bloodlust
        track = AURA_TYPE_BUFF,
        priority = 9,
        spellIDs = { 2825 },
    },
    [32182] = { -- Heroism
        track = AURA_TYPE_BUFF,
        priority = 9,
        spellIDs = { 32182 },
    },
    [33206] = { -- Pain Suppression
        track = AURA_TYPE_BUFF,
        priority = 22,
        spellIDs = { 33206 },
    },
    [29166] = { -- Innervate
        track = AURA_TYPE_BUFF,
        priority = 21,
        spellIDs = { 29166 },
    },
    [18708] = { -- Fel Domination
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 18708 },
    },
    [47241] = { -- Metamorphosis
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 47241 },
    },
    [51713] = { -- Shadow Dance
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 51713 },
    },
    [12292] = { -- Death Wish
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 12292 },
    },
    [23920] = { -- Spell Reflection
        track = AURA_TYPE_BUFF,
        priority = 30,
        spellIDs = { 23920 },
    },
    [6346] = { -- Fear Ward
        track = AURA_TYPE_BUFF,
        priority = 9,
        spellIDs = { 6346 },
    },
    [50334] = { -- Berserk
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 50334 },
    },
    [46924] = { -- Bladestorm
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 46924 },
    },
    [13750] = { -- Adrenaline Rush
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 13750 },
    },
    [12042] = { -- Arcane Power
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 12042 },
    },
    [28682] = { -- Combustion
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 28682 },
    },
    [48505] = { -- Starfall
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 48505, 53199, 53200, 53201 },
    },
    [3411] = { -- Intervene
        track = AURA_TYPE_BUFF,
        priority = 21,
        spellIDs = { 3411 },
    },
    [53476] = { -- Intervene Pet
        track = AURA_TYPE_BUFF,
        priority = 21,
        spellIDs = { 53476 },
    },
    [16188] = { -- Nature's Swiftness
        track = AURA_TYPE_BUFF,
        priority = 5,
        spellIDs = { 16188, 17116 },
    },
    [16166] = { -- Elemental Mastery
        track = AURA_TYPE_BUFF,
        priority = 5,
        spellIDs = { 16166 },
    },

    --- Turtling abilities
    [871] = { -- Shield Wall
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 871 },
    },
    [48707] = { -- Anti-Magic Shell
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 48707 },
    },
    [31224] = { -- Cloak of Shadows
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 31224 },
    },
    [19263] = { -- Deterrence
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 19263 },
    },
    [26669] = { -- Evasion
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 5277, 26669 },
    },
    [47585] = { -- Dispersion
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 47585 },
    },
    [498] = { -- Divine Protection
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 498 },
    },
    [20230] = { -- Retaliation
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 20230 },
    },
    [20594] = { -- Stoneform
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 20594 },
    },
    [30823] = { -- Shamanistic Rage
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 30823 },
    },
    [55694] = { -- Enraged Regeneration
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 55694 },
    },
    [22812] = { -- Barkskin
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 22812 },
    },

    --- Immunities
    [34471] = { -- The Beast Within (CC Immune)
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 34471 },
    },
    [45438] = { -- Ice Block
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 45438 },
    },
    [41425] = { -- Hypothermia (Ice Block Immune)
        track = AURA_TYPE_DEBUFF,
        priority = 8,
        spellIDs = { 41425 },
    },
    [642] = { -- Divine Shield
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 642 },
    },
    [18499] = { -- Berserker Rage (Flee Immune)
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 18499 },
    },
    [1719] = { -- Recklessness (Flee Immune)
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 1719 },
    },
    [48792] = { -- Icebound Fortitude
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 48792 },
    },
    [49039] = { -- Lichborne
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 49039 },
    },
    [27827] = { -- Spirit of Redemption
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 27827 },
    },
    [54748] = { -- Burning Determination
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 54748 },
    },

    --- Alt Stuff
    [34709] = { -- Shadowsight Buff
        track = AURA_TYPE_DEBUFF,
        priority = 9,
        spellIDs = { 34709 },
    },
    [8178] = { -- Grounding Totem Effect
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 8178 }
    },
    [5024] = { -- Flee (Skull of impending Doom) -- 5024
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 5024 },
    },

    --- Stances
    [2457] = { -- Battle Stance
        track = AURA_TYPE_BUFF,
        priority = 5,
        spellIDs = { 2457 },
    },
    [2458] = { -- Berserker Stance
        track = AURA_TYPE_BUFF,
        priority = 5,
        spellIDs = { 2458 },
    },
    [71] = { -- Defensive Stance
        track = AURA_TYPE_BUFF,
        priority = 5,
        spellIDs = { 71 },
    },
}

function Gladdy:GetImportantAuras()
    return importantAuras
end

local interrupts = {
    [GetSpellInfo(19675)] = { duration = 4, spellID = 19675, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(19675)), priority = 15 }, -- Feral Charge Effect (Druid)
    [GetSpellInfo(2139)] = { duration = 8, spellID = 2139, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(2139)), priority = 15 }, -- Counterspell (Mage)
    [GetSpellInfo(1766)] = { duration = 5, spellID = 1766, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(1766)), priority = 15 }, -- Kick (Rogue)
    [GetSpellInfo(6552)] = { duration = 4, spellID = 6552, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(6552)), priority = 15 }, -- Pummel (Warrior)
    [GetSpellInfo(72)] = { duration = 6, spellID = 72, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(72)), priority = 15 }, -- Shield Bash (Warrior)
    [GetSpellInfo(57994)] = { duration = 2, spellID = 57994, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(57994)), priority = 15 }, -- Wind Shear (Shaman)
    [GetSpellInfo(19244)] = { duration = 5, spellID = 19244, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(19244)), priority = 15 }, -- Spell Lock (Warlock
    [GetSpellInfo(47528)] = { duration = 5, spellID = 47528, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(47528)), priority = 15 }, -- Mind Freeze (Deathknight)
}
function Gladdy:GetInterrupts()
    return interrupts
end

local cooldownList = {
    -- Spell Name			   Cooldown[, Spec]
    -- Mage
    ["MAGE"] = {
        [1953] = 15, -- Blink
        [42917] = 25, -- Frost Nova
        [2139] = 24, -- Counterspell
        [55342] = 180, -- Mirror Image
        [12051] = 480, --Evocation
        [45438] = { cd = 300, [L["Frost"]] = 240, }, -- Ice Block
        [44572] = { cd = 30, spec = L["Frost"], }, -- Deep Freeze
        [12472] = { cd = 180, spec = L["Frost"], }, -- Icy Veins
        [31687] = { cd = 180, spec = L["Frost"], }, -- Summon Water Elemental
        [12043] = { cd = 120, spec = L["Arcane"], }, -- Presence of Mind
        [12042] = { cd = 180, spec = L["Arcane"], }, -- Arcane Power
        [42950] = { cd = 20, spec = L["Fire"] }, -- Dragon's Breath
        [11129] = { cd = 120, spec = L["Fire"] }, -- Combustion
        [11958] = { cd = 480, spec = L["Frost"], -- Coldsnap
                    resetCD = {
                        [12472] = true,
                        [45438] = true,
                        [42917] = true,
                        [31687] = true,
                        [44572] = true,
                    },
        },
    },

    -- Priest
    ["PRIEST"] = {
        [10890] = { cd = 27, [L["Shadow"]] = 23, }, -- Psychic Scream
        [34433] = { cd = 300, [L["Shadow"]] = 180, }, -- Shadowfiend
        [15487] = { cd = 45, spec = L["Shadow"], }, -- Silence
        [64044] = { cd = 120, spec = L["Shadow"], }, -- Psychic Horror
        [64843] = 480, -- Divine Hymn
        [64901] = 360, -- Hymn of Hope
        [32379] = 12, -- Shadow Word: Death
        [6346] = 180, -- Fear Ward
        [47585] = { cd = 75, spec = L["Shadow"], }, -- Dispersion (+ Glyph)
        [10060] = { cd = 120, spec = L["Discipline"], }, -- Power Infusion
        [33206] = { cd = 180, spec = L["Discipline"], }, -- Pain Suppression
    },

    -- Death Knight
    ["DEATHKNIGHT"] = {
        [47476] = 120, -- Strangulate
        [47528] = 10, -- Mind Freeze
        [48707] = 45, -- Anti-Magic Shell
        [48792] = 120, -- Icebound Fortitude
        [49576] = 35, -- Death Grip
        [47568] = 300, -- Empower Rune Weapon
        [48743] = 120, -- Death Pact
        [49039] = 120, -- Lichborne
        [47481] = { cd = 60, spec = L["Unholy"], }, -- Pet Gnaw
        [51052] = { cd = 120, spec = L["Unholy"], }, -- Anti-Magic Zone
        [46584] = { cd = 180, notSpec = L["Unholy"], }, -- Raise Dead
        [49206] = { cd = 180, spec = L["Unholy"], }, -- Summon Gargoyle
        [49028] = { cd = 90, spec = L["Blood"], }, -- Dancing Rune Weapon
        [49203] = { cd = 60, spec = L["Frost"], }, -- Hungering Cold
    },

    -- Druid
    ["DRUID"] = {
        [22812] = 60, -- Barkskin
        [29166] = 180, -- Innervate
        [8983] = 60, -- Bash
        [53312] = 60, -- Natures Grasp
        [48505] = { cd = 90, spec = L["Balance"], }, -- Starfall
        [50334] = { cd = 180, spec = L["Feral"], altName = GetSpellInfo(50334) .. " Feral" }, -- Berserk
        [61336] = { cd = 180, spec = L["Feral"], }, -- Survival Instincts
        [17116] = { cd = 120, spec = L["Restoration"], }, -- Natures Swiftness
        [18562] = { cd = 15, spec = L["Restoration"], }, -- Swiftmend
        [33831] = { cd = 180, spec = L["Balance"], }, -- Force of Nature
        [61384] = { cd = 20, spec = L["Balance"], }, -- Typhoon
    },

    -- Shaman
    ["SHAMAN"] = {
        [57994] = 6, -- Wind Shear
        [51514] = 45, -- Hex
        [8177] = 15, -- Grounding Totem
        [30823] = { cd = 60, spec = L["Enhancement"], }, -- Shamanistic Rage
        [16166] = { cd = 180, spec = L["Elemental"], }, -- Elemental Mastery
        [59159] = { cd = 35, spec = L["Elemental"], }, -- Thunderstorm
        [16188] = { cd = 120, spec = L["Restoration"], }, -- Natures Swiftness
        [51533] = { cd = 180, spec = L["Enhancement"], }, -- Feral Spirit
        [16190] = { cd = 300, spec = L["Restoration"], }, -- Mana Tide Totem
    },

    -- Paladin
    ["PALADIN"] = {
        [10278] = 300, -- Hand of Protection
        [1044] = 25, -- Hand of Freedom
        [54428] = 60, -- Divine Plea
        [6940] = 120, -- Hand of Sacrifice
        [64205] = 120, -- Divine Sacrifice
        [10308] = { cd = 60, [L["Protection"]] = 40, }, -- Hammer of Justice
        [642] = { cd = 300, -- Divine Shield
                  sharedCD = {
                      cd = 30,
                      [31884] = true,
                  },
        },
        [31884] = { cd = 180, -- Avenging Wrath
                    sharedCD = {
                        cd = 30,
                        [642] = true,
                    },
        },
        [31821] = { cd = 120, spec = L["Holy"], }, -- Aura Mastery
        [20066] = { cd = 60, spec = L["Retribution"], }, -- Repentance
        [20216] = { cd = 120, spec = L["Holy"], }, -- Divine Favor
        [31842] = { cd = 180, spec = L["Holy"], }, -- Divine Illumination
        [31935] = { cd = 30, spec = L["Protection"], }, -- Avengers Shield

    },

    -- Warlock
    ["WARLOCK"] = {
        [17928] = 40, -- Howl of Terror
        [47860] = 120, -- Death Coil
        [18708] = 180, -- Feldom
        [48020] = 30, -- Demonic Circle: Port
        [19647] = { cd = 24, pet = true, }, -- Spell Lock
        [27277] = { cd = 8, pet = true, },  -- Devour Magic
        [61290] = 15,  -- Shadowflame
        [47847] = { cd = 20, spec = L["Destruction"], }, -- Shadowfury
        [17877] = { cd = 15, spec = L["Destruction"], }, -- Shadowburn
        [17962] = { cd = 10, spec = L["Destruction"], }, -- Conflagrate
        [59172] = { cd = 12, spec = L["Destruction"], }, -- Chaos Bolt
        [47241] = { cd = 180, spec = L["Demonology"], }, -- Metamorphosis
        [47996] = { cd = 30, spec = L["Demonology"], pet = true, altName = GetSpellInfo(47996) .. " Felguard" }, -- Intercept
        [1122] = { cd = 600, spec = L["Demonology"], }, -- Inferno
    },

    -- Warrior
    ["WARRIOR"] = {
        [6552] = { cd = 10, -- Pummel
                   sharedCD = {
                       [72] = true,
                   },
        },
        [72] = { cd = 12, -- Shield Bash
                 sharedCD = {
                     [6552] = true,
                 },
        },
        [18499] = 30, -- Berserker Rage
        [23920] = 10, -- Spell Reflection
        [3411] = 30, -- Intervene
        [20252] = { cd = 30, [L["Arms"]] = 20, }, -- Intercept
        [676] = 60, -- Disarm
        [5246] = 120, -- Intimidating Shout
        [2565] = 60, -- Shield Block
        [55694] = 180, -- Enraged Regeneration
        [20230] = 300, -- Retaliation
        [1719] = 300, -- Recklessness
        [871] = 300, -- Shield Wall
        [64382] = 300, -- Shattering Throw
        [12292] = { cd = 180, spec = L["Fury"], }, -- Death Wish
        [46924] = { cd = 90, spec = L["Arms"], }, -- Bladestorm
        [46968] = { cd = 20, spec = L["Protection"], }, -- Shockwave
        [12975] = { cd = 180, spec = L["Protection"], }, -- Last Stand
        [12809] = { cd = 30, spec = L["Protection"], }, -- Concussion Blow

    },

    -- Hunter
    ["HUNTER"] = {
        --[53548] 	= 28,    -- Crab Prin
        --[53562] 	= 40,    -- Ravager Stun

        [19503] = 30, -- Scatter Shot
        [19263] = 90, -- Deterrence
        [781] = 15, -- Disengage
        [5384] = 30, -- Feign Death
        [3045] = 20, -- Rapid Fire
        [60192] = { cd = 28, -- Freezing Arrow
                    sharedCD = {
                        [14311] = true, -- Freezing Trap
                        [13809] = true, -- Frost Trap
                    },
        },
        [14311] = { cd = 28, -- Freezing Trap
                    sharedCD = {
                        [60192] = true, -- Freezing Arrow
                        [13809] = true, -- Frost Trap
                    },
        },
        [13809] = { cd = 28, -- Frost Trap
                    sharedCD = {
                        [14311] = true, -- Freezing Trap
                        [60192] = true, -- Freezing Arrow
                    },
        },
        [34600] = { cd = 28, }, -- Snake Trap
        [34490] = { cd = 20, spec = L["Marksmanship"], }, -- Silencing Shot
        [19386] = { cd = 60, spec = L["Survival"], }, -- Wyvern Sting
        [53271] = { cd = 60, pet = true, }, -- Masters Call
        [19577] = { cd = 60, pet = true, }, -- Intimidation
        [19574] = { cd = 120, pet = true, }, -- Bestial Wrath
        [23989] = { cd = 180, -- Readiness
                    resetCD = {
                        [19503] = true, -- Scatter Shot
                        [19263] = true, -- Deterrence
                        [781] = true, -- Disengage
                        [60192] = true, -- Freezing Arrow
                        [14311] = true, -- Freezing Trap
                        [13809] = true, -- Frost Trap
                        [34600] = true, -- Snake Trap
                        [34490] = true, -- Silencing Shot
                        [19386] = true, -- Wyvern Sting
                        [53271] = true, -- Masters call
                        [19577] = true, -- Intimidation
                    },
        },
    },

    -- Rogue
    ["ROGUE"] = {
        [1766] = 10, -- Kick
        [8643] = 20, -- Kidney Shot
        [26669] = 180, -- Evasion
        [31224] = 60, -- Cloak of Shadow
        [26889] = 180, -- Vanish
        [2094] = 120, -- Blind
        [51722] = 60, -- Dismantle
        [11305] = 180, -- Sprint
        [14177] = { cd = 180, spec = L["Assassination"], }, -- Cold Blood
        [51713] = { cd = 60, spec = L["Subtlety"], }, -- Shadow Dance
        [13750] = { cd = 180, spec = L["Combat"], }, -- Adrenaline Rush
        [13877] = { cd = 120, spec = L["Combat"], }, -- Blade Flurry
        [51690] = { cd = 120, spec = L["Combat"], }, -- Killing Spree
        [36554] = { cd = 20, spec = L["Subtlety"], }, -- Shadowstep
        [14185] = { cd = 480, spec = { L["Subtlety"], L["Assassination"] }, -- Preparation
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

    },
    ["BloodElf"] = {

    },
    ["Tauren"] = {

    },
    ["Orc"] = {

    },
    ["Troll"] = {

    },
    ["NightElf"] = {

    },
    ["Draenei"] = {

    },
    ["Human"] = {

    },
    ["Gnome"] = {
    },
    ["Dwarf"] = {

    },
}
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
        [26297] = true,
        duration = 180,
        spellName = select(1, GetSpellInfo(26297)),
        texture = select(3, GetSpellInfo(26297))
    },
    ["NightElf"] = {
        [58984] = true,
        duration = 120,
        spellName = select(1, GetSpellInfo(58984)),
        texture = select(3, GetSpellInfo(58984))
    },
    ["Draenei"] = {
        [28880] = true,
        duration = 180,
        spellName = select(1, GetSpellInfo(28880)),
        texture = select(3, GetSpellInfo(28880))
    },
    ["Human"] = {
        [59752] = true, -- Perception
        duration = 120,
        spellName = select(1, GetSpellInfo(59752)),
        texture = select(3, GetSpellInfo(59752))
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
    [string_lower("Disease Cleansing Totem")] = {id = 8170,texture = select(3, GetSpellInfo(8170)), color = {r = 0, g = 0, b = 0, a = 1}, pulse = 3},
    [string_lower("Mana Spring Totem")] = { id = 5675, texture = select(3, GetSpellInfo(5675)), color = { r = 0, g = 0, b = 0, a = 1 } },
    -- Earth
    -- Air
}

local totemSpellIdToPulse = {
    [GetSpellInfo(totemData[string_lower("Disease Cleansing Totem")].id)] = totemData[string_lower("Disease Cleansing Totem")].pulse,
    [8170] = totemData[string_lower("Disease Cleansing Totem")].pulse,
}

local totemNpcIdsToTotemData = {
    [5924] = totemData[string_lower("Disease Cleansing Totem")],

    [3573] = totemData[string_lower("Mana Spring Totem")],
    [7414] = totemData[string_lower("Mana Spring Totem")],
    [7415] = totemData[string_lower("Mana Spring Totem")],
    [7416] = totemData[string_lower("Mana Spring Totem")],
    [15304] = totemData[string_lower("Mana Spring Totem")],
    [15489] = totemData[string_lower("Mana Spring Totem")],
    [31186] = totemData[string_lower("Mana Spring Totem")],
    [31189] = totemData[string_lower("Mana Spring Totem")],
    [31190] = totemData[string_lower("Mana Spring Totem")],


}

local totemDataShared, totemNpcIdsToTotemDataShared, totemSpellIdToPulseShared = Gladdy:GetSharedTotemData()
Gladdy:AddEntriesToTable(totemData, totemDataShared)
Gladdy:AddEntriesToTable(totemNpcIdsToTotemData, totemNpcIdsToTotemDataShared)
Gladdy:AddEntriesToTable(totemSpellIdToPulse, totemSpellIdToPulseShared)

function Gladdy:GetTotemData()
    return totemData, totemNpcIdsToTotemData, totemSpellIdToPulse
end
