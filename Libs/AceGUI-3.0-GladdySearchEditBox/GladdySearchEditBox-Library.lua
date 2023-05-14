local MAJOR, MINOR = "AceGUI-3.0-GladdySearchEditBox", 1
local lib, oldminor = LibStub:NewLibrary(MAJOR,MINOR)
if not lib then return end

local AceGUI = LibStub("AceGUI-3.0")

local function Constructor(options)
	local self = AceGUI:Create("GladdySearchEditBox")
	self.options = type(options) == "table" and options or { GetValues = options }
	return self
end

function lib:Register (typename, options)
	AceGUI:RegisterWidgetType ("GladdySearchEditBox"..typename, function() return Constructor(options) end, MINOR)
end



--- Example on how to use the Edit GladdySearchEditBox

--- init a Predictor
--[[
local Predictor = {}
function Predictor:Initialize()
end
function Predictor:GetValues(input)
    local values = {}
    local spellName, icon = GetSpellInfo(input)
    if (spellName) then
    	values[input] = {
			text = spellName .. " - (" .. input .. ")",
			icon = icon
		}
	end
    return values
end
function Predictor:GetValue(text, key)
    return key
end
function Predictor:GetHyperlink(key)
    return "spell:" .. key .. ":0"
end
]]

--- Register as follows
--[[
LibStub("AceGUI-3.0-GladdySearchEditBox"):Register("Auras", Predictor)
]]

--- usage in config
--[[
editBox = {
	order = 1,
	width = "2",
	name = L["Add Aura"],
	type = "input",
	dialogControl = "GladdySearchEditBoxAuras",
	get = function()

	end,
	set = function(_, value)

	end,
},
]]