local tbl_sort, select, string_lower = table.sort, select, string.lower

local GetSpellInfo = GetSpellInfo
local GetItemInfo = GetItemInfo

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

Gladdy.expansion = "Wrath"
Gladdy.CLASSES = { "MAGE", "PRIEST", "DRUID", "SHAMAN", "PALADIN", "WARLOCK", "WARRIOR", "HUNTER", "ROGUE", "DEATHKNIGHT" }
tbl_sort(Gladdy.CLASSES)

local specSpells = {
    [GetSpellInfo(55050)] = L["Blood"], -- Heart Strike
    [GetSpellInfo(55233)] = L["Blood"], -- Vampiric Blood
    [GetSpellInfo(49028)] = L["Blood"], -- Dancing Rune Weapon
    [GetSpellInfo(53138)] = L["Blood"], -- Abomination's Might
    [GetSpellInfo(77513)] = L["Blood"], -- Blood Shield
    [GetSpellInfo(77535)] = L["Blood"], -- Blood Shield
    [GetSpellInfo(49222)] = L["Blood"], -- Bone Shield
    [GetSpellInfo(53137)] = L["Blood"], -- Abomination's Might
    [GetSpellInfo(79893)] = L["Blood"], -- Bloodworm
    [GetSpellInfo(96171)] = L["Blood"], -- Will of the Necropolis
    [GetSpellInfo(81162)] = L["Blood"], -- Will of the Necropolis
    [GetSpellInfo(48982)] = L["Blood"], -- Rune Tap
    [GetSpellInfo(49143)] = L["Frost"], -- Frost Strike
    [GetSpellInfo(50435)] = L["Frost"], -- Chilblains
    [GetSpellInfo(50434)] = L["Frost"], -- Chilblains
    [GetSpellInfo(51271)] = L["Frost"], -- Pillar of Frost
    [GetSpellInfo(49203)] = L["Frost"], -- Hungering Cold
    [GetSpellInfo(49184)] = L["Frost"], -- Howling Blast
    [GetSpellInfo(55610)] = L["Frost"], -- Improved Icy Talons
    [GetSpellInfo(51124)] = L["Frost"], -- Killing Machine
    [GetSpellInfo(51271)] = L["Frost"], -- Pillar of Frost
    [GetSpellInfo(55090)] = L["Unholy"], -- Scourge Strike
    [GetSpellInfo(65142)] = L["Unholy"], -- Ebon Plague
    [GetSpellInfo(51052)] = L["Unholy"], -- Anti-Magic Zone
    [GetSpellInfo(49206)] = L["Unholy"], -- Summon Gargoyle
    [GetSpellInfo(66803)] = L["Unholy"], -- Desolation
    [GetSpellInfo(66802)] = L["Unholy"], -- Desolation
    [GetSpellInfo(66801)] = L["Unholy"], -- Desolation
    [GetSpellInfo(66800)] = L["Unholy"], -- Desolation
    [GetSpellInfo(63583)] = L["Unholy"], -- Desolation
    [GetSpellInfo(49194)] = L["Unholy"], -- Unholy Blight (debuff)
    [GetSpellInfo(51460)] = L["Unholy"], -- Runic Corruption
    [GetSpellInfo(49016)] = L["Unholy"], -- Unholy Frenzy
    [GetSpellInfo(91342)] = L["Unholy"], -- Shadow Infusion
    [GetSpellInfo(63560)] = L["Unholy"], -- Dark Transformation
    --
    [GetSpellInfo(24858)] = L["Balance"], -- Moonkin Form
    [GetSpellInfo(50516)] = L["Balance"], -- Typhoon
    [GetSpellInfo(61391)] = L["Balance"], -- Typoon Dazed (Debuff)
    [GetSpellInfo(48505)] = L["Balance"], -- Starfall
    [GetSpellInfo(48391)] = L["Balance"], -- Owlkin Frenzy
    [GetSpellInfo(48517)] = L["Balance"], -- Eclipse Solar
    [GetSpellInfo(48518)] = L["Balance"], -- Eclipse Lunar
    [GetSpellInfo(60433)] = L["Balance"], -- Earth and Moon
    [GetSpellInfo(33831)] = L["Balance"], -- Force of Nature
    [GetSpellInfo(24907)] = L["Balance"], -- Moonkin Aura
    [GetSpellInfo(93402)] = L["Balance"], -- Sunfire (cast)
    [GetSpellInfo(93400)] = L["Balance"], -- Shooting Stars
    [GetSpellInfo(81006)] = L["Balance"], -- Lunar Shower
    [GetSpellInfo(81288)] = L["Balance"], -- Fungal Growth (debuff)
    [GetSpellInfo(81281)] = L["Balance"], -- Fungal Growth (debuff)
    [GetSpellInfo(24932)] = L["Feral"], -- Leader of the Pack
    [GetSpellInfo(58180)] = L["Feral"], -- Infected Wounds
    [GetSpellInfo(58179)] = L["Feral"], -- Infected Wounds
    [GetSpellInfo(33876)] = L["Feral"], -- Mangle (Cat)
    [GetSpellInfo(33878)] = L["Feral"], -- Mangle (Bear)
    [GetSpellInfo(50334)] = L["Feral"], -- Berserk (Bear)
    [GetSpellInfo(81016)] = L["Feral"], -- Stampede
    [GetSpellInfo(81022)] = L["Feral"], -- Stampede
    [GetSpellInfo(81017)] = L["Feral"], -- Stampede
    [GetSpellInfo(81021)] = L["Feral"], -- Stampede
    [GetSpellInfo(51185)] = L["Feral"], -- King of the Jungle
    [GetSpellInfo(61336)] = L["Feral"], -- Survival Instincts
    [GetSpellInfo(80313)] = L["Feral"], -- Pulverize
    [GetSpellInfo(49377)] = L["Feral"], -- Feral Charge (cast)
    [GetSpellInfo(33891)] = L["Restoration"], -- Tree of Life
    [GetSpellInfo(48438)] = L["Restoration"], -- Wild Growth
    [GetSpellInfo(18562)] = L["Restoration"], -- Swiftmend
    [GetSpellInfo(45283)] = L["Restoration"], -- R3
    [GetSpellInfo(45282)] = L["Restoration"], -- R2
    [GetSpellInfo(45281)] = L["Restoration"], -- R1
    [GetSpellInfo(48504)] = L["Restoration"], -- Living Seed
    [GetSpellInfo(17116)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(81093)] = L["Restoration"], -- Fury of Stormrage
    [GetSpellInfo(81262)] = L["Restoration"], -- Efflorescence
    --
    [GetSpellInfo(19574)] = L["BeastMastery"], -- Bestial Wrath
    [GetSpellInfo(53257)] = L["BeastMastery"], -- Cobra Strikes
    [GetSpellInfo(34471)] = L["BeastMastery"], -- Beast within
    [GetSpellInfo(75447)] = L["BeastMastery"], -- Ferocious Inspiration
    [GetSpellInfo(19577)] = L["BeastMastery"], -- Intimidation
    [GetSpellInfo(94006)] = L["BeastMastery"], -- Killing Streak R1
    [GetSpellInfo(94007)] = L["BeastMastery"], -- Killing Streak R2
    [GetSpellInfo(82692)] = L["BeastMastery"], -- Focus Fire
    [GetSpellInfo(82726)] = L["BeastMastery"], -- Fervor
    [GetSpellInfo(19506)] = L["Marksmanship"], -- Trueshot Aura
    [GetSpellInfo(53209)] = L["Marksmanship"], -- Chimera Shot
    [GetSpellInfo(34490)] = L["Marksmanship"], -- Silencing Shot
    [GetSpellInfo(63468)] = L["Marksmanship"], -- Piercing Shots
    [GetSpellInfo(53220)] = L["Marksmanship"], -- Improved Steady Shot
    [GetSpellInfo(19434)] = L["Marksmanship"], -- Aimed Shot
    [GetSpellInfo(88691)] = L["Marksmanship"], -- Marked for Death
    [GetSpellInfo(83559)] = L["Marksmanship"], -- Posthaste
    [GetSpellInfo(82925)] = L["Marksmanship"], -- Ready, Set, Aim...
    [GetSpellInfo(23989)] = L["Marksmanship"], -- Readiness
    [GetSpellInfo(82897)] = L["Marksmanship"], -- Resistance is Futile!
    [GetSpellInfo(82921)] = L["Marksmanship"], -- Bombardment
    [GetSpellInfo(413848)] = L["Marksmanship"], -- Piercing Shots (debuff)
    [GetSpellInfo(63468)] = L["Marksmanship"], -- Piercing Shots (debuff)
    [GetSpellInfo(35101)] = L["Marksmanship"], -- Concussive Barrage (debuff)
    [GetSpellInfo(19386)] = L["Survival"], -- Wyvern Sting
    [GetSpellInfo(63672)] = L["Survival"], -- Black Arrow (debuff)
    [GetSpellInfo(3674)] = L["Survival"], -- Black Arrow
    [GetSpellInfo(53301)] = L["Survival"], -- Explosive Shot
    [GetSpellInfo(34837)] = L["Survival"], -- Rank 5 Master Tactician
    [GetSpellInfo(34836)] = L["Survival"], -- Rank 4 Master Tactician
    [GetSpellInfo(34835)] = L["Survival"], -- Rank 3 Master Tactician
    [GetSpellInfo(34834)] = L["Survival"], -- Rank 2 Master Tactician
    [GetSpellInfo(34833)] = L["Survival"], -- Rank 1 Master Tactician
    [GetSpellInfo(64420)] = L["Survival"], -- Sniper Training R3
    [GetSpellInfo(64419)] = L["Survival"], -- Sniper Training R2
    [GetSpellInfo(64418)] = L["Survival"], -- Sniper Training R1
    [GetSpellInfo(19306)] = L["Survival"], -- Counterattack
    [GetSpellInfo(56453)] = L["Survival"], -- Lock and Load
    [GetSpellInfo(53290)] = L["Survival"], -- Hunting Party
    --
    [GetSpellInfo(31589)] = L["Arcane"], -- Slow
    [GetSpellInfo(44425)] = L["Arcane"], -- Arcane Barrage
    [GetSpellInfo(12042)] = L["Arcane"], -- Arcane Power
    [GetSpellInfo(44413)] = L["Arcane"], -- Incanter's Absorption
    [GetSpellInfo(83098)] = L["Arcane"], -- Improved Mana Gem
    [GetSpellInfo(54646)] = L["Arcane"], -- Focus Magic
    [GetSpellInfo(57531)] = L["Arcane"], -- Arcane Potency
    [GetSpellInfo(57529)] = L["Arcane"], -- Arcane Potency
    [GetSpellInfo(12043)] = L["Arcane"], -- Presence of Mind
    [GetSpellInfo(82930)] = L["Arcane"], -- Arcane Tactics
    [GetSpellInfo(44457)] = L["Fire"], -- Living Bomb
    [GetSpellInfo(31661)] = L["Fire"], -- Dragon's Breath
    [GetSpellInfo(83853)] = L["Fire"], -- Combustion (debuff)
    [GetSpellInfo(48108)] = L["Fire"], -- Hot Streak
    [GetSpellInfo(64346)] = L["Fire"], -- Fiery Payback
    [GetSpellInfo(54741)] = L["Fire"], -- Firestarter
    [GetSpellInfo(11113)] = L["Fire"], -- Blast wave
    [GetSpellInfo(11366)] = L["Fire"], -- Pyroblast
    [GetSpellInfo(83582)] = L["Fire"], -- Pyromaniac
    [GetSpellInfo(22959)] = L["Fire"], -- Critical Mass
    [GetSpellInfo(11113)] = L["Fire"], -- Blast Wave
    [GetSpellInfo(87023)] = L["Fire"], -- Cauterize
    [GetSpellInfo(11426)] = L["Frost"], -- Ice Barrier
    [GetSpellInfo(44572)] = L["Frost"], -- Deep Freeze
    [GetSpellInfo(31687)] = L["Frost"], -- Summon Water Elemental
    [GetSpellInfo(55080)] = L["Frost"], -- Shattered Barrier (R1)
    [GetSpellInfo(83073)] = L["Frost"], -- Shattered Barrier (R2)
    [GetSpellInfo(44544)] = L["Frost"], -- Fingers of Frost
    [GetSpellInfo(57761)] = L["Frost"], -- Brain Freeze
    [GetSpellInfo(92283)] = L["Frost"], -- Frostfire Orb
    [GetSpellInfo(44544)] = L["Frost"], -- Fingers of Frost
    [GetSpellInfo(12472)] = L["Frost"], -- Icy Veins
    [GetSpellInfo(11958)] = L["Frost"], -- Cold Snap
    [GetSpellInfo(63095)] = L["Frost"], -- Ice Barrier (Glyph)
    --
    [GetSpellInfo(20473)] = L["Holy"], -- Holy Shock
    [GetSpellInfo(53563)] = L["Holy"], -- Beacon of Light
    [GetSpellInfo(31842)] = L["Holy"], -- Divine Favor
    [GetSpellInfo(43741)] = L["Holy"], -- Light's Grace
    [GetSpellInfo(53657)] = L["Holy"], -- Judgements of the Pure
    [GetSpellInfo(53656)] = L["Holy"], -- Judgements of the Pure
    [GetSpellInfo(53655)] = L["Holy"], -- Judgements of the Pure
    [GetSpellInfo(54149)] = L["Holy"], -- Infusion of Light
    [GetSpellInfo(85222)] = L["Holy"], -- Light of Dawn
    [GetSpellInfo(31821)] = L["Holy"], -- Aura Mastery
    [GetSpellInfo(20050)] = L["Holy"], -- Conviction
    [GetSpellInfo(85497)] = L["Holy"], -- Speed of Light
    [GetSpellInfo(88819)] = L["Holy"], -- Daybreak
    [GetSpellInfo(85509)] = L["Holy"], -- Denounce
    [GetSpellInfo(20925)] = L["Protection"], -- Holy Shield
    [GetSpellInfo(31935)] = L["Protection"], -- Avenger's Shield
    [GetSpellInfo(53595)] = L["Protection"], -- Hammer of the Righteous
    [GetSpellInfo(68055)] = L["Protection"], -- Judgements of the Just
    [GetSpellInfo(20132)] = L["Protection"], -- Redoubt
    [GetSpellInfo(20131)] = L["Protection"], -- Redoubt
    [GetSpellInfo(20128)] = L["Protection"], -- Redoubt
    [GetSpellInfo(31850)] = L["Protection"], -- Ardent Defender
    [GetSpellInfo(63529)] = L["Protection"], -- Dazed - Avenger's Shield (debuff)
    [GetSpellInfo(85416)] = L["Protection"], -- Grand Crusader
    [GetSpellInfo(53600)] = L["Protection"], -- Shield of the Righteous
    [GetSpellInfo(20177)] = L["Protection"], -- Reckoning
    [GetSpellInfo(85433)] = L["Protection"], -- Sacred Duty
    [GetSpellInfo(70940)] = L["Protection"], -- Divine Guardian
    [GetSpellInfo(26017)] = L["Protection"], -- Vindication (debuff)
    [GetSpellInfo(35395)] = L["Retribution"], -- Crusader Strike
    [GetSpellInfo(53385)] = L["Retribution"], -- Divine Storm
    [GetSpellInfo(20066)] = L["Retribution"], -- Repentance
    [GetSpellInfo(59578)] = L["Retribution"], -- The Art of War
    [GetSpellInfo(85256)] = L["Retribution"], -- Templar's Verdict
    [GetSpellInfo(85696)] = L["Retribution"], -- Zealotry
    [GetSpellInfo(87173)] = L["Retribution"], -- Long Arm of the Law
    [GetSpellInfo(96263)] = L["Retribution"], -- Sacred Shield
    [GetSpellInfo(85673)] = L["Retribution"], -- Word of Glory
    --
    [GetSpellInfo(10060)] = L["Discipline"], -- Power Infusion
    [GetSpellInfo(33206)] = L["Discipline"], -- Pain Suppression
    [GetSpellInfo(45242)] = L["Discipline"], -- Focused Will
    [GetSpellInfo(45241)] = L["Discipline"], -- Focused Will
    [GetSpellInfo(47753)] = L["Discipline"], -- Divine Aegis
    [GetSpellInfo(47930)] = L["Discipline"], -- Grace (R1)
    [GetSpellInfo(77613)] = L["Discipline"], -- Grace (R2)
    [GetSpellInfo(59889)] = L["Discipline"], -- Borrowed Time
    [GetSpellInfo(59888)] = L["Discipline"], -- Borrowed Time
    [GetSpellInfo(59887)] = L["Discipline"], -- Borrowed Time
    [GetSpellInfo(89485)] = L["Discipline"], -- Inner Focus
    [GetSpellInfo(62618)] = L["Discipline"], -- Power Word: Barrier
    [GetSpellInfo(96267)] = L["Discipline"], -- Strength of Soul
    [GetSpellInfo(96266)] = L["Discipline"], -- Strength of Soul
    [GetSpellInfo(81751)] = L["Discipline"], -- Attonement (Heal)
    [GetSpellInfo(34861)] = L["Holy"], -- Circle of Healing
    [GetSpellInfo(724)] = L["Holy"], -- Lightwell
    [GetSpellInfo(7001)] = L["Holy"], -- Lightwell Heal
    [GetSpellInfo(33143)] = L["Holy"], -- Blessed Resilience
    [GetSpellInfo(65081)] = L["Holy"], -- Body and Soul
    [GetSpellInfo(64128)] = L["Holy"], -- Body and Soul
    [GetSpellInfo(63735)] = L["Holy"], -- Serendipity
    [GetSpellInfo(63731)] = L["Holy"], -- Serendipity
    [GetSpellInfo(47788)] = L["Holy"], -- Guardian Spirit
    [GetSpellInfo(27827)] = L["Holy"], -- Spirit of Redemption
    [GetSpellInfo(14751)] = L["Holy"], -- Chakra
    [GetSpellInfo(81206)] = L["Holy"], -- Chakra: Sanctuary
    [GetSpellInfo(81209)] = L["Holy"], -- Chakra: Chastise
    [GetSpellInfo(81208)] = L["Holy"], -- Chakra: Serenity
    [GetSpellInfo(89912)] = L["Holy"], -- Chakra: Flow
    [GetSpellInfo(88625)] = L["Holy"], -- Chastise (cast)
    [GetSpellInfo(15473)] = L["Shadow"], -- Shadowform
    [GetSpellInfo(34914)] = L["Shadow"], -- Vampiric Touch
    [GetSpellInfo(33198)] = L["Shadow"], -- Misery
    [GetSpellInfo(33197)] = L["Shadow"], -- Misery
    [GetSpellInfo(33196)] = L["Shadow"], -- Misery
    [GetSpellInfo(64044)] = L["Shadow"], -- Psychic Horror
    [GetSpellInfo(47585)] = L["Shadow"], -- Dispersion
    [GetSpellInfo(15286)] = L["Shadow"], -- Vampiric Embrace
    [GetSpellInfo(15487)] = L["Shadow"], -- Silence
    [GetSpellInfo(77487)] = L["Shadow"], -- Shadow orb
    [GetSpellInfo(81292)] = L["Shadow"], -- Mind Melt
    [GetSpellInfo(87532)] = L["Shadow"], -- Shadowy Apparition
    [GetSpellInfo(49868)] = L["Shadow"], -- Mind Quickening
    [GetSpellInfo(87204)] = L["Shadow"], -- Sin and Punishment (Horror)
    --
    [GetSpellInfo(1329)] = L["Assassination"], -- Mutilate
    [GetSpellInfo(58427)] = L["Assassination"], -- Overkill (buff after stealth)
    [GetSpellInfo(58426)] = L["Assassination"], -- Overkill
    [GetSpellInfo(60177)] = L["Assassination"], -- Hunger For Blood
    [GetSpellInfo(52910)] = L["Assassination"], -- Turn the Tables
    [GetSpellInfo(52915)] = L["Assassination"], -- Turn the Tables
    [GetSpellInfo(52914)] = L["Assassination"], -- Turn the Tables
    [GetSpellInfo(14177)] = L["Assassination"], -- Cold Blood
    [GetSpellInfo(79140)] = L["Assassination"], -- Vendetta
    [GetSpellInfo(93068)] = L["Assassination"], -- Master Poisoner
    [GetSpellInfo(13750)] = L["Combat"], -- Adrenaline Rush
    [GetSpellInfo(51690)] = L["Combat"], -- Killing Spree
    [GetSpellInfo(58683)] = L["Combat"], -- Savage Combat
    [GetSpellInfo(58684)] = L["Combat"], -- Savage Combat
    [GetSpellInfo(13877)] = L["Combat"], -- Blade Flurry
    [GetSpellInfo(31125)] = L["Combat"], -- Blade Twisting (debuff)
    [GetSpellInfo(84748)] = L["Combat"], -- Bandith's Guile (debuff)
    [GetSpellInfo(51680)] = L["Combat"], -- Throwing Specialization
    [GetSpellInfo(84617)] = L["Combat"], -- Revealing Strike
    [GetSpellInfo(84745)] = L["Combat"], -- Shallow Insight
    [GetSpellInfo(36554)] = L["Subtlety"], -- Shadowstep
    [GetSpellInfo(36563)] = L["Subtlety"], -- Shadowstep
    [GetSpellInfo(51713)] = L["Subtlety"], -- Shadow Dance
    [GetSpellInfo(14183)] = L["Subtlety"], -- Premeditation
    [GetSpellInfo(45182)] = L["Subtlety"], -- Cheat Death
    [GetSpellInfo(51693)] = L["Subtlety"], -- Waylay
    [GetSpellInfo(31666)] = L["Subtlety"], -- Master of Subtlety
    [GetSpellInfo(16511)] = L["Subtlety"], -- Hemorrhage
    [GetSpellInfo(51698)] = L["Subtlety"], -- Honor Among Thieves
    [GetSpellInfo(45182)] = L["Subtlety"], -- Cheat Death
    [GetSpellInfo(14185)] = L["Subtlety"], -- Preparation
    [GetSpellInfo(31666)] = L["Subtlety"], -- Master of Subtlety
    --
    [GetSpellInfo(77746)] = L["Elemental"], -- Totem Wrath
    [GetSpellInfo(51490)] = L["Elemental"], -- Thunderstorm
    [GetSpellInfo(16166)] = L["Elemental"], -- Elemental Mastery
    [GetSpellInfo(64695)] = L["Elemental"], -- Earthgrab (debuff)
    [GetSpellInfo(52179)] = L["Elemental"], -- Astral Shift
    [GetSpellInfo(51470)] = L["Elemental"], -- Elemental Oath (R2)
    [GetSpellInfo(51466)] = L["Elemental"], -- Elemental Oath (R1)
    [GetSpellInfo(61882)] = L["Elemental"], -- Knockdown
    [GetSpellInfo(16246)] = L["Elemental"], -- Clearcasting
    [GetSpellInfo(51480)] = L["Elemental"], -- Lava Flows R1
    [GetSpellInfo(51481)] = L["Elemental"], -- Lava Flows
    [GetSpellInfo(51482)] = L["Elemental"], -- Lava Flows
    [GetSpellInfo(65264)] = L["Elemental"], -- Lava Flows
    [GetSpellInfo(17364)] = L["Enhancement"], -- Stormstrike
    [GetSpellInfo(60103)] = L["Enhancement"], -- Lava Lash
    [GetSpellInfo(30823)] = L["Enhancement"], -- Shamanistic Rage
    [GetSpellInfo(53817)] = L["Enhancement"], -- Maelstrom Weapon
    [GetSpellInfo(51533)] = L["Enhancement"], -- Feral Spirit
    [GetSpellInfo(97620)] = L["Enhancement"], -- Seasoned Winds (Nature, buff)
    [GetSpellInfo(97619)] = L["Enhancement"], -- SW (Frost)
    [GetSpellInfo(97621)] = L["Enhancement"], -- SW (Arcane)
    [GetSpellInfo(97622)] = L["Enhancement"], -- SW (Shadow)
    [GetSpellInfo(97618)] = L["Enhancement"], -- SW (Fire)
    [GetSpellInfo(63685)] = L["Enhancement"], -- Freeze (debuff)
    [GetSpellInfo(974)] = L["Restoration"], -- Earth Shield
    [GetSpellInfo(61295)] = L["Restoration"], -- Riptide
    [GetSpellInfo(51886)] = L["Restoration"], -- Cleanse Spirit
    [GetSpellInfo(16190)] = L["Restoration"], -- Mana Tide Totem
    [GetSpellInfo(53390)] = L["Restoration"], -- Tidal Waves
    [GetSpellInfo(31616)] = L["Restoration"], -- Nature's Guardian
    [GetSpellInfo(16236)] = L["Restoration"], -- Ancestral Fortitude (buff)
    [GetSpellInfo(16188)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(98008)] = L["Restoration"], -- Soul Link Totem
    [GetSpellInfo(51564)] = L["Restoration"], -- Tidal Waves
    [GetSpellInfo(51562)] = L["Restoration"], -- Tidal Waves
    [GetSpellInfo(51563)] = L["Restoration"], -- Tidal Waves
    [GetSpellInfo(105284)] = L["Restoration"], -- Ancestral Vigor
    [GetSpellInfo(51945)] = L["Restoration"], -- Earthliving
    [GetSpellInfo(52752)] = L["Restoration"], -- Ancestral Awakening (SPELL_HEAL)

    --
    [GetSpellInfo(30108)] = L["Affliction"], -- Unstable Affliction
    [GetSpellInfo(48181)] = L["Affliction"], -- Haunt
    [GetSpellInfo(64371)] = L["Affliction"], -- Eradication (R3)
    [GetSpellInfo(64370)] = L["Affliction"], -- Eradication (R2)
    [GetSpellInfo(64368)] = L["Affliction"], -- Eradication (R1)
    [GetSpellInfo(18223)] = L["Affliction"], -- Curse of Exhaustion (cast)
    [GetSpellInfo(86121)] = L["Affliction"], -- Soul Swap (cast)
    [GetSpellInfo(17941)] = L["Affliction"], -- Shadow Trance (buff)
    [GetSpellInfo(31117)] = L["Affliction"], -- Unstable Affliction (Silence)
    [GetSpellInfo(60947)] = L["Affliction"], -- Nightmare (debuff)
    [GetSpellInfo(32386)] = L["Affliction"], -- Shadow Embrace (debuff)
    [GetSpellInfo(47193)] = L["Demonology"], -- Demonic Empowerment
    [GetSpellInfo(63167)] = L["Demonology"], -- Decimation (R2)
    [GetSpellInfo(63165)] = L["Demonology"], -- Decimation (R1)
    [GetSpellInfo(30146)] = L["Demonology"], -- Summon Felguard
    [GetSpellInfo(47241)] = L["Demonology"], -- Metamorphosis Buff
    [GetSpellInfo(59672)] = L["Demonology"], -- Metamorphosis Cast
    [GetSpellInfo(53646)] = L["Demonology"], -- Demonic Pact (buff)
    [GetSpellInfo(71521)] = L["Demonology"], -- Hand of Gul'dan
    [GetSpellInfo(47383)] = L["Demonology"], -- Molten Core (buff)
    [GetSpellInfo(84740)] = L["Demonology"], -- Demonic Knowledge
    [GetSpellInfo(17962)] = L["Destruction"], -- Conflagrate
    [GetSpellInfo(30283)] = L["Destruction"], -- Shadowfury
    [GetSpellInfo(50796)] = L["Destruction"], -- Chaos bolt
    [GetSpellInfo(54277)] = L["Destruction"], -- Backdraft
    [GetSpellInfo(54276)] = L["Destruction"], -- Backdraft
    [GetSpellInfo(54274)] = L["Destruction"], -- Backdraft
    [GetSpellInfo(34936)] = L["Destruction"], -- Backlash
    [GetSpellInfo(85383)] = L["Destruction"], -- Improved Soulfire (buff)
    [GetSpellInfo(17877)] = L["Destruction"], -- Shadowburn (cast)
    [GetSpellInfo(29341)] = L["Destruction"], -- Shadowburn (buff)
    [GetSpellInfo(79621)] = L["Destruction"], -- burning ember (debuff)
    [GetSpellInfo(91711)] = L["Destruction"], -- Nether Ward (buff)
    [GetSpellInfo(54375)] = L["Destruction"], -- Nether Protection (Nature)
    [GetSpellInfo(54372)] = L["Destruction"], -- NP (Frost)
    [GetSpellInfo(54371)] = L["Destruction"], -- NP (Fire)
    [GetSpellInfo(54370)] = L["Destruction"], -- NP (Holy)
    [GetSpellInfo(54374)] = L["Destruction"], -- NP (Shadow)
    [GetSpellInfo(54373)] = L["Destruction"], -- NP (Arcane)
    [GetSpellInfo(47283)] = L["Destruction"], -- Empowered Imp (buff)
    [GetSpellInfo(80240)] = L["Destruction"], -- Bane of Havoc (cast/debuff)
    --
    [GetSpellInfo(12294)] = L["Arms"], -- Mortal strike
    [GetSpellInfo(46924)] = L["Arms"], -- Bladestorm
    [GetSpellInfo(29842)] = L["Arms"], -- Second Wind (R2)
    [GetSpellInfo(29841)] = L["Arms"], -- Second Wind (R1)
    [GetSpellInfo(65156)] = L["Arms"], -- Juggernaut (buff)
    [GetSpellInfo(64976)] = L["Arms"], -- Juggernaut
    [GetSpellInfo(52437)] = L["Arms"], -- Sudden Death
    [GetSpellInfo(46857)] = L["Arms"], -- Trauma (debuff)
    [GetSpellInfo(60503)] = L["Arms"], -- Taste for Blood
    [GetSpellInfo(23694)] = L["Arms"], -- Improved Harmstring
    [GetSpellInfo(85730)] = L["Arms"], -- Deadly Calm
    [GetSpellInfo(30070)] = L["Arms"], -- Blood Frenzy (debuff)
    [GetSpellInfo(84584)] = L["Arms"], -- Slaughter
    [GetSpellInfo(57518)] = L["Arms"], -- Enrage
    [GetSpellInfo(85388)] = L["Arms"], -- Throwdown
    [GetSpellInfo(23881)] = L["Fury"], -- Bloodthirst
    [GetSpellInfo(60970)] = L["Fury"], -- Heroic Fury
    [GetSpellInfo(56112)] = L["Fury"], -- Furious Attacks
    [GetSpellInfo(46916)] = L["Fury"], -- Bloodsurge
    [GetSpellInfo(12966)] = L["Fury"], -- Flurry
    [GetSpellInfo(12292)] = L["Fury"], -- Death Wish
    [GetSpellInfo(12880)] = L["Fury"], -- Enrage
    [GetSpellInfo(85386)] = L["Fury"], -- Die by the Sword
    [GetSpellInfo(85288)] = L["Fury"], -- Raging Blow
    [GetSpellInfo(29801)] = L["Fury"], -- Rampage
    [GetSpellInfo(60970)] = L["Fury"], -- Heroic Fury
    [GetSpellInfo(56112)] = L["Fury"], -- Furious Attacks
    [GetSpellInfo(85738)] = L["Fury"], -- Meat Cleaver
    [GetSpellInfo(46916)] = L["Fury"], -- Bloodsurge (aura)
    [GetSpellInfo(20243)] = L["Protection"], -- Devastate
    [GetSpellInfo(46968)] = L["Protection"], -- Shockwave
    [GetSpellInfo(50720)] = L["Protection"], -- Vigilance
    [GetSpellInfo(46947)] = L["Protection"], -- Safeguard (R2)
    [GetSpellInfo(46946)] = L["Protection"], -- Safeguard (R1)
    [GetSpellInfo(50227)] = L["Protection"], -- Sword and Board
    [GetSpellInfo(12976)] = L["Protection"], -- Last Stand (buff)
    [GetSpellInfo(57514)] = L["Protection"], -- Enrage (buff)
    [GetSpellInfo(46945)] = L["Protection"], -- Safeguard (cast)
    [GetSpellInfo(50227)] = L["Protection"], -- Sword and board (buff)
    [GetSpellInfo(12809)] = L["Protection"], -- Concussion blow (debuff)
}

--[[local specSpellsOld = {
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
    [GetSpellInfo(59672)] = L["Demonology"], -- Metamorphosis
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
    [GetSpellInfo(50516)] = L["Balance"], -- Typhoon
    [GetSpellInfo(24858)] = L["Balance"], -- Moonkin Form
    [GetSpellInfo(48566)] = L["Feral"], -- Mangle (Cat)
    [GetSpellInfo(48564)] = L["Feral"], -- Mangle (Bear)
    [GetSpellInfo(50334) .. " Feral"] = L["Feral"], -- Berserk
    [GetSpellInfo(18562)] = L["Restoration"], -- Swiftmend
    [GetSpellInfo(17116)] = L["Restoration"], -- Nature's Swiftness
    [GetSpellInfo(33891)] = L["Restoration"], -- Tree of Life
    [GetSpellInfo(53251)] = L["Restoration"], -- Wild Growth
}]]
function Gladdy:GetSpecSpells()
    return specSpells
end

local importantAuras = {
    --- Crowd control
    [33786] = { -- Cyclone
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 33786 },
    },
    [2637] = { -- Hibernate
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 2637 },
    },
    [6770] = { -- Sap
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 6770 },
    },
    [2094] = { -- Blind
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 2094 },
    },
    [5782] = { -- Fear
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5782 },
    },
    [6789] = { -- Death Coil Warlock
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 6789 },
    },
    [6358] = { -- Seduction
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 6358 },
    },
    [5484] = { -- Howl of Terror
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5484 },
    },
    [5246] = { -- Intimidating Shout
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5246 },
    },
    [8122] = { -- Psychic Scream
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 8122 },
    },
    [64044] = { -- Psychic Horror
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 64044 },
    },
    [118] = { -- Polymorph
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 118 },
        texture = 136071,
    },
    [51514] = { -- Hex
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 51514 },
    },
    [710] = { -- Banish
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 710 },
    },
    [605] = { -- Mind Control
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 605 },
    },
    [1513] = { -- Scare Beast
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 1513 },
    },

    --- Roots
    [87193] = { -- Paralysis
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 87193 },
    },

    [83302] = { -- Improved Cone of Cold
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 83302 },
    },

    -- Entangling Roots
    [339] = {
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 339 },
    },

    [122] = { -- Frost Nova
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 122 },
    },
    [33395] = { -- Freeze (Water Elemental)
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 33395 },
    },
    [55080] = { -- Shattered Barrier
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 83073 },
    },
    [16979] = { -- Feral Charge
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 16979 },
    },
    [23694] = { -- Improved Hamstring
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 23694 },
    },
    [4167] = { -- Web (Hunter Pet)
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 4167 },
    },
    [47168] = { -- Improved Wingclip
        track = AURA_TYPE_DEBUFF,
        priority = 30,
        spellIDs = { 47168 },
    },

    --- Stuns and incapacitates
    [87204] = { -- Sin and Punishment
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 87204 },
    },

    [90337] = { -- Bad Manner
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 90337 },
    },

    [88625] = { -- Holy Word: Chastise
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 88625 },
    },

    [85388] = { -- Throwdown
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 85388 },
    },

    [89766] = { -- Axe Toss (Felguard)
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 89766 },
    },

    [82691] = { -- Ring of Frost
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 82691 },
    },

    [91797] = { --  Monstrous Blow (Dark Transformation)
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 91797 },
    },

    [93986] = { -- Aura of Foreboding
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 93986 },
    },

    [5211] = { -- Bash
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 5211 },
    },
    [1833] = { -- Cheap Shot
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 1833 },
    },
    [408] = { -- Kidney Shot
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 408 },
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
        spellIDs = { 19386 },
    },
    [19503] = { -- Scatter Shot
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 19503 },
    },
    [9005] = { -- Pounce
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 9005 },
    },
    [22570] = { -- Maim
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 22570 },
    },
    [853] = { -- Hammer of Justice
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 853 },
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
        spellIDs = { 30283 },
    },

    [20549] = { -- War Stomp
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 20549 },
    },
    [7922] = { -- Charge Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 7922 },
        texture = 135860
    },
    [20253] = { -- Intercept Stun
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 20253 },
        texture = 135860
    },
    [12809] = { -- Concussion Blow
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 12809 },
    },
    [12355] = { -- Impact
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 12355 },
    },
    [19577] = {-- Intimidation
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 19577 },
    },
    [31661] = { -- Dragon's Breath
        track = AURA_TYPE_DEBUFF,
        priority = 40,
        spellIDs = { 31661 },
    },

    --- Silences
    [81261] = { -- Solar Beam
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 81261 },
    },

    [31935] = { -- Avenger's Shield
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 31935 },
    },

    [93985] = { -- Skull Bash
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 93985 },
    },

    [18469] = { -- Improved Counterspell
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 18469 },
    },
    [15487] = { -- Silence
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 15487 },
    },
    [34490] = { -- Silencing Shot
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 34490 },
    },
    [18425] = { -- Improved Kick
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 18425 },
    },
    [47476] = { -- Strangulate
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 47476 },
    },
    [18498] = { -- Silenced - Gag Order
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 18498 },
    },
    [31117] = { -- Unstable Affliction Silence (GetSpellInfo returns "Unstable Affliction")
        track = AURA_TYPE_DEBUFF,
        altName = select(1, GetSpellInfo(31117)) .. " Silence",
        priority = 20,
        spellIDs = { 31117 },
    },
    [24259] = { -- Spell Lock (Felhunter)
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 24259 },
    },
    [28730] = { -- Arcane Torrent
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 28730 },
    },
    [1330] = { -- Garrote - Silence
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 1330 },
    },

    --- Disarms
    [676] = { -- Disarm
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 676 },
    },
    [51722] = { -- Dismantle
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 51722 },
    },
    [64058] = { -- Psychic Horror Disarm
        track = AURA_TYPE_DEBUFF,
        priority = 20,
        spellIDs = { 64058 },
    },

    --- Buffs
    [55233] = { -- Vampiric Blood
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 55233 },
    },
    [61336] = { -- Survival Instincts
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 61336 },
    },
    [70940] = { -- Divine Guardian
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 70940 },
    },
    [96263] = { -- Sacred Shield
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 96263 },
    },
    [86669] = { -- Guardian
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 86669, 86659, 86698 },
    },
    [89485] = { -- Inner Focus
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 89485 },
    },
    [46946] = { -- Safeguard
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 46946 },
    },
    [1022] = { -- Hand of Protection
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 1022 },
    },
    [1044] = { -- Hand of Freedom
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 1044 },
    },
    [6940] = { -- Hand of Sacrifice
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 6940 },
    },
    [64205] = { -- Divine Sacrifice
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 64205 },
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
        priority = 20,
        spellIDs = { 32182 },
    },
    [80353] = { -- Time Warp
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 80353 },
    },
    [33206] = { -- Pain Suppression
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 33206 },
    },
    [29166] = { -- Innervate
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 29166 },
    },
    [18708] = { -- Fel Domination
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 18708 },
    },
    [54428] = { -- Divine Plea
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 54428 },
    },
    [31821] = { -- Aura mastery
        track = AURA_TYPE_BUFF,
        priority = 21,
        spellIDs = { 31821 },
    },
    [51713] = { -- Shadow Dance
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 51713 },
    },
    [12292] = { -- Death Wish
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 12292 },
    },
    [23920] = { -- Spell Reflection
        track = AURA_TYPE_BUFF,
        priority = 40,
        spellIDs = { 23920 },
    },
    [6346] = {-- Fear Ward
        track = AURA_TYPE_BUFF,
        priority = 9,
        spellIDs = { 6346 },
    },
    [50334] = {-- Berserk
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 50334 },
    },
    [46924] = { -- Bladestorm
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 46924 },
    },
    [79206] = { -- Spiritwalker's Grace
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 79206 },
    },

    --- Turtling abilities
    [47788] = { -- Guardian Spirit
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 47788 },
    },
    [98008] = { -- Spirit Link Totem
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 98008 },
    },
    [53480] = { -- Roar of Sacrifice
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 53480 },
    },
    [62618] = { -- Shield Wall
        track = AURA_TYPE_BUFF,
        priority = 25,
        spellIDs = { 62618 },
    },
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
    [5277] = { -- Evasion
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 5277 },
    },
    [87023] = { -- Cauterize
        track = AURA_TYPE_BUFF,
        priority = 10,
        spellIDs = { 87023 },
    },

    --- Immunities
    [34471] = { -- The Beast Within (CC Immune)
        track = AURA_TYPE_BUFF,
        priority = 20,
        spellIDs = { 34471 },
    },
    [45438] = { -- Ice Block
        track = AURA_TYPE_BUFF,
        priority = 30,
        spellIDs = { 45438 },
    },
    [41425] = { -- Hypothermia (Ice Block Immune
        track = AURA_TYPE_DEBUFF,
        priority = 8,
        spellIDs = { 41425 },
    },
    [642] = { -- Divine Shield
        track = AURA_TYPE_BUFF,
        priority = 30,
        spellIDs = { 642 },
    },
    [18499] = { -- Berserker Rage (Flee Immune)
        track = AURA_TYPE_BUFF,
        priority = 30,
        spellIDs = { 18499 },
    },
    [1719] = { -- Recklessness (Flee Immune)
        track = AURA_TYPE_BUFF,
        priority = 30,
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
    [49039] = { -- Lichborne
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 49039 },
    },
    --- Alt Stuff
    [34709] = { -- Shadowsight Buff
        track = AURA_TYPE_DEBUFF,
        duration = 15,
        priority = 9,
        spellIDs = { 34709 },
        magic = true,
    },
    [8178] = { -- Grounding Totem Effect
        track = AURA_TYPE_BUFF,
        duration = 0,
        priority = 15,
        spellIDs = { 8178 }
    },
    [5024] = { -- Flee (Skull of impending Doom) -- 5024
        track = AURA_TYPE_BUFF,
        priority = 15,
        spellIDs = { 5024 },
        altName = select(1, GetSpellInfo(5024)) .. " - " .. (select(1, GetItemInfo(4984)) or "Skull of Impending Doom"),
    },
}

function Gladdy:GetImportantAuras()
    return importantAuras
end

local interrupts = {
    [GetSpellInfo(79870)] = { duration = 4, spellID = 79870, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(79870)), priority = 15 }, -- Feral Charge Effect (Druid)
    [GetSpellInfo(2139)] = { duration = 7, spellID = 2139, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(2139)), priority = 15 }, -- Counterspell (Mage)
    [GetSpellInfo(1766)] = { duration = 5, spellID = 1766, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(1766)), priority = 15 }, -- Kick (Rogue)
    [GetSpellInfo(6552)] = { duration = 4, spellID = 6552, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(6552)), priority = 15 }, -- Pummel (Warrior)
    [GetSpellInfo(57994)] = { duration = 2, spellID = 57994, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(57994)), priority = 15 }, -- Wind Shear (Shaman)
    [GetSpellInfo(19647)] = { duration = 6, spellID = 19647, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(19647)), priority = 15 }, -- Spell Lock (Warlock
    [GetSpellInfo(47528)] = { duration = 4, spellID = 47528, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(47528)), priority = 15 }, -- Mind Freeze (Deathknight)
    [GetSpellInfo(96231)] = { duration = 4, spellID = 96231, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(96231)), priority = 15 }, -- Rebuke (Paladin)
    [GetSpellInfo(91807)] = { duration = 2, spellID = 91807, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(91807)), priority = 15 }, -- Shambling Rush (DK pet)
    [GetSpellInfo(80964)] = { duration = 4, spellID = 80964, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(80964)), priority = 15 }, -- Skull Bash (Bear)
    [GetSpellInfo(80965)] = { duration = 2, spellID = 80965, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(80965)), priority = 15 }, -- Skull Bash (Cat)
    [GetSpellInfo(31935)] = { duration = 3, spellID = 31935, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(31935)), priority = 15 }, -- Avenger's Shield (Paladin)
    [GetSpellInfo(34490)] = { duration = 3, spellID = 34490, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(34490)), priority = 15 }, -- Silencing Shot (Hunter)
    [GetSpellInfo(26090)] = { duration = 2, spellID = 26090, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(26090)), priority = 15 }, -- Pummel (Hunter Pet)
    [GetSpellInfo(97547)] = { duration = 5, spellID = 97547, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(97547)), priority = 15 }, -- Solar Beam (Druid)
    [GetSpellInfo(51680)] = { duration = 3, spellID = 51680, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(51680)), priority = 15 }, -- Throwing Specialization (Rogue)
    [GetSpellInfo(93985)] = { duration = 4, spellID = 93985, track = AURA_TYPE_DEBUFF, texture = select(3, GetSpellInfo(93985)), priority = 15 }, -- Skull Bash
}
function Gladdy:GetInterrupts()
    return interrupts
end

local cooldownList = {
    -- Spell Name			   Cooldown[, Spec]
    -- Mage
    ["MAGE"] = {
        [1953] = 15, -- Blink
        [82731] = 60, -- Fire Orb
        [543] = 30, -- Mage Ward
        [80353] = 300, -- Time Warp
        [2139] = 24, -- Counterspell
        [55342] = 180, -- Mirror Image
        [12051] = 240, -- Evocation
        [82676] = 150, -- Ring of Frost
        [45438] = { cd = 300, [L["Frost"]] = 240, }, -- Ice Block
        [120] = { cd = 10, [L["Frost"]] = 8, }, -- Cone of Cold
        [11426] = { cd = 30, [L["Frost"]] = 24, }, -- Ice Barrier
        [122] = { cd = 25, [L["Frost"]] = 20, }, -- Frost Nova
        [44425] = { cd = 4, spec = L["Arcane"], }, -- Arcane Barrage
        [44572] = { cd = 30, spec = L["Frost"], }, -- Deep Freeze
        [12472] = { cd = 180, spec = L["Frost"], }, -- Icy Veins
        [31687] = { cd = 180, spec = L["Frost"], }, -- Summon Water Elemental
        [12043] = { cd = 120, spec = L["Arcane"], }, -- Presence of Mind
        [12042] = { cd = 120, spec = L["Arcane"], }, -- Arcane Power
        [11113] = { cd = 15, spec = L["Fire"] }, -- Blast Wave
        [31661] = { cd = 20, spec = L["Fire"] }, -- Dragon's Breath
        [11129] = { cd = 120, spec = L["Fire"] }, -- Combustion
        [11958] = { cd = 480, spec = L["Frost"], -- Coldsnap
                    resetCD = {
                        [12472] = true,
                        [45438] = true,
                        [42917] = true,
                        [31687] = true,
                        [44572] = true,
                        [120] = true,
                        [31687] = true,
                        [122] = true,
                        [11426] = true,
                    },
        },
    },

    -- Priest
    ["PRIEST"] = {
        [8122] = { cd = 27, [L["Shadow"]] = 26, }, -- Psychic Scream
        [34433] = { cd = 300, [L["Shadow"]] = 240, }, -- Shadowfiend
        [15487] = { cd = 45, spec = L["Shadow"], }, -- Silence
        [15473] = { cd = 1.5, spec = L["Shadow"], }, -- Shadowform
        [64044] = { cd = 90, spec = L["Shadow"], }, -- Psychic Horror (+ Glyph) else 120
        [586] = { cd = 30, [L["Shadow"]] = 15, }, -- Fade (+ Glyph) else 24
        [33076] = 10, -- Prayer of Mending
        [73325] = 90, -- Leap of Faith
        [64843] = { cd = 640, [L["Holy"]] = 180, },  -- Divine Hymn
        [64901] = 360, -- Hymn of Hope
        [32379] = 10, -- Shadow Word: Death
        [6346] = 180, -- Fear Ward
        [81700] = 30, -- Archangel
        [87153] = 90, -- Dark Archangel
        [47585] = { cd = 75, spec = L["Shadow"], }, -- Dispersion (+ Glyph)
        [10060] = { cd = 120, spec = L["Discipline"], }, -- Power Infusion
        [33206] = { cd = 180, spec = L["Discipline"], }, -- Pain Suppression
        [62618] = { cd = 180, spec = L["Discipline"], }, -- Power Word: Barrier
        [47788] = { cd = 150, spec = L["Holy"], }, -- Guardian spirit (+ Glyph)
        [14751] = { cd = 30, spec = L["Holy"], }, -- Chakra
        [724] = { cd = 180, spec = L["Holy"], }, -- Lightwell
        [19236] = { cd = 120, spec = L["Holy"], }, -- Desperate Prayer
    },

    -- Death Knight
    ["DEATHKNIGHT"] = {
        [47476] = 120, -- Strangulate
        [47528] = 10, -- Mind Freeze
        [48707] = 45, -- Anti-Magic Shell
        [48792] = 180, -- Icebound Fortitude
        [49576] = { cd = 35, [L["Unholy"]] = 25, }, -- Death Grip
        [47568] = 300, -- Empower Rune Weapon
        [48743] = 120, -- Death Pact
        [49039] = 120, -- Lichborne
        [77575] = 60, -- Outbreak
        [77606] = 60, -- Dark Simulacrum
        [47481] = { cd = 60, spec = L["Unholy"], }, -- Pet Gnaw
        [51052] = { cd = 120, spec = L["Unholy"], }, -- Anti-Magic Zone
        [46584] = { cd = 120, notSpec = L["Unholy"], }, -- Raise Dead
        [49206] = { cd = 180, spec = L["Unholy"], }, -- Summon Gargoyle
        [49016] = { cd = 180, spec = L["Unholy"], }, -- Unholy Frenzy
        [49028] = { cd = 90, spec = L["Blood"], }, -- Dancing Rune Weapon
        [48982] = { cd = 30, spec = L["Blood"], }, -- Rune tap
        [55233] = { cd = 60, spec = L["Blood"], }, -- Vampiric Blood
        [49222] = { cd = 60, spec = L["Blood"], }, -- Bone Shield
        [49203] = { cd = 60, spec = L["Frost"], }, -- Hungering Cold
        [51271] = { cd = 60, spec = L["Frost"], }, -- Pillar of Frost
    },

    -- Druid
    ["DRUID"] = {
        [22812] = 60, -- Barkskin
        [29166] = 180, -- Innervate
        [5211] = 60, -- Bash
        [80964] = 60, -- Skull Bash
        [80965] = 60, -- Skull Bash
        [16689] = 60, -- Natures Grasp
        [77764] = 120, -- Stampeding Roar
        [77761] = 120, -- Stampeding Roar
        [22842] = 180, -- Frenzied Regeneration
        [48505] = { cd = 90, spec = L["Balance"], }, -- Starfall
        [16979] = { cd = 15, spec = L["Feral"], }, -- Feral Charge(Bear)
        [49376] = { cd = 30, spec = L["Feral"], }, -- Feral Charge(Cat)
        [61336] = { cd = 180, spec = L["Feral"], }, -- Survival Instincts
        [50334] = { cd = 180, spec = L["Feral"], altName = GetSpellInfo(50334) .. " Feral" }, -- Berserk
        [17116] = { cd = 180, spec = L["Restoration"], }, -- Natures Swiftness
        [18562] = { cd = 15, spec = L["Restoration"], }, -- Swiftmend
        [33891] = { cd = 180, spec = L["Restoration"], }, -- Tree of Life
        [48438] = { cd = 8, spec = L["Restoration"], }, -- Wild's Growth
        [33831] = { cd = 180, spec = L["Balance"], }, -- Force of Nature
        [50516] = { cd = 20, spec = L["Balance"], }, -- Typhoon
        [88751] = { cd = 10, spec = L["Balance"], }, -- Wild Mushroom: Detonate
        [78675] = { cd = 60, spec = L["Balance"], }, -- Solar Beam
        [78674] = { cd = 15, spec = L["Balance"], }, -- Starsurge

    },

    -- Shaman
    ["SHAMAN"] = {
        [57994] = 15, -- Wind Shear
        [51514] = 45, -- Hex
        [8177] = 25, -- Grounding Totem
        [79206] = 120, -- Spiritwalker's Grace
        [1535] = 4, -- Fire nova
        [30823] = { cd = 60, spec = L["Enhancement"], }, -- Shamanistic Rage
        [61882] = { cd = 10, spec = L["Elemental"], }, -- Earthquake
        [16166] = { cd = 180, spec = L["Elemental"], }, -- Elemental Mastery
        [51490] = { cd = 45, spec = L["Elemental"], }, -- Thunderstorm
        [16188] = { cd = 120, spec = L["Restoration"], }, -- Natures Swiftness
        [51533] = { cd = 120, spec = L["Enhancement"], }, -- Feral Spirit
        [16190] = { cd = 180, spec = L["Restoration"], }, -- Mana Tide Totem
        [98008] = { cd = 180, spec = L["Restoration"], }, -- Spirit Link Totem
    },

    -- Paladin
    ["PALADIN"] = {
        [1022] = 300, -- Hand of Protection
        [1044] = 25, -- Hand of Freedom
        [54428] = 60, -- Divine Plea
        [6940] = 120, -- Hand of Sacrifice
        [2812] = 15, -- Holy Wrath
        [85673] = 20, -- World of Glory
        [64205] = 120, -- Divine Sacrifice
        [853] = 40, -- Hammer of Justice
        [81650] = 300, -- Guardian of the Ancient Kings
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
        [31842] = { cd = 180, spec = L["Holy"], }, -- Divine Favor
        [20473] = { cd = 6, spec = L["Holy"], }, -- Holy Shock
        [20066] = { cd = 60, spec = L["Retribution"], }, -- Repentance
        [31935] = { cd = 15, spec = L["Protection"], }, -- Avengers Shield
        [31850] = { cd = 180, spec = L["Protection"], }, -- Ardent Defender
        [70940] = { cd = 180, spec = L["Protection"], }, -- Divine Guardian
        [20925] = { cd = 30, spec = L["Protection"], }, -- Holy Shield
        [53595] = { cd = 4.5, spec = L["Protection"], }, -- Hammer of the Righteous
    },

    -- Warlock
    ["WARLOCK"] = {
        [5484] = 40, -- Howl of Terror (-8 if you use Glyph, so 32?)
        [6789] = 120, -- Death Coil
        [18708] = 180, -- Feldom
        [48020] = 30, -- Demonic Circle: Port
        [18540] = 600, -- Summon Doomguard
        [74434] = 45, -- Soulburn
        [19647] = { cd = 24, pet = true, }, -- Spell Lock
        [19505] = { cd = 15, pet = true, },  -- Devour Magic
        [47897] = 12,  -- Shadowflame (Shadow)
        [30283] = { cd = 20, spec = L["Destruction"], }, -- Shadowfury
        [17877] = { cd = 15, spec = L["Destruction"], }, -- Shadowburn
        [17962] = { cd = 10, spec = L["Destruction"], }, -- Conflagrate
        [50796] = { cd = 12, spec = L["Destruction"], }, -- Chaos Bolt (with glyph 10s)
        [91711] = { cd = 30, spec = L["Destruction"], }, -- Nether Ward
        [47241] = { cd = 180, spec = L["Demonology"], }, -- Metamorphosis
        [30151] = { cd = 15, spec = L["Demonology"], pet = true }, -- Pursuit
        [30213] = { cd = 6, spec = L["Demonology"], pet = true }, -- Legion Strike
        [89751] = { cd = 45, spec = L["Demonology"], pet = true }, -- Felstorm
        [89766] = { cd = 30, spec = L["Demonology"], pet = true }, -- Axe Toss
        [1122] = { cd = 600, spec = L["Demonology"], }, -- Inferno
        [71521] = { cd = 12, spec = L["Demonology"], }, -- Hand of Guldan
        [47193] = { cd = 60, spec = L["Demonology"], }, -- Demonic Empowerment
    },

    -- Warrior
    ["WARRIOR"] = {
        [6552] = { cd = 10 }, -- Pummel
        [18499] = 30, -- Berserker Rage
        [23920] = 10, -- Spell Reflection
        [3411] = 30, -- Intervene
        [20252] = { cd = 30, [L["Arms"]] = 20, }, -- Intercept
        [6544] = { cd = 60, [L["Arms"]] = 40, }, -- Heroic Leap
        [676] = 60, -- Disarm
        [5246] = 120, -- Intimidating Shout
        [2565] = 60, -- Shield Block
        [55694] = 180, -- Enraged Regeneration
        [20230] = 300, -- Retaliation
        [1719] = 300, -- Recklessness
        [871] = 300, -- Shield Wall
        [64382] = 300, -- Shattering Throw
        [86346] = 20, -- Colossus Smash
        [1134] = 30, -- Inner Rage
        [97462] = 180, -- Rallying Cry
        [12292] = { cd = 180, spec = L["Fury"], }, -- Death Wish
        [46924] = { cd = 90, spec = L["Arms"], }, -- Bladestorm
        [85388] = { cd = 45, spec = L["Arms"], }, -- Throwdown
        [85730] = { cd = 120, spec = L["Arms"], }, -- Deadly Calm
        [12328] = { cd = 60, spec = L["Arms"], }, -- Sweeping strikes
        [46968] = { cd = 20, spec = L["Protection"], }, -- Shockwave
        [12975] = { cd = 180, spec = L["Protection"], }, -- Last Stand
        [12809] = { cd = 30, spec = L["Protection"], }, -- Concussion Blow

    },

    -- Hunter
    ["HUNTER"] = {
        --[53548] 	= 28,    -- Crab Prin
        --[53562] 	= 40,    -- Ravager Stun

        [19503] = 30, -- Scatter Shot
        [19263] = 120, -- Deterrence (110 with Glyph)
        [781] = 15, -- Disengage
        [5384] = 30, -- Feign Death
        [77769] = 1.5, -- Trap Launcher
        [60192] = { cd = 30, [L["Survival"]] = 24, }, -- Freezing Trap Trap Launcher
        [82941] = { cd = 30, [L["Survival"]] = 24, }, -- Freezing Trap Trap Launcher
        [3045] = { cd = 300, [L["Marksmanship"]] = 180, }, -- Rapid Fire
        [1499] = { cd = 30, [L["Survival"]] = 24, -- Freezing Trap
                    sharedCD = {
                        [13809] = true, -- Ice Trap
                       [60192] = true, -- Trap Launcher Freezing trap
                       [82941] = true, -- Ice Trap (Trap Launcher)
                    },
        },
        [13809] = { cd = 30, [L["Survival"]] = 24,-- Ice Trap
                    sharedCD = {
                        [1499] = true, -- Freezing Trap
                        [60192] = true, -- Freezing trap (Trap Launcher)
                        [82941] = true, -- Ice Trap (Trap Launcher)
                    },
        },
        [82726] = { cd = 120, spec = L["Beast Mastery"] }, -- Fervor
        [82692] = { cd = 30, spec = L["Beast Mastery"] }, -- Focus Fire
        [34600] = { cd = 30, [L["Survival"]] = 24, }, -- Snake Trap
        [34490] = { cd = 20, spec = L["Marksmanship"], }, -- Silencing Shot
        [53209] = { cd = 10, spec = L["Marksmanship"], }, -- Chimera Shot
        [19386] = { cd = 60, spec = L["Survival"], }, -- Wyvern Sting
        [3674] = { cd = 30, spec = L["Survival"], }, -- Black Arrow
        [53271] = { cd = 45, pet = true, }, -- Masters Call
        [19577] = { cd = 60, pet = true, }, -- Intimidation
        [19574] = { cd = 120, pet = true, }, -- Bestial Wrath
        [51753] = 60, -- Camouflage
        [23989] = { cd = 180, spec = L["Marksmanship"], -- Readiness
                    resetCD = {
                        [19503] = true, -- Scatter Shot
                        [19263] = true, -- Deterrence
                        [781] = true, -- Disengage
                        [60192] = true, -- Freezing Trap
                        [1499] = true, -- Freezing Trap
                        [13809] = true, -- Frost Trap
                        [34600] = true, -- Snake Trap
                        [34490] = true, -- Silencing Shot
                        [53271] = true, -- Masters call
                        [19577] = true, -- Intimidation
                        [77769] = true, -- Trap Launcher
                        [51753] = true, -- Camouflage
                        [3045] = true, -- Rapid Fire
                        [53209] = true, -- Chimera Shot
                    },
        },
    },

    -- Rogue
    ["ROGUE"] = {
        [1766] = 10, -- Kick
        [408] = 20, -- Kidney Shot
        [5277] = 180, -- Evasion
        [31224] = 60, -- Cloak of Shadow
        [1856] = 180, -- Vanish
        [2094] = 180, -- Blind
        [51722] = 60, -- Dismantle
        [2983] = 60, -- Sprint
        [76577] = 180, -- Smoke Bomb
        [73981] = 60, -- Redirect
        [74001] = 90, -- Combat Readiness
        [14177] = { cd = 120, spec = L["Assassination"], }, -- Cold Blood
        [79140] = { cd = 120, spec = L["Assassination"], }, -- Vendetta
        [51713] = { cd = 60, spec = L["Subtlety"], }, -- Shadow Dance
        [13750] = { cd = 180, spec = L["Combat"], }, -- Adrenaline Rush
        [13877] = { cd = 10, spec = L["Combat"], }, -- Blade Flurry
        [51690] = { cd = 120, spec = L["Combat"], }, -- Killing Spree
        [36554] = { cd = 24, spec = L["Subtlety"], }, -- Shadowstep
        [14185] = { cd = 300, spec = L["Subtlety"], -- Preparation
                    resetCD = {
                        [2983] = true,
                        [1856] = true,
                        [1766] = true,
                        [51722] = true,
                        [36554] = true,
                        [76577] = true,
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
    ["Goblin"] = {
    },
    ["Worgen"] = {
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
        [25046] = true,
        [50613] = true,
        [69179] = true,
        [80483] = true,
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
        [59542] = true,
        [59543] = true,
        [59544] = true,
        [59545] = true,
        [59547] = true,
        [59548] = true,
        duration = 180,
        spellName = select(1, GetSpellInfo(28880)),
        texture = select(3, GetSpellInfo(28880))
    },
    ["Human"] = {
        [59752] = true, -- Will to Survive
        duration = 120,
        spellName = select(1, GetSpellInfo(59752)),
        texture = select(3, GetSpellInfo(59752))
    },
    ["Gnome"] = {
        [20589] = true, -- Escape Artist
        duration = 90,
        spellName = select(1, GetSpellInfo(20589)),
        texture = select(3, GetSpellInfo(20589))
    },
    ["Dwarf"] = {
        [20594] = true, -- Stoneform
        duration = 120,
        spellName = select(1, GetSpellInfo(20594)),
        texture = select(3, GetSpellInfo(20594))
    },
    ["Goblin"] = {
        [69070] = true, -- Rocket Jump
        duration = 120,
        spellName = select(1, GetSpellInfo(69070)),
        texture = select(3, GetSpellInfo(69070))
    },
    ["Worgen"] = {
        [68992] = true, -- Darkflight
        duration = 120,
        spellName = select(1, GetSpellInfo(68992)),
        texture = select(3, GetSpellInfo(68992))
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
    --[string_lower("Disease Cleansing Totem")] = {id = 8170,texture = select(3, GetSpellInfo(8170)), color = {r = 0, g = 0, b = 0, a = 1}, pulse = 3},
    [string_lower("Mana Spring Totem")] = { id = 5675, texture = select(3, GetSpellInfo(5675)), color = { r = 0, g = 0, b = 0, a = 1 } },
    -- Earth
    [string_lower("Tremor Totem")] = {id = 8143,texture = select(3, GetSpellInfo(8143)), color = {r = 1, g = 0.9, b = 0.1, a = 1}, pulse = { cd = 6, once = true }},
    -- Air
}

local totemSpellIdToPulse = {
    --[GetSpellInfo(totemData[string_lower("Disease Cleansing Totem")].id)] = totemData[string_lower("Disease Cleansing Totem")].pulse,
    --[8170] = totemData[string_lower("Disease Cleansing Totem")].pulse,
    [8143] = totemData[string_lower("Tremor Totem")].pulse,
}

local totemNpcIdsToTotemData = {
    --[5924] = totemData[string_lower("Disease Cleansing Totem")],

    [3573] = totemData[string_lower("Mana Spring Totem")],
    [7414] = totemData[string_lower("Mana Spring Totem")],
    [7415] = totemData[string_lower("Mana Spring Totem")],
    [7416] = totemData[string_lower("Mana Spring Totem")],
    [15304] = totemData[string_lower("Mana Spring Totem")],
    [15489] = totemData[string_lower("Mana Spring Totem")],
    [31186] = totemData[string_lower("Mana Spring Totem")],
    [31189] = totemData[string_lower("Mana Spring Totem")],
    [31190] = totemData[string_lower("Mana Spring Totem")],

    [5927] = totemData[string_lower("Elemental Resistance Totem")]

}

local totemDataShared, totemNpcIdsToTotemDataShared, totemSpellIdToPulseShared = Gladdy:GetSharedTotemData()
Gladdy:AddEntriesToTable(totemData, totemDataShared)
Gladdy:AddEntriesToTable(totemNpcIdsToTotemData, totemNpcIdsToTotemDataShared)
Gladdy:AddEntriesToTable(totemSpellIdToPulse, totemSpellIdToPulseShared)

function Gladdy:GetTotemData()
    return totemData, totemNpcIdsToTotemData, totemSpellIdToPulse
end
