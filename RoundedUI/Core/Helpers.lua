-- Core/Helpers.lua
-- Lightweight UI builder utilities used across all modules.
-- No state — pure functions only.

local UIS = game:GetService("UserInputService")

-- Require Theme and Animation from the same Core package.
-- When used inside init.lua these are passed in to avoid circular requires.
-- All functions accept them as arguments for full decoupling.

-- ─── Instance factory ────────────────────────────────────────────────────────

-- Create a Roblox instance, apply a property table, and optionally parent
-- a list of children to it.
local function create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    for _, child in ipairs(children or {}) do child.Parent = obj end
    return obj
end

-- ─── Decoration helpers ──────────────────────────────────────────────────────

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)  -- raw px, never scaled
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color        = color        or Color3.fromRGB(60, 60, 60)
    s.Thickness    = thickness    or 1
    s.Transparency = transparency or 0.4
    s.Parent = parent
    return s
end

local function addPadding(parent, pad)
    local p  = Instance.new("UIPadding")
    local px = UDim.new(0, pad)
    p.PaddingTop    = px
    p.PaddingBottom = px
    p.PaddingLeft   = px
    p.PaddingRight  = px
    p.Parent = parent
    return p
end

-- ─── Hover helpers ───────────────────────────────────────────────────────────

-- Non-animated hover — direct color assignment.
-- Used on tab buttons where tweens must not compete with selected state.
local function withHover(btn, base, hover)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = base  end)
end

-- Animated hover — tween on enter/leave.
-- Used on regular controls: buttons, dropdowns, pagination, etc.
local function withHoverAnim(btn, base, hover, Anim)
    btn.MouseEnter:Connect(function()
        Anim:Play(btn, Anim.Fast, { BackgroundColor3 = hover })
    end)
    btn.MouseLeave:Connect(function()
        Anim:Play(btn, Anim.Fast, { BackgroundColor3 = base })
    end)
end

-- ─── Platform detection ──────────────────────────────────────────────────────

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

-- ─── Exports ─────────────────────────────────────────────────────────────────

return {
    create        = create,
    addCorner     = addCorner,
    addStroke     = addStroke,
    addPadding    = addPadding,
    withHover     = withHover,
    withHoverAnim = withHoverAnim,
    isMobile      = isMobile,
}
