local GetSpellInfo = GetSpellInfo
local select = select
local LibClassAuras = LibStub("LibClassAuras-1.0")
local Buff = LibClassAuras.Buff

-------------
-- PRIEST
-------------
Buff({ 1243, 1244, 1245, 2791, 10937, 10938, 25389 }, { buffType = "magic" }, "PRIEST") -- Power Word: Fortitude
Buff({ 21562, 21564, 25392 }, { buffType = "magic" }, "PRIEST") -- Prayer of Fortitude
Buff({ 17, 592, 600, 3747, 6065, 6066, 10898, 10899, 10900, 10901, 25217, 25218 }, { buffType = "magic" }, "PRIEST") -- Power Word: Shield
Buff({ 588, 7128, 602, 1006, 10951, 10952, 25431 }, { buffType = "magic" }, "PRIEST") -- Inner Fire
Buff({ 2651 }, { buffType = "magic" }, "PRIEST") -- Elune's Grace
Buff({ 6346 }, { buffType = "magic" }, "PRIEST") -- Fear Ward
Buff({ 14752, 14818, 14819, 27841, 25312 }, { buffType = "magic" }, "PRIEST") -- Divine Spirit
Buff({ 27681, 32999 }, { buffType = "magic" }, "PRIEST") -- Prayer of Spirit
Buff({ 1706 }, { buffType = "magic" }, "PRIEST") -- Levitate
Buff({ 139, 6074, 6075, 6076, 6077, 6078, 10927, 10928, 10929, 25315, 25221, 25222 }, { buffType = "magic" }, "PRIEST") -- Renew
Buff({ 552 }, { buffType = "magic" }, "PRIEST") -- Abolish Disease
Buff({ 33076 }, { buffType = "magic" }, "PRIEST") -- Prayer of Mending
Buff({ 586, 9578, 9579, 9592, 10941, 10942, 25429 }, { buffType = "magic" }, "PRIEST") -- Fade
Buff({ 2652, 19261, 19262, 19264, 19265, 19266, 25461 }, { buffType = "magic" }, "PRIEST") -- Touch of Weakness
Buff({ 18137, 19308, 19310, 19311, 19312, 25477 }, { buffType = "magic" }, "PRIEST") -- Shadowguard
Buff({ 976, 10957, 10958, 16874, 25433 }, { buffType = "magic" }, "PRIEST") -- Shadow Protection
Buff({ 27683, 39374 }, { buffType = "magic" }, "PRIEST") -- Prayer of Shadow Protection
Buff({ 15473 }, { buffType = "form" }, "PRIEST") -- Shadowform
--talents
Buff({ 14893, 15357, 15359 }, { buffType = "magic" }, "PRIEST") -- Inspiration
Buff({ 27813, 27817, 27818 }, { buffType = "magic" }, "PRIEST") -- Blessed Recovery
Buff({ 14743 }, { buffType = "magic" }, "PRIEST") -- Focused Casting
Buff({ 14751 }, { buffType = "magic" }, "PRIEST") -- Inner Focus
Buff({ 10060 }, { buffType = "magic" }, "PRIEST") -- Power Infusion
Buff({ 33206 }, { buffType = "magic" }, "PRIEST") -- Pain Suppression
Buff({ 34754 }, { buffType = "magic" }, "PRIEST") -- Clearcasting

---------------
-- DRUID
---------------
Buff({ 467, 782, 1075, 8914, 9756, 9910, 26992 }, { buffType = "magic"}, "DRUID") -- Thorns
Buff({ 5487 }, { buffType = "form"}, "DRUID") -- Bear Form
Buff({ 783 }, { buffType = "form"}, "DRUID") -- Travel Form
Buff({ 9634 }, { buffType = "form"}, "DRUID") -- Dire Bear Form
Buff({ 768 }, { buffType = "form"}, "DRUID") -- Cat Form
Buff({ 22812 }, { buffType = "magic"}, "DRUID") -- Barkskin
Buff({ 5229 }, { buffType = "physical"}, "DRUID") -- Enrage
Buff({ 5217, 6793, 9845, 9846 }, { buffType = "physical"}, "DRUID") -- Tiger's Fury
Buff({ 1850, 9821, 33357 }, { buffType = "physical"}, "DRUID") -- Dash
Buff({ 22842, 22895, 22896, 26999 }, { buffType = "physical"}, "DRUID") -- Frenzied Regeneration
Buff({ 1126, 5232, 6756, 5234, 8907, 9884, 9885, 26990 }, { buffType = "magic"}, "DRUID") -- Mark of the Wild
Buff({ 21849, 21850, 26991 }, { buffType = "magic"}, "DRUID") -- Gift of the Wild
Buff({ 774, 1058, 1430, 2090, 2091, 3627, 8910, 9839, 9840, 9841, 25299, 26981, 26982 }, { buffType = "magic"}, "DRUID") -- Regrowth
Buff({ 8936, 8938, 8939, 8940, 8941, 9750, 9856, 9857, 9858, 26980 }, { buffType = "magic"}, "DRUID") -- Rejuvenation
Buff({ 2893 }, { buffType = "magic"}, "DRUID") -- Abolish Poison
Buff({ 33763 }, { buffType = "magic"}, "DRUID") -- Lifebloom
--Talents
Buff({ 24858 }, { buffType = "form"}, "DRUID") -- Moonkin Form
Buff({ 24907 }, { buffType = "aura"}, "DRUID") -- Moonkin Aura
Buff({ 33891 }, { buffType = "form"}, "DRUID") -- Tree of Life
Buff({ 16864 }, { buffType = "magic"}, "DRUID") -- Omen of Clarity
Buff({ 16689, 16810, 16811, 16812, 16813, 17329, 27009 }, { buffType = "magic"}, "DRUID") -- Nature's Grasp
Buff({ 45281, 45282, 45283 }, { buffType = "magic"}, "DRUID") -- Natural Perfection
Buff({ 17116 }, { buffType = "magic"}, "DRUID") -- Nature's Swiftness
Buff({ 17007 }, { buffType = "aura"}, "DRUID") -- Leader of the Pack

-------------
-- WARRIOR -- TODO
-------------
Buff({ 29838 }, { buffType = "physical"}, "WARRIOR") -- Second Wind
Buff({ 12292 }, { buffType = "physical"}, "WARRIOR") -- Death Wish
Buff({ 6673 }, { buffType = "physical"}, "WARRIOR") -- Battle Shout
Buff({ 469 }, { buffType = "physical"}, "WARRIOR") -- Commanding Shout
Buff({ 12328 }, { buffType = "physical"}, "WARRIOR") -- Sweeping Strikes
Buff({ 30032 }, { buffType = "physical"}, "WARRIOR") -- Rampage
Buff({ 2687 }, { buffType = "physical"}, "WARRIOR") -- Blood Rage
Buff({ 20230 }, { buffType = "physical"}, "WARRIOR") -- Retaliation
Buff({ 871 }, { buffType = "physical"}, "WARRIOR") -- Shield Wall
Buff({ 18499 }, { buffType = "physical"}, "WARRIOR") -- Berserker Rage
Buff({ 23885 }, { buffType = "physical"}, "WARRIOR") -- Bloodthirst
Buff({ 3411 }, { buffType = "physical"}, "WARRIOR") -- Intervene


--------------
-- ROGUE -- TODO
--------------

Buff({ 2983 }, { buffType = "physical" }, "ROGUE") -- Sprint
Buff({ 5277 }, { buffType = "physical" }, "ROGUE") -- Evasion
Buff({ 31224 }, { buffType = "physical" }, "ROGUE") -- Cloak of Shadows
Buff({ 14278 }, { buffType = "physical" }, "ROGUE") -- Ghostly Strike


------------
-- WARLOCK --TODO
------------
Buff({ 19028 }, { buffType = "aura"}, "WARLOCK") -- Soul Link
Buff({ 696 }, { buffType = "aura"}, "WARLOCK") -- Demon Skin
Buff({ 706 }, { buffType = "aura"}, "WARLOCK") -- Demon Armor
Buff({ 28176 }, { buffType = "aura"}, "WARLOCK") -- Fel Armor
Buff({ 23759 }, { buffType = "aura"}, "WARLOCK") -- Master Demonologist
Buff({ 34936 }, { buffType = "magic"}, "WARLOCK") -- Backlash
Buff({ 5697 }, { buffType = "magic"}, "WARLOCK") -- Unending Breath
Buff({ 132 }, { buffType = "magic"}, "WARLOCK") -- Detect Invisibility
Buff({ 1949 }, { buffType = "aura"}, "WARLOCK") -- Hellfire
Buff({ 6229 }, { buffType = "magic"}, "WARLOCK") -- Shadow Ward
Buff({ 19480 }, { buffType = "magic"}, "WARLOCK") -- Paranoia
Buff({ 7812 }, { buffType = "magic"}, "WARLOCK") -- Sacrifice
Buff({ 2947 }, { buffType = "magic"}, "WARLOCK") -- Fire Shield


---------------
-- SHAMAN
---------------

Buff({ 8178 } ,{ buffType = "magic" }, "SHAMAN") -- Grounding Totem Effect
Buff({ 30823 } ,{ buffType = "magic" }, "SHAMAN") -- Shamanistic Rage
Buff({ 32182 } ,{ buffType = "magic" }, "SHAMAN") -- Heroism
Buff({ 2825 } ,{ buffType = "magic" }, "SHAMAN") -- Bloodlust
Buff({ 974 } ,{ buffType = "magic" }, "SHAMAN") -- Earth Shield
Buff({ 24398 } ,{ buffType = "magic" }, "SHAMAN") -- Water Shield
Buff({ 324 } ,{ buffType = "magic" }, "SHAMAN") -- Lightning Shield
Buff({ 16188 } ,{ buffType = "magic" }, "SHAMAN") -- Nature's Swiftness
Buff({ 16166 } ,{ buffType = "magic" }, "SHAMAN") -- Elemental Mastery

--------------
-- PALADIN --TODO
--------------
--Blessings
Buff( { 1022, 5599, 10278 }, { buffType = "magic"}, "PALADIN") -- Blessing of Protection
Buff( { 6940 }, { buffType = "magic"}, "PALADIN") -- Blessing of Sacrifice
Buff( { 1044 }, { buffType = "magic"}, "PALADIN") -- Blessing of Freedom
Buff( { 19740, 19834, 19835, 19836, 19837, 19838, 25291, 27140 }, { buffType = "magic"}, "PALADIN") -- Blessing of Might
Buff( { 19742 }, { buffType = "magic"}, "PALADIN") -- Blessing of Wisdom
Buff( { 20217 }, { buffType = "magic"}, "PALADIN") -- Blessing of Kings
Buff( { 19977 }, { buffType = "magic"}, "PALADIN") -- Blessing of Light
Buff( { 1038 }, { buffType = "magic"}, "PALADIN") -- Blessing of Salvation
Buff( { 20911 }, { buffType = "magic"}, "PALADIN") -- Blessing of Sanctuary
Buff( { 25898 }, { buffType = "magic"}, "PALADIN") -- Greater Blessing of Kings
Buff( { 25890 }, { buffType = "magic"}, "PALADIN") -- Greater Blessing of Light
Buff( { 25782 }, { buffType = "magic"}, "PALADIN") -- Greater Blessing of Might
Buff( { 25895 }, { buffType = "magic"}, "PALADIN") -- Greater Blessing of Salvation
Buff( { 25899 }, { buffType = "magic"}, "PALADIN") -- Greater Blessing of Sanctuary
Buff( { 25894 }, { buffType = "magic"}, "PALADIN") -- Greater Blessing of Wisdom
Buff( { 642 }, { buffType = "immune"}, "PALADIN") -- Divine Shield
Buff( { 31884 }, { buffType = "magic"}, "PALADIN") -- Avenging Wrath
--Auras
Buff( { 465, 10290, 643, 10291, 1032, 10292, 10293, 27149 }, { buffType = "aura"}, "PALADIN") -- Devotion Aura
Buff( { 7294 }, { buffType = "aura"}, "PALADIN") -- Retribution Aura
Buff( { 19746 }, { buffType = "aura"}, "PALADIN") -- Concentration Aura
Buff( { 19876 }, { buffType = "aura"}, "PALADIN") -- Shadow Resistance Aura
Buff( { 20218 }, { buffType = "aura"}, "PALADIN") -- Sanctity Aura
Buff( { 19888 }, { buffType = "aura"}, "PALADIN") -- Frost Resistance Aura
Buff( { 19891 }, { buffType = "aura"}, "PALADIN") -- Fire Resistance Aura
Buff( { 32223 }, { buffType = "aura"}, "PALADIN") -- Crusader Aura
--Seals
Buff( { 20154, 20287, 20288, 20289, 20290, 20291, 20292, 20293, 27155 }, { buffType = "magic"}, "PALADIN") -- Seal of Righteousness
Buff( { 31892 }, { buffType = "magic"}, "PALADIN") -- Seal of Blood
Buff( { 20375 }, { buffType = "magic"}, "PALADIN") -- Seal of Command
Buff( { 20164 }, { buffType = "magic"}, "PALADIN") -- Seal of Justice
Buff( { 20165 }, { buffType = "magic"}, "PALADIN") -- Seal of Light
Buff( { 15277 }, { buffType = "magic"}, "PALADIN") -- Seal of Reckoning
Buff( { 31801 }, { buffType = "magic"}, "PALADIN") -- Seal of Vengeance
Buff( { 20166 }, { buffType = "magic"}, "PALADIN") -- Seal of Wisdom
Buff( { 21082 }, { buffType = "magic"}, "PALADIN") -- Seal of the Crusade


-------------
-- HUNTER
-------------

Buff( { 5384 }, { buffType = "physical"}, "HUNTER") -- Feign Death
Buff( { 19263 }, { buffType = "physical"}, "HUNTER") -- Deterrence
Buff( { 3045 }, { buffType = "physical"}, "HUNTER") -- Rapid Fire
--local FEIGN_DEATH = GetSpellInfo(5384) -- Localized name for Feign Death


-------------
-- MAGE --TODO
-------------

Buff({ 66 }, { buffType = "magic"}, "MAGE") -- Invisibility
Buff({ 1459 }, { buffType = "magic"}, "MAGE") -- Arcane Intellect
Buff({ 130 }, { buffType = "magic"}, "MAGE") -- Slow Fall
Buff({ 604 }, { buffType = "magic"}, "MAGE") -- Dampen Magic
Buff({ 1008 }, { buffType = "magic"}, "MAGE") -- Amplify Magic
Buff({ 1463 }, { buffType = "magic"}, "MAGE") -- Mana Shield
Buff({ 6117 }, { buffType = "form"}, "MAGE") -- Mage Armor
Buff({ 31643 }, { buffType = "magic"}, "MAGE") -- Blazing Speed
Buff({ 543 }, { buffType = "magic"}, "MAGE") -- Fire Ward
Buff({ 11129 }, { buffType = "magic"}, "MAGE") -- Combustion
Buff({ 30482 }, { buffType = "form"}, "MAGE") -- Molten Armor
Buff({ 168 }, { buffType = "form"}, "MAGE") -- Frost Armor
Buff({ 7302 }, { buffType = "form"}, "MAGE") -- Ice Armor
Buff({ 45438 }, { buffType = "immune"}, "MAGE") -- Ice Block
Buff({ 6143 }, { buffType = "magic"}, "MAGE") -- Frost Ward
--talents
Buff({ 11426 }, { buffType = "magic"}, "MAGE") -- Ice Barrier
Buff({ 12472 }, { buffType = "magic"}, "MAGE") -- Icy Veins