local floor, str_len, tostring, str_sub, str_find = math.floor, string.len, tostring, string.sub, string.find
local CreateFrame = CreateFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local ACDFrame = Gladdy:NewModule("Countdown", nil, {
    countdown = true,
    arenaCountdownSize = 256
})

function ACDFrame:OnEvent(event, ...)
    self[event](self, ...)
end

function ACDFrame:Initialize()
    self.hidden = false
    self.countdown = -1
    self.texturePath = "Interface\\AddOns\\Gladdy\\Images\\Countdown\\";

    local ACDNumFrame = CreateFrame("Frame", "ACDNumFrame", UIParent)
    ACDNumFrame:EnableMouse(false)
    ACDNumFrame:SetHeight(256)
    ACDNumFrame:SetWidth(256)
    ACDNumFrame:SetPoint("CENTER", 0, 128)
    ACDNumFrame:Show()
    self.ACDNumFrame = ACDNumFrame

    local ACDNumTens = ACDNumFrame:CreateTexture("ACDNumTens", "HIGH")
    ACDNumTens:SetWidth(256)
    ACDNumTens:SetHeight(128)
    ACDNumTens:SetPoint("CENTER", ACDNumFrame, "CENTER", -48, 0)
    self.ACDNumTens = ACDNumTens

    local ACDNumOnes = ACDNumFrame:CreateTexture("ACDNumOnes", "HIGH")
    ACDNumOnes:SetWidth(256)
    ACDNumOnes:SetHeight(128)
    ACDNumOnes:SetPoint("CENTER", ACDNumFrame, "CENTER", 48, 0)
    self.ACDNumOnes = ACDNumOnes

    local ACDNumOne = ACDNumFrame:CreateTexture("ACDNumOne", "HIGH")
    ACDNumOne:SetWidth(256)
    ACDNumOne:SetHeight(128)
    ACDNumOne:SetPoint("CENTER", ACDNumFrame, "CENTER", 0, 0)
    self.ACDNumOne = ACDNumOne

    self:RegisterMessage("JOINED_ARENA")
end

function ACDFrame.OnUpdate(self, elapse)
    if (self.countdown > 0 and Gladdy.db.countdown) then
        self.hidden = false;

        if ((floor(self.countdown) ~= floor(self.countdown - elapse)) and (floor(self.countdown - elapse) >= 0)) then
            local str = tostring(floor(self.countdown - elapse));

            if (floor(self.countdown - elapse) == 0) then
                self.ACDNumTens:Hide();
                self.ACDNumOnes:Hide();
                self.ACDNumOne:Hide();
            elseif (str_len(str) == 2) then
                -- Display has 2 digits
                self.ACDNumOne:Hide();
                self.ACDNumTens:Show();
                self.ACDNumOnes:Show();

                self.ACDNumTens:SetTexture(self.texturePath .. str_sub(str, 0, 1));
                self.ACDNumOnes:SetTexture(self.texturePath .. str_sub(str, 2, 2));
                self.ACDNumFrame:SetScale(0.7)
            elseif (str_len(str) == 1) then
                -- Display has 1 digit
                self.ACDNumOne:Show();
                self.ACDNumOne:SetTexture(self.texturePath .. str_sub(str, 0, 1));
                self.ACDNumOnes:Hide();
                self.ACDNumTens:Hide();
                self.ACDNumFrame:SetScale(1.0)
            end
        end
        self.countdown = self.countdown - elapse;
    else
        self.hidden = true;
        self.ACDNumTens:Hide();
        self.ACDNumOnes:Hide();
        self.ACDNumOne:Hide();
    end
end

function ACDFrame:JOINED_ARENA()
    self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
    self:SetScript("OnEvent", ACDFrame.OnEvent)
    self:SetScript("OnUpdate", ACDFrame.OnUpdate)
end

function ACDFrame:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
    if (str_find(msg, "L'ar\195\168ne ouvre ses portes dans 60 secondes !")) then
        self.countdown = 61
        return
    end
    if (str_find(msg, "L'ar\195\168ne ouvre ses portes dans 30 secondes !")) then
        self.countdown = 31
        return
    end
    if (str_find(msg, "L'ar\195\168ne ouvre ses portes dans 15 secondes !")) then
        self.countdown = 16
        return
    end
    if (str_find(msg, "L'ar\195\168ne ouvre ses portes dans 10 secondes !")) then
        self.countdown = 11
        return
    end
    if (str_find(msg, "One minute until the Arena battle begins!")) then
        self.countdown = 61
        return
    end
    if (str_find(msg, "Thirty seconds until the Arena battle begins!")) then
        self.countdown = 31
        return
    end
    if (str_find(msg, "Fifteen seconds until the Arena battle begins!")) then
        self.countdown = 16
        return
    end
    if (str_find(msg, "Ten seconds until the Arena battle begins!")) then
        self.countdown = 10
        return
    end
    if (str_find(msg, "The Arena battle has begun!")) then
        ACDFrame:SetScript("OnUpdate", nil)
        return
    end
end

function ACDFrame:UpdateFrame()
    self.ACDNumFrame:SetHeight(Gladdy.db.arenaCountdownSize)
    self.ACDNumFrame:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumFrame:SetPoint("CENTER", 0, 128)

    self.ACDNumTens:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumTens:SetHeight(Gladdy.db.arenaCountdownSize/2)
    self.ACDNumTens:SetPoint("CENTER", self.ACDNumFrame, "CENTER", -(Gladdy.db.arenaCountdownSize/8 + Gladdy.db.arenaCountdownSize/8/2), 0)

    self.ACDNumOnes:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumOnes:SetHeight(Gladdy.db.arenaCountdownSize/2)
    self.ACDNumOnes:SetPoint("CENTER", self.ACDNumFrame, "CENTER", (Gladdy.db.arenaCountdownSize/8 + Gladdy.db.arenaCountdownSize/8/2), 0)

    self.ACDNumOne:SetWidth(Gladdy.db.arenaCountdownSize)
    self.ACDNumOne:SetHeight(Gladdy.db.arenaCountdownSize/2)
    self.ACDNumOne:SetPoint("CENTER", self.ACDNumFrame, "CENTER", 0, 0)
end

function ACDFrame:Test()
    self.countdown = 30
    self:JOINED_ARENA()
end

function ACDFrame:Reset()
    self.countdown = 0
    self:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
    self:SetScript("OnUpdate", nil)
    self.hidden = true;
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
            name = L["Turn on/off"],
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
        }),
    }
end
