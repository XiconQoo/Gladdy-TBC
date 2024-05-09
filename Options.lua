local type, pairs, tinsert, tsort = type, pairs, table.insert, table.sort
local tostring, str_match, tonumber, str_format = tostring, string.match, tonumber, string.format
local ceil, floor = ceil, floor
local ReloadUI = ReloadUI

local GetSpellInfo = GetSpellInfo
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF


local Gladdy = LibStub("Gladdy")
local LibClassAuras = LibStub("LibClassAuras-1.0")
local L = Gladdy.L

Gladdy.TIMER_FORMAT = { tenths = "tenths", seconds = "seconds",
                       values = {
                           ["tenths"] = "xx:xx Miliseconds",
                           ["seconds"] = "xx Seconds"
                       }}

function Gladdy:FormatTimer(fontString, timeLeft, milibreakpoint, showSeconds)
    if timeLeft < 0 then
        fontString:SetText("")
        return
    end
    local time = timeLeft >= 0.0 and timeLeft or 0.0
    if Gladdy.db.timerFormat == Gladdy.TIMER_FORMAT.tenths and milibreakpoint then
        fontString:SetFormattedText("%.1f", time)
    else
        if time >= 60 then
            if showSeconds then
                fontString:SetText(floor(timeLeft / 60) .. ":" .. str_format("%02.f", floor(timeLeft - floor(timeLeft / 60) * 60)))
            else
                fontString:SetText(ceil(ceil(time / 60)) .. "m")
            end
        else
            fontString:SetFormattedText("%d", ceil(time))
        end
    end
end

Gladdy.defaults = {
    profile = {
        locked = false,
        hideBlizzard = "arena",
        x = 0,
        y = 0,
        growDirection = "BOTTOM",
        growMiddle = false,
        frameScale = 1,
        pixelPerfect = false,
        barWidth = 180,
        bottomMargin = 2,
        statusbarBorderOffset = 6,
        timerFormat = Gladdy.TIMER_FORMAT.tenths,
        backgroundColor = {r = 0, g = 0, b = 0, a = 0},
        newLayout = false,
        showMover = true,
        useOmnicc =false,
        version = Gladdy.version_num
    },
}

SLASH_GLADDY1 = "/gladdy"
SlashCmdList["GLADDY"] = function(msg)
    if (str_match(msg, "test[1-5]")) then
        local _, num = str_match(msg, "(test)([1-5])")
        Gladdy:ToggleFrame(tonumber(num))
    elseif (msg == "test") then
        Gladdy:ToggleFrame(3)
    elseif (msg == "ui" or msg == "options" or msg == "config") then
        LibStub("AceConfigDialog-3.0"):Open("Gladdy")
    elseif (msg == "reset") then
        Gladdy.dbi:ResetProfile()
    elseif (msg == "hide") then
        Gladdy:Reset()
        Gladdy:HideFrame()
    else
        Gladdy:Print(L["Valid slash commands are:"])
        Gladdy:Print("/gladdy ui")
        Gladdy:Print("/gladdy test")
        Gladdy:Print("/gladdy test1-5")
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

function Gladdy:SetColor(option, factor, altAlpha)
    if not factor then
        factor = 1
    end
    return option.r / factor, option.g / factor, option.b / factor, altAlpha or option.a
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
    if Gladdy.db.hideBlizzard == "always" then
        Gladdy:BlizzArenaSetAlpha(0)
    elseif Gladdy.db.hideBlizzard == "never" then
        Gladdy:BlizzArenaSetAlpha(1)
    end
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

function Gladdy:ResetMenu(name, module, order)
    self.options.args[name].args = module:GetOptions()
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
            Gladdy:SetupModule(name, module, order)
        end
    }
end

function Gladdy:SetupModule(name, module, order)
    local options = module:GetOptions()
    if options then
        self.options.args[name] = {
            type = "group",
            name = L[name],
            desc = L[name] .. " " .. L["settings"],
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

function Gladdy:GetFromMultipleOptions(options)
    local val = options[1]
    local isAllSameValue = true
    for _,v in pairs(options) do
        if type(v) == "table" then
            if not (v.r == val.r and v.g == val.g and v.b == val.b and v.a == val.a) then
                isAllSameValue = false
                break
            end
        else
            if val ~= v then
                isAllSameValue = false
                break
            end
        end
    end

    if type(val) == "table" then
        if isAllSameValue then
            return val.r, val.g, val.b, val.a
        else
            return 0,0,0,0
        end
    else
        return isAllSameValue and val or ""
    end
end

local function setAll(value, options)
    for k,_ in pairs(options) do
        Gladdy.db[k] = value
    end
    Gladdy:UpdateFrame()
end

local function pairsByKeys(t)
    local a = {}
    for k in pairs(t) do
        tinsert(a, k)
    end
    tsort(a, function(a, b) return L[a] < L[b] end)

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
        name = L["Gladdy"],
        plugins = {},
        childGroups = "tree",
        get = getOpt,
        set = setOpt,
        args = {
            lock = {
                order = 1,
                width = 0.7,
                name = Gladdy.db.locked and L["Unlock frame"] or L["Lock frame"],
                desc = L["Toggle if frame can be moved"],
                type = "execute",
                func = function()
                    Gladdy.db.locked = not Gladdy.db.locked
                    Gladdy:UpdateFrame()
                    self.options.args.lock.name = Gladdy.db.locked and L["Unlock frame"] or L["Lock frame"]
                end,
            },
            showMover = {
                order = 2,
                width = 0.7,
                name = Gladdy.db.showMover and L["Hide Mover"] or L["Show Mover"],
                desc = L["Toggle to show Mover Frames"],
                type = "execute",
                func = function()
                    Gladdy.db.showMover = not Gladdy.db.showMover
                    Gladdy:UpdateFrame()
                    self.options.args.showMover.name = Gladdy.db.showMover and L["Hide Mover"] or L["Show Mover"]
                end,
            },
            test = {
                order = 2,
                width = 0.7,
                name = L["Test"],
                desc = L["Show Test frames"],
                type = "execute",
                func = function()
                    Gladdy:ToggleFrame(3)
                end,
            },
            hide = {
                order = 3,
                width = 0.7,
                name = L["Hide"],
                desc = L["Hide frames"],
                type = "execute",
                func = function()
                    Gladdy:Reset()
                    Gladdy:HideFrame()
                end,
            },
            reload = {
                order = 4,
                width = 0.7,
                name = L["ReloadUI"],
                desc = L["Reloads the UI"],
                type = "execute",
                func = function()
                    ReloadUI()
                end,
            },
            version = {
                order = 5,
                width = 1,
                type = "description",
                name = "     " .. Gladdy.version
            },
            general = {
                type = "group",
                name = L["General"],
                desc = L["General settings"],
                childGroups = "tab",
                order = 5,
                args = {
                    growDirection = {
                        type = "select",
                        name = L["Grow Direction"],
                        order = 3,
                        values = {
                            ["BOTTOM"] = L["Down"],
                            ["TOP"] = L["Up"],
                            ["LEFT"] = L["Left"],
                            ["RIGHT"] = L["Right"],
                        }
                    },
                    hideBlizzard = {
                        type = "select",
                        name = L["Hide Blizzard"],
                        values = {
                            ["arena"] = L["Arena only"],
                            ["never"] = L["Never"],
                            ["always"] = L["Always"],
                        },
                        order = 4,
                    },
                    group = {
                        type = "group",
                        name = L["General"],
                        order = 6,
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
                                        order = 2,
                                    },
                                    growMiddle = {
                                        type = "toggle",
                                        name = L["Grow Middle"],
                                        desc = L["Frames expand along a centric anchor"],
                                        order = 3,
                                    },
                                    pixelPerfect = {
                                        type = "toggle",
                                        name = L["Pixel Perfect Scale"],
                                        desc = L["Enables Pixel Perfect Scale - disables manual "].. L["Frame scale"],
                                        order = 4,
                                    },
                                    frameScale = {
                                        type = "range",
                                        name = L["Frame scale"],
                                        desc = L["Scale of the frame"],
                                        disabled = function() return Gladdy.db.pixelPerfect end,
                                        order = 5,
                                        min = .1,
                                        max = 2,
                                        step = .01,
                                    },
                                    barWidth = {
                                        type = "range",
                                        name = L["Frame width"],
                                        desc = L["Width of the bars"],
                                        order = 7,
                                        min = 10,
                                        max = 500,
                                        step = 5,
                                    },
                                    bottomMargin = {
                                        type = "range",
                                        name = L["Margin"],
                                        desc = L["Margin between each button"],
                                        order = 8,
                                        min = -200,
                                        max = 200,
                                        step = 1,
                                    },
                                    backgroundColor = {
                                        type = "color",
                                        name = L["Background color"],
                                        desc = L["Background Color of the frame"],
                                        order = 9,
                                        hasAlpha = true,
                                        get = getColorOpt,
                                        set = setColorOpt,
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
                                    useOmnicc = {
                                        type = "toggle",
                                        name = L["OmniCC Enabled"],
                                        order = 9,
                                    },
                                    disableCooldownCircle = {
                                        type = "toggle",
                                        name = L["No Cooldown Circle"],
                                        order = 10,
                                        disabled = function()
                                            return Gladdy.db.useOmnicc
                                        end,
                                        get = function(info)
                                            local isAllSameValue =  Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.auraDisableCircle,
                                                Gladdy.db.buffsDisableCircle,
                                                Gladdy.db.cooldownDisableCircle,
                                                Gladdy.db.drDisableCircle,
                                                Gladdy.db.racialDisableCircle,
                                                Gladdy.db.trinketDisableCircle,
                                            })
                                            if isAllSameValue then
                                                return Gladdy.db.auraDisableCircle
                                            else
                                                return false
                                            end
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.auraDisableCircle = value
                                            Gladdy.db.buffsDisableCircle = value
                                            Gladdy.db.cooldownDisableCircle = value
                                            Gladdy.db.drDisableCircle = value
                                            Gladdy.db.racialDisableCircle = value
                                            Gladdy.db.trinketDisableCircle = value
                                            Gladdy:UpdateFrame()
                                        end,
                                        width= "full",
                                    },
                                    cooldownCircleAlpha = {
                                        type = "range",
                                        name = L["Cooldown circle alpha"],
                                        order = 11,
                                        min = 0,
                                        max = 1,
                                        step = 0.1,
                                        disabled = function()
                                            return Gladdy.db.useOmnicc
                                        end,
                                        get = function(info)
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.auraCooldownAlpha,
                                                Gladdy.db.buffsCooldownAlpha,
                                                Gladdy.db.cooldownCooldownAlpha,
                                                Gladdy.db.drCooldownAlpha,
                                                Gladdy.db.racialCooldownAlpha,
                                                Gladdy.db.totemPulseCooldownAlpha,
                                                Gladdy.db.trinketCooldownAlpha,
                                            })
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.auraCooldownAlpha = value
                                            Gladdy.db.buffsCooldownAlpha = value
                                            Gladdy.db.cooldownCooldownAlpha = value
                                            Gladdy.db.drCooldownAlpha = value
                                            Gladdy.db.racialCooldownAlpha = value
                                            Gladdy.db.totemPulseCooldownAlpha = value
                                            Gladdy.db.trinketCooldownAlpha = value
                                            Gladdy:UpdateFrame()
                                        end
                                    },
                                    timerFormat = Gladdy:option({
                                        type = "select",
                                        name = L["Timer Format"],
                                        order = 12,
                                        values = Gladdy.TIMER_FORMAT.values,
                                        disabled = function()
                                            return Gladdy.db.useOmnicc
                                        end,
                                    })
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
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.auraFont,
                                                Gladdy.db.buffsFont,
                                                Gladdy.db.castBarFont,
                                                Gladdy.db.cooldownFont,
                                                Gladdy.db.drFont,
                                                Gladdy.db.drLevelTextFont,
                                                Gladdy.db.healthBarFont,
                                                Gladdy.db.petHealthBarFont,
                                                Gladdy.db.powerBarFont,
                                                Gladdy.db.racialFont,
                                                Gladdy.db.targetsHealthBarFont,
                                                Gladdy.db.npTremorFont,
                                                Gladdy.db.totemPulseTextFont,
                                                Gladdy.db.trinketFont
                                            })
                                        end,
                                        set = function(info, value)
                                            setAll(value, {
                                                auraFont = value,
                                                buffsFont = value,
                                                castBarFont = value,
                                                cooldownFont = value,
                                                drFont = value,
                                                drLevelTextFont = value,
                                                healthBarFont = value,
                                                petHealthBarFont = value,
                                                powerBarFont = value,
                                                racialFont = value,
                                                targetsHealthBarFont = value,
                                                npTremorFont = value,
                                                totemPulseTextFont = value,
                                                trinketFont = value,
                                            })
                                        end,
                                    },
                                    fontColor = {
                                        type = "color",
                                        name = L["Font color text"],
                                        desc = L["Color of the text"],
                                        order = 12,
                                        hasAlpha = true,
                                        get = function(info)
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.castBarFontColor,
                                                Gladdy.db.healthBarFontColor,
                                                Gladdy.db.petHealthBarFontColor,
                                                Gladdy.db.powerBarFontColor,
                                                Gladdy.db.petHealthBarFontColor,
                                                Gladdy.db.targetHealthBarFontColor,
                                            })
                                        end,
                                        set = function(info, r, g, b, a)
                                            local rgb = {r = r, g = g, b = b, a = a}
                                            setAll(rgb, {
                                                castBarFontColor = true,
                                                healthBarFontColor = true,
                                                petHealthBarFontColor = true,
                                                powerBarFontColor = true,
                                                petHealthBarFontColor = true,
                                                targetHealthBarFontColor = true,
                                            })
                                        end,
                                    },
                                    fontColorCD = {
                                        type = "color",
                                        name = L["Font color timer"],
                                        desc = L["Color of the timers"],
                                        order = 12,
                                        hasAlpha = true,
                                        get = function(info)
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.auraFontColor,
                                                Gladdy.db.buffsFontColor,
                                                Gladdy.db.cooldownFontColor,
                                                Gladdy.db.drFontColor,
                                            })
                                        end,
                                        set = function(info, r, g, b, a)
                                            local rgb = {r = r, g = g, b = b, a = a}
                                            setAll(rgb, {
                                                auraFontColor = true,
                                                buffsFontColor = true,
                                                cooldownFontColor = true,
                                                drFontColor = true,
                                            })
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
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.auraBorderStyle,
                                                Gladdy.db.buffsBorderStyle,
                                                Gladdy.db.castBarIconStyle,
                                                Gladdy.db.classIconBorderStyle,
                                                Gladdy.db.ciBorderStyle,
                                                Gladdy.db.cooldownBorderStyle,
                                                Gladdy.db.drBorderStyle,
                                                Gladdy.db.petPortraitBorderStyle,
                                                Gladdy.db.racialBorderStyle,
                                                Gladdy.db.targetPortraitBorderStyle,
                                                Gladdy.db.npTotemPlatesBorderStyle,
                                                Gladdy.db.trinketBorderStyle,
                                            })
                                        end,
                                        set = function(info, value)
                                            setAll(value, {
                                                auraBorderStyle = true,
                                                buffsBorderStyle = true,
                                                castBarIconStyle = true,
                                                classIconBorderStyle = true,
                                                ciBorderStyle = true,
                                                cooldownBorderStyle = true,
                                                drBorderStyle = true,
                                                petPortraitBorderStyle = true,
                                                racialBorderStyle = true,
                                                targetPortraitBorderStyle = true,
                                                npTotemPlatesBorderStyle = true,
                                                trinketBorderStyle = true,
                                            })
                                        end,
                                    },
                                    buttonBorderColor = {
                                        type = "color",
                                        name = L["Icon border color"],
                                        desc = L["This changes the border color of all icons"],
                                        order = 15,
                                        hasAlpha = true,
                                        get = function(info)
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.buffsBorderColor,
                                                Gladdy.db.castBarIconColor,
                                                Gladdy.db.classIconBorderColor,
                                                Gladdy.db.ciBorderColor,
                                                Gladdy.db.cooldownBorderColor,
                                                Gladdy.db.drBorderColor,
                                                Gladdy.db.petPortraitBorderColor,
                                                Gladdy.db.racialBorderColor,
                                                Gladdy.db.targetPortraitBorderColor,
                                                Gladdy.db.trinketBorderColor,
                                            })
                                        end,
                                        set = function(info, r, g, b, a)
                                            local rgb = {r = r, g = g, b = b, a = a}
                                            setAll(rgb, {
                                                buffsBorderColor = true,
                                                castBarIconColor = true,
                                                classIconBorderColor = true,
                                                ciBorderColor = true,
                                                cooldownBorderColor = true,
                                                drBorderColor = true,
                                                petPortraitBorderColor = true,
                                                racialBorderColor = true,
                                                targetPortraitBorderColor = true,
                                                trinketBorderColor = true,
                                            })
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
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.castBarTexture,
                                                Gladdy.db.healthBarTexture,
                                                Gladdy.db.petHealthBarTexture,
                                                Gladdy.db.powerBarTexture,
                                                Gladdy.db.targetHealthBarTexture,
                                                Gladdy.db.totemPulseBarTexture,
                                            })
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.castBarTexture = value
                                            Gladdy.db.healthBarTexture = value
                                            Gladdy.db.petHealthBarTexture = value
                                            Gladdy.db.powerBarTexture = value
                                            Gladdy.db.targetHealthBarTexture = value
                                            Gladdy.db.totemPulseBarTexture = value
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
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.castBarBorderStyle,
                                                Gladdy.db.healthBarBorderStyle,
                                                Gladdy.db.petHealthBarBorderStyle,
                                                Gladdy.db.powerBarBorderStyle,
                                                Gladdy.db.targetHealthBarBorderStyle,
                                                Gladdy.db.totemPulseBarBorderStyle,
                                            })
                                        end,
                                        set = function(info, value)
                                            Gladdy.db.castBarBorderStyle = value
                                            Gladdy.db.healthBarBorderStyle = value
                                            Gladdy.db.petHealthBarBorderStyle = value
                                            Gladdy.db.powerBarBorderStyle = value
                                            Gladdy.db.targetHealthBarBorderStyle = value
                                            Gladdy.db.totemPulseBarBorderStyle = value
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
                                            return Gladdy:GetFromMultipleOptions({
                                                Gladdy.db.castBarBorderColor,
                                                Gladdy.db.healthBarBorderColor,
                                                Gladdy.db.petHealthBarBorderColor,
                                                Gladdy.db.powerBarBorderColor,
                                                Gladdy.db.targetHealthBarBorderColor,
                                                Gladdy.db.totemPulseBarBorderColor,
                                            })
                                        end,
                                        set = function(info, r, g, b, a)
                                            local value = {r = r, g = g, b = b, a = a}
                                            Gladdy.db.castBarBorderColor = value
                                            Gladdy.db.healthBarBorderColor = value
                                            Gladdy.db.petHealthBarBorderColor = value
                                            Gladdy.db.powerBarBorderColor = value
                                            Gladdy.db.targetHealthBarBorderColor = value
                                            Gladdy.db.totemPulseBarBorderColor = value
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

    local order = 6
    for k, v in pairsByKeys(self.modules) do
        self:SetupModule(k, v, order)
        order = order + 1
    end

    local options = {
        name = L["Gladdy"],
        type = "group",
        args = {
            load = {
                name = L["Load configuration"],
                desc = L["Load configuration options"],
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
    LibStub("AceConfigDialog-3.0"):Open("Gladdy")
end

function Gladdy:GetAuras(auraType)
    local path = auraType == AURA_TYPE_DEBUFF and "trackedDebuffs" or "trackedBuffs"
    local optionPath = auraType == AURA_TYPE_DEBUFF and "debuffList" or "buffList"
    local spells = {
        ckeckAll = {
            order = 2,
            width = "0.7",
            name = L["Check All"],
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
            order = 3,
            width = "0.7",
            name = L["Uncheck All"],
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
        ["DRUID"] = {
            order = 4,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["DRUID"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["DRUID"],
            args = {},
        },
        ["HUNTER"] = {
            order = 5,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["HUNTER"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["HUNTER"],
            args = {},
        },
        ["MAGE"] = {
            order = 6,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["MAGE"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["MAGE"],
            args = {},
        },
        ["PALADIN"] = {
            order = 7,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["PALADIN"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["PALADIN"],
            args = {},
        },
        ["PRIEST"] = {
            order = 8,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["PRIEST"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["PRIEST"],
            args = {},
        },
        ["ROGUE"] = {
            order = 9,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["ROGUE"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["ROGUE"],
            args = {},
        },
        ["SHAMAN"] = {
            order = 10,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["SHAMAN"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["SHAMAN"],
            args = {},
        },
        ["WARLOCK"] = {
            order = 11,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["WARLOCK"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["WARLOCK"],
            args = {},
        },
        ["WARRIOR"] = {
            order = 12,
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
        local defaultSpells = auraType == AURA_TYPE_DEBUFF and LibClassAuras.GetClassDebuffs(class) or LibClassAuras.GetClassBuffs(class)
        local classSpells = auraType == AURA_TYPE_DEBUFF and LibClassAuras.GetClassDebuffs(class) or LibClassAuras.GetClassBuffs(class)
        local dbSpells = Gladdy.dbi and Gladdy.dbi.profile[path]
        if dbSpells then
            for k,v in pairs(dbSpells) do
                if v.class == class then
                    tinsert(classSpells, {
                        id = { k },
                        name = GetSpellInfo(k),
                        texture = select(3, GetSpellInfo(k))
                    })
                end
            end
        end
        table.sort(classSpells, function(a, b)
            return a.name:upper() < b.name:upper()
        end)
        args.group = {
            name = "",
            type = "group",
            inline = true,
            order = 1,
            args = {}
        }
        args.group.args.add = {
            order = 0,
            width = "2",
            name = auraType == AURA_TYPE_DEBUFF and L["Add Debuff"] or L["Add Buff"],
            type = "input",
            dialogControl = "GladdySearchEditBoxAuras",
            width = "double",
            get = function()
                return ""
            end,
            set = function(_, value)
                local spellName = GetSpellInfo(value)
                if not spellName then
                    return
                end
                local db = Gladdy.dbi.profile[path]

                local exists = false
                for k,v in pairs(Gladdy.db[path]) do
                    local searchName, _, searchIcon = GetSpellInfo(value)
                    local dbName, _, dbIcon = GetSpellInfo(k)
                    if tostring(k) == tostring(value) then
                        value = tostring(value)
                        exists = true
                        class = v.class
                        break
                    elseif searchName == dbName and searchIcon == dbIcon then -- same spell
                        exists = true
                        value = k
                        class = v.class
                        break
                    end
                end
                if not exists then
                    local values = Gladdy:SearchAllSpellIdsBySpellId(value)
                    Gladdy.db[path][tostring(value)] = {
                        class = class,
                        active = true,
                        ids = values
                    }

                    Gladdy.options.args["Buffs and Debuffs"].args = Gladdy.modules["Buffs and Debuffs"]:GetOptions()
                    Gladdy.modules["Buffs and Debuffs"]:UpdateTrackedAuras()

                    LibStub("AceConfigRegistry-3.0"):NotifyChange("Gladdy")
                    LibStub("AceConfigDialog-3.0"):SelectGroup("Gladdy", "Buffs and Debuffs", optionPath, class)
                end
                LibStub("AceConfigDialog-3.0"):SelectGroup("Gladdy", "Buffs and Debuffs", optionPath, class)
            end,
        }
        for i=1, #classSpells do
            local libSpellId = classSpells[i].id[#classSpells[i].id]
            local _, _, texture = GetSpellInfo(libSpellId)
            if classSpells[i].texture then
                texture = classSpells[i].texture
            end
            args.group.args[tostring(libSpellId)] = {
                name = "",
                type = "group",
                inline = true,
                order = i,
                args = {
                    [tostring(libSpellId)] = {
                        order = 1,
                        name = classSpells[i].name,
                        desc = Gladdy:GetSpellDescription(libSpellId),
                        type = "toggle",
                        width = 1.1,
                        image = texture,
                        arg = libSpellId
                    },
                    delete = {
                        order = 2,
                        name = "",
                        type = "execute",
                        width = 0.1,
                        image = select(3, GetSpellInfo(28084)),
                        imageWidth = 15,
                        imageHeight = 15,
                        hidden = function()
                            for _,v in pairs(defaultSpells) do
                                if v and tostring(v.id[#v.id]) == tostring(libSpellId) then
                                    return true
                                end
                            end
                        end,
                        func = function()
                            defaultDebuffs[libSpellId] = nil
                            Gladdy.db[path][libSpellId] = nil
                            Gladdy.modules["Buffs and Debuffs"]:UpdateTrackedAuras()
                            Gladdy.options.args["Buffs and Debuffs"].args = Gladdy.modules["Buffs and Debuffs"]:GetOptions()
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("Gladdy")
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("Gladdy")
                            LibStub("AceConfigDialog-3.0"):SelectGroup("Gladdy", "Buffs and Debuffs", optionPath, class)--LibStub("AceConfigDialog-3.0"):SelectGroup("Gladdy", "Buffs and Debuffs", "trackedDebuffs", "HUNTER")
                        end,
                    }
                },

            }
            defaultDebuffs[tostring(libSpellId)] = {
                id = classSpells[i].id,
                class = class,
                active = true,
            }
        end
        return args
    end
    if Gladdy.expansion == "Wrath" then
        spells["DEATHKNIGHT"] = {
            order = 3,
            type = "group",
            name = LOCALIZED_CLASS_NAMES_MALE["DEATHKNIGHT"],
            icon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
            iconCoords = CLASS_ICON_TCOORDS["DEATHKNIGHT"],
            args = {},
        }
        spells["DEATHKNIGHT"].args = assignForClass("DEATHKNIGHT")
    end
    spells["DRUID"].args = assignForClass("DRUID")
    spells["HUNTER"].args = assignForClass("HUNTER")
    spells["MAGE"].args = assignForClass("MAGE")
    spells["PALADIN"].args = assignForClass("PALADIN")
    spells["PRIEST"].args = assignForClass("PRIEST")
    spells["ROGUE"].args = assignForClass("ROGUE")
    spells["SHAMAN"].args = assignForClass("SHAMAN")
    spells["WARLOCK"].args = assignForClass("WARLOCK")
    spells["WARRIOR"].args = assignForClass("WARRIOR")
    return spells, defaultDebuffs
end