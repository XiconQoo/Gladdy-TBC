local GetSpellInfo = GetSpellInfo
local select = select
local LibClassAuras = LibStub("LibClassAuras-1.0")
local Debuff = LibClassAuras.Debuff

-------------
-- PRIEST
-------------
Debuff({ 2943, 19249, 19251, 19252, 19253, 19254, 25460 }, { buffType = "curse" }, "PRIEST") -- Touch of Weakness Effect
Debuff({ 9035, 19281, 19282, 19283, 19284, 19285, 25470 }, { buffType = "curse" }, "PRIEST") -- Hex of Weakness
Debuff({ 6788 }, { }, "PRIEST") -- Weakened Soul
Debuff({ 15487 }, { buffType = "magic" }, "PRIEST") -- Silence
Debuff({ 10797, 19296, 19299, 19302, 19303, 19304, 19305, 25446 }, { stacking = true, buffType = "magic", preEvent = "SPELL_CAST_SUCCESS" }, "PRIEST") -- starshards
Debuff({ 2944, 19276, 19277, 19278, 19279, 19280, 25467 }, { stacking = true , buffType = "disease", preEvent = "SPELL_CAST_SUCCESS"}, "PRIEST") --devouring plague
Debuff({ 453, 8192, 10953, 25596 }, { }, "PRIEST") -- mind soothe
Debuff({ 14914, 15261, 15262, 15263, 15264, 15265, 15266, 15267, 25384 }, { stacking = true, buffType = "magic", preEvent = "SPELL_DAMAGE"}, "PRIEST") -- Holy Fire, stacking?
Debuff({ 589, 594, 970, 992, 2767, 10892, 10893, 10894, 25367, 25368 }, { stacking = true, buffType = "magic", preEvent = "SPELL_CAST_SUCCESS"}, "PRIEST") -- SW:P
Debuff({ 15258 } ,{ buffType = "magic" }, "PRIEST") -- Shadow Vulnerability (Shadow Weaving Talent Effect)
Debuff({ 15286 } ,{ buffType = "magic" }, "PRIEST") -- Vampiric Embrace
Debuff({ 15407, 17311, 17312, 17313, 17314, 18807, 25387 }, { buffType = "magic" }, "PRIEST") -- Mind Flay
Debuff({ 605, 10911, 10912 }, { buffType = "magic" }, "PRIEST") -- Mind Control
Debuff({ 8122, 8124, 10888, 10890 }, { buffType = "magic", }, "PRIEST") -- Psychic Scream
Debuff({ 15269 }, { buffType = "magic"}, "PRIEST") -- Blackout
Debuff({ 44041, 44043, 44044, 44045, 44046, 44047 }, { buffType = "magic"}, "PRIEST") -- Chastise

---------------
-- DRUID
---------------
Debuff({ 33786 }, { buffType = "immune"}, "DRUID") -- Cyclone
Debuff({ 19675 }, { }, "DRUID") -- Feral Charge
Debuff( { 22570}, { buffType = "physical"}, "DRUID") -- Maim
Debuff({ 19975, 19974, 19973, 19972, 19971, 19970, 27010 }, { buffType = "magic", altName = select(1, GetSpellInfo(27010)) .. " " .. select(1, GetSpellInfo(16689))  }, "DRUID") -- Nature's Grasp root
Debuff({ 339, 1062, 5195, 5196, 9852, 9853, 26989 }, { buffType = "magic"}, "DRUID") -- Entangling Roots
Debuff({ 770, 778, 9749, 9907, 26993 }, { buffType = "magic"  }, "DRUID") -- Faerie Fire
Debuff({ 16857, 17390, 17391, 17392, 27011 }, { buffType = "magic"  }, "DRUID") -- Faerie Fire (Feral)
Debuff({ 2637, 18657, 18658 }, { buffType = "magic"}, "DRUID") -- Hibernate
Debuff({ 99, 1735, 9490, 9747, 9898, 26998 }, { buffType = "physical" }, "DRUID") -- Demoralizing Roar
Debuff({ 5209 }, { buffType = "physical"  }, "DRUID") -- Challenging Roar
Debuff({ 6795 }, { stacking = true, buffType = "physical", preEvent = "SPELL_CAST_SUCCESS" }, "DRUID") -- Taunt
Debuff({ 16922 }, { buffType = "physical" }, "DRUID") -- Imp Starfire Stun
Debuff({ 9005, 9823, 9827, 27006 }, { buffType = "physical" }, "DRUID") -- Pounce
Debuff({ 9007, 9824, 9826, 27007 }, { buffType = "physical", stacking = true, preEvent = "SPELL_CAST_SUCCESS" }, "DRUID") -- Pounce Bleed
Debuff({ 8921, 8924, 8925, 8926, 8927, 8928, 8929, 9833, 9834, 9835, 26987, 26988 }, { stacking = true, buffType = "magic"}, "DRUID") -- Moonfire
Debuff({ 1822, 1823, 1824, 9904, 27003 }, { stacking = true, buffType = "physical", preEvent = "SPELL_CAST_SUCCESS" }, "DRUID") -- Rake
Debuff({ 1079, 9492, 9493, 9752, 9894, 9896, 27008 }, { stacking = true, buffType = "physical", preEvent = "SPELL_CAST_SUCCESS" }, "DRUID") -- Rip
Debuff({ 5570, 24974, 24975, 24976, 24977, 27013 }, { stacking = true, buffType = "magic", preEvent = "SPELL_CAST_SUCCESS" }, "DRUID") -- Insect Swarm
Debuff({ 33745 }, { stacking = true, buffType = "physical", preEvent = "SPELL_CAST_SUCCESS" }, "DRUID") -- Lacerate
Debuff({ 33878, 33986, 33987 }, { buffType = "physical" }, "DRUID") -- Mangle (Bear)
Debuff({ 33876, 33982, 33983 }, { buffType = "physical" }, "DRUID") -- Mangle (Cat)

-------------
-- WARRIOR
-------------
Debuff({ 29703 }, { buffType = "physical"}, "WARRIOR") -- Dazed
Debuff({ 12294, 21551, 21552, 21553, 25248, 30330 }, { buffType = "physical" }, "WARRIOR") -- Mortal Strike
Debuff({ 72, 1671, 1672, 29704}, { buffType = "physical" }, "WARRIOR") -- Shield Bash
Debuff({ 18498 }, { buffType = "physical" }, "WARRIOR") -- Improved Shield Bash
Debuff({ 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208 }, { stacking = true, buffType = "physical"}, "WARRIOR") -- Rend
Debuff({ 12721, 43104 }, { stacking = true, buffType = "physical"}, "WARRIOR") -- Deep Wounds
Debuff({ 12323 }, { buffType = "physical"}, "WARRIOR") -- Piercing Howl
Debuff({ 1715, 7372, 7373, 25212 }, { buffType = "physical" }, "WARRIOR") -- Hamstring
Debuff({ 23694 } , { buffType = "physical" }, "WARRIOR") -- Improved Hamstring
Debuff({ 6343, 8198, 8204, 8205, 11580, 11581, 25264 }, { buffType = "physical"}, "WARRIOR") -- Thunder Clap
Debuff({ 694, 7400, 7402, 20559, 20560 }, { buffType = "physical", }, "WARRIOR") -- Mocking Blow
Debuff({ 1161 } ,{ buffType = "physical", }, "WARRIOR") -- Challenging Shout
Debuff({ 355 } ,{ stacking = true, buffType = "physical", preEvent = "SPELL_CAST_SUCCESS" }, "WARRIOR") -- Taunt
Debuff({ 1160, 6190, 11554, 11555, 11556, 25202, 25203 }, { buffType = "physical" }, "WARRIOR") -- Demoralizing Shout, varies
Debuff({ 5246 }, { buffType = "physical" }, "WARRIOR") -- Intimidating Shout Fear
Debuff({ 676 } ,{ buffType = "physical" }, "WARRIOR") -- Disarm
Debuff({ 12798 } , { buffType = "physical" }, "WARRIOR") -- Imp Revenge Stun
Debuff({ 7386, 7405, 8380, 11596, 11597, 25225, buffType = "physical" }, { }, "WARRIOR") -- Sunder Armor
Debuff({ 12809 } ,{ buffType = "physical" }, "WARRIOR") -- Concussion Blow
Debuff({ 7922 }, { buffType = "physical" }, "WARRIOR") -- Charge Stun
Debuff({ 20253, 20614, 20615, 25273, 25274 }, { buffType = "physical" }, "WARRIOR") -- Intercept Stun
Debuff({ 5530 }, { buffType = "physical"}, "WARRIOR") -- Mace Stun Effect (Mace Specialization)

--------------
-- ROGUE
--------------

Debuff({ 16511, 17347, 17348, 26864 }, { buffType = "physical" }, "ROGUE") -- Hemorrhage
Debuff({ 3409, 11201 }, { buffType = "poison" }, "ROGUE") -- Crippling Poison
Debuff({ 13218, 13222, 13223, 13224, 27189 }, { buffType = "poison" }, "ROGUE") -- Wound Poison
Debuff({ 26679 }, { buffType = "physical"}, "ROGUE") -- Deadly Throw Slow
Debuff({ 2818, 2819, 11353, 11354, 25349, 26968, 27187 }, { stacking = true, buffType = "poison", preEvent = { { event = "SPELL_DAMAGE", spellID = 5940}, "SWING_DAMAGE" }}, "ROGUE") -- Deadly Poison
Debuff({ 5760, 8692, 11398 }, { buffType = "poison" }, "ROGUE") -- Mind-numbing Poison
Debuff({ 18425 }, { buffType = "physical" }, "ROGUE") -- Improved Kick Silence
Debuff({ 1833 }, { buffType = "physical" }, "ROGUE") -- Cheap Shot
Debuff({ 2070, 6770, 11297 }, { buffType = "physical" }, "ROGUE") -- Sap
Debuff({ 2094 } , { buffType = "physical" }, "ROGUE") -- Blind
Debuff({ 8647, 8649, 8650, 11197, 11198, 26866 }, { buffType = "physical" }, "ROGUE") -- Expose Armor
Debuff({ 703, 8631, 8632, 8633, 11289, 11290, 26839, 26884 }, { buffType = "physical", stacking = true, preEvent = "SPELL_CAST_SUCCESS"}, "ROGUE") -- Garrote
Debuff({ 1330 }, { buffType = "physical"}, "ROGUE")-- Garrote - Silence
Debuff({ 408, 8643 }, { buffType = "physical" }, "ROGUE") -- Kidney Shot
Debuff({ 1943, 8639, 8640, 11273, 11274, 11275, 26867 }, { buffType = "physical", stacking = true}, "ROGUE") -- Rupture
Debuff({ 1776, 1777, 8629, 11285, 11286, 38764 }, { buffType = "physical", }, "ROGUE") -- Gouge
Debuff({ 14251 } , { buffType = "physical", }, "ROGUE") -- Riposte (disarm)

------------
-- WARLOCK
------------
Debuff({ 32386 }, { buffType = "magic"}, "WARLOCK") -- Shadow Embrace
Debuff({ 710, 18647 } ,{ buffType = "immune"}, "WARLOCK") -- Banish
Debuff( { 348, 707, 1094, 2941, 11665, 11667, 11668, 25309, 27215 }, { buffType = "magic", stacking = true, preEvent = "SPELL_DAMAGE"}, "WARLOCK") -- Immolate
Debuff({ 24259 } ,{ buffType = "magic" }, "WARLOCK") -- Spell Lock Silence
Debuff({ 27243 } ,{ buffType = "magic", stacking = true, preEvent = "SPELL_CAST_START" }, "WARLOCK") -- Seed of Corruption
Debuff( { 689, 699, 709, 7651, 11699, 11700, 27219, 27220 }, { buffType = "magic", stacking = true, preEvent = "SPELL_CAST_SUCCESS"}, "WARLOCK") -- Drain Life
Debuff( { 5138, 6226, 11703, 11704, 27221, 30908 }, { buffType = "magic", stacking = true, preEvent = "SPELL_CAST_SUCCESS"}, "WARLOCK") -- Drain Mana
Debuff( { 1120, 8288, 8289, 11675, 27217 }, { buffType = "magic", stacking = true, preEvent = "SPELL_CAST_SUCCESS"}, "WARLOCK") -- Drain Soul
Debuff( { 18265, 18879, 18880, 18881, 27264, 30911}, { buffType = "magic", stacking = true, preEvent = "SPELL_CAST_SUCCESS"}, "WARLOCK") -- Siphon Life
Debuff( { 172, 6222, 6223, 7648, 11671, 11672, 25311, 27216 }, { buffType = "magic", stacking = true }, "WARLOCK") -- Corruption
Debuff( { 980, 1014, 6217, 11711, 11712, 11713, 27218 }, { buffType = "curse", stacking = true, preEvent = "SPELL_CAST_SUCCESS"}, "WARLOCK") -- Curse of Agony
Debuff({ 18223, 29539, 46434 }, { buffType = "curse"}, "WARLOCK") -- Curse of Exhaustion
Debuff( { 704, 7658, 7659, 11717, 27226 }, { buffType = "curse"}, "WARLOCK") -- Curse of Recklessness
Debuff( { 1490, 11721, 11722, 27228 }, { buffType = "curse"}, "WARLOCK") -- Curse of the Elements
Debuff( { 1714, 11719 }, { buffType = "curse"}, "WARLOCK") -- Curse of Tongues
Debuff( { 702, 1108, 6205, 7646, 11707, 11708, 27224, 30909 }, { buffType = "curse"}, "WARLOCK") -- Curse of Weakness
Debuff( { 603, 30910 }, { buffType = "curse"}, "WARLOCK") -- Curse of Doom
Debuff( { 6789, 17925, 17926, 27223 }, { buffType = "magic"}, "WARLOCK") -- Death Coil
Debuff( { 5782, 6213, 6215 }, { buffType = "magic"}, "WARLOCK") -- Fear
Debuff( { 5484, 17928 }, { buffType = "magic"}, "WARLOCK") -- Howl of Terror
Debuff({ 6358 }, { buffType = "magic" }, "WARLOCK") -- Seduction
Debuff({ 30108, 30404, 30405 }, { buffType = "magic", stacking = true, preEvent = "SPELL_CAST_START" }, "WARLOCK") -- Unstable Affliction
Debuff({ 31117, 43523 }, { buffType = "magic", altName = select(1, GetSpellInfo(30405)) .. " Silence" }, "WARLOCK") -- Unstable Affliction Silence
Debuff({ 18093 } ,{ buffType = "physical" }, "WARLOCK") -- Pyroclasm
Debuff({ 17877, 18867, 18868, 18869, 18870, 18871, 27263, 30546 }, { buffType = "physical", stacking = true, preEvent = "SPELL_CAST_SUCCESS" }, "WARLOCK") -- Shadowburn Debuff

---------------
-- SHAMAN
---------------

Debuff({ 17364 } ,{ buffType = "magic" }, "SHAMAN") -- Stormstrike
Debuff({ 8056, 8058, 10472, 10473, 25464 }, { buffType = "magic" }, "SHAMAN") -- Frost Shock
Debuff({ 8050, 8052, 8053, 10447, 10448, 29228, 25457 }, { stacking = true, buffType = "magic", preEvent = "SPELL_CAST_SUCCESS" }, "SHAMAN") -- Flame Shock
Debuff({ 8034, 8037, 10458, 16352, 16353, 25501 }, { buffType = "magic" }, "SHAMAN") -- Frostbrand Attack
Debuff({ 3600 } ,{ buffType = "magic" }, "SHAMAN") -- Earthbind Totem

--------------
-- PALADIN
--------------

Debuff( { 25771 }, { buffType = "immune"}, "PALADIN") -- Forbearance
Debuff({ 20066 }, { buffType = "magic" }, "PALADIN") -- Repentance
Debuff({ 2878, 5627, 5627 }, { buffType = "magic"}, "PALADIN") -- Turn Undead
Debuff({ 21183, 20188, 20300, 20301, 20302, 20303, 27159 }, { }, "PALADIN") -- Judgement of the Crusader
Debuff({ 20185, 20344, 20345, 20346 }, { buffType = "magic"}, "PALADIN") -- Judgement of Light
Debuff({ 20186, 20354, 20355 }, { buffType = "magic"}, "PALADIN") -- Judgement of Wisdom
Debuff({ 20184, 31896}, { buffType = "magic", }, "PALADIN") -- Judgement of Justice
Debuff({ 853, 5588, 5589, 10308 }, { buffType = "magic" }, "PALADIN") -- Hammer of Justice
Debuff({ 20170 } ,{ buffType = "physical", }, "PALADIN") -- Seal of Justice stun

-------------
-- HUNTER
-------------

Debuff( { 19434, 20900, 20901, 20902, 20903, 20904}, { buffType = "physical"}, "HUNTER") -- Aimed Shot
Debuff({ 1130, 14323, 14324, 14325 }, { buffType = "magic", }, "HUNTER") -- Hunter's Mark
Debuff({ 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 27016 }, { stacking = true, buffType = "poison", preEvent = "SPELL_CAST_SUCCESS" }, "HUNTER") -- Serpent Sting
Debuff({ 34490 }, { buffType = "magic" }, "HUNTER") -- Silencing Shot
Debuff({ 3043 }, { buffType = "poison", }, "HUNTER") -- Scorpid Sting
Debuff({ 3034, 14279, 14280, 27018 }, { buffType = "poison", }, "HUNTER") -- Viper Sting
Debuff({ 19386, 24132, 24133, 27068 }, { buffType = "poison", }, "HUNTER") -- Wyvern Sting
Debuff({ 24131, 24134, 24135, 27069 }, { buffType = "poison", altName = select(1, GetSpellInfo(19386)) .. " Dot" }, "HUNTER") -- Wyvern Sting Dot
Debuff({ 1513, 14326, 14327 }, { buffType = "magic"}, "HUNTER") -- Scare Beast
Debuff({ 19229 }, { buffType = "physical", }, "HUNTER") -- Wing Clip Root
Debuff({ 19306, 20909, 20910 }, { buffType = "physical"}, "HUNTER") -- Counterattack
Debuff({ 13812, 14314, 14315, 27026 }, { stacking = true, buffType = "physical", preEvent = "SPELL_CAST_SUCCESS" }, "HUNTER") -- Explosive Trap
Debuff({ 13797, 14298, 14299, 14300, 14301, 27024 }, { stacking = true, buffType = "magic", preEvent = "SPELL_CAST_SUCCESS" }, "HUNTER") -- Immolation Trap
Debuff({ 3355, 14308, 14309 }, { buffType = "magic" }, "HUNTER") -- Freezing Trap
Debuff({ 19503 }, { buffType = "physical" }, "HUNTER") -- Scatter Shot
Debuff({ 2974, 14267, 14268 }, { buffType = "physical" }, "HUNTER") -- Wing Clip
Debuff({ 5116 }, { buffType = "physical" }, "HUNTER") -- Concussive Shot
Debuff({ 19410 }, { buffType = "physical" }, "HUNTER") -- Conc Stun
Debuff({ 24394 }, { buffType = "physical" }, "HUNTER") -- Intimidation
Debuff({ 15571 }, { buffType = "physical" }, "HUNTER") -- Daze from Aspect
Debuff({ 19185 }, { buffType = "physical" }, "HUNTER") -- Entrapment
Debuff({ 25999 }, { buffType = "physical" }, "HUNTER") -- Boar Charge
Debuff({ 24640, 24583, 24586, 24587, 27060 }, { buffType = "poison" }, "HUNTER") -- Scorpid Poison

-------------
-- MAGE
-------------

Debuff({ 133, 143, 145, 3140, 8400, 8401, 8402, 10148, 10149, 10150, 10151, 25306, 27070 }, { buffType = "magic"}, "MAGE") -- Fireball
Debuff({ 11366, 12505, 12522, 12523, 12524, 12525, 12526, 18809, 27132, 33938 }, { buffType = "magic" }, "MAGE") -- Pyroblast
Debuff({ 18469 }, { buffType = "magic" }, "MAGE") -- Imp CS Silence
Debuff({ 118, 12824, 12825, 12826 }, { buffType = "magic" }, "MAGE") -- Polymorph
Debuff({ 12355 } , { buffType = "physical" }, "MAGE") -- Impact
Debuff({ 12654 }, { buffType = "magic" }, "MAGE") -- Ignite
Debuff({ 22959 }, { buffType = "magic" }, "MAGE") -- Fire Vulnerability
Debuff({ 12579 }, { buffType = "magic" }, "MAGE") -- Winter's Chill
Debuff({ 11113, 13018, 13019, 13020, 13021, 27133, 33933 }, { buffType = "physical" }, "MAGE") -- Blast Wave
--Spell({ 2120, 2121, 8422, 8423, 10215, 10216, 27086 }, { stacking = true, buffType = "physical" }) -- Flamestrike
Debuff({ 120, 8492, 10159, 10160, 10161, 27087 }, { buffType = "magic" }, "MAGE") -- Cone of Cold
Debuff({ 12484, 12485, 12486 }, { .5 }) -- Improved Blizzard (Chilled)
Debuff({ 6136, 7321, 18101, 20005, 16927, 15850, 31257}, { buffType = "magic" }, "MAGE") -- Frost/Ice Armor (Chilled)
Debuff({ 116, 205, 837, 7322, 8406, 8407, 8408, 10179, 10180, 10181, 25304, 27071, 27072, 38697 }, { buffType = "magic" }, "MAGE") -- Frostbolt
Debuff({ 12494 }, { buffType = "magic" }, "MAGE") -- Frostbite
Debuff({ 122, 865, 6131, 10230 }, { buffType = "magic" }, "MAGE") -- Frost Nova
Debuff({ 31589 }, { buffType = "magic" }, "MAGE") -- Slow
Debuff({ 41425 }, { buffType = "immune" }, "MAGE") -- Hypothermia