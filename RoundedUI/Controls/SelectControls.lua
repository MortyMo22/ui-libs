-- Controls/SelectControls.lua
-- Controls: Slider, DropDown, List
-- DropDown and List share a unified popup builder (openSelectPopup).
--
-- deps table expected keys:
--   Theme, FONT, FONT_B, create, addCorner, addStroke, withHoverAnim,
--   Anim, UIS, windowCleanup,
--   getOpenPopup()         → current open popup frame or nil
--   setOpenPopup(frame)    → store current popup (nil to clear)
--   closeOpenPopup()       → destroy current popup and set nil

local SelectControls = {}

-- ─── Shared popup builder ─────────────────────────────────────────────────────
-- Used by both DropDown and List.
-- anchorBtn   : the button whose position anchors the popup
-- popHeight   : pixel height of the popup
-- buildItems  : function(sc, pop, ov) that populates the ScrollingFrame
-- Returns the popup Frame.

local function openSelectPopup(anchorBtn, deps, popHeight, buildItems)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local Anim = deps.Anim

    deps.closeOpenPopup()

    local rootGui = anchorBtn:FindFirstAncestorOfClass("ScreenGui")

    local ov = create("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, Text = "", ZIndex = 200,
    }, {})
    ov.Parent = rootGui

    local pop = create("Frame", {
        Size     = UDim2.new(0, anchorBtn.AbsoluteSize.X, 0, 0),
        Position = UDim2.new(0, anchorBtn.AbsolutePosition.X,
                             0, anchorBtn.AbsolutePosition.Y + anchorBtn.AbsoluteSize.Y),
        BackgroundColor3 = T.panel2, ZIndex = 201,
    }, {})
    addCorner(pop, 8); addStroke(pop, T.stroke, 1, 0.5)
    pop.Parent = rootGui
    Anim:Play(pop, Anim.Normal, { Size = UDim2.new(0, anchorBtn.AbsoluteSize.X, 0, popHeight) })

    local sc = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 202,
    }, {})
    sc.Parent = pop
    local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0, 4); lay.Parent = sc

    buildItems(sc, pop, ov)

    ov.MouseButton1Click:Connect(function()
        ov:Destroy(); pop:Destroy()
        deps.setOpenPopup(nil)
    end)

    deps.setOpenPopup(pop)
    return pop
end

-- ─── Slider ───────────────────────────────────────────────────────────────────

function SelectControls.Slider(stack, deps, text, cfg, callback)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create, addCorner, withHoverAnim, Anim, UIS, windowCleanup =
        deps.create, deps.addCorner, deps.withHoverAnim, deps.Anim, deps.UIS, deps.windowCleanup

    local min         = cfg.min         or 0
    local max         = cfg.max         or 100
    local value       = cfg.default     or min
    local suffix      = cfg.suffix      or ""
    local showPercent = cfg.showPercent or false
    local showReset   = cfg.showReset   ~= false

    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, showReset and 72 or 50),
        BackgroundTransparency = 1,
    }, {})
    container.Parent = stack

    local top = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = ("%s: %s%s"):format(text, tostring(value), suffix),
        TextColor3 = T.text, Font = F, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {})
    top.Parent = container

    local bar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = T.control,
    }, {})
    addCorner(bar, 8); bar.Parent = container

    local fill = create("Frame", {
        Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = T.accent,
    }, {})
    addCorner(fill, 8); fill.Parent = bar

    local function set(v)
        value = math.clamp(v, min, max)
        local rel = (value - min) / (max - min)
        Anim:Play(fill, Anim.Fast, { Size = UDim2.new(rel, 0, 1, 0) })
        if showPercent then
            top.Text = ("%s: %d%%"):format(text, math.floor(rel * 100 + 0.5))
        else
            top.Text = ("%s: %s%s"):format(text, string.format("%.2f", value):gsub(",", ""), suffix)
        end
        if callback then callback(value) end
    end

    if showReset then
        local actRow = create("Frame", {
            Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 46),
            BackgroundTransparency = 1,
        }, {})
        actRow.Parent = container
        local resetBtn = create("TextButton", {
            Size = UDim2.new(0, 64, 0, 20), Position = UDim2.new(1, -68, 0, 2),
            BackgroundColor3 = T.control, Text = "Reset",
            TextColor3 = T.text, Font = FB, TextSize = 12,
        }, {})
        addCorner(resetBtn, 6)
        withHoverAnim(resetBtn, T.control, T.hover, Anim)
        resetBtn.Parent = actRow
        resetBtn.MouseButton1Click:Connect(function() set(cfg.default or min) end)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            local conn, endConn
            conn = UIS.InputChanged:Connect(function(ch)
                if ch.UserInputType == Enum.UserInputType.MouseMovement
                or ch.UserInputType == Enum.UserInputType.Touch then
                    local rel = math.clamp(
                        (ch.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                        0, 1)
                    set(min + (max - min) * rel)
                end
            end)
            endConn = UIS.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == input.UserInputType then
                    if conn    then conn:Disconnect()    end
                    if endConn then endConn:Disconnect() end
                end
            end)
            windowCleanup:Add(conn)
            windowCleanup:Add(endConn)
        end
    end)

    return { Set = set, Get = function() return value end }
end

-- ─── DropDown ─────────────────────────────────────────────────────────────────

function SelectControls.DropDown(stack, deps, text, options, default, callback)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke, withHoverAnim, Anim =
        deps.create, deps.addCorner, deps.addStroke, deps.withHoverAnim, deps.Anim

    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1,
    }, {})
    container.Parent = stack

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = T.text, Font = F, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container,
    }, {})

    local current = default or options[1]
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = T.control, Text = tostring(current),
        TextColor3 = T.text, Font = F, TextSize = 14, ZIndex = 5,
    }, {})
    addCorner(btn, 8); addStroke(btn, T.stroke, 1, 0.5)
    btn.Parent = container

    btn.MouseButton1Click:Connect(function()
        if deps.getOpenPopup() then
            deps.closeOpenPopup()
            return
        end
        local popH = math.min(#options * 26, 150)
        openSelectPopup(btn, deps, popH, function(sc, pop, ov)
            sc.CanvasSize = UDim2.new(0, 0, 0, #options * 26)
            for _, opt in ipairs(options) do
                local item = create("TextButton", {
                    Size = UDim2.new(1, -8, 0, 24),
                    BackgroundColor3 = T.control,
                    Text = tostring(opt), TextColor3 = T.text,
                    Font = F, TextSize = 14, ZIndex = 203,
                }, {})
                addCorner(item, 6); item.Parent = sc
                withHoverAnim(item, T.control, T.hover, Anim)
                item.MouseButton1Click:Connect(function()
                    current = opt; btn.Text = tostring(current)
                    if callback then callback(current) end
                    ov:Destroy(); pop:Destroy()
                    deps.setOpenPopup(nil)
                end)
            end
        end)
    end)

    return {
        Get = function() return current end,
        Set = function(val)
            if table.find(options, val) then
                current = val; btn.Text = tostring(current)
                if callback then callback(current) end
            end
        end,
    }
end

-- ─── List ─────────────────────────────────────────────────────────────────────

function SelectControls.List(stack, deps, text, options, callback)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke, withHoverAnim, Anim =
        deps.create, deps.addCorner, deps.addStroke, deps.withHoverAnim, deps.Anim

    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 56), BackgroundTransparency = 1,
    }, {})
    container.Parent = stack

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1,
        Text = text, TextColor3 = T.text, Font = F, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = container,
    }, {})

    local STATUS_TEXT = "Choose..."
    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 0, 24),
        BackgroundColor3 = T.control, Text = STATUS_TEXT,
        TextColor3 = T.text, Font = F, TextSize = 14, ZIndex = 5,
    }, {})
    addCorner(btn, 8); addStroke(btn, T.stroke, 1, 0.5)
    btn.Parent = container

    local selected = {}
    local function updateStatus()
        local keys = {}
        for name, on in pairs(selected) do
            if on then table.insert(keys, name) end
        end
        btn.Text = (#keys > 0) and table.concat(keys, ", ") or STATUS_TEXT
    end

    btn.MouseButton1Click:Connect(function()
        if deps.getOpenPopup() then
            deps.closeOpenPopup()
            return
        end
        local popH = math.min(#options * 26, 150)
        openSelectPopup(btn, deps, popH, function(sc, pop, ov)
            sc.CanvasSize = UDim2.new(0, 0, 0, #options * 26)
            for _, name in ipairs(options) do
                local item = create("TextButton", {
                    Size = UDim2.new(1, -8, 0, 24),
                    BackgroundColor3 = T.control,
                    Text = name, TextColor3 = T.text,
                    Font = F, TextSize = 14, ZIndex = 203,
                }, {})
                addCorner(item, 6); item.Parent = sc
                withHoverAnim(item, T.control, T.hover, Anim)
                item.MouseButton1Click:Connect(function()
                    selected[name] = not selected[name]
                    Anim:Play(item, Anim.Fast, {
                        BackgroundColor3 = selected[name] and T.accent or T.control,
                    })
                    updateStatus()
                    if callback then callback(selected) end
                end)
            end
        end)
    end)

    return {
        Get = function() return selected end,
        Set = function(tbl)
            selected = tbl or {}
            updateStatus()
            if callback then callback(selected) end
        end,
    }
end

return SelectControls
