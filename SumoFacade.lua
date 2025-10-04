-- SumoFacade.lua
-- Фасад под DiscordLib-стиль, поверх SUMOHOOK.lua (с lib-режимом)

local CORE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/SUMOHOOK.lua"

-- Включаем lib-режим для ядра
getgenv().SUMOHOOK_LIB_MODE = true

-- Загружаем ядро и получаем Interface
local Interface = loadstring(game:HttpGet(CORE_URL))()
assert(Interface, "SUMOHOOK core did not return Interface (проверь патч в конце файла).")

-- универсальный Notification-хелпер
local function safeNotify(title, text, button)
    -- 1) нативное уведомление библиотеки (если есть)
    if typeof(Interface.Notification) == "function" then
        Interface:Notification(title, text, button)
        return
    end
    if typeof(Interface.Notify) == "function" then
        Interface:Notify(title, text, button)
        return
    end
    if typeof(Interface.Message) == "function" then
        Interface:Message(title, text, button)
        return
    end
    -- 2) SetCore фолбэк (чтобы точно было видно)
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

                -- Элементы
                function Channel:Button(label, optsOrCb)
                    local opts = type(optsOrCb) == "function" and { Callback = optsOrCb } or (optsOrCb or {})
                    return Section:AddButton(label, opts)
                end
                function Channel:Toggle(label, opts)
                    return Section:AddToggle(label, opts or {})
                end
                function Channel:Slider(label, opts)
                    return Section:AddSlider(label, opts or {})
                end
                function Channel:List(label, opts)
                    return Section:AddList(label, opts or {})
                end
                function Channel:Bind(label, opts)
                    return Section:AddBind(label, opts or {})
                end
                function Channel:Color(label, opts)
                    return Section:AddColor(label, opts or {})
                end
                function Channel:Seperator()
                    -- Если в ядре есть реальный сепаратор — можно заменить на него.
                    return Section:AddButton(" ", { Callback = function() end, Disabled = true })
                end

                return Channel
            end

            return Server
        end

        -- Рендер
        function Win:Init()
            Interface:Init(title or "Window", nil, extra)
        end

        -- Хелперы
        function Win:Flags()
            return Interface.Flags
        end
        function Win:Toggle()
            Interface:Toggle()
        end
        function Win:Unload()
            Interface:Unload()
        end

        -- Уведомления через фасад
        function Facade:Notification(t, msg, btn)
            safeNotify(t, msg, btn)
        end

        return Win
    end

    return Facade
end

return makeFacade(Interface)
