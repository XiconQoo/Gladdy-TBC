local select = select

local Gladdy = LibStub("Gladdy")
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local L = Gladdy.L
local Classicon = Gladdy:NewModule("Class Icon", 80, {
    classIconPos = "LEFT",
    classIconSize = 60 + 20 + 1,
    classIconWidthFactor = 0.9,
    classIconBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    classIconBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    classIconSpecIcon = false,
})

local classIconPath = "Interface\\Addons\\Gladdy\\Images\\Classes\\"
local classIcons = {
    ["DRUID"] = classIconPath .. "inv_misc_monsterclaw_04",
    ["HUNTER"] = classIconPath .. "inv_weapon_bow_07",
    ["MAGE"] = classIconPath .. "inv_staff_13",
    ["PALADIN"] = classIconPath .. "inv_hammer_01",
    ["PRIEST"] = classIconPath .. "inv_staff_30",
    ["ROGUE"] = classIconPath .. "inv_throwingknife_04",
    ["SHAMAN"] = classIconPath .. "inv_jewelry_talisman_04",
    ["WARLOCK"] = classIconPath .. "spell_nature_drowsy",
    ["WARRIOR"] = classIconPath .. "inv_sword_27",
}

local specIcons = {
    --DRUID
    ["DRUID"] = {
        [L["Balance"]] = select(3, GetSpellInfo(8921)), -- Moonfire
        [L["Feral"]] = select(3, GetSpellInfo(27545)), -- Cat Form
        [L["Restoration"]] = select(3, GetSpellInfo(5185)), -- Healing Touch
    },
    ["HUNTER"] = {
        [L["Beast Mastery"]] = select(3, GetSpellInfo(1515)), -- Tame Beast
        [L["Marksmanship"]] = select(3, GetSpellInfo(42243)), -- Volley
        [L["Survival"]] = select(3, GetSpellInfo(1495)), -- Mongoose Bite
    },
    ["MAGE"] = {
        [L["Arcane"]] = select(3, GetSpellInfo(1459)), -- Arcane Intellect
        [L["Fire"]] = select(3, GetSpellInfo(133)), -- Fireball
        [L["Frost"]] = select(3, GetSpellInfo(116)), -- Frostbolt
    },
    ["PALADIN"] = {
        [L["Holy"]] = select(3, GetSpellInfo(635)), -- Holy Light
        [L["Retribution"]] = select(3, GetSpellInfo(7294)), -- Retribution Aura
        [L["Protection"]] = select(3, GetSpellInfo(32828)), -- Protection Aura
    },
    ["PRIEST"] = {
        [L["Discipline"]] = select(3, GetSpellInfo(1243)), -- Power Word: Fortitude
        [L["Shadow"]] = select(3, GetSpellInfo(589)), -- Shadow Word: Pain
        [L["Holy"]] = select(3, GetSpellInfo(635)), -- Holy Light
    },
    ["ROGUE"] = {
        [L["Assassination"]] = select(3, GetSpellInfo(1329)), -- Mutilate (Eviscerate? 2098)
        [L["Combat"]] = select(3, GetSpellInfo(53)), -- Backstab
        [L["Subtlety"]] = select(3, GetSpellInfo(1784)), -- Stealth
    },
    ["SHAMAN"] = {
        [L["Elemental"]] = select(3, GetSpellInfo(403)), -- Lightning Bolt
        [L["Enhancement"]] = select(3, GetSpellInfo(324)), -- Lightning Shield
        [L["Restoration"]] = select(3, GetSpellInfo(331)), -- Healing Wave
    },
    ["WARLOCK"] = {
        [L["Affliction"]] = select(3, GetSpellInfo(6789)), -- Affliction
        [L["Demonology"]] = select(3, GetSpellInfo(5500)), -- Sense Demons
        [L["Destruction"]] = select(3, GetSpellInfo(5740)), -- Rain of Fire
    },
    ["WARRIOR"] = {
        [L["Arms"]] = select(3, GetSpellInfo(12294)), -- Mortal Strike
        [L["Fury"]] = select(3, GetSpellInfo(12325)), -- Inner Rage
        [L["Protection"]] = select(3, GetSpellInfo(71)), -- Defensive Stance
    },
}

function Classicon:Initialize()
    self.frames = {}

    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_DEATH")
    self:RegisterMessage("UNIT_SPEC")
end

function Classicon:CreateFrame(unit)
    local classIcon = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    classIcon:EnableMouse(false)
    classIcon:SetFrameStrata("MEDIUM")
    classIcon:SetFrameLevel(1)
    classIcon.texture = classIcon:CreateTexture(nil, "BACKGROUND")
    classIcon.texture:SetAllPoints(classIcon)
    classIcon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")

    classIcon.texture.overlay = classIcon:CreateTexture(nil, "BORDER")
    classIcon.texture.overlay:SetAllPoints(classIcon)
    classIcon.texture.overlay:SetTexture(Gladdy.db.classIconBorderStyle)

    classIcon:SetFrameStrata("MEDIUM")
    classIcon:SetFrameLevel(2)

    classIcon:ClearAllPoints()
    if (Gladdy.db.classIconPos == "RIGHT") then
        classIcon:SetPoint("TOPLEFT", Gladdy.buttons[unit].healthBar, "TOPRIGHT", 2, 2)
    else
        classIcon:SetPoint("TOPRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", -2, 2)
    end

    Gladdy.buttons[unit].classIcon = classIcon
    self.frames[unit] = classIcon
end

function Classicon:UpdateFrame(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then
        return
    end

    classIcon:SetWidth(Gladdy.db.classIconSize * Gladdy.db.classIconWidthFactor)
    classIcon:SetHeight(Gladdy.db.classIconSize)

    classIcon:ClearAllPoints()
    local margin = (Gladdy.db.highlightInset and 0 or Gladdy.db.highlightBorderSize) + Gladdy.db.padding
    if (Gladdy.db.classIconPos == "LEFT") then
        classIcon:SetPoint("TOPRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", -margin, 0)
    else
        classIcon:SetPoint("TOPLEFT", Gladdy.buttons[unit], "TOPRIGHT", margin, 0)
    end

    classIcon.texture:ClearAllPoints()
    classIcon.texture:SetAllPoints(classIcon)

    classIcon.texture.overlay:SetTexture(Gladdy.db.classIconBorderStyle)
    classIcon.texture.overlay:SetVertexColor(Gladdy.db.classIconBorderColor.r, Gladdy.db.classIconBorderColor.g, Gladdy.db.classIconBorderColor.b, Gladdy.db.classIconBorderColor.a)
end

function Classicon:ENEMY_SPOTTED(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then
        return
    end

    classIcon.texture:SetTexture(classIcons[Gladdy.buttons[unit].class])
    --classIcon.texture:SetTexCoord(unpack(CLASS_BUTTONS[Gladdy.buttons[unit].class]))
    classIcon.texture:SetAllPoints(classIcon)
end

function Classicon:UNIT_SPEC(unit, spec)
    local classIcon = self.frames[unit]
    if (not Gladdy.db.classIconSpecIcon or not classIcon) then
        return
    end
    classIcon.texture:SetTexture(specIcons[Gladdy.buttons[unit].class][spec])
end

function Classicon:Test(unit)
    self:ENEMY_SPOTTED(unit)
end

function Classicon:ResetUnit(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then
        return
    end

    classIcon.texture:SetTexture("")
end

function Classicon:GetOptions()
    return {
        headerClassicon = {
            type = "header",
            name = L["Class Icon"],
            order = 2,
        },
        classIconSpecIcon = {
            type = "toggle",
            name = L["Show Spec Icon"],
            desc = L["Shows Spec Icon once spec is detected"],
            order = 3,
            get = function(info) return Gladdy.db.classIconSpecIcon end,
            set = function(info, value)
                Gladdy.db.classIconSpecIcon = value
                if Gladdy.curBracket and Gladdy.curBracket > 0 then
                    for i=1,Gladdy.curBracket do
                        local unit = "arena" .. i
                        if (Gladdy.buttons[unit] and Gladdy.buttons[unit].spec) then
                            self:ENEMY_SPOTTED(unit)
                            self:UNIT_SPEC(unit, Gladdy.buttons[unit].spec)
                        end
                    end
                end
            end
        },
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            args = {
                size = {
                    type = "group",
                    name = L["Icon size"],
                    order = 1,
                    args = {
                        header = {
                            type = "header",
                            name = L["Icon size"],
                            order = 1,
                        },
                        classIconSize = Gladdy:option({
                            type = "range",
                            name = L["Icon size"],
                            min = 1,
                            max = 100,
                            step = 1,
                            order = 3,
                        }),
                        classIconWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            order = 4,
                        }),
                    },
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 1,
                    args = {
                        headerPosition = {
                            type = "header",
                            name = L["Position"],
                            order = 5,
                        },
                        classIconPos = Gladdy:option({
                            type = "select",
                            name = L["Icon position"],
                            desc = L["This changes positions with trinket"],
                            order = 6,
                            values = {
                                ["LEFT"] = L["Left"],
                                ["RIGHT"] = L["Right"],
                            },
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 1,
                    args = {
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 10,
                        },
                        classIconBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 11,
                            values = Gladdy:GetIconStyles()
                        }),
                        classIconBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 12,
                            hasAlpha = true,
                        }),
                    },
                },
            },
        },
    }
end