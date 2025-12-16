local pairs, ipairs, select, tinsert, tbl_sort, tostring, tonumber = pairs, ipairs, select, table.insert, table.sort, tostring, tonumber
local GetSpellInfo = GetSpellInfo
local CreateFrame, GetTime = CreateFrame, GetTime
local UnitGUID, UnitAura, UnitExists = UnitGUID, UnitAura, UnitExists
local AURA_TYPE_DEBUFF, AURA_TYPE_BUFF = AURA_TYPE_DEBUFF, AURA_TYPE_BUFF
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
    nameplateFrameStrata = "TOOLTIP",
    nameplateFrameLevel = 10,
})

function Nameplates:Initialize()
    self.activeNameplates = {}
    self.iconCache = {}
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

function Nameplates:CreateIcon()
    local icon
    if #self.iconCache > 0 then
        icon = table.remove(self.iconCache, #self.iconCache)
    else
        icon = CreateFrame("Frame")
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
        
        icon.border = icon.cooldownFrame:CreateTexture(nil, "OVERLAY")
        icon.border:SetAllPoints(icon)
        
        icon.text = icon.cooldownFrame:CreateFontString(nil, "OVERLAY")
        icon.text:SetJustifyH("CENTER")
        icon.text:SetPoint("CENTER")
        
        self:UpdateIcon(icon)
    end
    return icon
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
    if not Gladdy.db.nameplateEnabled or not UnitExists(unitID) then
        return
    end
    
    local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
    if not nameplate then
        return
    end
    
    if not nameplate.gladdyAuraFrame then
        nameplate.gladdyAuraFrame = CreateFrame("Frame", nil, nameplate)
        nameplate.gladdyAuraFrame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
        nameplate.gladdyAuraFrame:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
        nameplate.gladdyAuraFrame:SetPoint("BOTTOMLEFT", nameplate, "TOPLEFT", 0, 0)
        nameplate.gladdyAuraFrame:SetPoint("BOTTOMRIGHT", nameplate, "TOPRIGHT", 0, 0)
        nameplate.gladdyAuraFrame:SetHeight(1)
        nameplate.gladdyAuraFrame.icons = {}
        nameplate.gladdyAuraFrame.unitID = unitID
    end
    
    self.activeNameplates[unitID] = nameplate
    -- Scan for existing auras when nameplate is added
    self:UpdateNameplateAuras(unitID)
end

function Nameplates:NAME_PLATE_UNIT_REMOVED(unitID)
    local nameplate = self.activeNameplates[unitID]
    if nameplate and nameplate.gladdyAuraFrame then
        -- Return icons to cache
        for i = #nameplate.gladdyAuraFrame.icons, 1, -1 do
            local icon = nameplate.gladdyAuraFrame.icons[i]
            icon:Hide()
            icon:ClearAllPoints()
            icon:SetParent(nil)
            icon.active = false
            icon.spellID = nil
            icon.timeLeft = nil
            icon.priority = nil
            icon.startTime = nil
            icon.endTime = nil
            icon.track = nil
            icon.cooldown:Clear()
            icon.text:SetText("")
            icon.texture:SetTexture("")
            tinsert(self.iconCache, icon)
        end
        nameplate.gladdyAuraFrame.icons = {}
        nameplate.gladdyAuraFrame:Hide()
    end
    self.activeNameplates[unitID] = nil
end

-------------------------------------------
--- Aura Handling
-------------------------------------------

function Nameplates:AURA_GAIN(unit, auraType, spellID, spellName, icon, duration, expirationTime, count, dispelType, n, unitCaster)
    if not Gladdy.db.nameplateEnabled then
        return
    end
    
    -- In test mode, check test frame first
    local nameplate = nil
    local foundUnitID = nil
    
    if Gladdy.frame and Gladdy.frame.testing and self.testFrame and self.testFrame.gladdyAuraFrame then
        if UnitIsUnit(self.testFrame.gladdyAuraFrame.unitID, unit) then
            nameplate = self.testFrame
            foundUnitID = self.testFrame.gladdyAuraFrame.unitID
        end
    end
    
    -- Find nameplate for this unit
    if not nameplate then
        for unitID, np in pairs(self.activeNameplates) do
            if UnitIsUnit(unitID, unit) then
                nameplate = np
                foundUnitID = unitID
                break
            end
        end
    end
    
    -- If no nameplate found, try to get it directly
    if not nameplate then
        local nameplateForUnit = C_NamePlate.GetNamePlateForUnit(unit)
        if nameplateForUnit then
            nameplate = nameplateForUnit
            foundUnitID = unit
            if not nameplate.gladdyAuraFrame then
                nameplate.gladdyAuraFrame = CreateFrame("Frame", nil, nameplate)
                nameplate.gladdyAuraFrame:SetFrameStrata(Gladdy.db.nameplateFrameStrata)
                nameplate.gladdyAuraFrame:SetFrameLevel(Gladdy.db.nameplateFrameLevel)
                nameplate.gladdyAuraFrame:ClearAllPoints()
                nameplate.gladdyAuraFrame:SetPoint("BOTTOMLEFT", nameplate, "TOPLEFT", 0, 0)
                nameplate.gladdyAuraFrame:SetPoint("BOTTOMRIGHT", nameplate, "TOPRIGHT", 0, 0)
                nameplate.gladdyAuraFrame:SetHeight(1)
                nameplate.gladdyAuraFrame.icons = {}
                nameplate.gladdyAuraFrame.unitID = foundUnitID
            end
            self.activeNameplates[foundUnitID] = nameplate
        end
    end
    
    if not nameplate or not nameplate.gladdyAuraFrame then
        return
    end

    
    -- Use the same aura system as Auras module
    local auraData = Gladdy.enabledAuras and Gladdy.enabledAuras[auraType] and Gladdy.enabledAuras[auraType][spellID]
    if not auraData then
        return
    end

    
    -- Check if icon already exists
    local existingIcon = nil
    for _, iconFrame in ipairs(nameplate.gladdyAuraFrame.icons) do
        if iconFrame.spellID == spellID and iconFrame.track == auraType then
            existingIcon = iconFrame
            break
        end
    end
    
    if not existingIcon then
        -- Create new icon
        if #nameplate.gladdyAuraFrame.icons >= Gladdy.db.nameplateMaxIcons then
            return -- Max icons reached
        end
        existingIcon = self:CreateIcon()
        existingIcon:SetParent(nameplate.gladdyAuraFrame)
        existingIcon:SetAlpha(1)
        existingIcon:Show()
        nameplate.gladdyAuraFrame:Show()
        tinsert(nameplate.gladdyAuraFrame.icons, existingIcon)
    end
    
    -- Update icon
    existingIcon.spellID = spellID
    existingIcon.track = auraType
    existingIcon.priority = auraData.priority
    existingIcon.startTime = expirationTime - duration
    existingIcon.endTime = expirationTime
    existingIcon.timeLeft = duration > 0 and (expirationTime - GetTime()) or 999
    existingIcon.noDuration = duration == 0
    existingIcon.active = true
    
    existingIcon.texture:SetTexture(auraData.texture or icon)
    existingIcon.border:Show()
    
    if auraType == AURA_TYPE_DEBUFF then
        existingIcon.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.nameplateDebuffBorderColor))
    elseif auraType == AURA_TYPE_BUFF then
        existingIcon.border:SetVertexColor(Gladdy:SetColor(Gladdy.db.nameplateBuffBorderColor))
    end
    
    if not existingIcon.noDuration then
        existingIcon.cooldown:SetCooldown(existingIcon.startTime, duration)
    else
        existingIcon.cooldown:Clear()
    end
    
    existingIcon:SetScript("OnUpdate", function(self, elapsed)
        if self.active then
            if self.timeLeft <= 0 then
                Nameplates:AURA_FADE(nameplate.gladdyAuraFrame.unitID, self.track, self.spellID)
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
    print("AURA_GAIN")
    self:LayoutIcons(nameplate.gladdyAuraFrame)
end

function Nameplates:AURA_FADE(unit, auraType, spellID)
    if not Gladdy.db.nameplateEnabled then
        return
    end
    
    -- Find nameplate for this unit
    local nameplate = nil
    for unitID, np in pairs(self.activeNameplates) do
        if UnitIsUnit(unitID, unit) then
            nameplate = np
            break
        end
    end
    
    -- Also check test frame
    if not nameplate and self.testFrame and self.testFrame.gladdyAuraFrame and UnitIsUnit(self.testFrame.gladdyAuraFrame.unitID, unit) then
        nameplate = self.testFrame
    end
    
    if not nameplate or not nameplate.gladdyAuraFrame then
        return
    end
    
    -- Find and remove icon
    for i = #nameplate.gladdyAuraFrame.icons, 1, -1 do
        local icon = nameplate.gladdyAuraFrame.icons[i]
        if icon.spellID == spellID and icon.track == auraType then
            icon:SetScript("OnUpdate", nil)
            icon.cooldown:Clear()
            icon.active = false
            icon.spellID = nil
            icon.timeLeft = nil
            icon.priority = nil
            icon.startTime = nil
            icon.endTime = nil
            icon.track = nil
            icon.texture:SetTexture("")
            icon.text:SetText("")
            icon:Hide()
            icon:ClearAllPoints()
            icon:SetParent(nil)
            table.remove(nameplate.gladdyAuraFrame.icons, i)
            tinsert(self.iconCache, icon)
            break
        end
    end
    
    self:LayoutIcons(nameplate.gladdyAuraFrame)
end

function Nameplates:UpdateNameplateAuras(unitID)
    if not Gladdy.enabledAuras then
        return
    end
    
    local nameplate = self.activeNameplates[unitID]
    if not nameplate or not nameplate.gladdyAuraFrame then
        return
    end
    
    -- Scan auras on the unit
    for i = 1, 2 do
        local filter = (i == 1 and "HELPFUL" or "HARMFUL")
        local auraType = i == 1 and AURA_TYPE_BUFF or AURA_TYPE_DEBUFF
        
        for n = 1, 40 do
            local spellName, texture, count, dispelType, duration, expirationTime, unitCaster, _, shouldConsolidate, spellID = UnitAura(unitID, n, filter)
            if not spellID then
                break
            end
            
            local auraData = Gladdy.enabledAuras[auraType] and Gladdy.enabledAuras[auraType][spellID]
            if auraData then
                self:AURA_GAIN(unitID, auraType, spellID, spellName, texture, duration, expirationTime, count, dispelType, n, unitCaster)
            end
        end
    end
end

function Nameplates:LayoutIcons(auraFrame)
    if not auraFrame or not auraFrame.icons then
        return
    end
    
    -- Sort icons
    self:SortIcons(auraFrame.icons, Gladdy.db.nameplateSortOrder)
    
    -- Limit to max icons
    while #auraFrame.icons > Gladdy.db.nameplateMaxIcons do
        local icon = table.remove(auraFrame.icons, #auraFrame.icons)
        icon:SetScript("OnUpdate", nil)
        icon:Hide()
        icon:ClearAllPoints()
        icon:SetParent(nil)
        tinsert(self.iconCache, icon)
    end
    
    -- Position icons
    local padding = Gladdy.db.nameplateIconPadding
    for i, icon in ipairs(auraFrame.icons) do
        self:UpdateIcon(icon)
        icon:ClearAllPoints()
        icon:SetAlpha(1)
        if i == 1 then
            icon:SetPoint("BOTTOMLEFT", auraFrame, "TOPLEFT", Gladdy.db.nameplateXOffset, Gladdy.db.nameplateYOffset)
        else
            icon:SetPoint("LEFT", auraFrame.icons[i-1], "RIGHT", padding, 0)
        end
        icon:Show()
    end
    
    if #auraFrame.icons > 0 then
        auraFrame:Show()
    else
        auraFrame:Hide()
    end
end

-------------------------------------------
--- Test/Config Mode
-------------------------------------------

function Nameplates:TestOnce()
    if not self.testFrame then
        self.testFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
        self.testFrame:SetWidth(200)
        self.testFrame:SetHeight(50)
        self.testFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
        self.testFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        self.testFrame:SetBackdropColor(0, 0, 0, 0.8)
        self.testFrame:SetBackdropBorderColor(1, 1, 1, 1)
        
        -- Create fake nameplate text
        self.testFrame.nameText = self.testFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.testFrame.nameText:SetPoint("CENTER", self.testFrame, "CENTER", 0, 10)
        self.testFrame.nameText:SetText("Test Nameplate")
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
    for i = #self.testFrame.gladdyAuraFrame.icons, 1, -1 do
        local icon = self.testFrame.gladdyAuraFrame.icons[i]
        icon:SetScript("OnUpdate", nil)
        icon:Hide()
        icon:ClearAllPoints()
        icon:SetParent(nil)
        table.remove(self.testFrame.gladdyAuraFrame.icons, i)
        tinsert(self.iconCache, icon)
    end
    
    -- Add test auras from enabled list
    local testAuras = {}
    if Gladdy.enabledAuras then
        for auraType, spells in pairs(Gladdy.enabledAuras) do
            for spellID, data in pairs(spells) do
                if #testAuras < Gladdy.db.nameplateMaxIcons then
                    local texture = data.texture
                    if not texture or texture == "" then
                        texture = select(3, GetSpellInfo(spellID))
                    end
                    tinsert(testAuras, {
                        spellID = spellID,
                        auraType = auraType,
                        priority = data.priority or 40,
                        texture = texture,
                        duration = data.duration or 10
                    })
                end
            end
        end
    end
    
    -- Fallback: if no enabled auras, use some default test auras
    if #testAuras == 0 then
        local defaultSpells = {
            {spellID = 22812, auraType = AURA_TYPE_BUFF, priority = 40, duration = 12}, -- Barkskin
            {spellID = 45438, auraType = AURA_TYPE_BUFF, priority = 40, duration = 10}, -- Ice Block
            {spellID = 31224, auraType = AURA_TYPE_BUFF, priority = 50, duration = 5}, -- Cloak of Shadows
        }
        for i, spell in ipairs(defaultSpells) do
            if #testAuras < Gladdy.db.nameplateMaxIcons then
                local texture = select(3, GetSpellInfo(spell.spellID))
                if texture then
                    tinsert(testAuras, {
                        spellID = spell.spellID,
                        auraType = spell.auraType,
                        priority = spell.priority,
                        texture = texture,
                        duration = spell.duration
                    })
                end
            end
        end
    end
    
    -- Sort and add test auras
    tbl_sort(testAuras, function(a, b)
        if Gladdy.db.nameplateSortOrder == "priority" then
            if a.priority == b.priority then
                return a.duration < b.duration
            end
            return a.priority > b.priority
        elseif Gladdy.db.nameplateSortOrder == "timeleft" then
            return a.duration < b.duration
        else
            return a.spellID < b.spellID
        end
    end)
    
    for i, testAura in ipairs(testAuras) do
        if i <= Gladdy.db.nameplateMaxIcons then
            local expirationTime = GetTime() + testAura.duration
            self:AURA_GAIN("player", testAura.auraType, testAura.spellID, GetSpellInfo(testAura.spellID), testAura.texture, testAura.duration, expirationTime, 1, nil, i, "player")
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
                icon:SetScript("OnUpdate", nil)
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
            self:LayoutIcons(nameplate.gladdyAuraFrame)
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

