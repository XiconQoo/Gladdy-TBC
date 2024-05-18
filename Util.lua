local pairs, ipairs = pairs, ipairs
local select = select
local tonumber = tonumber
local type = type
local floor = math.floor
local coroutine = coroutine
local debugprofilestop = debugprofilestop
local geterrorhandler = geterrorhandler
local debugstack = debugstack
local next = next
local str_find, str_gsub, str_sub, str_format, str_match, str_gmatch = string.find, string.gsub, string.sub, string.format, string.match, string.gmatch
local tinsert = table.insert
local pcall = pcall
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local AuraUtil = AuraUtil
local GetSpellInfo = GetSpellInfo
local UnitIsUnit = UnitIsUnit
local GetSpellPowerCost = GetSpellPowerCost
local GetSpellDescription = GetSpellDescription

---------------------------

-- TAGS

---------------------------

local tagsFunctions = {
    ["percent"] = function(current, max, status, name, class, race, spec, arena) return current and max and floor(current * 100 / max) .. "%%" or "" end,
    ["max"] = function(current, max, status, name, class, race, spec, arena) return max and max > 999 and ("%.1fk"):format(max / 1000) or max or "" end,
    ["status"] = function(current, max, status, name, class, race, spec, arena) return status or "" end,
    ["name"] = function(current, max, status, name, class, race, spec, arena) return name or "" end,
    ["class"] = function(current, max, status, name, class, race, spec, arena) return class or "" end,
    ["race"] = function(current, max, status, name, class, race, spec, arena) return race or "" end,
    ["current"] = function(current, max, status, name, class, race, spec, arena) return current and max > 999 and ("%.1fk"):format(current / 1000) or current or "" end,
    ["arena"] = function(current, max, status, name, class, race, spec, arena) return arena or "" end,
    ["spec"] = function(current, max, status, name, class, race, spec, arena) return spec or "" end,
}

local function escapePattern(pattern)
    local specialCharacters = "()%-.%+%*?[%]%^$"
    return pattern:gsub("([%" .. specialCharacters .. "])", "%%%1")
end

local function getTag(tag, unit, current, max, status)
    local button = Gladdy.buttons[unit]
    if not button then
        return
    end
    local returnStr = tag
    local class = button.classLoc
    local spec = button.spec
    local name = button.name
    local race = button.raceLoc
    local arenaNumber,found = str_gsub(unit, "arena", "")
    local arena = found == 1 and arenaNumber or ""
    if str_find(tag, "%[[%w|%|]+%]") then
        for block in str_gmatch(tag, "%[[%w|%|]+%]") do
            local replace = block
            for tagOption in str_gmatch(block, "%w+") do
                if tagsFunctions[tagOption] then
                    local tagStr = tagsFunctions[tagOption](current, max, status, name, class, race, spec, arena)
                    replace =  replace == block and tagStr or tagStr ~= "" and tagStr or replace
                end
            end
            local pattern = escapePattern(block)
            returnStr = returnStr:gsub(pattern, replace)
        end
    end
    return returnStr
end

function Gladdy:SetTag(unit, tagOption, current, max, status)
    local button = self.buttons[unit]
    if not button then
        return
    end

    return getTag(tagOption, unit, current, max, status)


end

function Gladdy:GetTagOption(name, order, enabledOption, func, toggle)
    if toggle then
        return func({
            type = "toggle",
            name = name,
            order = order,
            width = "full",
            desc = L["Custom Tags:\n"..
                    "\n|cff1ac742[current]|r - Shows current\n" ..
                    "\n|cff1ac742[max]|r - Shows max\n" ..
                    "\n|cff1ac742[percent]|r - Shows percent\n" ..
                    "\n|cff1ac742[name]|r - Shows name\n" ..
                    "\n|cff1ac742[arena]|r - Shows arena number\n" ..
                    "\n|cff1ac742[status]|r - Shows status (eg DEATH)\n" ..
                    "\n|cff1ac742[race]|r - Shows race\n" ..
                    "\n|cff1ac742[class]|r - Shows class\n" ..
                    "\n|cff1ac742[spec]|r - Shows spec\n\n" ..
                    "Can be combined with OR operator like |cff1ac742[percent|status]|r. The last valid option will be used.\n"],
        })
    else
        return func({
            type = "input",
            name = name,
            order = order,
            width = "full",
            disabled = function() return not Gladdy.db[enabledOption] end,
            desc = L["Custom Tags:\n"..
                    "\n|cff1ac742[current]|r - Shows current\n" ..
                    "\n|cff1ac742[max]|r - Shows max\n" ..
                    "\n|cff1ac742[percent]|r - Shows percent\n" ..
                    "\n|cff1ac742[name]|r - Shows name\n" ..
                    "\n|cff1ac742[arena]|r - Shows arena number\n" ..
                    "\n|cff1ac742[status]|r - Shows status (eg DEATH)\n" ..
                    "\n|cff1ac742[race]|r - Shows race\n" ..
                    "\n|cff1ac742[class]|r - Shows class\n" ..
                    "\n|cff1ac742[spec]|r - Shows spec\n\n" ..
                    "Can be combined with OR operator like |cff1ac742[percent|status]|r. The last valid option will be used.\n"],
        })
    end
end

function Gladdy:contains(entry, list)
    for _,v in pairs(list) do
        if entry == v then
            return true
        end
    end
    return false
end

local feignDeath = GetSpellInfo(5384)
function Gladdy:isFeignDeath(unit)
    return AuraUtil.FindAuraByName(feignDeath, unit)
end

function Gladdy:GetArenaUnit(unitCaster, unify)
    if unitCaster then
        for i=1,5 do
            local arenaUnit = "arena" .. i
            local arenaUnitPet = "arenapet" .. i
            if unify then
                if unitCaster and (UnitIsUnit(arenaUnit, unitCaster) or UnitIsUnit(arenaUnitPet, unitCaster)) then
                    return arenaUnit
                end
            else
                if unitCaster and UnitIsUnit(arenaUnit, unitCaster) then
                    return arenaUnit
                end
                if unitCaster and UnitIsUnit(arenaUnitPet, unitCaster) then
                    return arenaUnitPet
                end
            end
        end
    end
end

function Gladdy:ShallowCopy(table)
    local copy
    if type(table) == 'table' then
        copy = {}
        for k,v in pairs(table) do
            copy[k] = v
        end
    else -- number, string, boolean, etc
        copy = table
    end
    return copy
end

function Gladdy:DeepCopy(table)
    local copy
    if type(table) == 'table' then
        copy = {}
        for k,v in pairs(table) do
            if type(v) == 'table' then
                copy[k] = self:DeepCopy(v)
            else -- number, string, boolean, etc
                copy[k] = v
            end
        end
    else -- number, string, boolean, etc
        copy = table
    end
    return copy
end

function Gladdy:AddEntriesToTable(table, entries)
    for k,v in pairs(entries) do
        if not table[k] then
            table[k] = v
        end
    end
end

function Gladdy:RemoveEntriesFromTable(table, entries)
    for _,v in pairs(entries) do
        if table[v] then
            table[v] = nil
        end
    end
end

function Gladdy:GetExceptionSpellName(spellID)
    for k,v in pairs(Gladdy.exceptionNames) do
        if k == spellID and Gladdy:GetImportantAuras()[v] and Gladdy:GetImportantAuras()[v].altName then
            return Gladdy:GetImportantAuras()[v].altName
        end
    end
    return select(1, GetSpellInfo(spellID))
end

local function toHex(color)
    if not color or not color.r or not color.g or not color.b then
        return "000000"
    end
    return str_format("%.2x%.2x%.2x", floor(color.r * 255), floor(color.g * 255), floor(color.b * 255))
end
function Gladdy:SetTextColor(text, color)
    return "|cff" .. toHex(color) .. text or "" .. "|r"
end

function Gladdy:SetRGBTextColor(text, r, g, b)
    r, g, b = self:RGBtoDecimal(r, g, b)
    Gladdy:SetTextColor(text, { r = r, g = g, b = b })
end

function Gladdy:ColorAsArray(color)
    return {color.r, color.g, color.b, color.a}
end

function Gladdy:RGBtoDecimal(r, g, b)
    return floor(r/255), floor(g/255), floor(b/255)
end

function Gladdy:Dump(table, space)
    if type(table) ~= "table" then
        return
    end
    if not space then
        space = ""
    end
    for k,v in pairs(table) do
        Gladdy:Print(space .. k .. " - ", v)
        if type(v) == "table" then
            Gladdy:Dump(v, space .. " ")
        end
    end
end

function Gladdy:GetSpellDescription(spellID, cooldown) -- GetSpellPowerCost(51052) GetSpellDescription(2983)
    local cost = (GetSpellPowerCost(spellID) and GetSpellPowerCost(spellID)[1] and (GetSpellPowerCost(spellID)[1].cost .. " " .. _G[GetSpellPowerCost(spellID)[1].name])) or ""
    cost = cost .. (cost ~= "" and "\n\n" or "")
    local castTimeInfo = select(4, GetSpellInfo(spellID))
    local castTime = tonumber(castTimeInfo)

    castTime = (castTime <= 0 and "Instant" or castTime / 1000 .. "s") .. "\n\n"
    local str = ""
    if cooldown then
        --[586] = { cd = 30, [L["Shadow"]] = 15, }
        if type(cooldown) == "table" then
            local defaultCD = cooldown.cd .. "s" .. " cd" .. "\n"

            local spec = cooldown.spec or cooldown.notSpec
            if spec and not cooldown.sharedCD then
                str = str .. ((cooldown.spec and "") or (cooldown.notSpec and "NOT ")) .. (cooldown.spec or cooldown.notSpec) .. " : " .. defaultCD
            else
                str = str .. defaultCD
                for k,v in pairs(cooldown) do
                    if k ~= "cd" and k ~= "pet" and k ~= "sharedCD" and k ~= "notSpec" then
                        str = str .. k .. " : " .. v .. "s" .. " cd" .. "\n"
                    end
                end
            end
            str = str .. "\n"
        else
            str = str .. cooldown .. "s" .. " cd" .. "\n\n"
        end
    end
    str = str .. castTime
    local desc = GetSpellDescription(spellID)
    if not desc or desc == "" then
        for i=1, 100 do
            desc = GetSpellDescription(spellID)
            if desc and desc ~= "" then
                break
            end
        end
    end
    str = str .. Gladdy:SetTextColor(desc, {r = 1, g=0.82, b=0})
    str = str .. "\n\n" .. Gladdy:SetTextColor("spell id = ".. spellID, {r = 0, g=0.82, b=0})
    return str
end

function Gladdy:CacheSpells()
    local co = coroutine.create(function()
        local id = 0
        local misses = 0
        while misses < 50000 do
            id = id + 1
            local name, _, icon = GetSpellInfo(id)

            if(icon == 136243) then -- 136243 is the a gear icon, we can ignore those spells
                misses = 0;
            elseif name and name ~= "" and icon then
                Gladdy.spellCache[name] = Gladdy.spellCache[name] or {}
                Gladdy.spellCache[name].spells = Gladdy.spellCache[name].spells or {}
                tinsert(Gladdy.spellCache[name].spells, {
                    spellID = id,
                    icon = icon,
                    spellName = name
                })
                misses = 0
            else
                misses = misses + 1
            end
            coroutine.yield()
        end
    end)
    Gladdy.coroutineFrame = CreateFrame("Frame")
    Gladdy.coroutineFrame.update = {}
    Gladdy.coroutineFrame.update["spellCache"] = co
    Gladdy.coroutineFrame:SetScript("OnUpdate", function(self, elapsed)
        -- Start timing
        local start = debugprofilestop()
        local hasData = true

        -- Resume as often as possible (Limit to 16ms per frame -> 60 FPS)
        while (debugprofilestop() - start < 16 and hasData) do
            -- Stop loop without data
            hasData = false

            -- Resume all coroutines
            for name, func in pairs(self.update) do
                -- Loop has data
                hasData = true

                -- Resume or remove
                if coroutine.status(func) ~= "dead" then
                    local ok, msg = coroutine.resume(func)
                    if not ok then
                        geterrorhandler()(msg .. '\n' .. debugstack(func))
                    end
                else
                    Gladdy:Debug("INFO", "done with coroutine " .. name)
                    self.update[name] = nil
                end
            end
            if next(self.update) == nil then
                self:SetScript("OnUpdate", nil)
                Gladdy:Debug("INFO",elapsed)
                Gladdy:Debug("INFO", "done with all corutines in coroutineFrame")
                break
            end
        end
    end)
end

local Predictor = {}
function Predictor:Initialize()
end
function Predictor:GetValues(text, values, max)
    values = {}
    if text and text ~= "" then
        if tonumber(text) then
            local spellName,_,icon = GetSpellInfo(text)
            if spellName then
                values[tonumber(text)] = {
                    text = spellName .. " - (" .. text .. ")",
                    icon = icon
                }
                return values
            end
        end

        --init spell cache
        if not Gladdy.spellCache then
            Gladdy.spellCache = {}
            Gladdy:CacheSpells()
        end
        for k,v in pairs(Gladdy.spellCache) do
            local status, result = pcall(str_match, k:lower(), "^" .. text:lower())
            if status and result then
                for _,tbl in ipairs(v.spells) do
                    values[tbl.spellID] = {
                        text = tbl.spellName .. " - (" .. tbl.spellID .. ")",
                        icon = tbl.icon
                    }
                end
            end
        end
    end
    return values
end
function Predictor:GetValue(text, key)
    return key
end
function Predictor:GetHyperlink(key)
    return "spell:" .. key .. ":0"
end
LibStub("AceGUI-3.0-GladdySearchEditBox"):Register("Auras", Predictor)


local function replace(str)
    return str:gsub("%s", "%%s"):gsub("%-", "%%-")
end

function Gladdy:SearchAllSpellIdsBySpellId(spellId)
    local values =  {}
    if spellId then
        local text,_,texture = GetSpellInfo(spellId)
        if text and texture then
            --init spell cache
            if not Gladdy.spellCache then
                Gladdy.spellCache = {}
                Gladdy:CacheSpells()
            end
            for k,v in pairs(Gladdy.spellCache) do
                local status, result = pcall(str_match, k:lower(), "^" .. replace(text:lower()))
                if status and result then
                    for _,tbl in ipairs(v.spells) do
                        if tbl.icon == texture and tbl.spellName == text then
                            tinsert(values, tbl.spellID)
                        end
                    end
                end
            end
        end
    end
    return values
end