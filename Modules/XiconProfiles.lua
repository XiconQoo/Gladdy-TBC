local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local XiconProfiles = Gladdy:NewModule("XiconProfiles", nil, {
})

function XiconProfiles:ApplyKlimp()
    Gladdy.db.castBarXOffset = -7
    Gladdy.db.powerActual = false
    Gladdy.db.npCastbarsBorderSize = 4
    Gladdy.db.healthBarTexture = "Minimalist"
    Gladdy.db.highlight = false
    Gladdy.db.healthMax = false
    Gladdy.db.castBarYOffset = -24
    Gladdy.db.castBarFont = "Friz Quadrata TT"
    Gladdy.db.drXOffset = -7
    Gladdy.db.classIconBorderColor.a = 0.6200000047683716
    Gladdy.db.auraBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp"
    Gladdy.db.powerBarHeight = 7
    Gladdy.db.powerBarFontSize = 8
    Gladdy.db.announcements.dest = "party"
    Gladdy.db.powerMax = false
    Gladdy.db.healthBarFontSize = 17
    Gladdy.db.healthBarBorderSize = 5
    Gladdy.db.npCastbarsWidth = 85
    Gladdy.db.npCastbarsTexture = "Minimalist"
    Gladdy.db.cooldown = false
    Gladdy.db.barWidth = 190
    Gladdy.db.healthBarBgColor.a = 0.6700000166893005
    Gladdy.db.drCooldownPos = "LEFT"
    Gladdy.db.npCastbarsFont = "Friz Quadrata TT"
    Gladdy.db.trinketSize = 40
    Gladdy.db.y = 501.7654729182068
    Gladdy.db.x = 1048.626941536808
    Gladdy.db.bottomMargin = 2
    Gladdy.db.npCastbarsIconSize = 14
    Gladdy.db.castBarTexture = "Minimalist"
    Gladdy.db.drFont = "Friz Quadrata TT"
    Gladdy.db.highlightBorderSize = 1
    Gladdy.db.healthBarFont = "Friz Quadrata TT"
    Gladdy.db.padding = 0
    Gladdy.db.castBarBorderSize = 5
    Gladdy.db.powerBarFontColor.a = 0
    Gladdy.db.classIconSize = 40
    Gladdy.db.npCastbarsHeight = 14
    Gladdy.db.castBarIconColor.a = 0.6200000047683716
    Gladdy.db.trinketFontScale = 1.3
    Gladdy.db.trinketBorderColor.a = 0.6200000047683716
    Gladdy.db.leaderBorder = false
    Gladdy.db.powerPercentage = true
    Gladdy.db.drYOffset = 33
    Gladdy.db.healthBarHeight = 40
    Gladdy.db.powerBarTexture = "Minimalist"
    Gladdy.db.cooldownFont = "Friz Quadrata TT"
    Gladdy.db.powerBarFont = "Friz Quadrata TT"
    Gladdy.db.auraFont = "Friz Quadrata TT"
    Gladdy.db.powerBarBorderSize = 3
    Gladdy.db.trinketFont = "Friz Quadrata TT"
    Gladdy.db.castBarIconSize = 20
    Gladdy.db.cooldownYOffset = 15.10000000000002
    Gladdy.db.cooldownXOffset = 5
    Gladdy.db.cooldownMaxIconsPerLine = 4
    Gladdy.db.cooldownBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp"
    Gladdy.db.cooldownYPos = "RIGHT"
    Gladdy.db.cooldownCooldownAlpha = 0.6000000000000001
    Gladdy.db.cooldownSize = 25.25495910644531
    Gladdy.db.cooldownFontScale = 0.6
    Gladdy.db.cooldownBorderColor = {
        b = 0.3019607843137255,
        g = 0.3019607843137255,
        r = 0.3019607843137255,
    }
    Gladdy.db.locked = true
    Gladdy.db.classIconWidthFactor = 1
    Gladdy.db.buffsFontScale = 0.8
    Gladdy.db.buffsIconSize = 24
    Gladdy.db.buffsCooldownAlpha = 0.8
    Gladdy.db.trinketWidthFactor = 1
    Gladdy.db.frameScale = 1
    Gladdy.db.drWidthFactor = 1.3
    Gladdy:UpdateFrame()
end

function XiconProfiles:ApplyKnall()
    Gladdy.db["cooldownCooldownAlpha"] = 0.6000000000000001
    Gladdy.db["buffsIconPadding"] = 1.5
    Gladdy.db["powerBarBorderSize"] = 5.5
    Gladdy.db["trinketSize"] = 66
    Gladdy.db["cooldownFontScale"] = 0.8
    Gladdy.db["healthBarHeight"] = 54
    Gladdy.db["drYOffset"] = -14
    Gladdy.db["classIconSize"] = 70
    Gladdy.db["padding"] = 0
    Gladdy.db["buffsFontScale"] = 0.8
    Gladdy.db["healthBarFontColor"]["a"] = 0
    Gladdy.db["buffsCooldownGrowDirection"] = "LEFT"
    Gladdy.db["cooldownXOffset"] = 1
    Gladdy.db["castBarIconSize"] = 26
    Gladdy.db["bottomMargin"] = -35
    Gladdy.db["y"] = 457.111085058903
    Gladdy.db["x"] = 993.110763706718
    Gladdy.db["locked"] = true
    Gladdy.db["drCooldownPos"] = "LEFT"
    Gladdy.db["castBarWidth"] = 162
    Gladdy.db["healthBarBorderSize"] = 8.5
    Gladdy.db["buffsYOffset"] = -47
    Gladdy.db["frameScale"] = 0.9
    Gladdy.db["announcements"]["dest"] = "fct"
    Gladdy.db["powerBarFontSize"] = 8.576186180114746
    Gladdy.db["powerBarHeight"] = 11
    Gladdy.db["drIconPadding"] = 2
    Gladdy.db["buffsXOffset"] = -245.7
    Gladdy.db["castBarYOffset"] = -13.59999999999997
    Gladdy.db["drFontScale"] = 0.8
    Gladdy.db["castBarHeight"] = 26
    Gladdy.db["castBarHeight"] = 26
    Gladdy.db["buffsCooldownAlpha"] = 0.8
    Gladdy.db["drCooldownAlpha"] = 0.7000000000000001
    Gladdy.db["buffsIconSize"] = 35
    Gladdy:UpdateFrame()
end

function XiconProfiles:ApplyClassic()
    Gladdy.db["buffsIconSize"] = 29
    Gladdy.db["drCooldownAlpha"] = 0.8
    Gladdy.db["castBarBgColor"] = {
        ["a"] = 0.4000000357627869,
        ["b"] = 0.7372549019607844,
        ["g"] = 0.7372549019607844,
        ["r"] = 0.7372549019607844,
    }
    Gladdy.db["npCastbarsBorderSize"] = 4
    Gladdy.db["healthBarTexture"] = "Minimalist"
    Gladdy.db["drFontScale"] = 0.9
    Gladdy.db["highlight"] = false
    Gladdy.db["buffsCooldownPos"] = "LEFT"
    Gladdy.db["castBarYOffset"] = -67
    Gladdy.db["castBarFont"] = "Friz Quadrata TT"
    Gladdy.db["buffsXOffset"] = -1
    Gladdy.db["drXOffset"] = -1
    Gladdy.db["classIconBorderColor"]["a"] = 0
    Gladdy.db["cooldownYOffset"] = 10
    Gladdy.db["auraBorderStyle"] = "Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp"
    Gladdy.db["powerBarHeight"] = 16
    Gladdy.db["powerBarFontSize"] = 10.21056747436523
    Gladdy.db["announcements"]["dest"] = "party"
    Gladdy.db["healthBarFontSize"] = 13.42293167114258
    Gladdy.db["buffsYOffset"] = -2.099999999999966
    Gladdy.db["healthBarBorderSize"] = 4
    Gladdy.db["healthBarBorderStyle"] = "Gladdy Tooltip squared"
    Gladdy.db["barWidth"] = 190
    Gladdy.db["castBarWidth"] = 265
    Gladdy.db["cooldownMaxIconsPerLine"] = 4
    Gladdy.db["drCooldownPos"] = "LEFT"
    Gladdy.db["locked"] = true
    Gladdy.db["npCastbarsFont"] = "Friz Quadrata TT"
    Gladdy.db["cooldownFontScale"] = 0.6
    Gladdy.db["auraFont"] = "Friz Quadrata TT"
    Gladdy.db["y"] = 511.0100769632991
    Gladdy.db["x"] = 912.8048284050892
    Gladdy.db["bottomMargin"] = 20
    Gladdy.db["trinketFont"] = "Friz Quadrata TT"
    Gladdy.db["npCastbarsIconSize"] = 14
    Gladdy.db["trinketFontScale"] = 1.3
    Gladdy.db["cooldownBorderStyle"] = "Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp"
    Gladdy.db["castBarTexture"] = "Minimalist"
    Gladdy.db["classIconWidthFactor"] = 1
    Gladdy.db["cooldownYPos"] = "RIGHT"
    Gladdy.db["castBarIconSize"] = 20
    Gladdy.db["drFont"] = "Friz Quadrata TT"
    Gladdy.db["buffsCooldownAlpha"] = 0.8
    Gladdy.db["cooldownXOffset"] = 1
    Gladdy.db["buffsCooldownGrowDirection"] = "LEFT"
    Gladdy.db["highlightBorderSize"] = 1
    Gladdy.db["drIconSize"] = 34
    Gladdy.db["powerBarBgColor"] = {
        ["a"] = 0.3500000238418579,
        ["r"] = 0.8,
        ["g"] = 0.8,
        ["b"] = 0.8,
    }
    Gladdy.db["castBarXOffset"] = 287
    Gladdy.db["healthBarFont"] = "Friz Quadrata TT"
    Gladdy.db["buffsFontScale"] = 0.8
    Gladdy.db["castBarIconStyle"] = "Interface\\AddOns\\Gladdy\\Images\\Border_squared_blp"
    Gladdy.db["padding"] = 0
    Gladdy.db["powerBarBorderStyle"] = "Gladdy Tooltip squared"
    Gladdy.db["castBarBorderSize"] = 4
    Gladdy.db["classIconSize"] = 48
    Gladdy.db["castBarColor"]["g"] = 0.8274509803921568
    Gladdy.db["castBarColor"]["b"] = 0
    Gladdy.db["castBarIconColor"]["a"] = 0.6200000047683716
    Gladdy.db["leaderBorder"] = false
    Gladdy.db["castBarBorderStyle"] = "Gladdy Tooltip squared"
    Gladdy.db["drYOffset"] = -3
    Gladdy.db["cooldownCooldownAlpha"] = 0.6000000000000001
    Gladdy.db["healthBarHeight"] = 30
    Gladdy.db["healthBarBgColor"] = {
        ["a"] = 0.3600000143051148,
        ["r"] = 0.7294117647058823,
        ["g"] = 0.7294117647058823,
        ["b"] = 0.7294117647058823,
    }
    Gladdy.db["powerBarTexture"] = "Minimalist"
    Gladdy.db["healthBarBorderColor"] = {
        ["r"] = 0.4313725490196079,
        ["g"] = 0.4313725490196079,
        ["b"] = 0.4313725490196079,
        ["a"] = 1,
    }
    Gladdy.db["powerBarFont"] = "Friz Quadrata TT"
    Gladdy.db["cooldownFont"] = "Friz Quadrata TT"
    Gladdy.db["cooldownBorderColor"] = {
        ["r"] = 0.3019607843137255,
        ["g"] = 0.3019607843137255,
        ["b"] = 0.3019607843137255,
        ["a"] = 1,
    }
    Gladdy.db["trinketWidthFactor"] = 1
    Gladdy.db["powerBarBorderSize"] = 4
    Gladdy.db["trinketSize"] = 47
    Gladdy.db["cooldownSize"] = 25.25495910644531
    Gladdy.db["trinketBorderColor"]["a"] = 0
    Gladdy.db["npCastbarsTexture"] = "Minimalist"
    Gladdy:UpdateFrame()
end

function XiconProfiles:GetOptions()
    return {
        headerProfileClassic = {
            type = "header",
            name = L["Classic Profile"],
            order = 2,
        },
        classicProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                XiconProfiles:ApplyClassic()
            end,
            name = " ",
            desc = "Classic Profile",
            image = "Interface\\AddOns\\Gladdy\\Images\\BasicProfiles\\Classic1.blp",
            imageWidth = 256,
            imageHeight = 128,
            width = "full",
            order = 3,
        },
        headerProfileKnall = {
            type = "header",
            name = L["Knall's Profile"],
            order = 4,
        },
        knallProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                XiconProfiles:ApplyKnall()
            end,
            name = " ",
            desc = "Knall's Profile",
            image = "Interface\\AddOns\\Gladdy\\Images\\BasicProfiles\\Knall1.blp",
            imageWidth = 256,
            imageHeight = 128,
            width = "full",
            order = 5,
        },
        headerProfileKlimp = {
            type = "header",
            name = L["Klimp's Profile"],
            order = 6,
        },
        klimpProfiles = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                XiconProfiles:ApplyKlimp()
            end,
            image = "Interface\\AddOns\\Gladdy\\Images\\BasicProfiles\\Klimp1.blp",
            imageWidth = 256,
            imageHeight = 128,
            name = " ",
            desc = "Klimp's Profile",
            width = "full",
            order = 7,
        },
    }
end