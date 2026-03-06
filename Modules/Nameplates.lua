local pairs, ipairs, select, tinsert, tremove, tbl_sort, tostring, tonumber, rand = pairs, ipairs, select, table.insert, table.remove, table.sort, tostring, tonumber, math.random
local GetSpellInfo = GetSpellInfo
local CreateFrame, GetTime = CreateFrame, GetTime
local UnitGUID, UnitAura, UnitExists = UnitGUID, UnitAura, UnitExists
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = "DEBUFF", "BUFF"
local C_NamePlate = C_NamePlate

local Gladdy = LibStub("Gladdy")
local L = Gladdy.L

-------------------------------------------
--- Helper functions
-------------------------------------------

-- Uses the same aura system as Auras module

-------------------------------------------
--- INIT
-------------------------------------------

local Nameplates = Gladdy:NewModule("Nameplates", nil, {
    nameplateEnabled = true,
    nameplateFont = "DorisPP",
    nameplateFontSizeScale = 1,
    nameplateFontColor = { r = 1, g = 1, b = 0, a = 1 },
    nameplateBorderStyle = "Interface\\AddOns\\Gladdy\\Images\\Border_rounded_blp",
    nameplateBuffBorderColor = { r = 1, g = 0, b = 0, a = 1 },
    nameplateDebuffBorderColor = { r = 0, g = 1, b = 0, a = 1 },
    nameplateDisableCircle = false,
    nameplateCooldownAlpha = 1,
    nameplateSize = 30,
    nameplateWidthFactor = 1,
    nameplateIconZoomed = false,
    nameplateXOffset = 0,
    nameplateYOffset = 0,
    nameplateMaxIcons = 5,
    nameplateIconPadding = 2,
    nameplateSortOrder = "priority", -- "time", "timeleft", "priority"
    nameplateCenterIcons = false,
    nameplateFrameStrata = "FULLSCREEN_DIALOG",
    nameplateFrameLevel = 10,
})

function Nameplates:Initialize()
    self.activeNameplates = {}
    self.activeAuras = {}
    self.iconCache = {}
    self.auraFrameCache = {}
    self.testFrame = nil
    
    if Gladdy.db.nameplateEnabled then
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:RegisterMessage("AURA_GAIN")
        self:RegisterMessage("AURA_FADE")
        self:SetScript("OnEvent", Nameplates.OnEvent)
    end
end

function Nameplates.OnEvent(self, event, ...)
    Nameplates[event](self, ...)
end

function Nameplates:LoadModule()
    if Gladdy.db.nameplateEnabled then
        self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
        self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:RegisterMessage("AURA_GAIN")
        self:RegisterMessage("AURA_FADE")
        self:SetScript("OnEvent", Nameplates.OnEvent)
    else
        self:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
        self:UnregisterEvent("NAME_PLATE_UNIT_REMOVED")
        self:UnregisterMessage("AURA_GAIN")
        self:UnregisterMessage("AURA_FADE")
        self:SetScript("OnEvent", nil)
    end
end

-------------------------------------------
--- Frame Creation
-------------------------------------------

function Nameplates:CreateAuraFrame(unitID, nameplate)
    local auraFrame
    if #self.auraFrameCache > 0 then
        auraFrame = tremove(self.auraFrameCache, #self.auraFrameCache)
    else
        auraFrame = CreateFrame("Frame", nil, nameplate)
        Gladdy:PixelPerfectScaleFrame(auraFrame, true)
    end
    nameplate.gladdyAuraFrame = auraFrame
    nameplate.gladdyAuraFrame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
    nameplate.gladdyAuraFrame:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
    nameplate.gladdyAuraFrame:SetPoint("BOTTOMLEFT", nameplate, "TOPLEFT", 0, 0)
    nameplate.gladdyAuraFrame:SetPoint("BOTTOMRIGHT", nameplate, "TOPRIGHT", 0, 0)
    nameplate.gladdyAuraFrame:SetHeight(1)
    nameplate.gladdyAuraFrame.icons = {}
    nameplate.gladdyAuraFrame.unitID = unitID
end

function Nameplates:CacheAuraFrame(auraFrame, nameplate)
    if not auraFrame then
        return
    end
    for i,v in ipairs(auraFrame.icons) do
        self:CacheIcon(v, auraFrame, i)
    end

    if nameplate and nameplate.gladdyAuraFrame then
        auraFrame.icons = {}
        auraFrame.unitID = nil
        auraFrame:ClearAllPoints()
        auraFrame:Hide()
        tinsert(self.auraFrameCache, auraFrame)
        nameplate.gladdyAuraFrame = nil
    end
end


function Nameplates:CreateIcon()
    local icon
    if #self.iconCache > 0 then
        icon = table.remove(self.iconCache, #self.iconCache)
    else
        icon = CreateFrame("Frame")
        Gladdy:PixelPerfectScaleFrame(icon, true)
        icon:EnableMouse(false)
        
        icon.frame = CreateFrame("Frame", nil, icon)
        icon.frame:SetAllPoints(icon)
        icon.frame:EnableMouse(false)
        
        icon.cooldown = CreateFrame("Cooldown", nil, icon.frame, "CooldownFrameTemplate")
        icon.cooldown.noCooldownCount = true
        icon.cooldown:SetReverse(true)
        icon.cooldown:SetHideCountdownNumbers(true)
        
        icon.cooldownFrame = CreateFrame("Frame", nil, icon.frame)
        icon.cooldownFrame:ClearAllPoints()
        icon.cooldownFrame:SetAllPoints(icon.frame)
        
        icon.texture = icon.frame:CreateTexture(nil, "BACKGROUND")
        icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
        icon.texture:SetAllPoints(icon)
        icon.texture.masked = true
        
        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY", nil, 7)
        icon.border:SetAllPoints(icon)
        
        icon.text = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.text:SetJustifyH("CENTER")
        icon.text:SetPoint("CENTER")

        icon:SetScript("OnUpdate", function(self, elapsed)
            if self.active then
                if self.timeLeft <= 0 then
                    Nameplates:AURA_FADE(self.unit, self.track, self.spellID)
                else
                    if not self.noDuration then
                        self.timeLeft = self.timeLeft - elapsed
                        if not Gladdy.db.useOmnicc then
                            Gladdy:FormatTimer(self.text, self.timeLeft, self.timeLeft < 10)
                        end
                    else
                        self.text:SetText("")
                    end
                end
            end
        end)
        
        self:UpdateIcon(icon)
    end
    return icon
end

function Nameplates:CacheIcon(icon, auraFrame, index)
    if not icon then
        return
    end
    icon:Hide()
    icon:ClearAllPoints()
    icon:SetParent(nil)
    icon.unit = nil
    icon.spellID = nil
    icon.track = nil
    icon.priority = nil
    icon.startTime = nil
    icon.endTime = nil
    icon.timeLeft = nil
    icon.noDuration = nil
    icon.active = nil
    tinsert(self.iconCache, icon)
    if auraFrame and auraFrame.icons and auraFrame.icons[index] == icon then
        tremove(auraFrame.icons, index)
    end
end

function Nameplates:CacheIcons(auraFrame)
    for i = #auraFrame.icons, 1, -1 do
        self:CacheIcon(auraFrame.icons[i], auraFrame, i)
    end
end

function Nameplates:UpdateIcon(icon)
    local size = Gladdy.db.nameplateSize
    local width = size * Gladdy.db.nameplateWidthFactor
    
    icon:SetWidth(width)
    icon:SetHeight(size)
    icon.frame:SetWidth(width)
    icon.frame:SetHeight(size)
    
    icon:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
    icon:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
    icon.frame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
    icon.frame:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
    icon.cooldown:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
    icon.cooldown:SetFrameLevel(Gladdy.db.nameplateFrameLevel + 1)
    icon.cooldownFrame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
    icon.cooldownFrame:SetFrameLevel(Gladdy.db.nameplateFrameLevel + 2)
    
    icon.cooldown:ClearAllPoints()
    icon.cooldown:SetPoint("CENTER", icon, "CENTER")
    if Gladdy.db.nameplateIconZoomed then
        icon.cooldown:SetWidth(width)
        icon.cooldown:SetHeight(size)
    else
        icon.cooldown:SetWidth(width - width/16)
        icon.cooldown:SetHeight(size - size/16)
    end
    icon.cooldown:SetAlpha(Gladdy.db.nameplateCooldownAlpha)
    
    icon.text:SetFont(Gladdy:SMFetch("font", "nameplateFont"), (size/2 - 1) * Gladdy.db.nameplateFontSizeScale, "OUTLINE")
    icon.text:SetTextColor(Gladdy:SetColor(Gladdy.db.nameplateFontColor))
    
    icon.border:SetTexture(Gladdy.db.nameplateBorderStyle)
    
    if Gladdy.db.nameplateIconZoomed then
        if icon.texture.masked then
            icon.texture:SetMask("")
            icon.texture:SetTexCoord(0.1,0.9,0.1,0.9)
            icon.texture.masked = nil
        end
    else
        if not icon.texture.masked then
            icon.texture:SetMask("")
            icon.texture:SetTexCoord(0,1,0,1)
            icon.texture:SetMask("Interface\\AddOns\\Gladdy\\Images\\mask")
            icon.texture.masked = true
        end
    end
    
    icon.cooldown.noCooldownCount = not Gladdy.db.useOmnicc
    if Gladdy.db.useOmnicc then
        icon.text:Hide()
    else
        icon.text:Show()
    end
    
    if Gladdy.db.nameplateDisableCircle then
        icon.cooldown:SetAlpha(0)
    end
end

-------------------------------------------
--- Sort Functions
-------------------------------------------

function Nameplates:SortIcons(icons, sortOrder)
    if sortOrder == "time" then
        tbl_sort(icons, function(a, b)
            return (a.startTime or 0) < (b.startTime or 0)
        end)
    elseif sortOrder == "timeleft" then
        tbl_sort(icons, function(a, b)
            return (a.timeLeft or 999) < (b.timeLeft or 999)
        end)
    elseif sortOrder == "priority" then
        tbl_sort(icons, function(a, b)
            local prioA = a.priority or 0
            local prioB = b.priority or 0
            if prioA == prioB then
                return (a.timeLeft or 999) < (b.timeLeft or 999)
            end
            return prioA > prioB
        end)
    end
end

-------------------------------------------
--- Nameplate Events
-------------------------------------------

function Nameplates:NAME_PLATE_UNIT_ADDED(unitID)
    unitID = Gladdy:GetArenaUnit(unitID, false)
    if not Gladdy.db.nameplateEnabled or not UnitExists(unitID) then
        return
    end
    
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    if not nameplate then
        return
    end
    
    if not nameplate.gladdyAuraFrame then
        self:CreateAuraFrame(unitID, nameplate)
    end
    
    self.activeNameplates[unitID] = nameplate
    self:LayoutIcons(unitID)
end

function Nameplates:NAME_PLATE_UNIT_REMOVED(unitID)
    local nameplate = self.activeNameplates[unitID]
    if nameplate and nameplate.gladdyAuraFrame then
        Nameplates:CacheAuraFrame(nameplate.gladdyAuraFrame, nameplate)
    end
    self.activeNameplates[unitID] = nil
    self:LayoutIcons(unitID)
end

-------------------------------------------
--- Aura Handling
-------------------------------------------

function Nameplates:AURA_GAIN(unit, auraType, spellID, spellName, icon, duration, expirationTime, count, dispelType, n, unitCaster)
    if not Gladdy.db.nameplateEnabled then
        return
    end
    
    if Gladdy.frame and Gladdy.frame.testing and self.testFrame and self.testFrame.gladdyAuraFrame and unit == "player" then
        self.activeNameplates[unit] = self.testFrame
    end

    
    -- Use the same aura system as Auras module
    local auraData = Gladdy.enabledAuras and Gladdy.enabledAuras[auraType] and Gladdy.enabledAuras[auraType][spellID]
    --print("Nameplates:AURA_GAIN", unit, auraType, spellID, spellName, icon, duration, expirationTime, count, dispelType, n, unitCaster)
    if not auraData then
        return
    end

    if not self.activeAuras then
        self.activeAuras = {}
    end

    if not self.activeAuras[unit] then
        self.activeAuras[unit] = {}
    end

    --print("AURA_GAIN", unit, spellID, auraType)
    self.activeAuras[unit][spellID] = {
        startTime = expirationTime - duration,
        endTime = expirationTime,
        duration = duration,
        name = spellName,
        priority = auraData.priority,
        noDuration = auraData.noDuration,
        texture = auraData.texture or icon,
        track = auraType,
        active = true
    }
    --auraFrame.startTime = expirationTime - duration
    --auraFrame.endTime = expirationTime
    --auraFrame.name = spellName
    --auraFrame.spellID = spellID
    --auraFrame.timeLeft = auraFrame.noDuration and 999 or expirationTime - GetTime()
    --auraFrame.priority = auraData.priority
    --auraFrame.icon:SetTexture(auraData.texture or icon)
    --auraFrame.track = auraType
    --auraFrame.active = true


    -- Check if icon already exists
    self:LayoutIcons(unit)
end

function Nameplates:AURA_FADE(unit, auraType, spellID)
    if not Gladdy.db.nameplateEnabled  then
        return
    end
    --print("AURA_FADE", unit, auraType, spellID)
    if spellID and self.activeAuras[unit] then
        self.activeAuras[unit][spellID] = nil
    else
        self.activeAuras[unit] = {}
    end
    self:LayoutIcons(unit)
end

function Nameplates:LayoutIcons(unit)
    if not unit then
        return
    end

    local nameplate = self.activeNameplates[unit]
    local activeAuras = self.activeAuras[unit]

    if not nameplate or not activeAuras then
        return
    end

    local auraFrame = nameplate.gladdyAuraFrame

    if not auraFrame then
        nameplate.gladdyAuraFrame = self:CreateAuraFrame(unit, nameplate)
    end

    self:CacheIcons(auraFrame)

    local newIcon
    for spellID, auraData in pairs(activeAuras) do
        -- create icon with data
        newIcon = self:CreateIcon()
        newIcon:SetParent(nameplate.gladdyAuraFrame)
        newIcon:SetAlpha(1)

        newIcon.unit = unit
        newIcon.spellID = spellID
        newIcon.track = auraData.track
        newIcon.priority = auraData.priority
        newIcon.startTime = auraData.startTime
        newIcon.endTime = auraData.endTime
        newIcon.timeLeft = auraData.duration > 0 and (auraData.endTime - GetTime()) or 999
        newIcon.noDuration = auraData.noDuration
        newIcon.active = auraData.active

        newIcon.texture:SetTexture(auraData.texture)
        newIcon.border:Show()

        newIcon:Show()
        nameplate.gladdyAuraFrame:Show()

        tinsert(nameplate.gladdyAuraFrame.icons, newIcon)

        if auraData.track == AURA_TYPE_DEBUFF then
            newIcon.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.nameplateDebuffBorderColor))
        elseif auraData.track == AURA_TYPE_BUFF then
            newIcon.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.nameplateBuffBorderColor))
        end

        if not newIcon.noDuration then
            newIcon.cooldown:SetCooldown(newIcon.startTime, auraData.duration)
        else
            newIcon.cooldown:Clear()
        end
    end
    
    -- Sort icons
    self:SortIcons(auraFrame.icons, Gladdy.db.nameplateSortOrder)
    -- Limit to max icons
    if #auraFrame.icons > Gladdy.db.nameplateMaxIcons then
        for i = #auraFrame.icons, Gladdy.db.nameplateMaxIcons + 1, -1 do
            self:CacheIcon(auraFrame.icons[i], auraFrame, i)
        end
    end
    
    -- Position icons
    self:PositionIcons(auraFrame)
    
    if #auraFrame.icons > 0 then
        auraFrame:Show()
    else
        auraFrame:Hide()
    end
end

function Nameplates:PositionIcons(auraFrame)
    local padding = Gladdy.db.nameplateIconPadding
    local center = Gladdy.db.nameplateCenterIcons

    local xOffset = 0
    local yOffset = 0
    local size = Gladdy.db.nameplateSize
    local width = size * Gladdy.db.nameplateWidthFactor

    if center and #auraFrame.icons > 1 then
        xOffset = ((#auraFrame.icons - 1) * width + (#auraFrame.icons - 1) * padding) / 2
    end

    for i, icon in ipairs(auraFrame.icons) do
        self:UpdateIcon(icon)
        icon:ClearAllPoints()
        icon:SetAlpha(1)
        if i == 1 then
            if center then
                icon:SetPoint("BOTTOM", auraFrame, "TOP", Gladdy.db.nameplateXOffset - xOffset, Gladdy.db.nameplateYOffset)
            else
                icon:SetPoint("BOTTOMLEFT", auraFrame, "TOPLEFT", Gladdy.db.nameplateXOffset - xOffset, Gladdy.db.nameplateYOffset)
            end
        else
            icon:SetPoint("LEFT", auraFrame.icons[i-1], "RIGHT", padding, 0)
        end
        icon:Show()
    end
end

-------------------------------------------
--- Test/Config Mode
-------------------------------------------

function Nameplates:TestOnce()
    --print("Nameplates:TestOnce")
    if not self.testFrame then

        self.testFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
        self.testFrame:SetWidth(200)
        self.testFrame:SetHeight(30)
        self.testFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 220)
        self.testFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        self.testFrame:SetBackdropColor(0.9, 0.1, 0, 0.8)
        self.testFrame:SetBackdropBorderColor(1, 1, 1, 1)
        
        -- Create fake nameplate text
        self.testFrame.nameText = self.testFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.testFrame.nameText:SetPoint("CENTER", self.testFrame, "CENTER", 0, 0)
        self.testFrame.nameText:SetText("TEST NAMEPLATE")
        self.testFrame.nameText:SetTextColor(1, 1, 1, 1)
        
        -- Create aura frame (positioned at top of test frame for icon anchoring)
        self.testFrame.gladdyAuraFrame = CreateFrame("Frame", nil, self.testFrame)
        self.testFrame.gladdyAuraFrame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
        self.testFrame.gladdyAuraFrame:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
        self.testFrame.gladdyAuraFrame:SetPoint("BOTTOMLEFT", self.testFrame, "TOPLEFT", 0, 0)
        self.testFrame.gladdyAuraFrame:SetPoint("BOTTOMRIGHT", self.testFrame, "TOPRIGHT", 0, 0)
        self.testFrame.gladdyAuraFrame:SetHeight(1) -- Minimal height, just for anchoring
        self.testFrame.gladdyAuraFrame.icons = {}
        self.testFrame.gladdyAuraFrame.unitID = "player"
    end
    
    if Gladdy.frame.testing and Gladdy.db.nameplateEnabled then
        -- Register test frame as active nameplate so AURA_GAIN can find it
        self.activeNameplates["player"] = self.testFrame
        -- Update aura frame settings
        if self.testFrame.gladdyAuraFrame then
            self.testFrame.gladdyAuraFrame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
            self.testFrame.gladdyAuraFrame:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
            self.testFrame.gladdyAuraFrame:ClearAllPoints()
            self.testFrame.gladdyAuraFrame:SetPoint("BOTTOMLEFT", self.testFrame, "TOPLEFT", 0, 0)
            self.testFrame.gladdyAuraFrame:SetPoint("BOTTOMRIGHT", self.testFrame, "TOPRIGHT", 0, 0)
            self.testFrame.gladdyAuraFrame:SetHeight(1)
        end
        self.testFrame:Show()
        self.activeAuras["player"] = {}
        -- Add some test auras
        self:TestAuras()
    else
        -- Remove test frame from active nameplates
        self.activeNameplates["player"] = nil
        self.testFrame:Hide()
    end
end

function Nameplates:TestAuras()
    if not self.testFrame or not self.testFrame.gladdyAuraFrame then
        return
    end
    
    -- Clear existing test icons
    self:CacheIcons(self.testFrame.gladdyAuraFrame)
    
    -- Add test auras from enabled list
    local testAuras = 0
    if Gladdy.enabledAuras then -- TODO Gladdy.db.auraListInterrupts
        local random, spellID
        local auras = { [AURA_TYPE_DEBUFF] = {},  [AURA_TYPE_BUFF] = {} }

        for spellId, data in pairs(Gladdy:GetImportantAuras()) do
            tinsert(auras[data.track], spellId)
        end

        for auraType, spells in pairs(auras) do
            local max = math.ceil(Gladdy.db.nameplateMaxIcons / 2.0)
            for i = 1, max do
                if #spells > 0 then
                    random = rand(1, #spells)
                    spellID = tonumber(tremove(spells, random))

                    local data = Gladdy.enabledAuras[auraType][spellID]
                    if data then
                        --print("spellid", auraType, random, data.auraType, data.spellID, data.duration)
                        local texture = data.texture
                        if not texture then
                            texture = select(3, GetSpellInfo(spellID))
                        end
                        local duration = math.random(6, 17)
                        local expirationTime = GetTime() + duration
                        self:AURA_GAIN("player", auraType, spellID, GetSpellInfo(spellID), data.texture, duration, expirationTime, 1, nil, i, "player")
                        testAuras = testAuras + 1
                    else -- TODO ????
                        i = i - 1
                    end
                end
            end
        end
    end
    
    -- Fallback: if no enabled auras, use some default test auras
    if testAuras == 0 then
        local defaultSpells = {
            {spellID = 22812, auraType = AURA_TYPE_BUFF, priority = 40, duration = 12}, -- Barkskin
            {spellID = 45438, auraType = AURA_TYPE_BUFF, priority = 40, duration = 10}, -- Ice Block
            {spellID = 31224, auraType = AURA_TYPE_BUFF, priority = 50, duration = 5}, -- Cloak of Shadows
        }
        for i, data in ipairs(defaultSpells) do
            local texture = select(3, GetSpellInfo(data.spellID))
            if texture then
                local expirationTime = GetTime() + data.duration
                self:AURA_GAIN("player", data.auraType, data.spellID, GetSpellInfo(data.spellID), texture, data.duration, expirationTime, 1, nil, i, "player")
            end
        end
    end
end

function Nameplates:Reset()
    -- Remove test frame from active nameplates
    self.activeNameplates["player"] = nil
    
    if self.testFrame then
        self.testFrame:Hide()
        if self.testFrame.gladdyAuraFrame then
            for i = #self.testFrame.gladdyAuraFrame.icons, 1, -1 do
                local icon = self.testFrame.gladdyAuraFrame.icons[i]
                --icon:SetScript("OnUpdate", nil)
                icon:Hide()
                icon:ClearAllPoints()
                icon:SetParent(nil)
                table.remove(self.testFrame.gladdyAuraFrame.icons, i)
                tinsert(self.iconCache, icon)
            end
        end
    end
end

function Nameplates:UpdateFrameOnce()
    if Gladdy.frame and Gladdy.frame.testing then
        self:TestOnce()
    end
    
    -- Update all active nameplates
    for unitID, nameplate in pairs(self.activeNameplates) do
        if nameplate.gladdyAuraFrame then
            self:LayoutIcons(unitID)
            for _, icon in ipairs(nameplate.gladdyAuraFrame.icons) do
                self:UpdateIcon(icon)
            end
        end
    end
    
    -- Update test frame if it exists
    if self.testFrame and self.testFrame.gladdyAuraFrame then
        self:LayoutIcons(self.testFrame.gladdyAuraFrame)
        for _, icon in ipairs(self.testFrame.gladdyAuraFrame.icons) do
            self:UpdateIcon(icon)
        end
    end
end

-------------------------------------------
--- Options
-------------------------------------------

function Nameplates:GetOptions()
    return {
        header = {
            type = "header",
            name = L["Nameplates"],
            order = 2,
        },
        nameplateEnabled = Gladdy:option({
            type = "toggle",
            name = L["Enabled"],
            desc = L["Show important auras on nameplates"],
            order = 3,
        }, function()
            Nameplates:LoadModule()
            Gladdy:UpdateFrame()
        end),
        group = {
            type = "group",
            childGroups = "tree",
            name = L["Frame"],
            order = 4,
            disabled = function() return not Gladdy.db.nameplateEnabled end,
            args = {
                icon = {
                    type = "group",
                    name = L["Icon"],
                    order = 1,
                    args = {
                        headerIcon = {
                            type = "header",
                            name = L["Icon"],
                            order = 1,
                        },
                        nameplateIconZoomed = Gladdy:option({
                            type = "toggle",
                            name = L["Zoomed Icon"],
                            desc = L["Zoomes the icon to remove borders"],
                            order = 2,
                            width = "full",
                        }),
                        nameplateSize = Gladdy:option({
                            type = "range",
                            name = L["Icon size"],
                            desc = L["Size of each aura icon"],
                            order = 3,
                            min = 10,
                            max = 100,
                            step = 1,
                            width = "full",
                        }),
                        nameplateWidthFactor = Gladdy:option({
                            type = "range",
                            name = L["Icon Width Factor"],
                            desc = L["Stretches the icon"],
                            order = 4,
                            min = 0.5,
                            max = 2,
                            step = 0.05,
                            width = "full",
                        }),
                        nameplateMaxIcons = Gladdy:option({
                            type = "range",
                            name = L["Max Icons"],
                            desc = L["Maximum number of aura icons to show"],
                            order = 5,
                            min = 1,
                            max = 10,
                            step = 1,
                            width = "full",
                        }),
                        nameplateIconPadding = Gladdy:option({
                            type = "range",
                            name = L["Icon Padding"],
                            desc = L["Space between icons"],
                            order = 6,
                            min = 0,
                            max = 20,
                            step = 1,
                            width = "full",
                        }),
                    },
                },
                position = {
                    type = "group",
                    name = L["Position"],
                    order = 2,
                    args = {
                        headerPosition = {
                            type = "header",
                            name = L["Position"],
                            order = 1,
                        },
                        nameplateXOffset = Gladdy:option({
                            type = "range",
                            name = L["Horizontal offset"],
                            order = 2,
                            min = -200,
                            max = 200,
                            step = 1,
                            width = "full",
                        }),
                        nameplateYOffset = Gladdy:option({
                            type = "range",
                            name = L["Vertical offset"],
                            order = 3,
                            min = -200,
                            max = 200,
                            step = 1,
                            width = "full",
                        }),
                        nameplateCenterIcons = Gladdy:option({
                            type = "toggle",
                            name = L["Center Icons"],
                            order = 4,
                            width = "full",
                        }),
                    },
                },
                sort = {
                    type = "group",
                    name = L["Sort Order"],
                    order = 3,
                    args = {
                        headerSort = {
                            type = "header",
                            name = L["Sort Order"],
                            order = 1,
                        },
                        nameplateSortOrder = Gladdy:option({
                            type = "select",
                            name = L["Sort Order"],
                            desc = L["How to sort aura icons"],
                            order = 2,
                            values = {
                                ["time"] = L["Time"],
                                ["timeleft"] = L["Time Left"],
                                ["priority"] = L["Priority"],
                            },
                            width = "full",
                        }),
                    },
                },
                cooldown = {
                    type = "group",
                    name = L["Cooldown"],
                    order = 4,
                    args = {
                        headerCooldown = {
                            type = "header",
                            name = L["Cooldown"],
                            order = 1,
                        },
                        nameplateDisableCircle = Gladdy:option({
                            type = "toggle",
                            name = L["No Cooldown Circle"],
                            order = 2,
                            width = "full",
                        }),
                        nameplateCooldownAlpha = Gladdy:option({
                            type = "range",
                            name = L["Cooldown circle alpha"],
                            order = 3,
                            min = 0,
                            max = 1,
                            step = 0.1,
                            width = "full",
                        }),
                    },
                },
                font = {
                    type = "group",
                    name = L["Font"],
                    order = 5,
                    disabled = function()
                        return Gladdy.db.useOmnicc
                    end,
                    args = {
                        headerFont = {
                            type = "header",
                            name = L["Font"],
                            order = 1,
                        },
                        nameplateFont = Gladdy:option({
                            type = "select",
                            name = L["Font"],
                            desc = L["Font of the cooldown"],
                            order = 2,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                        }),
                        nameplateFontSizeScale = Gladdy:option({
                            type = "range",
                            name = L["Font scale"],
                            desc = L["Scale of the text"],
                            order = 3,
                            min = 0.1,
                            max = 2,
                            step = 0.1,
                            width = "full",
                        }),
                        nameplateFontColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Font color"],
                            desc = L["Color of the text"],
                            order = 4,
                            hasAlpha = true,
                        }),
                    },
                },
                border = {
                    type = "group",
                    name = L["Border"],
                    order = 6,
                    args = {
                        headerBorder = {
                            type = "header",
                            name = L["Border"],
                            order = 1,
                        },
                        nameplateBorderStyle = Gladdy:option({
                            type = "select",
                            name = L["Border style"],
                            order = 2,
                            values = Gladdy:GetIconStyles(),
                        }),
                        nameplateBuffBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Buff color"],
                            desc = L["Color of the border"],
                            order = 3,
                            hasAlpha = true,
                            width = "0.8",
                        }),
                        nameplateDebuffBorderColor = Gladdy:colorOption({
                            type = "color",
                            name = L["Debuff color"],
                            desc = L["Color of the border"],
                            order = 4,
                            hasAlpha = true,
                            width = "0.8",
                        }),
                    },
                },
                frameStrata = {
                    type = "group",
                    name = L["Frame Strata and Level"],
                    order = 7,
                    args = {
                        headerFrameStrata = {
                            type = "header",
                            name = L["Frame Strata and Level"],
                            order = 1,
                        },
                        nameplateFrameStrata = Gladdy:option({
                            type = "select",
                            name = L["Frame Strata"],
                            order = 2,
                            values = Gladdy.frameStrata,
                            sorting = Gladdy.frameStrataSorting,
                            width = "full",
                        }),
                        nameplateFrameLevel = Gladdy:option({
                            type = "range",
                            name = L["Frame Level"],
                            order = 3,
                            min = 0,
                            max = 500,
                            step = 1,
                            width = "full",
                        }),
                    },
                },
            },
        },
        auraList = {
            type = "group",
            childGroups = "tree",
            name = L["Aura List"],
            order = 5,
            disabled = function() return not Gladdy.db.nameplateEnabled end,
            args = {
                headerAuras = {
                    type = "header",
                    name = L["Configure which auras to show on nameplates"],
                    order = 1,
                },
                note = {
                    type = "description",
                    name = L["Note: Uses the same aura list as the Auras module. Configure auras in the Auras module settings."],
                    order = 2,
                    fontSize = "medium",
                },
            },
        },
    }
end

