-- Controls/LayoutControls.lua
-- Layout and composition controls: ScrollList, Card, Container, Pagination, VirtualList.
-- SearchBox lives in SimpleControls but is re-exported here for sectionAPI convenience.
--
-- deps table expected keys:
--   Theme, FONT, FONT_B, create, addCorner, addStroke, withHoverAnim, Anim,
--   CardAPI        (the Controls/CardAPI module)
--   windowCleanup  (Cleanup instance from CreateWindow)

local LayoutControls = {}

-- ─── ScrollList ───────────────────────────────────────────────────────────────

function LayoutControls.ScrollList(stack, deps, label, opts)
    local T, F = deps.Theme, deps.FONT
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local CardAPI = deps.CardAPI
    opts = opts or {}

    local height   = opts.Height  or 200
    local padding2 = opts.Padding or 4
    local yOffset  = 0

    local wrapper = create("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundTransparency = 1,
    }, {})
    wrapper.Parent = stack

    if label and label ~= "" then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
            Text = label, TextColor3 = T.textDim, Font = F, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = wrapper,
        }, {})
        yOffset = 22
        wrapper.Size = UDim2.new(1, 0, 0, height + yOffset)
    end

    local scroll = create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 0, height), Position = UDim2.new(0, 0, 0, yOffset),
        BackgroundColor3 = T.panel, ScrollBarThickness = 5,
        ScrollBarImageColor3 = T.stroke,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0,
        ClipsDescendants = true,
    }, {})
    scroll.Parent = wrapper
    addCorner(scroll, 8); addStroke(scroll, T.stroke, 1, 0.5)

    local il = Instance.new("UIListLayout")
    il.FillDirection = Enum.FillDirection.Vertical
    il.Padding = UDim.new(0, padding2)
    il.SortOrder = Enum.SortOrder.LayoutOrder
    il.Parent = scroll

    local ip = Instance.new("UIPadding")
    ip.PaddingTop = UDim.new(0, 4); ip.PaddingBottom = UDim.new(0, 4)
    ip.PaddingLeft = UDim.new(0, 4); ip.PaddingRight = UDim.new(0, 4)
    ip.Parent = scroll

    local listObj = {}

    function listObj:Clear()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end
    end
    function listObj:AddItem(frame)   frame.Parent = scroll end
    function listObj:SetPadding(px)   il.Padding = UDim.new(0, px) end
    function listObj:GetFrame()       return scroll end
    function listObj:SetHeight(px)
        scroll.Size  = UDim2.new(1, 0, 0, px)
        wrapper.Size = UDim2.new(1, 0, 0, px + yOffset)
    end
    function listObj:SetMaxHeight(px)
        if scroll.AbsoluteSize.Y > px then listObj:SetHeight(px) end
    end
    function listObj:Card()
        local cardFrame, innerStack = CardAPI.buildFrame(scroll, { widthOffset = -8 })
        return CardAPI.make(cardFrame, innerStack)
    end

    return listObj
end

-- ─── Card ─────────────────────────────────────────────────────────────────────

function LayoutControls.Card(stack, deps)
    local CardAPI = deps.CardAPI
    local cardFrame, innerStack = CardAPI.buildFrame(stack, {})
    return CardAPI.make(cardFrame, innerStack)
end

-- ─── Container ────────────────────────────────────────────────────────────────

function LayoutControls.Container(stack, deps, opts)
    local T = deps.Theme
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    opts = opts or {}

    local height     = opts.Height     or 150
    local scrollable = opts.Scrollable or false

    local outer = create("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = T.panel,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, {})
    outer.Parent = stack
    addCorner(outer, 8); addStroke(outer, T.stroke, 1, 0.5)

    local inner
    if scrollable then
        inner = create("ScrollingFrame", {
            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
            ScrollBarThickness = 5, ScrollBarImageColor3 = T.stroke,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, {})
    else
        inner = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, {})
    end
    inner.Parent = outer

    local obj = {}
    function obj:Mount(instance) instance.Parent = inner end
    function obj:GetFrame()      return outer end
    function obj:SetHeight(px)   outer.Size = UDim2.new(1, 0, 0, px) end
    return obj
end

-- ─── Pagination ───────────────────────────────────────────────────────────────

function LayoutControls.Pagination(stack, deps, opts)
    local T, F, FB = deps.Theme, deps.FONT, deps.FONT_B
    local create, addCorner, withHoverAnim, Anim = deps.create, deps.addCorner, deps.withHoverAnim, deps.Anim
    opts = opts or {}
    local align = opts.Align or "Center"

    local row = create("Frame", { Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 }, {})
    row.Parent = stack

    local rl = Instance.new("UIListLayout")
    rl.FillDirection = Enum.FillDirection.Horizontal
    rl.Padding = UDim.new(0, 6)
    rl.HorizontalAlignment =
        align == "Right" and Enum.HorizontalAlignment.Right  or
        align == "Left"  and Enum.HorizontalAlignment.Left   or
        Enum.HorizontalAlignment.Center
    rl.VerticalAlignment = Enum.VerticalAlignment.Center
    rl.Parent = row

    local prevBtn = create("TextButton", {
        Size = UDim2.new(0, 64, 0, 28), BackgroundColor3 = T.control,
        TextColor3 = T.text, Font = FB, TextSize = 14,
        Text = "◀ Prev", AutoButtonColor = false,
    }, {})
    addCorner(prevBtn, 7); prevBtn.Parent = row

    local pageLabel = create("TextLabel", {
        Size = UDim2.new(0, 80, 0, 28), BackgroundTransparency = 1,
        Text = "Page 1", TextColor3 = T.text, Font = F, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, {})
    pageLabel.Parent = row

    local nextBtn = create("TextButton", {
        Size = UDim2.new(0, 64, 0, 28), BackgroundColor3 = T.control,
        TextColor3 = T.text, Font = FB, TextSize = 14,
        Text = "Next ▶", AutoButtonColor = false,
    }, {})
    addCorner(nextBtn, 7); nextBtn.Parent = row

    local hasNext = false
    local hasPrev = false
    local pager   = {}
    pager.OnNext  = nil
    pager.OnPrev  = nil

    local function refresh()
        Anim:Play(prevBtn, Anim.Fast, { BackgroundColor3 = hasPrev and T.accent or T.control })
        Anim:Play(nextBtn, Anim.Fast, { BackgroundColor3 = hasNext and T.accent or T.control })
        prevBtn.TextColor3 = hasPrev and T.text or T.textDim
        nextBtn.TextColor3 = hasNext and T.text or T.textDim
    end

    prevBtn.MouseButton1Click:Connect(function()
        if hasPrev and pager.OnPrev then pager.OnPrev() end
    end)
    nextBtn.MouseButton1Click:Connect(function()
        if hasNext and pager.OnNext then pager.OnNext() end
    end)
    withHoverAnim(prevBtn, T.control, T.hover, Anim)
    withHoverAnim(nextBtn, T.control, T.hover, Anim)

    function pager:SetPage(n, total)
        pageLabel.Text = total
            and (tostring(n) .. " / " .. tostring(total))
            or  ("Page " .. tostring(n))
    end
    function pager:SetHasNext(v) hasNext = v; refresh() end
    function pager:SetHasPrev(v) hasPrev = v; refresh() end
    function pager:SetEnabled(v)
        prevBtn.Visible  = v
        nextBtn.Visible  = v
        pageLabel.Visible = v
    end
    function pager:GetFrame() return row end

    refresh()
    return pager
end

-- ─── VirtualList ──────────────────────────────────────────────────────────────

function LayoutControls.VirtualList(stack, deps, opts)
    local T = deps.Theme
    local create, addCorner, addStroke = deps.create, deps.addCorner, deps.addStroke
    local CardAPI = deps.CardAPI
    local windowCleanup = deps.windowCleanup
    opts = opts or {}

    local listHeight = opts.Height     or 260
    local itemHeight = opts.ItemHeight or 60
    local padding3   = opts.Padding    or 4

    local wrapper = create("Frame", {
        Size = UDim2.new(1, 0, 0, listHeight),
        BackgroundColor3 = T.panel, ClipsDescendants = true,
    }, {})
    wrapper.Parent = stack
    addCorner(wrapper, 8); addStroke(wrapper, T.stroke, 1, 0.5)

    local scroll = create("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        ScrollBarThickness = 5, ScrollBarImageColor3 = T.stroke,
        CanvasSize = UDim2.new(0, 0, 0, 0), ClipsDescendants = true,
    }, {})
    scroll.Parent = wrapper

    local rowContainer = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
    }, {})
    rowContainer.Parent = scroll

    -- ── Virtualization pool ───────────────────────────────────────────────────
    local items          = {}
    local renderer       = nil
    local pool           = {}
    local renderedFrames = {}

    local function getPooled()
        if #pool > 0 then
            local f = pool[#pool]; pool[#pool] = nil; f.Visible = true; return f
        end
        return nil
    end

    local function recycle(frame)
        for _, child in ipairs(frame:GetChildren()) do child:Destroy() end
        frame.Visible = false
        table.insert(pool, frame)
    end

    local function renderVisible()
        local scrollY  = scroll.CanvasPosition.Y
        local step     = itemHeight + padding3
        local firstI   = math.max(1, math.floor(scrollY / step) + 1)
        local visCount = math.ceil(listHeight / step) + 2
        local lastI    = math.min(#items, firstI + visCount - 1)

        for idx, frame in pairs(renderedFrames) do
            if idx < firstI or idx > lastI then
                recycle(frame); renderedFrames[idx] = nil
            end
        end

        for idx = firstI, lastI do
            if not renderedFrames[idx] and renderer then
                local frame = getPooled()
                if not frame then
                    frame = create("Frame", {
                        Size = UDim2.new(1, -8, 0, itemHeight),
                        BackgroundTransparency = 1,
                    }, {})
                    frame.Parent = rowContainer
                end
                frame.Position = UDim2.new(0, 4, 0, (idx - 1) * step)
                frame.Size     = UDim2.new(1, -8, 0, itemHeight)
                local rendered = renderer(items[idx], idx)
                if rendered then
                    rendered.Size   = UDim2.fromScale(1, 1)
                    rendered.Parent = frame
                end
                renderedFrames[idx] = frame
            end
        end
    end

    local function refreshCanvas()
        scroll.CanvasSize = UDim2.new(0, 0, 0, #items * (itemHeight + padding3))
        renderVisible()
    end

    local scrollConn = scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(renderVisible)
    windowCleanup:Add(scrollConn)

    -- ── Public API ────────────────────────────────────────────────────────────
    local vlist = {}

    function vlist:SetItems(dataArray)
        items = dataArray or {}
        for _, f in pairs(renderedFrames) do recycle(f) end
        renderedFrames = {}; refreshCanvas()
    end

    function vlist:SetRenderer(fn)
        renderer = fn
        for _, f in pairs(renderedFrames) do recycle(f) end
        renderedFrames = {}; renderVisible()
    end

    function vlist:UpdateItem(index, newData)
        items[index] = newData
        if renderedFrames[index] then
            recycle(renderedFrames[index]); renderedFrames[index] = nil
        end
        renderVisible()
    end

    function vlist:Clear()
        items = {}
        for _, f in pairs(renderedFrames) do recycle(f) end
        renderedFrames = {}; refreshCanvas()
    end

    function vlist:GetFrame() return wrapper end

    function vlist:Card()
        local cardFrame, innerStack = CardAPI.buildFrame(nil, {
            virtualList = true, innerPadding = 3,
        })
        -- VirtualList cards are not immediately parented to a fixed parent;
        -- the renderer callback is responsible for placing them.
        return CardAPI.make(cardFrame, innerStack)
    end

    return vlist
end

return LayoutControls
