-- Controls/ToggleControls.lua
-- All toggle variants share a common checkbox box builder.
-- Controls: Toggle, ToggleWithBind, ToggleBind, ToggleColor, ToggleDualColor

local ToggleControls = {}

-- Shared: build the 28×28 checkbox button already parented to row.
local function buildBox(row, state, deps)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local box = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = state and T.accent or T.control,
        Text = "",
    }, {})
    addCorner(box, 6); addStroke(box, T.stroke, 1, 0.5)
    box.Parent = row
    return box
end

-- Shared: animate box color on state change.
local function animBox(box, state, deps)
    deps.Anim:Play(box, deps.Anim.Fast, {
        BackgroundColor3 = state and deps.Theme.accent or deps.Theme.control
    })
end

-- ─── Toggle ──────────────────────────────────────────────────────────────────

function ToggleControls.Toggle(stack, deps, text, opts)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create    = deps.create
    opts = opts or {}
    local state = opts.Default or false

    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, {})
    row.Parent = stack

    local box = buildBox(row, state, deps)
    create("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0), Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = T.text,
        Font = F, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    }, {})

    local function set(val)
        state = val
        animBox(box, state, deps)
        if opts.Callback then opts.Callback(state) end
    end
    box.MouseButton1Click:Connect(function() set(not state) end)

    return { Set = set, Get = function() return state end }
end

-- ─── ToggleWithBind ──────────────────────────────────────────────────────────

function ToggleControls.ToggleWithBind(stack, deps, text, opts)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local addKeybind, removeKeybind, setCurrentRecorder =
        deps.addKeybind, deps.removeKeybind, deps.setCurrentRecorder
    opts = opts or {}
    local state    = opts.Default  or false
    local bindKey  = opts.Bind     or Enum.KeyCode.F
    local onToggle = opts.Callback
    local onTrigger= opts.Trigger

    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, {})
    row.Parent = stack
    local box = buildBox(row, state, deps)

    create("TextLabel", {
        Size = UDim2.new(0.55, 0, 1, 0), Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = T.text,
        Font = F, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    }, {})

    local keyBtn = create("TextButton", {
        Size = UDim2.new(0.35, -6, 1, 0), Position = UDim2.new(0.65, 6, 0, 0),
        BackgroundColor3 = T.control, TextColor3 = T.text,
        Font = FB, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        Text = bindKey.Name,
    }, {})
    addCorner(keyBtn, 8); addStroke(keyBtn, T.stroke, 1, 0.5)
    keyBtn.Parent = row

    local function setState(val)
        state = val
        animBox(box, state, deps)
        if onToggle then onToggle(state, bindKey) end
    end
    box.MouseButton1Click:Connect(function() setState(not state) end)

    local function onBind()
        setState(not state)
        if onTrigger then onTrigger(state, bindKey) end
    end
    local function updateBind(newKey)
        removeKeybind(bindKey, onBind)
        bindKey = newKey
        keyBtn.Text = bindKey.Name
        keyBtn.BackgroundColor3 = T.control
        addKeybind(bindKey, onBind)
    end
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "Press key..."
        keyBtn.BackgroundColor3 = T.accentDim
        setCurrentRecorder(function(newKey) updateBind(newKey) end)
    end)
    updateBind(bindKey)

    return {
        Set     = setState,
        Get     = function() return state end,
        SetBind = function(newKey) updateBind(newKey) end,
    }
end

-- ─── ToggleBind ──────────────────────────────────────────────────────────────
-- Thin wrapper: Toggle + a Label hint + keybind wiring.

function ToggleControls.ToggleBind(stack, deps, text, opts)
    local addKeybind, removeKeybind = deps.addKeybind, deps.removeKeybind
    opts = opts or {}
    local bindKey = opts.Bind or Enum.KeyCode.R

    -- Reuse Toggle via sectionAPI reference (passed as deps.sectionAPI)
    local toggle = ToggleControls.Toggle(stack, deps, text, {
        Default  = opts.Default  or false,
        Callback = opts.Callback,
    })

    -- Label hint (create directly so we don't need full sectionAPI)
    local hint = deps.create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = ("Bind: %s"):format(tostring(bindKey)),
        TextColor3 = deps.Theme.textDim,
        Font = deps.FONT, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {})
    hint.Parent = stack

    local function onBind() toggle.Set(not toggle.Get()) end
    local function updateBind(newKey)
        removeKeybind(bindKey, onBind)
        bindKey = newKey
        hint.Text = ("Bind: %s"):format(tostring(bindKey))
        addKeybind(bindKey, onBind)
    end
    updateBind(bindKey)

    return {
        Set     = toggle.Set,
        Get     = toggle.Get,
        SetBind = function(newKey) updateBind(newKey) end,
    }
end

-- ─── ToggleColor ─────────────────────────────────────────────────────────────

function ToggleControls.ToggleColor(stack, deps, text, defaultState, defaultColor, callback)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local openColorPicker = deps.openColorPicker

    -- Spacer
    create("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Parent = stack }, {})
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, {})
    row.Parent = stack

    local state = defaultState or false
    local box   = buildBox(row, state, deps)

    create("TextLabel", {
        Size = UDim2.new(1, -36 - 36, 1, 0), Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = T.text,
        Font = F, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    }, {})

    local colorBtn = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -32, 0, 3),
        BackgroundColor3 = defaultColor or T.accent, Text = "", ZIndex = 5,
    }, {})
    addCorner(colorBtn, 6); addStroke(colorBtn, T.stroke, 1, 0.5)
    colorBtn.Parent = row

    local function setToggle(newState)
        state = newState
        animBox(box, state, deps)
        if callback then callback(state, colorBtn.BackgroundColor3) end
    end
    box.MouseButton1Click:Connect(function() setToggle(not state) end)

    colorBtn.MouseButton1Click:Connect(function()
        openColorPicker(colorBtn.BackgroundColor3, function(newColor)
            colorBtn.BackgroundColor3 = newColor
            if callback then callback(state, colorBtn.BackgroundColor3) end
        end)
    end)

    if callback then callback(state, colorBtn.BackgroundColor3) end

    return {
        Set = function(s, c)
            setToggle(s)
            if c then colorBtn.BackgroundColor3 = c end
            if callback then callback(state, colorBtn.BackgroundColor3) end
        end,
        Get = function() return state, colorBtn.BackgroundColor3 end,
    }
end

-- ─── ToggleDualColor ─────────────────────────────────────────────────────────

function ToggleControls.ToggleDualColor(stack, deps, text, defaultState, c1, c2, callback)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local openColorPicker = deps.openColorPicker

    create("Frame", { Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Parent = stack }, {})
    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, {})
    row.Parent = stack

    local state = defaultState or false
    local box   = buildBox(row, state, deps)

    create("TextLabel", {
        Size = UDim2.new(1, -36 - 68, 1, 0), Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1, Text = text, TextColor3 = T.text,
        Font = F, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    }, {})

    local btn1 = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -64, 0, 3),
        BackgroundColor3 = c1 or T.accent, Text = "", ZIndex = 5,
    }, {})
    addCorner(btn1, 6); addStroke(btn1, T.stroke, 1, 0.5); btn1.Parent = row

    local btn2 = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(1, -32, 0, 3),
        BackgroundColor3 = c2 or T.good, Text = "", ZIndex = 5,
    }, {})
    addCorner(btn2, 6); addStroke(btn2, T.stroke, 1, 0.5); btn2.Parent = row

    local function notify()
        if callback then callback(state, btn1.BackgroundColor3, btn2.BackgroundColor3) end
    end
    local function setToggle(newState)
        state = newState
        animBox(box, state, deps)
        notify()
    end
    box.MouseButton1Click:Connect(function() setToggle(not state) end)

    local function openPicker(btn)
        openColorPicker(btn.BackgroundColor3, function(newColor)
            btn.BackgroundColor3 = newColor
            notify()
        end)
    end
    btn1.MouseButton1Click:Connect(function() openPicker(btn1) end)
    btn2.MouseButton1Click:Connect(function() openPicker(btn2) end)
    notify()

    return {
        Set = function(s, nc1, nc2)
            setToggle(s)
            if nc1 then btn1.BackgroundColor3 = nc1 end
            if nc2 then btn2.BackgroundColor3 = nc2 end
            notify()
        end,
        Get = function() return state, btn1.BackgroundColor3, btn2.BackgroundColor3 end,
    }
end

return ToggleControls
