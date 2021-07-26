local floor, str_len, tostring, str_sub, str_find, pairs = math.floor, string.len, tostring, string.sub, string.find, pairs
local CreateFrame = CreateFrame

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L
local ShadowsightTimer = Gladdy:NewModule("Shadowsight Timer", nil, {
    shadowsightTimerEnabled = true,
    shadowsightTimerLocked = false,
    shadowsightTimerScale = 1,
    shadowsightTimerRelPoint1 = "CENTER",
    shadowsightTimerRelPoint2 = "CENTER",
    shadowsightTimerX = 0,
    shadowsightTimerY = 0,
    shadowsightAnnounce = true,
})

function ShadowsightTimer:OnEvent(event, ...)
    self[event](self, ...)
end

function ShadowsightTimer:Initialize()
    self.locale = Gladdy:GetArenaTimer()
    self:RegisterMessage("JOINED_ARENA")
    self:CreateTimerFrame()
end

function ShadowsightTimer:JOINED_ARENA()
    self:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
    self:SetScript("OnEvent", ShadowsightTimer.OnEvent)
    self.timerFrame.font:SetText("1:30")
    self.timerFrame.font:SetTextColor(1, 0.8, 0)
    self.timerFrame:Show()
end

function ShadowsightTimer:CHAT_MSG_BG_SYSTEM_NEUTRAL(msg)
    for k,v in pairs(self.locale) do
        if str_find(msg, v) then
            if k == 0 then
                self:Start()
            end
        end
    end
end

function ShadowsightTimer:Test()
    if Gladdy.db.shadowsightTimerEnabled then
        self.timerFrame:Show()
        self:Start()
    end
end

function ShadowsightTimer:Reset()
    self.timerFrame:Hide()
    self.timerFrame:SetScript("OnUpdate", nil)
    self.timerFrame.font:SetTextColor(1, 0.8, 0)
end

function ShadowsightTimer:CreateTimerFrame()
    self.timerFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    self.timerFrame:SetPoint(Gladdy.db.shadowsightTimerRelPoint1, nil, Gladdy.db.shadowsightTimerRelPoint, Gladdy.db.shadowsightTimerX, Gladdy.db.shadowsightTimerY)

    local backdrop = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = {left = 0, right = 0, top = 0, bottom = 0}
    }

    self.timerFrame:SetBackdrop(backdrop)
    self.timerFrame:SetBackdropColor(0,0,0,0.8)
    self.timerFrame:SetHeight(17)
    self.timerFrame:SetWidth(35)

    self.timerFrame:SetMovable(true)
    self.timerFrame:EnableMouse(true)

    self.timerFrame.texture = self.timerFrame:CreateTexture(nil,"OVERLAY")
    self.timerFrame.texture:SetWidth(16)
    self.timerFrame.texture:SetHeight(16)
    self.timerFrame.texture:SetTexture("Interface\\Icons\\Spell_Shadow_EvilEye")
    self.timerFrame.texture:SetTexCoord(0.125,0.875,0.125,0.875)
    self.timerFrame.texture:SetPoint("RIGHT", self.timerFrame, "LEFT")

    self.timerFrame.font = self.timerFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
    self.timerFrame.font:SetPoint("LEFT", 5, 0)
    self.timerFrame.font:SetJustifyH("LEFT")
    self.timerFrame.font:SetTextColor(1, 0.8, 0)

    self.timerFrame:SetScript("OnMouseDown",function(self) self:StartMoving() end)
    self.timerFrame:SetScript("OnMouseUp",function(self)
        self:StopMovingOrSizing()
        Gladdy.db.shadowsightTimerRelPoint1,_,Gladdy.db.shadowsightTimerRelPoint2,Gladdy.db.shadowsightTimerX,Gladdy.db.shadowsightTimerY = self:GetPoint()
    end)
    self.timerFrame:SetScale(Gladdy.db.shadowsightTimerScale)
    self.timerFrame:Hide()
end

function ShadowsightTimer:UpdateFrameOnce()
    self.timerFrame:EnableMouse(not Gladdy.db.shadowsightTimerLocked)
    if Gladdy.db.shadowsightTimerEnabled then
        self.timerFrame:SetScale(Gladdy.db.shadowsightTimerScale)
        self.timerFrame:ClearAllPoints()
        self.timerFrame:SetPoint(Gladdy.db.shadowsightTimerRelPoint1, nil, Gladdy.db.shadowsightTimerRelPoint2, Gladdy.db.shadowsightTimerX, Gladdy.db.shadowsightTimerY)
        self.timerFrame:Show()
    else
        self.timerFrame:SetScale(Gladdy.db.shadowsightTimerScale)
        self.timerFrame:ClearAllPoints()
        self.timerFrame:SetPoint(Gladdy.db.shadowsightTimerRelPoint1, nil, Gladdy.db.shadowsightTimerRelPoint2, Gladdy.db.shadowsightTimerX, Gladdy.db.shadowsightTimerY)
        self.timerFrame:Hide()
    end
end

function ShadowsightTimer:Start()
    self.timerFrame.endTime = 91
    self.timerFrame.timeSinceLastUpdate = 0
    self.timerFrame:SetScript("OnUpdate", ShadowsightTimer.OnUpdate)
end

function ShadowsightTimer.OnUpdate(self, elapsed)
    self.timeSinceLastUpdate = self.timeSinceLastUpdate + elapsed;
    self.endTime = self.endTime - elapsed

    if (self.timeSinceLastUpdate > 0.1) then
        self.font:SetFormattedText(floor(self.endTime / 60) .. ":" ..  "%02d", self.endTime - floor(self.endTime / 60) * 60)
        self.timeSinceLastUpdate = 0;
        if floor(self.endTime) == 15 and Gladdy.db.shadowsightAnnounce then
            Gladdy:SendMessage("SHADOWSIGHT", L["Shadowsight up in %ds"]:format(15))
        end
    end
    if self.endTime <= 0 then
        if Gladdy.db.shadowsightAnnounce then
            Gladdy:SendMessage("SHADOWSIGHT", L["Shadowsight up!"])
        end
        self:SetScript("OnUpdate", nil)
        self.font:SetText("0:00")
        self.font:SetTextColor(0, 1, 0)
    end
end

function ShadowsightTimer:GetOptions()
    return {
        headerArenaCountdown = {
            type = "header",
            name = L["Shadowsight Timer"],
            order = 2,
        },
        shadowsightTimerEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            --desc = L["Turns countdown before the start of an arena match on/off."],
            order = 3,
            width = "full",
        }),
        shadowsightTimerLocked = Gladdy:option({
            type = "toggle",
            name = L["Locked"],
            --desc = L["Turns countdown before the start of an arena match on/off."],
            order = 4,
            width = "full",
        }),
        shadowsightAnnounce = Gladdy:option({
            type = "toggle",
            name = L["Announce"],
            --desc = L["Turns countdown before the start of an arena match on/off."],
            order = 5,
            width = "full",
        }),
        shadowsightTimerScale = Gladdy:option({
            type = "range",
            name = L["Scale"],
            order = 6,
            min = 0.1,
            max = 5,
            step = 0.1,
            width = "full",
        }),
    }
end