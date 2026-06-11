-- Core/Scale.lua
-- Viewport-aware scale system.
-- Desktop always stays at 1.0 to match original v2.0 pixel layout.
-- Mobile scales down proportionally so controls remain usable.
--
-- Usage:
--   local ScaleMod = require(path.Core.Scale)
--   ScaleMod.init(globalCleanup)   -- call once at startup
--   ScaleMod.Scale.factor          -- current multiplier
--   ScaleMod.Scale.px(32)          -- scaled pixel value

local UIS = game:GetService("UserInputService")

local Metrics = {
    ControlHeight = 34,
    SmallControl  = 28,
    LargeControl  = 44,
    FontBase      = 14,
    FontTitle     = 16,
    FontSmall     = 12,
    Padding       = 8,
    PaddingLarge  = 10,
    Radius        = 8,
    RadiusLarge   = 12,
    Spacing       = 6,
    StrokeThick   = 1,
    SliderHeight  = 18,
    WindowMinW    = 420,
    WindowMinH    = 320,
}

local Scale = { factor = 1.0 }

local BASE_W, BASE_H     = 1280, 720
local MIN_SCALE          = 0.55

local function isMobileNow()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local function computeFactor()
    local Camera = workspace.CurrentCamera
    local vp     = (Camera and Camera.ViewportSize) or Vector2.new(BASE_W, BASE_H)
    if isMobileNow() then
        local ref = math.min(vp.X / BASE_W, vp.Y / BASE_H)
        Scale.factor = math.clamp(ref * 1.1, MIN_SCALE, 1.0)
    else
        Scale.factor = 1.0
    end
end

function Scale.px(value)
    return math.round(value * Scale.factor)
end

function Scale.m(key)
    local base = Metrics[key]
    if not base then return 0 end
    return Scale.px(base)
end

-- Call once at startup, passing a Cleanup instance to track the connection.
local function init(globalCleanup)
    computeFactor()
    local Camera = workspace.CurrentCamera
    if Camera and globalCleanup then
        globalCleanup:Add(
            Camera:GetPropertyChangedSignal("ViewportSize"):Connect(computeFactor)
        )
    end
end

return { Scale = Scale, Metrics = Metrics, init = init }
