local pairs = pairs
local floor = math.floor

local GetSpellInfo = GetSpellInfo
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GetTime = GetTime
local SendChatMessage = SendChatMessage
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RaidBossEmoteFrame = RaidBossEmoteFrame
local IsAddOnLoaded = IsAddOnLoaded
local IsInGroup = IsInGroup
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local CombatText_AddMessage = CombatText_AddMessage
local UnitName = UnitName

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Announcements = Gladdy:NewModule("Announcements", nil, {
    announcements = {
        drinks = true,
        resurrections = true,
        enemy = false,
        spec = true,
        health = false,
        healthThreshold = 20,
        trinketUsed = true,
        trinketReady = false,
        dest = "party",
    },
})

function Announcements:Initialize()
    self.enemy = {}
    self.throttled = {}

    self.DRINK_AURA = GetSpellInfo(46755)
    self.RES_SPELLS = {
        [GetSpellInfo(20770)] = true,
        [GetSpellInfo(20773)] = true,
        [GetSpellInfo(20777)] = true,
    }

    self:RegisterMessage("CAST_START")
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_SPEC")
    self:RegisterMessage("UNIT_HEALTH")
    self:RegisterMessage("TRINKET_USED")
    self:RegisterMessage("TRINKET_READY")
    self:RegisterMessage("SHADOWSIGHT")
end

function Announcements:Reset()
    self.enemy = {}
    self.throttled = {}
end

function Announcements:Test(unit)
    local button = Gladdy.buttons[unit]
    if (not button) then
        return
    end

    if (unit == "arena1") then
        self:UNIT_SPEC(unit, button.testSpec)
    elseif (unit == "arena2") then
        self:CheckDrink(unit, self.DRINK_AURA)
    elseif (unit == "arena3") then
        self:UNIT_HEALTH(unit, button.health, button.healthMax)
        self:ENEMY_SPOTTED(unit)
    end
end

function Announcements:CAST_START(unit, spell)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.resurrections) then
        return
    end

    if (self.RES_SPELLS[spell]) then
        self:Send(L["RESURRECTING: %s (%s)"]:format(button.name, button.classLoc), 3, RAID_CLASS_COLORS[button.class])
    end
end

function Announcements:ENEMY_SPOTTED(unit)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.enemy) then
        return
    end

    if (not self.enemy[unit]) then
        if button.name == "Unknown" then
            button.name = UnitName(unit)
        end
        self:Send("ENEMY SPOTTED:" .. ("%s (%s)"):format(button.name, button.classLoc), 0, RAID_CLASS_COLORS[button.class])
        self.enemy[unit] = true
    end
end

function Announcements:UNIT_SPEC(unit, spec)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.spec) then
        return
    end
    if button.name == "Unknown" then
        button.name = UnitName(unit)
    end
    self:Send(L["SPEC DETECTED: %s - %s (%s)"]:format(button.name, spec, button.classLoc), 0, RAID_CLASS_COLORS[button.class])
end

function Announcements:UNIT_HEALTH(unit, health, healthMax)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.health) then
        return
    end

    local healthPercent = floor(health * 100 / healthMax)
    if (healthPercent < Gladdy.db.announcements.healthThreshold) then
        self:Send(L["LOW HEALTH: %s (%s)"]:format(button.name, button.classLoc), 10, RAID_CLASS_COLORS[button.class])
    end
end

function Announcements:TRINKET_USED(unit)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.trinketUsed) then
        return
    end

    self:Send(L["TRINKET USED: %s (%s)"]:format(button.name, button.classLoc), 0, RAID_CLASS_COLORS[button.class])
end

function Announcements:TRINKET_READY(unit)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.trinketReady) then
        return
    end

    self:Send(L["TRINKET READY: %s (%s)"]:format(button.name, button.classLoc), 3, RAID_CLASS_COLORS[button.class])
end

function Announcements:CheckDrink(unit, aura)
    local button = Gladdy.buttons[unit]
    if (not button or not Gladdy.db.announcements.drinks) then
        return
    end

    if (aura == self.DRINK_AURA) then
        self:Send(L["DRINKING: %s (%s)"]:format(button.name, button.classLoc), 3, RAID_CLASS_COLORS[button.class])
    end
end

function Announcements:SHADOWSIGHT(msg)
    self:Send(msg, 2)
end

function Announcements:Send(msg, throttle, color)
    if (throttle and throttle > 0) then
        if (not self.throttled[msg]) then
            self.throttled[msg] = GetTime() + throttle
        elseif (self.throttled[msg] < GetTime()) then
            self.throttled[msg] = nil
        else
            return
        end
    end

    local dest = Gladdy.db.announcements.dest
    color = color or { r = 0, g = 1, b = 0 }

    if (dest == "self") then
        Gladdy:Print(msg)
    elseif (dest == "party" and IsInGroup(LE_PARTY_CATEGORY_HOME)) then --(GetNumSubgroupMembers() > 0 or GetNumGroupMembers() > 0)) then
        SendChatMessage(msg, "PARTY")
    elseif dest == "party" and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(msg, "INSTANCE_CHAT")
    elseif (dest == "rw") then
        RaidNotice_AddMessage(RaidBossEmoteFrame, msg, color)
    elseif (dest == "fct" and IsAddOnLoaded("Blizzard_CombatText")) then
        CombatText_AddMessage(msg, nil, color.r, color.g, color.b, "crit", 1)
    elseif (dest == "msbt" and IsAddOnLoaded("MikScrollingBattleText")) then
        MikSBT.Animations.DisplayMessage(msg, MikSBT.DISPLAYTYPE_NOTIFICATION, true, color.r * 255, color.g * 255, color.b * 255)
    --[[elseif (dest == "sct" and IsAddOnLoaded("sct")) then
        SCT:DisplayText(msg, color, true, "event", 1)
    elseif (dest == "parrot" and IsAddOnLoaded("parrot")) then
        Parrot:ShowMessage(msg, "Notification", true, color.r, color.g, color.b)--]]
    end
end

local function option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile.announcements[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile.announcements[key] = value
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Announcements:GetOptions()
    local destValues = {
        ["self"] = L["Self"],
        ["party"] = L["Party"],
        ["rw"] = L["Raid Warning"],
    }

    if IsAddOnLoaded("Blizzard_CombatText") then
        destValues["fct"] = L["Blizzard's Floating Combat Text"]
    end
    if IsAddOnLoaded("MikScrollingBattleText") then
        destValues["msbt"] = L["MikScrollingBattleText"]
    end

    return {
        headerAnnouncements = {
            type = "header",
            name = L["Announcements"],
            order = 2,
        },
        trinketUsed = option({
            type = "toggle",
            name = L["Trinket used"],
            desc = L["Announce when an enemy's trinket is used"],
            order = 3,
        }),
        trinketReady = option({
            type = "toggle",
            name = L["Trinket ready"],
            desc = L["Announce when an enemy's trinket is ready again"],
            order = 4,
        }),
        drinks = option({
            type = "toggle",
            name = L["Drinking"],
            desc = L["Announces when enemies sit down to drink"],
            order = 5,
        }),
        resurrections = option({
            type = "toggle",
            name = L["Resurrection"],
            desc = L["Announces when an enemy tries to resurrect a teammate"],
            order = 6,
        }),
        enemy = option({
            type = "toggle",
            name = L["New enemies"],
            desc = L["Announces when new enemies are discovered"],
            order = 7,
        }),
        spec = option({
            type = "toggle",
            name = L["Spec Detection"],
            desc = L["Announces when the spec of an enemy was detected"],
            order = 8,
        }),
        health = option({
            type = "toggle",
            name = L["Low health"],
            desc = L["Announces when an enemy drops below a certain health threshold"],
            order = 9,
        }),
        healthThreshold = option({
            type = "range",
            name = L["Low health threshold"],
            desc = L["Choose how low an enemy must be before low health is announced"],
            order = 10,
            min = 1,
            max = 100,
            step = 1,
            disabled = function()
                return not Gladdy.dbi.profile.announcements.health
            end,
        }),
        dest = option({
            type = "select",
            name = L["Destination"],
            desc = L["Choose how your announcements are displayed"],
            order = 11,
            values = destValues,
        }),
    }
end