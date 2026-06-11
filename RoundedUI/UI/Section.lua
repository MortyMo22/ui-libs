-- UI/Section.lua
-- Factory that creates a single named section panel (the grey box with a title)
-- and returns sectionAPI — the object callers use to add controls.
--
-- Called by UI/Window.lua's AddSection → pageAPI:AddUnderSections.
--
-- makeSection(parentCol, sectionName, sharedDeps) → { Raw, API }
--   Raw  = the sec Frame
--   API  = sectionAPI table
--
-- sharedDeps must contain ALL dependencies needed by every control module:
--   Theme, FONT, FONT_B, create, addCorner, addStroke, addPadding,
--   withHover, withHoverAnim, isMobile, Anim, UIS,
--   addKeybind, removeKeybind, setCurrentRecorder,
--   openColorPicker,     ← function(startColor, onApply)
--   windowCleanup,       ← Cleanup instance from CreateWindow
--   CardAPI, SimpleControls, ToggleControls, SelectControls, LayoutControls

local Section = {}

function Section.make(parentCol, sectionName, D)
    -- D = sharedDeps (see header above)
    local T, F, FB = D.Theme, D.FONT, D.FONT_B

    -- ── Per-section popup state ───────────────────────────────────────────────
    -- Both DropDown and List share one slot per section so opening one closes
    -- the other automatically.
    local openPopup = nil
    local popupDeps = {}  -- subset of D extended with popup accessors

    local function closeOpenPopup()
        if openPopup and openPopup.Parent then openPopup:Destroy() end
        openPopup = nil
    end

    -- Extend D with popup accessors for SelectControls
    for k, v in pairs(D) do popupDeps[k] = v end
    popupDeps.getOpenPopup   = function()       return openPopup end
    popupDeps.setOpenPopup   = function(frame)  openPopup = frame end
    popupDeps.closeOpenPopup = closeOpenPopup

    -- ── Section frame ─────────────────────────────────────────────────────────
    local sec = D.create("Frame", {
        Size = UDim2.new(1, -6, 0, 40),
        BackgroundColor3 = T.panel,
    }, {})
    sec.Parent = parentCol
    D.addCorner(sec, 10)
    D.addStroke(sec, T.stroke, 1, 0.6)
    D.addPadding(sec, 8)

    D.create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = sectionName or "",
        TextColor3 = T.text, Font = FB, TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sec,
    }, {})

    local stack = D.create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
    }, {})
    stack.Parent = sec

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = stack

    -- Auto-resize section height when stack content changes
    stack:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        sec.Size = UDim2.new(1, -6, 0, 24 + stack.AbsoluteSize.Y + 12)
    end)

    -- ── sectionAPI ────────────────────────────────────────────────────────────
    local SC = D.SimpleControls
    local TC = D.ToggleControls
    local SL = D.SelectControls
    local LC = D.LayoutControls

    local sectionAPI = {}

    -- Simple controls
    function sectionAPI:Label(text, opts)
        return SC.Label(stack, D, text, opts)
    end
    function sectionAPI:Separator()
        return SC.Separator(stack, D)
    end
    function sectionAPI:Button(text, callback)
        return SC.Button(stack, D, text, callback)
    end
    function sectionAPI:TextBox(placeholder, callback, opts)
        return SC.TextBox(stack, D, placeholder, callback, opts)
    end
    function sectionAPI:SearchBox(placeholder, callback, props)
        return SC.SearchBox(stack, D, placeholder, callback, props)
    end
    function sectionAPI:TextBind(labelText, initKey, callback)
        return SC.TextBind(stack, D, labelText, initKey, callback)
    end

    -- Toggle controls
    function sectionAPI:Toggle(text, opts)
        return TC.Toggle(stack, D, text, opts)
    end
    function sectionAPI:ToggleWithBind(text, opts)
        return TC.ToggleWithBind(stack, D, text, opts)
    end
    function sectionAPI:ToggleBind(text, opts)
        return TC.ToggleBind(stack, D, text, opts)
    end
    function sectionAPI:ToggleColor(text, defaultState, defaultColor, callback)
        return TC.ToggleColor(stack, D, text, defaultState, defaultColor, callback)
    end
    function sectionAPI:ToggleDualColor(text, defaultState, c1, c2, callback)
        return TC.ToggleDualColor(stack, D, text, defaultState, c1, c2, callback)
    end

    -- Select controls (popup deps, not plain D)
    function sectionAPI:Slider(text, cfg, callback)
        return SL.Slider(stack, popupDeps, text, cfg, callback)
    end
    function sectionAPI:DropDown(text, options, default, callback)
        return SL.DropDown(stack, popupDeps, text, options, default, callback)
    end
    function sectionAPI:List(text, options, callback)
        return SL.List(stack, popupDeps, text, options, callback)
    end

    -- Layout controls
    function sectionAPI:ScrollList(label, opts)
        return LC.ScrollList(stack, D, label, opts)
    end
    function sectionAPI:Card(opts)
        return LC.Card(stack, D)
    end
    function sectionAPI:Container(opts)
        return LC.Container(stack, D, opts)
    end
    function sectionAPI:Pagination(opts)
        return LC.Pagination(stack, D, opts)
    end
    function sectionAPI:VirtualList(opts)
        return LC.VirtualList(stack, D, opts)
    end

    return { Raw = sec, API = sectionAPI }
end

return Section
