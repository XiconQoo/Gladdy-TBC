local floor, str_len, tostring, str_sub, str_find, pairs = math.floor, string.len, tostring, string.sub, string.find, pairs
local CreateFrame = CreateFrame
local GetLocale = GetLocale
local GetTime = GetTime

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local ACDFrame = Gladdy:NewModule("Arena Countdown", nil, {
    countdown = true,
    arenaCountdownSize = 256
})

function ACDFrame:OnEvent(event, ...)
    self[event](self, ...)
end

function ACDFrame:Initialize()
    if ACDFrame.locales[GetLocale()] then
        self.locale = ACDFrame.locales[GetLocale()]
    else
        self.locale = ACDFrame.locales["default"]
    end
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
    self:RegisterMessage("ENEMY_SPOTTED")
    self:RegisterMessage("UNIT_SPEC")
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
    if (GetTime() > self.endTime) then
        self:SetScript("OnUpdate", nil)
    end
end

function ACDFrame:JOINED_ARENA()
    self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
    self:SetScript("OnEvent", ACDFrame.OnEvent)
    self.endTime = GetTime() + 70
    self:SetScript("OnUpdate", ACDFrame.OnUpdate)
end

function ACDFrame:ENEMY_SPOTTED()
    ACDFrame:Reset()
end

function ACDFrame:UNIT_SPEC()
    ACDFrame:Reset()
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
    self.endTime = 0
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
        }),
    }
end

ACDFrame.locales = {
    ["default"] = {
        [61] = "One minute until the Arena battle begins!",
        [31] = "Thirty seconds until the Arena battle begins!",
        [16] = "Fifteen seconds until the Arena battle begins!",
        [0] = "The Arena battle has begun!",
    },
    ["esES"] = {
        [61] = "¡Un minuto hasta que dé comienzo la batalla en arena!",
        [31] = "¡Treinta segundos hasta que comience la batalla en arena!",
        [16] = "¡Quince segundos hasta que comience la batalla en arena!",
        [0] = "¡La batalla en arena ha comenzado!",
    },
    ["ptBR"] = {
        [61] = "Um minuto até a batalha na Arena começar!",
        [31] = "Trinta segundos até a batalha na Arena começar!",
        [16] = "Quinze segundos até a batalha na Arena começar!",
        [0] = "A batalha na Arena começou!",
    },
    ["deDE"] = {
        [61] = "Noch eine Minute bis der Arenakampf beginnt!",
        [31] = "Noch dreißig Sekunden bis der Arenakampf beginnt!",
        [16] = "Noch fünfzehn Sekunden bis der Arenakampf beginnt!",
        [0] = "Der Arenakampf hat begonnen!",
    },
    ["frFR"] = {
        [60] = "Le combat d'arène commence dans une minute\194\160!",
        [30] = "Le combat d'arène commence dans trente secondes\194\160!",
        [15] = "Le combat d'arène commence dans quinze secondes\194\160!",
        [0] = "Le combat d'arène commence\194\160!",
    },
    ["ruRU"] = {
        [61] = "Одна минута до начала боя на арене!",
        [31] = "Тридцать секунд до начала боя на арене!",
        [16] = "До начала боя на арене осталось 15 секунд.",
        [0] = "Бой начался!",
    },
    ["itIT"] = { -- TODO
        -- Beta has no itIT version available?
    },
    ["koKR"] = {
        [61] = "투기장 전투 시작 1분 전입니다!",
        [31] = "투기장 전투 시작 30초 전입니다!",
        [16] = "투기장 전투 시작 15초 전입니다!",
        [0] = "투기장 전투가 시작되었습니다!",
    },
    ["zhCN"] = {
        [61] = "竞技场战斗将在一分钟后开始！",
        [31] = "竞技场战斗将在三十秒后开始！",
        [16] = "竞技场战斗将在十五秒后开始！",
        [0] = "竞技场的战斗开始了！",
    },
    ["zhTW"] = {
        [61] = "1分鐘後競技場戰鬥開始!",
        [31] = "30秒後競技場戰鬥開始!",
        [16] = "15秒後競技場戰鬥開始!",
        [0] = "競技場戰鬥開始了!",
    },
}

ACDFrame.locales["esMX"] = ACDFrame.locales["esES"]
ACDFrame.locales["ptPT"] = ACDFrame.locales["ptBR"]
