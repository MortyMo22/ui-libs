-- SumoFacade.lua (адаптирован под реальные поля SUMOHOOK)

local CORE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/SUMOHOOK.lua"

getgenv().SUMOHOOK_LIB_MODE = true
local Interface = loadstring(game:HttpGet(CORE_URL))()
assert(Interface, "SUMOHOOK core did not return Interface")

local function safeNotify(title, text, button)
    if typeof(Interface.Notification) == "function" then
        Interface:Notification(title, text, button); return
    end
    local StarterGui = game:GetService("StarterGui")
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or "Notification"),
            Text = tostring(text or ""),
            Duration = 4,
            Button1 = tostring(button or "OK")
        })
    end)
end

local function callFirst(section, names, ...)
    for _, name in ipairs(names) do
        local fn = section[name]
        if typeof(fn) == "function" then
            return fn(section, ...)
        end
    end
end

local function makeFacade(Interface)
    local Facade = {}

    function Facade:Window(title, extra)
        Interface.Tabs = {}
        Interface.Flags = Interface.Flags or {}

        local Win = {}

        function Win:Server(name, icon)
            local Tab = Interface:AddTab(name or "Tab", icon)
            local Server = {}

            function Server:Channel(sectionName, side)
                local Section = Tab:AddSection(sectionName or "Section", side or "Left")
                local Channel = {}

                -- Button
                function Channel:Button(label, optsOrCb)
                    local opts = type(optsOrCb) == "function" and { Callback = optsOrCb } or (optsOrCb or {})
                    return callFirst(Section, {"AddButton","Button"}, tostring(label or "Button"), opts)
                end

                -- Toggle (SUMOHOOK: State, Flag, Callback)
                function Channel:Toggle(label, opts)
                    local o = opts or {}
                    o.Flag = tostring(o.Flag or label or "Toggle")
                    o.State = (o.State ~= nil) and (o.State == true) or (o.Default == true) or false
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddToggle","Toggle"}, tostring(label or "Toggle"), o)
                end

                -- Slider (SUMOHOOK: Min, Max, Value, Suffix, Flag)
                function Channel:Slider(label, opts)
                    local o = opts or {}
                    o.Min = tonumber(o.Min) or 0
                    o.Max = tonumber(o.Max) or 100
                    local defaultVal = tonumber(o.Value)
                    if defaultVal == nil then defaultVal = o.Min end
                    o.Value = defaultVal
                    o.Suffix = tostring(o.Suffix or "")
                    o.Flag = tostring(o.Flag or label or "Slider")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddSlider","Slider"}, tostring(label or "Slider"), o)
                end

                -- List / Dropdown (SUMOHOOK: Values, Value, Multi, Flag)
                function Channel:List(label, opts)
                    local o = opts or {}
                    o.Values = (type(o.Values) == "table" and #o.Values > 0) and o.Values or {"Item 1","Item 2"}
                    if o.Value == nil then
                        -- map с Default → Value, иначе первый элемент
                        o.Value = (o.Default ~= nil) and o.Default or o.Values[1]
                    end
                    o.Multi = (o.Multi == true) or (typeof(o.Value) == "table")
                    o.Flag = tostring(o.Flag or label or "List")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddList","List","AddDropdown","Dropdown"}, tostring(label or "List"), o)
                end

                -- Bind / Keybind (SUMOHOOK: Key, Flag)
                function Channel:Bind(label, opts)
                    local o = opts or {}
                    local def = o.Default or o.Key or Enum.KeyCode.RightControl
                    o.Key = (typeof(def) == "EnumItem") and def or Enum.KeyCode.RightControl
                    o.Flag = tostring(o.Flag or label or "Bind")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddBind","Bind","AddKeybind","Keybind"}, tostring(label or "Bind"), o)
                end

                -- Color / Colorpicker (SUMOHOOK: Color, Alpha, Flag)
                function Channel:Color(label, opts)
                    local o = opts or {}
                    o.Color = o.Color or o.Default or Color3.fromRGB(255, 60, 60)
                    o.Flag = tostring(o.Flag or label or "Color")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddColor","Color","AddColorpicker","Colorpicker"}, tostring(label or "Color"), o)
                end

                -- Separator
                function Channel:Seperator()
                    local sep = callFirst(Section, {"AddSeparator","Separator","Seperator"})
                    if not sep then
                        callFirst(Section, {"AddButton","Button"}, " ", {Disabled=true, Callback=function() end})
                    end
                    return sep
                end

                return Channel
            end

            return Server
        end

        function Win:Init()
            Interface:Init(title or "Window", nil, extra)
        end

        function Win:Flags() return Interface.Flags end
        function Win:Toggle() Interface:Toggle() end
        function Win:Unload() Interface:Unload() end

        function Facade:Notification(t, msg, btn) safeNotify(t, msg, btn) end

        return Win
    end

    return Facade
end

return makeFacade(Interface)
