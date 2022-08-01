local tbl_sort, select, string_lower = table.sort, select, string.lower
local GetLocale = GetLocale

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

Gladdy.RACES = {"Scourge", "BloodElf", "Tauren", "Orc", "Troll", "NightElf", "Draenei", "Human", "Gnome", "Dwarf"}
tbl_sort(Gladdy.RACES)

local RACE_ICON_TCOORDS = {
    ["HUMAN_MALE"] = { 0, 0.125, 0, 0.25 },
    ["DWARF_MALE"] = { 0.125, 0.25, 0, 0.25 },
    ["GNOME_MALE"] = { 0.25, 0.375, 0, 0.25 },
    ["NIGHTELF_MALE"] = { 0.375, 0.5, 0, 0.25 },

    ["TAUREN_MALE"] = { 0, 0.125, 0.25, 0.5 },
    ["SCOURGE_MALE"] = { 0.125, 0.25, 0.25, 0.5 },
    ["TROLL_MALE"] = { 0.25, 0.375, 0.25, 0.5 },
    ["ORC_MALE"] = { 0.375, 0.5, 0.25, 0.5 },

    ["HUMAN_FEMALE"] = { 0, 0.125, 0.5, 0.75 },
    ["DWARF_FEMALE"] = { 0.125, 0.25, 0.5, 0.75 },
    ["GNOME_FEMALE"] = { 0.25, 0.375, 0.5, 0.75 },
    ["NIGHTELF_FEMALE"] = { 0.375, 0.5, 0.5, 0.75 },

    ["TAUREN_FEMALE"] = { 0, 0.125, 0.75, 1.0 },
    ["SCOURGE_FEMALE"] = { 0.125, 0.25, 0.75, 1.0 },
    ["TROLL_FEMALE"] = { 0.25, 0.375, 0.75, 1.0 },
    ["ORC_FEMALE"] = { 0.375, 0.5, 0.75, 1.0 },

    ["BLOODELF_MALE"] = { 0.5, 0.625, 0.25, 0.5 },
    ["BLOODELF_FEMALE"] = { 0.5, 0.625, 0.75, 1.0 },

    ["DRAENEI_MALE"] = { 0.5, 0.625, 0, 0.25 },
    ["DRAENEI_FEMALE"] = { 0.5, 0.625, 0.5, 0.75 },
}

local arenaTimer = {
    ["default"] = {
        [60] = "One minute until the Arena battle begins!",
        [30] = "Thirty seconds until the Arena battle begins!",
        [15] = "Fifteen seconds until the Arena battle begins!",
        [0] = "The Arena battle has begun!",
    },
    ["esES"] = {
        [60] = "¡Un minuto hasta que dé comienzo la batalla en arena!",
        [30] = "¡Treinta segundos hasta que comience la batalla en arena!",
        [15] = "¡Quince segundos hasta que comience la batalla en arena!",
        [0] = "¡La batalla en arena ha comenzado!",
    },
    ["ptBR"] = {
        [60] = "Um minuto até a batalha na Arena começar!",
        [30] = "Trinta segundos até a batalha na Arena começar!",
        [15] = "Quinze segundos até a batalha na Arena começar!",
        [0] = "A batalha na Arena começou!",
    },
    ["deDE"] = {
        [60] = "Noch eine Minute bis der Arenakampf beginnt!",
        [30] = "Noch dreißig Sekunden bis der Arenakampf beginnt!",
        [15] = "Noch fünfzehn Sekunden bis der Arenakampf beginnt!",
        [0] = "Der Arenakampf hat begonnen!",
    },
    ["frFR"] = {
        [60] = "Le combat d'arène commence dans une minute\194\160!",
        [30] = "Le combat d'arène commence dans trente secondes\194\160!",
        [15] = "Le combat d'arène commence dans quinze secondes\194\160!",
        [0] = "Le combat d'arène commence\194\160!",
    },
    ["ruRU"] = {
        [60] = "Одна минута до начала боя на арене!",
        [30] = "Тридцать секунд до начала боя на арене!",
        [15] = "До начала боя на арене осталось 15 секунд.",
        [0] = "Бой начался!",
    },
    ["itIT"] = { -- TODO
        -- Beta has no itIT version available?
    },
    ["koKR"] = {
        [60] = "투기장 전투 시작 1분 전입니다!",
        [30] = "투기장 전투 시작 30초 전입니다!",
        [15] = "투기장 전투 시작 15초 전입니다!",
        [0] = "투기장 전투가 시작되었습니다!",
    },
    ["zhCN"] = {
        [60] = "竞技场战斗将在一分钟后开始！",
        [30] = "竞技场战斗将在三十秒后开始！",
        [15] = "竞技场战斗将在十五秒后开始！",
        [0] = "竞技场的战斗开始了！",
    },
    ["zhTW"] = {
        [60] = "1分鐘後競技場戰鬥開始!",
        [30] = "30秒後競技場戰鬥開始!",
        [15] = "15秒後競技場戰鬥開始!",
        [0] = "競技場戰鬥開始了!",
    },
}
arenaTimer["esMX"] = arenaTimer["esES"]
arenaTimer["ptPT"] = arenaTimer["ptBR"]

function Gladdy:GetArenaTimer()
    if arenaTimer[GetLocale()] then
        return arenaTimer[GetLocale()]
    else
        return arenaTimer["default"]
    end
end

Gladdy.legacy = {
    castBarPos = "LEFT",
    buffsCooldownPos = "TOP",
    buffsBuffsCooldownPos = "BOTTOM",
    classIconPos = "LEFT",
    ciAnchor = "healthBar",
    ciPos = "TOP",
    cooldownYPos = "TOP",
    cooldownXPos = "LEFT",
    drCooldownPos = "RIGHT",
    racialAnchor = "trinket",
    racialPos = "RIGHT",
    trinketPos = "RIGHT",
    padding = 1,
    growUp = false,
}

Gladdy.newDefaults = {
    ["bottomMargin"] = 94.99996948242188,
    ["newLayout"] = true,
    Pets = {
        ["petYOffset"] = -81.99993896484375,
        ["petXOffset"] = 181,
    },
    ClassIcon = {
        ["classIconXOffset"] = -74.90008544921875,
    },
    Racial = {
        ["racialXOffset"] = 255.9000244140625,
    },
    Trinket = {
        ["trinketXOffset"] = 182,
    },
    ["Combat Indicator"] = {
        ["ciXOffset"] = 79.99993896484375,
        ["ciYOffset"] = -10.99993896484375,
    },
    Cooldowns = {
        ["cooldownYOffset"] = 31,
    },
    ["Buffs and Debuffs"] = {
        ["buffsBuffsXOffset"] = 29,
        ["buffsBuffsYOffset"] = -82.99993896484375,
        ["buffsXOffset"] = 29,
        ["buffsYOffset"] = 62.00006103515625,
    },
    Diminishings = {
        ["drXOffset"] = 329.7999877929688,
        ["drYOffset"] = -22.5,
    },
    ["Cast Bar"] = {
        ["castBarXOffset"] = -235.900146484375,
        ["castBarYOffset"] = -30.5,
    },
}

Gladdy.frameStrata = {
    BACKGROUND = L["Background"] .. "(0)",
    LOW = L["Low"] .. "(1)",
    MEDIUM = L["Medium"] .. "(2)",
    HIGH = L["High"] .. "(3)",
    DIALOG = L["Dialog"] .. "(4)",
    FULLSCREEN = L["Fullscreen"] .. "(5)",
    FULLSCREEN_DIALOG = L["Fullscreen Dialog"] .. "(6)",
    TOOLTIP = L["Tooltip"] .. "(7)",
}

Gladdy.frameStrataSorting = {
    [1] = "BACKGROUND",
    [2] = "LOW",
    [3] = "MEDIUM",
    [4] = "HIGH",
    [5] = "DIALOG",
    [6] = "FULLSCREEN",
    [7] = "FULLSCREEN_DIALOG",
    [8] = "TOOLTIP",
}

local dispelTypeColors = {}
dispelTypeColors["none"] = { r = 0.80, g = 0, b = 0, a = 1 }
dispelTypeColors["magic"] = { r = 0.20, g = 0.60, b = 1.00, a = 1 }
dispelTypeColors["curse"] = { r = 0.60, g = 0.00, b = 1.00, a = 1 }
dispelTypeColors["disease"] = { r = 0.60, g = 0.40, b = 0, a = 1 }
dispelTypeColors["poison"] = { r = 0.00, g = 0.60, b = 0, a = 1 }
dispelTypeColors["immune"] = { r = 1.00, g = 0.02, b = 0.99, a = 1 }
dispelTypeColors["enrage"] = dispelTypeColors["none"]
dispelTypeColors["form"] = dispelTypeColors["none"]
dispelTypeColors["aura"] = dispelTypeColors["none"]
dispelTypeColors[""] = dispelTypeColors["none"]

function Gladdy:GetDispelTypeColors()
    return dispelTypeColors
end


--[[schoolColoring = {
    [SCHOOL_MASK_NONE]	= {a=1.0,r=1.00,g=1.00,b=1.00};
    [SCHOOL_MASK_PHYSICAL]	= {a=1.0,r=1.00,g=1.00,b=0.00};
    [SCHOOL_MASK_HOLY] 	= {a=1.0,r=1.00,g=0.90,b=0.50};
    [SCHOOL_MASK_FIRE] 	= {a=1.0,r=1.00,g=0.50,b=0.00};
    [SCHOOL_MASK_NATURE] 	= {a=1.0,r=0.30,g=1.00,b=0.30};
    [SCHOOL_MASK_FROST] 	= {a=1.0,r=0.50,g=1.00,b=1.00};
    [SCHOOL_MASK_SHADOW] 	= {a=1.0,r=0.50,g=0.50,b=1.00};
    [SCHOOL_MASK_ARCANE] 	= {a=1.0,r=1.00,g=0.50,b=1.00};

SCHOOL_MASK_NONE		= 0x00;
SCHOOL_MASK_PHYSICAL	= 0x01;
SCHOOL_MASK_HOLY		= 0x02;
SCHOOL_MASK_FIRE		= 0x04;
SCHOOL_MASK_NATURE		= 0x08;
SCHOOL_MASK_FROST		= 0x10;
SCHOOL_MASK_SHADOW		= 0x20;
SCHOOL_MASK_ARCANE		= 0x40;
--]]
local spellSchoolColors = {}
spellSchoolColors[1] = { r = 1, g = 1, b = 0, a = 1, type = "Physical" } -- "physical" 255, 255, 0
spellSchoolColors[2] = { r = 1, g = 0.901, b = 0.501, a = 1, type = "Holy" } --"holy" -- 255, 230, 128
spellSchoolColors[4] = { r = 1, g = 0.501, b = 0, a = 1, type = "Fire" } --"fire" --  255, 128, 0
spellSchoolColors[8] = { r = 0.302, g = 1, b = 0.302, a = 1, type = "Nature" } --"nature" --  77, 255, 77
spellSchoolColors[16] = { r = 0.501, g = 1, b = 1, a = 1, type = "Frost" } --"frost" -- 128, 255, 255
spellSchoolColors[32] = { r = 0.501, g = 0.501, b = 1, a = 1, type = "Shadow" } --"shadow" --128, 128, 255
spellSchoolColors[64] = { r = 1, g = 0.501, b = 1, a = 1, type = "Arcane" } --"arcane" -- 255, 128, 255
spellSchoolColors["unknown"] = { r = 0, g = 0, b = 0, a = 1, type = "Unknown" } --"unknown spell school"

function Gladdy:GetSpellSchoolColors()
    return spellSchoolColors
end

---------------------
-- TRINKET STUFF
---------------------

local pvpTrinkets = { -- [itemID] = cd in ms
    --wotlk
    [59752] = 120000,
    [51377] = 120000,
    [51378] = 120000,
    [46083] = 120000,
    [46085] = 120000,
    [46081] = 120000,
    [46084] = 120000,
    [46082] = 120000,
    [42122] = 120000,
    [42123] = 120000,
    --tbc
    [37864] = 120000,
    [37865] = 120000,
    [28235] = 120000,
    [30348] = 120000,
    [28238] = 120000,
    [30351] = 120000,
    [28236] = 120000,
    [30349] = 120000,
    [28234] = 120000,
    [28237] = 120000,
    [30350] = 120000,
    [28240] = 120000,
    [28243] = 120000,
    [30345] = 120000,
    [28241] = 120000,
    [30343] = 120000,
    [28239] = 120000,
    [30346] = 120000,
    [28242] = 120000,
    [30344] = 120000,
    [29593] = 120000,
    [29593] = 300000,
    [18859] = 300000,
    [18857] = 300000,
    [18864] = 300000,
    [18854] = 300000,
    [18862] = 300000,
    [18858] = 300000,
    [18856] = 300000,
    [18863] = 300000,
    [18834] = 300000,
    [18851] = 300000,
    [18845] = 300000,
    [18852] = 300000,
    [29592] = 300000,
    [18850] = 300000,
    [18846] = 300000,
    [18853] = 300000,
}

function Gladdy:GetPvpTrinkets()
    return pvpTrinkets
end