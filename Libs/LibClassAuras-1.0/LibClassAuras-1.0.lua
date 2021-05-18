local type, ipairs, pairs, tinsert = type, ipairs, pairs, tinsert
local GetSpellInfo = GetSpellInfo
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

local LibClassAuras = LibStub:NewLibrary("LibClassAuras-1.0", 1)
LibClassAuras.debuffs = {}
LibClassAuras.debuffToId = {}
LibClassAuras.buffs = {}
LibClassAuras.buffToId = {}

local function Spell(id, opts, class, spellTable, idTable)
    if not opts or not class then
        return
    end

    local lastRankID
    if type(id) == "table" then
        local clones = id
        lastRankID = clones[#clones]
    else
        lastRankID = id
    end

    local spellName = GetSpellInfo(lastRankID)
    if not spellName then
        return
    end
    if opts.altName then
        idTable[opts.altName] = {id = id , class = class}
    else
        idTable[spellName] = {id = id , class = class}
    end

    if type(id) == "table" then
        for _, spellID in ipairs(id) do
            spellTable[spellID] = opts
            spellTable[spellID].class = class
        end
    else
        spellTable[id] = opts
        spellTable[id].class = class
    end
end

local function Debuff(id, opts, class)
    Spell(id, opts, class, LibClassAuras.debuffs, LibClassAuras.debuffToId)
end
LibClassAuras.Debuff = Debuff

local function Buff(id, opts, class)
    Spell(id, opts, class, LibClassAuras.buffs, LibClassAuras.buffToId)
end
LibClassAuras.Buff = Buff

local function getClassDebuffs(class)
    local classSpells = {}
    for k,v in pairs(LibClassAuras.debuffToId) do
        if v.class == class then
            tinsert(classSpells, {name = k, id = v.id})
        end
    end
    return classSpells
end
LibClassAuras.GetClassDebuffs = getClassDebuffs

local function getClassBuffs(class)
    local classSpells = {}
    for k,v in pairs(LibClassAuras.buffToId) do
        if v.class == class then
            tinsert(classSpells, {name = k, id = v.id})
        end
    end
    return classSpells
end
LibClassAuras.GetClassBuffs = getClassBuffs

local function getSpellNameToId(auraType)
    if auraType == AURA_TYPE_DEBUFF then
        return LibClassAuras.debuffToId
    else
        return LibClassAuras.buffToId
    end
end

LibClassAuras.GetSpellNameToId = getSpellNameToId