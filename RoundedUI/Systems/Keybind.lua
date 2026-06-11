-- Systems/Keybind.lua
-- Global keybind registry.
-- Supports multiple callbacks per key, add/remove, and one-shot recorder.
--
-- Usage:
--   local KB = require(path.Systems.Keybind)
--   KB.init(globalCleanup)
--   KB.add(Enum.KeyCode.F, myFn)
--   KB.remove(Enum.KeyCode.F, myFn)
--   KB.record(function(keyCode) ... end)   -- next key press captured once

local UIS = game:GetService("UserInputService")

local keybinds          = {}
local currentRecorder   = nil   -- nil or function(KeyCode)

local function add(key, fn)
    if not key then return end
    local list = keybinds[key]
    if not list then list = {}; keybinds[key] = list end
    table.insert(list, fn)
end

local function remove(key, fn)
    if not key then return end
    local list = keybinds[key]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == fn then table.remove(list, i) end
    end
    if #list == 0 then keybinds[key] = nil end
end

-- Set a one-shot recorder: the next keyboard input will call fn(keyCode)
-- and clear the recorder.
local function record(fn)
    currentRecorder = fn
end

-- Call once at startup to wire the global InputBegan listener.
local function init(globalCleanup)
    local conn = UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- One-shot key recorder (used by ToggleWithBind / TextBind)
        if currentRecorder and input.UserInputType == Enum.UserInputType.Keyboard then
            local fn = currentRecorder
            currentRecorder = nil
            fn(input.KeyCode)
            return
        end

        local list = keybinds[input.KeyCode]
        if list then
            for _, fn in ipairs(list) do fn() end
        end
    end)

    if globalCleanup then globalCleanup:Add(conn) end
end

return {
    add    = add,
    remove = remove,
    record = record,
    init   = init,
    -- Expose recorder state for TextBind/ToggleWithBind inline writes
    _setRecorder = function(fn) currentRecorder = fn end,
}
