--!strict
-- init.lua  (project root — this is the file you loadstring / require)
-- ─────────────────────────────────────────────────────────────────────────────
-- RoundedUI  v2.3  |  modular edition
-- Public API is identical to the original single-file version:
--
--   local UI  = loadstring(game:HttpGet("..."))()
--   local app = UI.CreateWindow("Title", "Subtitle")
--   local tab = app:AddSection("Main")
--   local L, R = tab:AddUnderSections("Left", "Right")
--   L:Toggle("Name", { Default=false, Callback=function(v) end })
--   ...
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. Resolve module paths ───────────────────────────────────────────────────
-- When loaded via loadstring the script has no parent, so we use relative
-- requires.  Adjust this block if you host files differently.

local function req(path)
    -- Works in both ModuleScript trees and raw loadstring environments.
    -- For raw loadstring: replace this with your own HttpGet loader.
    if script and script:FindFirstChild(path:gsub("/", ".")) then
        return require(script:FindFirstChild(path:gsub("/", ".")))
    end
    -- Fallback: load from the same GitHub URL base as the entry point.
    -- Replace BASE_URL with wherever your files are hosted.
    local BASE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/RoundedUI/"
    return loadstring(game:HttpGet(BASE_URL .. path .. ".lua"))()
end

-- ── 2. Load all modules ───────────────────────────────────────────────────────

local CleanupModule   = req("Core/Cleanup")
local ThemeModule     = req("Core/Theme")
local AnimModule      = req("Core/Animation")
local ScaleModule     = req("Core/Scale")
local HelpersModule   = req("Core/Helpers")

local KeybindModule   = req("Systems/Keybind")
local ColorPickerMod  = req("Systems/ColorPicker")
local NotifModule     = req("Systems/Notification")

local CardAPIMod      = req("Controls/CardAPI")
local SimpleMod       = req("Controls/SimpleControls")
local ToggleMod       = req("Controls/ToggleControls")
local SelectMod       = req("Controls/SelectControls")
local LayoutMod       = req("Controls/LayoutControls")

local SectionMod      = req("UI/Section")
local WindowMod       = req("UI/Window")

-- ── 3. Bootstrap shared singletons ───────────────────────────────────────────

-- Global cleanup registry — lives for the entire script session.
local globalCleanup = CleanupModule.new()

-- Scale system — monitors viewport, stays at 1.0 on desktop.
ScaleModule.init(globalCleanup)

-- Keybind system — wires the single InputBegan listener.
KeybindModule.init(globalCleanup)

-- Unpack theme
local Theme = ThemeModule.Theme
local FONT  = ThemeModule.FONT
local FONT_B= ThemeModule.FONT_B

-- Unpack helpers
local create        = HelpersModule.create
local addCorner     = HelpersModule.addCorner
local addStroke     = HelpersModule.addStroke
local addPadding    = HelpersModule.addPadding
local withHover     = HelpersModule.withHover
local withHoverAnim = HelpersModule.withHoverAnim
local isMobile      = HelpersModule.isMobile

-- Unpack animation
local Anim = AnimModule

-- ── 4. Inject shared state into modules that need it ─────────────────────────

-- ColorPicker needs helpers + theme (injected to avoid circular requires)
ColorPickerMod._inject({
    Theme      = Theme,
    FONT       = FONT,
    FONT_B     = FONT_B,
    create     = create,
    addCorner  = addCorner,
    addStroke  = addStroke,
    addPadding = addPadding,
    withHover  = withHover,
})

-- Notification needs helpers + theme + anim + globalCleanup
NotifModule._inject({
    Theme         = Theme,
    FONT          = FONT,
    FONT_B        = FONT_B,
    create        = create,
    addCorner     = addCorner,
    addStroke     = addStroke,
    Anim          = Anim,
    isMobile      = isMobile,
    globalCleanup = globalCleanup,
})

-- CardAPI needs helpers + theme + anim
CardAPIMod._inject({
    Theme         = Theme,
    FONT          = FONT,
    FONT_B        = FONT_B,
    create        = create,
    addCorner     = addCorner,
    withHoverAnim = withHoverAnim,
    Anim          = Anim,
})

-- ── 5. Build the shared deps table passed to every control/section/window ─────
-- This single table is the "dependency container" — all modules read from it.
-- windowCleanup is added per-window by Window.lua at creation time.

local UIS = game:GetService("UserInputService")

local sharedDeps = {
    -- Core
    Theme         = Theme,
    FONT          = FONT,
    FONT_B        = FONT_B,
    Anim          = Anim,
    Cleanup       = CleanupModule,   -- the class (for Cleanup.new())
    UIS           = UIS,

    -- Helpers
    create        = create,
    addCorner     = addCorner,
    addStroke     = addStroke,
    addPadding    = addPadding,
    withHover     = withHover,
    withHoverAnim = withHoverAnim,
    isMobile      = isMobile,

    -- Keybind
    addKeybind           = KeybindModule.add,
    removeKeybind        = KeybindModule.remove,
    setCurrentRecorder   = KeybindModule._setRecorder,

    -- ColorPicker (passed as a closure so controls don't need rootGui at dep-build time)
    openColorPicker = function(startColor, onApply)
        -- rootGui is retrieved lazily from the stack context inside each control.
        -- Controls that call this pass a rootGui reference themselves;
        -- the closure here is called from ToggleControls which passes the gui via
        -- deps.openColorPickerInGui(rootGui, startColor, onApply).
        -- See note in ToggleControls.ToggleColor.
    end,
    openColorPickerInGui = function(rootGui, startColor, onApply)
        ColorPickerMod.open(rootGui, startColor, onApply)
    end,

    -- Control modules
    CardAPI        = CardAPIMod,
    SimpleControls = SimpleMod,
    ToggleControls = ToggleMod,
    SelectControls = SelectMod,
    LayoutControls = LayoutMod,

    -- Section factory (UI/Section.make)
    SectionFactory = SectionMod.make,

    -- windowCleanup is set per-window by Window.lua
    windowCleanup = nil,
}

-- Patch openColorPicker so ToggleControls can call it without passing rootGui
-- explicitly from stack context.  The control passes rootGui via:
--   deps.openColorPicker = function(startColor, onApply)
--       local rootGui = <stack>:FindFirstAncestorOfClass("ScreenGui")
--       deps.openColorPickerInGui(rootGui, startColor, onApply)
--   end
-- We provide a default that ToggleControls overrides per-call if needed.
-- In practice ToggleColor and ToggleDualColor call openColorPickerInGui directly.
sharedDeps.openColorPicker = function(startColor, onApply)
    -- Fallback: caller must supply rootGui separately.
    error("openColorPicker called without rootGui — use openColorPickerInGui instead")
end

-- ── 6. Build the public RoundedUI table ───────────────────────────────────────

local RoundedUI = {}

-- CreateWindow — main entry point for consumers
function RoundedUI.CreateWindow(nameLeft, nameRight)
    return WindowMod.CreateWindow(nameLeft, nameRight, sharedDeps)
end

-- Notify — can be called without a window
function RoundedUI:Notify(cfg)
    NotifModule.Notify(cfg)
end

-- Advanced: expose internals for power users who want to extend the lib
RoundedUI.Scale   = ScaleModule.Scale
RoundedUI.Metrics = ScaleModule.Metrics
RoundedUI.Anim    = Anim
RoundedUI.Theme   = Theme

return RoundedUI
