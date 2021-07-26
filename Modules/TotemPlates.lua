local select, pairs, string_lower, tremove, tinsert, format, string_gsub, ipairs = select, pairs, string.lower, tremove, tinsert, format, string.gsub, ipairs
local UnitExists, UnitIsUnit, UnitName, UnitIsEnemy = UnitExists, UnitIsUnit, UnitName, UnitIsEnemy
local C_NamePlate = C_NamePlate
local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local GetSpellInfo, CreateFrame, GetCVar = GetSpellInfo, CreateFrame, GetCVar

---------------------------------------------------

-- Constants

---------------------------------------------------

local totemData = {
    -- Fire
    [string_lower("Searing Totem")] = {id = 3599,texture = select(3, GetSpellInfo(3599)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Searing Totem
    [string_lower("Flametongue Totem")] = {id = 8227,texture = select(3, GetSpellInfo(8227)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Flametongue Totem
    [string_lower("Magma Totem")] = {id = 8190,texture = select(3, GetSpellInfo(8190)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Magma Totem
    [string_lower("Fire Nova Totem")] = {id = 1535,texture = select(3, GetSpellInfo(1535)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Nova Totem
    [string_lower("Totem of Wrath")] = {id = 30706,texture = select(3, GetSpellInfo(30706)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 1}, -- Totem of Wrath
    [string_lower("Fire Elemental Totem")] = {id = 32982,texture = select(3, GetSpellInfo(32982)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Elemental Totem
    [string_lower("Frost Resistance Totem")] = {id = 8181,texture = select(3, GetSpellInfo(8181)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Frost Resistance Totem
    -- Water
    [string_lower("Fire Resistance Totem")] = {id = 8184,texture = select(3, GetSpellInfo(8184)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Fire Resistance Totem
    [string_lower("Poison Cleansing Totem")] = {id = 8166,texture = select(3, GetSpellInfo(8166)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Poison Cleansing Totem
    [string_lower("Disease Cleansing Totem")] = {id = 8170,texture = select(3, GetSpellInfo(8170)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Disease Cleansing Totem
    [string_lower("Healing Stream Totem")] = {id = 5394,texture = select(3, GetSpellInfo(5394)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Healing Stream Totem
    [string_lower("Mana Tide Totem")] = {id = 16190,texture = select(3, GetSpellInfo(16190)), color = {r = 0.078, g = 0.9, b = 0.16, a = 1}, enabled = true, priority = 3}, -- Mana Tide Totem
    [string_lower("Mana Spring Totem")] = {id = 5675,texture = select(3, GetSpellInfo(5675)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 1}, -- Mana Spring Totem
    -- Earth
    [string_lower("Earthbind Totem")] = {id = 2484,texture = select(3, GetSpellInfo(2484)), color = {r = 0.5, g = 0.5, b = 0.5, a = 1}, enabled = true, priority = 1}, -- Earthbind Totem
    [string_lower("Stoneclaw Totem")] = {id = 5730,texture = select(3, GetSpellInfo(5730)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Stoneclaw Totem
    [string_lower("Stoneskin Totem")] = {id = 8071,texture = select(3, GetSpellInfo(8071)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Stoneskin Totem
    [string_lower("Strength of Earth Totem")] = {id = 8075,texture = select(3, GetSpellInfo(8075)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Strength of Earth Totem
    [string_lower("Earth Elemental Totem")] = {id = 33663,texture = select(3, GetSpellInfo(33663)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Earth Elemental Totem
    [string_lower("Tremor Totem")] = {id = 8143,texture = select(3, GetSpellInfo(8143)), color = {r = 1, g = 0.9, b = 0.1, a = 1}, enabled = true, priority = 3}, -- Tremor Totem
    -- Air
    [string_lower("Grounding Totem")] = {id = 8177,texture = select(3, GetSpellInfo(8177)), color = {r = 0, g = 0.53, b = 0.92, a = 1}, enabled = true, priority = 3}, -- Grounding Totem
    [string_lower("Grace of Air Totem")] = {id = 8835,texture = select(3, GetSpellInfo(8835)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Grace of Air Totem
    [string_lower("Nature Resistance Totem")] = {id = 10595,texture = select(3, GetSpellInfo(10595)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Nature Resistance Totem
    [string_lower("Windfury Totem")] = {id = 8512,texture = select(3, GetSpellInfo(8512)), color = {r = 0.96, g = 0, b = 0.07, a = 1}, enabled = true, priority = 2}, -- Windfury Totem
    [string_lower("Sentry Totem")] = {id = 6495, texture = select(3, GetSpellInfo(6495)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Sentry Totem
    [string_lower("Windwall Totem")] = {id = 15107,texture = select(3, GetSpellInfo(15107)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Windwall Totem
    [string_lower("Wrath of Air Totem")] = {id = 3738,texture = select(3, GetSpellInfo(3738)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Wrath of Air Totem
    [string_lower("Tranquil Air Totem")] = {id = 25908,texture = select(3, GetSpellInfo(25908)), color = {r = 0, g = 0, b = 0, a = 1}, enabled = true, priority = 0}, -- Tranquil Air Totem
}
local localizedTotemData = {
    ["default"] = {
        [string_lower(select(1, GetSpellInfo(3599)))] = totemData[string_lower("Searing Totem")], -- Searing Totem
        [string_lower(select(1, GetSpellInfo(8227)))] = totemData[string_lower("Flametongue Totem")], -- Flametongue Totem
        [string_lower(select(1, GetSpellInfo(8190)))] = totemData[string_lower("Magma Totem")], -- Magma Totem
        [string_lower(select(1, GetSpellInfo(1535)))] = totemData[string_lower("Fire Nova Totem")], -- Fire Nova Totem
        [string_lower(select(1, GetSpellInfo(30706)))] = totemData[string_lower("Totem of Wrath")], -- Totem of Wrath
        [string_lower(select(1, GetSpellInfo(32982)))] = totemData[string_lower("Fire Elemental Totem")], -- Fire Elemental Totem
        [string_lower(select(1, GetSpellInfo(8181)))] = totemData[string_lower("Frost Resistance Totem")], -- Frost Resistance Totem
        -- Water
        [string_lower(select(1, GetSpellInfo(8184)))] = totemData[string_lower("Fire Resistance Totem")], -- Fire Resistance Totem
        [string_lower(select(1, GetSpellInfo(8166)))] = totemData[string_lower("Poison Cleansing Totem")], -- Poison Cleansing Totem
        [string_lower(select(1, GetSpellInfo(8170)))] = totemData[string_lower("Disease Cleansing Totem")], -- Disease Cleansing Totem
        [string_lower(select(1, GetSpellInfo(5394)))] = totemData[string_lower("Healing Stream Totem")], -- Healing Stream Totem
        [string_lower(select(1, GetSpellInfo(16190)))] = totemData[string_lower("Mana Tide Totem")], -- Mana Tide Totem
        [string_lower(select(1, GetSpellInfo(5675)))] = totemData[string_lower("Mana Spring Totem")], -- Mana Spring Totem
        -- Earth
        [string_lower(select(1, GetSpellInfo(2484)))] = totemData[string_lower("Earthbind Totem")], -- Earthbind Totem
        [string_lower(select(1, GetSpellInfo(5730)))] = totemData[string_lower("Stoneclaw Totem")], -- Stoneclaw Totem
        [string_lower(select(1, GetSpellInfo(8071)))] = totemData[string_lower("Stoneskin Totem")], -- Stoneskin Totem
        [string_lower(select(1, GetSpellInfo(8075)))] = totemData[string_lower("Strength of Earth Totem")], -- Strength of Earth Totem
        [string_lower(select(1, GetSpellInfo(33663)))] = totemData[string_lower("Earth Elemental Totem")], -- Earth Elemental Totem
        [string_lower(select(1, GetSpellInfo(8143)))] = totemData[string_lower("Tremor Totem")], -- Tremor Totem
        -- Air
        [string_lower(select(1, GetSpellInfo(8177)))] = totemData[string_lower("Grounding Totem")], -- Grounding Totem
        [string_lower(select(1, GetSpellInfo(8835)))] = totemData[string_lower("Grace of Air Totem")], -- Grace of Air Totem
        [string_lower(select(1, GetSpellInfo(10595)))] = totemData[string_lower("Nature Resistance Totem")], -- Nature Resistance Totem
        [string_lower(select(1, GetSpellInfo(8512)))] = totemData[string_lower("Windfury Totem")], -- Windfury Totem
        [string_lower(select(1, GetSpellInfo(6495)))] = totemData[string_lower("Sentry Totem")], -- Sentry Totem
        [string_lower(select(1, GetSpellInfo(15107)))] = totemData[string_lower("Windwall Totem")], -- Windwall Totem
        [string_lower(select(1, GetSpellInfo(3738)))] = totemData[string_lower("Wrath of Air Totem")], -- Wrath of Air Totem
        [string_lower(select(1, GetSpellInfo(25908)))] = totemData[string_lower("Tranquil Air Totem")], -- Tranquil Air Totem
    },
    ["frFR"] = {
        [string_lower("Totem d'\195\169lementaire de terre")] = totemData[string_lower("Earth Elemental Totem")], -- Earth Elemental Totem
        [string_lower("Totem d'\195\169lementaire de feu")] = totemData[string_lower("Fire Elemental Totem")], -- Fire Elemental Totem
    },
    ["ruRU"] = {
        [string_lower("")] = totemData[string_lower("Sentry Totem")], -- Sentry Totem
    }
}

local function GetTotemColorDefaultOptions()
    local defaultDB = {}
    local options = {}
    local indexedList = {}
    for k,v in pairs(totemData) do
        tinsert(indexedList, {name = k, id = v.id, color = v.color, texture = v.texture, enabled = v.enabled})
    end
    table.sort(indexedList, function (a, b)
        return a.name < b.name
    end)
    for i=1,#indexedList do
        defaultDB["totem" .. indexedList[i].id] = {color = indexedList[i].color, enabled = indexedList[i].enabled, alpha = 0.6, customText = ""}
        options["totem" .. indexedList[i].id] = {
            order = i+1,
            name = select(1, GetSpellInfo(indexedList[i].id)),
            --inline = true,
            width  = "3.0",
            type = "group",
            icon = indexedList[i].texture,
            args = {
                headerTotemConfig = {
                    type = "header",
                    name = format("|T%s:20|t %s", indexedList[i].texture, select(1, GetSpellInfo(indexedList[i].id))),
                    order = 1,
                },
                enabled = {
                    order = 2,
                    name = L["Enabled"],
                    desc = "Enable " .. format("|T%s:20|t %s", indexedList[i].texture, select(1, GetSpellInfo(indexedList[i].id))),
                    type = "toggle",
                    width = "full",
                    get = function(info) return Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].enabled end,
                    set = function(info, value)
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].enabled = value
                        Gladdy:UpdateFrame()
                    end
                },
                color = {
                    type = "color",
                    name = L["Border color"],
                    desc = L["Color of the border"],
                    order = 3,
                    hasAlpha = true,
                    width = "full",
                    get = function(info)
                        local key = info.arg or info[#info]
                        return Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.r,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.g,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.b,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.a
                    end,
                    set = function(info, r, g, b, a)
                        local key = info.arg or info[#info]
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.r,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.g,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.b,
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].color.a = r, g, b, a
                        Gladdy:UpdateFrame()
                    end,
                },
                alpha = {
                    type = "range",
                    name = L["Alpha"],
                    order = 4,
                    min = 0,
                    max = 1,
                    step = 0.1,
                    width = "full",
                    get = function(info)
                        return Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].alpha
                    end,
                    set = function(info, value)
                        Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id].alpha = value
                        Gladdy:UpdateFrame()
                    end
                },
                customText = {
                    type = "input",
                    name = L["Custom totem name"],
                    order = 5,
                    width = "full",
                    get = function(info) return Gladdy.db.npTotemColors["totem" .. indexedList[i].id].customText end,
                    set = function(info, value) Gladdy.db.npTotemColors["totem" .. indexedList[i].id].customText = value Gladdy:UpdateFrame() end
                },
            }
        }
    end
    return defaultDB, options, indexedList
end

local function GetTotemOptions()
    local indexedList = select(3, GetTotemColorDefaultOptions())
    local colorList = {}
    for i=1, #indexedList do
        tinsert(colorList, Gladdy.dbi.profile.npTotemColors["totem" .. indexedList[i].id])
    end
    return colorList
end

function Gladdy:GetTotemColors()
    return GetTotemColorDefaultOptions()
end

---------------------------------------------------

-- Core

---------------------------------------------------

local TotemPlates = Gladdy:NewModule("Totem Plates", nil, {
    npTotems = true,
    npTotemsShowFriendly = true,
    npTotemsShowEnemy = true,
    npTotemPlatesBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    npTotemPlatesSize = 40,
    npTotemPlatesWidthFactor = 1,
    npTremorFont = "DorisPP",
    npTremorFontSize = 10,
    npTremorFontXOffset = 0,
    npTremorFontYOffset = 0,
    npTotemPlatesAlpha = 0.6,
    npTotemPlatesAlphaAlways = false,
    npTotemPlatesAlphaAlwaysTargeted = false,
    npTotemColors = select(1, GetTotemColorDefaultOptions())
})

LibStub("AceHook-3.0"):Embed(TotemPlates)
LibStub("AceTimer-3.0"):Embed(TotemPlates)

function TotemPlates.OnEvent(self, event, ...)
    TotemPlates[event](self, ...)
end

function TotemPlates:Initialize()
    self.numChildren = 0
    self.activeTotemNameplates = {}
    self.totemPlateCache = {}
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("UNIT_NAME_UPDATE")
    self:SetScript("OnEvent", TotemPlates.OnEvent)
    if Gladdy.db.npTotems and Gladdy.db.npTotemsShowEnemy then
        --GetCVar("nameplateShowEnemyTotems")
        --SetCVar("nameplateShowEnemyTotems", true);
    end
    if Gladdy.db.npTotems and Gladdy.db.npTotemsShowFriendly then
        --GetCVar("nameplateShowFriendlyTotems")
        --SetCVar("nameplateShowFriendlyTotems", true);
    end
    self.addon = "Blizzard"
    if (IsAddOnLoaded("Plater")) then
        self.addon = "Plater"
    elseif (IsAddOnLoaded("Kui_Nameplates")) then
        self.addon = "Kui_Nameplates"
    elseif (IsAddOnLoaded("NeatPlates")) then
        self.addon = "NeatPlates"
    elseif (IsAddOnLoaded("TidyPlates_ThreatPlates")) then
        self.addon = "TidyPlates_ThreatPlates"
    elseif (IsAddOnLoaded("Tukui")) then
        local _, C, _ = Tukui:unpack()
        if C.NamePlates.Enable then
            self.addon = "Tukui"
        end
    elseif (IsAddOnLoaded("ElvUI")) then
        local E = unpack(ElvUI)
        if E.private.nameplates.enable then
            self.addon = "ElvUI"
        end
    end
end

function TotemPlates:PLAYER_ENTERING_WORLD()
    self.numChildren = 0
    self.activeTotemNameplates = {}
end

function TotemPlates:Reset()
    --self:CancelAllTimers()
    --self:UnhookAll()
end

function TotemPlates:UpdateFrameOnce()
    for k,nameplate in pairs(self.activeTotemNameplates) do
        local totemDataEntry = nameplate.gladdyTotemFrame.totemDataEntry
        nameplate.gladdyTotemFrame:SetWidth(Gladdy.db.npTotemPlatesSize * Gladdy.db.npTotemPlatesWidthFactor)
        nameplate.gladdyTotemFrame:SetHeight(Gladdy.db.npTotemPlatesSize)
        nameplate.gladdyTotemFrame.totemBorder:SetTexture(Gladdy.db.npTotemPlatesBorderStyle)
        nameplate.gladdyTotemFrame.totemBorder:SetVertexColor(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.r,
                Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.g,
                Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.b,
                Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.a)
        nameplate.gladdyTotemFrame.totemName:SetPoint("TOP", nameplate.gladdyTotemFrame, "BOTTOM", Gladdy.db.npTremorFontXOffset, Gladdy.db.npTremorFontYOffset)
        nameplate.gladdyTotemFrame.totemName:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npTremorFont), Gladdy.db.npTremorFontSize, "OUTLINE")
        nameplate.gladdyTotemFrame.totemName:SetText(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].customText or "")
        self:SetTotemAlpha(nameplate.gladdyTotemFrame, k)

        if not Gladdy.db.npTotems then
            nameplate.gladdyTotemFrame:Hide()
            self:ToggleAddon(nameplate, true)
        else
            nameplate.gladdyTotemFrame:Show()
            self:ToggleAddon(nameplate)
        end
        local isEnemy = UnitIsEnemy("player", nameplate.gladdyTotemFrame.unitID)
        if Gladdy.db.npTotems and Gladdy.db.npTotemsShowEnemy and isEnemy then
            nameplate.gladdyTotemFrame:Show()
            self:ToggleAddon(nameplate)
        elseif Gladdy.db.npTotems and not Gladdy.db.npTotemsShowEnemy and isEnemy then
            nameplate.gladdyTotemFrame:Hide()
            self:ToggleAddon(nameplate, true)
        end
        if Gladdy.db.npTotems and Gladdy.db.npTotemsShowFriendly and not isEnemy then
            nameplate.gladdyTotemFrame:Show()
            self:ToggleAddon(nameplate)
        elseif not Gladdy.db.npTotemsShowFriendly and not isEnemy then
            nameplate.gladdyTotemFrame:Hide()
            self:ToggleAddon(nameplate, true)
        end
    end
    for _,gladdyTotemFrame in ipairs(self.totemPlateCache) do
        gladdyTotemFrame:SetWidth(Gladdy.db.npTotemPlatesSize * Gladdy.db.npTotemPlatesWidthFactor)
        gladdyTotemFrame:SetHeight(Gladdy.db.npTotemPlatesSize)
        gladdyTotemFrame.totemBorder:SetTexture(Gladdy.db.npTotemPlatesBorderStyle)
        gladdyTotemFrame.totemName:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npTremorFont), Gladdy.db.npTremorFontSize, "OUTLINE")
        gladdyTotemFrame.totemName:SetPoint("TOP", gladdyTotemFrame, "BOTTOM", Gladdy.db.npTremorFontXOffset, Gladdy.db.npTremorFontYOffset)
    end
end

---------------------------------------------------

-- TotemPlates Frame

---------------------------------------------------

function TotemPlates:CreateTotemFrame(nameplate)
    nameplate.gladdyTotemFrame = CreateFrame("Frame")
    nameplate.gladdyTotemFrame:SetIgnoreParentAlpha(true)
    nameplate.gladdyTotemFrame:SetWidth(Gladdy.db.npTotemPlatesSize * Gladdy.db.npTotemPlatesWidthFactor)
    nameplate.gladdyTotemFrame:SetHeight(Gladdy.db.npTotemPlatesSize)
    nameplate.gladdyTotemFrame.totemIcon = nameplate.gladdyTotemFrame:CreateTexture(nil, "BACKGROUND")
    nameplate.gladdyTotemFrame.totemIcon:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    nameplate.gladdyTotemFrame.totemIcon:ClearAllPoints()
    nameplate.gladdyTotemFrame.totemIcon:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT")
    nameplate.gladdyTotemFrame.totemIcon:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT")
    nameplate.gladdyTotemFrame.totemBorder = nameplate.gladdyTotemFrame:CreateTexture(nil, "BORDER")
    nameplate.gladdyTotemFrame.totemBorder:ClearAllPoints()
    nameplate.gladdyTotemFrame.totemBorder:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT")
    nameplate.gladdyTotemFrame.totemBorder:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT")
    nameplate.gladdyTotemFrame.totemBorder:SetTexture(Gladdy.db.npTotemPlatesBorderStyle)
    nameplate.gladdyTotemFrame.totemName = nameplate.gladdyTotemFrame:CreateFontString(nil, "OVERLAY")
    nameplate.gladdyTotemFrame.totemName:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.npTremorFont), Gladdy.db.npTremorFontSize, "OUTLINE")
    nameplate.gladdyTotemFrame.totemName:SetPoint("TOP", nameplate.gladdyTotemFrame, "BOTTOM", Gladdy.db.npTremorFontXOffset, Gladdy.db.npTremorFontYOffset)
    nameplate.gladdyTotemFrame.selectionHighlight = nameplate.gladdyTotemFrame:CreateTexture(nil, "OVERLAY")
    nameplate.gladdyTotemFrame.selectionHighlight:SetTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
    nameplate.gladdyTotemFrame.selectionHighlight:SetAlpha(0)
    nameplate.gladdyTotemFrame.selectionHighlight:SetBlendMode("ADD")
    nameplate.gladdyTotemFrame.selectionHighlight:SetIgnoreParentAlpha(true)
    nameplate.gladdyTotemFrame.selectionHighlight:SetPoint("TOPLEFT", nameplate.gladdyTotemFrame, "TOPLEFT", Gladdy.db.npTotemPlatesSize/16, -Gladdy.db.npTotemPlatesSize/16)
    nameplate.gladdyTotemFrame.selectionHighlight:SetPoint("BOTTOMRIGHT", nameplate.gladdyTotemFrame, "BOTTOMRIGHT", -Gladdy.db.npTotemPlatesSize/16, Gladdy.db.npTotemPlatesSize/16)
    nameplate.gladdyTotemFrame:SetScript('OnUpdate', TotemPlates.OnUpdate)
    nameplate.gladdyTotemFrame:SetScript("OnHide", function(self)
        self.parent = nil
        self:SetParent(nil)
    end)
end

---------------------------------------------------

-- Nameplate functions

---------------------------------------------------

function TotemPlates:GetAddonFrame(nameplate)
    if self.addon == "Blizzard" then
        if nameplate.UnitFrame then
            return nameplate.UnitFrame
        end
    elseif self.addon == "Plater" or self.addon == "Tukui" or self.addon == "ElvUI" then
        if nameplate.unitFrame then
            return nameplate.unitFrame
        end
    elseif self.addon == "Kui_Nameplates" then
        if nameplate.kui then
            return nameplate.kui
        end
    elseif self.addon == "NeatPlates" then
        if nameplate.extended or nameplate.carrier then
            return nameplate.extended , nameplate.carrier
        end
    elseif self.addon == "TidyPlates_ThreatPlates" then
        if nameplate.TPFrame then
            return nameplate.TPFrame
        end
    end
end

function TotemPlates:PLAYER_TARGET_CHANGED()
    for k,nameplate in pairs(self.activeTotemNameplates) do
        TotemPlates:SetTotemAlpha(nameplate.gladdyTotemFrame, k)
    end
end

function TotemPlates:ToggleAddon(nameplate, show)
    local addonFrames = { self:GetAddonFrame(nameplate) }
    if addonFrames and #addonFrames > 0 then
        if show then
            for i,v in ipairs(addonFrames) do
                v:Show()
            end
        else
            for i,v in ipairs(addonFrames) do
                v:Hide()
            end
        end
    end
end

function TotemPlates.OnUpdate(self)
    if (UnitIsUnit("mouseover", self.unitID) or UnitIsUnit("target", self.unitID)) then
        self.selectionHighlight:SetAlpha(.25)
    else
        self.selectionHighlight:SetAlpha(0)
    end
    if (TotemPlates.addon == "Plater" or TotemPlates.addon == "Tukui" or TotemPlates.addon == "ElvUI") and self.parent and self.parent.unitFrame then
        self.parent.unitFrame:Hide()
    end
end

function TotemPlates:OnUnitEvent(unitID)
    local isEnemy = UnitIsEnemy("player", unitID)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    if not nameplate then
        return
    end
    if not Gladdy.db.npTotems then
        self:ToggleAddon(nameplate, true)
        return
    end
    if not Gladdy.db.npTotemsShowEnemy and isEnemy then
        self:ToggleAddon(nameplate, true)
        return
    end
    if not Gladdy.db.npTotemsShowFriendly and not isEnemy then
        self:ToggleAddon(nameplate, true)
        return
    end
    local nameplateName = UnitName(unitID)
    local totemName = string_gsub(nameplateName, "^%s+", "") --trim
    totemName = string_gsub(totemName, "%s+$", "") --trim
    totemName = string_gsub(totemName, "%s+[I,V,X]+$", "") --trim rank
    totemName = string_lower(totemName)
    local totemDataEntry = localizedTotemData["default"][totemName] or localizedTotemData["frFR"][totemName] or localizedTotemData["ruRU"][totemName]
    if totemDataEntry and Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].enabled then-- modify this nameplates
        if #self.totemPlateCache > 0 then
            nameplate.gladdyTotemFrame = tremove(self.totemPlateCache, #self.totemPlateCache)
        else
            self:CreateTotemFrame(nameplate)
        end
        nameplate.gladdyTotemFrame.unitID = unitID
        nameplate.gladdyTotemFrame.totemDataEntry = totemDataEntry
        nameplate.gladdyTotemFrame.parent = nameplate
        nameplate.gladdyTotemFrame:SetParent(nameplate)
        nameplate.gladdyTotemFrame:ClearAllPoints()
        nameplate.gladdyTotemFrame:SetPoint("CENTER", nameplate, "CENTER", 0, 0)
        nameplate.gladdyTotemFrame.totemIcon:SetTexture(totemDataEntry.texture)
        nameplate.gladdyTotemFrame.totemBorder:SetVertexColor(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.r,
                Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.g,
                Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.b,
                Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].color.a)
        nameplate.gladdyTotemFrame.totemName:SetText(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].customText or "")
        nameplate.gladdyTotemFrame.parent = nameplate
        nameplate.gladdyTotemFrame:Show()
        TotemPlates:SetTotemAlpha(nameplate.gladdyTotemFrame, unitID)
        self:ToggleAddon(nameplate)
        self.activeTotemNameplates[unitID] = nameplate
    else
        self:ToggleAddon(nameplate, true)
    end
end

function TotemPlates:NAME_PLATE_UNIT_ADDED(...)
    self:OnUnitEvent(...)
end

function TotemPlates:UNIT_NAME_UPDATE(...)
    self:OnUnitEvent(...)
end

function TotemPlates:NAME_PLATE_UNIT_REMOVED(...)
    local unitID = ...
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    self.activeTotemNameplates[unitID] = nil
    --self:ToggleAddon(nameplate, true)
    if nameplate.gladdyTotemFrame then
        nameplate.gladdyTotemFrame:Hide()
        nameplate.gladdyTotemFrame:SetParent(nil)
        tinsert(self.totemPlateCache, nameplate.gladdyTotemFrame)
        nameplate.gladdyTotemFrame = nil
    end
end

function TotemPlates:SetTotemAlpha(gladdyTotemFrame, unitID)
    local targetExists = UnitExists("target")
    local totemDataEntry = gladdyTotemFrame.totemDataEntry
    if targetExists then
        if (UnitIsUnit(unitID, "target")) then -- is target
            if Gladdy.db.npTotemPlatesAlphaAlwaysTargeted then
                gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
            else
                gladdyTotemFrame:SetAlpha(1)
            end
        else -- is not target
            gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
        end
    else -- no target
        if Gladdy.db.npTotemPlatesAlphaAlways then
            gladdyTotemFrame:SetAlpha(Gladdy.db.npTotemColors["totem" .. totemDataEntry.id].alpha)
        else
            gladdyTotemFrame:SetAlpha(0.95)
        end
    end
end

---------------------------------------------------

-- Interface options

---------------------------------------------------

function TotemPlates:GetOptions()
    return {
        headerTotems = {
            type = "header",
            name = L["Totem Plates"],
            order = 2,
        },
        npTotems = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Turns totem icons instead of nameplates on or off. (Requires reload)"],
            order = 3,
            width = 0.9,
        }),
        npTotemsShowFriendly = Gladdy:option({
            type = "toggle",
            name = L["Show friendly"],
            desc = L["Turns totem icons instead of nameplates on or off. (Requires reload)"],
            order = 4,
            width = 0.65,
        }),
        npTotemsShowEnemy = Gladdy:option({
            type = "toggle",
            name = L["Show enemy"],
            desc = L["Turns totem icons instead of nameplates on or off. (Requires reload)"],
            order = 5,
            width = 0.6,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            args = {
                icon = {
                    type = "group",
                    name = L["Icon"],
                    order = 1,
                    args = {
                        header = {
                            type = "header",
                            name = L["Icon"],
                            order = 1,
                        },
                        npTotemPlatesSize = Gladdy:option({
                            type = "range",
                            name = L["Totem size"],
                            desc = L["Size of totem icons"],
                            order = 5,
                            min = 20,
                            max = 100,
                            step = 1,
                            width = "full",
                        }),
                        npTotemPlatesWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon Width Factor"],
                            desc = L["Stretches the icon"],
                            order = 6,
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            width = "full",
                        }),
                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 2,
                    args = {
                        header = {
                            type = "header",
                            name = L["Font"],
                            order = 1,
                        },
                        npTremorFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the custom totem name"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        npTremorFontSize = Gladdy:option({
                            type = "range",
                            name = L["Size"],
                            desc = L["Scale of the font"],
                            order = 12,
                            min = 1,
                            max = 50,
                            step = 0.1,
                            width = "full",
                        }),
                        npTremorFontXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            desc = L["Scale of the font"],
                            order = 13,
                            min = -300,
                            max = 300,
                            step = 1,
                            width = "full",
                        }),
                        npTremorFontYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            desc = L["Scale of the font"],
                            order = 14,
                            min = -300,
                            max = 300,
                            step = 1,
                            width = "full",
                        }),
                    },
                },
                alpha = {
                    type = "group",
                    name = L["Alpha"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Alpha"],
                            order = 1,
                        },
                        npTotemPlatesAlphaAlways = Gladdy:option({
                            type = "toggle",
                            name = L["Apply alpha when no target"],
                            desc = L["Always applies alpha, even when you don't have a target. Else it is 1."],
                            width = "full",
                            order = 21,
                        }),
                        npTotemPlatesAlphaAlwaysTargeted = Gladdy:option({
                            type = "toggle",
                            name = L["Apply alpha when targeted"],
                            desc = L["Always applies alpha, even when you target the totem. Else it is 1."],
                            width = "full",
                            order = 22,
                        }),
                        npAllTotemAlphas = {
                            type = "range",
                            name = L["All totem border alphas (configurable per totem)"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            width = "full",
                            order = 23,
                            get = function(info)
                                local alphas = GetTotemOptions()
                                for i=2, #alphas do
                                    if alphas[i].alpha ~= alphas[1].alpha then
                                        return ""
                                    end
                                end
                                return alphas[1].alpha
                            end,
                            set = function(info, value)
                                local alphas = GetTotemOptions()
                                for i=1, #alphas do
                                    alphas[i].alpha = value
                                end
                                Gladdy:UpdateFrame()
                            end,
                        },
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 5,
                    args = {
                        header = {
                            type = "header",
                            name = L["Border"],
                            order = 1,
                        },
                        npTotemPlatesBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Totem icon border style"],
                            order = 41,
                            values = Gladdy:GetIconStyles()
                        }),
                        npAllTotemColors = {
                            type = "color",
                            name = L["All totem border color"],
                            order = 42,
                            hasAlpha = true,
                            get = function(info)
                                local colors = GetTotemOptions()
                                local color = colors[1].color
                                for i=2, #colors do
                                    if colors[i].r ~= color.r or colors[i].color.r ~= color.r or colors[i].color.r ~= color.r or colors[i].color.r ~= color.r then
                                        return 0, 0, 0, 0
                                    end
                                end
                                return color.r, color.g, color.b, color.a
                            end,
                            set = function(info, r, g, b, a)
                                local colors = GetTotemOptions()
                                for i=1, #colors do
                                    colors[i].color.r = r
                                    colors[i].color.g = g
                                    colors[i].color.b = b
                                    colors[i].color.a = a
                                end
                                Gladdy:UpdateFrame()
                            end,
                        },
                    },
                },
            },
        },
        npTotemColors = {
            order = 50,
            name = L["Customize Totems"],
            type = "group",
            childGroups = "tree",
            args = select(2, Gladdy:GetTotemColors())
        },
    }
end