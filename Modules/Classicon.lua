local Gladdy = LibStub("Gladdy")
local CreateFrame = CreateFrame
local L = Gladdy.L
local Classicon = Gladdy:NewModule("Classicon", 80, {
    classIconPos = "LEFT",
    classIconSize = 60 + 20 + 1,
    classIconWidthFactor = 0.9,
    classIconBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    classIconBorderColor = { r = 0, g = 0, b = 0, a = 1 },
})

function Classicon:Initialize()
    self.frames = {}

    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_DEATH")
end

function Classicon:CreateFrame(unit)
    local classIcon = CreateFrame("Frame", nil, Gladdy.buttons[unit])
    classIcon:SetFrameStrata("MEDIUM")
    classIcon:SetFrameLevel(1)
    classIcon.texture = classIcon:CreateTexture(nil, "BACKGROUND")
    classIcon.texture:SetAllPoints(classIcon)

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
    local margin = Gladdy.db.highlightBorderSize + Gladdy.db.padding
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
        group = {
            type = "group",
            childGroups = "tree",
            name = "Frame",
            order = 3,
            args = {
                size = {
                    type = "group",
                    name = L["Icon size"],
                    order = 1,
                    args = {
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

local function getClassIcon(class)
    -- see https://wow.gamepedia.com/Class_icon
    local classIcon = "Interface\\Addons\\Gladdy\\Images\\Classes\\"
    if class == "DRUID" then
        return classIcon .. "inv_misc_monsterclaw_04"
    elseif class == "HUNTER" then
        return classIcon .. "inv_weapon_bow_07"
    elseif class == "MAGE" then
        return classIcon .. "inv_staff_13"
    elseif class == "PALADIN" then
        return classIcon .. "inv_hammer_01"
    elseif class == "PRIEST" then
        return classIcon .. "inv_staff_30"
    elseif class == "ROGUE" then
        return classIcon .. "inv_throwingknife_04"
    elseif class == "SHAMAN" then
        return classIcon .. "inv_jewelry_talisman_04"
    elseif class == "WARLOCK" then
        return classIcon .. "spell_nature_drowsy"
    elseif class == "WARRIOR" then
        return classIcon .. "inv_sword_27"
    end
end

function Classicon:ENEMY_SPOTTED(unit)
    local classIcon = self.frames[unit]
    if (not classIcon) then
        return
    end

    classIcon.texture:SetTexture(getClassIcon(Gladdy.buttons[unit].class))
    --classIcon.texture:SetTexCoord(unpack(CLASS_BUTTONS[Gladdy.buttons[unit].class]))
    classIcon.texture:SetAllPoints(classIcon)
end