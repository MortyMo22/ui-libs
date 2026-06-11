-- UI/Window.lua
-- Creates the root window: ScreenGui, draggable frame, header, tab strip,
-- content area, minimize/close, and the mobile floating toggle button.
--
-- Returns CreateWindow(nameLeft, nameRight) → api
--   api:AddSection(tabName)          → pageAPI
--   api:SetHeader(leftText, rightText)
--
-- pageAPI:AddUnderSections(leftName, rightName) → leftSectionAPI, rightSectionAPI
-- pageAPI:SetNameOfMainSection(newName)
--
-- sharedDeps is built in init.lua and passed here.

local UIS = game:GetService("UserInputService")

local Window = {}

function Window.CreateWindow(nameLeft, nameRight, sharedDeps)
    local D  = sharedDeps          -- full deps table
    local T  = D.Theme
    local F  = D.FONT
    local FB = D.FONT_B

    local create, addCorner, addStroke, addPadding =
        D.create, D.addCorner, D.addStroke, D.addPadding
    local isMobile        = D.isMobile
    local addKeybind      = D.addKeybind
    local Cleanup         = D.Cleanup
    local SectionFactory  = D.SectionFactory   -- UI/Section.make

    -- ── Cleanup registry for this window's lifetime ───────────────────────────
    local windowCleanup = Cleanup.new()

    -- Inject windowCleanup into deps so controls (Slider, VirtualList) can track
    -- their own connections safely.
    D.windowCleanup = windowCleanup

    -- ── ScreenGui ─────────────────────────────────────────────────────────────
    local gui = create("ScreenGui", {
        Name = "RoundedUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 2147483647,
    }, {})
    gui.Parent = game:GetService("CoreGui")

    -- ── Window frame ──────────────────────────────────────────────────────────
    local function getWindowSize()
        local Camera = workspace.CurrentCamera
        local vp     = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
        local wScale = isMobile() and 0.95 or 0.6
        local hScale = isMobile() and 0.8  or 0.7
        return UDim2.new(wScale, 0, hScale, 0)
    end

    local window = create("Frame", {
        Name = "Window",
        Size = getWindowSize(),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = T.bg,
    }, {})
    window.Parent = gui
    addCorner(window, 12)
    addStroke(window, T.stroke, 1, 0.6)
    addPadding(window, 10)

    -- ── Header ────────────────────────────────────────────────────────────────
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = T.panel,
    }, {})
    header.Parent = window
    addCorner(header, 10)
    addStroke(header, T.stroke, 1, 0.6)

    local leftTitle = create("TextLabel", {
        Size = UDim2.new(0.5, -8, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = nameLeft or "UI",
        TextColor3 = T.text, Font = FB, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, {})
    leftTitle.Parent = header

    local rightTitle = create("TextLabel", {
        Size = UDim2.new(1, -120, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = nameRight or "",
        TextColor3 = T.textDim, Font = F, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, {})
    rightTitle.Parent = header

    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -28, 0.5, -12),
        BackgroundColor3 = T.warn,
        Text = "X", TextColor3 = Color3.new(1, 1, 1),
        Font = FB, TextSize = 14,
    }, {})
    addCorner(closeBtn, 6)
    closeBtn.Parent = header

    local minimizeBtn = create("TextButton", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = T.control,
        Text = "_", TextColor3 = T.text,
        Font = FB, TextSize = 14,
    }, {})
    addCorner(minimizeBtn, 6)
    minimizeBtn.Parent = header

    -- ── Drag ──────────────────────────────────────────────────────────────────
    do
        local dragging = false
        local dragStart, startPos

        windowCleanup:Add(header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = window.Position
            end
        end))

        windowCleanup:Add(UIS.InputChanged:Connect(function(input)
            if dragging
            and (input.UserInputType == Enum.UserInputType.MouseMovement
              or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                window.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end))

        windowCleanup:Add(UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    -- ── Tab strip ─────────────────────────────────────────────────────────────
    local tabsStrip = create("ScrollingFrame", {
        Name = "Tabs",
        Size = UDim2.new(1, 0, 0, 44),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = T.panel2,
        ScrollBarThickness = 4,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, {})
    tabsStrip.Parent = window
    addCorner(tabsStrip, 10)
    addStroke(tabsStrip, T.stroke, 1, 0.5)
    addPadding(tabsStrip, 6)

    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.FillDirection = Enum.FillDirection.Horizontal
    tabsLayout.Padding = UDim.new(0, 6)
    tabsLayout.Parent = tabsStrip

    -- ── Content area ──────────────────────────────────────────────────────────
    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        BackgroundColor3 = T.bg,
    }, {})
    content.Parent = window
    addPadding(content, 6)

    -- ── Minimize hint (desktop only) ──────────────────────────────────────────
    local hidden    = false
    local shownHint = false

    local function showHint()
        if shownHint or isMobile() then return end
        shownHint = true
        local notif = create("Frame", {
            Size = UDim2.new(0, 260, 0, 90),
            Position = UDim2.new(1, -270, 1, -100),
            BackgroundColor3 = T.panel, ZIndex = 999,
        }, {})
        notif.Parent = gui
        addCorner(notif, 10)
        addStroke(notif, T.stroke, 1, 0.4)
        create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = "Press RightShift to open UI again",
            TextColor3 = T.text, Font = F, TextSize = 14, TextWrapped = true,
            Parent = notif,
        }, {})
        local ok = create("TextButton", {
            Size = UDim2.new(0.4, 0, 0, 28), Position = UDim2.new(0.3, 0, 1, -36),
            BackgroundColor3 = T.accent, Text = "OK",
            TextColor3 = Color3.new(1, 1, 1), Font = FB, TextSize = 14,
        }, {})
        addCorner(ok, 6); ok.Parent = notif
        ok.MouseButton1Click:Connect(function() notif:Destroy() end)
        task.delay(8, function()
            if notif and notif.Parent then notif:Destroy() end
        end)
    end

    -- ── Minimize / Close ──────────────────────────────────────────────────────
    addKeybind(Enum.KeyCode.RightShift, function()
        hidden = not hidden
        window.Visible = not hidden
        if hidden then showHint() end
    end)

    minimizeBtn.MouseButton1Click:Connect(function()
        hidden = not hidden
        window.Visible = not hidden
        if hidden then showHint() end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        windowCleanup:Destroy()
        gui:Destroy()
    end)

    -- ── Tab canvas ────────────────────────────────────────────────────────────
    local tabs = {}

    local function recalcTabsCanvas()
        local total = 0
        for _, child in ipairs(tabsStrip:GetChildren()) do
            if child:IsA("GuiObject") then
                total = total + child.AbsoluteSize.X + 6
            end
        end
        tabsStrip.CanvasSize = UDim2.new(0, total, 0, 0)
    end

    -- ── Public API ────────────────────────────────────────────────────────────
    local api = {}

    function api:AddSection(tabName)
        local isFirst = next(tabs) == nil

        -- Tab button
        local btn = create("TextButton", {
            Size = UDim2.new(0, 120, 1, -12),
            BackgroundColor3 = T.control,
            Text = tabName, TextColor3 = T.text, Font = F, TextSize = 16,
        }, {})
        addCorner(btn, 8)

        -- Hover: direct assignment, guard active tab (v2.0 behaviour — no tween conflict)
        btn.MouseEnter:Connect(function()
            if tabs[tabName] and tabs[tabName].page.Visible then return end
            btn.BackgroundColor3 = T.hover
        end)
        btn.MouseLeave:Connect(function()
            if tabs[tabName] and tabs[tabName].page.Visible then return end
            btn.BackgroundColor3 = T.control
        end)

        btn.Parent = tabsStrip
        recalcTabsCanvas()

        -- Page frame (full-size, only visible when this tab is active)
        local page = create("Frame", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = isFirst,
        }, {})
        page.Parent = content

        tabs[tabName] = { button = btn, page = page }
        if isFirst then
            btn.BackgroundColor3 = T.accent
            btn.Font = FB
        end

        btn.MouseButton1Click:Connect(function()
            for name, data in pairs(tabs) do
                data.page.Visible               = (name == tabName)
                data.button.BackgroundColor3    = (name == tabName) and T.accent or T.control
                data.button.Font                = (name == tabName) and FB or F
            end
        end)

        -- Two-column layout inside the page
        local container = create("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        }, {})
        container.Parent = page

        local columns = create("Frame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        }, {})
        columns.Parent = container

        local leftCol = create("ScrollingFrame", {
            Size = UDim2.new(0.5, -6, 1, 0),
            BackgroundTransparency = 1, ScrollBarThickness = 6,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, {})
        leftCol.Parent = columns

        local rightCol = create("ScrollingFrame", {
            Size = UDim2.new(0.5, -6, 1, 0),
            Position = UDim2.new(0.5, 6, 0, 0),
            BackgroundTransparency = 1, ScrollBarThickness = 6,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, {})
        rightCol.Parent = columns

        -- pageAPI returned to the caller
        local pageAPI = {}

        -- AddUnderSections: creates two named section panels (left + right column)
        function pageAPI:AddUnderSections(leftName, rightName)
            local leftSec  = SectionFactory(leftCol,  leftName,  D)
            local rightSec = SectionFactory(rightCol, rightName, D)
            return leftSec.API, rightSec.API
        end

        -- Rename the tab button at runtime
        function pageAPI:SetNameOfMainSection(newName)
            tabs[tabName].button.Text = newName
        end

        return pageAPI
    end

    -- Update header labels at runtime
    function api:SetHeader(leftText, rightText)
        leftTitle.Text  = leftText
        rightTitle.Text = rightText
    end

    -- ── Mobile floating toggle button ─────────────────────────────────────────
    if isMobile() then
        local toggleBtn = create("TextButton", {
            Size = UDim2.new(0, 60, 0, 60),
            Position = UDim2.new(0, 20, 0.5, 0),
            BackgroundColor3 = T.accent,
            Text = "UI", TextColor3 = Color3.new(1, 1, 1),
            Font = FB, TextSize = 16, ZIndex = 500,
        }, {})
        toggleBtn.Parent = gui
        addCorner(toggleBtn, 12)

        local dragging = false
        local dragStart, startPos2

        windowCleanup:Add(toggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos2 = toggleBtn.Position
            end
        end))
        windowCleanup:Add(UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                toggleBtn.Position = UDim2.new(
                    startPos2.X.Scale, startPos2.X.Offset + delta.X,
                    startPos2.Y.Scale, startPos2.Y.Offset + delta.Y
                )
            end
        end))
        windowCleanup:Add(UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        toggleBtn.MouseButton1Click:Connect(function()
            hidden = not hidden
            window.Visible = not hidden
        end)
    end

    return api
end

return Window
