local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

local XiconProfiles = Gladdy:NewModule("XiconProfiles", nil, {
})

function XiconProfiles:ApplyKlimp()
    local deserialized = Gladdy.modules["ExportImport"]:Decode(Gladdy:GetKlimpProfile())
    if deserialized then
        Gladdy.modules["ExportImport"]:ApplyImport(deserialized, Gladdy.db)
    end
    Gladdy:Reset()
    Gladdy:HideFrame()
    Gladdy:ToggleFrame(3)
end

function XiconProfiles:ApplyKnall()
    local deserialized = Gladdy.modules["ExportImport"]:Decode(Gladdy:GetKnallProfile())
    if deserialized then
        Gladdy.modules["ExportImport"]:ApplyImport(deserialized, Gladdy.db)
    end
    Gladdy:Reset()
    Gladdy:HideFrame()
    Gladdy:ToggleFrame(3)
end

function XiconProfiles:ApplyClassic()
    local deserialized = Gladdy.modules["ExportImport"]:Decode(Gladdy:GetClassicProfile())
    if deserialized then
        Gladdy.modules["ExportImport"]:ApplyImport(deserialized, Gladdy.db)
    end
    Gladdy:Reset()
    Gladdy:HideFrame()
    Gladdy:ToggleFrame(3)
end

function XiconProfiles:ApplyBlizz()
    local deserialized = Gladdy.modules["ExportImport"]:Decode(Gladdy:GetBlizzardProfile())
    if deserialized then
        Gladdy.modules["ExportImport"]:ApplyImport(deserialized, Gladdy.db)
    end
    Gladdy:Reset()
    Gladdy:HideFrame()
    Gladdy:ToggleFrame(3)
end

function XiconProfiles:GetOptions()
    return {
        headerProfileBlizzard = {
            type = "header",
            name = L["Blizzard Profile"],
            order = 2,
        },
        blizzardProfile = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                XiconProfiles:ApplyBlizz()
            end,
            name = " ",
            desc = "Blizzard Profile",
            image = "Interface\\AddOns\\Gladdy\\Images\\BasicProfiles\\Blizz1.blp",
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 3,
        },
        headerProfileClassic = {
            type = "header",
            name = L["Classic Profile"],
            order = 4,
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
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 5,
        },
        headerProfileKnall = {
            type = "header",
            name = L["Knall's Profile"],
            order = 6,
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
            imageWidth = 350,
            imageHeight = 175,
            width = "full",
            order = 7,
        },
        headerProfileKlimp = {
            type = "header",
            name = L["Klimp's Profile"],
            order = 8,
        },
        klimpProfiles = {
            type = "execute",
            func = function()
                Gladdy.dbi:ResetProfile(Gladdy.dbi:GetCurrentProfile())
                XiconProfiles:ApplyKlimp()
            end,
            image = "Interface\\AddOns\\Gladdy\\Images\\BasicProfiles\\Klimp1.blp",
            imageWidth = 350,
            imageHeight = 175,
            name = " ",
            desc = "Klimp's Profile",
            width = "full",
            order = 9,
        },

    }
end