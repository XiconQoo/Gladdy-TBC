local setmetatable = setmetatable
local type = type
local tostring = tostring
local select = select
local pairs = pairs
local tinsert = table.insert
local tsort = table.sort
local CreateFrame = CreateFrame
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local IsAddOnLoaded = IsAddOnLoaded
local IsInInstance = IsInInstance
local GetBattlefieldStatus = GetBattlefieldStatus
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local RELEASE_TYPES = { alpha = "Alpha", beta = "Beta", release = "Release"}
local PREFIX = "TBC-Classic_v"
local VERSION_REGEX = PREFIX .. "(%d+%.%d+)%-(%a)"

---------------------------

-- CORE

---------------------------

local MAJOR, MINOR = "Gladdy", 4
local Gladdy = LibStub:NewLibrary(MAJOR, MINOR)
local L
Gladdy.version_major_num = 1
Gladdy.version_minor_num = 0.10
Gladdy.version_num = Gladdy.version_major_num + Gladdy.version_minor_num
Gladdy.version_releaseType = RELEASE_TYPES.beta
Gladdy.version = PREFIX .. Gladdy.version_num .. "-" .. Gladdy.version_releaseType
Gladdy.VERSION_REGEX = VERSION_REGEX

LibStub("AceTimer-3.0"):Embed(Gladdy)
LibStub("AceComm-3.0"):Embed(Gladdy)
Gladdy.modules = {}
setmetatable(Gladdy, {
    __tostring = function()
        return MAJOR
    end
})

function Gladdy:Print(...)
    local text = "|cff0384fcGladdy|r:"
    local val
    for i = 1, select("#", ...) do
        val = select(i, ...)
        if (type(val) == 'boolean') then val = val and "true" or false end
        text = text .. " " .. tostring(val)
    end
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

function Gladdy:Warn(...)
    local text = "|cfffc0303Gladdy|r:"
    local val
    for i = 1, select("#", ...) do
        val = select(i, ...)
        if (type(val) == 'boolean') then val = val and "true" or false end
        text = text .. " " .. tostring(val)
    end
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

Gladdy.events = CreateFrame("Frame")
Gladdy.events.registered = {}
Gladdy.events:RegisterEvent("PLAYER_LOGIN")
Gladdy.events:SetScript("OnEvent", function(self, event, ...)
    if (event == "PLAYER_LOGIN") then
        Gladdy:OnInitialize()
        Gladdy:OnEnable()
    else
        local func = self.registered[event]

        if (type(Gladdy[func]) == "function") then
            Gladdy[func](Gladdy, event, ...)
        end
    end
end)

function Gladdy:RegisterEvent(event, func)
    self.events.registered[event] = func or event
    self.events:RegisterEvent(event)
end
function Gladdy:UnregisterEvent(event)
    self.events.registered[event] = nil
    self.events:UnregisterEvent(event)
end
function Gladdy:UnregisterAllEvents()
    self.events.registered = {}
    self.events:UnregisterAllEvents()
end

---------------------------

-- MODULE FUNCTIONS

---------------------------

local function pairsByPrio(t)
    local a = {}
    for k, v in pairs(t) do
        tinsert(a, { k, v.priority })
    end
    tsort(a, function(x, y)
        return x[2] > y[2]
    end)

    local i = 0
    return function()
        i = i + 1

        if (a[i] ~= nil) then
            return a[i][1], t[a[i][1]]
        else
            return nil
        end
    end
end
function Gladdy:IterModules()
    return pairsByPrio(self.modules)
end

function Gladdy:Call(module, func, ...)
    if (type(module) == "string") then
        module = self.modules[module]
    end

    if (type(module[func]) == "function") then
        module[func](module, ...)
    end
end
function Gladdy:SendMessage(message, ...)
    for k, v in self:IterModules() do
        self:Call(v, v.messages[message], ...)
    end
end

function Gladdy:NewModule(name, priority, defaults)
    local module = CreateFrame("Frame")
    module.name = name
    module.priority = priority or 0
    module.defaults = defaults or {}
    module.messages = {}

    module.RegisterMessage = function(self, message, func)
        self.messages[message] = func or message
    end

    module.GetOptions = function()
        return nil
    end

    for k, v in pairs(module.defaults) do
        self.defaults.profile[k] = v
    end

    self.modules[name] = module

    return module
end

---------------------------

-- INIT

---------------------------

function Gladdy:DeleteUnknownOptions(tbl, refTbl, str)
    if str == nil then
        str = "Gladdy.db"
    end
    for k,v in pairs(tbl) do
        if refTbl[k] == nil then
            --Gladdy:Print("SavedVariable deleted:", str .. "." .. k, "not found!")
            tbl[k] = nil
        else
            if type(v) ~= type(refTbl[k]) then
                --Gladdy:Print("SavedVariable deleted:", str .. "." .. k, "type error!", "Expected", type(refTbl[k]), "but found", type(v))
                tbl[k] = nil
            elseif type(v) == "table" then
                Gladdy:DeleteUnknownOptions(v, refTbl[k], str .. "." .. k)
            end
        end
    end
end

function Gladdy:OnInitialize()
    self.dbi = LibStub("AceDB-3.0"):New("GladdyXZ", self.defaults)
    self.dbi.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.dbi.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.dbi.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    self.db = self.dbi.profile

    self.LSM = LibStub("LibSharedMedia-3.0")
    self.LSM:Register("statusbar", "Gloss", "Interface\\AddOns\\Gladdy\\Images\\Gloss")
    self.LSM:Register("statusbar", "Smooth", "Interface\\AddOns\\Gladdy\\Images\\Smooth")
    self.LSM:Register("statusbar", "Minimalist", "Interface\\AddOns\\Gladdy\\Images\\Minimalist")
    self.LSM:Register("statusbar", "LiteStep", "Interface\\AddOns\\Gladdy\\Images\\LiteStep.tga")
    self.LSM:Register("border", "Gladdy Tooltip round", "Interface\\AddOns\\Gladdy\\Images\\UI-Tooltip-Border_round_selfmade")
    self.LSM:Register("border", "Gladdy Tooltip squared", "Interface\\AddOns\\Gladdy\\Images\\UI-Tooltip-Border_square_selfmade")
    self.LSM:Register("font", "DorisPP", "Interface\\AddOns\\Gladdy\\Images\\DorisPP.TTF")

    L = self.L

    self.testData = {
        ["arena1"] = { name = "Swift", raceLoc = L["Tauren"], classLoc = L["Warrior"], class = "WARRIOR", health = 9635, healthMax = 14207, power = 76, powerMax = 100, powerType = 1, testSpec = L["Arms"], race = "Tauren" },
        ["arena2"] = { name = "Vilden", raceLoc = L["Undead"], classLoc = L["Mage"], class = "MAGE", health = 10969, healthMax = 11023, power = 7833, powerMax = 10460, powerType = 0, testSpec = L["Frost"], race = "Scourge" },
        ["arena3"] = { name = "Krymu", raceLoc = L["Human"], classLoc = L["Rogue"], class = "ROGUE", health = 1592, healthMax = 11740, power = 45, powerMax = 110, powerType = 3, testSpec = L["Subtlety"], race = "Human" },
        ["arena4"] = { name = "Talmon", raceLoc = L["Human"], classLoc = L["Warlock"], class = "WARLOCK", health = 10221, healthMax = 14960, power = 9855, powerMax = 9855, powerType = 0, testSpec = L["Demonology"], race = "Human" },
        ["arena5"] = { name = "Hydra", raceLoc = L["Undead"], classLoc = L["Priest"], class = "PRIEST", health = 11960, healthMax = 11960, power = 2515, powerMax = 10240, powerType = 0, testSpec = L["Discipline"], race = "Human" },
    }

    self.cooldownSpellIds = {}
    self.spellTextures = {}
    self.specBuffs = self:GetSpecBuffs()
    self.specSpells = self:GetSpecSpells()
    self.buttons = {}
    self.guids = {}
    self.curBracket = nil
    self.curUnit = 1
    self.lastInstance = nil

    self:SetupOptions()

    for k, v in self:IterModules() do
        self:Call(v, "Initialize") -- B.E > A.E :D
    end
    self:DeleteUnknownOptions(self.db, self.defaults.profile)
end

function Gladdy:OnProfileChanged()
    self.db = self.dbi.profile
    self:DeleteUnknownOptions(self.db, self.defaults.profile)

    self:HideFrame()
    self:ToggleFrame(3)
end

function Gladdy:OnEnable()
    self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    if (IsAddOnLoaded("Clique")) then
        for i = 1, 5 do
            self:CreateButton(i)
        end

        ClickCastFrames = ClickCastFrames or {}
        ClickCastFrames[self.buttons.arena1.secure] = true
        ClickCastFrames[self.buttons.arena2.secure] = true
        ClickCastFrames[self.buttons.arena3.secure] = true
        ClickCastFrames[self.buttons.arena4.secure] = true
        ClickCastFrames[self.buttons.arena5.secure] = true
    end

    if (not self.db.locked and self.db.x == 0 and self.db.y == 0) then
        self:Print(L["Welcome to Gladdy!"])
        self:Print(L["First run has been detected, displaying test frame."])
        self:Print(L["Valid slash commands are:"])
        self:Print(L["/gladdy ui"])
        self:Print(L["/gladdy test2-5"])
        self:Print(L["/gladdy hide"])
        self:Print(L["/gladdy reset"])
        self:Print(L["If this is not your first run please lock or move the frame to prevent this from happening."])

        self:HideFrame()
        self:ToggleFrame(3)
    end
end

function Gladdy:GetIconStyles()
    return
    {
        ["Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp"] = L["Gladdy Tooltip round"],
        ["Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp"] = L["Gladdy Tooltip squared"],
        ["Interface\\AddOns\\Gladdy\\Images\\Border_Gloss"] = L["Gloss (black border)"],
    }
end

---------------------------

-- TEST

---------------------------

function Gladdy:Test()
    Gladdy.frame.testing = true
    for i = 1, self.curBracket do
        local unit = "arena" .. i
        if (not self.buttons[unit]) then
            self:CreateButton(i)
        end
        local button = self.buttons[unit]

        for k, v in pairs(self.testData[unit]) do
            button[k] = v
        end

        for k, v in self:IterModules() do
            self:Call(v, "Test", unit)
        end

        button:SetAlpha(1)
    end
end

---------------------------

-- EVENT HANDLING

---------------------------

function Gladdy:PLAYER_ENTERING_WORLD()
    local instance = select(2, IsInInstance())
    if (instance ~= "arena" and self.frame and self.frame:IsVisible() and not self.frame.testing) then
        self:Reset()
        self:HideFrame()
    end
    if (instance == "arena") then
        self:Reset()
        self:HideFrame()
    end
    self.lastInstance = instance
end

function Gladdy:UPDATE_BATTLEFIELD_STATUS(_, index)
    local status, mapName, instanceID, levelRangeMin, levelRangeMax, teamSize, isRankedArena, suspendedQueue, bool, queueType = GetBattlefieldStatus(index)
    if (status == "active" and teamSize > 0 and IsActiveBattlefieldArena()) then
        self.curBracket = teamSize
        self:JoinedArena()
    end
end

---------------------------

-- RESET FUNCTIONS (ARENA LEAVE)

---------------------------

function Gladdy:Reset()
    if type(self.guids) == "table" then
        for k, v in pairs(self.guids) do
            self.guids[k] = nil
        end
    end
    self.guids = {}
    self.curBracket = nil
    self.curUnit = 1

    for k1, v1 in self:IterModules() do
        self:Call(v1, "Reset")
    end

    for unit in pairs(self.buttons) do
        self:ResetUnit(unit)
    end
end

function Gladdy:ResetUnit(unit)
    local button = self.buttons[unit]
    if (not button) then
        return
    end

    button:SetAlpha(0)
    self:ResetButton(unit)

    for k2, v2 in self:IterModules() do
        self:Call(v2, "ResetUnit", unit)
    end
end

function Gladdy:ResetButton(unit)
    local button = self.buttons[unit]
    if (not button) then
        return
    end
    for k1, v1 in pairs(self.BUTTON_DEFAULTS) do
        if (type(v1) == "string") then
            button[k1] = nil
        elseif (type(v1) == "number") then
            button[k1] = 0
        elseif (type(v1) == "array") then
            button[k1] = {}
        elseif (type(v1) == "boolean") then
            button[k1] = false
        end
    end
end

---------------------------

-- ARENA JOINED

---------------------------

function Gladdy:JoinedArena()
    if not self.curBracket then
        self.curBracket = 2
    end

    for i = 1, self.curBracket do
        if (not self.buttons["arena" .. i]) then
            self:CreateButton(i)
        end
    end

    self:SendMessage("JOINED_ARENA")
    self:UpdateFrame()
    self.frame:Show()
    for i=1, self.curBracket do
        self.buttons["arena" .. i]:SetAlpha(1)
    end
end
