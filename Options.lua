local type, pairs, tinsert, tsort, tostring = type, pairs, table.insert, table.sort, tostring

local InterfaceOptionsFrame_OpenToFrame = InterfaceOptionsFrame_OpenToFrame
local GetSpellInfo = GetSpellInfo
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF

local Gladdy = LibStub("Gladdy")
local LibClassAuras = LibStub("LibClassAuras-1.0")
local L = Gladdy.L

Gladdy.defaults = {
    profile = {
        locked = false,
        x = 0,
        y = 0,
        growUp = false,
        frameScale = 1,
        padding = 3,
        barWidth = 180,
        bottomMargin = 10,
        statusbarBorderOffset = 7,
    },
}

SLASH_GLADDY1 = "/gladdy"
SlashCmdList["GLADDY"] = function(msg)
    if (msg == "test2") then
        Gladdy:ToggleFrame(2)
    elseif (msg == "test5") then
        Gladdy:ToggleFrame(5)
    elseif (msg:find("test")) then
        Gladdy:ToggleFrame(3)
    elseif (msg == "ui" or msg == "options" or msg == "config") then
        LibStub("AceConfigDialog-3.0"):Open("Gladdy")
        --Gladdy:ShowOptions()
    elseif (msg == "reset") then
        Gladdy.dbi:ResetProfile()
    elseif (msg == "hide") then
        Gladdy:Reset()
        Gladdy:HideFrame()
    else
        Gladdy:Print(L["Valid slash commands are:"])
        Gladdy:Print("/gladdy ui")
        Gladdy:Print("/gladdy test2-5")
        Gladdy:Print("/gladdy hide")
        Gladdy:Print("/gladdy reset")
    end
end

function Gladdy:option(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key] = value
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

function Gladdy:colorOption(params)
    local defaults = {
        get = function(info)
            local key = info.arg or info[#info]
            return Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a
        end,
        set = function(info, r, g, b, a)
            local key = info.arg or info[#info]
            Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a = r, g, b, a
            Gladdy:UpdateFrame()
        end,
    }

    for k, v in pairs(params) do
        defaults[k] = v
    end

    return defaults
end

local function getOpt(info)
    local key = info.arg or info[#info]
    return Gladdy.dbi.profile[key]
end
local function setOpt(info, value)
    local key = info.arg or info[#info]
    Gladdy.dbi.profile[key] = value
    Gladdy:UpdateFrame()
end
local function getColorOpt(info)
    local key = info.arg or info[#info]
    return Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a
end
local function setColorOpt(info, r, g, b, a)
    local key = info.arg or info[#info]
    Gladdy.dbi.profile[key].r, Gladdy.dbi.profile[key].g, Gladdy.dbi.profile[key].b, Gladdy.dbi.profile[key].a = r, g, b, a
    Gladdy:UpdateFrame()
end

function Gladdy:SetupModule(name, module, order)
    local options = module:GetOptions()
    if options then
        self.options.args[name] = {
            type = "group",
            name = L[name],
            desc = L[name .. " settings"],
            childGroups = "tab",
            order = order,
            args = {},
        }

        if (type(options) == "table") then
            self.options.args[name].args = options
            self.options.args[name].args.reset = {
                type = "execute",
                name = L["Reset module"],
                desc = L["Reset module to defaults"],
                order = 1,
                func = function()
                    for k, v in pairs(module.defaults) do
                        self.dbi.profile[k] = v
                    end

                    Gladdy:UpdateFrame()
                    Gladdy:SetupModule(name, module, order) -- For example click names are not reset by default
                end
            }
        else
            self.options.args[name].args.nothing = {
                type = "description",
                name = L["No settings"],
                desc = L["Module has no settings"],
                order = 1,
            }
        end
    end
end

local function pairsByKeys(t)
    local a = {}
    for k in pairs(t) do
        tinsert(a, k)
    end
    tsort(a)

    local i = 0
    return function()
        i = i + 1

        if (a[i] ~= nil) then
            return a[i], t[a[i]]
        else
            return nil
        end
    end
end

function Gladdy:SetupOptions()
    self.options = {
        type = "group",
        name = "Gladdy",
        plugins = {},
        childGroups = "tree",
        get = getOpt,
        set = setOpt,
        args = {
            general = {
                type = "group",
                name = L["General"],
                desc = L["General settings"],
                childGroups = "tab",
                order = 1,
                args = {
                    locked = {
                        type = "toggle",
                        name = L["Lock frame"],
                        desc = L["Toggle if frame can be moved"],
                        order = 1,
                    },
                    growUp = {
                        type = "toggle",
                        name = L["Grow frame upwards"],
                        desc = L["If enabled the frame will grow upwards instead of downwards"],
                        order = 2,
                    },
                    group = {
                        type = "group",
                        name = "General",
                        order = 3,
                        childGroups = "tree",
                        args = {
                            frameGeneral = {
                                type = "group",
                                name = L["Frame General"],
                                order = 3,
                                args = {
                                    headerFrame = {
                                        type = "header",
                                        name = L["Frame General"],
                                        order = 3,
                                    },
                                    frameScale = {
                                        type = "range",
                                        name = L["Frame scale"],
                                        desc = L["Scale of the frame"],
                                        order = 4,
                                        min = .1,
                                        max = 2,
                                        step = .1,
                                    },
                                    padding = {
                                        type = "range",
                                        name = L["Frame padding"],
                                        desc = L["Padding of the frame"],
                                        order = 5,
                                        min = 0,
                                        max = 20,
                                        step = 1,
                                    },
                                    barWidth = {
                                        type = "range",
                                        name = L["Frame width"],
                                        desc = L["Width of the bars"],
                                        order = 6,
                                        min = 10,
                                        max = 500,
                                        step = 5,
                                    },
                                    bottomMargin = {
                                        type = "range",
                                        name = L["Bottom margin"],
                                        desc = L["Margin between each button"],
                                        order = 7,
                                        min = -100,
                                        max = 100,
                                        step = 1,
                                    },
                                }
                            },
                            cooldownGeneral = {
                                type = "group",
                                name = L["Cooldown General"],
                                order = 4,
                                args = {
                                    headerCooldown = {
                                        type = "header",
                                        name = L["Cooldown General"],
                                        order = 8,
                                    },
                                    disableCooldownCircle = {
                                        type = "toggle",
                                        name = L["No Cooldown Circle"],
                                        order = 9,
                                        get = function(info)
                                            local a = Gladdy.db.auraDisableCircle
                                            local b = Gladdy.db.cooldownDisableCircle
                                            local c = Gladdy.db.trinketDisableCircle
                                            local d = Gladdy.db.drDisableCircle
                                            local e = Gladdy.db.buffsDisableCircle
                                            if (a == b and a == c and a == d and a == e) then
                                                return a
                                            else
                                                return ""
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.auraDisableCircle = value
                                            Gladdy.db.cooldownDisableCircle = value
                                            Gladdy.db.trinketDisableCircle = value
                                            Gladdy.db.drDisableCircle = value
                                            Gladdy.db.buffsDisableCircle = value
                                            Gladdy:UpdateFrame()
                                        end,
                                        width= "full",
                                    },
                                    cooldownCircleAlpha = {
                                        type = "range",
                                        name = L["Cooldown circle alpha"],
                                        order = 10,
                                        min = 0,
                                        max = 1,
                                        step = 0.1,
                                        get = function(info)
                                            local a = Gladdy.db.cooldownCooldownAlpha
                                            local b = Gladdy.db.drCooldownAlpha
                                            local c = Gladdy.db.auraCooldownAlpha
                                            local d = Gladdy.db.trinketCooldownAlpha
                                            local e = Gladdy.db.buffsCooldownAlpha
                                            if (a == b and a == c and a == d and a == e) then
                                                return a
                                            else
                                                return ""
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.cooldownCooldownAlpha = value
                                            Gladdy.db.drCooldownAlpha = value
                                            Gladdy.db.auraCooldownAlpha = value
                                            Gladdy.db.trinketCooldownAlpha = value
                                            Gladdy.db.buffsCooldownAlpha = value
                                            Gladdy:UpdateFrame()
                                        end
                                    },
                                },
                            },
                            fontGeneral = {
                                type = "group",
                                name = L["Font General"],
                                order = 4,
                                args = {
                                    headerFont = {
                                        type = "header",
                                        name = L["Font General"],
                                        order = 10,
                                    },
                                    font = {
                                        type = "select",
                                        name = L["Font"],
                                        desc = L["General Font"],
                                        order = 11,
                                        dialogControl = "LSM30_Font",
                                        values = AceGUIWidgetLSMlists.font,
                                        get = function(info)
                                            local a = Gladdy.db.castBarFont
                                            local b = Gladdy.db.healthBarFont
                                            local c = Gladdy.db.powerBarFont
                                            local d = Gladdy.db.cooldownFont
                                            local e = Gladdy.db.drFont
                                            local f = Gladdy.db.auraFont
                                            local g = Gladdy.db.buffsFont
                                            if (a == b and a == c and a == d and a == e and a == f and a == g) then
                                                return a
                                            else
                                                return ""
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.castBarFont = value
                                            Gladdy.db.healthBarFont = value
                                            Gladdy.db.powerBarFont = value
                                            Gladdy.db.cooldownFont = value
                                            Gladdy.db.drFont = value
                                            Gladdy.db.auraFont = value
                                            Gladdy.db.buffsFont = value
                                            Gladdy:UpdateFrame()
                                        end,
                                    },
                                    fontColor = {
                                        type = "color",
                                        name = L["Font color"],
                                        desc = L["Color of the text"],
                                        order = 12,
                                        hasAlpha = true,
                                        get = function(info)
                                            local a = Gladdy.db.healthBarFontColor
                                            local b = Gladdy.db.powerBarFontColor
                                            local c = Gladdy.db.castBarFontColor
                                            if (a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
                                                    and a.r == c.r and a.g == c.g and a.b == c.b and a.a == c.a) then
                                                return a.r, a.g, a.b, a.a
                                            else
                                                return { r = 0, g = 0, b = 0, a = 0 }
                                            end
                                        end,
                                        set = function(info, r, g, b, a)
                                            local rgb = {r = r, g = g, b = b, a = a}
                                            Gladdy.db.healthBarFontColor = rgb
                                            Gladdy.db.powerBarFontColor = rgb
                                            Gladdy.db.castBarFontColor = rgb
                                            Gladdy:UpdateFrame()
                                        end,
                                    },
                                },
                            },
                            iconsGeneral = {
                                type = "group",
                                name = L["Icons General"],
                                order = 5,
                                args = {
                                    headerIcon = {
                                        type = "header",
                                        name = L["Icons General"],
                                        order = 13,
                                    },
                                    buttonBorderStyle = {
                                        type = "select",
                                        name = L["Icon border style"],
                                        desc = L["This changes the border style of all icons"],
                                        order = 14,
                                        values = Gladdy:GetIconStyles(),
                                        get = function(info)
                                            if (Gladdy.db.classIconBorderStyle == Gladdy.db.trinketBorderStyle
                                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.castBarIconStyle
                                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.auraBorderStyle
                                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.cooldownBorderStyle
                                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.buffsBorderStyle
                                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.drBorderStyle
                                                    and Gladdy.db.classIconBorderStyle == Gladdy.db.npTotemPlatesBorderStyle) then
                                                return Gladdy.db.classIconBorderStyle
                                            else
                                                return ""
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.classIconBorderStyle = value
                                            Gladdy.db.trinketBorderStyle = value
                                            Gladdy.db.castBarIconStyle = value
                                            Gladdy.db.auraBorderStyle = value
                                            Gladdy.db.npTotemPlatesBorderStyle = value
                                            Gladdy.db.cooldownBorderStyle = value
                                            Gladdy.db.buffsBorderStyle = value
                                            Gladdy.db.drBorderStyle = value
                                            Gladdy:UpdateFrame()
                                        end,
                                    },
                                    buttonBorderColor = {
                                        type = "color",
                                        name = L["Icon border color"],
                                        desc = L["This changes the border color of all icons"],
                                        order = 15,
                                        hasAlpha = true,
                                        get = function(info)
                                            local a = Gladdy.db.classIconBorderColor
                                            local b = Gladdy.db.trinketBorderColor
                                            local c = Gladdy.db.castBarIconColor
                                            if (a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
                                                    and a.r == c.r and a.g == c.g and a.b == c.b and a.a == c.a) then
                                                return a.r, a.g, a.b, a.a
                                            else
                                                return { r = 0, g = 0, b = 0, a = 0 }
                                            end
                                        end,
                                        set = function(info, r, g, b, a)
                                            local rgb = {r = r, g = g, b = b, a = a}
                                            Gladdy.db.classIconBorderColor = rgb
                                            Gladdy.db.trinketBorderColor = rgb
                                            Gladdy.db.castBarIconColor = rgb
                                            Gladdy.db.npTotemPlatesBorderColor = rgb
                                            Gladdy.db.drBorderColor = rgb
                                            Gladdy.db.cooldownBorderColor = rgb
                                            Gladdy.db.buffsBorderColor = rgb
                                            Gladdy:UpdateFrame()
                                        end,
                                    },
                                },
                            },
                            statusbarGeneral = {
                                type = "group",
                                name = L["Statusbar General"],
                                order = 6,
                                args = {
                                    headerStatusbar = {
                                        type = "header",
                                        name = L["Statusbar General"],
                                        order = 47,
                                    },
                                    statusbarTexture = {
                                        type = "select",
                                        name = L["Statusbar texture"],
                                        desc = L["This changes the texture of all statusbar frames"],
                                        order = 48,
                                        dialogControl = "LSM30_Statusbar",
                                        values = AceGUIWidgetLSMlists.statusbar,
                                        get = function(info)
                                            local a = Gladdy.db.healthBarTexture
                                            local b = Gladdy.db.powerBarTexture
                                            local c = Gladdy.db.castBarTexture
                                            if (a == b and a == c) then
                                                return a
                                            else
                                                return ""
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.healthBarTexture = value
                                            Gladdy.db.powerBarTexture = value
                                            Gladdy.db.castBarTexture = value
                                            Gladdy:UpdateFrame()
                                        end,
                                        width= "full",
                                    },
                                    statusbarBorderStyle = {
                                        type = "select",
                                        name = L["Statusbar border style"],
                                        desc = L["This changes the border style of all statusbar frames"],
                                        order = 49,
                                        dialogControl = "LSM30_Border",
                                        values = AceGUIWidgetLSMlists.border,
                                        get = function(info)
                                            local a = Gladdy.db.healthBarBorderStyle
                                            local b = Gladdy.db.powerBarBorderStyle
                                            local c = Gladdy.db.castBarBorderStyle
                                            if (a == b and a == c) then
                                                return a
                                            else
                                                return ""
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.healthBarBorderStyle = value
                                            Gladdy.db.powerBarBorderStyle = value
                                            Gladdy.db.castBarBorderStyle = value
                                            Gladdy:UpdateFrame()
                                        end,
                                    },
                                    statusbarBorderOffset = Gladdy:option({
                                        type = "range",
                                        name = L["Statusbar border offset divider (smaller is higher offset)"],
                                        desc = L["Offset of border to statusbar (in case statusbar shows beyond the border)"],
                                        min = 1,
                                        max = 20,
                                        step = 0.1,
                                    }),
                                    statusbarBorderColor = {
                                        type = "color",
                                        name = L["Statusbar border color"],
                                        desc = L["This changes the border color of all statusbar frames"],
                                        order = 50,
                                        hasAlpha = true,
                                        get = function(info)
                                            local a = Gladdy.db.castBarBorderColor
                                            local b = Gladdy.db.healthBarBorderColor
                                            local c = Gladdy.db.powerBarBorderColor
                                            if (a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
                                                    and a.r == c.r and a.g == c.g and a.b == c.b and a.a == c.a) then
                                                return a.r, a.g, a.b, a.a
                                            else
                                                return { r = 0, g = 0, b = 0, a = 0 }
                                            end
                                        end,
                                        set = function(info, r, g, b, a)
                                            local rgb = {r = r, g = g, b = b, a = a}
                                            Gladdy.db.castBarBorderColor = rgb
                                            Gladdy.db.healthBarBorderColor = rgb
                                            Gladdy.db.powerBarBorderColor = rgb
                                            Gladdy:UpdateFrame()
                                        end,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    }

    local order = 2
    for k, v in pairsByKeys(self.modules) do
        self:SetupModule(k, v, order)
        order = order + 1
    end

    local options = {
        name = "Gladdy",
        type = "group",
        args = {
            load = {
                name = "Load configuration",
                desc = "Load configuration options",
                type = "execute",
                func = function()
                    HideUIPanel(InterfaceOptionsFrame)
                    HideUIPanel(GameMenuFrame)
                    LibStub("AceConfigDialog-3.0"):Open("Gladdy")
                end,
            },
        },
    }

    self.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.dbi) }
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Gladdy_blizz", options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Gladdy_blizz", "Gladdy")
    LibStub("AceConfig-3.0"):RegisterOptionsTable("Gladdy", self.options)

end

function Gladdy:ShowOptions()
    InterfaceOptionsFrame_OpenToFrame("Gladdy")
end

function Gladdy:GetAuras(auraType)
    local spells = {
        ckeckAll = {
            order = 1,
            width = "0.7",
            name = "Check All",
            type = "execute",
            func = function(info)
                if auraType == AURA_TYPE_DEBUFF then
                    for k,v in pairs(Gladdy.defaults.profile.trackedDebuffs) do
                        Gladdy.dbi.profile.trackedDebuffs[k] = true
                    end
                else
                    for k,v in pairs(Gladdy.defaults.profile.trackedBuffs) do
                        Gladdy.dbi.profile.trackedBuffs[k] = true
                    end
                end
            end,
        },
        uncheckAll = {
            order = 2,
            width = "0.7",
            name = "Uncheck All",
            type = "execute",
            func = function(info)
                if auraType == AURA_TYPE_DEBUFF then
                    for k,v in pairs(Gladdy.defaults.profile.trackedDebuffs) do
                        Gladdy.dbi.profile.trackedDebuffs[k] = false
                    end
                else
                    for k,v in pairs(Gladdy.defaults.profile.trackedBuffs) do
                        Gladdy.dbi.profile.trackedBuffs[k] = false
                    end
                end
            end,
        },
        druid = {
            order = 3,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["DRUID"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["DRUID"],
            args = {},
        },
        hunter = {
            order = 4,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["HUNTER"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["HUNTER"],
            args = {},
        },
        mage = {
            order = 5,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["MAGE"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["MAGE"],
            args = {},
        },
        paladin = {
            order = 6,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["PALADIN"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["PALADIN"],
            args = {},
        },
        priest = {
            order = 7,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["PRIEST"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["PRIEST"],
            args = {},
        },
        rogue = {
            order = 8,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["ROGUE"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["ROGUE"],
            args = {},
        },
        shaman = {
            order = 9,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["SHAMAN"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["SHAMAN"],
            args = {},
        },
        warlock = {
            order = 10,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["WARLOCK"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["WARLOCK"],
            args = {},
        },
        warrior = {
            order = 10,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["WARRIOR"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["WARRIOR"],
            args = {},
        },
    }
    local defaultDebuffs = {}
    local assignForClass = function(class)
        local args = {}
        local classSpells = auraType == AURA_TYPE_DEBUFF and LibClassAuras.GetClassDebuffs(class) or LibClassAuras.GetClassBuffs(class)
        table.sort(classSpells, function(a, b)
            return a.name:upper() < b.name:upper()
        end)
        for i=1, #classSpells do
            local _, _, texture = GetSpellInfo(classSpells[i].id[#classSpells[i].id])
            if classSpells[i].texture then
                texture = classSpells[i].texture
            end
            args[tostring(classSpells[i].id[1])] = {
                order = i,
                name = classSpells[i].name,
                type = "toggle",
                image = texture,
                width = "2",
                arg = tostring(classSpells[i].id[1])
            }
            defaultDebuffs[tostring(classSpells[i].id[1])] = true
        end
        return args
    end
    spells.druid.args = assignForClass("DRUID")
    spells.hunter.args = assignForClass("HUNTER")
    spells.mage.args = assignForClass("MAGE")
    spells.paladin.args = assignForClass("PALADIN")
    spells.priest.args = assignForClass("PRIEST")
    spells.rogue.args = assignForClass("ROGUE")
    spells.shaman.args = assignForClass("SHAMAN")
    spells.warlock.args = assignForClass("WARLOCK")
    spells.warrior.args = assignForClass("WARRIOR")
    return spells, defaultDebuffs
end