local floor, str_len, tostring, str_sub, str_find, pairs = math.floor, string.len, tostring, string.sub, string.find, pairs
local CreateFrame = CreateFrame
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local ACDFrame = Gladdy:NewModule("Arena Countdown", nil, {
    countdown = true,
    arenaCountdownSize = 256,
    arenaCountdownFrameStrata = "HIGH",
    arenaCountdownFrameLevel = 50,
})

function ACDFrame:OnEvent(event, ...)
    self[event](self, ...)
end

function ACDFrame:Initialize()
    self.locale = Gladdy:GetArenaTimer()
    self.hidden = false
    self.countdown = -1
    self.texturePath = "Interface\\AddOns\\Gladdy\\Images\\Countdown\\";

    local ACDNumFrame = CreateFrame("Frame", "ACDNumFrame", UIParent)
    self.ACDNumFrame = ACDNumFrame
    self.ACDNumFrame:EnableMouse(false)
    self.ACDNumFrame:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumFrame:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumFrame:SetPoint("CENTER", 0, 128)
    self.ACDNumFrame:Hide()

    local ACDNumTens = ACDNumFrame:CreateTexture("ACDNumTens", "HIGH")
    self.ACDNumTens = ACDNumTens
    self.ACDNumTens:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumTens:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumTens:SetPoint("CENTER", self.ACDNumFrame, "CENTER", -(Gladdy.db.arenaCountdownSize/8 + Gladdy.db.arenaCountdownSize/8/2), 0)

    local ACDNumOnes = ACDNumFrame:CreateTexture("ACDNumOnes", "HIGH")
    self.ACDNumOnes = ACDNumOnes
    self.ACDNumOnes:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumOnes:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumOnes:SetPoint("CENTER", self.ACDNumFrame, "CENTER", (Gladdy.db.arenaCountdownSize/8 + Gladdy.db.arenaCountdownSize/8/2), 0)

    local ACDNumOne = ACDNumFrame:CreateTexture("ACDNumOne", "HIGH")
    self.ACDNumOne = ACDNumOne
    self.ACDNumOne:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumOne:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumOne:SetPoint("CENTER", self.ACDNumFrame, "CENTER", 0, 0)

    if Gladdy.db.countdown then
        self:RegisterMessage("JOINED_ARENA")
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_SPEC")
    end
    self.faction = UnitFactionGroup("player")
end

function ACDFrame:UpdateFrameOnce()
    if Gladdy.db.countdown then
        self:RegisterMessage("JOINED_ARENA")
        self:RegisterMessage("ENEMY_SPOTTED")
        self:RegisterMessage("UNIT_SPEC")
    else
        self:UnregisterAllMessages()
    end
    self.ACDNumFrame:SetFrameStrata(Gladdy.db.arenaCountdownFrameStrata)
    self.ACDNumFrame:SetFrameLevel(Gladdy.db.arenaCountdownFrameLevel)

    self.ACDNumFrame:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumFrame:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumFrame:SetPoint("CENTER", 0, 128)

    self.ACDNumTens:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumTens:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumTens:SetPoint("CENTER", self.ACDNumFrame, "CENTER", -(Gladdy.db.arenaCountdownSize/8 + Gladdy.db.arenaCountdownSize/8/2), 0)

    self.ACDNumOnes:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumOnes:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumOnes:SetPoint("CENTER", self.ACDNumFrame, "CENTER", (Gladdy.db.arenaCountdownSize/8 + Gladdy.db.arenaCountdownSize/8/2), 0)

    self.ACDNumOne:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumOne:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumOne:SetPoint("CENTER", self.ACDNumFrame, "CENTER", 0, 0)
end

function ACDFrame.OnUpdate(self, elapse)
    if (self.countdown > 0 and Gladdy.db.countdown) then
        self.hidden = false;
        self.ACDNumFrame:Show()
        if ((floor(self.countdown) ~= floor(self.countdown - elapse)) and (floor(self.countdown - elapse) >= 0)) then
            local str = tostring(floor(self.countdown - elapse));

            if (str_len(str) == 2) then
                -- Display has 2 digits
                self.ACDNumOne:Hide();
                self.ACDNumTens:Show();
                self.ACDNumOnes:Show();

                self.ACDNumTens:SetTexture(self.texturePath .. str_sub(str, 0, 1));
                self.ACDNumOnes:SetTexture(self.texturePath .. str_sub(str, 2, 2));
                self.ACDNumFrame:SetScale(0.7)
            elseif (str_len(str) == 1) then
                -- Display has 1 digit
                local numStr = str_sub(str, 0, 1)
                local path = numStr == "0" and self.faction or numStr
                self.ACDNumOne:Show();
                self.ACDNumOne:SetTexture(self.texturePath .. path);
                self.ACDNumOnes:Hide();
                self.ACDNumTens:Hide();
                self.ACDNumFrame:SetScale(1.0)
            end
        end
        self.countdown = self.countdown - elapse;
    else
        self.hidden = true;
        self.ACDNumFrame:Hide()
        self.ACDNumTens:Hide();
        self.ACDNumOnes:Hide();
        self.ACDNumOne:Hide();
    end
    if (GetTime() > self.endTime) then
        self:SetScript("OnUpdate", nil)
    end
end

function ACDFrame:JOINED_ARENA()
    if Gladdy.db.countdown then
        self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
        self:SetScript("OnEvent", ACDFrame.OnEvent)
        self.endTime = GetTime() + 70
        self:SetScript("OnUpdate", ACDFrame.OnUpdate)
    end
end

function ACDFrame:ENEMY_SPOTTED()
    if not Gladdy.frame.testing then
        ACDFrame:Reset()
    end
end

function ACDFrame:UNIT_SPEC()
    if not Gladdy.frame.testing then
        ACDFrame:Reset()
    end
end

function ACDFrame:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
    for k,v in pairs(self.locale) do
        if str_find(msg, v) then
            if k == 0 then
                ACDFrame:Reset()
            else
                self.countdown = k
            end
        end
    end
end

function ACDFrame:TestOnce()
    self.countdown = 30
    self:JOINED_ARENA()
end

function ACDFrame:Reset()
    self.endTime = 0
    self.countdown = 0
    self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
    self:SetScript("OnUpdate", nil)
    self.hidden = true;
    self.ACDNumFrame:Hide()
    self.ACDNumTens:Hide();
    self.ACDNumOnes:Hide();
    self.ACDNumOne:Hide();
end

function ACDFrame:GetOptions()
    return {
        headerArenaCountdown = {
            type = "header",
            name = L["Arena Countdown"],
            order = 2,
        },
        countdown = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Turns countdown before the start of an arena match on/off."],
            order = 3,
            width = "full",
        }),
        arenaCountdownSize = Gladdy:option({
            type = "range",
            name = L["Size"],
            order = 4,
            min = 64,
            max = 512,
            step = 16,
            width = "full",
            disabled = function() return not Gladdy.db.countdown end,
        }),
        headerAuraLevel = {
            type = "header",
            name = L["Frame Strata and Level"],
            order = 5,
        },
        arenaCountdownFrameStrata = Gladdy:option({
            type = "select",
            name = L["Frame Strata"],
            order = 6,
            values = Gladdy.frameStrata,
            sorting = Gladdy.frameStrataSorting,
            disabled = function() return not Gladdy.db.countdown end,
        }),
        arenaCountdownFrameLevel = Gladdy:option({
            type = "range",
            name = L["Frame Level"],
            min = 0,
            max = 500,
            step = 1,
            order = 7,
            width = "full",
            disabled = function() return not Gladdy.db.countdown end,
        }),
    }
end
