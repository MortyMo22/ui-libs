-- Systems/ColorPicker.lua
-- Self-contained HSV colour picker popup.
-- Opens as a modal overlay inside the given ScreenGui.
--
-- Usage:
--   local CP = require(path.Systems.ColorPicker)
--   CP.open(rootGui, startColor, function(newColor) ... end)

local UIS = game:GetService("UserInputService")

-- These are injected by init.lua to avoid circular dependencies.
local _Theme, _FONT, _FONT_B
local _create, _addCorner, _addStroke, _addPadding, _withHover

local ColorPicker = {}

-- Called once by init.lua to inject shared state.
function ColorPicker._inject(deps)
    _Theme     = deps.Theme
    _FONT      = deps.FONT
    _FONT_B    = deps.FONT_B
    _create    = deps.create
    _addCorner = deps.addCorner
    _addStroke = deps.addStroke
    _addPadding= deps.addPadding
    _withHover = deps.withHover
end

function ColorPicker.open(rootGui, startColor, onApply)
    local connections = {}

    local overlay = _create("TextButton", {
        Name = "ColorPickerOverlay",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.45,
        Text = "",
        ZIndex = 200,
        AutoButtonColor = false,
    }, {})
    overlay.Parent = rootGui
    overlay.Modal  = true

    local _prevIgnoreGuiInset = nil
    if typeof(rootGui.IgnoreGuiInset) ~= "nil" then
        _prevIgnoreGuiInset = rootGui.IgnoreGuiInset
        rootGui.IgnoreGuiInset = true
    end

    local GuiService = game:GetService("GuiService")
    local Camera     = workspace.CurrentCamera
    local viewportY  = (Camera and Camera.ViewportSize and Camera.ViewportSize.Y) or 720
    local topInset   = 0
    if GuiService and GuiService.GetGuiInset then
        topInset = (GuiService:GetGuiInset()).Y or 0
    end

    local baseW, baseH = 340, 440
    if viewportY < baseH + 60 then
        local ratio = math.max((viewportY - 60) / baseH, 0.6)
        baseW = math.floor(baseW * ratio)
        baseH = math.floor(baseH * ratio)
    end

    local popup = _create("Frame", {
        Name = "ColorPickerWindow",
        Size = UDim2.new(0, baseW, 0, baseH),
        Position = UDim2.new(0.5, -baseW/2, 0.5, -baseH/2),
        BackgroundColor3 = _Theme.bg,
        ZIndex = 201,
    }, {})
    popup.Parent = overlay
    _addCorner(popup, 12)
    _addStroke(popup, _Theme.stroke, 2, 0.4)

    local titleBar = _create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = _Theme.panel2,
        ZIndex = 202,
    }, {})
    titleBar.Parent = popup
    _addCorner(titleBar, 12)
    _addStroke(titleBar, _Theme.stroke, 1, 0.5)

    _create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = "Color Picker",
        TextColor3 = _Theme.text,
        Font = _FONT_B,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
        Parent = titleBar,
    }, {})

    local scaleRatio = math.max(baseH / 440, 0.01)
    local pickerSize = math.max(96, math.floor(240 * scaleRatio))

    local content = _create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -24, 0, pickerSize),
        Position = UDim2.new(0, 12, 0, 52),
        BackgroundTransparency = 1,
        ZIndex = 202,
    }, {})
    content.Parent = popup

    local H, S, V = 0, 1, 1
    if startColor then H, S, V = startColor:ToHSV() end

    -- ── Picker square ────────────────────────────────────────────────────────

    local pickerFrame = _create("Frame", {
        Name = "ColorPicker",
        Size = UDim2.new(0, pickerSize, 0, pickerSize),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromHSV(H, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 203,
        ClipsDescendants = true,
    }, {})
    pickerFrame.Parent = content
    _addCorner(pickerFrame, 10)
    _addStroke(pickerFrame, _Theme.stroke, 2, 0.3)

    local satGradient = _create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 204,
    }, {})
    satGradient.Parent = pickerFrame
    _addCorner(satGradient, 10)
    local satGrad = Instance.new("UIGradient")
    satGrad.Color        = ColorSequence.new(Color3.new(1, 1, 1))
    satGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
    satGrad.Rotation     = 0
    satGrad.Parent       = satGradient

    local valGradient = _create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 205,
    }, {})
    valGradient.Parent = pickerFrame
    _addCorner(valGradient, 10)
    local valGrad = Instance.new("UIGradient")
    valGrad.Color        = ColorSequence.new(Color3.new(0, 0, 0))
    valGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0) })
    valGrad.Rotation     = 90
    valGrad.Parent       = valGradient

    local pickerButton = _create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 206,
    }, {})
    pickerButton.Parent = pickerFrame

    local cursor = _create("Frame", {
        Size = UDim2.new(0, 20, 0, 20), AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1, ZIndex = 207,
    }, {})
    cursor.Parent = pickerFrame
    local cursorOuter = _create("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 207,
    }, {})
    cursorOuter.Parent = cursor; _addCorner(cursorOuter, 10)
    local cursorInner = _create("Frame", {
        Size = UDim2.new(1, -4, 1, -4), Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 208,
    }, {})
    cursorInner.Parent = cursorOuter; _addCorner(cursorInner, 8)

    -- ── Hue slider ───────────────────────────────────────────────────────────

    local sliderWidth = 24
    local hueSlider = _create("Frame", {
        Name = "HueSlider",
        Size = UDim2.new(0, sliderWidth, 0, pickerSize),
        Position = UDim2.new(0, pickerSize + 8, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 203, ClipsDescendants = true,
    }, {})
    hueSlider.Parent = content
    _addCorner(hueSlider, 8); _addStroke(hueSlider, _Theme.stroke, 2, 0.3)

    local hueFill = _create("Frame", {
        Name = "HueFill",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 0,
        BorderSizePixel = 0, ZIndex = 203,
    }, {})
    hueFill.Parent = hueSlider; _addCorner(hueFill, 8)

    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.000, Color3.new(1, 0, 0)),
        ColorSequenceKeypoint.new(0.166, Color3.new(1, 1, 0)),
        ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
        ColorSequenceKeypoint.new(0.500, Color3.new(0, 1, 1)),
        ColorSequenceKeypoint.new(0.666, Color3.new(0, 0, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
        ColorSequenceKeypoint.new(1.000, Color3.new(1, 0, 0)),
    })
    hueGrad.Rotation = 90
    hueGrad.Parent   = hueFill

    local hueButton = _create("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 204,
    }, {})
    hueButton.Parent = hueSlider

    local hueCursor = _create("Frame", {
        Name = "HueCursor",
        Size = UDim2.new(1, 6, 0, 6),
        Position = UDim2.new(0.5, 0, 0, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0, ZIndex = 205,
    }, {})
    hueCursor.Parent = hueSlider
    _addCorner(hueCursor, 3); _addStroke(hueCursor, Color3.new(0, 0, 0), 2, 0)

    -- ── Preview swatch ───────────────────────────────────────────────────────

    local preview = _create("Frame", {
        Name = "Preview",
        Size = UDim2.new(0, 36, 0, pickerSize),
        Position = UDim2.new(0, pickerSize + sliderWidth + 16, 0, 0),
        BackgroundColor3 = Color3.fromHSV(H, S, V),
        BorderSizePixel = 0, ZIndex = 203,
    }, {})
    preview.Parent = content
    _addCorner(preview, 10); _addStroke(preview, _Theme.stroke, 2, 0.3)

    -- ── Info panel (RGB + HEX) ───────────────────────────────────────────────

    local infoPanelHeight = 90
    local infoPanelY      = pickerSize + 12
    do
        local btnHeight = 38; local btnGap = 12
        local totalNeeded = infoPanelY + infoPanelHeight + btnGap + btnHeight + 12
        if totalNeeded > baseH then
            local overflow = totalNeeded - baseH
            local reduceBy = math.min(math.floor(overflow + 4), infoPanelHeight - 40)
            if reduceBy > 0 then infoPanelHeight = infoPanelHeight - reduceBy end
        end
    end

    local infoPanel = _create("Frame", {
        Size = UDim2.new(1, -24, 0, infoPanelHeight),
        Position = UDim2.new(0, 12, 0, infoPanelY),
        BackgroundColor3 = _Theme.panel2, ZIndex = 202,
    }, {})
    infoPanel.Parent = popup
    _addCorner(infoPanel, 10); _addStroke(infoPanel, _Theme.stroke, 1, 0.4); _addPadding(infoPanel, 10)

    local function createNumberInput(name, yPos)
        _create("TextLabel", {
            Size = UDim2.new(0, 25, 0, 24), Position = UDim2.new(0, 0, 0, yPos),
            BackgroundTransparency = 1, Text = name .. ":",
            TextColor3 = _Theme.textDim, Font = _FONT, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203, Parent = infoPanel,
        }, {})
        local input = _create("TextBox", {
            Size = UDim2.new(0, 70, 0, 24), Position = UDim2.new(0, 30, 0, yPos),
            BackgroundColor3 = _Theme.control, Text = "255", TextColor3 = _Theme.text,
            Font = _FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center,
            ClearTextOnFocus = false, ZIndex = 203, PlaceholderText = "0",
        }, {})
        input.Parent = infoPanel; _addCorner(input, 6); _addStroke(input, _Theme.stroke, 1, 0.4)
        return input
    end

    local rInput = createNumberInput("R", 0)
    local gInput = createNumberInput("G", 30)
    local bInput = createNumberInput("B", 60)

    _create("TextLabel", {
        Size = UDim2.new(0, 40, 0, 24), Position = UDim2.new(0, 120, 0, 30),
        BackgroundTransparency = 1, Text = "HEX:",
        TextColor3 = _Theme.textDim, Font = _FONT, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 203, Parent = infoPanel,
    }, {})

    local hexInput = _create("TextBox", {
        Size = UDim2.new(1, -170, 0, 24), Position = UDim2.new(0, 165, 0, 30),
        BackgroundColor3 = _Theme.control, Text = "", TextColor3 = _Theme.text,
        Font = _FONT, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false, ZIndex = 203, PlaceholderText = "#FFFFFF",
    }, {})
    hexInput.Parent = infoPanel
    _addCorner(hexInput, 6); _addStroke(hexInput, _Theme.stroke, 1, 0.4)

    -- ── Buttons ──────────────────────────────────────────────────────────────

    local btnHeight = 38; local btnGap = 12
    local buttonsY  = infoPanelY + infoPanelHeight + btnGap

    local buttonContainer = _create("Frame", {
        Size = UDim2.new(1, -24, 0, btnHeight),
        Position = UDim2.new(0, 12, 0, buttonsY),
        BackgroundTransparency = 1, ZIndex = 210,
    }, {})
    buttonContainer.Parent = popup

    local cancelBtn = _create("TextButton", {
        Size = UDim2.new(0.48, 0, 1, 0),
        BackgroundColor3 = _Theme.control,
        Text = "Cancel", TextColor3 = _Theme.text,
        Font = _FONT_B, TextSize = 16, ZIndex = 203,
    }, {})
    cancelBtn.Parent = buttonContainer
    _addCorner(cancelBtn, 8); _withHover(cancelBtn, _Theme.control, _Theme.hover)

    local applyBtn = _create("TextButton", {
        Size = UDim2.new(0.48, 0, 1, 0), Position = UDim2.new(0.52, 0, 0, 0),
        BackgroundColor3 = _Theme.accent,
        Text = "Apply", TextColor3 = _Theme.text,
        Font = _FONT_B, TextSize = 16, ZIndex = 203,
    }, {})
    applyBtn.Parent = buttonContainer
    _addCorner(applyBtn, 8); _withHover(applyBtn, _Theme.accent, _Theme.accentDim)

    -- ── Drag state and visual update ─────────────────────────────────────────

    local draggingPicker = false
    local draggingHue    = false
    local updatingFromCode = false

    local function getInsetY()
        if typeof(rootGui.IgnoreGuiInset) ~= "nil" and rootGui.IgnoreGuiInset == true then
            local gs = game:GetService("GuiService")
            return (gs:GetGuiInset()).Y or 0
        end
        return 0
    end

    local function updateVisuals()
        updatingFromCode = true
        local currentColor = Color3.fromHSV(H, S, V)
        pickerFrame.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        cursor.Position    = UDim2.new(S, 0, 1 - V, 0)
        hueCursor.Position = UDim2.new(0.5, 0, H, 0)
        preview.BackgroundColor3 = currentColor
        local r = math.floor(currentColor.R * 255 + 0.5)
        local g = math.floor(currentColor.G * 255 + 0.5)
        local b = math.floor(currentColor.B * 255 + 0.5)
        rInput.Text   = tostring(r)
        gInput.Text   = tostring(g)
        bInput.Text   = tostring(b)
        hexInput.Text = "#" .. currentColor:ToHex():upper()
        updatingFromCode = false
    end

    -- ── Input events ─────────────────────────────────────────────────────────

    pickerButton.MouseButton1Down:Connect(function(x, y)
        draggingPicker = true
        local iy = getInsetY()
        S = math.clamp((x - pickerFrame.AbsolutePosition.X) / pickerFrame.AbsoluteSize.X, 0, 1)
        V = 1 - math.clamp(((y - iy) - pickerFrame.AbsolutePosition.Y) / pickerFrame.AbsoluteSize.Y, 0, 1)
        updateVisuals()
    end)

    hueButton.MouseButton1Down:Connect(function(x, y)
        draggingHue = true
        local iy = getInsetY()
        H = math.clamp(((y - iy) - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
        updateVisuals()
    end)

    pickerButton.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        draggingPicker = true
        local iy = getInsetY()
        local pos = input.Position
        S = math.clamp((pos.X - pickerFrame.AbsolutePosition.X) / pickerFrame.AbsoluteSize.X, 0, 1)
        V = 1 - math.clamp(((pos.Y - iy) - pickerFrame.AbsolutePosition.Y) / pickerFrame.AbsoluteSize.Y, 0, 1)
        updateVisuals()
    end)

    hueButton.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        draggingHue = true
        local iy = getInsetY()
        local pos = input.Position
        H = math.clamp(((pos.Y - iy) - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
        updateVisuals()
    end)

    table.insert(connections, UIS.InputChanged:Connect(function(input)
        local isMM = input.UserInputType == Enum.UserInputType.MouseMovement
        local isT  = input.UserInputType == Enum.UserInputType.Touch
        if not (isMM or isT) then return end
        local pos = input.Position
        local iy  = getInsetY()
        if draggingPicker then
            S = math.clamp((pos.X - pickerFrame.AbsolutePosition.X) / pickerFrame.AbsoluteSize.X, 0, 1)
            V = 1 - math.clamp(((pos.Y - iy) - pickerFrame.AbsolutePosition.Y) / pickerFrame.AbsoluteSize.Y, 0, 1)
            updateVisuals()
        elseif draggingHue then
            H = math.clamp(((pos.Y - iy) - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
            updateVisuals()
        end
    end))

    table.insert(connections, UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingPicker = false
            draggingHue    = false
        end
    end))

    local function handleRGBInput()
        if updatingFromCode then return end
        local r = math.clamp(tonumber(rInput.Text) or 0, 0, 255) / 255
        local g = math.clamp(tonumber(gInput.Text) or 0, 0, 255) / 255
        local b = math.clamp(tonumber(bInput.Text) or 0, 0, 255) / 255
        H, S, V = Color3.new(r, g, b):ToHSV()
        updateVisuals()
    end
    rInput.FocusLost:Connect(handleRGBInput)
    gInput.FocusLost:Connect(handleRGBInput)
    bInput.FocusLost:Connect(handleRGBInput)

    hexInput.FocusLost:Connect(function()
        if updatingFromCode then return end
        local text = hexInput.Text
        if text:sub(1, 1) == "#" then text = text:sub(2) end
        local ok, res = pcall(function() return Color3.fromHex(text) end)
        if ok then H, S, V = res:ToHSV() end
        updateVisuals()
    end)

    -- ── Close logic ──────────────────────────────────────────────────────────

    local function closePopup()
        for _, c in ipairs(connections) do c:Disconnect() end
        overlay:Destroy()
        if _prevIgnoreGuiInset ~= nil then
            rootGui.IgnoreGuiInset = _prevIgnoreGuiInset
        end
    end

    applyBtn.MouseButton1Click:Connect(function()
        if onApply then onApply(Color3.fromHSV(H, S, V)) end
        closePopup()
    end)
    cancelBtn.MouseButton1Click:Connect(closePopup)

    table.insert(connections, overlay.MouseButton1Click:Connect(function()
        local mouse  = UIS:GetMouseLocation()
        local gs     = game:GetService("GuiService")
        local inset  = gs:GetGuiInset()
        local pos    = Vector2.new(mouse.X, mouse.Y - inset.Y)
        local p0     = popup.AbsolutePosition
        local ps     = popup.AbsoluteSize
        local inside = pos.X >= p0.X and pos.X <= p0.X + ps.X
                   and pos.Y >= p0.Y and pos.Y <= p0.Y + ps.Y
        if not inside then closePopup() end
    end))

    updateVisuals()
end

return ColorPicker
