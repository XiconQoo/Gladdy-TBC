local ceil, floor, string_format, tonumber = ceil, floor, string.format, tonumber
local C_PvP = C_PvP

local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local Trinket = Gladdy:NewModule("Trinket", nil, {
    trinketFont = "DorisPP",
    trinketFontScale = 1,
    trinketEnabled = true,
    trinketSize = 60 + 20 + 1,
    trinketWidthFactor = 0.9,
    trinketPos = "RIGHT",
    trinketBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    trinketBorderColor = { r = 0, g = 0, b = 0, a = 1 },
    trinketDisableCircle = false,
    trinketCooldownAlpha = 1,
})
LibStub("AceComm-3.0"):Embed(Trinket)

function Trinket:Initialize()
    self.frames = {}

    self:RegisterMessage("JOINED_ARENA")
end

local function iconTimer(self, elapsed)
    if (self.active) then
        if (self.timeLeft <= 0) then
            self.active = false
            self.cooldown:Clear()
            Gladdy:SendMessage("TRINKET_READY", self.unit)
        else
            self.timeLeft = self.timeLeft - elapsed
        end

        local timeLeft = ceil(self.timeLeft)

        if timeLeft >= 60 then
            -- more than 1 minute
            self.cooldownFont:SetTextColor(1, 1, 0)
            self.cooldownFont:SetText(floor(timeLeft / 60) .. ":" .. string_format("%02.f", floor(timeLeft - floor(timeLeft / 60) * 60)))
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), (self:GetWidth()/2 - 0.15*self:GetWidth()) * Gladdy.db.trinketFontScale, "OUTLINE")
        elseif timeLeft < 60 and timeLeft >= 21 then
            -- between 60s and 21s (green)
            self.cooldownFont:SetTextColor(0.7, 1, 0)
            self.cooldownFont:SetText(timeLeft)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), (self:GetWidth()/2 - 1) * Gladdy.db.trinketFontScale, "OUTLINE")
        elseif timeLeft < 20.9 and timeLeft >= 11 then
            -- between 20s and 11s (green)
            self.cooldownFont:SetTextColor(0, 1, 0)
            self.cooldownFont:SetText(timeLeft)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), (self:GetWidth()/2 - 1) * Gladdy.db.trinketFontScale, "OUTLINE")
        elseif timeLeft <= 10 and timeLeft >= 5 then
            -- between 10s and 5s (orange)
            self.cooldownFont:SetTextColor(1, 0.7, 0)
            self.cooldownFont:SetFormattedText("%.1f", self.timeLeft)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), (self:GetWidth()/2 - 1) * Gladdy.db.trinketFontScale, "OUTLINE")
        elseif timeLeft < 5 and timeLeft > 0 then
            -- between 5s and 1s (red)
            self.cooldownFont:SetTextColor(1, 0, 0)
            self.cooldownFont:SetFormattedText("%.1f", self.timeLeft >= 0.0 and self.timeLeft or 0.0)
            self.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), (self:GetWidth()/2 - 1) * Gladdy.db.trinketFontScale, "OUTLINE")
        else
            self.cooldownFont:SetText("")
        end
    end
end

function Trinket:CreateFrame(unit)
    local trinket = CreateFrame("Button", "GladdyTrinketButton" .. unit, Gladdy.buttons[unit])
    trinket:EnableMouse(false)
    trinket.texture = trinket:CreateTexture(nil, "BACKGROUND")
    trinket.texture:SetAllPoints(trinket)
    trinket.texture:SetTexture("Interface\\Icons\\INV_Jewelry_TrinketPVP_02")
    trinket.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")

    trinket.cooldown = CreateFrame("Cooldown", nil, trinket, "CooldownFrameTemplate")
    trinket.cooldown.noCooldownCount = true --Gladdy.db.trinketDisableOmniCC
    trinket.cooldown:SetHideCountdownNumbers(true)

    trinket.cooldownFrame = CreateFrame("Frame", nil, trinket)
    trinket.cooldownFrame:ClearAllPoints()
    trinket.cooldownFrame:SetPoint("TOPLEFT", trinket, "TOPLEFT")
    trinket.cooldownFrame:SetPoint("BOTTOMRIGHT", trinket, "BOTTOMRIGHT")

    trinket.cooldownFont = trinket.cooldownFrame:CreateFontString(nil, "OVERLAY")
    trinket.cooldownFont:SetFont(Gladdy.LSM:Fetch("font", Gladdy.db.trinketFont), 20, "OUTLINE")
    --trinket.cooldownFont:SetAllPoints(trinket.cooldown)
    trinket.cooldownFont:SetJustifyH("CENTER")
    trinket.cooldownFont:SetPoint("CENTER")

    trinket.borderFrame = CreateFrame("Frame", nil, trinket)
    trinket.borderFrame:SetAllPoints(trinket)
    trinket.texture.overlay = trinket.borderFrame:CreateTexture(nil, "OVERLAY")
    trinket.texture.overlay:SetAllPoints(trinket)
    trinket.texture.overlay:SetTexture(Gladdy.db.trinketBorderStyle)

    trinket.unit = unit

    trinket:SetScript("OnUpdate", iconTimer)

    self.frames[unit] = trinket
    Gladdy.buttons[unit].trinket = trinket
end

function Trinket:UpdateFrame(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    local width, height = Gladdy.db.trinketSize * Gladdy.db.trinketWidthFactor, Gladdy.db.trinketSize

    trinket:SetWidth(width)
    trinket:SetHeight(height)
    trinket.cooldown:SetWidth(width - width/16)
    trinket.cooldown:SetHeight(height - height/16)
    trinket.cooldown:ClearAllPoints()
    trinket.cooldown:SetPoint("CENTER", trinket, "CENTER")
    trinket.cooldown.noCooldownCount = true -- Gladdy.db.trinketDisableOmniCC
    trinket.cooldown:SetAlpha(Gladdy.db.trinketCooldownAlpha)

    trinket.texture:ClearAllPoints()
    trinket.texture:SetAllPoints(trinket)

    trinket.texture.overlay:SetTexture(Gladdy.db.trinketBorderStyle)
    trinket.texture.overlay:SetVertexColor(Gladdy.db.trinketBorderColor.r, Gladdy.db.trinketBorderColor.g, Gladdy.db.trinketBorderColor.b, Gladdy.db.trinketBorderColor.a)

    trinket:ClearAllPoints()
    local margin = (Gladdy.db.highlightInset and 0 or Gladdy.db.highlightBorderSize) + Gladdy.db.padding
    if (Gladdy.db.classIconPos == "LEFT") then
        if (Gladdy.db.trinketPos == "RIGHT") then
            trinket:SetPoint("TOPLEFT", Gladdy.buttons[unit].healthBar, "TOPRIGHT", margin, 0)
        else
            trinket:SetPoint("TOPRIGHT", Gladdy.buttons[unit].classIcon, "TOPLEFT", -Gladdy.db.padding, 0)
        end
    else
        if (Gladdy.db.trinketPos == "RIGHT") then
            trinket:SetPoint("TOPLEFT", Gladdy.buttons[unit].classIcon, "TOPRIGHT", Gladdy.db.padding, 0)
        else
            trinket:SetPoint("TOPRIGHT", Gladdy.buttons[unit].healthBar, "TOPLEFT", -margin, 0)
        end
    end

    if (Gladdy.db.trinketEnabled == false) then
        trinket:Hide()
    else
        trinket:Show()
    end
end

function Trinket:Reset()
    self:UnregisterEvent("ARENA_COOLDOWNS_UPDATE")
    self:SetScript("OnEvent", nil)
end

function Trinket:ResetUnit(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end

    trinket.timeLeft = nil
    trinket.active = false
    trinket.cooldown:Clear()
    trinket.cooldownFont:SetText("")
end

function Trinket:Test(unit)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end
    if (unit == "arena2" or unit == "arena3") then
        self:Used(unit, GetTime() * 1000, 120000)
    end
end

function Trinket:JOINED_ARENA()
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE")
    self:SetScript("OnEvent", function(self, event, ...)
        if self[event] then
            self[event](self, ...)
        end
    end)
end

function Trinket:ARENA_COOLDOWNS_UPDATE()
    for i=1, Gladdy.curBracket do
        local unit = "arena" .. i
        local spellID, itemID, startTime, duration = C_PvP.GetArenaCrowdControlInfo(unit);
        if (spellID) then
            if (startTime ~= 0 and duration ~= 0) then
                self:Used(unit, startTime, duration)
            end
        end
    end
end

function Trinket:Used(unit, startTime, duration)
    local trinket = self.frames[unit]
    if (not trinket) then
        return
    end
    if not trinket.active then
        trinket.timeLeft = (startTime/1000.0 + duration/1000.0) - GetTime()
        if not Gladdy.db.trinketDisableCircle then trinket.cooldown:SetCooldown(startTime/1000.0, duration/1000.0) end
        trinket.active = true
        Gladdy:SendMessage("TRINKET_USED", unit)
    end
end

function Trinket:GetOptions()
    return {
        headerTrinket = {
            type = "header",
            name = L["Trinket"],
            order = 2,
        },
        trinketEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Enable trinket icon"],
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
                        trinketSize = Gladdy:option({
                            type = "range",
                            name = L["Size"],
                            min = 5,
                            max = 100,
                            step = 1,
                            order = 4,
                            width = "full",
                        }),
                        trinketWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon width factor"],
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            order = 6,
                            width = "full",
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
                        trinketDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 7,
                            width = "full",
                        }),
                        trinketCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            min = 0,
                            max = 1,
                            step = 0.1,
                            order = 8,
                            width = "full",
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
                        trinketFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 11,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        trinketFontScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the font"],
                            order = 12,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
                            width = "full",
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
                        trinketPos = Gladdy:option({
                            type = "select",
                            name = L["Icon position"],
                            desc = L["This changes positions of the trinket"],
                            order = 21,
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
                    order = 4,
                    args = {
                        header = {
                            type = "header",
                            name = L["Border"],
                            order = 4,
                        },
                        trinketBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 31,
                            values = Gladdy:GetIconStyles()
                        }),
                        trinketBorderColor = Gladdy:colorOption({
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