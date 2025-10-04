-- SumoFacade.lua
-- Фасад под DiscordLib-стиль, поверх SUMOHOOK.lua

local CORE_URL = "https://raw.githubusercontent.com/MortyMo22/ui-libs/refs/heads/main/SUMOHOOK.lua"

-- Включаем lib-режим для ядра
getgenv().SUMOHOOK_LIB_MODE = true

-- Загружаем ядро и получаем Interface
local Interface = loadstring(game:HttpGet(CORE_URL))()
assert(Interface, "SUMOHOOK core did not return Interface (проверь патч в конце файла).")

-- Обёртка в удобный API
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

                function Channel:Button(label, cb)
                    return Section:AddButton(label, { Callback = cb })
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
                    return Section:AddButton(" ", { Callback = function() end, Disabled = true })
                end

                return Channel
            end

            return Server
        end

        -- ВАЖНО: теперь Init вызывается вручную после построения UI
        function Win:Init()
            Interface:Init(title or "Window", nil, extra)
        end

        function Win:Flags()
            return Interface.Flags
        end
        function Win:Toggle()
            Interface:Toggle()
        end
        function Win:Unload()
            Interface:Unload()
        end

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
