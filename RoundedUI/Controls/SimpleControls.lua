-- Controls/SimpleControls.lua
-- Stateless or lightly-stateful controls that do not share toggle/color logic.
-- Controls: Label, Separator, Button, TextBox, SearchBox, TextBind
--
-- Each function receives (stack, deps, ...) where:
--   stack = the UIListLayout parent frame to insert into
--   deps  = { Theme, FONT, FONT_B, create, addCorner, addStroke, Anim,
--             withHoverAnim, addKeybind, removeKeybind, setCurrentRecorder }

local SimpleControls = {}

-- ─── Label ───────────────────────────────────────────────────────────────────

function SimpleControls.Label(stack, deps, text, opts)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create    = deps.create
    opts = opts or {}

    local spacer = create("Frame", {
        Size = UDim2.new(1, 0, 0, opts.topMargin or 6),
        BackgroundTransparency = 1,
    }, {})
    spacer.Parent = stack

    local lbl = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, (opts.size or 14) + 2),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = opts.color or T.textDim,
        Font = opts.bold and FB or F,
        TextSize = opts.size or 14,
        TextXAlignment = opts.align or Enum.TextXAlignment.Left,
    }, {})
    lbl.Parent = stack
    return lbl
end

-- ─── Separator ───────────────────────────────────────────────────────────────

function SimpleControls.Separator(stack, deps)
    local sep = deps.create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = deps.Theme.stroke,
    }, {})
    sep.Parent = stack
    return sep
end

-- ─── Button ──────────────────────────────────────────────────────────────────

function SimpleControls.Button(stack, deps, text, callback)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create, addCorner, withHoverAnim, Anim = deps.create, deps.addCorner, deps.withHoverAnim, deps.Anim

    local btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.control,
        Text = text, TextColor3 = T.text,
        Font = FB, TextSize = 14,
    }, {})
    addCorner(btn, 8)
    withHoverAnim(btn, T.control, T.hover, Anim)
    btn.Parent = stack
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

-- ─── TextBox ─────────────────────────────────────────────────────────────────
-- opts: { MaxLength, NumbersOnly, FloatOnly, OnChanged, OnSubmitted }

function SimpleControls.TextBox(stack, deps, placeholder, callback, opts)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke, Anim = deps.create, deps.addCorner, deps.addStroke, deps.Anim
    opts = opts or {}

    local box = create("TextBox", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.control,
        TextColor3 = T.text,
        Font = F, TextSize = 14,
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = T.textDim,
        Text = "",                       -- fixed: was showing "TextBox" placeholder
        ClearTextOnFocus = false,
    }, {})
    addCorner(box, 8)
    local stroke = addStroke(box, T.stroke, 1, 0.5)
    box.Parent = stack

    -- Focus: accent stroke glow
    box.Focused:Connect(function()
        Anim:Play(stroke, Anim.Fast, { Color = T.accent, Transparency = 0 })
    end)
    box.FocusLost:Connect(function(enterPressed)
        Anim:Play(stroke, Anim.Fast, { Color = T.stroke, Transparency = 0.5 })
        if callback then callback(box.Text, enterPressed) end
        if opts.OnSubmitted and enterPressed then opts.OnSubmitted(box.Text) end
    end)

    if opts.OnChanged then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            opts.OnChanged(box.Text)
        end)
    end
    if opts.MaxLength then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            if #box.Text > opts.MaxLength then
                box.Text = box.Text:sub(1, opts.MaxLength)
            end
        end)
    end
    if opts.NumbersOnly then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local clean = box.Text:gsub("[^%d]", "")
            if clean ~= box.Text then box.Text = clean end
        end)
    end
    if opts.FloatOnly then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local clean = box.Text:gsub("[^%d%.]", "")
            if clean ~= box.Text then box.Text = clean end
        end)
    end

    return box
end

-- ─── SearchBox ───────────────────────────────────────────────────────────────

function SimpleControls.SearchBox(stack, deps, placeholder, callback, props)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke, Anim = deps.create, deps.addCorner, deps.addStroke, deps.Anim
    props = props or {}

    local row = create("Frame", {
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = T.control,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, {})
    row.Parent = stack
    addCorner(row, 8)
    local stroke = addStroke(row, T.stroke, 1, 0.5)

    create("TextLabel", {
        Size = UDim2.new(0, 28, 1, 0),
        BackgroundTransparency = 1, Text = "🔍", TextSize = 14,
        Font = F, TextColor3 = T.textDim,
        TextXAlignment = Enum.TextXAlignment.Center, Parent = row,
    }, {})

    local box = create("TextBox", {
        Size = UDim2.new(1, -34, 1, -4), Position = UDim2.new(0, 28, 0, 2),
        BackgroundTransparency = 1,
        TextColor3 = props.TextColor or T.text,
        PlaceholderColor3 = props.PlaceholderColor or T.textDim,
        PlaceholderText = placeholder or "Search...",
        Font = F, TextSize = 14, ClearTextOnFocus = false,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {})
    box.Parent = row

    box.Focused:Connect(function()
        Anim:Play(stroke, Anim.Fast, { Color = T.accent, Transparency = 0 })
    end)
    box.FocusLost:Connect(function()
        Anim:Play(stroke, Anim.Fast, { Color = T.stroke, Transparency = 0.5 })
    end)

    local currentCb = callback
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if currentCb then currentCb(box.Text) end
    end)

    local obj = {}
    function obj:SetText(text)     box.Text = text end
    function obj:GetText()         return box.Text end
    function obj:SetCallback(fn)   currentCb = fn  end
    function obj:GetBox()          return box       end
    return obj
end

-- ─── TextBind ────────────────────────────────────────────────────────────────

function SimpleControls.TextBind(stack, deps, labelText, initKey, callback)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local addKeybind, removeKeybind, setCurrentRecorder =
        deps.addKeybind, deps.removeKeybind, deps.setCurrentRecorder

    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, {})
    row.Parent = stack

    create("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0), BackgroundTransparency = 1,
        Text = labelText, TextColor3 = T.text,
        Font = F, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
    }, {})

    local keyBtn = create("TextButton", {
        Size = UDim2.new(0.3, -6, 1, 0), Position = UDim2.new(0.7, 6, 0, 0),
        BackgroundColor3 = T.control, TextColor3 = T.text,
        Font = FB, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = (initKey and initKey.Name) or "RightShift",
    }, {})
    addCorner(keyBtn, 8); addStroke(keyBtn, T.stroke, 1, 0.5)
    keyBtn.Parent = row

    local bindKey = initKey or Enum.KeyCode.RightShift
    local function onBind() if callback then callback() end end

    local function updateBind(newKey)
        removeKeybind(bindKey, onBind)
        bindKey = newKey
        keyBtn.Text = bindKey.Name
        keyBtn.BackgroundColor3 = T.control
        addKeybind(bindKey, onBind)
    end
    updateBind(bindKey)

    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "Press key..."
        keyBtn.BackgroundColor3 = T.accentDim
        setCurrentRecorder(function(newKey) updateBind(newKey) end)
    end)

    return { SetBind = function(newKey) updateBind(newKey) end }
end

return SimpleControls
