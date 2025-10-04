-- SumoFacade.lua (финальный фасад для SUMOHOOK.lua)

local CORE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/SUMOHOOK.lua"

getgenv().SUMOHOOK_LIB_MODE = true
local Interface = loadstring(game:HttpGet(CORE_URL))()
assert(Interface, "SUMOHOOK core did not return Interface")

-- универсальный Notify
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

-- helper: безопасно вызвать первый существующий конструктор из списка имён
local function callFirst(section, names, ...)
    for _, name in ipairs(names) do
        local fn = section[name]
        if typeof(fn) == "function" then
            return fn(section, ...)
        end
    end
    return nil
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

                -- Toggle
                function Channel:Toggle(label, opts)
                    local o = opts or {}
                    o.Flag = tostring(o.Flag or label or "Toggle")
                    o.Default = (o.Default == true)
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddToggle","Toggle"}, tostring(label or "Toggle"), o)
                end

                -- Slider
                function Channel:Slider(label, opts)
                    local o = opts or {}
                    o.Min = tonumber(o.Min) or 0
                    o.Max = tonumber(o.Max) or 100
                    o.Value = tonumber(o.Value) or o.Min
                    o.Suffix = tostring(o.Suffix or "")
                    o.Flag = tostring(o.Flag or label or "Slider")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddSlider","Slider"}, tostring(label or "Slider"), o)
                end

                -- List / Dropdown
                function Channel:List(label, opts)
                    local o = opts or {}
                    o.Values = o.Values or {"Item 1","Item 2"}
                    o.Default = o.Default or o.Values[1]
                    o.Multi = (o.Multi == true)
                    o.Flag = tostring(o.Flag or label or "List")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddList","AddDropdown","Dropdown","List"}, tostring(label or "List"), o)
                end

                -- Bind / Keybind
                function Channel:Bind(label, opts)
                    local o = opts or {}
                    o.Default = o.Default or Enum.KeyCode.RightControl
                    o.Flag = tostring(o.Flag or label or "Bind")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddBind","AddKeybind","Keybind","Bind"}, tostring(label or "Bind"), o)
                end

                -- Color / Colorpicker
                function Channel:Color(label, opts)
                    local o = opts or {}
                    o.Default = o.Default or Color3.fromRGB(255, 60, 60)
                    o.Flag = tostring(o.Flag or label or "Color")
                    o.Callback = o.Callback or function() end
                    return callFirst(Section, {"AddColor","AddColorpicker","Colorpicker","Color"}, tostring(label or "Color"), o)
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
