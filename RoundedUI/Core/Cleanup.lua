-- Core/Cleanup.lua
-- RAII registry for RBXScriptConnections and Tweens.
-- Create one instance per logical lifetime (window, popup, etc.).
-- Call :Destroy() to disconnect everything at once.

local Cleanup = {}
Cleanup.__index = Cleanup

function Cleanup.new()
    return setmetatable({ _connections = {}, _tweens = {} }, Cleanup)
end

-- Add a RBXScriptConnection; returns it so callers can chain.
function Cleanup:Add(connection)
    if connection and connection.Connected ~= nil then
        table.insert(self._connections, connection)
    end
    return connection
end

-- Track a Tween for cancellation on Destroy.
function Cleanup:Track(tween)
    if tween then table.insert(self._tweens, tween) end
    return tween
end

-- Disconnect all connections and cancel all tweens.
function Cleanup:Destroy()
    for _, c in ipairs(self._connections) do
        if c and c.Connected then c:Disconnect() end
    end
    for _, t in ipairs(self._tweens) do
        if t then pcall(function() t:Cancel(); t:Destroy() end) end
    end
    self._connections = {}
    self._tweens = {}
end

return Cleanup
