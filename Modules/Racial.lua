local ceil, floor, string_format, tonumber = ceil, floor, string.format, tonumber

local CreateFrame = CreateFrame
local GetTime = GetTime



local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Racial = Gladdy:NewModule("Racial", nil, {
    racialFont = "DorisPP",
    racialFontScale = 1,
    racialEnabled = true,
    racialSize = 60 + 20 + 1,
    racialWidthFactor = 0.9,
    racialAnchor = "trinket",
    racialPos = "RIGHT",
    racialXOffset = 0,
    racialYOffset = 0,
    racialBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    racialBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    racialDisableCircle = false,
    racialCooldownAlpha = 1,
})

local ANCHORS = { ["LEFT"] = "RIGHT", ["RIGHT"] = "LEFT", ["BOTTOM"] = "TOP", ["TOP"] = "BOTTOM"}

function Racial:Initialize()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("RACIAL_USED")
end

local function iconTimer(self,elapsed)
    if (self.active) then
        if (self.timeLeft <= 0) then
            self.active = false
            self.cooldown:Clear()
        else
            self.timeLeft = self.timeLeft - elapsed
        end

        local timeLeft = ceil(self.timeLeft)

        if timeLeft >= 60 then
            -- more than 1 minute
            self.cooldownFont:SetTextColor(1, 1, 0)
            self.cooldownFont:SetText(floor(timeLeft / 60) .. ":" .. string_format("%02.f", floor(timeLeft - floor(timeLeft / 60) * 60)))
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.racialFont), (self:GetWidth()/2 - 0.15* self:GetWidth()) * Gladdy.db.racialFontScale, "OUTLINE")
        elseif timeLeft < 60 and timeLeft >= 21 then
            -- between 60s and 21s (green)
            self.cooldownFont:SetTextColor(0.7, 1, 0)
            self.cooldownFont:SetText(timeLeft)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.racialFont), (self:GetWidth()/2 - 1) * Gladdy.db.racialFontScale, "OUTLINE")
        elseif timeLeft < 20.9 and timeLeft >= 11 then
            -- between 20s and 11s (green)
            self.cooldownFont:SetTextColor(0, 1, 0)
            self.cooldownFont:SetText(timeLeft)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.racialFont), (self:GetWidth()/2 - 1) * Gladdy.db.racialFontScale, "OUTLINE")
        elseif timeLeft <= 10 and timeLeft >= 5 then
            -- between 10s and 5s (orange)
            self.cooldownFont:SetTextColor(1, 0.7, 0)
            self.cooldownFont:SetFormattedText("%.1f", timeLeft)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.racialFont), (self:GetWidth()/2 - 1) * Gladdy.db.racialFontScale, "OUTLINE")
        elseif timeLeft < 5 and timeLeft > 0 then
            -- between 5s and 1s (red)
            self.cooldownFont:SetTextColor(1, 0, 0)
            self.cooldownFont:SetFormattedText("%.1f", timeLeft >= 0.0 and timeLeft or 0.0)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.racialFont), (self:GetWidth()/2 - 1) * Gladdy.db.racialFontScale, "OUTLINE")
        else
            self.cooldownFont:SetText("")
        end
    end
end

function Racial:CreateFrame(unit)
    local racial = CreateFrame("Button", "GladdyTrinketButton" .. unit, Gladdy.buttons[unit])
    racial:EnableMouse(false)
    racial.texture = racial:CreateTexture(nil, "BACKGROUND")
    racial.texture:SetAllPoints(racial)
    racial.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
    --racial.texture:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_02")

    racial.cooldown = CreateFrame("Cooldown", nil, racial, "CooldownFrameTemplate")
    racial.cooldown.noCooldownCount = true --Gladdy.db.racialDisableOmniCC
    racial.cooldown:SetHideCountdownNumbers(true)

    racial.cooldownFrame = CreateFrame("Frame", nil, racial)
    racial.cooldownFrame:ClearAllPoints()
    racial.cooldownFrame:SetPoint("TOPLEFT", racial, "TOPLEFT")
    racial.cooldownFrame:SetPoint("BOTTOMRIGHT", racial, "BOTTOMRIGHT")

    racial.cooldownFont = racial.cooldownFrame:CreateFontString(nil, "OVERLAY")
    racial.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.racialFont), 20, "OUTLINE")
    --trinket.cooldownFont:SetAllPoints(trinket.cooldown)
    racial.cooldownFont:SetJustifyH("CENTER")
    racial.cooldownFont:SetPoint("CENTER")

    racial.borderFrame = CreateFrame("Frame", nil, racial)
    racial.borderFrame:SetAllPoints(racial)
    racial.texture.overlay = racial.borderFrame:CreateTexture(nil, "OVERLAY")
    racial.texture.overlay:SetAllPoints(racial)
    racial.texture.overlay:SetTexture(Gladdy.db.racialBorderStyle)

    racial:SetScript("OnUpdate", iconTimer)

    Gladdy.buttons[unit].racial = racial
    self.frames[unit] = racial
end

function Racial:UpdateFrame(unit)
    local racial = self.frames[unit]
    if (not racial) then
        return
    end

    local width, height = Gladdy.db.racialSize * Gladdy.db.racialWidthFactor, Gladdy.db.racialSize

    racial:SetWidth(width)
    racial:SetHeight(height)
    racial.cooldown:SetWidth(width - width/16)
    racial.cooldown:SetHeight(height - height/16)
    racial.cooldown:ClearAllPoints()
    racial.cooldown:SetPoint("CENTER", racial, "CENTER")
    racial.cooldown.noCooldownCount = true -- Gladdy.db.racialDisableOmniCC
    racial.cooldown:SetAlpha(Gladdy.db.racialCooldownAlpha)

    racial.texture:ClearAllPoints()
    racial.texture:SetAllPoints(racial)

    racial.texture.overlay:SetTexture(Gladdy.db.racialBorderStyle)
    racial.texture.overlay:SetVertexColor(Gladdy.db.racialBorderColor.r, Gladdy.db.racialBorderColor.g, Gladdy.db.racialBorderColor.b, Gladdy.db.racialBorderColor.a)

    racial:ClearAllPoints()
    local margin = (Gladdy.db.highlightInset and 0 or Gladdy.db.highlightBorderSize) + Gladdy.db.padding
    local parent = Gladdy.buttons[unit][Gladdy.db.racialAnchor]
    if (Gladdy.db.racialPos == "RIGHT") then
        racial:SetPoint(ANCHORS[Gladdy.db.racialPos], parent, Gladdy.db.racialPos, Gladdy.db.padding + Gladdy.db.racialXOffset, Gladdy.db.racialYOffset)
    elseif (Gladdy.db.racialPos == "LEFT") then
        racial:SetPoint(ANCHORS[Gladdy.db.racialPos], parent, Gladdy.db.racialPos, -Gladdy.db.padding + Gladdy.db.racialXOffset, Gladdy.db.racialYOffset)
    elseif (Gladdy.db.racialPos == "TOP") then
        racial:SetPoint(ANCHORS[Gladdy.db.racialPos], parent, Gladdy.db.racialPos, Gladdy.db.racialXOffset, Gladdy.db.padding + Gladdy.db.racialYOffset)
    elseif (Gladdy.db.racialPos == "BOTTOM") then
        racial:SetPoint(ANCHORS[Gladdy.db.racialPos], parent, Gladdy.db.racialPos, Gladdy.db.racialXOffset, -Gladdy.db.padding + Gladdy.db.racialYOffset)
    end

    if (Gladdy.db.racialEnabled == false) then
        racial:Hide()
    else
        racial:Show()
    end
end

function Racial:JOINED_ARENA()
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
    self:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end

function Racial:RACIAL_USED(unit)
    local racial = self.frames[unit]
    local button = Gladdy.buttons[unit]
    if (not racial or not button or not button.race) then
        return
    end
    Racial:Used(unit, GetTime(), Gladdy:Racials()[button.race].duration)
end

function Racial:Used(unit, startTime, duration)
    local racial = self.frames[unit]
    if (not racial) then
        return
    end
    if not racial.active then
        racial.timeLeft = duration
        if not Gladdy.db.trinketDisableCircle then racial.cooldown:SetCooldown(startTime, duration) end
        racial.active = true
    end
end

function Racial:ENEMY_SPOTTED(unit)
    local racial = self.frames[unit]
    if (not racial) then
        return
    end
    racial.texture:SetTexture(Gladdy:Racials()[Gladdy.buttons[unit].race].texture)
end

function Racial:ResetUnit(unit)
    local racial = self.frames[unit]
    if (not racial) then
        return
    end
    racial.texture:SetTexture(nil)
    racial.timeLeft = nil
    racial.active = false
    racial.cooldown:Clear()
    racial.cooldownFont:SetText("")
end

function Racial:Test(unit)
    Racial:ENEMY_SPOTTED(unit)
    if (unit == "arena1" or unit == "arena3") then
        Racial:Used(unit, GetTime(), Gladdy:Racials()[Gladdy.buttons[unit].race].duration)
    end
end

function Racial:GetOptions()
    return {
        headerTrinket = {
            type = "header",
            name = L["Racial"],
            order = 2,
        },
        racialEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enable racial icon"],
            order = 3,
        }),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            args = {
                general = {
                    type = "group",
                    name = L["Size"],
                    order = 1,
                    args = {
                        header = {
                            type = "header",
                            name = L["Size"],
                            order = 1,
                        },
                        racialSize = Gladdy:option({
                            type = "range",
                            name = L["Icon size"],
                            min = 5,
                            max = 100,
                            step = 1,
                            order = 2,
                        }),
                        racialWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            order = 3,
                        }),
                    },
                },
                cooldown = {
                    type = "group",
                    name = L["Cooldown"],
                    order = 2,
                    args = {
                        header = {
                            type = "header",
                            name = L["Cooldown"],
                            order = 4,
                        },
                        racialDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 7,
                            width = "full",
                        }),
                        racialCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 8,
                        }),
                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 3,
                    args = {
                        header = {
                            type = "header",
                            name = L["Font"],
                            order = 4,
                        },
                        racialFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        racialFontScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the font"],
                            order = 12,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
                        }),
                    },
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Icon position"],
                            order = 4,
                        },
                        racialAnchor = Gladdy:option({
                            type = "select",
                            name = L["Anchor"],
                            desc = L["This changes the anchor of the racial icon"],
                            order = 20,
                            values = {
                                ["trinket"] = L["Trinket"],
                                ["classIcon"] = L["Class Icon"],
                                ["healthBar"] = L["Health Bar"],
                                ["powerBar"] = L["Power Bar"],
                            },
                        }),
                        racialPos = Gladdy:option({
                            type = "select",
                            name = L["Icon position"],
                            desc = L["This changes position relative to its anchor of the racial icon"],
                            order = 21,
                            values = {
                                ["LEFT"] = L["Left"],
                                ["RIGHT"] = L["Right"],
                                ["TOP"] = L["Top"],
                                ["BOTTOM"] = L["Bottom"],
                            },
                        }),
                        racialXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 23,
                            min = -400,
                            max = 400,
                            step = 0.1,
                        }),
                        racialYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 24,
                            min = -400,
                            max = 400,
                            step = 0.1,
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Border"],
                            order = 4,
                        },
                        racialBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 31,
                            values = Gladdy:GetIconStyles()
                        }),
                        racialBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Border color"],
                            desc = L["Color of the border"],
                            order = 32,
                            hasAlpha = true,
                        }),
                    },
                },
            },
        },
    }
end