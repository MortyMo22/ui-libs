-- Controls/CardAPI.lua
-- Shared card builder returned by ScrollList:Card(), Card(), and VirtualList:Card().
-- Accepts a pre-built cardFrame and an inner stack frame; returns a fluent API.
--
-- Dependencies injected via _inject(deps) from init.lua.

local _Theme, _FONT, _FONT_B
local _create, _addCorner, _withHoverAnim, _Anim

local CardAPI = {}

function CardAPI._inject(deps)
    _Theme        = deps.Theme
    _FONT         = deps.FONT
    _FONT_B       = deps.FONT_B
    _create       = deps.create
    _addCorner    = deps.addCorner
    _withHoverAnim= deps.withHoverAnim
    _Anim         = deps.Anim
end

-- Build a standard card frame with padding + inner stack.
-- parent : the frame to parent the card into (scroll or stack)
-- opts   : { padding=8, innerPadding=4, autoSize=true }
-- Returns { cardFrame, innerStack }
function CardAPI.buildFrame(parent, opts)
    opts = opts or {}
    local pad       = opts.padding      or 8
    local innerPad  = opts.innerPadding or 4
    local isVList   = opts.virtualList  or false

    local cardFrame = _create("Frame", {
        Size = isVList and UDim2.fromScale(1, 1) or UDim2.new(1, opts.widthOffset or 0, 0, 10),
        BackgroundColor3 = _Theme.panel2,
        BorderSizePixel = 0,
        AutomaticSize = isVList and Enum.AutomaticSize.None or Enum.AutomaticSize.Y,
    }, {})
    cardFrame.Parent = parent
    _addCorner(cardFrame, 8)

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = _Theme.stroke
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.4
    uiStroke.Parent = cardFrame

    local cp = Instance.new("UIPadding")
    cp.PaddingTop    = UDim.new(0, pad)
    cp.PaddingBottom = UDim.new(0, pad)
    cp.PaddingLeft   = UDim.new(0, pad)
    cp.PaddingRight  = UDim.new(0, pad)
    cp.Parent = cardFrame

    local innerStack = _create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, {})
    innerStack.Parent = cardFrame

    local cl = Instance.new("UIListLayout")
    cl.FillDirection = Enum.FillDirection.Vertical
    cl.Padding = UDim.new(0, innerPad)
    cl.Parent = innerStack

    return cardFrame, innerStack
end

-- Wrap cardFrame + innerStack into the fluent API object returned to callers.
function CardAPI.make(cardFrame, innerStack)
    local api = {}

    function api:GetFrame() return cardFrame end

    function api:Label(text, props)
        props = props or {}
        local lbl = _create("TextLabel", {
            Size = UDim2.new(1, 0, 0, (props.size or 14) + 2),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = props.color or _Theme.text,
            Font = props.bold and _FONT_B or _FONT,
            TextSize = props.size or 14,
            TextXAlignment = props.align or Enum.TextXAlignment.Left,
            TextWrapped = true,
        }, {})
        lbl.Parent = innerStack
        return lbl
    end

    function api:Button(text, callback, props)
        props = props or {}
        local btn = _create("TextButton", {
            Size = UDim2.new(props.fullWidth ~= false and 1 or 0, props.width or 0, 0, 28),
            BackgroundColor3 = props.color or _Theme.accent,
            TextColor3 = props.textColor or _Theme.text,
            Font = _FONT_B,
            TextSize = props.size or 14,
            Text = text,
        }, {})
        _addCorner(btn, 6)
        _withHoverAnim(btn, props.color or _Theme.accent, _Theme.accentDim, _Anim)
        btn.Parent = innerStack
        btn.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)
        return btn
    end

    function api:Row(props)
        props = props or {}
        local rowHeight = props.Height  or 28
        local spacing   = props.Spacing or 6
        local align     = props.Align   or "Left"

        local rowFrame = _create("Frame", {
            Size = UDim2.new(1, 0, 0, rowHeight),
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.Y,
        }, {})
        rowFrame.Parent = innerStack

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.Padding = UDim.new(0, spacing)
        rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rowLayout.HorizontalAlignment =
            align == "Center" and Enum.HorizontalAlignment.Center or
            align == "Right"  and Enum.HorizontalAlignment.Right  or
            Enum.HorizontalAlignment.Left
        rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        rowLayout.Parent = rowFrame

        local rowObj = {}

        function rowObj:GetFrame() return rowFrame end

        function rowObj:Label(text, rowProps)
            rowProps = rowProps or {}
            local lbl = _create("TextLabel", {
                Size = UDim2.new(0, 0, 0, rowHeight),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = rowProps.color or _Theme.text,
                Font = rowProps.bold and _FONT_B or _FONT,
                TextSize = rowProps.size or 13,
                TextXAlignment = rowProps.align or Enum.TextXAlignment.Left,
            }, {})
            lbl.Parent = rowFrame
            return lbl
        end

        function rowObj:Button(text, callback, rowProps)
            rowProps = rowProps or {}
            local btn = _create("TextButton", {
                Size = UDim2.new(0, rowProps.width or 70, 0, rowHeight - 2),
                BackgroundColor3 = rowProps.color or _Theme.accent,
                TextColor3 = rowProps.textColor or _Theme.text,
                Font = _FONT_B,
                TextSize = rowProps.size or 13,
                Text = text,
            }, {})
            _addCorner(btn, 6)
            _withHoverAnim(btn, rowProps.color or _Theme.accent, _Theme.accentDim, _Anim)
            btn.Parent = rowFrame
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        function rowObj:AddCustom(instance)
            instance.Parent = rowFrame
            return instance
        end

        return rowObj
    end

    return api
end

return CardAPI
