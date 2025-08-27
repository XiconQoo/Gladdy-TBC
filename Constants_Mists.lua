local tbl_sort, select, string_lower = table.sort, select, string.lower

local GetSpellInfo = GetSpellInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

Gladdy.expansion = "Wrath"
Gladdy.CLASSES = { "MAGE", "PRIEST", "DRUID", "SHAMAN", "PALADIN", "WARLOCK", "WARRIOR", "HUNTER", "ROGUE", "DEATHKNIGHT", "MONK" }
table.sort(Gladdy.CLASSES, function(a, b) return a > b end)
tbl_sort(Gladdy.CLASSES)
Gladdy.RACES[#Gladdy.RACES + 1] = "Goblin"
Gladdy.RACES[#Gladdy.RACES + 1] = "Pandaren"
tbl_sort(Gladdy.RACES)

local specSpells = {
    -- spec to class
}

local classRangeSpells = {
    ["MAGE"] = { spellID = 118, melee = false, range = false }, -- Polymorph
    ["PRIEST"] = { spellID = 32379, melee = false, range = false }, -- Shadow Word: Death
    ["DRUID"] = { spellID = 33786, melee = true, range = false }, -- Cyclone
    ["SHAMAN"] = { spellID = 57994, melee = true, range = false }, -- Wind Shear
    ["PALADIN"] = { spellID = 853, melee = true, range = false }, -- Hammer of Justice
    ["WARLOCK"] = { spellID = 5782, melee = false, range = false }, -- Fear
    ["WARRIOR"] = { spellID = 100, melee = true, range = false }, -- Charge
    ["HUNTER"] = { spellID = 1978, melee = true, range = true }, -- Serpent Sting
    ["ROGUE"] = { spellID = 2094, melee = true, range = false }, -- Blind
    ["DEATHKNIGHT"] = { spellID = 49576, melee = true, range = false }, -- Death Grip
    ["MONK"] = { spellID = 115078, melee = true, range = false }, --Paralysis
}
Gladdy.classRangeSpells = classRangeSpells

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

-- Crowd Control
AddImportantAura(33786, AURA_TYPE_DEBUFF, 40, { 33786 }) -- Cyclone
AddImportantAura(2637, AURA_TYPE_DEBUFF, 40, { 2637 }) -- Hibernate
AddImportantAura(6770, AURA_TYPE_DEBUFF, 40, { 6770 }) -- Sap
AddImportantAura(2094, AURA_TYPE_DEBUFF, 40, { 2094 }) -- Blind
AddImportantAura(5782, AURA_TYPE_DEBUFF, 40, { 5782, 118699, 130616 }) -- Fear
AddImportantAura(6789, AURA_TYPE_DEBUFF, 40, { 6789 }) -- Mortal Coil
AddImportantAura(6358, AURA_TYPE_DEBUFF, 40, { 6358, 115268, 132412 }) -- Seduction
AddImportantAura(5484, AURA_TYPE_DEBUFF, 40, { 5484 }) -- Howl of Terror
AddImportantAura(5246, AURA_TYPE_DEBUFF, 40, { 5246, 20511 }) -- Intimidating Shout
AddImportantAura(8122, AURA_TYPE_DEBUFF, 40, { 8122, 13704 }) -- Psychic Scream
AddImportantAura(64044, AURA_TYPE_DEBUFF, 40, { 64044 }) -- Psychic Horror
AddImportantAura(118, AURA_TYPE_DEBUFF, 40, { 118, 61305, 61780, 61721, 28271, 28272, 61025, 126819 }, { texture = 136071, textureSpell = 118 }) -- Polymorph
AddImportantAura(51514, AURA_TYPE_DEBUFF, 40, { 51514 }) -- Hex
AddImportantAura(710, AURA_TYPE_DEBUFF, 40, { 710 }) -- Banish
AddImportantAura(605, AURA_TYPE_DEBUFF, 40, { 605 }, { priority = true }) -- Dominate Mind
AddImportantAura(1513, AURA_TYPE_DEBUFF, 40, { 1513 }) -- Scare Beast
AddImportantAura(9484, AURA_TYPE_DEBUFF, 40, { 9484, 11444 }) -- Shackle Undead
AddImportantAura(39796, AURA_TYPE_DEBUFF, 40, { 39796 }) -- Stoneclaw Stun
AddImportantAura(2812, AURA_TYPE_DEBUFF, 40, { 2812, 119072 }) -- Holy Wrath
AddImportantAura(10326, AURA_TYPE_DEBUFF, 40, { 10326, 145067 }) -- Turn Evil
AddImportantAura(3355, AURA_TYPE_DEBUFF, 40, { 1499, 3355 }) -- Freezing Trap
AddImportantAura(83046, AURA_TYPE_DEBUFF, 40, { 83046 }) -- Improved Polymorph
AddImportantAura(99, AURA_TYPE_DEBUFF, 40, { 99 }) -- Disorienting Roar
AddImportantAura(113801, AURA_TYPE_DEBUFF, 40, { 113801 }) -- Bash (Force of Nature - Feral Treants)
AddImportantAura(102051, AURA_TYPE_DEBUFF, 40, { 102051 }) -- Frostjaw
AddImportantAura(76780, AURA_TYPE_DEBUFF, 40, { 76780 }) -- Bind Elemental
AddImportantAura(77505, AURA_TYPE_DEBUFF, 40, { 77505 }) -- Earthquake (Stun)
AddImportantAura(118345, AURA_TYPE_DEBUFF, 40, { 118345 }) -- Pulverize
AddImportantAura(118905, AURA_TYPE_DEBUFF, 40, { 118905 }) -- Static Charge
AddImportantAura(113287, AURA_TYPE_DEBUFF, 40, { 113287 }) -- Solar Beam (Symbiosis)
AddImportantAura(113506, AURA_TYPE_DEBUFF, 40, { 113506 }) -- Symbiosis: Cyclone
AddImportantAura(127361, AURA_TYPE_DEBUFF, 40, { 127361 }) -- Symbiosis: Bear Hug
AddImportantAura(113004, AURA_TYPE_DEBUFF, 40, { 113004, 113056 }) -- Symbiosis: Intimidating Roar
AddImportantAura(102355, AURA_TYPE_DEBUFF, 40, { 102355 }) -- Faerie Swarm
AddImportantAura(102795, AURA_TYPE_DEBUFF, 40, { 102795 }) -- Bear Hug
AddImportantAura(114238, AURA_TYPE_DEBUFF, 40, { 114238 }) -- Fae Silence (Glyph of Fae Silence)
AddImportantAura(117526, AURA_TYPE_DEBUFF, 40, { 117526 }) -- Binding Shot Stun
AddImportantAura(115078, AURA_TYPE_DEBUFF, 40, { 115078 }) -- Paralysis
AddImportantAura(119381, AURA_TYPE_DEBUFF, 40, { 119381 }) -- Leg Sweep
AddImportantAura(119392, AURA_TYPE_DEBUFF, 40, { 119392 }) -- Charging Ox Wave
AddImportantAura(120086, AURA_TYPE_DEBUFF, 40, { 120086 }) -- Fists of Fury
AddImportantAura(123393, AURA_TYPE_DEBUFF, 40, { 123393 }) -- Breath of Fire (Glyph of Breath of Fire)
AddImportantAura(117368, AURA_TYPE_DEBUFF, 40, { 117368 }) -- Grapple Weapon
AddImportantAura(137461, AURA_TYPE_DEBUFF, 40, { 137461 }) -- Disarmed (Ring of Peace)
AddImportantAura(137460, AURA_TYPE_DEBUFF, 40, { 137460 }) -- Silenced (Ring of Peace)
AddImportantAura(115001, AURA_TYPE_DEBUFF, 40, { 115001 }) -- Remorseless Winter
AddImportantAura(108194, AURA_TYPE_DEBUFF, 40, { 108194 }) -- Asphyxiate
AddImportantAura(113792, AURA_TYPE_DEBUFF, 40, { 113792 }) -- Psychic Terror (Psyfiend)
AddImportantAura(115750, AURA_TYPE_DEBUFF, 40, { 115750, 105421, 115752 }) -- Blinding Light
AddImportantAura(30217, AURA_TYPE_DEBUFF, 40, { 30217 }) -- Adamantite Grenade
AddImportantAura(89637, AURA_TYPE_DEBUFF, 40, { 89637 }) -- Big Daddy
AddImportantAura(30461, AURA_TYPE_DEBUFF, 40, { 30461 }) -- Bigger One
AddImportantAura(67769, AURA_TYPE_DEBUFF, 40, { 67769 }) -- Cobalt Frag Bomb
AddImportantAura(30216, AURA_TYPE_DEBUFF, 40, { 30216 }) -- Fel Iron Bomb
AddImportantAura(19784, AURA_TYPE_DEBUFF, 40, { 19784 }) -- Dark Iron Bomb
AddImportantAura(13327, AURA_TYPE_DEBUFF, 40, { 13327 }) -- Reckless Charge
AddImportantAura(19769, AURA_TYPE_DEBUFF, 40, { 19769 }) -- Thorium Grenade
AddImportantAura(19821, AURA_TYPE_DEBUFF, 40, { 19821 }) -- Arcane Bomb
AddImportantAura(12562, AURA_TYPE_DEBUFF, 40, { 12562 }) -- The Big One
AddImportantAura(107079, AURA_TYPE_DEBUFF, 40, { 107079 }) -- Quaking Palm
AddImportantAura(129597, AURA_TYPE_DEBUFF, 40, { 129597, 25046, 28730, 50613, 69179, 80483 }) -- Arcane Torrent
AddImportantAura(22703, AURA_TYPE_DEBUFF, 40, { 22703 }) -- Infernal Awakening
AddImportantAura(104045, AURA_TYPE_DEBUFF, 40, { 104045 }) -- Sleep (Metamorphosis)

-- Roots
AddImportantAura(87193, AURA_TYPE_DEBUFF, 30, { 87193, 87194 }) -- Paralysis
AddImportantAura(50245, AURA_TYPE_DEBUFF, 30, { 50245 }) -- Pin (hunter pet)
AddImportantAura(54706, AURA_TYPE_DEBUFF, 30, { 54706 }) -- Venom Web Spray (hunter pet)
AddImportantAura(83302, AURA_TYPE_DEBUFF, 30, { 83302 }) -- Improved Cone of Cold
AddImportantAura(91807, AURA_TYPE_DEBUFF, 30, { 91807 }) -- Shambling Rush, Root
AddImportantAura(96294, AURA_TYPE_DEBUFF, 30, { 96294 }) -- Chains of Ice (Chilblains)
AddImportantAura(53534, AURA_TYPE_DEBUFF, 30, { 53534 }) -- Chains of Ice
AddImportantAura(64695, AURA_TYPE_DEBUFF, 30, { 64695 }) -- Earthgrab Shaman
AddImportantAura(19306, AURA_TYPE_DEBUFF, 30, { 19306 }) -- Counterattack
AddImportantAura(339, AURA_TYPE_DEBUFF, 30, { 339, 19975, 113770, 102359 }) -- Entangling Roots
AddImportantAura(122, AURA_TYPE_DEBUFF, 30, { 122, 55080, 111340 }) -- Frost Nova
AddImportantAura(33395, AURA_TYPE_DEBUFF, 30, { 33395, 63685 }) -- Freeze (Water Elemental)
AddImportantAura(83073, AURA_TYPE_DEBUFF, 30, { 83073 }) -- Shattered Barrier
AddImportantAura(16979, AURA_TYPE_DEBUFF, 30, { 16979, 45334 }) -- Feral Charge
AddImportantAura(23694, AURA_TYPE_DEBUFF, 30, { 23694 }) -- Improved Hamstring
AddImportantAura(4167, AURA_TYPE_DEBUFF, 30, { 4167 }) -- Web (Hunter Pet)
AddImportantAura(47168, AURA_TYPE_DEBUFF, 30, { 47168 }) -- Improved Wingclip
AddImportantAura(19185, AURA_TYPE_DEBUFF, 30, { 19185, 64803 }) -- Entrapment
AddImportantAura(128405, AURA_TYPE_DEBUFF, 30, { 128405 }) -- Narrow Escape
AddImportantAura(113275, AURA_TYPE_DEBUFF, 30, { 113275 }) -- Symbiosis: Entangling Roots
AddImportantAura(110693, AURA_TYPE_DEBUFF, 30, { 110693 }) -- Symbiosis: Frost Nova
AddImportantAura(116706, AURA_TYPE_DEBUFF, 30, { 116706 }) -- Disable
AddImportantAura(123407, AURA_TYPE_DEBUFF, 30, { 123407 }) -- Spinning Fire Blossom
AddImportantAura(115197, AURA_TYPE_DEBUFF, 30, { 115197 }) -- Partial Paralysis
AddImportantAura(105771, AURA_TYPE_DEBUFF, 30, { 105771 }) -- Charge (Warrior)
AddImportantAura(107566, AURA_TYPE_DEBUFF, 30, { 107566 }) -- Staggering Shout
AddImportantAura(39965, AURA_TYPE_DEBUFF, 30, { 39965 }) -- Frost Grenade
AddImportantAura(55536, AURA_TYPE_DEBUFF, 30, { 55536 }) -- Frostweave Net
AddImportantAura(75148, AURA_TYPE_DEBUFF, 30, { 75148 }) -- Embersilk Net
AddImportantAura(13099, AURA_TYPE_DEBUFF, 30, { 13099 }) -- Net-o-Matic
AddImportantAura(90327, AURA_TYPE_DEBUFF, 30, { 90327 }) -- Lock Jaw (Dog)
AddImportantAura(114404, AURA_TYPE_DEBUFF, 30, { 114404 }) -- Void Tendril's Grasp

-- Stuns and Incapacitates
AddImportantAura(87204, AURA_TYPE_DEBUFF, 40, { 87204 }) -- Sin and Punishment
AddImportantAura(54786, AURA_TYPE_DEBUFF, 40, { 54786 }) -- Demon Leap
AddImportantAura(60995, AURA_TYPE_DEBUFF, 40, { 60995 }) -- Demon Charge
AddImportantAura(90337, AURA_TYPE_DEBUFF, 40, { 90337 }) -- Bad Manner
AddImportantAura(88625, AURA_TYPE_DEBUFF, 40, { 88625 }) -- Holy Word: Chastise
AddImportantAura(85388, AURA_TYPE_DEBUFF, 40, { 85388 }) -- Throwdown
AddImportantAura(89766, AURA_TYPE_DEBUFF, 40, { 89766 }) -- Axe Toss (Felguard)
AddImportantAura(82691, AURA_TYPE_DEBUFF, 40, { 82691 }) -- Ring of Frost
AddImportantAura(91797, AURA_TYPE_DEBUFF, 40, { 91797 }) -- Monstrous Blow (Dark Transformation)
AddImportantAura(91800, AURA_TYPE_DEBUFF, 40, { 91800, 47481 }) -- Gnaw (dk pet stun)
AddImportantAura(93986, AURA_TYPE_DEBUFF, 40, { 93986 }) -- Aura of Foreboding
AddImportantAura(5211, AURA_TYPE_DEBUFF, 40, { 5211 }) -- Mighty Bash
AddImportantAura(1833, AURA_TYPE_DEBUFF, 40, { 1833 }) -- Cheap Shot
AddImportantAura(408, AURA_TYPE_DEBUFF, 40, { 408 }) -- Kidney Shot
AddImportantAura(1776, AURA_TYPE_DEBUFF, 40, { 1776 }) -- Gouge
AddImportantAura(44572, AURA_TYPE_DEBUFF, 40, { 44572 }) -- Deep Freeze
AddImportantAura(19386, AURA_TYPE_DEBUFF, 40, { 19386 }) -- Wyvern Sting
AddImportantAura(19503, AURA_TYPE_DEBUFF, 40, { 19503 }) -- Scatter Shot
AddImportantAura(9005, AURA_TYPE_DEBUFF, 40, { 9005, 102546 }) -- Pounce
AddImportantAura(22570, AURA_TYPE_DEBUFF, 40, { 22570 }) -- Maim
AddImportantAura(853, AURA_TYPE_DEBUFF, 40, { 853, 105593 }) -- Hammer of Justice
AddImportantAura(20066, AURA_TYPE_DEBUFF, 40, { 20066 }) -- Repentance
AddImportantAura(46968, AURA_TYPE_DEBUFF, 40, { 46968, 132168 }) -- Shockwave
AddImportantAura(49203, AURA_TYPE_DEBUFF, 40, { 49203 }) -- Hungering Cold
AddImportantAura(30283, AURA_TYPE_DEBUFF, 40, { 30283 }) -- Shadowfury
AddImportantAura(20549, AURA_TYPE_DEBUFF, 40, { 20549 }) -- War Stomp
AddImportantAura(7922, AURA_TYPE_DEBUFF, 40, { 7922, 100 }, { texture = 132337, textureSpell = 100 }) -- Charge Stun
AddImportantAura(20253, AURA_TYPE_DEBUFF, 40, { 20253 }, { texture = 132307, textureSpell = 20252 }) -- Intercept Stun
AddImportantAura(12809, AURA_TYPE_DEBUFF, 40, { 12809 }) -- Concussion Blow
AddImportantAura(12355, AURA_TYPE_DEBUFF, 40, { 12355 }) -- Impact
AddImportantAura(19577, AURA_TYPE_DEBUFF, 40, { 19577, 24394 }) -- Intimidation
AddImportantAura(31661, AURA_TYPE_DEBUFF, 40, { 31661 }) -- Dragon's Breath
AddImportantAura(50519, AURA_TYPE_DEBUFF, 40, { 50519 }) -- Sonic Blast (Bat)
AddImportantAura(56626, AURA_TYPE_DEBUFF, 40, { 56626 }) -- Sting (Wasp)
AddImportantAura(96201, AURA_TYPE_DEBUFF, 40, { 96201 }) -- Web Wrap (Shale Spider)
AddImportantAura(50541, AURA_TYPE_DEBUFF, 40, { 50541 }) -- Clench (Scorpid)
AddImportantAura(126246, AURA_TYPE_DEBUFF, 40, { 126246 }) -- Lullaby (Crane)
AddImportantAura(126355, AURA_TYPE_DEBUFF, 40, { 126355 }) -- Paralyzing Quill (Porcupine)
AddImportantAura(126423, AURA_TYPE_DEBUFF, 40, { 126423 }) -- Petrifying Gaze (Basilisk)
AddImportantAura(107570, AURA_TYPE_DEBUFF, 40, { 107570, 132169, 145585 }) -- Storm Bolt
AddImportantAura(113953, AURA_TYPE_DEBUFF, 40, { 113953 }) -- Paralysis (Paralytic Poison)
AddImportantAura(118271, AURA_TYPE_DEBUFF, 40, { 118271 }) -- Combustion stun
AddImportantAura(122242, AURA_TYPE_DEBUFF, 40, { 122242, 126451 }) -- Clash
AddImportantAura(118895, AURA_TYPE_DEBUFF, 40, { 118895, 118000 }) -- Dragon Roar

-- Silences
AddImportantAura(81261, AURA_TYPE_DEBUFF, 20, { 81261, 78675, 113287 }) -- Solar Beam
AddImportantAura(31935, AURA_TYPE_DEBUFF, 20, { 31935 }) -- Avenger's Shield
AddImportantAura(93985, AURA_TYPE_DEBUFF, 20, { 93985 }) -- Skull Bash
AddImportantAura(55021, AURA_TYPE_DEBUFF, 20, { 55021 }) -- Improved Counterspell
AddImportantAura(15487, AURA_TYPE_DEBUFF, 20, { 15487 }) -- Silence
AddImportantAura(34490, AURA_TYPE_DEBUFF, 20, { 34490 }) -- Silencing Shot
AddImportantAura(18425, AURA_TYPE_DEBUFF, 20, { 18425 }) -- Improved Kick
AddImportantAura(47476, AURA_TYPE_DEBUFF, 20, { 47476 }) -- Strangulate
AddImportantAura(18498, AURA_TYPE_DEBUFF, 20, { 18498 }) -- Silenced - Gag Order
AddImportantAura(31117, AURA_TYPE_DEBUFF, 20, { 31117 }, { altName = GetSpellInfo(31117) .. " Silence" }) -- Unstable Affliction Silence
AddImportantAura(24259, AURA_TYPE_DEBUFF, 20, { 24259 }) -- Spell Lock (Felhunter)
AddImportantAura(28730, AURA_TYPE_DEBUFF, 20, { 28730, 25046, 50613, 69179, 80483, 129597 }) -- Arcane Torrent
AddImportantAura(1330, AURA_TYPE_DEBUFF, 20, { 1330 }) -- Garrote - Silence
AddImportantAura(87023, AURA_TYPE_DEBUFF, 10, { 87023 }) -- Cauterize
AddImportantAura(115782, AURA_TYPE_DEBUFF, 20, { 115782 }) -- Optical Blast
AddImportantAura(116709, AURA_TYPE_DEBUFF, 20, { 116709 }) -- Spear Hand Strike
AddImportantAura(102051, AURA_TYPE_DEBUFF, 20, { 102051 }) -- Frostjaw
AddImportantAura(137460, AURA_TYPE_DEBUFF, 20, { 137460 }) -- Silenced (Ring of Peace)

-- Disarms
AddImportantAura(676, AURA_TYPE_DEBUFF, 20, { 676 }) -- Disarm
AddImportantAura(51722, AURA_TYPE_DEBUFF, 20, { 51722 }) -- Dismantle
AddImportantAura(64058, AURA_TYPE_DEBUFF, 20, { 64058 }) -- Psychic Horror Disarm
AddImportantAura(91644, AURA_TYPE_DEBUFF, 20, { 91644 }) -- Snatch Disarm
AddImportantAura(64346, AURA_TYPE_DEBUFF, 20, { 64346 }) -- Fiery Payback
AddImportantAura(118093, AURA_TYPE_DEBUFF, 20, { 118093 }) -- Disarm (Void)

-- Buffs
AddImportantAura(44544, AURA_TYPE_BUFF, 35, { 44544 }) -- Fingers of Frost
AddImportantAura(69369, AURA_TYPE_BUFF, 35, { 69369 }) -- Predator's Swiftness
AddImportantAura(22812, AURA_TYPE_BUFF, 25, { 22812, 113075 }) -- Barkskin
AddImportantAura(33891, AURA_TYPE_BUFF, 25, { 33891 }) -- Incarnation: Tree of Life
AddImportantAura(3411, AURA_TYPE_BUFF, 25, { 3411, 34784, 147833 }) -- Intervene
AddImportantAura(55694, AURA_TYPE_BUFF, 25, { 55694 }) -- Enraged Regeneration
AddImportantAura(55233, AURA_TYPE_BUFF, 20, { 55233 }) -- Vampiric Blood
AddImportantAura(61336, AURA_TYPE_BUFF, 20, { 61336, 113306 }) -- Survival Instincts
AddImportantAura(70940, AURA_TYPE_BUFF, 20, { 70940 }) -- Divine Guardian
AddImportantAura(96263, AURA_TYPE_BUFF, 20, { 96263 }) -- Sacred Shield
AddImportantAura(86669, AURA_TYPE_BUFF, 20, { 86669, 86659, 86698 }) -- Guardian
AddImportantAura(89485, AURA_TYPE_BUFF, 20, { 89485 }, { duration = 0 }) -- Inner Focus
AddImportantAura(46946, AURA_TYPE_BUFF, 20, { 46946, 114029 }) -- Safeguard
AddImportantAura(1022, AURA_TYPE_BUFF, 20, { 1022 }) -- Hand of Protection
AddImportantAura(1044, AURA_TYPE_BUFF, 20, { 1044 }) -- Hand of Freedom
AddImportantAura(6940, AURA_TYPE_BUFF, 20, { 6940 }) -- Hand of Sacrifice
AddImportantAura(64205, AURA_TYPE_BUFF, 20, { 64205 }) -- Divine Sacrifice
AddImportantAura(54216, AURA_TYPE_BUFF, 20, { 54216, 53271, 62305 }) -- Master's Call
AddImportantAura(2825, AURA_TYPE_BUFF, 9, { 2825, 32182 }) -- Bloodlust
AddImportantAura(80353, AURA_TYPE_BUFF, 20, { 80353 }) -- Time Warp
AddImportantAura(33206, AURA_TYPE_BUFF, 20, { 33206 }) -- Pain Suppression
AddImportantAura(29166, AURA_TYPE_BUFF, 20, { 29166 }) -- Innervate
AddImportantAura(18708, AURA_TYPE_BUFF, 20, { 18708 }) -- Fel Domination
AddImportantAura(54428, AURA_TYPE_BUFF, 15, { 54428 }) -- Divine Plea
AddImportantAura(85696, AURA_TYPE_BUFF, 9, { 85696 }) -- Zealotry
AddImportantAura(31821, AURA_TYPE_BUFF, 21, { 31821 }) -- Aura Mastery
AddImportantAura(51713, AURA_TYPE_BUFF, 21, { 51713 }) -- Shadow Dance
AddImportantAura(12292, AURA_TYPE_BUFF, 15, { 12292 }) -- Bloodbath
AddImportantAura(23920, AURA_TYPE_BUFF, 40, { 23920, 114028, 113002 }) -- Spell Reflection
AddImportantAura(6346, AURA_TYPE_BUFF, 9, { 6346, 110717 }) -- Fear Ward
AddImportantAura(50334, AURA_TYPE_BUFF, 15, { 50334, 106951 }) -- Berserk
AddImportantAura(79206, AURA_TYPE_BUFF, 9, { 79206, 110806 }) -- Spiritwalker's Grace
AddImportantAura(12472, AURA_TYPE_BUFF, 9, { 12472, 131078 }) -- Icy Veins
AddImportantAura(3045, AURA_TYPE_BUFF, 9, { 3045 }) -- Rapid Fire
AddImportantAura(136, AURA_TYPE_BUFF, 20, { 136 }) -- Mend Pet
AddImportantAura(19574, AURA_TYPE_BUFF, 15, { 19574 }) -- Bestial Wrath
AddImportantAura(51755, AURA_TYPE_BUFF, 20, { 51755 }) -- Camouflage
AddImportantAura(66, AURA_TYPE_BUFF, 15, { 66, 110959, 110960 }) -- Invisibility
AddImportantAura(113862, AURA_TYPE_BUFF, 20, { 113862 }) -- Greater Invisibility -90%
AddImportantAura(12042, AURA_TYPE_BUFF, 15, { 12042 }) -- Arcane Power
AddImportantAura(12043, AURA_TYPE_BUFF, 15, { 12043 }) -- Presence of Mind
AddImportantAura(12051, AURA_TYPE_BUFF, 15, { 12051 }) -- Evocation
AddImportantAura(108839, AURA_TYPE_BUFF, 15, { 108839 }) -- Ice Floes
AddImportantAura(110909, AURA_TYPE_BUFF, 15, { 110909 }, { priority = true }) -- Alter Time
AddImportantAura(115610, AURA_TYPE_BUFF, 20, { 115610 }) -- Temporal Shield
AddImportantAura(11426, AURA_TYPE_BUFF, 20, { 11426 }) -- Ice Barrier
AddImportantAura(120954, AURA_TYPE_BUFF, 20, { 120954, 126456 }) -- Fortifying Brew
AddImportantAura(116849, AURA_TYPE_BUFF, 20, { 116849 }) -- Life Cocoon
AddImportantAura(122278, AURA_TYPE_BUFF, 20, { 122278 }) -- Dampen Harm
AddImportantAura(122470, AURA_TYPE_BUFF, 20, { 122470 }) -- Touch of Karma
AddImportantAura(122783, AURA_TYPE_BUFF, 20, { 122783 }) -- Diffuse Magic
AddImportantAura(115176, AURA_TYPE_BUFF, 20, { 115176, 131523 }) -- Zen Meditation
AddImportantAura(115295, AURA_TYPE_BUFF, 20, { 115295 }) -- Guard
AddImportantAura(115308, AURA_TYPE_BUFF, 20, { 115308 }) -- Elusive Brew
AddImportantAura(137562, AURA_TYPE_BUFF, 20, { 137562 }) -- Nimble Brew
AddImportantAura(140023, AURA_TYPE_BUFF, 20, { 140023 }) -- Ring of Peace
AddImportantAura(31884, AURA_TYPE_BUFF, 15, { 31884 }) -- Avenging Wrath
AddImportantAura(31842, AURA_TYPE_BUFF, 15, { 31842 }) -- Divine Favor
AddImportantAura(105809, AURA_TYPE_BUFF, 15, { 105809 }) -- Holy Avenger
AddImportantAura(586, AURA_TYPE_BUFF, 20, { 586 }) -- Fade
AddImportantAura(10060, AURA_TYPE_BUFF, 15, { 10060 }) -- Power Infusion
AddImportantAura(64843, AURA_TYPE_BUFF, 20, { 64843 }) -- Divine Hymn
AddImportantAura(64901, AURA_TYPE_BUFF, 20, { 64901, 64904 }) -- Hymn of Hope
AddImportantAura(81700, AURA_TYPE_BUFF, 20, { 81700 }) -- Archangel
AddImportantAura(96267, AURA_TYPE_BUFF, 20, { 96267 }) -- Inner Focus
AddImportantAura(1966, AURA_TYPE_BUFF, 20, { 1966 }) -- Feint
AddImportantAura(13750, AURA_TYPE_BUFF, 15, { 13750 }) -- Adrenaline Rush
AddImportantAura(51690, AURA_TYPE_BUFF, 15, { 51690 }) -- Killing Spree
AddImportantAura(57933, AURA_TYPE_BUFF, 15, { 57933 }) -- Tricks +15% dmg
AddImportantAura(74001, AURA_TYPE_BUFF, 20, { 74001 }) -- Combat Readiness
AddImportantAura(79140, AURA_TYPE_BUFF, 15, { 79140 }) -- Vendetta
AddImportantAura(121471, AURA_TYPE_BUFF, 15, { 121471 }) -- Shadow Blades
AddImportantAura(114018, AURA_TYPE_BUFF, 20, { 114018 }) -- Shroud of Concealment
AddImportantAura(30823, AURA_TYPE_BUFF, 20, { 30823 }) -- Shamanistic Rage
AddImportantAura(108281, AURA_TYPE_BUFF, 20, { 108281 }) -- Ancestral Guidance
AddImportantAura(16166, AURA_TYPE_BUFF, 15, { 16166 }) -- Elemental Mastery
AddImportantAura(120676, AURA_TYPE_BUFF, 15, { 120676 }) -- Stormlash Totem Effect
AddImportantAura(114050, AURA_TYPE_BUFF, 20, { 114050, 114052, 114051 }) -- Ascendance
AddImportantAura(20707, AURA_TYPE_BUFF, 20, { 20707 }) -- Soulstone
AddImportantAura(89751, AURA_TYPE_BUFF, 15, { 89751, 115831 }) -- Felstorm
AddImportantAura(110913, AURA_TYPE_BUFF, 20, { 110913 }) -- Dark Bargain
AddImportantAura(104773, AURA_TYPE_BUFF, 20, { 104773, 122291 }) -- Unending Resolve
AddImportantAura(113860, AURA_TYPE_BUFF, 20, { 113860 }) -- Dark Soul: Misery
AddImportantAura(113861, AURA_TYPE_BUFF, 20, { 113861 }) -- Dark Soul: Knowledge
AddImportantAura(113858, AURA_TYPE_BUFF, 20, { 113858 }) -- Dark Soul: Instability
AddImportantAura(108359, AURA_TYPE_BUFF, 20, { 108359 }) -- Dark Regeneration
AddImportantAura(108416, AURA_TYPE_BUFF, 20, { 108416 }) -- Sacrificial Pact
AddImportantAura(111397, AURA_TYPE_BUFF, 20, { 111397 }) -- Blood Horror
AddImportantAura(114206, AURA_TYPE_BUFF, 15, { 114206 }) -- Skull Banner
AddImportantAura(107574, AURA_TYPE_BUFF, 15, { 107574 }) -- Avatar
AddImportantAura(97462, AURA_TYPE_BUFF, 20, { 97462, 97463 }) -- Rallying Cry
AddImportantAura(114030, AURA_TYPE_BUFF, 20, { 114030 }) -- Vigilance
AddImportantAura(2457, AURA_TYPE_BUFF, 9, { 2457 }) -- Battle Stance
AddImportantAura(2458, AURA_TYPE_BUFF, 9, { 2458 }) -- Berserker Stance
AddImportantAura(71, AURA_TYPE_BUFF, 9, { 71 }) -- Defensive Stance
AddImportantAura(104270, AURA_TYPE_BUFF, 9, { 104270, 104235, 104269, 118358, 149024, 148996, 149000, 148997 }) -- Drink
AddImportantAura(49028, AURA_TYPE_BUFF, 15, { 49028, 81256 }) -- Dancing Rune Weapon
AddImportantAura(51271, AURA_TYPE_BUFF, 9, { 51271 }) -- Pillar of Frost
AddImportantAura(77606, AURA_TYPE_BUFF, 9, { 77606 }) -- Dark Simulacrum
AddImportantAura(49016, AURA_TYPE_BUFF, 15, { 49016 }) -- Unholy Frenzy
AddImportantAura(49222, AURA_TYPE_BUFF, 20, { 49222, 122285 }) -- Bone Shield
AddImportantAura(73975, AURA_TYPE_BUFF, 9, { 73975 }) -- Necrotic Wound
AddImportantAura(16689, AURA_TYPE_BUFF, 20, { 16689 }) -- Nature's Grasp
AddImportantAura(5217, AURA_TYPE_BUFF, 15, { 5217 }) -- Tiger's Fury
AddImportantAura(22842, AURA_TYPE_BUFF, 20, { 22842 }) -- Frenzied Regeneration
AddImportantAura(102342, AURA_TYPE_BUFF, 20, { 102342 }) -- Ironbark
AddImportantAura(102543, AURA_TYPE_BUFF, 15, { 102543 }) -- Incarnation: King of the Jungle
AddImportantAura(102558, AURA_TYPE_BUFF, 15, { 102558 }) -- Incarnation: Guardian of Ursoc
AddImportantAura(102560, AURA_TYPE_BUFF, 15, { 102560 }) -- Incarnation: Chosen of Elune
AddImportantAura(106922, AURA_TYPE_BUFF, 20, { 106922, 113072 }) -- Might of Ursoc
AddImportantAura(132402, AURA_TYPE_BUFF, 20, { 132402, 122286 }) -- Savage Defense
AddImportantAura(108291, AURA_TYPE_BUFF, 20, { 108291, 108292, 108293, 108294 }) -- Heart of the Wild
AddImportantAura(132158, AURA_TYPE_BUFF, 20, { 132158 }) -- Nature's Swiftness
AddImportantAura(131894, AURA_TYPE_DEBUFF, 15, { 131894 }) -- A Murder of Crows

-- Turtling Abilities
AddImportantAura(88611, AURA_TYPE_DEBUFF, 25, { 88611, 76577 }, { duration = 6 }) -- Smoke Bomb
AddImportantAura(45182, AURA_TYPE_BUFF, 25, { 45182 }) -- Cheating Death
AddImportantAura(2565, AURA_TYPE_BUFF, 25, { 2565 }) -- Shield Block
AddImportantAura(12976, AURA_TYPE_BUFF, 25, { 12976 }) -- Last Stand
AddImportantAura(47788, AURA_TYPE_BUFF, 25, { 47788 }) -- Guardian Spirit
AddImportantAura(31850, AURA_TYPE_BUFF, 25, { 31850 }) -- Ardent Defender
AddImportantAura(498, AURA_TYPE_BUFF, 25, { 498 }) -- Divine Protection
AddImportantAura(98008, AURA_TYPE_BUFF, 25, { 98008 }) -- Spirit Link Totem
AddImportantAura(53480, AURA_TYPE_BUFF, 25, { 53480 }) -- Roar of Sacrifice
AddImportantAura(81782, AURA_TYPE_BUFF, 20, { 81782, 62618 }) -- Power Word: Barrier
AddImportantAura(871, AURA_TYPE_BUFF, 25, { 871 }) -- Shield Wall
AddImportantAura(48707, AURA_TYPE_BUFF, 25, { 48707, 110570 }) -- Anti-Magic Shell
AddImportantAura(31224, AURA_TYPE_BUFF, 25, { 31224, 110788 }) -- Cloak of Shadows
AddImportantAura(19263, AURA_TYPE_BUFF, 25, { 19263, 148467, 110617 }) -- Deterrence
AddImportantAura(5277, AURA_TYPE_BUFF, 10, { 5277, 110791 }) -- Evasion
AddImportantAura(50461, AURA_TYPE_BUFF, 10, { 50461, 145629 }) -- Anti-Magic Zone
AddImportantAura(5384, AURA_TYPE_BUFF, 10, { 5384, 110597 }) -- Feign Death

-- Immunities
AddImportantAura(46924, AURA_TYPE_BUFF, 20, { 46924 }) -- Bladestorm
AddImportantAura(34471, AURA_TYPE_BUFF, 20, { 34471 }) -- The Beast Within
AddImportantAura(27827, AURA_TYPE_BUFF, 20, { 27827 }) -- Spirit of Redemption
AddImportantAura(47585, AURA_TYPE_BUFF, 20, { 47585, 110715 }) -- Dispersion
AddImportantAura(45438, AURA_TYPE_BUFF, 30, { 45438, 115760, 110696 }) -- Ice Block
AddImportantAura(41425, AURA_TYPE_DEBUFF, 8, { 41425 }) -- Hypothermia (Ice Block Immune)
AddImportantAura(642, AURA_TYPE_BUFF, 30, { 642, 110700 }) -- Divine Shield
AddImportantAura(18499, AURA_TYPE_BUFF, 30, { 18499 }) -- Berserker Rage
AddImportantAura(1719, AURA_TYPE_BUFF, 30, { 1719 }) -- Recklessness
AddImportantAura(48792, AURA_TYPE_BUFF, 15, { 48792, 110575 }) -- Icebound Fortitude
AddImportantAura(49039, AURA_TYPE_BUFF, 15, { 49039 }) -- Lichborne
AddImportantAura(115018, AURA_TYPE_BUFF, 15, { 115018 }) -- Desecrated Ground
AddImportantAura(8178, AURA_TYPE_BUFF, 15, { 8178 }) -- Grounding Totem Effect
AddImportantAura(114896, AURA_TYPE_BUFF, 15, { 114896 }) -- Windwalk Totem Effect
AddImportantAura(108271, AURA_TYPE_BUFF, 15, { 108271 }) -- Astral Shift
AddImportantAura(114239, AURA_TYPE_BUFF, 15, { 114239 }) -- Phantasm

AddImportantAura(34709, AURA_TYPE_DEBUFF, 9, { 34709 }, { duration = 15, magic = true }) -- Shadowsight Buff
AddImportantAura(8178, AURA_TYPE_BUFF, 15, { 8178 }, { duration = 0 }) -- Grounding Totem Effect


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

AddInterrupt(2139, 7, 15)   -- Counterspell (Mage)
AddInterrupt(1766, 5, 15)   -- Kick (Rogue)
AddInterrupt(6552, 4, 15)   -- Pummel (Warrior)
AddInterrupt(57994, 3, 15)  -- Wind Shear (Shaman)
AddInterrupt(19647, 6, 15)  -- Spell Lock (Warlock)
AddInterrupt(47528, 3, 15)  -- Mind Freeze (Death Knight)
AddInterrupt(96231, 4, 15)  -- Rebuke (Paladin)
AddInterrupt(91807, 2, 15)  -- Shambling Rush (DK pet)
AddInterrupt(80964, 4, 15)  -- Skull Bash (Bear)
AddInterrupt(80965, 4, 15)  -- Skull Bash (Cat)
AddInterrupt(31935, 3, 15)  -- Avenger's Shield (Paladin)
AddInterrupt(34490, 3, 15)  -- Silencing Shot (Hunter)
AddInterrupt(26090, 2, 15)  -- Pummel (Hunter Pet)
AddInterrupt(97547, 5, 15) -- Solar Beam (Druid)
AddInterrupt(93985, 4, 15)  -- Skull Bash
AddInterrupt(102060, 4, 15) -- Disrupting Shout
AddInterrupt(132409, 6, 15) -- Spell Lock
AddInterrupt(115782, 6, 15) -- Optical Blast
AddInterrupt(116705, 4, 15) -- Spear Hand Strike
AddInterrupt(137576, 4, 15)  -- Deadly Throw
AddInterrupt(24259, 6, 15)  -- Spell Lock
AddInterrupt(62347, 2, 15)  -- Nether Shock (pet)
AddInterrupt(50318, 4, 15)  -- Serenity Dust (pet)
AddInterrupt(147362, 3, 15) -- Counter Shot (Hunter)
AddInterrupt(113288, 4, 15) -- Solar Beam
AddInterrupt(32747, 3, 15) -- Interrupt Deadly Throw

function Gladdy:GetInterrupts()
    return interrupts
end

local cooldownList = {
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
    ["Goblin"] = {
    },
    ["Worgen"] = {
    },
    ["Pandaren"] = {
    },
}
local function AddCooldownEntry(class, spellId, cooldownInfo)
    if not cooldownList[class] then
        cooldownList[class] = {}
    end
    cooldownList[class][spellId] = cooldownInfo
end

AddCooldownEntry("DEATHKNIGHT", 50034, { cd = 180, spec = L["Blood"] }) -- Blood Rites
AddCooldownEntry("DEATHKNIGHT", 49222, { cd = 60, spec = L["Blood"] }) -- Bone Shield
AddCooldownEntry("DEATHKNIGHT", 49028, { cd = 90, spec = L["Blood"] }) -- Dancing Rune Weapon
AddCooldownEntry("DEATHKNIGHT", 56222, { cd = 8, spec = L["Blood"] }) -- Dark Command
AddCooldownEntry("DEATHKNIGHT", 48982, { cd = 30, spec = L["Blood"] }) -- Rune Tap
AddCooldownEntry("DEATHKNIGHT", 114866, { cd = 6, spec = L["Blood"] }) -- Soul Reaper
AddCooldownEntry("DEATHKNIGHT", 55233, { cd = 60, spec = L["Blood"] }) -- Vampiric Blood
AddCooldownEntry("DEATHKNIGHT", 51271, { cd = 60, spec = L["Frost"] }) -- Pillar of Frost
AddCooldownEntry("DEATHKNIGHT", 130735, { cd = 6, spec = L["Frost"] }) -- Soul Reaper
AddCooldownEntry("DEATHKNIGHT", 130736, { cd = 6, spec = L["Unholy"] }) -- Soul Reaper
AddCooldownEntry("DEATHKNIGHT", 49206, { cd = 180, spec = L["Unholy"] }) -- Summon Gargoyle
AddCooldownEntry("DEATHKNIGHT", 49016, { cd = 180, spec = L["Unholy"] }) -- Unholy Frenzy
AddCooldownEntry("DEATHKNIGHT", 123693, { cd = 25, talent = 0 }) -- Plague Leech
AddCooldownEntry("DEATHKNIGHT", 115989, { cd = 90, talent = 0 }) -- Unholy Blight
AddCooldownEntry("DEATHKNIGHT", 51052, { cd = 120, talent = 1 }) -- Anti-Magic Zone
AddCooldownEntry("DEATHKNIGHT", 49039, { cd = 120, talent = 1 }) -- Lichborne
AddCooldownEntry("DEATHKNIGHT", 108194, { cd = 30, talent = 2, replaces = 47476 }) -- Asphyxiate (replaces Strangulate)
AddCooldownEntry("DEATHKNIGHT", 96268, { cd = 30, talent = 2 }) -- Death's Advance
AddCooldownEntry("DEATHKNIGHT", 48743, { cd = 120, talent = 3 }) -- Death Pact
AddCooldownEntry("DEATHKNIGHT", 108201, { cd = 120, talent = 5 }) -- Desecrated Ground
AddCooldownEntry("DEATHKNIGHT", 108199, { cd = 60, talent = 5 }) -- Gorefiend's Grasp
AddCooldownEntry("DEATHKNIGHT", 108200, { cd = 60, talent = 5 }) -- Remorseless Winter
AddCooldownEntry("DEATHKNIGHT", 48707, { cd = 45 }) -- Anti-Magic Shell
AddCooldownEntry("DEATHKNIGHT", 77606, { cd = 60 }) -- Dark Simulacrum
AddCooldownEntry("DEATHKNIGHT", 50977, { cd = 60 }) -- Death Gate
AddCooldownEntry("DEATHKNIGHT", 49576, { cd = 25 }) -- Death Grip
AddCooldownEntry("DEATHKNIGHT", 43265, { cd = 30 }) -- Death and Decay
AddCooldownEntry("DEATHKNIGHT", 47568, { cd = 300 }) -- Empower Rune Weapon
AddCooldownEntry("DEATHKNIGHT", 57330, { cd = 20 }) -- Horn of Winter
AddCooldownEntry("DEATHKNIGHT", 48792, { cd = 180 }) -- Icebound Fortitude
AddCooldownEntry("DEATHKNIGHT", 47528, { cd = 15 }) -- Mind Freeze
AddCooldownEntry("DEATHKNIGHT", 77575, { cd = 60 }) -- Outbreak
AddCooldownEntry("DEATHKNIGHT", 46584, { cd = 120 }) -- Raise Dead
AddCooldownEntry("DEATHKNIGHT", 47476, { cd = 60 }) -- Strangulate

AddCooldownEntry("DRUID", 112071, { cd = 180, spec = L["Balance"] }) -- Celestial Alignment
AddCooldownEntry("DRUID", 132158, { cd = 60, spec = { L["Balance"], L["Restoration"] } }) -- Nature's Swiftness
AddCooldownEntry("DRUID", 78675, { cd = 60, spec = L["Balance"] }) -- Solar Beam
AddCooldownEntry("DRUID", 48505, { cd = 90, spec = L["Balance"], enabled = false }) -- Starfall
AddCooldownEntry("DRUID", 78674, { cd = 15, spec = L["Balance"], enabled = false }) -- Starsurge
AddCooldownEntry("DRUID", 106952, { cd = 180, spec = { L["Feral"], L["Guardian"] } }) -- Berserk
AddCooldownEntry("DRUID", 2782, { cd = 8, spec = { L["Feral"], L["Guardian"], L["Balance"] } }) -- Remove Corruption
AddCooldownEntry("DRUID", 106839, { cd = 15, spec = L["Feral"] }) -- Skull Bash
AddCooldownEntry("DRUID", 61336, { cd = 180, spec = { L["Feral"], L["Guardian"] } }) -- Survival Instincts
AddCooldownEntry("DRUID", 5217, { cd = 30, spec = L["Feral"], enabled = false }) -- Tiger's Fury
AddCooldownEntry("DRUID", 102795, { cd = 60, spec = L["Guardian"], enabled = false }) -- Bear Hug
AddCooldownEntry("DRUID", 5229, { cd = 60, spec = L["Guardian"], enabled = false }) -- Enrage
AddCooldownEntry("DRUID", 62606, { cd = 9, spec = L["Guardian"], charges = 3, enabled = false }) -- Savage Defense
AddCooldownEntry("DRUID", 102342, { cd = 60, spec = L["Restoration"] }) -- Ironbark
AddCooldownEntry("DRUID", 88423, { cd = 8, spec = L["Restoration"] }) -- Nature's Cure
AddCooldownEntry("DRUID", 18562, { cd = 15, spec = L["Restoration"], enabled = false }) -- Swiftmend
AddCooldownEntry("DRUID", 102560, { cd = 180, talent = 3, spec = L["Balance"], enabled = false }) -- Incarnation: Chosen of Elune (talent 106731)
AddCooldownEntry("DRUID", 102543, { cd = 180, talent = 3, spec = L["Feral"], enabled = false }) -- Incarnation: King of the Jungle (talent 106731)
AddCooldownEntry("DRUID", 102558, { cd = 180, talent = 3, spec = L["Guardian"], enabled = false }) -- Incarnation: Son of Ursoc (talent 106731)
AddCooldownEntry("DRUID", 33891, { cd = 180, talent = 3, spec = L["Restoration"], enabled = false }) -- Incarnation: Son of Ursoc (talent 106731)
AddCooldownEntry("DRUID", 102280, { cd = 30, talent = 0 }) -- Displacer Beast
AddCooldownEntry("DRUID", 102401, { cd = 15, talent = 0 }) -- Wild Charge
AddCooldownEntry("DRUID", 102351, { cd = 30, talent = 1, enabled = false }) -- Cenarion Ward
AddCooldownEntry("DRUID", 108238, { cd = 120, talent = 1, enabled = false }) -- Renewal
AddCooldownEntry("DRUID", 102359, { cd = 30, talent = 2 }) -- Mass Entanglement
AddCooldownEntry("DRUID", 132469, { cd = 30, talent = 2 }) -- Typhoon
AddCooldownEntry("DRUID", 99, { cd = 30, talent = 4 }) -- Disorienting Roar
AddCooldownEntry("DRUID", 5211, { cd = 50, talent = 4 }) -- Mighty Bash
AddCooldownEntry("DRUID", 102793, { cd = 60, talent = 4 }) -- Ursol's Vortex
AddCooldownEntry("DRUID", 108288, { cd = 360, talent = 5, enabled = false }) -- Heart of the Wild
AddCooldownEntry("DRUID", 124974, { cd = 90, talent = 5, enabled = false }) -- Nature's Vigil
AddCooldownEntry("DRUID", 22812, { cd = 60 }) -- Barkskin
AddCooldownEntry("DRUID", 1850, { cd = 180, enabled = false }) -- Dash
AddCooldownEntry("DRUID", 29166, { cd = 180 }) -- Innervate
AddCooldownEntry("DRUID", 22570, { cd = 10, enabled = false }) -- Maim
AddCooldownEntry("DRUID", 106922, { cd = 180, enabled = false }) -- Might of Ursoc
AddCooldownEntry("DRUID", 16689, { cd = 60, enabled = false }) -- Nature's Grasp
AddCooldownEntry("DRUID", 106898, { cd = 120, enabled = false }) -- Stampeding Roar
AddCooldownEntry("DRUID", 740, { cd = 480, enabled = false }) -- Tranquility

AddCooldownEntry("HUNTER", 19574, { cd = 60, spec = L["Beast Mastery"] }) -- Bestial Wrath
AddCooldownEntry("HUNTER", 34026, { cd = 6, spec = L["Beast Mastery"] }) -- Kill Command
AddCooldownEntry("HUNTER", 53209, { cd = 9, spec = L["Marksmanship"] }) -- Chimera Shot
AddCooldownEntry("HUNTER", 34490, { cd = 24, spec = L["Marksmanship"] }) -- Silencing Shot
AddCooldownEntry("HUNTER", 3674, { cd = 30, spec = L["Survival"] }) -- Black Arrow
AddCooldownEntry("HUNTER", 53301, { cd = 6, spec = L["Survival"] }) -- Explosive Shot
AddCooldownEntry("HUNTER", 109248, { cd = 45, talent = 1 }) -- Binding Shot
AddCooldownEntry("HUNTER", 19577, { cd = 60, talent = 1 }) -- Intimidation
AddCooldownEntry("HUNTER", 19386, { cd = 45, talent = 1 }) -- Wyvern Sting
AddCooldownEntry("HUNTER", 109304, { cd = 120, talent = 2 }) -- Exhilaration
AddCooldownEntry("HUNTER", 120679, { cd = 30, talent = 3 }) -- Dire Beast
AddCooldownEntry("HUNTER", 82726, { cd = 30, talent = 3 }) -- Fervor
AddCooldownEntry("HUNTER", 131894, { cd = 120, talent = 4 }) -- A Murder of Crows
AddCooldownEntry("HUNTER", 120697, { cd = 90, talent = 4 }) -- Lynx Rush
AddCooldownEntry("HUNTER", 120360, { cd = 30, talent = 5 }) -- Barrage
AddCooldownEntry("HUNTER", 117050, { cd = 15, talent = 5 }) -- Glaive Toss
AddCooldownEntry("HUNTER", 109259, { cd = 45, talent = 5 }) -- Powershot
AddCooldownEntry("HUNTER", 51753, { cd = 60 }) -- Camouflage
AddCooldownEntry("HUNTER", 5116, { cd = 5 }) -- Concussive Shot
AddCooldownEntry("HUNTER", 147362, { cd = 24 }) -- Counter Shot
AddCooldownEntry("HUNTER", 19263, { cd = 180, charges = 2 }) -- Deterrence
AddCooldownEntry("HUNTER", 781, { cd = 20 }) -- Disengage
AddCooldownEntry("HUNTER", 20736, { cd = 8 }) -- Distracting Shot
AddCooldownEntry("HUNTER", 13813, { cd = 30, [L["Survival"]] = 24 }) -- Explosive Trap
AddCooldownEntry("HUNTER", 6991, { cd = 10 }) -- Feed Pet
AddCooldownEntry("HUNTER", 5384, { cd = 30 }) -- Feign Death
AddCooldownEntry("HUNTER", 1543, { cd = 20 }) -- Flare
AddCooldownEntry("HUNTER", 1499, { cd = 30,  -- Freezing Trap
                                   [L["Survival"]] = 24,
                                   sharedCD = {
                                       [13809] = true, -- Ice Trap
                                       [60192] = true, -- Freezing Trap (Trap Launcher)
                                   },
})
AddCooldownEntry("HUNTER", 13809, { cd = 30,  -- Ice Trap
                                    [L["Survival"]] = 24,
                                    sharedCD = {
                                        [1499] = true, -- Freezing Trap
                                        [60192] = true, -- Freezing Trap (Trap Launcher)
                                    },
})
AddCooldownEntry("HUNTER", 53351, { cd = 10 }) -- Kill Shot
AddCooldownEntry("HUNTER", 53271, { cd = 45 }) -- Master's Call
AddCooldownEntry("HUNTER", 34477, { cd = 30 }) -- Misdirection
AddCooldownEntry("HUNTER", 3045, { cd = 180 }) -- Rapid Fire
AddCooldownEntry("HUNTER", 19503, { cd = 30 }) -- Scatter Shot
AddCooldownEntry("HUNTER", 34600, { cd = 30, [L["Survival"]] = 24 }) -- Snake Trap
AddCooldownEntry("HUNTER", 121818, { cd = 300 }) -- Stampede

AddCooldownEntry("MAGE", 44425, { cd = 3, spec = L["Arcane"], enabled = false }) -- Arcane Barrage
AddCooldownEntry("MAGE", 12042, { cd = 90, spec = L["Arcane"] }) -- Arcane Power
AddCooldownEntry("MAGE", 11129, { cd = 45, spec = L["Fire"], enabled = false }) -- Combustion
AddCooldownEntry("MAGE", 31661, { cd = 20, spec = L["Fire"] }) -- Dragon's Breath
AddCooldownEntry("MAGE", 108853, { cd = 8, spec = L["Fire"], enabled = false }) -- Inferno Blast
AddCooldownEntry("MAGE", 84714, { cd = 60, spec = L["Frost"], enabled = false }) -- Frozen Orb
AddCooldownEntry("MAGE", 12472, { cd = 180, spec = L["Frost"] }) -- Icy Veins
AddCooldownEntry("MAGE", 31687, { cd = 60, spec = L["Frost"], enabled = false }) -- Summon Water Elemental
AddCooldownEntry("MAGE", 108843, { cd = 25, talent = 0, enabled = false }) -- Blazing Speed
AddCooldownEntry("MAGE", 12043, { cd = 90, talent = 0 }) -- Presence of Mind
AddCooldownEntry("MAGE", 11426, { cd = 25, talent = 1, enabled = false }) -- Ice Barrier
AddCooldownEntry("MAGE", 115610, { cd = 25, talent = 1 }) -- Temporal Shield
AddCooldownEntry("MAGE", 102051, { cd = 20, talent = 2 }) -- Frostjaw
AddCooldownEntry("MAGE", 111264, { cd = 20, talent = 2, enabled = false }) -- Ice Ward
AddCooldownEntry("MAGE", 113724, { cd = 45, talent = 2 }) -- Ring of Frost
AddCooldownEntry("MAGE", 11958, { cd = 180, spec = nil, talent = 3, -- Cold Snap
                                  resetCD = {
                                      [45438] = true, -- Ice Block
                                      [120] = true, -- Cone of Cold
                                      [122] = true, -- Frost Nova
                                  },
})
AddCooldownEntry("MAGE", 110959, { cd = 90, talent = 3, replaces = 66, enabled = false }) -- Greater Invisibility (replaces Invisibility)
AddCooldownEntry("MAGE", 112948, { cd = 10, talent = 4, replaces = 125430, enabled = false }) -- Frost Bomb (replaces Mage Bomb)
AddCooldownEntry("MAGE", 1463, { cd = 25, talent = 5, enabled = false }) -- Incanter's Ward
AddCooldownEntry("MAGE", 108978, { cd = 180 }) -- Alter Time
AddCooldownEntry("MAGE", 1953, { cd = 15, chargeMod = 2, chargeModifiedBy = 146659 }) -- Blink (gains 2 charges from Glyph of Rapid Displacement 146659)
AddCooldownEntry("MAGE", 120, { cd = 10, enabled = false }) -- Cone of Cold
AddCooldownEntry("MAGE", 2139, { cd = 24 }) -- Counterspell
AddCooldownEntry("MAGE", 44572, { cd = 30 }) -- Deep Freeze
AddCooldownEntry("MAGE", 12051, { cd = 120 }) -- Evocation
AddCooldownEntry("MAGE", 116011, { cd = 0, spec = nil, talent = nil, replaces = 12051, enabled = false }) -- Rune of Power
AddCooldownEntry("MAGE", 2136, { cd = 8, enabled = false }) -- Fire Blast
AddCooldownEntry("MAGE", 2120, { cd = 12, enabled = false }) -- Flamestrike
AddCooldownEntry("MAGE", 122, { cd = 25, [L["Frost"]] = 20, enabled = false }) -- Frost Nova (modified by Glyph of Frost Nova 56376)
AddCooldownEntry("MAGE", 45438, { cd = 300 }) -- Ice Block
AddCooldownEntry("MAGE", 66, { cd = 300, enabled = false }) -- Invisibility
AddCooldownEntry("MAGE", 55342, { cd = 180, enabled = false }) -- Mirror Image
AddCooldownEntry("MAGE", 475, { cd = 8 }) -- Remove Curse

AddCooldownEntry("MONK", 115213, { cd = 180, spec = L["Brewmaster"] }) -- Avert Harm
AddCooldownEntry("MONK", 122057, { cd = 35, spec = L["Brewmaster"] }) -- Clash
AddCooldownEntry("MONK", 115308, { cd = 6, spec = L["Brewmaster"] }) -- Elusive Brew
AddCooldownEntry("MONK", 115295, { cd = 30, spec = L["Brewmaster"] }) -- Guard
AddCooldownEntry("MONK", 121253, { cd = 8, spec = L["Brewmaster"] }) -- Keg Smash
AddCooldownEntry("MONK", 115315, { cd = 30, spec = L["Brewmaster"] }) -- Summon Black Ox Statue
AddCooldownEntry("MONK", 116849, { cd = 120, spec = L["Mistweaver"] }) -- Life Cocoon
AddCooldownEntry("MONK", 115151, { cd = 8, spec = L["Mistweaver"] }) -- Renewing Mist
AddCooldownEntry("MONK", 115310, { cd = 180, spec = L["Mistweaver"] }) -- Revival
AddCooldownEntry("MONK", 115313, { cd = 30, spec = L["Mistweaver"] }) -- Summon Jade Serpent Statue
AddCooldownEntry("MONK", 116680, { cd = 45, spec = L["Mistweaver"] }) -- Thunder Focus Tea
AddCooldownEntry("MONK", 115288, { cd = 60, spec = L["Windwalker"] }) -- Energizing Brew
AddCooldownEntry("MONK", 113656, { cd = 25, spec = L["Windwalker"] }) -- Fists of Fury
AddCooldownEntry("MONK", 101545, { cd = 25, spec = L["Windwalker"] }) -- Flying Serpent Kick
AddCooldownEntry("MONK", 107428, { cd = 8, spec = L["Windwalker"] }) -- Rising Sun Kick
AddCooldownEntry("MONK", 116740, { cd = 5, spec = L["Windwalker"] }) -- Tigereye Brew
AddCooldownEntry("MONK", 122470, { cd = 90, spec = L["Windwalker"] }) -- Touch of Karma
AddCooldownEntry("MONK", 116841, { cd = 30, talent = 0 }) -- Tiger's Lust
AddCooldownEntry("MONK", 123986, { cd = 30, talent = 1 }) -- Chi Burst
AddCooldownEntry("MONK", 115098, { cd = 15, talent = 1 }) -- Chi Wave
AddCooldownEntry("MONK", 124081, { cd = 10, talent = 1 }) -- Zen Sphere
AddCooldownEntry("MONK", 119392, { cd = 30, talent = 3 }) -- Charging Ox Wave
AddCooldownEntry("MONK", 119381, { cd = 45, talent = 3 }) -- Leg Sweep
AddCooldownEntry("MONK", 116844, { cd = 45, talent = 3 }) -- Ring of Peace
AddCooldownEntry("MONK", 122278, { cd = 90, talent = 4 }) -- Dampen Harm
AddCooldownEntry("MONK", 122783, { cd = 90, talent = 4 }) -- Diffuse Magic
AddCooldownEntry("MONK", 123904, { cd = 180, talent = 5 }) -- Invoke Xuen, the White Tiger
AddCooldownEntry("MONK", 116847, { cd = 6, talent = 5, replaces = 101546 }) -- Rushing Jade Wind (replaces Spinning Crane Kick)
AddCooldownEntry("MONK", 115450, { cd = 8 }) -- Detox
AddCooldownEntry("MONK", 115072, { cd = 15 }) -- Expel Harm
AddCooldownEntry("MONK", 115203, { cd = 180 }) -- Fortifying Brew
AddCooldownEntry("MONK", 117368, { cd = 60 }) -- Grapple Weapon
AddCooldownEntry("MONK", 115543, { cd = 20 }) -- Leer of the Ox
AddCooldownEntry("MONK", 137562, { cd = 120 }) -- Nimble Brew
AddCooldownEntry("MONK", 115078, { cd = 15 }) -- Paralysis
AddCooldownEntry("MONK", 115546, { cd = 8 }) -- Provoke
AddCooldownEntry("MONK", 109132, { cd = 20, charges = 2 }) -- Roll
AddCooldownEntry("MONK", 116705, { cd = 15 }) -- Spear Hand Strike
AddCooldownEntry("MONK", 115080, { cd = 90 }) -- Touch of Death
AddCooldownEntry("MONK", 101643, { cd = 45 }) -- Transcendence
AddCooldownEntry("MONK", 119996, { cd = 25 }) -- Transcendence: Transfer
AddCooldownEntry("MONK", 115176, { cd = 180 }) -- Zen Meditation
AddCooldownEntry("MONK", 126892, { cd = 1800 }) -- Zen Pilgrimage

AddCooldownEntry("PALADIN", 53563, { cd = 3, spec = L["Holy"] }) -- Beacon of Light
AddCooldownEntry("PALADIN", 31842, { cd = 180, spec = L["Holy"] }) -- Divine Favor
AddCooldownEntry("PALADIN", 54428, { cd = 120, spec = L["Holy"] }) -- Divine Plea
AddCooldownEntry("PALADIN", 86669, { cd = 180, spec = L["Holy"] }) -- Guardian of Ancient Kings
AddCooldownEntry("PALADIN", 20473, { cd = 6, spec = L["Holy"] }) -- Holy Shock
AddCooldownEntry("PALADIN", 31850, { cd = 180, spec = L["Protection"] }) -- Ardent Defender
AddCooldownEntry("PALADIN", 31935, { cd = 15, spec = L["Protection"] }) -- Avenger's Shield
AddCooldownEntry("PALADIN", 26573, { cd = 9, spec = L["Protection"] }) -- Consecration
AddCooldownEntry("PALADIN", 86659, { cd = 180, spec = L["Protection"] }) -- Guardian of Ancient Kings
AddCooldownEntry("PALADIN", 53595, { cd = 4, spec = L["Protection"] }) -- Hammer of the Righteous
AddCooldownEntry("PALADIN", 119072, { cd = 9, spec = L["Protection"] }) -- Holy Wrath
AddCooldownEntry("PALADIN", 879, { cd = 15, spec = L["Retribution"] }) -- Exorcism
AddCooldownEntry("PALADIN", 86698, { cd = 180, spec = L["Retribution"] }) -- Guardian of Ancient Kings
AddCooldownEntry("PALADIN", 53595, { cd = 4, spec = L["Retribution"] }) -- Hammer of the Righteous
AddCooldownEntry("PALADIN", 85499, { cd = 45, talent = 0 }) -- Speed of Light
AddCooldownEntry("PALADIN", 105593, { cd = 30, talent = 1, replaces = 853 }) -- Fist of Justice (replaces Hammer of Justice)
AddCooldownEntry("PALADIN", 20066, { cd = 15, talent = 1 }) -- Repentance
AddCooldownEntry("PALADIN", 20925, { cd = 6, talent = 2 }) -- Sacred Shield
AddCooldownEntry("PALADIN", 20925, { cd = 6, talent = 2 }) -- Sacred Shield
AddCooldownEntry("PALADIN", 114039, { cd = 30, talent = 3 }) -- Hand of Purity
AddCooldownEntry("PALADIN", 105809, { cd = 120, talent = 4 }) -- Holy Avenger
AddCooldownEntry("PALADIN", 114157, { cd = 60, talent = 5 }) -- Execution Sentence
AddCooldownEntry("PALADIN", 114165, { cd = 20, talent = 5 }) -- Holy Prism
AddCooldownEntry("PALADIN", 114158, { cd = 60, talent = 5 }) -- Light's Hammer
AddCooldownEntry("PALADIN", 31884, { cd = 180 }) -- Avenging Wrath
AddCooldownEntry("PALADIN", 115750, { cd = 120 }) -- Blinding Light
AddCooldownEntry("PALADIN", 4987, { cd = 8 }) -- Cleanse
AddCooldownEntry("PALADIN", 35395, { cd = 4 }) -- Crusader Strike
AddCooldownEntry("PALADIN", 31821, { cd = 180 }) -- Devotion Aura
AddCooldownEntry("PALADIN", 498, { cd = 60, [L["Holy"]] = 30 }) -- Divine Protection (modified by Unbreakable Spirit 114154)
AddCooldownEntry("PALADIN", 642, { cd = 300, [L["Holy"]] = 150 }) -- Divine Shield
AddCooldownEntry("PALADIN", 853, { cd = 60 }) -- Hammer of Justice
AddCooldownEntry("PALADIN", 24275, { cd = 6 }) -- Hammer of Wrath
AddCooldownEntry("PALADIN", 1044, { cd = 25, chargeMod = 2, chargeModifiedBy = 105622 }) -- Hand of Freedom (gains 2 charges from Clemency 105622)
AddCooldownEntry("PALADIN", 1022, { cd = 300, chargeMod = 2, chargeModifiedBy = 105622 }) -- Hand of Protection (gains 2 charges from Clemency 105622)
AddCooldownEntry("PALADIN", 6940, { cd = 120, chargeMod = 2, chargeModifiedBy = 105622 }) -- Hand of Sacrifice (gains 2 charges from Clemency 105622)
AddCooldownEntry("PALADIN", 1038, { cd = 120, chargeMod = 2, chargeModifiedBy = 105622 }) -- Hand of Salvation (gains 2 charges from Clemency 105622)
AddCooldownEntry("PALADIN", 114852, { cd = 20 }) -- Holy Prism
AddCooldownEntry("PALADIN", 114871, { cd = 20 }) -- Holy Prism
AddCooldownEntry("PALADIN", 20271, { cd = 6 }) -- Judgment
AddCooldownEntry("PALADIN", 96231, { cd = 15 }) -- Rebuke
AddCooldownEntry("PALADIN", 62124, { cd = 8 }) -- Reckoning
AddCooldownEntry("PALADIN", 10326, { cd = 15 }) -- Turn Evil

AddCooldownEntry("PRIEST", 81700, { cd = 30, spec = L["Discipline"] }) -- Archangel
AddCooldownEntry("PRIEST", 14914, { cd = 10, spec = L["Discipline"] }) -- Holy Fire
AddCooldownEntry("PRIEST", 89485, { cd = 45, spec = L["Discipline"] }) -- Inner Focus
AddCooldownEntry("PRIEST", 33206, { cd = 180, spec = L["Discipline"] }) -- Pain Suppression
AddCooldownEntry("PRIEST", 47540, { cd = 9, spec = L["Discipline"] }) -- Penance
AddCooldownEntry("PRIEST", 62618, { cd = 180, spec = L["Discipline"] }) -- Power Word: Barrier
AddCooldownEntry("PRIEST", 527, { cd = 8, spec = L["Discipline"] }) -- Purify
AddCooldownEntry("PRIEST", 109964, { cd = 60, spec = L["Discipline"] }) -- Spirit Shell
AddCooldownEntry("PRIEST", 108968, { cd = 300, spec = L["Discipline"] }) -- Void Shift
AddCooldownEntry("PRIEST", 81209, { cd = 30, spec = L["Holy"] }) -- Chakra: Chastise
AddCooldownEntry("PRIEST", 81206, { cd = 30, spec = L["Holy"] }) -- Chakra: Sanctuary
AddCooldownEntry("PRIEST", 81208, { cd = 30, spec = L["Holy"] }) -- Chakra: Serenity
AddCooldownEntry("PRIEST", 34861, { cd = 10, spec = L["Holy"] }) -- Circle of Healing
AddCooldownEntry("PRIEST", 64843, { cd = 180, spec = L["Holy"] }) -- Divine Hymn
AddCooldownEntry("PRIEST", 47788, { cd = 180, spec = L["Holy"] }) -- Guardian Spirit
AddCooldownEntry("PRIEST", 14914, { cd = 10, spec = L["Holy"] }) -- Holy Fire
AddCooldownEntry("PRIEST", 88625, { cd = 30, spec = L["Holy"] }) -- Holy Word: Chastise
AddCooldownEntry("PRIEST", 126135, { cd = 180, spec = L["Holy"] }) -- Lightwell
AddCooldownEntry("PRIEST", 527, { cd = 8, spec = L["Holy"] }) -- Purify
AddCooldownEntry("PRIEST", 108968, { cd = 300, spec = L["Holy"] }) -- Void Shift
AddCooldownEntry("PRIEST", 47585, { cd = 120, spec = L["Shadow"] }) -- Dispersion
AddCooldownEntry("PRIEST", 8092, { cd = 8, spec = L["Shadow"] }) -- Mind Blast
AddCooldownEntry("PRIEST", 64044, { cd = 45, spec = L["Shadow"] }) -- Psychic Horror
AddCooldownEntry("PRIEST", 15487, { cd = 45, spec = L["Shadow"] }) -- Silence
AddCooldownEntry("PRIEST", 15286, { cd = 180, spec = L["Shadow"] }) -- Vampiric Embrace
AddCooldownEntry("PRIEST", 108921, { cd = 45, talent = 0 }) -- Psyfiend
AddCooldownEntry("PRIEST", 108920, { cd = 30, talent = 0 }) -- Void Tendrils
AddCooldownEntry("PRIEST", 121536, { cd = 10, talent = 1, charges = 3 }) -- Angelic Feather
AddCooldownEntry("PRIEST", 123040, { cd = 60, talent = 2, replaces = 34433 }) -- Mindbender (replaces Shadowfiend)
AddCooldownEntry("PRIEST", 19236, { cd = 120, talent = 3 }) -- Desperate Prayer
AddCooldownEntry("PRIEST", 112833, { cd = 30, talent = 3 }) -- Spectral Guise
AddCooldownEntry("PRIEST", 10060, { cd = 120, talent = 4 }) -- Power Infusion
AddCooldownEntry("PRIEST", 121135, { cd = 25, talent = 5 }) -- Cascade
AddCooldownEntry("PRIEST", 110744, { cd = 15, talent = 5 }) -- Divine Star
AddCooldownEntry("PRIEST", 120517, { cd = 40, talent = 5 }) -- Halo
AddCooldownEntry("PRIEST", 586, { cd = 30 }) -- Fade
AddCooldownEntry("PRIEST", 6346, { cd = 180 }) -- Fear Ward
AddCooldownEntry("PRIEST", 64901, { cd = 360 }) -- Hymn of Hope
AddCooldownEntry("PRIEST", 73325, { cd = 90 }) -- Leap of Faith
AddCooldownEntry("PRIEST", 32375, { cd = 15 }) -- Mass Dispel
AddCooldownEntry("PRIEST", 17, { cd = 6 }) -- Power Word: Shield
AddCooldownEntry("PRIEST", 33076, { cd = 10 }) -- Prayer of Mending
AddCooldownEntry("PRIEST", 8122, { cd = 30 }) -- Psychic Scream
AddCooldownEntry("PRIEST", 32379, { cd = 8 }) -- Shadow Word: Death
AddCooldownEntry("PRIEST", 34433, { cd = 180 }) -- Shadowfiend

AddCooldownEntry("ROGUE", 79140, { cd = 120, spec = L["Assassination"], enabled = false }) -- Vendetta
AddCooldownEntry("ROGUE", 13750, { cd = 180, spec = L["Combat"], enabled = false }) -- Adrenaline Rush
AddCooldownEntry("ROGUE", 13877, { cd = 10, spec = L["Combat"], enabled = false }) -- Blade Flurry
AddCooldownEntry("ROGUE", 51690, { cd = 120, spec = L["Combat"], enabled = false }) -- Killing Spree
AddCooldownEntry("ROGUE", 14183, { cd = 20, spec = L["Subtlety"], enabled = false }) -- Premeditation
AddCooldownEntry("ROGUE", 51713, { cd = 60, spec = L["Subtlety"] }) -- Shadow Dance
AddCooldownEntry("ROGUE", 74001, { cd = 120, talent = 1 }) -- Combat Readiness
AddCooldownEntry("ROGUE", 36554, { cd = 20, talent = 3, enabled = false }) -- Shadowstep
AddCooldownEntry("ROGUE", 137619, { cd = 60, talent = 5 }) -- Marked for Death
AddCooldownEntry("ROGUE", 2094, { cd = 120 }) -- Blind
AddCooldownEntry("ROGUE", 31224, { cd = 60 }) -- Cloak of Shadows
AddCooldownEntry("ROGUE", 51722, { cd = 60 }) -- Dismantle
AddCooldownEntry("ROGUE", 1725, { cd = 30, enabled = false }) -- Distract
AddCooldownEntry("ROGUE", 5277, { cd = 120 }) -- Evasion
AddCooldownEntry("ROGUE", 1776, { cd = 10, enabled = false }) -- Gouge
AddCooldownEntry("ROGUE", 1766, { cd = 15, successfulInterrupt = 9 }) -- Kick
AddCooldownEntry("ROGUE", 408, { cd = 20 }) -- Kidney Shot
AddCooldownEntry("ROGUE", 14185, { cd = 300,  -- Preparation
                                   resetCD = {
                                       [2983] = true, -- Sprint
                                       [1856] = true, -- Vanish
                                       [51722] = true, -- Dismantle
                                   },
})
AddCooldownEntry("ROGUE", 73981, { cd = 60, enabled = false }) -- Redirect
AddCooldownEntry("ROGUE", 121471, { cd = 180, enabled = false }) -- Shadow Blades
AddCooldownEntry("ROGUE", 114842, { cd = 60, enabled = false }) -- Shadow Walk
AddCooldownEntry("ROGUE", 5938, { cd = 10, enabled = false }) -- Shiv
AddCooldownEntry("ROGUE", 114018, { cd = 300, enabled = false }) -- Shroud of Concealment
AddCooldownEntry("ROGUE", 76577, { cd = 180 }) -- Smoke Bomb
AddCooldownEntry("ROGUE", 2983, { cd = 60, enabled = false }) -- Sprint
AddCooldownEntry("ROGUE", 1784, { cd = 6, enabled = false }) -- Stealth
AddCooldownEntry("ROGUE", 57934, { cd = 30, enabled = false }) -- Tricks of the Trade
AddCooldownEntry("ROGUE", 1856, { cd = 120 }) -- Vanish

AddCooldownEntry("SHAMAN", 61882, { cd = 10, spec = L["Elemental"] }) -- Earthquake
AddCooldownEntry("SHAMAN", 51505, { cd = 8, spec = L["Elemental"] }) -- Lava Burst
AddCooldownEntry("SHAMAN", 30823, { cd = 60, spec = L["Elemental"] }) -- Shamanistic Rage
AddCooldownEntry("SHAMAN", 51490, { cd = 45, spec = L["Elemental"] }) -- Thunderstorm
AddCooldownEntry("SHAMAN", 51533, { cd = 120, spec = L["Enhancement"] }) -- Feral Spirit
AddCooldownEntry("SHAMAN", 1535, { cd = 4, spec = L["Enhancement"] }) -- Fire Nova
AddCooldownEntry("SHAMAN", 60103, { cd = 10, spec = L["Enhancement"] }) -- Lava Lash
AddCooldownEntry("SHAMAN", 30823, { cd = 60, spec = L["Enhancement"] }) -- Shamanistic Rage
AddCooldownEntry("SHAMAN", 58875, { cd = 60, spec = L["Enhancement"] }) -- Spirit Walk
AddCooldownEntry("SHAMAN", 17364, { cd = 8, spec = L["Enhancement"] }) -- Stormstrike
AddCooldownEntry("SHAMAN", 51505, { cd = 8, spec = L["Restoration"] }) -- Lava Burst
AddCooldownEntry("SHAMAN", 16190, { cd = 180, spec = L["Restoration"] }) -- Mana Tide Totem
AddCooldownEntry("SHAMAN", 77130, { cd = 8, spec = L["Restoration"] }) -- Purify Spirit
AddCooldownEntry("SHAMAN", 61295, { cd = 6, spec = L["Restoration"] }) -- Riptide
AddCooldownEntry("SHAMAN", 98008, { cd = 180, spec = L["Restoration"] }) -- Spirit Link Totem
AddCooldownEntry("SHAMAN", 108271, { cd = 90, talent = 0 }) -- Astral Shift
AddCooldownEntry("SHAMAN", 108270, { cd = 60, talent = 0 }) -- Stone Bulwark Totem
AddCooldownEntry("SHAMAN", 51485, { cd = 30, talent = 1, replaces = 2484 }) -- Earthgrab Totem (replaces Earthbind Totem)
AddCooldownEntry("SHAMAN", 108273, { cd = 60, talent = 1 }) -- Windwalk Totem
AddCooldownEntry("SHAMAN", 108285, { cd = 180, talent = 2 }) -- Call of the Elements
AddCooldownEntry("SHAMAN", 108287, { cd = 10, talent = 2 }) -- Totemic Projection
AddCooldownEntry("SHAMAN", 16188, { cd = 90, talent = 3 }) -- Ancestral Swiftness
AddCooldownEntry("SHAMAN", 16166, { cd = 90, talent = 3 }) -- Elemental Mastery
AddCooldownEntry("SHAMAN", 108281, { cd = 120, talent = 4 }) -- Ancestral Guidance
AddCooldownEntry("SHAMAN", 117014, { cd = 12, talent = 5 }) -- Elemental Blast
AddCooldownEntry("SHAMAN", 114049, { cd = 180 }) -- Ascendance
AddCooldownEntry("SHAMAN", 108269, { cd = 45 }) -- Capacitor Totem
AddCooldownEntry("SHAMAN", 421, { cd = 3 }) -- Chain Lightning
AddCooldownEntry("SHAMAN", 51886, { cd = 8 }) -- Cleanse Spirit
AddCooldownEntry("SHAMAN", 2062, { cd = 300 }) -- Earth Elemental Totem
AddCooldownEntry("SHAMAN", 8042, { cd = 6 }) -- Earth Shock
AddCooldownEntry("SHAMAN", 2484, { cd = 30 }) -- Earthbind Totem
AddCooldownEntry("SHAMAN", 2894, { cd = 300 }) -- Fire Elemental Totem
AddCooldownEntry("SHAMAN", 8050, { cd = 6 }) -- Flame Shock
AddCooldownEntry("SHAMAN", 8056, { cd = 6 }) -- Frost Shock
AddCooldownEntry("SHAMAN", 8177, { cd = 25 }) -- Grounding Totem
AddCooldownEntry("SHAMAN", 73920, { cd = 10 }) -- Healing Rain
AddCooldownEntry("SHAMAN", 5394, { cd = 30 }) -- Healing Stream Totem
AddCooldownEntry("SHAMAN", 108280, { cd = 180 }) -- Healing Tide Totem
AddCooldownEntry("SHAMAN", 51514, { cd = 45 }) -- Hex
AddCooldownEntry("SHAMAN", 26364, { cd = 3 }) -- Lightning Shield
AddCooldownEntry("SHAMAN", 73899, { cd = 8 }) -- Primal Strike
AddCooldownEntry("SHAMAN", 79206, { cd = 120 }) -- Spiritwalker's Grace
AddCooldownEntry("SHAMAN", 115356, { cd = 8 }) -- Stormblast
AddCooldownEntry("SHAMAN", 120668, { cd = 300 }) -- Stormlash Totem
AddCooldownEntry("SHAMAN", 8143, { cd = 60 }) -- Tremor Totem
AddCooldownEntry("SHAMAN", 73680, { cd = 15 }) -- Unleash Elements
AddCooldownEntry("SHAMAN", 73685, { cd = 15 }) -- Unleash Life
AddCooldownEntry("SHAMAN", 57994, { cd = 12 }) -- Wind Shear
AddCooldownEntry("WARLOCK", 113860, { cd = 120, spec = L["Affliction"], chargeMod = 2, chargeModifiedBy = 108505 }) -- Dark Soul: Misery (gains 2 charges from Archimonde's Darkness 108505)
AddCooldownEntry("WARLOCK", 103967, { cd = 12, spec = L["Demonology"] }) -- Carrion Swarm
AddCooldownEntry("WARLOCK", 113861, { cd = 120, spec = L["Demonology"], chargeMod = 2, chargeModifiedBy = 108505 }) -- Dark Soul: Knowledge (gains 2 charges from Archimonde's Darkness 108505)
AddCooldownEntry("WARLOCK", 109151, { cd = 10, spec = L["Demonology"] }) -- Demonic Leap
AddCooldownEntry("WARLOCK", 105174, { cd = 15, spec = L["Demonology"], charges = 2, chargeMod = -1, chargeModifiedBy = 63310 }) -- Hand of Gul'dan (gains -1 charges from Glyph of Shadowflame 63310)
AddCooldownEntry("WARLOCK", 103958, { cd = 10, spec = L["Demonology"] }) -- Metamorphosis
AddCooldownEntry("WARLOCK", 17962, { cd = 12, spec = L["Destruction"], charges = 2 }) -- Conflagrate
AddCooldownEntry("WARLOCK", 113858, { cd = 120, spec = L["Destruction"], chargeMod = 2, chargeModifiedBy = 108505 }) -- Dark Soul: Instability (gains 2 charges from Archimonde's Darkness 108505)
AddCooldownEntry("WARLOCK", 120451, { cd = 60, spec = L["Destruction"] }) -- Flames of Xoroth
AddCooldownEntry("WARLOCK", 80240, { cd = 25, spec = L["Destruction"] }) -- Havoc
AddCooldownEntry("WARLOCK", 108359, { cd = 120, talent = 0 }) -- Dark Regeneration
AddCooldownEntry("WARLOCK", 47897, { cd = 20, talent = 1 }) -- Demonic Breath
AddCooldownEntry("WARLOCK", 6789, { cd = 45, talent = 1 }) -- Mortal Coil
AddCooldownEntry("WARLOCK", 30283, { cd = 30, talent = 1 }) -- Shadowfury
AddCooldownEntry("WARLOCK", 110913, { cd = 180, talent = 2 }) -- Dark Bargain
AddCooldownEntry("WARLOCK", 108416, { cd = 60, talent = 2 }) -- Sacrificial Pact
AddCooldownEntry("WARLOCK", 111397, { cd = 30, talent = 3 }) -- Blood Horror
AddCooldownEntry("WARLOCK", 108482, { cd = 60, talent = 3 }) -- Unbound Will
AddCooldownEntry("WARLOCK", 108503, { cd = 30, talent = 4 }) -- Grimoire of Sacrifice
AddCooldownEntry("WARLOCK", 108501, { cd = 120, talent = 4 }) -- Grimoire of Service
AddCooldownEntry("WARLOCK", 108508, { cd = 60, talent = 5 }) -- Mannoroth's Fury
AddCooldownEntry("WARLOCK", 29893, { cd = 120 }) -- Create Soulwell
AddCooldownEntry("WARLOCK", 77801, { cd = 120 }) -- Dark Soul
AddCooldownEntry("WARLOCK", 48020, { cd = 30 }) -- Demonic Circle: Teleport
AddCooldownEntry("WARLOCK", 111771, { cd = 10 }) -- Demonic Gateway
AddCooldownEntry("WARLOCK", 5484, { cd = 40 }) -- Howl of Terror
AddCooldownEntry("WARLOCK", 87385, { cd = 60 }) -- Seed of Corruption
AddCooldownEntry("WARLOCK", 6229, { cd = 30 }) -- Twilight Ward
AddCooldownEntry("WARLOCK", 104773, { cd = 180 }) -- Unending Resolve

AddCooldownEntry("WARRIOR", 86346, { cd = 20, spec = L["Arms"] }) -- Colossus Smash
AddCooldownEntry("WARRIOR", 118038, { cd = 120, spec = L["Arms"] }) -- Die by the Sword
AddCooldownEntry("WARRIOR", 12294, { cd = 6, spec = L["Arms"] }) -- Mortal Strike
AddCooldownEntry("WARRIOR", 12328, { cd = 10, spec = L["Arms"] }) -- Sweeping Strikes
AddCooldownEntry("WARRIOR", 23881, { cd = 4, spec = L["Fury"] }) -- Bloodthirst
AddCooldownEntry("WARRIOR", 86346, { cd = 20, spec = L["Fury"] }) -- Colossus Smash
AddCooldownEntry("WARRIOR", 118038, { cd = 120, spec = L["Fury"] }) -- Die by the Sword
AddCooldownEntry("WARRIOR", 1160, { cd = 60, spec = L["Protection"] }) -- Demoralizing Shout
AddCooldownEntry("WARRIOR", 12975, { cd = 180, spec = L["Protection"] }) -- Last Stand
AddCooldownEntry("WARRIOR", 6572, { cd = 9, spec = L["Protection"] }) -- Revenge
AddCooldownEntry("WARRIOR", 2565, { cd = 9, spec = L["Protection"], charges = 2 }) -- Shield Block
AddCooldownEntry("WARRIOR", 23922, { cd = 6, spec = L["Protection"] }) -- Shield Slam
AddCooldownEntry("WARRIOR", 55694, { cd = 60, talent = 1 }) -- Enraged Regeneration
AddCooldownEntry("WARRIOR", 103840, { cd = 30, talent = 1, replaces = 34428 }) -- Impending Victory (replaces Victory Rush)
AddCooldownEntry("WARRIOR", 102060, { cd = 40, talent = 2 }) -- Disrupting Shout
AddCooldownEntry("WARRIOR", 107566, { cd = 40, talent = 2 }) -- Staggering Shout
AddCooldownEntry("WARRIOR", 46924, { cd = 60, talent = 3 }) -- Bladestorm
AddCooldownEntry("WARRIOR", 118000, { cd = 60, talent = 3 }) -- Dragon Roar
AddCooldownEntry("WARRIOR", 46968, { cd = 40, talent = 3 }) -- Shockwave
AddCooldownEntry("WARRIOR", 114028, { cd = 60, talent = 4 }) -- Mass Spell Reflection
AddCooldownEntry("WARRIOR", 114029, { cd = 30, talent = 4, replaces = 3411 }) -- Safeguard (replaces Intervene)
AddCooldownEntry("WARRIOR", 114030, { cd = 120, talent = 4 }) -- Vigilance
AddCooldownEntry("WARRIOR", 107574, { cd = 180, talent = 5 }) -- Avatar
AddCooldownEntry("WARRIOR", 12292, { cd = 60, talent = 5 }) -- Bloodbath
AddCooldownEntry("WARRIOR", 107570, { cd = 30, talent = 5 }) -- Storm Bolt
AddCooldownEntry("WARRIOR", 6673, { cd = 60 }) -- Battle Shout
AddCooldownEntry("WARRIOR", 18499, { cd = 30 }) -- Berserker Rage
AddCooldownEntry("WARRIOR", 100, { cd = 20, chargeMod = 2, chargeModifiedBy = 103827 }) -- Charge (gains 2 charges from Double Time 103827)
AddCooldownEntry("WARRIOR", 469, { cd = 60 }) -- Commanding Shout
AddCooldownEntry("WARRIOR", 114203, { cd = 180 }) -- Demoralizing Banner
AddCooldownEntry("WARRIOR", 676, { cd = 60 }) -- Disarm
AddCooldownEntry("WARRIOR", 6544, { cd = 45, glyph = 30 }) -- Heroic Leap (modified by Glyph of Death From Above 63325)
AddCooldownEntry("WARRIOR", 57755, { cd = 30 }) -- Heroic Throw
AddCooldownEntry("WARRIOR", 118340, { cd = 30 }) -- Impending Victory
AddCooldownEntry("WARRIOR", 3411, { cd = 30 }) -- Intervene
AddCooldownEntry("WARRIOR", 5246, { cd = 90 }) -- Intimidating Shout
AddCooldownEntry("WARRIOR", 114192, { cd = 180 }) -- Mocking Banner
AddCooldownEntry("WARRIOR", 6552, { cd = 15 }) -- Pummel
AddCooldownEntry("WARRIOR", 97462, { cd = 180 }) -- Rallying Cry
AddCooldownEntry("WARRIOR", 1719, { cd = 180 }) -- Recklessness
AddCooldownEntry("WARRIOR", 64382, { cd = 300 }) -- Shattering Throw
AddCooldownEntry("WARRIOR", 871, { cd = 180 }) -- Shield Wall
AddCooldownEntry("WARRIOR", 114207, { cd = 180 }) -- Skull Banner
AddCooldownEntry("WARRIOR", 23920, { cd = 25 }) -- Spell Reflection
AddCooldownEntry("WARRIOR", 355, { cd = 8 }) -- Taunt
AddCooldownEntry("WARRIOR", 6343, { cd = 6 }) -- Thunder Clap
AddCooldownEntry("WARRIOR", 118779, { cd = 30 }) -- Victory Rush

function Gladdy:GetCooldownList()
    return cooldownList
end

for k,v in pairs(cooldownList) do
    for spellID in pairs(v) do
        if GetSpellInfo(spellID) == nil then
            --print("cooldown", spellID)
        end
    end
end

local racials = {
    ["Scourge"] = {
        [7744] = true, -- Will of the Forsaken
        duration = 120,
        spellName = GetSpellInfo(7744),
        texture = GetSpellTexture(7744)
    },
    ["BloodElf"] = {
        [28730] = true, -- Arcane Torrent
        [25046] = true,
        [50613] = true,
        [69179] = true,
        [80483] = true,
        duration = 120,
        spellName = GetSpellInfo(28730),
        texture = GetSpellTexture(28730)
    },
    ["Tauren"] = {
        [20549] = true, -- War Stomp
        duration = 120,
        spellName = GetSpellInfo(20549),
        texture = GetSpellTexture(20549)
    },
    ["Orc"] = {
        [20572] = true,
        [33697] = true,
        [33702] = true,
        duration = 120,
        spellName = GetSpellInfo(20572),
        texture = GetSpellTexture(20572)
    },
    ["Troll"] = {
        [26297] = true,
        duration = 180,
        spellName = GetSpellInfo(26297),
        texture = GetSpellTexture(26297)
    },
    ["NightElf"] = {
        [58984] = true,
        duration = 120,
        spellName = GetSpellInfo(58984),
        texture = GetSpellTexture(58984)
    },
    ["Draenei"] = {
        [28880] = true,
        [59542] = true,
        [59543] = true,
        [59544] = true,
        [59545] = true,
        [59547] = true,
        [59548] = true,
        duration = 180,
        spellName = GetSpellInfo(28880),
        texture = GetSpellTexture(28880)
    },
    ["Human"] = {
        [59752] = true, -- Will to Survive
        duration = 120,
        spellName = GetSpellInfo(59752),
        texture = GetSpellTexture(59752)
    },
    ["Gnome"] = {
        [20589] = true, -- Escape Artist
        duration = 90,
        spellName = GetSpellInfo(20589),
        texture = GetSpellTexture(20589)
    },
    ["Dwarf"] = {
        [65116] = true, -- Stoneform
        duration = 120,
        spellName = GetSpellInfo(65116),
        texture = GetSpellTexture(65116)
    },
    ["Goblin"] = {
        [69070] = true, -- Rocket Jump
        duration = 120,
        spellName = GetSpellInfo(69070),
        texture = GetSpellTexture(69070)
    },
    ["Worgen"] = {
        [68992] = true, -- Darkflight
        duration = 120,
        spellName = GetSpellInfo(68992),
        texture = GetSpellTexture(68992)
    },
    ["Pandaren"] = {
        [107079] = true, -- Darkflight
        duration = 120,
        spellName = GetSpellInfo(107079),
        texture = GetSpellTexture(107079)
    },
}
function Gladdy:Racials()
    return racials
end

for k,v in pairs(racials) do
    for spellID in pairs(v) do
        if GetSpellInfo(spellID) == nil then
            --print("racials", spellID)
        end
    end
end

---------------------
-- DISPEL ICONS
---------------------

--[[
Holy Pala
Cleanse
ID: 4987
Icon ID: 135949

Shadow Priest:
Mass Dispel
ID: 32375
Icon ID: 135739

Holy / Disc Priest:
Purify
ID: 527
Icon ID: 135894

Elem/Enchance Shaman
Cleanse Spirit
ID: 51886
Icon ID:236288

Resto Shaman
Purify Spirit
ID: 77130
Icon ID:236288

Mage
Remove Curse
ID: 475
Icon ID: 136082

Lock
Devour Magic
ID: 19505
Icon ID: 136075

Monk
Detox
ID: 115450
Icon ID: 135894

Druid
Nature's Cure (Resto druid)
ID 88423
Icon ID: 236288

Druid:
Remove Corruption (non resto, I think)
ID: 2782
Icon ID: 135952

Druid:
Symbiosis from priest: Mass Dispel
ID:110707
Icon ID: 135739

Druid:
Symbiosis from pala: Cleanse
ID:122288

]]


local dispelIcons = {
["DRUID"] = { [L["Restoration"]] = 88423 }, -- Nature's Cure
["DEATHKNIGHT"] = { },
["HUNTER"] = { },
["MAGE"] = { },--[L["Frost"]] = 475, [L["Fire"]] = 475, [L["Arcane"]] = 475 },
["PALADIN"] = { [L["Holy"]] = 4987 }, -- 4987 Cleanse
["PRIEST"] = { [L["Holy"]] = 527, [L["Discipline"]] = 527 }, -- 527 Purify
["ROGUE"] = { },
["SHAMAN"] = { [L["Restoration"]] = 77130 }, -- Purify Spirit
["WARLOCK"] = { },
["WARRIOR"] = { },
["MONK"] = { [L["Mistweaver"]] = 115450 }, -- Detox
    [88423] = 8,
    [4987] = 8,
    [527] = 8,
    [77130] = 8,
    [115450] = 8,
}
Gladdy.dispelIcons = dispelIcons


---------------------
-- TOTEM STUFF
---------------------

local totemData = {
    -- Fire
    --[string_lower("Fire Elemental Totem")] = {id = 32982,texture = select(3, GetSpellInfo(32982)), color = {r = 0, g = 0, b = 0, a = 1}},
    -- Water
    [string_lower("Mana Tide Totem")] = {id = 16190,texture = GetSpellTexture(16190), color = {r = 0.078, g = 0.9, b = 0.16, a = 1}, pulse = { cd = 16, once = true} },
    [string_lower("Healing Tide Totem")] = {id = 108280,texture = GetSpellTexture(108280), color = {r = 0.078, g = 0.9, b = 0.16, a = 1}, pulse = 2 },
    --[string_lower("Mana Spring Totem")] = { id = 5675, texture = select(3, GetSpellInfo(5675)), color = { r = 0, g = 0, b = 0, a = 1 } },
    --[string_lower("Elemental Resistance Totem")] = { id = 8184, texture = select(3, GetSpellInfo(8184)), color = { r = 0, g = 0, b = 0, a = 1 } },
    --[string_lower("Totem of Tranquil Mind")] = { id = 87718, texture = select(3, GetSpellInfo(87718)), color = { r = 0, g = 0, b = 0, a = 1 } },
    -- Earth
    [string_lower("Tremor Totem")] = {id = 8143,texture = GetSpellTexture(8143), color = {r = 1, g = 0.9, b = 0.1, a = 1}, pulse = { cd = 6, once = true }},
    [string_lower("Earth Elemental Totem")] = {id = 33663,texture = GetSpellTexture(33663), color = {r = 0, g = 0, b = 0, a = 1}},
    [string_lower("Stone Bulwark Totem")] = {id = 108270,texture = GetSpellTexture(108270), color = {r = 0, g = 0, b = 0, a = 1}, pulse = 5},
    [string_lower("Earthgrab Totem")] = {id = 2484, texture = GetSpellTexture(2484), color = {r = 0, g = 0, b = 0, a = 1}},
    -- Air
    [string_lower("Spirit Link Totem")] = { id = 98008, texture = GetSpellTexture(98008), color = { r = 0, g = 0, b = 0, a = 1 }, pulse = 1 },
    --[string_lower("Wrath of Air Totem")] = {id = 3738,texture = select(3, GetSpellInfo(3738)), color = {r = 0, g = 0, b = 0, a = 1}},
    [string_lower("Capacitor Totem")] = {id = 108269, texture = GetSpellTexture(108269), color = {r = 0, g = 0, b = 0, a = 1}, pulse = { cd = 5, once = true }},
    [string_lower("Stormlash Totem")] = {id = 120668, texture = GetSpellTexture(120668), color = {r = 0, g = 0, b = 0, a = 1}, pulse = { cd = 10, once = true }},
    [string_lower("Windwalk Totem")] = {id = 108273, texture = GetSpellTexture(108273), color = {r = 0, g = 0, b = 0, a = 1}, pulse = { cd = 6, once = true }},
}

local totemSpellIdToPulse = {
    [8143] = totemData[string_lower("Tremor Totem")].pulse,
    [98008] = totemData[string_lower("Spirit Link Totem")].pulse,
    [GetSpellInfo(totemData[string_lower("Mana Tide Totem")].id)] = totemData[string_lower("Mana Tide Totem")].pulse,
    [16190] = totemData[string_lower("Mana Tide Totem")].pulse, -- Rank 1
    [108280] = totemData[string_lower("Healing Tide Totem")].pulse,
    [120668] = totemData[string_lower("Stormlash Totem")].pulse,
    [108273] = totemData[string_lower("Windwalk Totem")].pulse,
    [108270] = totemData[string_lower("Stone Bulwark Totem")].pulse,
    [108269] = totemData[string_lower("Capacitor Totem")].pulse,
}

local totemNpcIdsToTotemData = {
    [3573] = totemData[string_lower("Mana Spring Totem")],
    [7414] = totemData[string_lower("Mana Spring Totem")],
    [7415] = totemData[string_lower("Mana Spring Totem")],
    [7416] = totemData[string_lower("Mana Spring Totem")],
    [15304] = totemData[string_lower("Mana Spring Totem")],
    [15489] = totemData[string_lower("Mana Spring Totem")],
    [31186] = totemData[string_lower("Mana Spring Totem")],
    [31189] = totemData[string_lower("Mana Spring Totem")],
    [31190] = totemData[string_lower("Mana Spring Totem")],
    [59764] = totemData[string_lower("Healing Tide Totem")],

    [5927] = totemData[string_lower("Elemental Resistance Totem")],
    [47069] = totemData[string_lower("Totem of Tranquil Mind")],
    [53006] = totemData[string_lower("Spirit Link Totem")],

    [15439] = totemData[string_lower("Fire Elemental Totem")],
    [40830] = totemData[string_lower("Fire Elemental Totem")],
    [41337] = totemData[string_lower("Fire Elemental Totem")],
    [41346] = totemData[string_lower("Fire Elemental Totem")],
    [72301] = totemData[string_lower("Fire Elemental Totem")],

    [15430] = totemData[string_lower("Earth Elemental Totem")],
    [24649] = totemData[string_lower("Earth Elemental Totem")],
    [39387] = totemData[string_lower("Earth Elemental Totem")],
    [40247] = totemData[string_lower("Earth Elemental Totem")],
    [72307] = totemData[string_lower("Earth Elemental Totem")],
    [59712] = totemData[string_lower("Stone Bulwark Totem")],
    [60561] = totemData[string_lower("Earthgrab Totem")],

    [15447] = totemData[string_lower("Wrath of Air Totem")],
    [36556] = totemData[string_lower("Wrath of Air Totem")],
    [61245] = totemData[string_lower("Capacitor Totem")],
    [62002] = totemData[string_lower("Stormlash Totem")],
    [59717] = totemData[string_lower("Windwalk Totem")],
}

local totemDataShared, totemNpcIdsToTotemDataShared, totemSpellIdToPulseShared = Gladdy:GetSharedTotemData()
Gladdy:AddEntriesToTable(totemData, totemDataShared)
Gladdy:AddEntriesToTable(totemNpcIdsToTotemData, totemNpcIdsToTotemDataShared)
Gladdy:AddEntriesToTable(totemSpellIdToPulse, totemSpellIdToPulseShared)

function Gladdy:GetTotemData()
    return totemData, totemNpcIdsToTotemData, totemSpellIdToPulse
end
