-- SumoFacade.lua
-- Фасад под DiscordLib-стиль, поверх оригинального SUMOHOOK.lua

local CORE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/SUMOHOOK.lua"

-- Включаем lib-режим для ядра
getgenv().SUMOHOOK_LIB_MODE = true

-- Загружаем ядро и получаем Interface
local Interface = loadstring(game:HttpGet(CORE_URL))()
assert(Interface, "SUMOHOOK core did not return Interface (проверь патч в конце файла).")

-- Обёртка в удобный API
local function makeFacade(Interface)
    local Facade = {}

    -- Окно: создаёт корневой GUI, возвращает объект окна
    function Facade:Window(title, extra)
        -- Инициализируем пустую структуру и рендерим корень
        Interface.Tabs = {}
        Interface.Flags = Interface.Flags or {}
        Interface:Init(title or "Window", nil, extra)

        local Win = {}

        -- Создать таб
        function Win:Server(name, icon)
            local Tab = Interface:AddTab(name or "Tab", icon)
            local Server = {}

            -- Создать секцию (канал), side: "Left" или "Right"
            function Server:Channel(sectionName, side)
                local Section = Tab:AddSection(sectionName or "Section", side or "Left")
                local Channel = {}

                -- Элементы (делегируются на оригинальные методы Section)
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
                    -- Если в оригинале есть реальный сепаратор — используй его.
                    -- Иначе кинем «пустую» кнопку как визуальный разделитель.
                    return Section:AddButton(" ", { Callback = function() end, Disabled = true })
                end

                return Channel
            end

            return Server
        end

        -- Хелперы управления окном
        function Win:Flags()
            return Interface.Flags
        end

        function Win:Toggle() -- показать/скрыть GUI
            Interface:Toggle()
        end

        function Win:Unload() -- полностью убрать GUI
            Interface:Unload()
        end

        -- Уведомление (если в ядре есть метод)
        function Facade:Notification(title, text, button)
            if Interface.Notification then
                Interface:Notification(title, text, button)
            end
        end

        return Win
    end

    return Facade
end

return makeFacade(Interface)
