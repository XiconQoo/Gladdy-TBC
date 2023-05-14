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
