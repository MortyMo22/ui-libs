-- RoundedUI v2.3
-- Executor entry point. Load this file with loadstring(game:HttpGet(...))().
-- All child modules are loaded from GitHub raw URLs via HttpGet.

local BASE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/main/RoundedUI/"
local CACHE_BUST = "?v=20260611"

local moduleCache = {}

local function fetchSource(path)
    local url = BASE_URL .. path .. ".lua" .. CACHE_BUST
    local ok, source = pcall(function()
        return game:HttpGet(url)
    end)

    if not ok then
        error(("[RoundedUI] HttpGet failed for %s: %s"):format(url, tostring(source)), 3)
    end

    if type(source) ~= "string" or source == "" then
        error(("[RoundedUI] Empty response for %s"):format(url), 3)
    end

    if source:find("404: Not Found", 1, true) or source:find("<!DOCTYPE", 1, true) then
        error(("[RoundedUI] Bad response for %s. Check file path and GitHub branch."):format(url), 3)
    end

    return source, url
end

local function req(path)
    if moduleCache[path] ~= nil then
        return moduleCache[path]
    end

    local source, url = fetchSource(path)
    local fn, compileErr = loadstring(source)
    if not fn then
        error(("[RoundedUI] Compile error in %s: %s"):format(url, tostring(compileErr)), 2)
    end

    local ok, result = pcall(fn)
    if not ok then
        error(("[RoundedUI] Runtime error in %s: %s"):format(url, tostring(result)), 2)
    end

    moduleCache[path] = result
    return result
end

local CleanupModule  = req("Core/Cleanup")
local ThemeModule    = req("Core/Theme")
local AnimModule     = req("Core/Animation")
local ScaleModule    = req("Core/Scale")
local HelpersModule  = req("Core/Helpers")

local KeybindModule  = req("Systems/Keybind")
local ColorPickerMod = req("Systems/ColorPicker")
local NotifModule    = req("Systems/Notification")

local CardAPIMod     = req("Controls/CardAPI")
local SimpleMod      = req("Controls/SimpleControls")
local ToggleMod      = req("Controls/ToggleControls")
local SelectMod      = req("Controls/SelectControls")
local LayoutMod      = req("Controls/LayoutControls")

local SectionMod     = req("UI/Section")
local WindowMod      = req("UI/Window")

local globalCleanup = CleanupModule.new()

ScaleModule.init(globalCleanup)
KeybindModule.init(globalCleanup)

local Theme = ThemeModule.Theme
local FONT = ThemeModule.FONT
local FONT_B = ThemeModule.FONT_B

local create = HelpersModule.create
local addCorner = HelpersModule.addCorner
local addStroke = HelpersModule.addStroke
local addPadding = HelpersModule.addPadding
local withHover = HelpersModule.withHover
local withHoverAnim = HelpersModule.withHoverAnim
local isMobile = HelpersModule.isMobile

local Anim = AnimModule

ColorPickerMod._inject({
    Theme = Theme,
    FONT = FONT,
    FONT_B = FONT_B,
    create = create,
    addCorner = addCorner,
    addStroke = addStroke,
    addPadding = addPadding,
    withHover = withHover,
})

NotifModule._inject({
    Theme = Theme,
    FONT = FONT,
    FONT_B = FONT_B,
    create = create,
    addCorner = addCorner,
    addStroke = addStroke,
    Anim = Anim,
    isMobile = isMobile,
    globalCleanup = globalCleanup,
})

CardAPIMod._inject({
    Theme = Theme,
    FONT = FONT,
    FONT_B = FONT_B,
    create = create,
    addCorner = addCorner,
    withHoverAnim = withHoverAnim,
    Anim = Anim,
})

local UIS = game:GetService("UserInputService")

local sharedDeps = {
    Theme = Theme,
    FONT = FONT,
    FONT_B = FONT_B,
    Anim = Anim,
    Cleanup = CleanupModule,
    UIS = UIS,

    create = create,
    addCorner = addCorner,
    addStroke = addStroke,
    addPadding = addPadding,
    withHover = withHover,
    withHoverAnim = withHoverAnim,
    isMobile = isMobile,

    addKeybind = KeybindModule.add,
    removeKeybind = KeybindModule.remove,
    setCurrentRecorder = KeybindModule._setRecorder,

    openColorPickerInGui = function(rootGui, startColor, onApply)
        if not rootGui then
            error("[RoundedUI] ColorPicker needs a ScreenGui ancestor", 2)
        end
        ColorPickerMod.open(rootGui, startColor, onApply)
    end,

    CardAPI = CardAPIMod,
    SimpleControls = SimpleMod,
    ToggleControls = ToggleMod,
    SelectControls = SelectMod,
    LayoutControls = LayoutMod,

    SectionFactory = SectionMod.make,
    windowCleanup = nil,
}

local RoundedUI = {}

function RoundedUI.CreateWindow(nameLeft, nameRight)
    return WindowMod.CreateWindow(nameLeft, nameRight, sharedDeps)
end

function RoundedUI:Notify(cfg)
    NotifModule.Notify(cfg)
end

RoundedUI.Scale = ScaleModule.Scale
RoundedUI.Metrics = ScaleModule.Metrics
RoundedUI.Anim = Anim
RoundedUI.Theme = Theme

return RoundedUI
