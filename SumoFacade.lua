-- SumoFacade.lua (адаптивный фасад для SUMOHOOK.lua)

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
                    return callFirst(Section, {"AddButton","Button"}, label, opts)
                end

                -- Toggle
                function Channel:Toggle(label, opts)
                    return callFirst(Section, {"AddToggle","Toggle"}, label, opts or {})
                end

                -- Slider (с форматированием числа через Suffix)
                function Channel:Slider(label, opts)
                    local o = opts or {}
                    o.Min = o.Min or 0
                    o.Max = o.Max or 100
                    o.Value = o.Value or o.Min
                    o.Suffix = o.Suffix or ""
                    return callFirst(Section, {"AddSlider","Slider"}, label, o)
                end

                -- List / Dropdown
                function Channel:List(label, opts)
                    local o = opts or {}
                    o.Values = o.Values or {"Item 1","Item 2"}
                    o.Default = o.Default or o.Values[1]
                    o.Multi = o.Multi or false
                    return callFirst(Section, {"AddList","AddDropdown","Dropdown","List"}, label, o)
                end

                -- Bind / Keybind
                function Channel:Bind(label, opts)
                    local o = opts or {}
                    o.Default = o.Default or Enum.KeyCode.RightControl
                    return callFirst(Section, {"AddBind","AddKeybind","Keybind","Bind"}, label, o)
                end

                -- Color / Colorpicker
                function Channel:Color(label, opts)
                    local o = opts or {}
                    o.Default = o.Default or Color3.fromRGB(255, 60, 60)
                    return callFirst(Section, {"AddColor","AddColorpicker","Colorpicker","Color"}, label, o)
                end

                -- Separator (если нет — делаем пустую disabled кнопку)
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
