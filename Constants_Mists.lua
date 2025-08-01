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
AddImportantAura(22812, AURA_TYPE_BUFF, 25, { 22812 }) -- Barkskin
AddImportantAura(33891, AURA_TYPE_BUFF, 25, { 33891 }) -- Incarnation: Tree of Life
AddImportantAura(3411, AURA_TYPE_BUFF, 25, { 3411, 34784, 147833 }) -- Intervene
AddImportantAura(55694, AURA_TYPE_BUFF, 25, { 55694 }) -- Enraged Regeneration
AddImportantAura(55233, AURA_TYPE_BUFF, 20, { 55233 }) -- Vampiric Blood
AddImportantAura(61336, AURA_TYPE_BUFF, 20, { 61336 }) -- Survival Instincts
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
AddImportantAura(23920, AURA_TYPE_BUFF, 40, { 23920, 114028 }) -- Spell Reflection
AddImportantAura(6346, AURA_TYPE_BUFF, 9, { 6346 }) -- Fear Ward
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
AddImportantAura(120954, AURA_TYPE_BUFF, 20, { 120954 }) -- Fortifying Brew
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
AddImportantAura(81782, AURA_TYPE_BUFF, 20, { 81782 }) -- Power Word: Barrier
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
AddImportantAura(114050, AURA_TYPE_BUFF, 20, { 114050, 114052 }) -- Ascendance
AddImportantAura(114051, AURA_TYPE_BUFF, 15, { 114051 }) -- Ascendance (Enhancement)
AddImportantAura(20707, AURA_TYPE_BUFF, 20, { 20707 }) -- Soulstone
AddImportantAura(89751, AURA_TYPE_BUFF, 15, { 89751, 115831 }) -- Felstorm
AddImportantAura(110913, AURA_TYPE_BUFF, 20, { 110913 }) -- Dark Bargain
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
AddImportantAura(49222, AURA_TYPE_BUFF, 20, { 49222 }) -- Bone Shield
AddImportantAura(73975, AURA_TYPE_BUFF, 9, { 73975 }) -- Necrotic Wound
AddImportantAura(16689, AURA_TYPE_BUFF, 20, { 16689 }) -- Nature's Grasp
AddImportantAura(5217, AURA_TYPE_BUFF, 15, { 5217 }) -- Tiger's Fury
AddImportantAura(22842, AURA_TYPE_BUFF, 20, { 22842 }) -- Frenzied Regeneration
AddImportantAura(102342, AURA_TYPE_BUFF, 20, { 102342 }) -- Ironbark
AddImportantAura(102543, AURA_TYPE_BUFF, 15, { 102543 }) -- Incarnation: King of the Jungle
AddImportantAura(102558, AURA_TYPE_BUFF, 15, { 102558 }) -- Incarnation: Guardian of Ursoc
AddImportantAura(102560, AURA_TYPE_BUFF, 15, { 102560 }) -- Incarnation: Chosen of Elune
AddImportantAura(106922, AURA_TYPE_BUFF, 20, { 106922 }) -- Might of Ursoc
AddImportantAura(132402, AURA_TYPE_BUFF, 20, { 132402 }) -- Savage Defense
AddImportantAura(108291, AURA_TYPE_BUFF, 20, { 108291, 108292, 108293, 108294 }) -- Heart of the Wild
AddImportantAura(132158, AURA_TYPE_BUFF, 20, { 132158 }) -- Nature's Swiftness
AddImportantAura(113072, AURA_TYPE_BUFF, 20, { 113072 }) -- Symbiosis: Might of Ursoc
AddImportantAura(113306, AURA_TYPE_BUFF, 20, { 113306 }) -- Symbiosis: Survival Instincts
AddImportantAura(113075, AURA_TYPE_BUFF, 20, { 113075 }) -- Symbiosis: Barkskin
AddImportantAura(113278, AURA_TYPE_BUFF, 20, { 113278 }) -- Symbiosis: Tranquillity
AddImportantAura(113613, AURA_TYPE_BUFF, 20, { 113613 }) -- Symbiosis: Growl
AddImportantAura(122286, AURA_TYPE_BUFF, 20, { 122286 }) -- Symbiosis: Savage Defense
AddImportantAura(122285, AURA_TYPE_BUFF, 20, { 122285 }) -- Symbiosis: Bone Shield
AddImportantAura(110575, AURA_TYPE_BUFF, 20, { 110575 }) -- Symbiosis: Icebound Fortitude
AddImportantAura(110597, AURA_TYPE_BUFF, 20, { 110597 }) -- Symbiosis: Feign Death
AddImportantAura(126456, AURA_TYPE_BUFF, 20, { 126456 }) -- Symbiosis: Fortifying Brew
AddImportantAura(110717, AURA_TYPE_BUFF, 20, { 110717 }) -- Symbiosis: Fear Ward
AddImportantAura(110791, AURA_TYPE_BUFF, 20, { 110791 }) -- Symbiosis: Evasion
AddImportantAura(122291, AURA_TYPE_BUFF, 20, { 122291 }) -- Symbiosis: Unending Resolve
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
AddImportantAura(62618, AURA_TYPE_BUFF, 25, { 62618 }) -- Power Word: Barrier
AddImportantAura(871, AURA_TYPE_BUFF, 25, { 871 }) -- Shield Wall
AddImportantAura(48707, AURA_TYPE_BUFF, 25, { 48707 }) -- Anti-Magic Shell
AddImportantAura(31224, AURA_TYPE_BUFF, 25, { 31224 }) -- Cloak of Shadows
AddImportantAura(19263, AURA_TYPE_BUFF, 25, { 19263, 148467 }) -- Deterrence
AddImportantAura(5277, AURA_TYPE_BUFF, 10, { 5277 }) -- Evasion
AddImportantAura(50461, AURA_TYPE_BUFF, 10, { 50461, 145629 }) -- Anti-Magic Zone
AddImportantAura(5384, AURA_TYPE_BUFF, 10, { 5384 }) -- Feign Death

-- Immunities
AddImportantAura(46924, AURA_TYPE_BUFF, 20, { 46924 }) -- Bladestorm
AddImportantAura(34471, AURA_TYPE_BUFF, 20, { 34471 }) -- The Beast Within
AddImportantAura(27827, AURA_TYPE_BUFF, 20, { 27827 }) -- Spirit of Redemption
AddImportantAura(47585, AURA_TYPE_BUFF, 20, { 47585 }) -- Dispersion
AddImportantAura(45438, AURA_TYPE_BUFF, 30, { 45438, 115760 }) -- Ice Block
AddImportantAura(41425, AURA_TYPE_DEBUFF, 8, { 41425 }) -- Hypothermia (Ice Block Immune)
AddImportantAura(642, AURA_TYPE_BUFF, 30, { 642 }) -- Divine Shield
AddImportantAura(18499, AURA_TYPE_BUFF, 30, { 18499 }) -- Berserker Rage
AddImportantAura(1719, AURA_TYPE_BUFF, 30, { 1719 }) -- Recklessness
AddImportantAura(48792, AURA_TYPE_BUFF, 15, { 48792 }) -- Icebound Fortitude
AddImportantAura(49039, AURA_TYPE_BUFF, 15, { 49039 }) -- Lichborne
AddImportantAura(115018, AURA_TYPE_BUFF, 15, { 115018 }) -- Desecrated Ground
AddImportantAura(8178, AURA_TYPE_BUFF, 15, { 8178 }) -- Grounding Totem Effect
AddImportantAura(114896, AURA_TYPE_BUFF, 15, { 114896 }) -- Windwalk Totem Effect
AddImportantAura(110570, AURA_TYPE_BUFF, 15, { 110570 }) -- Symbiosis: Anti-Magic Shell
AddImportantAura(110617, AURA_TYPE_BUFF, 15, { 110617 }) -- Symbiosis: Deterrence
AddImportantAura(110696, AURA_TYPE_BUFF, 15, { 110696 }) -- Symbiosis: Ice Block
AddImportantAura(110715, AURA_TYPE_BUFF, 15, { 110715 }) -- Symbiosis: Dispersion
AddImportantAura(110788, AURA_TYPE_BUFF, 15, { 110788 }) -- Symbiosis: Cloak of Shadows
AddImportantAura(110700, AURA_TYPE_BUFF, 15, { 110700 }) -- Symbiosis: Divine Shield
AddImportantAura(113002, AURA_TYPE_BUFF, 15, { 113002 }) -- Symbiosis: Spell Reflection
AddImportantAura(108271, AURA_TYPE_BUFF, 15, { 108271 }) -- Astral Shift
AddImportantAura(114239, AURA_TYPE_BUFF, 15, { 114239 }) -- Phantasm

AddImportantAura(34709, AURA_TYPE_DEBUFF, 9, { 34709 }, { duration = 15, magic = true }) -- Shadowsight Buff
AddImportantAura(8178, AURA_TYPE_BUFF, 15, { 8178 }, { duration = 0 }) -- Grounding Totem Effect


function Gladdy:GetImportantAuras()
    return importantAuras
end

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

-- Death Knight
AddCooldownEntry("DEATHKNIGHT", 46584, 120) -- Raise Dead
AddCooldownEntry("DEATHKNIGHT", 47528, 15) -- Mind Freeze
AddCooldownEntry("DEATHKNIGHT", 47476, 60) -- Strangulate
AddCooldownEntry("DEATHKNIGHT", 48792, 180) -- Icebound Fortitude
AddCooldownEntry("DEATHKNIGHT", 48707, 45) -- Anti-Magic Shell
AddCooldownEntry("DEATHKNIGHT", 61999, 600) -- Raise Ally
AddCooldownEntry("DEATHKNIGHT", 47568, 300) -- Empower Rune Weapon
AddCooldownEntry("DEATHKNIGHT", 42650, 600) -- Army of the Dead
AddCooldownEntry("DEATHKNIGHT", 77575, 60) -- Outbreak
AddCooldownEntry("DEATHKNIGHT", 77606, 60) -- Dark Simulacrum
AddCooldownEntry("DEATHKNIGHT", 123693, 25) -- Plague Leech
AddCooldownEntry("DEATHKNIGHT", 115989, 90) -- Unholy Blight
AddCooldownEntry("DEATHKNIGHT", 51052, 120) -- Anti-Magic Zone
AddCooldownEntry("DEATHKNIGHT", 49039, 120) -- Lichborne
AddCooldownEntry("DEATHKNIGHT", 108194, 30) -- Asphyxiate
AddCooldownEntry("DEATHKNIGHT", 96268, 30) -- Death's Advance
AddCooldownEntry("DEATHKNIGHT", 48743, 120) -- Death Pact
AddCooldownEntry("DEATHKNIGHT", 108201, 120) -- Desecrated Ground
AddCooldownEntry("DEATHKNIGHT", 108199, 60) -- Gorefiend's Grasp
AddCooldownEntry("DEATHKNIGHT", 108200, 60) -- Remorseless Winter
AddCooldownEntry("DEATHKNIGHT", 49576, 25) -- Death Grip
AddCooldownEntry("DEATHKNIGHT", 55233, { cd = 60, spec = L["Blood"] }) -- Vampiric Blood
AddCooldownEntry("DEATHKNIGHT", 49222, { cd = 60, spec = L["Blood"] }) -- Bone Shield
AddCooldownEntry("DEATHKNIGHT", 49028, { cd = 90, spec = L["Blood"] }) -- Dancing Rune Weapon
AddCooldownEntry("DEATHKNIGHT", 48982, { cd = 30, spec = L["Blood"] }) -- Rune Tap
AddCooldownEntry("DEATHKNIGHT", 114866, { cd = 6, spec = L["Blood"] }) -- Soul Reaper
AddCooldownEntry("DEATHKNIGHT", 51271, { cd = 60, spec = L["Frost"] }) -- Pillar of Frost
AddCooldownEntry("DEATHKNIGHT", 49016, { cd = 180, spec = L["Unholy"] }) -- Unholy Frenzy
AddCooldownEntry("DEATHKNIGHT", 49206, { cd = 180, spec = L["Unholy"] }) -- Summon Gargoyle
AddCooldownEntry("DEATHKNIGHT", 47481, { cd = 60, spec = L["Unholy"] }) -- Gnaw
AddCooldownEntry("DEATHKNIGHT", 47484, { cd = 45, spec = L["Unholy"] }) -- Huddle
AddCooldownEntry("DEATHKNIGHT", 47482, { cd = 30, spec = L["Unholy"] }) -- Leap
AddCooldownEntry("DEATHKNIGHT", 91797, { cd = 60, spec = L["Unholy"] }) -- Monstrous Blow

-- Druid
AddCooldownEntry("DRUID", 22812, 60) -- Barkskin
AddCooldownEntry("DRUID", 1850, 180) -- Dash
AddCooldownEntry("DRUID", 29166, 180) -- Innervate
AddCooldownEntry("DRUID", 106922, 180) -- Might of Ursoc
AddCooldownEntry("DRUID", 16689, 60) -- Nature's Grasp
AddCooldownEntry("DRUID", 77761, 120) -- Stampeding Roar
AddCooldownEntry("DRUID", 740, 480) -- Tranquility
AddCooldownEntry("DRUID", 102351, 30) -- Cenarion Ward
AddCooldownEntry("DRUID", 99, 30) -- Disorienting Roar
AddCooldownEntry("DRUID", 102280, 30) -- Displacer Beast
AddCooldownEntry("DRUID", 102401, 15) -- Wild Charge
AddCooldownEntry("DRUID", 106731, 180) -- Incarnation
AddCooldownEntry("DRUID", 106737, 20) -- Force of Nature
AddCooldownEntry("DRUID", 108288, 360) -- Heart of the Wild
AddCooldownEntry("DRUID", 102359, 30) -- Mass Entanglement
AddCooldownEntry("DRUID", 5211, 50) -- Mighty Bash
AddCooldownEntry("DRUID", 132158, 60) -- Nature's Swiftness
AddCooldownEntry("DRUID", 124974, 90) -- Nature's Vigil
AddCooldownEntry("DRUID", 108238, 120) -- Renewal
AddCooldownEntry("DRUID", 132469, 30) -- Typhoon
AddCooldownEntry("DRUID", 102793, 60) -- Ursol's Vortex
AddCooldownEntry("DRUID", 112071, { cd = 180, spec = L["Balance"] }) -- Celestial Alignment
AddCooldownEntry("DRUID", 61336, { cd = 180, spec = L["Feral"] }) -- Survival Instincts
AddCooldownEntry("DRUID", 61336, { cd = 180, spec = L["Guardian"] }) -- Survival Instincts
AddCooldownEntry("DRUID", 2782, { cd = 8, spec = L["Balance"] }) -- Remove Corruption
AddCooldownEntry("DRUID", 2782, { cd = 8, spec = L["Feral"] }) -- Remove Corruption
AddCooldownEntry("DRUID", 2782, { cd = 8, spec = L["Guardian"] }) -- Remove Corruption
AddCooldownEntry("DRUID", 62606, { cd = 9, spec = L["Guardian"] }) -- Savage Defense
AddCooldownEntry("DRUID", 48505, { cd = 90, spec = L["Balance"] }) -- Starfall
AddCooldownEntry("DRUID", 78675, { cd = 60, spec = L["Balance"] }) -- Solar Beam
AddCooldownEntry("DRUID", 5217, { cd = 30, spec = L["Feral"] }) -- Tiger's Fury
AddCooldownEntry("DRUID", 102795, { cd = 60, spec = L["Guardian"] }) -- Bear Hug
AddCooldownEntry("DRUID", 5229, { cd = 60, spec = L["Guardian"] }) -- Enrage
AddCooldownEntry("DRUID", 102342, { cd = 30, spec = L["Restoration"] }) -- Ironbark
AddCooldownEntry("DRUID", 88423, { cd = 8, spec = L["Restoration"] }) -- Nature's Cure
AddCooldownEntry("DRUID", 18562, { cd = 13, spec = L["Restoration"] }) -- Swiftmend
AddCooldownEntry("DRUID", 106951, { cd = 180, spec = L["Feral"] }) -- Berserk
AddCooldownEntry("DRUID", 106951, { cd = 180, spec = L["Guardian"] }) -- Berserk
AddCooldownEntry("DRUID", 93985, { cd = 15, spec = L["Feral"] }) -- Skull Bash
AddCooldownEntry("DRUID", 93985, { cd = 15, spec = L["Guardian"] }) -- Skull Bash

-- Hunter
AddCooldownEntry("HUNTER", 5116, 5) -- Concussive Shot
AddCooldownEntry("HUNTER", 781, 20) -- Disengage
AddCooldownEntry("HUNTER", 19503, 30) -- Scatter Shot
AddCooldownEntry("HUNTER", 1499, {  -- Freezing Trap
    cd = 30,
    [L["Survival"]] = 24,
    sharedCD = {
        [13809] = true, -- Ice Trap
        [60192] = true, -- Freezing Trap (Trap Launcher)
    },
})
AddCooldownEntry("HUNTER", 13813, { cd = 30, [L["Survival"]] = 24 })
AddCooldownEntry("HUNTER", 13809, { -- Ice Trap
    cd = 30,
    [L["Survival"]] = 24,
    sharedCD = {
        [1499] = true, -- Freezing Trap
        [60192] = true, -- Freezing Trap (Trap Launcher)
    },
})
AddCooldownEntry("HUNTER", 34600, { cd = 30, [L["Survival"]] = 24 }) -- Snake Trap
AddCooldownEntry("HUNTER", 53351, 10) -- Kill Shot
AddCooldownEntry("HUNTER", 1543, 20) -- Flare
AddCooldownEntry("HUNTER", 3045, { cd = 180, [L["Marksmanship"]] = 180 }) -- Rapid Fire
AddCooldownEntry("HUNTER", 53271, 45) -- Master's Call
AddCooldownEntry("HUNTER", 19263, { cd = 180 }) -- Deterrence
AddCooldownEntry("HUNTER", 51753, 60) -- Camouflage
AddCooldownEntry("HUNTER", 121818, 300) -- Stampede
AddCooldownEntry("HUNTER", 109248, 45) -- Binding Shot
AddCooldownEntry("HUNTER", 19386, 45) -- Wyvern Sting
AddCooldownEntry("HUNTER", 109304, 120) -- Exhilaration
AddCooldownEntry("HUNTER", 120679, 30) -- Dire Beast
AddCooldownEntry("HUNTER", 82726, 30) -- Fervor
AddCooldownEntry("HUNTER", 131894, 120) -- A Murder of Crows
AddCooldownEntry("HUNTER", 130392, 20) -- Blink Strike
AddCooldownEntry("HUNTER", 120697, 90) -- Lynx Rush
AddCooldownEntry("HUNTER", 120360, 30) -- Barrage
AddCooldownEntry("HUNTER", 117050, 15) -- Glaive Toss
AddCooldownEntry("HUNTER", 109259, 45) -- Powershot
AddCooldownEntry("HUNTER", 19577, 60) -- Intimidation
AddCooldownEntry("HUNTER", 19574, { cd = 60, spec = L["Beast Mastery"] }) -- Bestial Wrath
AddCooldownEntry("HUNTER", 53209, { cd = 9, spec = L["Marksmanship"] }) -- Chimera Shot
AddCooldownEntry("HUNTER", 34490, { cd = 24, spec = L["Marksmanship"] }) -- Silencing Shot
AddCooldownEntry("HUNTER", 147362, { cd = 24, spec = L["Beast Mastery"] }) -- Counter Shot
AddCooldownEntry("HUNTER", 53301, { cd = 6, spec = L["Survival"] }) -- Explosive Shot
AddCooldownEntry("HUNTER", 1742, 45) -- Cower
AddCooldownEntry("HUNTER", 53401, 90) -- Rabid
AddCooldownEntry("HUNTER", 55709, 480) -- Heart of the Phoenix
AddCooldownEntry("HUNTER", 61684, 32) -- Dash
AddCooldownEntry("HUNTER", 53478, 360) -- Last Stand
AddCooldownEntry("HUNTER", 61685, 25) -- Charge
AddCooldownEntry("HUNTER", 63900, 10) -- Thunderstomp
AddCooldownEntry("HUNTER", 53480, 60) -- Roar of Sacrifice
AddCooldownEntry("HUNTER", 53490, 180) -- Bullheaded
AddCooldownEntry("HUNTER", 50245, 40) -- Pin
AddCooldownEntry("HUNTER", 50285, 25) -- Dust Cloud
AddCooldownEntry("HUNTER", 50541, 60) -- Clench
AddCooldownEntry("HUNTER", 126423, 120) -- Petrifying Gaze
AddCooldownEntry("HUNTER", 137798, 30) -- Reflective Armor Plating
AddCooldownEntry("HUNTER", 24844, 30) -- Lightning Breath
AddCooldownEntry("HUNTER", 26064, 60) -- Shell Shield
AddCooldownEntry("HUNTER", 34889, 30) -- Fire Breath
AddCooldownEntry("HUNTER", 35346, 15) -- Time Warp
AddCooldownEntry("HUNTER", 4167, 40) -- Web
AddCooldownEntry("HUNTER", 50433, 10) -- Ankle Crack
AddCooldownEntry("HUNTER", 50479, 40) -- Nether Shock
AddCooldownEntry("HUNTER", 50519, 120) -- Sonic Blast
AddCooldownEntry("HUNTER", 90327, 40) -- Lock Jaw
AddCooldownEntry("HUNTER", 90339, 60) -- Harden Carapace
AddCooldownEntry("HUNTER", 126402, 10) -- Trample
AddCooldownEntry("HUNTER", 26090, 30) -- Pummel
AddCooldownEntry("HUNTER", 50318, 60) -- Serenity Dust
AddCooldownEntry("HUNTER", 56626, 90) -- Sting
AddCooldownEntry("HUNTER", 90337, 120) -- Bad Manner
AddCooldownEntry("HUNTER", 126355, 120) -- Paralyzing Quill
AddCooldownEntry("HUNTER", 54706, 40) -- Venom Web Spray
AddCooldownEntry("HUNTER", 91644, 60) -- Snatch
AddCooldownEntry("HUNTER", 126393, 600) -- Eternal Guardian
AddCooldownEntry("HUNTER", 54644, 10) -- Frost Breath
AddCooldownEntry("HUNTER", 93433, 14) -- Burrow Attack
AddCooldownEntry("HUNTER", 90314, 10) -- Tailspin
AddCooldownEntry("HUNTER", 90355, 360) -- Ancient Hysteria
AddCooldownEntry("HUNTER", 58604, 8) -- Lava Breath
AddCooldownEntry("HUNTER", 96201, 90) -- Web Wrap
AddCooldownEntry("HUNTER", 126246, 120) -- Lullaby
AddCooldownEntry("HUNTER", 50274, 8) -- Spore Cloud
AddCooldownEntry("HUNTER", 93434, 90) -- Horn Toss
AddCooldownEntry("HUNTER", 90361, 30) -- Spirit Mend

-- Mage
AddCooldownEntry("MAGE", 108978, 90) -- Alter Time
AddCooldownEntry("MAGE", 1953, 15) -- Blink
AddCooldownEntry("MAGE", 120, 10) -- Cone of Cold
AddCooldownEntry("MAGE", 2139, 24) -- Counterspell
AddCooldownEntry("MAGE", 44572, 30) -- Deep Freeze
AddCooldownEntry("MAGE", 12051, 120) -- Evocation
AddCooldownEntry("MAGE", 122, 25) -- Frost Nova
AddCooldownEntry("MAGE", 45438, 300) -- Ice Block
AddCooldownEntry("MAGE", 66, 300) -- Invisibility
AddCooldownEntry("MAGE", 55342, 180) -- Mirror Image
AddCooldownEntry("MAGE", 475, 8) -- Remove Curse
AddCooldownEntry("MAGE", 80353, 300) -- Time Warp
AddCooldownEntry("MAGE", 108843, 25) -- Blazing Speed
AddCooldownEntry("MAGE", 86949, 120) -- Cauterize
AddCooldownEntry("MAGE", 11958, { -- Cold Snap
    cd = 180,
    spec = L["Frost"],
    resetCD = {
        [45438] = true, -- Ice Block
        [44572] = true, -- Deep Freeze
        [12472] = true, -- Icy Veins
        [31687] = true, -- Summon Water Elemental
        [120] = true, -- Cone of Cold
        [122] = true, -- Frost Nova
        [11426] = true, -- Ice Barrier
    },
})
AddCooldownEntry("MAGE", 112948, 10) -- Frost Bomb
AddCooldownEntry("MAGE", 102051, 20) -- Frostjaw
AddCooldownEntry("MAGE", 110959, 90) -- Greater Invisibility
AddCooldownEntry("MAGE", 11426, 25) -- Ice Barrier
AddCooldownEntry("MAGE", 108839, 20) -- Ice Floes
AddCooldownEntry("MAGE", 111264, 20) -- Ice Ward
AddCooldownEntry("MAGE", 1463, 25) -- Incanter's Ward
AddCooldownEntry("MAGE", 114003, 10) -- Invocation
AddCooldownEntry("MAGE", 12043, 90) -- Presence of Mind
AddCooldownEntry("MAGE", 113724, 45) -- Ring of Frost
AddCooldownEntry("MAGE", 115610, 25) -- Temporal Shield
AddCooldownEntry("MAGE", 12042, { cd = 90, spec = L["Arcane"] }) -- Arcane Power
AddCooldownEntry("MAGE", 11129, { cd = 45, spec = L["Fire"] }) -- Combustion
AddCooldownEntry("MAGE", 31661, { cd = 20, spec = L["Fire"] }) -- Dragon's Breath
AddCooldownEntry("MAGE", 84714, { cd = 60, spec = L["Frost"] }) -- Frozen Orb
AddCooldownEntry("MAGE", 12472, { cd = 180, spec = L["Frost"] }) -- Icy Veins
AddCooldownEntry("MAGE", 31687, { cd = 60, spec = L["Frost"] }) -- Summon Water Elemental

-- Monk
AddCooldownEntry("MONK", 109132, { cd = 20, charges = 2 }) -- Roll
AddCooldownEntry("MONK", 115450, 8) -- Detox
AddCooldownEntry("MONK", 115072, 15) -- Expel Harm
AddCooldownEntry("MONK", 115203, 180) -- Fortifying Brew
AddCooldownEntry("MONK", 117368, 60) -- Grapple Weapon
AddCooldownEntry("MONK", 115078, 15) -- Paralysis
AddCooldownEntry("MONK", 116705, 15) -- Spear Hand Strike
--AddCooldownEntry("MONK", 101643, 45) -- Transcendence
AddCooldownEntry("MONK", 119996, 25) -- Transcendence: Transfer
AddCooldownEntry("MONK", 115176, 180) -- Zen Meditation
AddCooldownEntry("MONK", 137562, 120) -- Nimble Brew
AddCooldownEntry("MONK", 119392, 30) -- Charging Ox Wave
AddCooldownEntry("MONK", 122278, 90) -- Dampen Harm
AddCooldownEntry("MONK", 122783, 90) -- Diffuse Magic
AddCooldownEntry("MONK", 123904, 180) -- Invoke Xuen, the White
AddCooldownEntry("MONK", 119381, 45) -- Leg Sweep
AddCooldownEntry("MONK", 116844, 45) -- Ring of Peace
AddCooldownEntry("MONK", 116841, 30) -- Tiger's Lust
AddCooldownEntry("MONK", 115213, { cd = 180, spec = L["Brewmaster"] }) -- Avert Harm
AddCooldownEntry("MONK", 122057, { cd = 35, spec = L["Brewmaster"] }) -- Clash
AddCooldownEntry("MONK", 115308, { cd = 6, spec = L["Brewmaster"] }) -- Elusive Brew
AddCooldownEntry("MONK", 115295, { cd = 30, spec = L["Brewmaster"] }) -- Guard
--AddCooldownEntry("MONK", 121253, { cd = 8, spec = L["Brewmaster"] }) -- Keg Smash
AddCooldownEntry("MONK", 115315, { cd = 30, spec = L["Brewmaster"] }) -- Summon Black Ox
AddCooldownEntry("MONK", 115288, { cd = 60, spec = L["Windwalker"] }) -- Energizing Brew
AddCooldownEntry("MONK", 113656, { cd = 25, spec = L["Windwalker"] }) -- Fists of Fury
AddCooldownEntry("MONK", 101545, { cd = 25, spec = L["Windwalker"] }) -- Flying Serpent Kick
AddCooldownEntry("MONK", 122470, { cd = 90, spec = L["Windwalker"] }) -- Touch of Karma
AddCooldownEntry("MONK", 116849, { cd = 120, spec = L["Mistweaver"] }) -- Life Cocoon
--AddCooldownEntry("MONK", 115151, { cd = 8, spec = L["Mistweaver"] }) -- Renewing Mist
AddCooldownEntry("MONK", 115310, { cd = 180, spec = L["Mistweaver"] }) -- Revival
AddCooldownEntry("MONK", 115313, { cd = 30, spec = L["Mistweaver"] }) -- Summon Jade Serpent
AddCooldownEntry("MONK", 116680, { cd = 45, spec = L["Mistweaver"] }) -- Thunder Focus Tea

-- Paladin
AddCooldownEntry("PALADIN", 31884, 120) -- Avenging Wrath
AddCooldownEntry("PALADIN", 115750, 120) -- Blinding Light
AddCooldownEntry("PALADIN", 4987, 8) -- Cleanse
AddCooldownEntry("PALADIN", 31821, 180)  -- Devotion Aura
AddCooldownEntry("PALADIN", 498, 60) -- Divine Protection
AddCooldownEntry("PALADIN", 642, 300) -- Divine Shield
AddCooldownEntry("PALADIN", 853, 60) -- Hammer of Justice
AddCooldownEntry("PALADIN", 1044, 25) -- Hand of Freedom
AddCooldownEntry("PALADIN", 1022, 300) -- Hand of Protection
AddCooldownEntry("PALADIN", 6940, 120) -- Hand of Sacrifice
AddCooldownEntry("PALADIN", 96231, 15) -- Rebuke
AddCooldownEntry("PALADIN", 10326, 15) -- Turn Evil
AddCooldownEntry("PALADIN", 114157, 60) -- Execution Sentence
AddCooldownEntry("PALADIN", 105593, 30) -- Fist of Justice
AddCooldownEntry("PALADIN", 114039, 30) -- Hand of Purity
AddCooldownEntry("PALADIN", 105809, 120) -- Holy Avenger
AddCooldownEntry("PALADIN", 114165, 20) -- Holy Prism
AddCooldownEntry("PALADIN", 114158, 60) -- Light's Hammer
AddCooldownEntry("PALADIN", 20066, 15) -- Repentance
AddCooldownEntry("PALADIN", 20925, 6) -- Sacred Shield
AddCooldownEntry("PALADIN", 85499, 45) -- Speed of Light
AddCooldownEntry("PALADIN", 31842, { cd = 180, spec = L["Holy"] }) -- Divine Favor
AddCooldownEntry("PALADIN", 54428, { cd = 120, spec = L["Holy"] }) -- Divine Plea
AddCooldownEntry("PALADIN", 86669, { cd = 180, spec = L["Holy"] }) -- Guardian of Ancient Kings (Holy)
AddCooldownEntry("PALADIN", 20473, { cd = 6, spec = L["Holy"] }) -- Holy Shock
AddCooldownEntry("PALADIN", 31850, { cd = 180, spec = L["Protection"] }) -- Ardent Defender
AddCooldownEntry("PALADIN", 31935, { cd = 15, spec = L["Protection"] }) -- Avenger's Shield
AddCooldownEntry("PALADIN", 86659, { cd = 180, spec = L["Protection"] }) -- Guardian of Ancient Kings (Protection)
AddCooldownEntry("PALADIN", 86525, { cd = 180, spec = L["Retribution"] }) -- Guardian of Ancient Kings (Retribution)

-- Priest
AddCooldownEntry("PRIEST", 8122, { cd = 27, [L["Shadow"]] = 26 }) -- Psychic Scream
AddCooldownEntry("PRIEST", 34433, { cd = 300, [L["Shadow"]] = 240 }) -- Shadowfiend
AddCooldownEntry("PRIEST", 15487, { cd = 45, spec = L["Shadow"] }) -- Silence
AddCooldownEntry("PRIEST", 64044, { cd = 90, spec = L["Shadow"] }) -- Psychic Horror (+ Glyph) else 120
AddCooldownEntry("PRIEST", 586, { cd = 30, [L["Shadow"]] = 15 }) -- Fade (+ Glyph) else 24
AddCooldownEntry("PRIEST", 33076, 10) -- Prayer of Mending
AddCooldownEntry("PRIEST", 73325, 90) -- Leap of Faith
AddCooldownEntry("PRIEST", 64843, { cd = 180, spec = L["Holy"] }) -- Divine Hymn
AddCooldownEntry("PRIEST", 64901, 360) -- Hymn of Hope
AddCooldownEntry("PRIEST", 32379, 10) -- Shadow Word: Death
AddCooldownEntry("PRIEST", 6346, 180) -- Fear Ward
AddCooldownEntry("PRIEST", 81700, 30) -- Archangel
AddCooldownEntry("PRIEST", 87153, 90) -- Dark Archangel
AddCooldownEntry("PRIEST", 47585, { cd = 75, spec = L["Shadow"] }) -- Dispersion (+ Glyph)
AddCooldownEntry("PRIEST", 10060, { cd = 120, spec = L["Discipline"] }) -- Power Infusion
AddCooldownEntry("PRIEST", 33206, { cd = 180, spec = L["Discipline"] }) -- Pain Suppression
AddCooldownEntry("PRIEST", 62618, { cd = 180, spec = L["Discipline"] }) -- Power Word: Barrier
AddCooldownEntry("PRIEST", 47788, { cd = 150, spec = L["Holy"] }) -- Guardian spirit (+ Glyph)
AddCooldownEntry("PRIEST", 724, { cd = 180, spec = L["Holy"] }) -- Lightwell
AddCooldownEntry("PRIEST", 19236, { cd = 120, spec = L["Holy"] }) -- Desperate Prayer

-- Shaman
AddCooldownEntry("SHAMAN", 57994, 15) -- Wind Shear
AddCooldownEntry("SHAMAN", 51514, 45) -- Hex
AddCooldownEntry("SHAMAN", 8143, 60) -- Tremor Totem
AddCooldownEntry("SHAMAN", 8177, 25) -- Grounding Totem
AddCooldownEntry("SHAMAN", 79206, 120) -- Spiritwalker's Grace
AddCooldownEntry("SHAMAN", 30823, { cd = 60, spec = L["Enhancement"] }) -- Shamanistic Rage
AddCooldownEntry("SHAMAN", 61882, { cd = 10, spec = L["Elemental"] }) -- Earthquake
AddCooldownEntry("SHAMAN", 16166, { cd = 180, spec = L["Elemental"] }) -- Elemental Mastery
AddCooldownEntry("SHAMAN", 51490, { cd = 45, spec = L["Elemental"] }) -- Thunderstorm
AddCooldownEntry("SHAMAN", 16188, { cd = 120, spec = L["Restoration"] }) -- Natures Swiftness
AddCooldownEntry("SHAMAN", 51533, { cd = 120, spec = L["Enhancement"] }) -- Feral Spirit
AddCooldownEntry("SHAMAN", 16190, { cd = 180, spec = L["Restoration"] }) -- Mana Tide Totem
AddCooldownEntry("SHAMAN", 98008, { cd = 180, spec = L["Restoration"] }) -- Spirit Link Totem

-- Warlock
AddCooldownEntry("WARLOCK", 5484, 40) -- Howl of Terror
AddCooldownEntry("WARLOCK", 6789, 120) -- Death Coil
AddCooldownEntry("WARLOCK", 48020, 30) -- Demonic Circle: Port
AddCooldownEntry("WARLOCK", 19647, { cd = 24, pet = true }) -- Spell Lock
AddCooldownEntry("WARLOCK", 19505, { cd = 15, pet = true }) -- Devour Magic
AddCooldownEntry("WARLOCK", 110913, 180) -- Dark Bargain
AddCooldownEntry("WARLOCK", 30283, { cd = 20, spec = L["Destruction"] }) -- Shadowfury
AddCooldownEntry("WARLOCK", 91711, { cd = 30, spec = L["Destruction"] }) -- Nether Ward
AddCooldownEntry("WARLOCK", 89766, { cd = 30, spec = L["Demonology"], pet = true }) -- Axe Toss
AddCooldownEntry("WARLOCK", 113860, { cd = 120, spec = L["Affliction"] }) -- Dark Soul: Misery
AddCooldownEntry("WARLOCK", 113861, { cd = 120, spec = L["Demonology"] }) -- Dark Soul: Knowledge
AddCooldownEntry("WARLOCK", 113858, { cd = 120, spec = L["Destruction"] }) -- Dark Soul: Instability
AddCooldownEntry("WARLOCK", 108359, 120) -- Dark Regeneration

-- Warrior
AddCooldownEntry("WARRIOR", 6552, { cd = 10 }) -- Pummel
AddCooldownEntry("WARRIOR", 107570, { cd = 30 }) -- Storm Bolt
AddCooldownEntry("WARRIOR", 46968, { cd = 40 }) -- Shockwave
AddCooldownEntry("WARRIOR", 100, { cd = 20 }) -- Charge
AddCooldownEntry("WARRIOR", 18499, 30) -- Berserker Rage
AddCooldownEntry("WARRIOR", 23920, 10) -- Spell Reflection
AddCooldownEntry("WARRIOR", 3411, 30) -- Intervene
AddCooldownEntry("WARRIOR", 6544, { cd = 45, [L["Arms"]] = 30 }) -- Heroic Leap
AddCooldownEntry("WARRIOR", 676, 60) -- Disarm
AddCooldownEntry("WARRIOR", 5246, 120) -- Intimidating Shout
AddCooldownEntry("WARRIOR", 2565, 60) -- Shield Block
AddCooldownEntry("WARRIOR", 55694, 180) -- Enraged Regeneration
AddCooldownEntry("WARRIOR", 1719, 300) -- Recklessness
AddCooldownEntry("WARRIOR", 871, 300) -- Shield Wall
AddCooldownEntry("WARRIOR", 64382, 300) -- Shattering Throw
--AddCooldownEntry("WARRIOR", 86346, 20) -- Colossus Smash
AddCooldownEntry("WARRIOR", 97462, 180) -- Rallying Cry
AddCooldownEntry("WARRIOR", 12292, { cd = 180, spec = L["Fury"] }) -- Death Wish
AddCooldownEntry("WARRIOR", 46924, { cd = 90, spec = L["Arms"] }) -- Bladestorm
AddCooldownEntry("WARRIOR", 12328, { cd = 60, spec = L["Arms"] }) -- Sweeping strikes
AddCooldownEntry("WARRIOR", 12975, { cd = 180, spec = L["Protection"] }) -- Last Stand

-- Rogue
AddCooldownEntry("ROGUE", 1766, 10) -- Kick with glyph -4s and -6 when successful kick (so 15-4 or 15-6)
AddCooldownEntry("ROGUE", 408, 20) -- Kidney Shot
AddCooldownEntry("ROGUE", 5277, 180) -- Evasion
AddCooldownEntry("ROGUE", 31224, 60) -- Cloak of Shadow
AddCooldownEntry("ROGUE", 1856, 180) -- Vanish
AddCooldownEntry("ROGUE", 2094, 180) -- Blind
AddCooldownEntry("ROGUE", 51722, 60) -- Dismantle
AddCooldownEntry("ROGUE", 2983, 60) -- Sprint
AddCooldownEntry("ROGUE", 76577, 180) -- Smoke Bomb
AddCooldownEntry("ROGUE", 73981, 60) -- Redirect
AddCooldownEntry("ROGUE", 74001, 90) -- Combat Readiness
AddCooldownEntry("ROGUE", 79140, { cd = 120, spec = L["Assassination"] }) -- Vendetta
AddCooldownEntry("ROGUE", 51713, { cd = 60, spec = L["Subtlety"] }) -- Shadow Dance
AddCooldownEntry("ROGUE", 13750, { cd = 180, spec = L["Combat"] }) -- Adrenaline Rush
AddCooldownEntry("ROGUE", 13877, { cd = 10, spec = L["Combat"] }) -- Blade Flurry
AddCooldownEntry("ROGUE", 51690, { cd = 120, spec = L["Combat"] }) -- Killing Spree
AddCooldownEntry("ROGUE", 36554, { cd = 24, spec = L["Subtlety"] }) -- Shadowstep
AddCooldownEntry("ROGUE", 14185, { -- Preparation
    cd = 300,
    spec = L["Subtlety"],
    resetCD = {
        [2983] = true,
        [1856] = true,
        [1766] = true,
        [51722] = true,
        [36554] = true,
        [76577] = true,
    },
})

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
    ["DRUID"] = { [L["Restoration"]] = 88423}, -- 88423 Nature's Cure
    ["DEATHKNIGHT"] = { },
    ["HUNTER"] = { },
    ["MAGE"] = { [L["Frost"]] = 475, [L["Arcane"]] = 475, [L["Fire"]] = 475 }, -- 475 Remove Curse
    ["PALADIN"] = { [L["Holy"]] = 527, [L["Discipline"]] = 527 , [L["Shadow"]] = 32375 }, -- 4987 Cleanse
    ["PRIEST"] = { [L["Holy"]] = 527, [L["Discipline"]] = 527 , [L["Shadow"]] = 32375 }, -- 527 Purify
    ["ROGUE"] = { },
    ["SHAMAN"] = { [L["Elemental"]] = 51886, [L["Enhancement"]] = 51886 , [L["Restoration"]] = 77130 },
    ["WARLOCK"] = { },
    ["WARRIOR"] = { },
    ["MONK"] = { [L["Mistweaver"]] = 51886 },-- classicon-monk
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
