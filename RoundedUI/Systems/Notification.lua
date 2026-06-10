-- Systems/Notification.lua
-- Standalone toast notification system.
-- Lazy-creates its own ScreenGui on first use.
-- Supports queue, progress bar, typed notifications, and mobile width.
--
-- Usage:
--   local Notif = require(path.Systems.Notification)
--   Notif._inject(deps)           -- called once by init.lua
--   Notif.Notify("Hello")
--   Notif.Notify({ Title="Done", Content="Saved!", Type="Success", Duration=4 })
--
-- Types: "Success" | "Error" | "Warning" | "Info"

local RunService = game:GetService("RunService")

-- Injected dependencies (set via _inject before first use)
local _Theme, _FONT, _FONT_B
local _create, _addCorner, _addStroke
local _Anim, _isMobile, _globalCleanup

local MAX_NOTIFS = 5
local NOTIF_W    = 280
local NOTIF_H    = 70
local NOTIF_GAP  = 8
local EDGE_PAD   = 16

local activeNotifs = {}
local queue        = {}
local notifGui     = nil

local Notification = {}

function Notification._inject(deps)
    _Theme         = deps.Theme
    _FONT          = deps.FONT
    _FONT_B        = deps.FONT_B
    _create        = deps.create
    _addCorner     = deps.addCorner
    _addStroke     = deps.addStroke
    _Anim          = deps.Anim
    _isMobile      = deps.isMobile
    _globalCleanup = deps.globalCleanup
end

local TYPE_COLORS = {
    Success = function() return _Theme.notifSuccess end,
    Error   = function() return _Theme.notifError   end,
    Warning = function() return _Theme.notifWarning end,
    Info    = function() return _Theme.notifInfo    end,
}

local TYPE_ICONS = {
    Success = "✓",
    Error   = "✕",
    Warning = "⚠",
    Info    = "ℹ",
}

local function ensureGui()
    if notifGui and notifGui.Parent then return end
    notifGui = _create("ScreenGui", {
        Name = "RoundedUI_Notifs",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2147483646,
    }, {})
    notifGui.Parent = game:GetService("CoreGui")
end

local function getVP()
    local Camera = workspace.CurrentCamera
    return
        (Camera and Camera.ViewportSize.X or 1280),
        (Camera and Camera.ViewportSize.Y or 720)
end

local function notifWidth()
    local vpX = getVP()
    return _isMobile() and math.min(NOTIF_W, vpX - EDGE_PAD * 2) or NOTIF_W
end

local function repositionAll()
    local vpX, vpY = getVP()
    local nw = notifWidth()
    for i, frame in ipairs(activeNotifs) do
        local targetY = vpY - EDGE_PAD - i * (NOTIF_H + NOTIF_GAP)
        local targetX = vpX - nw - EDGE_PAD
        _Anim:Play(frame, _Anim.Ease, { Position = UDim2.new(0, targetX, 0, targetY) })
    end
end

local function dismissNotif(frame)
    local targetX = frame.AbsolutePosition.X + NOTIF_W + EDGE_PAD + 40
    _Anim:Play(frame, _Anim.Normal, {
        Position = UDim2.new(0, targetX, 0, frame.AbsolutePosition.Y),
        BackgroundTransparency = 1,
    })
    for i, f in ipairs(activeNotifs) do
        if f == frame then table.remove(activeNotifs, i); break end
    end
    repositionAll()
    task.delay(0.3, function()
        if frame and frame.Parent then frame:Destroy() end
        if #queue > 0 then
            Notification._show(table.remove(queue, 1))
        end
    end)
end

function Notification._show(cfg)
    ensureGui()
    if #activeNotifs >= MAX_NOTIFS then
        table.insert(queue, cfg)
        return
    end

    local title       = cfg.Title    or "Notification"
    local content     = cfg.Content  or ""
    local duration    = cfg.Duration or 4
    local ntype       = cfg.Type     or "Info"
    local colorFn     = TYPE_COLORS[ntype] or TYPE_COLORS.Info
    local accentColor = colorFn()
    local icon        = TYPE_ICONS[ntype] or "ℹ"

    local vpX, vpY = getVP()
    local nw       = notifWidth()
    local startX   = vpX + 20
    local startY   = vpY - EDGE_PAD - (1 + #activeNotifs) * (NOTIF_H + NOTIF_GAP)

    local frame = _create("Frame", {
        Size = UDim2.new(0, nw, 0, NOTIF_H),
        Position = UDim2.new(0, startX, 0, startY),
        BackgroundColor3 = _Theme.panel2,
        ZIndex = 300,
    }, {})
    frame.Parent = notifGui
    _addCorner(frame, 10)
    _addStroke(frame, accentColor, 2, 0.3)

    -- Left accent strip
    local strip = _create("Frame", {
        Size = UDim2.new(0, 4, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundColor3 = accentColor, ZIndex = 301,
    }, {})
    strip.Parent = frame; _addCorner(strip, 3)

    -- Icon glyph
    _create("TextLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 20, 0.5, -12),
        BackgroundTransparency = 1,
        Text = icon, TextColor3 = accentColor,
        Font = _FONT_B, TextSize = 16, ZIndex = 301,
        Parent = frame,
    }, {})

    -- Title
    _create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 20),
        Position = UDim2.new(0, 50, 0, 10),
        BackgroundTransparency = 1,
        Text = title, TextColor3 = _Theme.text,
        Font = _FONT_B, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 301, Parent = frame,
    }, {})

    -- Optional content line
    if content ~= "" then
        _create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 26),
            Position = UDim2.new(0, 50, 0, 32),
            BackgroundTransparency = 1,
            Text = content, TextColor3 = _Theme.textDim,
            Font = _FONT, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, ZIndex = 301, Parent = frame,
        }, {})
    end

    -- Progress bar track + fill
    local progressBg = _create("Frame", {
        Size = UDim2.new(1, -16, 0, 3),
        Position = UDim2.new(0, 8, 1, -7),
        BackgroundColor3 = _Theme.control, ZIndex = 301,
    }, {})
    progressBg.Parent = frame; _addCorner(progressBg, 2)

    local progressFill = _create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = accentColor, ZIndex = 302,
    }, {})
    progressFill.Parent = progressBg; _addCorner(progressFill, 2)

    -- Close button
    local closeX = _create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -24, 0, 6),
        BackgroundTransparency = 1,
        Text = "×", TextColor3 = _Theme.textDim,
        Font = _FONT_B, TextSize = 16, ZIndex = 302,
    }, {})
    closeX.Parent = frame

    table.insert(activeNotifs, frame)
    repositionAll()

    -- Slide in from right
    _Anim:Play(frame, _Anim.Spring, {
        Position = UDim2.new(0, vpX - nw - EDGE_PAD, 0, frame.Position.Y.Offset),
    })

    local dismissed = false
    local function doClose()
        if dismissed then return end
        dismissed = true
        dismissNotif(frame)
    end

    closeX.MouseButton1Click:Connect(doClose)

    -- Heartbeat countdown drives progress bar
    local elapsed = 0
    local conn
    conn = RunService.Heartbeat:Connect(function(dt)
        if dismissed then conn:Disconnect(); return end
        elapsed = elapsed + dt
        local t = math.clamp(1 - (elapsed / duration), 0, 1)
        progressFill.Size = UDim2.new(t, 0, 1, 0)
        if elapsed >= duration then
            conn:Disconnect()
            doClose()
        end
    end)
    if _globalCleanup then _globalCleanup:Add(conn) end
end

-- Public entry point
function Notification.Notify(cfg)
    if type(cfg) == "string" then
        cfg = { Title = cfg, Type = "Info" }
    end
    Notification._show(cfg)
end

return Notification
